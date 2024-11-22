from django.test import TestCase
from django.contrib.auth.models import User
from unittest.mock import patch, MagicMock
import base64

TEST_LAT = "40.7128"
TEST_LNG = "-74.0060"
TEST_ADDRESS = "123 Test St"

TEST_USERNAME = "johnny"
TEST_PASSWORD = "reallygoodpassword"


def basic_auth_header(username, password):
    """Creates HTTP basic authentication header"""
    return f"Basic {base64.b64encode(bytes(f"{username}:{password}", "utf-8")).decode("utf-8")}"


def login(test_case: TestCase, username=TEST_USERNAME, password=TEST_PASSWORD):
    response = test_case.client.post(
        "/api/auth/login/",
        headers={"authorization": basic_auth_header(username, password)},
    )
    test_case.assertEqual(response.status_code, 200)
    return response.json()["token"]


class LocationTest(TestCase):
    @classmethod
    def setUpTestData(cls):
        # https://stackoverflow.com/a/33294746
        user = User.objects.create(
            username=TEST_USERNAME,
            email="johndoe@example.com",
            first_name="john",
            last_name="doe",
        )
        user.set_password(TEST_PASSWORD)
        user.save()


    @patch('googlemaps.Client')
    def test_location_search(self, mock_client):
        gmaps_mock = MagicMock()
        mock_client.return_value = gmaps_mock
        gmaps_mock.geocode.return_value = [{
            'geometry': {
                'location': {
                    'lat': float(TEST_LAT),
                    'lng': float(TEST_LNG)
                }
            }
        }]

        response = self.client.get(
            "/api/search/",
            {"address": TEST_ADDRESS},
            headers={"authorization": f"Token {login(self)}"}
        )
        self.assertEqual(response.status_code, 200)
        data = response.json()
        self.assertIn('search_params', data)
        self.assertIn('locations', data)

    @patch('googlemaps.Client')
    def test_invalid_location_search(self, mock_client):
        gmaps_mock = MagicMock()
        mock_client.return_value = gmaps_mock

        gmaps_mock.geocode.return_value = []

        response = self.client.get(
            "/api/search/",
            {"address": "INVALID_ADDRESS_XXX"},
            headers={"authorization": f"Token {login(self)}"}
        )
        self.assertEqual(response.status_code, 400)


    def test_missing_address_parameter(self):
        response = self.client.get(
            "/api/search/",
            headers={"authorization": f"Token {login(self)}"}
        )
        self.assertEqual(response.status_code, 200)  
        data = response.json()
        self.assertIn('parameters', data)  


class RouteTest(TestCase):
    @classmethod
    def setUpTestData(cls):
        # https://stackoverflow.com/a/33294746
        user = User.objects.create(
            username=TEST_USERNAME,
            email="johndoe@example.com",
            first_name="john",
            last_name="doe",
        )
        user.set_password(TEST_PASSWORD)
        user.save()

    @patch('requests.get')
    def test_get_route(self, mock_get):
        mock_response = MagicMock()
        mock_response.status_code = 200
        mock_response.json.return_value = {
            'features': [{
                'properties': {
                    'segments': [{
                        'distance': 1000,
                        'duration': 60
                    }]
                },
                'geometry': {
                    'coordinates': [
                        [float(TEST_LNG), float(TEST_LAT)],
                        [-73.9851, 40.7589]
                    ]
                }
            }]
        }
        mock_get.return_value = mock_response

        response = self.client.get(
            "/api/route/",
            {
                "start_lat": TEST_LAT,
                "start_lng": TEST_LNG,
                "end_lat": "40.7589",
                "end_lng": "-73.9851"
            },
            headers={"authorization": f"Token {login(self)}"}
        )
        self.assertEqual(response.status_code, 200)
        self.assertIn('route', response.json())
            
    @patch('requests.get')
    def test_invalid_route(self, mock_get):
        mock_response = MagicMock()
        mock_response.status_code = 400
        mock_get.return_value = mock_response

        response = self.client.get(
            "/api/route/",
            {
                "start_lat": "INVALID",
                "start_lng": TEST_LNG,
                "end_lat": "40.7589",
                "end_lng": "-73.9851"
            },
            headers={"authorization": f"Token {login(self)}"}
        )
        self.assertEqual(response.status_code, 400)
        self.assertIn('error', response.json())

    @patch('requests.get')
    def test_missing_route_parameters(self, mock_get):
        response = self.client.get(
            "/api/route/",
            headers={"authorization": f"Token {login(self)}"}
        )
        self.assertEqual(response.status_code, 400)
        data = response.json()
        self.assertIn('required_parameters', data)

    @patch('requests.get')
    def test_partial_route_parameters(self, mock_get):
        response = self.client.get(
            "/api/route/",
            {"start_lat": TEST_LAT},
            headers={"authorization": f"Token {login(self)}"}
        )
        self.assertEqual(response.status_code, 400)
        data = response.json()
        self.assertIn('error', data)
        self.assertIn('Missing required parameters', data['error'])

