from django.test import Client, TestCase
from django.contrib.auth.models import User

class LoginTest(TestCase):
    @classmethod
    def setUpTestData(cls):
        # https://stackoverflow.com/a/33294746
        user = User.objects.create(username='john')
        user.set_password('12345')
        user.save()

    def test_login(self):
        c = Client()
        response = c.login(username="john", password="12345")
        assert response
