import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:open_route_service/open_route_service.dart';
import 'package:geolocator/geolocator.dart';
import 'package:app_settings/app_settings.dart';
import '../config.dart';

class MapPage extends StatefulWidget {
  const MapPage({super.key});

  @override
  MapPageState createState() => MapPageState();
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

  Future<void> _getRoute(List<LatLng> locations) async {
    if (currentLocation == null || locations.isEmpty) return;

    setState(() {
      _isLoadingRoute = true;
      _errorMessage = null;
    });

    try {
      // Will implement route calculation when we have locations
      setState(() {
        routePoints = [];
        _isLoadingRoute = false;
      });
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
                if (currentLocation != null)
                  Marker(
                    width: 80.0,
                    height: 80.0,
                    point: currentLocation!,
                    child: const Icon(Icons.location_pin,
                        color: Colors.red, size: 40.0),
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
                color: const Color.fromRGBO(
                    255, 17, 0, 0.898), // Updated from withOpacity
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                _errorMessage!,
                style: const TextStyle(color: Colors.white),
                textAlign: TextAlign.center,
              ),
            ),
          ),
      ],
    );
  }
}
