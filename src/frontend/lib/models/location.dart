// lib/models/location.dart
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

class Location {
  final String id;
  final String name;
  final String address;
  final double latitude;
  final double longitude;
  final double rating;
  final int userRatingsTotal;
  final String placeId;

  const Location({
    required this.id,
    required this.name,
    required this.address,
    required this.latitude,
    required this.longitude,
    required this.rating,
    required this.userRatingsTotal,
    required this.placeId,
  });

  factory Location.fromJson(Map<String, dynamic> json) {
    return Location(
      id: json['id']?.toString() ?? '',
      name: json['name'] as String? ?? 'Unknown',
      address: json['address'] as String? ?? 'Address not available',
      latitude: (json['latitude'] as num?)?.toDouble() ?? 0.0,
      longitude: (json['longitude'] as num?)?.toDouble() ?? 0.0,
      rating: (json['rating'] as num?)?.toDouble() ?? 0.0,
      userRatingsTotal: json['user_ratings_total'] as int? ?? 0,
      placeId: json['place_id'] as String? ?? '',
    );
  }

  String get formattedAddress =>
      address == 'Address not available' ? 'Address not available' : address;

  String get formattedRating =>
      rating > 0 ? rating.toStringAsFixed(1) : 'No rating';

  bool get hasValidCoordinates => latitude != 0.0 && longitude != 0.0;

  Color getRatingColor() {
    if (rating >= 4.5) return Colors.green;
    if (rating >= 4.0) return Colors.lightGreen;
    if (rating >= 3.0) return Colors.orange;
    return Colors.red;
  }

  String formatRatingCount() {
    if (userRatingsTotal >= 1000) {
      return '${(userRatingsTotal / 1000).toStringAsFixed(1)}K reviews';
    }
    return '$userRatingsTotal reviews';
  }

  String getDistanceString(double currentLat, double currentLng) {
    if (!hasValidCoordinates) return 'Distance unavailable';

    final distanceInMiles =
        Geolocator.distanceBetween(currentLat, currentLng, latitude, longitude);

    return formatDistance(distanceInMiles);
  }

  String formatDistance(double miles) {
    if (miles < 1000) {
      return '${miles.round()}mi';
    } else {
      final m = (miles / 1000).toStringAsFixed(1);
      return '$m mi';
    }
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'address': address,
        'latitude': latitude,
        'longitude': longitude,
        'rating': rating,
        'user_ratings_total': userRatingsTotal,
        'place_id': placeId,
      };

  @override
  String toString() {
    return 'Location(name: $name, address: $address, latitude: $latitude, longitude: $longitude, rating: $rating, userRatingsTotal: $userRatingsTotal, placeId: $placeId)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is Location &&
        other.name == name &&
        other.address == address &&
        other.latitude == latitude &&
        other.longitude == longitude &&
        other.rating == rating &&
        other.userRatingsTotal == userRatingsTotal &&
        other.placeId == placeId;
  }

  @override
  int get hashCode {
    return name.hashCode ^
        address.hashCode ^
        latitude.hashCode ^
        longitude.hashCode ^
        rating.hashCode ^
        userRatingsTotal.hashCode ^
        placeId.hashCode;
  }
}
