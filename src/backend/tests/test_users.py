from django.test import TestCase
from django.contrib.auth.models import User
import base64

TEST_USERNAME = "johnny"
TEST_PASSWORD = "reallygoodpassword"


def basic_auth_header(username, password):
    """Creates HTTP basic authentication header"""
    return f"Basic {base64.b64encode(bytes(f"{username}:{password}", "utf-8")).decode("utf-8")}"


class UserTest(TestCase):
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

    def login(self, username=TEST_USERNAME, password=TEST_PASSWORD):
        return self.client.post(
            "/api/auth/login/",
            headers={"authorization": basic_auth_header(username, password)},
        )

    def test_login(self):
        response = self.login()
        self.assertEqual(response.status_code, 200)

    def test_get_user(self):
        response = self.login()
        self.assertEqual(response.status_code, 200)
        token = response.json()["token"]

        response = self.client.get(
            "/api/user/", headers={"authorization": f"Token {token}"}
        )
        self.assertEqual(response.status_code, 200)
        body = response.json()
        self.assertEqual(body["username"], TEST_USERNAME)
        self.assertEqual(body["email"], "johndoe@example.com")
        self.assertEqual(body["first_name"], "john")
        self.assertEqual(body["last_name"], "doe")

    def test_logout(self):
        response = self.login()
        self.assertEqual(response.status_code, 200)
        token = response.json()["token"]

        response = self.client.post(
            "/api/auth/logout/", headers={"authorization": f"Token {token}"}
        )
        self.assertEqual(response.status_code, 204)
        # Check that token is now invalid

        response = self.client.get(
            "/api/user/", headers={"authorization": f"Token {token}"}
        )
        self.assertEqual(response.status_code, 401)

    def test_logout_all(self):
        """Tests logging in multiple times and making sure logout_all invalidates all tokens"""
        response = self.login()
        self.assertEqual(response.status_code, 200)
        token1 = response.json()["token"]

        response = self.login()
        self.assertEqual(response.status_code, 200)
        token2 = response.json()["token"]

        response = self.client.post(
            "/api/auth/logoutall/", headers={"authorization": f"Token {token1}"}
        )
        self.assertEqual(response.status_code, 204)

        # Check that all tokens are invalid
        response = self.client.get(
            "/api/user/", headers={"authorization": f"Token {token1}"}
        )
        self.assertEqual(response.status_code, 401)

        response = self.client.get(
            "/api/user/", headers={"authorization": f"Token {token2}"}
        )
        self.assertEqual(response.status_code, 401)

    def test_delete(self):
        response = self.login()
        self.assertEqual(response.status_code, 200)
        token = response.json()["token"]

        response = self.client.delete(
            "/api/user/", headers={"authorization": f"Token {token}"}
        )
        self.assertEqual(response.status_code, 204)

        # Check that the user was actually deleted
        response = self.login()
        self.assertEqual(response.status_code, 401)

    def test_registration(self):
        response = self.client.post(
            "/api/user/",
            data={
                "username": "NewGuy",
                "password": "newguyspassword",
                "password2": "newguyspassword",
                "email": "testemail@test.com",
                "first_name": "John",
                "last_name": "Doe",
            },
        )
        self.assertEqual(response.status_code, 201)

        response = self.login("NewGuy", "newguyspassword")
        self.assertEqual(response.status_code, 200)
