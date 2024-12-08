import 'package:flutter/material.dart';
import '../models/saved_locations.dart';
import '../models/location.dart';

class SetupCrawlPage extends StatefulWidget {
  const SetupCrawlPage({super.key});

  @override
  State<SetupCrawlPage> createState() => _SetupCrawlPageState();
}

class _SetupCrawlPageState extends State<SetupCrawlPage> {
  List<Location> _savedLocations = [];

  @override
  void initState() {
    super.initState();
    _loadSavedLocations();
  }

  Future<void> _loadSavedLocations() async {
    final locations = await SavedLocations.getSavedLocations();
    setState(() {
      _savedLocations = locations;
    });
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
            const TextField(
              decoration: InputDecoration(
                labelText: 'Crawl Name',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            const TextField(
              decoration: InputDecoration(
                labelText: 'Date',
                border: OutlineInputBorder(),
                suffixIcon: Icon(Icons.calendar_today),
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
                // TODO: Implement bar selection
              },
              child: const Text('Add Bar'),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  // TODO: Implement crawl creation
                },
                child: const Text('Create Crawl'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
