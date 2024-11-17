from django.contrib.auth.models import User
from knox.auth import TokenAuthentication
from knox.views import LoginView as KnoxLoginView
from rest_framework import mixins
from rest_framework.authentication import BasicAuthentication
from rest_framework.decorators import action
from rest_framework.permissions import AllowAny, IsAuthenticated
from rest_framework.viewsets import GenericViewSet

from .serializers import RegisterSerializer, UserSerializer


class LoginView(KnoxLoginView):
    authentication_classes = [BasicAuthentication]


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
