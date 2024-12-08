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
import '../models/saved_locations.dart';
import '../main.dart';

final baseUrl = '${dotenv.env['SERVER_HOST']}:${dotenv.env['SERVER_PORT']}';

class BarInfoState {
  static final BarInfoState _instance = BarInfoState._internal();
  factory BarInfoState() => _instance;
  BarInfoState._internal();

  List<Location> locations = [];
  Position? currentPosition;
  Set<String> selectedLocationIds = {};
  bool hasLocation = false;
  int totalLocations = 0;
}

class BarInfoPage extends StatefulWidget {
  const BarInfoPage({super.key});

  @override
  State<BarInfoPage> createState() => _BarInfoPageState();
}

class _BarInfoPageState extends State<BarInfoPage> {
  final _state = BarInfoState();
  final TextEditingController _radiusController =
      TextEditingController(text: '1');
  final TextEditingController _typeController =
      TextEditingController(text: 'bar');
  bool _isLoading = false;
  String _error = '';
  SortOption _currentSortOption = SortOption.distance;
  List<Location> _locations = [];
  Position? _currentPosition;
  Set<String> _selectedLocationIds = {};
  bool _hasLocation = false;
  int _totalLocations = 0;

  @override
  void initState() {
    super.initState();
    // Only fetch data if we don't have any
    if (_state.locations.isEmpty) {
      _getCurrentLocation();
    } else {
      setState(() {
        _locations = _state.locations;
        _currentPosition = _state.currentPosition;
        _selectedLocationIds = _state.selectedLocationIds;
        _hasLocation = _state.hasLocation;
        _totalLocations = _state.totalLocations;
      });
    }
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

        // Update singleton state
        _state.currentPosition = position;
        _state.hasLocation = true;
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
      final radiusInMiles = double.tryParse(_radiusController.text) ?? 1.0;
      final radiusInMeters = (radiusInMiles * 1609.34).round();

      final queryParameters = {
        'longitude': _currentPosition!.longitude.toString(),
        'latitude': _currentPosition!.latitude.toString(),
        'radius': radiusInMeters.toString(),
        'type': _typeController.text.isEmpty ? 'bar' : _typeController.text,
      };

      final uri = Uri.http(baseUrl, 'api/search/', queryParameters);

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

          // Update singleton state
          _state.locations = searchResponse.locations;
          _state.totalLocations = searchResponse.totalLocations;
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

  Future<void> _saveSelectedLocations() async {
    if (_selectedLocationIds.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select at least one location')),
      );
      return;
    }

    final selectedLocations = _sortedLocations
        .where((location) => _selectedLocationIds.contains(location.id))
        .toList();

    try {
      await SavedLocations.saveLocations(selectedLocations);
      if (mounted) {
        // Find the MainPageState and update the index
        final mainPageState = context.findAncestorStateOfType<MainPageState>();
        if (mainPageState != null) {
          mainPageState.setIndex(1); // Index 1 is SetupCrawlPage
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving locations: $e')),
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

  void _handleSelection(String locationId, bool? selected) {
    setState(() {
      if (selected == true) {
        _selectedLocationIds.add(locationId);
      } else {
        _selectedLocationIds.remove(locationId);
      }
      // Update singleton state
      _state.selectedLocationIds = _selectedLocationIds;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Bar Info'),
        actions: [
          if (_selectedLocationIds.isNotEmpty)
            TextButton.icon(
              onPressed: _saveSelectedLocations,
              icon: const Icon(Icons.add),
              label: Text('Add ${_selectedLocationIds.length} to Crawl'),
              style: TextButton.styleFrom(
                foregroundColor: Theme.of(context).colorScheme.onPrimary,
              ),
            ),
        ],
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
                  final location = _sortedLocations[index];
                  print(
                      'Building item ${location.id}: ${location.name}'); // Debug print
                  return ListTile(
                    leading: Checkbox(
                      value: _selectedLocationIds.contains(location.id),
                      onChanged: (bool? value) {
                        print(
                            'Checkbox changed for ${location.id} to $value'); // Debug print
                        _handleSelection(location.id, value);
                        print(
                            'Selected IDs: $_selectedLocationIds'); // Debug print
                      },
                    ),
                    title: LocationListItem(
                      location: location,
                      currentLat: _currentPosition?.latitude ?? 0.0,
                      currentLng: _currentPosition?.longitude ?? 0.0,
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
