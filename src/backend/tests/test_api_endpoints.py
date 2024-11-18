from django.test import TestCase
from django.urls import reverse
from unittest.mock import patch

class LocationSearchTests(TestCase):
    def setUp(self):
        self.url = '/api/search/'

    def test_search_no_params(self):
        response = self.client.get(self.url)
        self.assertEqual(response.status_code, 200)
        self.assertIn('parameters', response.json())

    @patch('googlemaps.Client.geocode')
    def test_invalid_address(self, mock_geocode):
        mock_geocode.return_value = []
        response = self.client.get(f'{self.url}?address=xxxxx')
        self.assertEqual(response.status_code, 400)

    @patch('googlemaps.Client.geocode')
    @patch('googlemaps.Client.places_nearby')
    def test_valid_search(self, mock_places, mock_geocode):
        mock_geocode.return_value = [{'geometry': {'location': {'lat': 40, 'lng': -75}}}]
        mock_places.return_value = {'results': [{'name': 'Bar', 'place_id': '123'}]}
        
        response = self.client.get(f'{self.url}?address=Philadelphia&radius=5')
        self.assertEqual(response.status_code, 200)
        self.assertIn('locations', response.json())

class RouteTests(TestCase):
    def setUp(self):
        self.url = '/api/route/'
        self.params = {
            'start_lat': '40',
            'start_lng': '-75',
            'end_lat': '41',
            'end_lng': '-76'
        }

    def test_missing_params(self):
        response = self.client.get(self.url)
        self.assertEqual(response.status_code, 400)

    @patch('requests.get')
    def test_valid_route(self, mock_get):
        mock_get.return_value.json.return_value = {
            'features': [{
                'properties': {'segments': [{'distance': 1000, 'duration': 60}]},
                'geometry': {'coordinates': [[0,0], [1,1]]}
            }]
        }
        mock_get.return_value.status_code = 200
        
        response = self.client.get(self.url, self.params)
        self.assertEqual(response.status_code, 200)
        self.assertIn('route', response.json())