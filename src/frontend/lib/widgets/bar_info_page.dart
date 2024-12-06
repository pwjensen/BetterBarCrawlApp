import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';
import '../services/token_storage.dart';
import '../models/location.dart';
import '../models/search_response.dart';
import '../models/search_params.dart';
import '../models/sort_option.dart';
import '../widgets/location_list_item.dart';

final baseUrl = '${dotenv.env['SERVER_HOST']}:${dotenv.env['SERVER_PORT']}';

class BarInfoPage extends StatefulWidget {
  const BarInfoPage({super.key});

  @override
  State<BarInfoPage> createState() => _BarInfoPageState();
}

class _BarInfoPageState extends State<BarInfoPage> {
  final TextEditingController _radiusController =
      TextEditingController(text: '1');
  final TextEditingController _typeController =
      TextEditingController(text: 'bar');
  Position? _currentPosition;
  List<Location> _locations = [];
  bool _isLoading = false;
  String _error = '';
  int _totalLocations = 0;
  bool _hasLocation = false;
  SortOption _currentSortOption = SortOption.distance;

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

      final uri = Uri.http(baseUrl, 'api/search/', queryParameters);
      // print('Request URL: ${uri.toString()}'); // For debugging

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

  Widget _buildSortButton() {
    return PopupMenuButton<SortOption>(
      initialValue: _currentSortOption,
      onSelected: (SortOption sortOption) {
        setState(() {
          _currentSortOption = sortOption;
        });
      },
      itemBuilder: (BuildContext context) => <PopupMenuEntry<SortOption>>[
        for (final option in SortOption.values)
          PopupMenuItem<SortOption>(
            value: option,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  option == _currentSortOption
                      ? Icons.radio_button_checked
                      : Icons.radio_button_unchecked,
                  size: 16,
                ),
                const SizedBox(width: 8),
                Text(
                  option.label,
                  style: const TextStyle(fontSize: 14),
                ),
              ],
            ),
          ),
      ],
      child: Chip(
        padding: const EdgeInsets.symmetric(horizontal: 4),
        labelPadding: const EdgeInsets.symmetric(horizontal: 4),
        avatar: const Icon(Icons.sort, size: 16),
        label: Text(
          'Sort: ${_currentSortOption.label}',
          style: const TextStyle(fontSize: 13),
        ),
      ),
    );
  }

  List<Location> get _sortedLocations {
    if (_locations.isEmpty) return [];
    return SearchResponse(
      locations: _locations,
      searchParams: SearchParams(
        longitude: _currentPosition!.longitude.toString(),
        latitude: _currentPosition!.latitude.toString(),
        radiusMiles: double.parse(_radiusController.text),
        type: _typeController.text,
      ),
      totalLocations: _totalLocations,
    ).getSortedLocations(
      _currentSortOption,
      currentLat: _currentPosition?.latitude,
      currentLng: _currentPosition?.longitude,
    );
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
            if (_totalLocations > 0) ...[
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Wrap(
                  alignment: WrapAlignment.spaceBetween,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    Text(
                      'Found $_totalLocations locations',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    _buildSortButton(),
                  ],
                ),
              ),
            ],
            Expanded(
              child: ListView.builder(
                itemCount: _sortedLocations.length,
                itemBuilder: (context, index) {
                  return LocationListItem(
                    location: _sortedLocations[index],
                    currentLat: _currentPosition!.latitude,
                    currentLng: _currentPosition!.longitude,
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
