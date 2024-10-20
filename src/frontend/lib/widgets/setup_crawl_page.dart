import 'package:flutter/material.dart';

class SetupCrawlPage extends StatelessWidget {
  const SetupCrawlPage({super.key});

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
              decoration: InputDecoration(
                labelText: 'Crawl Name',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            TextField(
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
                itemCount: 3, // Placeholder count
                itemBuilder: (context, index) {
                  return ListTile(
                    leading: Icon(Icons.local_bar),
                    title: Text('Bar ${index + 1}'),
                    trailing: Icon(Icons.delete),
                  );
                },
              ),
            ),
            ElevatedButton(
              onPressed: () {
                // TODO: Implement bar selection
              },
              child: Text('Add Bar'),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  // TODO: Implement crawl creation
                },
                child: Text('Create Crawl'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

