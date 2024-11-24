// lib/models/search_params.dart
class SearchParams {
  final String longitude;
  final String latitude;
  final double radiusMiles;
  final String type;

  const SearchParams({
    required this.longitude,
    required this.latitude,
    required this.radiusMiles,
    required this.type,
  });

  factory SearchParams.fromJson(Map<String, dynamic> json) {
    return SearchParams(
      longitude: json['longitude'] as String,
      latitude: json['latitude'] as String,
      radiusMiles: (json['radius_miles'] as num).toDouble(),
      type: json['type'] as String,
    );
  }

  Map<String, dynamic> toJson() => {
        'longitude': longitude,
        'latitude': latitude,
        'radius_miles': radiusMiles,
        'type': type,
      };

  @override
  String toString() {
    return 'SearchParams(longitude: $longitude, latitude: $latitude, radiusMiles: $radiusMiles, type: $type)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is SearchParams &&
        other.longitude == longitude &&
        other.latitude == latitude &&
        other.radiusMiles == radiusMiles &&
        other.type == type;
  }

  @override
  int get hashCode {
    return longitude.hashCode ^
        latitude.hashCode ^
        radiusMiles.hashCode ^
        type.hashCode;
  }

  SearchParams copyWith({
    String? longitude,
    String? latitude,
    double? radiusMiles,
    String? type,
  }) {
    return SearchParams(
      longitude: longitude ?? this.longitude,
      latitude: latitude ?? this.latitude,
      radiusMiles: radiusMiles ?? this.radiusMiles,
      type: type ?? this.type,
    );
  }
}
