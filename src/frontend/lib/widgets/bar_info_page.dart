import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';
import '../services/token_storage.dart';

const baseUrl = '192.168.1.171:8000';
const apiPath = 'api/search/';

class Location {
  final String name;
  final String address;
  final double latitude;
  final double longitude;
  final String rating;
  final int userRatingsTotal;
  final String placeId;

  Location({
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
      name: json['name'] as String,
      address: json['address'] as String,
      latitude: json['latitude'].toDouble(),
      longitude: json['longitude'].toDouble(),
      rating: json['rating'] as String,
      userRatingsTotal: json['user_ratings_total'] as int,
      placeId: json['place_id'] as String,
    );
  }
}

class SearchResponse {
  final List<Location> locations;
  final Map<String, dynamic> searchParams;
  final int totalLocations;

  SearchResponse({
    required this.locations,
    required this.searchParams,
    required this.totalLocations,
  });

  factory SearchResponse.fromJson(Map<String, dynamic> json) {
    return SearchResponse(
      locations: (json['locations'] as List)
          .map((location) => Location.fromJson(location))
          .toList(),
      searchParams: json['search_params'] as Map<String, dynamic>,
      totalLocations: json['total_locations'] as int,
    );
  }
}

class BarInfoPage extends StatefulWidget {
  const BarInfoPage({super.key});

  @override
  State<BarInfoPage> createState() => _BarInfoPageState();
}

class _BarInfoPageState extends State<BarInfoPage> {
  final TextEditingController _radiusController =
      TextEditingController(text: '10');
  final TextEditingController _typeController =
      TextEditingController(text: 'bar');
  Position? _currentPosition;
  List<Location> _locations = [];
  bool _isLoading = false;
  String _error = '';
  int _totalLocations = 0;
  bool _hasLocation = false;

  @override
  void dispose() {
    _radiusController.dispose();
    _typeController.dispose();
    super.dispose();
  }

  Future<void> _getCurrentLocation() async {
    setState(() {
      _isLoading = true;
      _error = '';
    });

    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          throw 'Location permissions are denied';
        }
      }

      if (permission == LocationPermission.deniedForever) {
        throw 'Location permissions are permanently denied';
      }

      Position position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      );

      setState(() {
        _currentPosition = position;
        _hasLocation = true;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _searchNearbyPlaces() async {
    if (_currentPosition == null) {
      await _getCurrentLocation();
      if (_currentPosition == null) {
        setState(() {
          _error = 'Location not available';
        });
        return;
      }
    }

    setState(() {
      _isLoading = true;
      _error = '';
    });

    try {
      final token = await TokenStorage.getToken();
      if (token == null) {
        throw Exception('No auth token found. Please log in first.');
      }

      final queryParameters = {
        'longitude': _currentPosition!.longitude.toString(),
        'latitude': _currentPosition!.latitude.toString(),
        'radius': _radiusController.text,
        'type': _typeController.text.isEmpty ? 'bar' : _typeController.text,
      };

      final uri = Uri.http(baseUrl, apiPath, queryParameters);

      print('Request URL: ${uri.toString()}'); // For debugging

      final response = await http.get(
        uri,
        headers: {
          HttpHeaders.authorizationHeader: 'Token $token',
          HttpHeaders.acceptHeader: 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final SearchResponse searchResponse = SearchResponse.fromJson(
          json.decode(response.body),
        );

        setState(() {
          _locations = searchResponse.locations;
          _totalLocations = searchResponse.totalLocations;
          _isLoading = false;
        });
      } else if (response.statusCode == 401) {
        throw Exception('Authentication failed. Please log in again.');
      } else {
        throw Exception('Failed to fetch locations: ${response.statusCode}');
      }
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_error),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Nearby Places'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _radiusController,
                    decoration: const InputDecoration(
                      labelText: 'Radius (mi)',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextField(
                    controller: _typeController,
                    decoration: const InputDecoration(
                      labelText: 'Type (default: bar)',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (!_hasLocation)
              ElevatedButton(
                onPressed: _getCurrentLocation,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.all(16),
                ),
                child: const Text('Get Current Location'),
              )
            else
              ElevatedButton(
                onPressed: _searchNearbyPlaces,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.all(16),
                ),
                child: Text(
                    'Find ${_typeController.text.isEmpty ? 'Bars' : _typeController.text}'),
              ),
            const SizedBox(height: 16),
            if (_currentPosition != null)
              Text(
                'Location: ${_currentPosition!.latitude.toStringAsFixed(4)}, '
                '${_currentPosition!.longitude.toStringAsFixed(4)}',
                style: Theme.of(context).textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
            if (_error.isNotEmpty)
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  _error,
                  style: const TextStyle(color: Colors.red),
                  textAlign: TextAlign.center,
                ),
              ),
            if (_isLoading)
              const Padding(
                padding: EdgeInsets.all(8.0),
                child: Center(child: CircularProgressIndicator()),
              ),
            if (_totalLocations > 0)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Text(
                  'Found $_totalLocations locations',
                  style: Theme.of(context).textTheme.titleMedium,
                  textAlign: TextAlign.center,
                ),
              ),
            Expanded(
              child: ListView.builder(
                itemCount: _locations.length,
                itemBuilder: (context, index) {
                  final location = _locations[index];
                  return Card(
                    child: ListTile(
                      title: Text(location.name),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(location.address),
                          const SizedBox(height: 4),
                          Text(
                            'Rating: ${location.rating} (${location.userRatingsTotal} reviews)',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ],
                      ),
                      trailing: Text(
                        '${(Geolocator.distanceBetween(
                              _currentPosition!.latitude,
                              _currentPosition!.longitude,
                              location.latitude,
                              location.longitude,
                            ) / 1000).toStringAsFixed(1)} km',
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
