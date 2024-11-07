from django.test import Client, TestCase
from django.contrib.auth.models import User
from django.http import HttpResponse
import base64


class LoginTest(TestCase):
    def auth_header(self, username, password):
        """Creates HTTP basic authentication header"""
        return f"Basic {base64.b64encode(bytes(f"{username}:{password}", "utf-8")).decode("utf-8")}"

    @classmethod
    def setUpTestData(cls):
        # https://stackoverflow.com/a/33294746
        user = User.objects.create(username="john")
        user.set_password("12345")
        user.save()

    def test_login(self):
        c = Client()
        response: HttpResponse = c.post("/api/auth/login/", headers={"authorization": self.auth_header("john", "12345")})
        assert response.status_code == 200
