// lib/models/search_response.dart
import 'package:geolocator/geolocator.dart';
import 'location.dart';
import 'search_params.dart';
import 'sort_option.dart';

class SearchResponse {
  final List<Location> locations;
  final SearchParams searchParams;
  final int totalLocations;

  const SearchResponse({
    required this.locations,
    required this.searchParams,
    required this.totalLocations,
  });

  factory SearchResponse.fromJson(Map<String, dynamic> json) {
    return SearchResponse(
      locations: (json['locations'] as List)
          .map((location) => Location.fromJson(location))
          .toList(),
      searchParams:
          SearchParams.fromJson(json['search_params'] as Map<String, dynamic>),
      totalLocations: json['total_locations'] as int,
    );
  }

  List<Location> getSortedLocations(SortOption sortOption,
      {double? currentLat, double? currentLng}) {
    final List<Location> sortedList = List.from(locations);

    switch (sortOption) {
      case SortOption.distance:
        if (currentLat != null && currentLng != null) {
          sortedList.sort((a, b) {
            final distanceA = Geolocator.distanceBetween(
              currentLat,
              currentLng,
              a.latitude,
              a.longitude,
            );
            final distanceB = Geolocator.distanceBetween(
              currentLat,
              currentLng,
              b.latitude,
              b.longitude,
            );
            return distanceA.compareTo(distanceB);
          });
        }
        break;
      case SortOption.rating:
        sortedList.sort((b, a) => a.rating.compareTo(b.rating));
        break;
      case SortOption.name:
        sortedList.sort(
            (a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
        break;
      case SortOption.reviewCount:
        sortedList
            .sort((b, a) => a.userRatingsTotal.compareTo(b.userRatingsTotal));
        break;
    }

    return sortedList;
  }

  Map<String, dynamic> toJson() => {
        'locations': locations.map((location) => location.toJson()).toList(),
        'search_params': searchParams.toJson(),
        'total_locations': totalLocations,
      };

  SearchResponse copyWith({
    List<Location>? locations,
    SearchParams? searchParams,
    int? totalLocations,
  }) {
    return SearchResponse(
      locations: locations ?? this.locations,
      searchParams: searchParams ?? this.searchParams,
      totalLocations: totalLocations ?? this.totalLocations,
    );
  }

  bool get hasResults => locations.isNotEmpty;

  double? getAverageRating() {
    if (locations.isEmpty) return null;
    final totalRating =
        locations.fold<double>(0, (sum, location) => sum + location.rating);
    return totalRating / locations.length;
  }

  int getTotalReviews() {
    return locations.fold<int>(
        0, (sum, location) => sum + location.userRatingsTotal);
  }

  Location? getHighestRated() {
    if (locations.isEmpty) return null;
    return locations
        .reduce((curr, next) => curr.rating > next.rating ? curr : next);
  }

  Location? getMostReviewed() {
    if (locations.isEmpty) return null;
    return locations.reduce((curr, next) =>
        curr.userRatingsTotal > next.userRatingsTotal ? curr : next);
  }

  @override
  String toString() {
    return 'SearchResponse(locations: ${locations.length}, searchParams: $searchParams, totalLocations: $totalLocations)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is SearchResponse &&
        other.locations == locations &&
        other.searchParams == searchParams &&
        other.totalLocations == totalLocations;
  }

  @override
  int get hashCode {
    return locations.hashCode ^ searchParams.hashCode ^ totalLocations.hashCode;
  }
}
