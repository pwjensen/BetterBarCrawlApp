import 'package:flutter/material.dart';
import '../models/saved_locations.dart';
import '../models/location.dart';
import '../main.dart';
import '../services/token_storage.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';
import '../config.dart';
import '../widgets/directions_container.dart';

class SetupCrawlPage extends StatefulWidget {
  const SetupCrawlPage({super.key});

  @override
  State<SetupCrawlPage> createState() => SetupCrawlPageState();
}

class SetupCrawlPageState extends State<SetupCrawlPage>
    with WidgetsBindingObserver {
  List<Location> _savedLocations = [];
  final TextEditingController _crawlNameController = TextEditingController();
  DateTime _selectedDate = DateTime.now();

  bool get _isFormValid => _crawlNameController.text.isNotEmpty;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _loadSavedLocations();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _loadSavedLocations();
    }
  }

  void refresh() {
    _loadSavedLocations();
  }

  Future<void> _loadSavedLocations() async {
    final locations = await SavedLocations.getSavedLocations();
    if (mounted) {
      setState(() {
        _savedLocations = locations;
      });
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _createCrawl() async {
    if (_savedLocations.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please add at least one location')),
      );
      return;
    }

    try {
      final token = await TokenStorage.getToken();
      if (token == null) {
        throw Exception('No auth token found');
      }

      final locationIds = _savedLocations.map((loc) => loc.id).toList();
      final queryParams = {'location': locationIds};

      print('Making request with params: $queryParams');

      final response = await http.get(
        Uri.http(Config.apiBaseUrl, '/api/optimize-crawl/', queryParams),
        headers: {
          HttpHeaders.authorizationHeader: 'Token $token',
          HttpHeaders.contentTypeHeader: 'application/json',
        },
      );

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (!mounted) return;

      if (response.statusCode == 200) {
        final routeData = jsonDecode(response.body);

        // Verify route data structure
        if (!routeData.containsKey('geo_json') ||
            !routeData.containsKey('ordered_locations')) {
          throw Exception('Invalid route data received from server');
        }

        // Find MainPageState and switch to directions tab
        if (mounted) {
          final mainPageState =
              context.findAncestorStateOfType<MainPageState>();
          if (mainPageState != null) {
            // Update DirectionsContainer data and switch to it
            DirectionsContainer.updateRouteData(routeData);
            mainPageState.setIndex(2); // Switch to directions tab
          }
        }
      } else {
        throw Exception('Failed to create route: ${response.statusCode}');
      }
    } catch (e) {
      print('Error in _createCrawl: $e');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error creating route: ${e.toString()}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Setup Crawl'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Create Your Bar Crawl',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _crawlNameController,
              decoration: const InputDecoration(
                labelText: 'Crawl Name',
                border: OutlineInputBorder(),
              ),
              onChanged: (value) => setState(() {}),
            ),
            const SizedBox(height: 20),
            InkWell(
              onTap: () => _selectDate(context),
              child: InputDecorator(
                decoration: const InputDecoration(
                  labelText: 'Date',
                  border: OutlineInputBorder(),
                  suffixIcon: Icon(Icons.calendar_today),
                ),
                child: Text(
                  '${_selectedDate.month}/${_selectedDate.day}/${_selectedDate.year}',
                ),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Selected Bars:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: _savedLocations.length,
                itemBuilder: (context, index) {
                  final location = _savedLocations[index];
                  return ListTile(
                    leading: const Icon(Icons.local_bar),
                    title: Text(location.name),
                    subtitle: Text(location.address),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete),
                      onPressed: () async {
                        // Remove location and update storage
                        setState(() {
                          _savedLocations.removeAt(index);
                        });
                        await SavedLocations.saveLocations(_savedLocations);
                      },
                    ),
                  );
                },
              ),
            ),
            ElevatedButton(
              onPressed: () {
                final mainPageState =
                    context.findAncestorStateOfType<MainPageState>();
                if (mainPageState != null) {
                  mainPageState.setIndex(0); // Index 0 is BarInfoPage
                }
              },
              child: const Text('Add Bar'),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isFormValid ? _createCrawl : null,
                child: const Text('Create Crawl'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
