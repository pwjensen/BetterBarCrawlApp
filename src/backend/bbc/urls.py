from django.contrib import admin
from django.urls import include, path
from rest_framework.routers import Route, SimpleRouter

from api.views import LoginView, UserViewSet


# I honestly don't rly know how the drf router works, but this made it work ig and i dont feel like finding the "correct" way to do this
class UserRouter(SimpleRouter):
    routes = [
        Route(
            url="^{prefix}$",
            mapping={"get": "retrieve", "post": "create", "delete": "destroy"},
            name="{basename}",
            detail=True,
            initkwargs={"suffix": "Detail"},
        ),
    ]


user_router = UserRouter()
user_router.register("api/user/", UserViewSet, basename="user")


urlpatterns = [
    path("admin/", admin.site.urls),
    path("api/auth/login/", LoginView.as_view(), name="knox_login"),  # The Knox login view is overwritten
    # Knox's token authentication is the only auth method allowed globally
    # This means that the login endpoint can only be authenticated with a token, which is impossible to do without already having logged in
    # To resolve this catch 22, only the login endpoint is overridden to accept HTTP Basic Authentication
    # All other endpoints expect a header `Authorization: Token <token>`
    path("api/auth/", include("knox.urls")),
]

urlpatterns += user_router.urls
