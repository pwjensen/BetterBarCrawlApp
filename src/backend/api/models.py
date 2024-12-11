from django.db import models


class Location(models.Model):
    place_id = models.CharField(primary_key=True)
    name = models.CharField()
    address = models.CharField(blank=True, null=True)
    latitude = models.DecimalField(max_digits=10, decimal_places=7)
    longitude = models.DecimalField(max_digits=10, decimal_places=7)
    rating = models.DecimalField(blank=True, null=True, max_digits=2, decimal_places=1)
    user_ratings_total = models.IntegerField()
