from django.http import JsonResponse
from django.views import View
from django.conf import settings
import googlemaps
import requests
import logging
import time

from knox.views import LoginView as KnoxLoginView
from rest_framework.authentication import BasicAuthentication

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
            return JsonResponse({'error': str(e)}, status=500)
    return wrapper

class LocationSearchView(View):
    def __init__(self):
        super().__init__()
        self.gmaps = googlemaps.Client(key=settings.GOOGLE_MAPS_API_KEY)
        
    def get_places_by_type(self, location, radius, place_type):
        """
        Get places of a specific type with pagination handling
        """
        places = []
        result = self.gmaps.places_nearby(
            location=location,
            radius=radius,
            type=place_type
        )
        
        if result.get('results'):
            places.extend(result['results'])

        while 'next_page_token' in result:
            time.sleep(2)  # Respect API rate limits
            result = self.gmaps.places_nearby(
                location=location,
                radius=radius,
                type=place_type,
                page_token=result['next_page_token']
            )
            if result.get('results'):
                places.extend(result['results'])
                
        return places

    def get_places_by_keyword(self, location, radius, keyword):
        """
        Get places by keyword search
        """
        results = self.gmaps.places(
            query=keyword,
            location=location,
            radius=radius
        ).get('results', [])
        
        return [place for place in results if self.is_alcohol_venue(place)]

    def is_alcohol_venue(self, place):
        """Check if a place is likely to serve alcohol"""
        alcohol_terms = {'bar', 'pub', 'tavern', 'brewery', 'beer', 'wine', 
                        'spirits', 'cocktail', 'lounge', 'ale house'}
        alcohol_types = {'bar', 'night_club', 'brewery'}
        
        place_name = place['name'].lower()
        place_types = {t.lower() for t in place.get('types', [])}
        
        return (any(term in place_name for term in alcohol_terms) or 
                any(t in alcohol_types for t in place_types))

    def filter_places(self, places):
        """Filter out duplicates and unwanted business types"""
        unwanted_types = {'beauty_salon', 'hair_care', 'barber', 'grocery_store', 
                         'supermarket', 'school', 'store'}
        
        seen_place_ids = set()
        filtered_places = []
        
        for place in places:
            place_id = place['place_id']
            place_types = {t.lower() for t in place.get('types', [])}
            
            if place_id not in seen_place_ids and not (unwanted_types & place_types):
                filtered_places.append(place)
                seen_place_ids.add(place_id)
                
        return filtered_places

    @handle_api_error
    def get(self, request):
        if not request.GET.get('address'):
            return JsonResponse({
                'message': 'Please provide search parameters',
                'parameters': {
                    'address': 'string (required)',
                    'radius': 'integer (optional, default: 10 miles)',
                    'type': 'string (optional, default: bar)'
                },
                'example': '/api/search/?address=Philadelphia&radius=5&type=bar'
            })

        # Get and process search parameters
        address = request.GET.get('address')
        radius = int(request.GET.get('radius', 10)) * 1609  # Convert miles to meters
        search_type = request.GET.get('type', 'bar')

        # Geocode address
        geocode_result = self.gmaps.geocode(address)
        if not geocode_result:
            return JsonResponse({'error': 'Address not found'}, status=400)

        location = (
            geocode_result[0]['geometry']['location']['lat'],
            geocode_result[0]['geometry']['location']['lng']
        )

        # Get places based on type and keywords
        type_mappings = {
            'bar': ['bar', 'night_club'],
            'night_club': ['night_club', 'bar'],
            'brewery': ['brewery'],
            'pub': ['bar']
        }
        
        search_types = type_mappings.get(search_type, [search_type])
        keywords = ['bar', 'pub', 'tavern', 'brewery', 'beer', 'cocktail']
        
        # Collect all places
        all_places = []
        for place_type in search_types:
            all_places.extend(self.get_places_by_type(location, radius, place_type))
        for keyword in keywords:
            all_places.extend(self.get_places_by_keyword(location, radius, keyword))

        # Filter and format results
        filtered_places = self.filter_places(all_places)
        locations = [{
            'name': place['name'],
            'address': place.get('vicinity', 'Address not available'),
            'lat': place['geometry']['location']['lat'],
            'lng': place['geometry']['location']['lng'],
            'rating': place.get('rating', 'N/A'),
            'user_ratings_total': place.get('user_ratings_total', 0),
            'place_id': place['place_id']
        } for place in filtered_places]

        # Sort by rating
        locations.sort(
            key=lambda x: (float(x['rating']) if x['rating'] != 'N/A' else 0),
            reverse=True
        )

        return JsonResponse({
            'locations': locations,
            'search_params': {
                'address': address,
                'radius_miles': radius/1609,
                'type': search_type,
            },
            'total_locations': len(locations)
        })

class RouteView(View):
    @handle_api_error
    def get(self, request):
        # Validate required parameters
        required_params = ['start_lat', 'start_lng', 'end_lat', 'end_lng']
        missing_params = [param for param in required_params if not request.GET.get(param)]
        
        if missing_params:
            return JsonResponse({
                'error': f'Missing required parameters: {", ".join(missing_params)}',
                'required_parameters': {
                    'start_lat': 'float (required)',
                    'start_lng': 'float (required)',
                    'end_lat': 'float (required)',
                    'end_lng': 'float (required)',
                    'start_name': 'string (optional)',
                    'end_name': 'string (optional)'
                },
                'example': '/api/route/?start_lat=39.9526&start_lng=-75.1652&end_lat=39.9496&end_lng=-75.1503'
            }, status=400)

        # Get parameters
        start_lat = request.GET.get('start_lat')
        start_lng = request.GET.get('start_lng')
        end_lat = request.GET.get('end_lat')
        end_lng = request.GET.get('end_lng')
        start_name = request.GET.get('start_name', 'Start')
        end_name = request.GET.get('end_name', 'End')

        # Calculate route using ORS API
        url = 'https://api.openrouteservice.org/v2/directions/driving-car'
        headers = {
            'Authorization': settings.ORS_API_KEY,
            'Content-Type': 'application/json; charset=utf-8'
        }
        params = {
            'start': f"{start_lng},{start_lat}",
            'end': f"{end_lng},{end_lat}",
            'instructions': 'true',
            'units': 'mi'
        }

        response = requests.get(url, headers=headers, params=params)
        response.raise_for_status()
        route_data = response.json()

        # Extract route details
        route_summary = route_data['features'][0]['properties']['segments'][0]
        duration_minutes = route_summary['duration'] / 60
        distance_miles = route_summary['distance'] / 1609.34

        # Format steps if available
        steps = []
        if 'steps' in route_summary:
            for step in route_summary['steps']:
                steps.append({
                    'instruction': step.get('instruction', ''),
                    'distance': f"{step['distance'] / 1609.34:.1f} miles",
                    'duration': f"{step['duration'] / 60:.1f} minutes"
                })

    
        # Format route response
        return JsonResponse({
            'route': {
                'start': {
                    'name': request.GET.get('start_name', 'Start'),
                    'lat': float(request.GET['start_lat']),
                    'lng': float(request.GET['start_lng'])
                },
                'end': {
                    'name': request.GET.get('end_name', 'End'),
                    'lat': float(request.GET['end_lat']),
                    'lng': float(request.GET['end_lng'])
                },
                'summary': {
                    'distance': f"{route_summary['distance'] / 1609.34:.1f} miles",
                    'duration': f"{route_summary['duration'] / 60:.1f} minutes"
                },
                'steps': [{
                    'instruction': step.get('instruction', ''),
                    'distance': f"{step['distance'] / 1609.34:.1f} miles",
                    'duration': f"{step['duration'] / 60:.1f} minutes"
                } for step in route_summary.get('steps', [])],
                'coordinates': [
                    [coord[1], coord[0]] 
                    for coord in route_data['features'][0]['geometry']['coordinates']
                ]
            }
        })