import 'package:flutter/material.dart';
import '../models/saved_locations.dart';
import '../models/location.dart';
import '../main.dart';

class SetupCrawlPage extends StatefulWidget {
  const SetupCrawlPage({super.key});

  @override
  State<SetupCrawlPage> createState() => _SetupCrawlPageState();
}

class _SetupCrawlPageState extends State<SetupCrawlPage> {
  List<Location> _savedLocations = [];
  final TextEditingController _crawlNameController = TextEditingController();
  DateTime _selectedDate = DateTime.now();

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
