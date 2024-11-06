from django.contrib import admin
from django.urls import path
from routeapp.views import RouteView, LocationSearchView

urlpatterns = [
    path('admin/', admin.site.urls),
    path('api/search/', LocationSearchView.as_view(), name='api_search'),
    path('api/route/', RouteView.as_view(), name='api_route'),
]