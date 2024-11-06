from django.http import JsonResponse
from django.views import View
from django.conf import settings
import googlemaps
import requests
import logging
import time

logger = logging.getLogger(__name__)

class LocationSearchView(View):
    def __init__(self):
        super().__init__()
        self.gmaps = googlemaps.Client(key=settings.GOOGLE_MAPS_API_KEY)

    def get_all_places(self, location, radius, type_list):
        """
        Get all places using multiple searches and pagination
        """
        keywords = ['bar', 'pub', 'tavern', 'brewery', 'beer', 'cocktail']
        all_places = []
            
        for place_type in type_list:
                try:
                    result = self.gmaps.places_nearby(
                        location=location,
                        radius=radius,
                        type=place_type
                    )
                    if result.get('results'):
                        all_places.extend(result['results'])

                    while 'next_page_token' in result:
                        time.sleep(2)
                        result = self.gmaps.places_nearby(
                            location=location,
                            radius=radius,
                            type=place_type,
                            page_token=result['next_page_token']
                        )
                        if result.get('results'):
                            all_places.extend(result['results'])

                except Exception as e:
                    logger.error(f"Error fetching {place_type}: {str(e)}")

            # Additional text searches for each keyword
        for keyword in keywords:
            try:
                text_results = self.gmaps.places(
                    query=keyword,
                    location=location,
                    radius=radius
                ).get('results', [])
                
                # Add only if place has liquor-related terms in name or types
                for place in text_results:
                    place_name_lower = place['name'].lower()
                    place_types = [t.lower() for t in place.get('types', [])]
                    
                    # Check if place is likely to serve alcohol
                    is_alcohol_venue = any(term in place_name_lower for term in [
                        'bar', 'pub', 'tavern', 'brewery', 'beer', 'wine', 
                        'spirits', 'cocktail', 'lounge', 'ale house'
                    ]) or any(t in place_types for t in [
                        'bar', 'night_club', 'brewery'
                    ])
                    
                    if is_alcohol_venue:
                        all_places.append(place)
                        
            except Exception as e:
                logger.error(f"Error in text search for {keyword}: {str(e)}")

        # Remove duplicates and filter out unwanted business types
        filtered_places = []
        seen_place_ids = set()
        
        for place in all_places:
            place_id = place['place_id']
            place_types = [t.lower() for t in place.get('types', [])]
            
            # Skip if we've seen this place before
            if place_id in seen_place_ids:
                continue
                
            # Skip if it matches unwanted business types
            if any(t in place_types for t in [
                'beauty_salon', 'hair_care', 'barber', 
                'grocery_store', 'supermarket', 'school',
                'store', 'church', 'mosque', 'temple'
            ]):
                continue
                
            # Add the place if it passes all filters
            filtered_places.append(place)
            seen_place_ids.add(place_id)

        return filtered_places
    

    def get(self, request):
        try:
            # If no parameters provided, return API documentation
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

            address = request.GET.get('address')
            radius = int(request.GET.get('radius', 10)) * 1609  # Convert miles to meters
            search_type = request.GET.get('type', 'bar')

            # Geocode the address
            geocode_result = self.gmaps.geocode(address)
            if not geocode_result:
                return JsonResponse({'error': 'Address not found'}, status=400)

            lat = geocode_result[0]['geometry']['location']['lat']
            lng = geocode_result[0]['geometry']['location']['lng']

            type_mappings = {
                'bar': ['bar', 'night_club'],
                'night_club': ['night_club', 'bar'],
                'brewery': ['brewery'],
                'pub': ['bar'] }

            search_types = type_mappings.get(search_type, [search_type])
            places = self.get_all_places(
                location=(lat, lng),
                radius=radius,
                type_list=search_types
            )

            # Format locations for response
            locations = []
            for place in places:
                locations.append({
                    'name': place['name'],
                    'address': place.get('vicinity', 'Address not available'),
                    'lat': place['geometry']['location']['lat'],
                    'lng': place['geometry']['location']['lng'],
                    'rating': place.get('rating', 'N/A'),
                    'user_ratings_total': place.get('user_ratings_total', 0),
                    'place_id': place['place_id']
                })

            # Sort locations by rating
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

        except Exception as e:
            logger.error(f"Error in location search: {str(e)}")
            return JsonResponse({'error': str(e)}, status=500)

class RouteView(View):
    def get(self, request):
        try:
            # Validate required parameters
            required_params = ['start_lat', 'start_lng', 'end_lat', 'end_lng']
            for param in required_params:
                if not request.GET.get(param):
                    return JsonResponse({
                        'error': f'Missing required parameter: {param}',
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

            return JsonResponse({
                'route': {
                    'start': {
                        'name': start_name,
                        'lat': float(start_lat),
                        'lng': float(start_lng)
                    },
                    'end': {
                        'name': end_name,
                        'lat': float(end_lat),
                        'lng': float(end_lng)
                    },
                    'summary': {
                        'distance': f"{distance_miles:.1f} miles",
                        'duration': f"{duration_minutes:.1f} minutes"
                    },
                    'steps': steps,
                    'coordinates': [
                        [coord[1], coord[0]] 
                        for coord in route_data['features'][0]['geometry']['coordinates']
                    ]
                }
            })

        except Exception as e:
            logger.error(f"Error calculating route: {str(e)}")
            return JsonResponse({'error': str(e)}, status=500)