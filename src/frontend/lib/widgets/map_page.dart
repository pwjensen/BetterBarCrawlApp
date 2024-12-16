import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:open_route_service/open_route_service.dart';
import 'package:geolocator/geolocator.dart';
import 'package:app_settings/app_settings.dart';
import '../config.dart';
import 'package:flutter_map_geojson/flutter_map_geojson.dart';
import 'package:http/http.dart' as http;
import '../services/token_storage.dart';
import 'dart:convert';
import 'dart:io';
import '../models/location.dart';
import 'directions_page.dart';

class MapPage extends StatefulWidget {
  final MapPageState state;

  const MapPage({super.key, required this.state});

  @override
  State<MapPage> createState() => MapPageState();
}

class MapPageState extends State<MapPage> {
  List<LatLng> routePoints = [];
  LatLng? currentLocation;
  final MapController mapController = MapController();
  bool _mounted = true;
  bool _isLoadingRoute = false;
  String? _errorMessage;
  final OpenRouteService client =
      OpenRouteService(apiKey: Config.openRouteServiceApiKey);
  final GeoJsonParser geoJsonParser = GeoJsonParser();
  List<Location> locations = [];
  Map<String, dynamic>? _routeData;

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  @override
  void dispose() {
    _mounted = false;
    super.dispose();
  }

  Future<void> _getCurrentLocation() async {
    try {
      bool serviceEnabled;
      LocationPermission permission;

      serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        _showLocationServiceDialog();
        return;
      }

      permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          _showPermissionDeniedDialog();
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        _showPermissionDeniedForeverDialog();
        return;
      }

      Position position = await Geolocator.getCurrentPosition();
      if (_mounted) {
        setState(() {
          currentLocation = LatLng(position.latitude, position.longitude);
          _errorMessage = null;
        });

        mapController.move(currentLocation!, 15);
        await _getRoute([]);
      }
    } catch (e) {
      if (_mounted) {
        setState(() {
          _errorMessage = 'Error getting location: ${e.toString()}';
        });
      }
    }
  }

  Future<void> _getRoute(List<Location> locations) async {
    if (currentLocation == null || locations.isEmpty) return;

    setState(() {
      _isLoadingRoute = true;
      _errorMessage = null;
    });

    try {
      final token = await TokenStorage.getToken();
      if (token == null) {
        throw Exception('No auth token found');
      }

      // Prepare the request body
      final body = {
        'start_location': {
          'latitude': currentLocation!.latitude,
          'longitude': currentLocation!.longitude,
        },
        'locations': locations
            .map((loc) => {
                  'id': loc.id,
                  'name': loc.name,
                  'latitude': loc.latitude,
                  'longitude': loc.longitude,
                })
            .toList(),
      };

      // Send request to optimize-crawl endpoint
      final response = await http.post(
        Uri.parse('${Config.apiBaseUrl}/api/optimize-crawl'),
        headers: {
          HttpHeaders.authorizationHeader: 'Token $token',
          HttpHeaders.contentTypeHeader: 'application/json',
        },
        body: jsonEncode(body),
      );

      if (response.statusCode == 200) {
        final geojson = jsonDecode(response.body);

        // Clear existing route
        setState(() {
          routePoints = [];
        });

        // Parse the GeoJSON and update the map
        geoJsonParser.parseGeoJson(geojson);

        // Update the map with the new route
        setState(() {
          routePoints = geoJsonParser.polylines.isNotEmpty
              ? geoJsonParser.polylines.first.points
                  .map((point) => LatLng(point.latitude, point.longitude))
                  .toList()
              : [];
          _isLoadingRoute = false;
        });
      } else {
        throw Exception('Failed to get route: ${response.statusCode}');
      }
    } catch (e) {
      if (_mounted) {
        setState(() {
          _errorMessage = 'Error getting route: ${e.toString()}';
          _isLoadingRoute = false;
        });
      }
    }
  }

  void _showLocationServiceDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Location Services Disabled'),
          content: const Text(
              'Please enable location services to use this feature.'),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Open Settings'),
              onPressed: () {
                Navigator.of(context).pop();
                AppSettings.openAppSettings(type: AppSettingsType.location);
              },
            ),
          ],
        );
      },
    );
  }

  void _showPermissionDeniedDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Location Permission Denied'),
          content: const Text(
              'Please grant location permission to use this feature.'),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Open Settings'),
              onPressed: () {
                Navigator.of(context).pop();
                AppSettings.openAppSettings(type: AppSettingsType.location);
              },
            ),
          ],
        );
      },
    );
  }

  void _showPermissionDeniedForeverDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Location Permission Permanently Denied'),
          content: const Text(
              'Please enable location permission in app settings to use this feature.'),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Open Settings'),
              onPressed: () {
                Navigator.of(context).pop();
                AppSettings.openAppSettings(type: AppSettingsType.location);
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        FlutterMap(
          mapController: mapController,
          options: MapOptions(
            initialCenter:
                currentLocation ?? const LatLng(37.4220698, -122.0862784),
            initialZoom: 12,
          ),
          children: [
            TileLayer(
              urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
              userAgentPackageName: 'com.example.frontend',
              additionalOptions: const {
                'User-Agent': 'frontend/1.0',
              },
              tileProvider: NetworkTileProvider(),
            ),
            if (_routeData != null) ...[
              if (routePoints.isNotEmpty)
                PolylineLayer(
                  polylines: [
                    Polyline(
                      points: routePoints,
                      color: Colors.blue,
                      strokeWidth: 4.0,
                    ),
                  ],
                ),
              MarkerLayer(
                markers: [
                  if (_routeData!['ordered_locations'] != null)
                    ..._routeData!['ordered_locations']
                        .map<Marker>((location) => Marker(
                              width: 40.0,
                              height: 40.0,
                              point: LatLng(
                                double.parse(location['latitude']),
                                double.parse(location['longitude']),
                              ),
                              child: const Icon(
                                Icons.location_on,
                                color: Colors.red,
                                size: 40.0,
                              ),
                            )),
                ],
              ),
            ],
            MarkerLayer(
              markers: [
                if (currentLocation != null)
                  Marker(
                    width: 40.0,
                    height: 40.0,
                    point: currentLocation!,
                    child: const Icon(
                      Icons.my_location,
                      color: Colors.blue,
                      size: 40.0,
                    ),
                  ),
              ],
            ),
          ],
        ),
        if (_isLoadingRoute)
          const Center(
            child: CircularProgressIndicator(),
          ),
        if (_errorMessage != null)
          Positioned(
            bottom: 16,
            left: 16,
            right: 16,
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color.fromRGBO(255, 17, 0, 0.898),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                _errorMessage!,
                style: const TextStyle(color: Colors.white),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        if (_routeData != null && _routeData!['ordered_locations'] != null)
          Positioned(
            bottom: 16,
            right: 16,
            child: FloatingActionButton.extended(
              onPressed: () {
                // Convert the JSON locations back to Location objects
                final orderedLocations = _routeData!['ordered_locations']
                    .map<Location>((loc) => Location(
                          id: loc['id'],
                          name: loc['name'],
                          latitude: double.parse(loc['latitude']),
                          longitude: double.parse(loc['longitude']),
                          address: loc['address'] ?? '',
                          rating: loc['rating']?.toDouble() ?? 0.0,
                          userRatingsTotal: loc['user_ratings_total'] ?? 0,
                          placeId: loc['place_id'] ?? '',
                        ))
                    .toList();

                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => DirectionsPage(
                      routeData: _routeData!,
                      orderedLocations: orderedLocations,
                    ),
                  ),
                );
              },
              label: const Text('View Directions'),
              icon: const Icon(Icons.directions),
            ),
          ),
      ],
    );
  }

  void updateRouteData(Map<String, dynamic> data) {
    setState(() {
      _routeData = data;

      if (data['geo_json'] != null) {
        geoJsonParser.parseGeoJson(data['geo_json']);
        routePoints = geoJsonParser.polylines.isNotEmpty
            ? geoJsonParser.polylines.first.points
                .map((point) => LatLng(point.latitude, point.longitude))
                .toList()
            : [];
      }

      if (data['ordered_locations'] != null) {
        locations = (data['ordered_locations'] as List).map<Location>((loc) {
          return Location(
            id: loc['place_id'] ?? '',
            name: loc['name'] ?? 'Unknown',
            address: loc['address'] ?? 'No address',
            latitude: double.tryParse(loc['latitude'] ?? '0') ?? 0.0,
            longitude: double.tryParse(loc['longitude'] ?? '0') ?? 0.0,
            rating: double.tryParse(loc['rating']?.toString() ?? '0') ?? 0.0,
            userRatingsTotal: loc['user_ratings_total'] ?? 0,
            placeId: loc['place_id'] ?? '',
          );
        }).toList();
      }
    });
  }
}
