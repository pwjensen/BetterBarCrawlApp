"""
URL configuration for bbc project.

The `urlpatterns` list routes URLs to views. For more information please see:
    https://docs.djangoproject.com/en/5.1/topics/http/urls/
Examples:
Function views
    1. Add an import:  from my_app import views
    2. Add a URL to urlpatterns:  path('', views.home, name='home')
Class-based views
    1. Add an import:  from other_app.views import Home
    2. Add a URL to urlpatterns:  path('', Home.as_view(), name='home')
Including another URLconf
    1. Import the include() function: from django.urls import include, path
    2. Add a URL to urlpatterns:  path('blog/', include('blog.urls'))
"""

from django.contrib import admin
from django.urls import path, include
from api.views import LoginView, UserView

urlpatterns = [
    path("admin/", admin.site.urls),
    path("api/auth/login/", LoginView.as_view(), name="knox_login"),  # The Knox login view is overwritten
    # Knox's token authentication is the only auth method allowed globally
    # This means that the login endpoint can only be authenticated with a token, which is impossible to do without already having logged in
    # To resolve this catch 22, the only the login endpoint is overridden to accept HTTP Basic Authentication
    # All other endpoints expect a header `Authorization: Token <token>`
    path("api/auth/", include("knox.urls")),
    path("api/user/", UserView.as_view(), name="user"),
]
