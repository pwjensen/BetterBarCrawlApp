from django.test import TestCase
from django.contrib.auth.models import User
from unittest.mock import patch, MagicMock
from api.models import Location
import requests
import base64

TEST_LAT = "40.7128"
TEST_LNG = "-74.0060"
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

    @patch("googlemaps.Client")
    def test_location_search(self, mock_client):
        #Test successful location search with valid coordinates
        # Mocks Google Maps API response and verifies search endpoint

        gmaps_mock = MagicMock()
        mock_client.return_value = gmaps_mock
        gmaps_mock.geocode.return_value = [{"geometry": {"location": {"lat": float(TEST_LAT), "lng": float(TEST_LNG)}}}]

        response = self.client.get(
            "/api/search/",
            {"longitude": TEST_LNG, "latitude": TEST_LAT},
            headers={"authorization": f"Token {login(self)}"},
        )
        self.assertEqual(response.status_code, 200)
        data = response.json()
        self.assertIn("search_params", data)
        self.assertIn("locations", data)

    def test_missing_address_parameter(self):
        response = self.client.get("/api/search/", headers={"authorization": f"Token {login(self)}"})
        self.assertEqual(response.status_code, 200)
        data = response.json()
        self.assertIn("parameters", data)


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

    @patch("requests.get")
    def test_get_route(self, mock_get):
        # Test successful route calculation between two points
        mock_response = MagicMock()
        mock_response.status_code = 200
        mock_response.json.return_value = {
            "features": [
                {
                    "properties": {"segments": [{"distance": 1000, "duration": 60}]},
                    "geometry": {"coordinates": [[float(TEST_LNG), float(TEST_LAT)], [-73.9851, 40.7589]]},
                }
            ]
        }
        mock_get.return_value = mock_response

        response = self.client.get(
            "/api/route/",
            {"start_lat": TEST_LAT, "start_lng": TEST_LNG, "end_lat": "40.7589", "end_lng": "-73.9851"},
            headers={"authorization": f"Token {login(self)}"},
        )
        self.assertEqual(response.status_code, 200)
        self.assertIn("route", response.json())

    @patch("requests.get")
    def test_invalid_route(self, mock_get):
        mock_response = MagicMock()
        mock_response.status_code = 400
        mock_get.return_value = mock_response

        response = self.client.get(
            "/api/route/",
            {"start_lat": "INVALID", "start_lng": TEST_LNG, "end_lat": "40.7589", "end_lng": "-73.9851"},
            headers={"authorization": f"Token {login(self)}"},
        )
        self.assertEqual(response.status_code, 400)
        self.assertIn("error", response.json())

    @patch("requests.get")
    def test_missing_route_parameters(self, mock_get):
        response = self.client.get("/api/route/", headers={"authorization": f"Token {login(self)}"})
        self.assertEqual(response.status_code, 400)
        data = response.json()
        self.assertIn("required_parameters", data)

    @patch("requests.get")
    def test_partial_route_parameters(self, mock_get):
        response = self.client.get(
            "/api/route/", {"start_lat": TEST_LAT}, headers={"authorization": f"Token {login(self)}"}
        )
        self.assertEqual(response.status_code, 400)
        data = response.json()
        self.assertIn("error", data)
        self.assertIn("Missing required parameters", data["error"])


class OptimizedCrawlTest(TestCase):
    @classmethod
    def setUpTestData(cls):
        # Test user
        user = User.objects.create(
            username=TEST_USERNAME,
            email="john@example.com",
            first_name="John",
            last_name="Doe"
        )
        user.set_password(TEST_PASSWORD)
        user.save()

        # Test locations
        Location.objects.create(
            place_id="place1",
            name="Location 1",
            latitude=40.7128,
            longitude=-74.0060,
            rating=4.5,
            user_ratings_total=100
        )
        Location.objects.create(
            place_id="place2",
            name="Location 2", 
            latitude=40.7589,
            longitude=-73.9851,
            rating=4.0,
            user_ratings_total=50
        )

    def setUp(self):
        # Runs before each test method. Logs in and gets authentication token for API requests.
        self.token = login(self)
        self.headers = {"authorization": f"Token {self.token}"}

    @patch('requests.get')
    def test_successful_optimization(self, mock_get):
        # Mock matrix API response
        matrix_response = MagicMock(spec=requests.Response)
        matrix_response.status_code = 200
        matrix_response.json.return_value = {
            "durations": [[0, 1000], [1000, 0]],
            "distances": [[0, 2000], [2000, 0]]
        }
        
        # Mock route API response
        route_response = MagicMock(spec=requests.Response)
        route_response.status_code = 200
        route_response.json.return_value = {
            "type": "FeatureCollection",
            "features": [{
                "properties": {
                    "segments": [{"distance": 2000, "duration": 1000}]
                },
                "geometry": {
                    "coordinates": [[-74.0060, 40.7128], [-73.9851, 40.7589]]
                }
            }]
        }
        
        mock_get.side_effect = [matrix_response, route_response]

        response = self.client.get(
            "/api/optimize-crawl/",
            {"location": ["place1", "place2"]},
            headers=self.headers
        )
        
        self.assertEqual(response.status_code, 200)
        data = response.json()
        self.assertIn("total_distance_miles", data)
        self.assertIn("total_time_seconds", data)
        self.assertIn("ordered_locations", data)
        self.assertIn("geo_json", data)

    def test_missing_locations(self):
        response = self.client.get(
            "/api/optimize-crawl/",
            headers=self.headers
        )
        self.assertEqual(response.status_code, 400)
        self.assertTrue(len(response.content) > 0)

    @patch('requests.get')
    def test_invalid_locations(self, mock_get):
        mock_response = MagicMock(spec=requests.Response)
        mock_response.status_code = 400
        def raise_error(*args, **kwargs):
            raise requests.exceptions.HTTPError(
                "400 Client Error", 
                response=mock_response
            )
        mock_get.side_effect = raise_error

        response = self.client.get(
            "/api/optimize-crawl/",
            {"location": ["invalid1", "invalid2"]},
            headers=self.headers
        )
        
        self.assertEqual(response.status_code, 400)
