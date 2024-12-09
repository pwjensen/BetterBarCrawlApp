import googlemaps
import requests
import logging
import time
from django.contrib.auth.models import User
from django.http import JsonResponse
from django.views import View
from django.conf import settings
from knox.auth import TokenAuthentication
from knox.views import LoginView as KnoxLoginView
from rest_framework import mixins
from rest_framework.authentication import BasicAuthentication
from rest_framework.decorators import action
from rest_framework.permissions import AllowAny, IsAuthenticated
from rest_framework.viewsets import GenericViewSet
from rest_framework.views import APIView

from .serializers import RegisterSerializer, UserSerializer

logger = logging.getLogger(__name__)


class LoginView(KnoxLoginView):
    authentication_classes = [BasicAuthentication]


def handle_api_error(func):
    """Decorator to handle API errors consistently"""

    def wrapper(*args, **kwargs):
        try:
            return func(*args, **kwargs)
        except Exception as e:
            logger.error(f"API Error in {func.__name__}: {str(e)}")
            return JsonResponse({"error": str(e)}, status=500)

    return wrapper


class LocationSearchView(APIView):
    authentication_classes = (TokenAuthentication,)
    permission_classes = (IsAuthenticated,)

    def __init__(self):
        super().__init__()
        self.gmaps = googlemaps.Client(key=settings.GOOGLE_MAPS_API_KEY)

    def get_places_by_type(self, location, radius, place_type):
        """
        Get places of a specific type with pagination handling
        """
        places = []
        result = self.gmaps.places_nearby(location=location, radius=radius, type=place_type)

        if result.get("results"):
            places.extend(result["results"])

        while "next_page_token" in result:
            time.sleep(2)  # Respect API rate limits
            result = self.gmaps.places_nearby(
                location=location, radius=radius, type=place_type, page_token=result["next_page_token"]
            )
            if result.get("results"):
                places.extend(result["results"])

        return places

    def get_places_by_keyword(self, location, radius, keyword):
        """
        Get places by keyword search
        """
        results = self.gmaps.places(query=keyword, location=location, radius=radius).get("results", [])

        return [place for place in results if self.is_alcohol_venue(place)]

    def is_alcohol_venue(self, place):
        """Check if a place is likely to serve alcohol"""
        alcohol_terms = {
            "bar",
            "pub",
            "tavern",
            "brewery",
            "beer",
            "wine",
            "spirits",
            "cocktail",
            "lounge",
            "ale house",
        }
        alcohol_types = {"bar", "night_club", "brewery"}

        place_name = place["name"].lower()
        place_types = {t.lower() for t in place.get("types", [])}

        return any(term in place_name for term in alcohol_terms) or any(t in alcohol_types for t in place_types)

    def filter_places(self, places):
        """Filter out duplicates and unwanted business types"""
        unwanted_types = {"beauty_salon", "hair_care", "barber", "grocery_store", "supermarket", "school", "store"}

        seen_place_ids = set()
        filtered_places = []

        for place in places:
            place_id = place["place_id"]
            place_types = {t.lower() for t in place.get("types", [])}

            if place_id not in seen_place_ids and not (unwanted_types & place_types):
                filtered_places.append(place)
                seen_place_ids.add(place_id)

        return filtered_places

    def get(self, request):
        if not (request.GET.get("latitude") and request.GET.get("latitude")):
            return JsonResponse(
                {
                    "message": "Please provide search parameters",
                    "parameters": {
                        "latitude": "float (required)",
                        "longitude": "float (required)",
                        "radius": "integer (optional, default: 10 miles)",
                        "type": "string (optional, default: bar)",
                    },
                    "example": "/api/search/?address=Philadelphia&radius=5&type=bar",
                }
            )

        # Get and process search parameters
        latitude = request.GET.get("latitude")
        longitude = request.GET.get("longitude")
        radius = int(request.GET.get("radius", 10)) * 1609  # Convert miles to meters
        search_type = request.GET.get("type", "bar")

        location = (latitude, longitude)

        # Get places based on type and keywords
        type_mappings = {
            "bar": ["bar", "night_club"],
            "night_club": ["night_club", "bar"],
            "brewery": ["brewery"],
            "pub": ["bar"],
        }

        search_types = type_mappings.get(search_type, [search_type])
        keywords = ["bar", "pub", "tavern", "brewery", "beer", "cocktail"]

        # Collect all places
        all_places = []
        for place_type in search_types:
            all_places.extend(self.get_places_by_type(location, radius, place_type))
        for keyword in keywords:
            all_places.extend(self.get_places_by_keyword(location, radius, keyword))

        # Filter and format results
        filtered_places = self.filter_places(all_places)
        locations = [
            {
                "name": place["name"],
                "address": place.get("vicinity", "Address not available"),
                "latitude": place["geometry"]["location"]["lat"],
                "longitude": place["geometry"]["location"]["lng"],
                "rating": place.get("rating", "N/A"),
                "user_ratings_total": place.get("user_ratings_total", 0),
                "place_id": place["place_id"],
            }
            for place in filtered_places
        ]

        # Sort by rating
        locations.sort(key=lambda x: (float(x["rating"]) if x["rating"] != "N/A" else 0), reverse=True)

        return JsonResponse(
            {
                "locations": locations,
                "search_params": {
                    "longitude": longitude,
                    "latitude": latitude,
                    "radius_miles": radius / 1609,
                    "type": search_type,
                },
                "total_locations": len(locations),
            }
        )


class RouteView(APIView):
    authentication_classes = (TokenAuthentication,)
    permission_classes = (IsAuthenticated,)

    @handle_api_error
    def get(self, request):
        # Validate required parameters
        required_params = ["start_lat", "start_lng", "end_lat", "end_lng"]
        missing_params = [param for param in required_params if not request.GET.get(param)]

        if missing_params:
            return JsonResponse(
                {
                    "error": f'Missing required parameters: {", ".join(missing_params)}',
                    "required_parameters": {
                        "start_lat": "float (required)",
                        "start_lng": "float (required)",
                        "end_lat": "float (required)",
                        "end_lng": "float (required)",
                        "start_name": "string (optional)",
                        "end_name": "string (optional)",
                    },
                    "example": "/api/route/?start_lat=39.9526&start_lng=-75.1652&end_lat=39.9496&end_lng=-75.1503",
                },
                status=400,
            )

        try:
            start_lat = float(request.GET.get("start_lat"))
            start_lng = float(request.GET.get("start_lng"))
            end_lat = float(request.GET.get("end_lat"))
            end_lng = float(request.GET.get("end_lng"))
        except ValueError:
            return JsonResponse(
                {
                    "error": "Invalid coordinates. Latitude and longitude must be valid numbers.",
                    "example": "/api/route/?start_lat=39.9526&start_lng=-75.1652&end_lat=39.9496&end_lng=-75.1503",
                },
                status=400,
            )
        start_name = request.GET.get("start_name", "Start")
        end_name = request.GET.get("end_name", "End")

        url = "https://api.openrouteservice.org/v2/directions/foot-walking"
        headers = {"Authorization": settings.ORS_API_KEY, "Content-Type": "application/json; charset=utf-8"}
        params = {
            "start": f"{start_lng},{start_lat}",
            "end": f"{end_lng},{end_lat}",
            "instructions": "true",
            "units": "mi",
        }

        response = requests.get(url, headers=headers, params=params)
        response.raise_for_status()
        route_data = response.json()

        # Extract route details
        route_summary = route_data["features"][0]["properties"]["segments"][0]
        duration_minutes = route_summary["duration"] / 60
        distance_miles = route_summary["distance"] / 1609.34

        steps = []
        if "steps" in route_summary:
            for step in route_summary["steps"]:
                steps.append(
                    {
                        "instruction": step.get("instruction", ""),
                        "distance": f"{step['distance'] / 1609.34:.1f} miles",
                        "duration": f"{step['duration'] / 60:.1f} minutes",
                    }
                )

        # Format route response
        return JsonResponse(
            {
                "route": {
                    "start": {
                        "name": request.GET.get("start_name", "Start"),
                        "lat": float(request.GET["start_lat"]),
                        "lng": float(request.GET["start_lng"]),
                    },
                    "end": {
                        "name": request.GET.get("end_name", "End"),
                        "lat": float(request.GET["end_lat"]),
                        "lng": float(request.GET["end_lng"]),
                    },
                    "summary": {
                        "distance": f"{route_summary['distance'] / 1609.34:.1f} miles",
                        "duration": f"{route_summary['duration'] / 60:.1f} minutes",
                    },
                    "steps": [
                        {
                            "instruction": step.get("instruction", ""),
                            "distance": f"{step['distance'] / 1609.34:.1f} miles",
                            "duration": f"{step['duration'] / 60:.1f} minutes",
                        }
                        for step in route_summary.get("steps", [])
                    ],
                    "coordinates": [
                        [coord[1], coord[0]] for coord in route_data["features"][0]["geometry"]["coordinates"]
                    ],
                }
            }
        )


class UserViewSet(mixins.CreateModelMixin, mixins.RetrieveModelMixin, mixins.DestroyModelMixin, GenericViewSet):
    queryset = User.objects.all()

    def get_serializer_class(self):
        if self.action == "retrieve":
            return UserSerializer
        elif self.action == "create":
            return RegisterSerializer
        return None

    @action(
        methods=["get"],
        detail=False,
        authentication_classes=[TokenAuthentication],
        permission_classes=[IsAuthenticated],
        url_path="user",
    )
    def retrieve_user(self, request, *args, **kwargs):
        return super().retrieve(request, *args, **kwargs)

    @action(
        methods=["delete"],
        detail=False,
        authentication_classes=[TokenAuthentication],
        permission_classes=[IsAuthenticated],
        url_path="user",
    )
    def destroy_user(self, request, *args, **kwargs):
        return super().destroy(request, *args, **kwargs)

    @action(methods=["post"], detail=False, authentication_classes=[], permission_classes=[AllowAny], url_path="user")
    def create_user(self, request, *args, **kwargs):
        return super().create(request, *args, **kwargs)

    def get_object(self):
        return self.request.user
