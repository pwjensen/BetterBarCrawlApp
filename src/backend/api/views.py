from .serializers import RegisterSerializer, UserSerializer

from knox.views import LoginView as KnoxLoginView
from knox.auth import TokenAuthentication

from django.shortcuts import render
from django.contrib.auth.models import User
from django.http.request import HttpRequest
from django.http.response import HttpResponseNotAllowed

from rest_framework.authentication import BasicAuthentication
from rest_framework import generics
from rest_framework.permissions import AllowAny, IsAuthenticated
from rest_framework.views import APIView


class LoginView(KnoxLoginView):
    authentication_classes = [BasicAuthentication]


class UserView(APIView):
    def delete(self, request, *args, **kwargs):
        # See third comment on https://stackoverflow.com/a/29399032
        # DRF views expect a normal django request object, and when they get one, they automatically upgrade it to a DRF request
        # So when this view gets a Django request, it upgrades it to a DRF request, so when I pass it down to another DRF view
        # It breaks because that one is also expecting a normal Django request. Adding ._request gets around this by getting the
        # original Django request object out of the DRF one.
        return DeleteUserView.as_view()(request._request, *args, **kwargs)

    def post(self, request, *args, **kwargs):
        return RegisterUserView.as_view()(request._request, *args, **kwargs)

    def get(self, request, *args, **kwargs):
        return GetUserView.as_view()(request._request, *args, **kwargs)


class GetUserView(generics.RetrieveAPIView):
    queryset = User.objects.all()
    authentication_classes = [TokenAuthentication]
    permission_classes = [IsAuthenticated]
    serializer_class = UserSerializer

    def get_object(self):
        return self.request.user


class DeleteUserView(generics.DestroyAPIView):
    queryset = User.objects.all()
    authentication_classes = [TokenAuthentication]
    permission_classes = [IsAuthenticated]

    def get_object(self):
        return self.request.user


class RegisterUserView(generics.CreateAPIView):
    queryset = User.objects.all()
    authentication_classes = []
    permission_classes = (AllowAny,)
    serializer_class = RegisterSerializer
