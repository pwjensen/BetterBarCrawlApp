import 'package:flutter/material.dart';
import '../models/location.dart';

class DirectionsPage extends StatefulWidget {
  final Map<String, dynamic> routeData;
  final List<Location> orderedLocations;

  const DirectionsPage({
    super.key,
    required this.routeData,
    required this.orderedLocations,
  });

  @override
  State<DirectionsPage> createState() => _DirectionsPageState();
}

class _DirectionsPageState extends State<DirectionsPage> {
  int _currentSegment = 0;
  int _currentStep = 0;
  late final List<dynamic> segments;
  late final double totalDistance;
  late final double totalTime;

  @override
  void initState() {
    super.initState();
    // Extract all segments from the features array
    segments = [];
    final features = widget.routeData['geo_json']?['features'] as List? ?? [];

    // Collect all segments from each feature
    for (var feature in features) {
      final featureSegments = feature['properties']?['segments'] as List? ?? [];
      segments.addAll(featureSegments);
    }

    print('Total segments found: ${segments.length}'); // Debug print

    totalDistance = widget.routeData['total_distance_miles'] ?? 0.0;
    totalTime = widget.routeData['total_time_seconds'] ?? 0.0;
  }

  String getCurrentInstruction() {
    if (segments.isEmpty) return 'No instructions available';
    try {
      final steps = segments[_currentSegment]['steps'] as List;
      if (steps.isEmpty) return 'No steps available';
      return steps[_currentStep]['instruction'] as String? ??
          'No instruction available';
    } catch (e) {
      print('Error getting instruction: $e');
      return 'Error loading instruction';
    }
  }

  double getCurrentDistance() {
    if (segments.isEmpty) return 0.0;
    try {
      final steps = segments[_currentSegment]['steps'] as List;
      return (steps[_currentStep]['distance'] as num?)?.toDouble() ?? 0.0;
    } catch (e) {
      print('Error getting distance: $e');
      return 0.0;
    }
  }

  bool canGoNext() {
    if (segments.isEmpty) return false;
    final currentSegmentSteps = segments[_currentSegment]['steps'] as List;
    return _currentStep < currentSegmentSteps.length - 1 ||
        _currentSegment < segments.length - 1;
  }

  bool canGoPrevious() {
    return _currentStep > 0 || _currentSegment > 0;
  }

  void _nextStep() {
    setState(() {
      if (segments.isEmpty) return;
      final currentSegmentSteps = segments[_currentSegment]['steps'] as List;
      if (_currentStep < currentSegmentSteps.length - 1) {
        _currentStep++;
      } else if (_currentSegment < segments.length - 1) {
        _currentSegment++;
        _currentStep = 0;
      }
    });
  }

  void _previousStep() {
    setState(() {
      if (segments.isEmpty) return;
      if (_currentStep > 0) {
        _currentStep--;
      } else if (_currentSegment > 0) {
        _currentSegment--;
        final steps = segments[_currentSegment]['steps'] as List;
        _currentStep = steps.length - 1;
      }
    });
  }

  String _formatDuration(double seconds) {
    final minutes = (seconds / 60).round();
    return '$minutes minutes';
  }

  String _getCurrentStepInfo() {
    if (segments.isEmpty) return 'No steps available';
    final currentSegmentSteps = segments[_currentSegment]['steps'] as List;
    final totalSteps = currentSegmentSteps.length;
    return 'Step ${_currentStep + 1} of $totalSteps';
  }

  @override
  Widget build(BuildContext context) {
    if (widget.orderedLocations.isEmpty) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Crawl Directions'),
        ),
        body: const Center(
          child: Text(
            'No directions available.\nCreate a crawl to see directions.',
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Crawl Directions'),
      ),
      body: Column(
        children: [
          // Summary card
          Card(
            margin: const EdgeInsets.all(16),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Total Distance: ${totalDistance.toStringAsFixed(2)} miles',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  Text(
                    'Estimated Time: ${_formatDuration(totalTime)}',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ],
              ),
            ),
          ),

          // Location cards
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Expanded(
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Current Stop',
                            style: Theme.of(context).textTheme.labelLarge,
                          ),
                          Text(
                            widget.orderedLocations[_currentSegment].name,
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                if (_currentSegment < widget.orderedLocations.length - 1)
                  Expanded(
                    child: Card(
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Next Stop',
                              style: Theme.of(context).textTheme.labelLarge,
                            ),
                            Text(
                              widget.orderedLocations[_currentSegment + 1].name,
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),

          // Current instructions
          Expanded(
            child: Card(
              margin: const EdgeInsets.all(16),
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  Text(
                    'Current Instructions',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    getCurrentInstruction(),
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Distance: ${getCurrentDistance().toStringAsFixed(3)} miles',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomAppBar(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                onPressed: canGoPrevious() ? _previousStep : null,
                icon: const Icon(Icons.arrow_back),
              ),
              Text(
                _getCurrentStepInfo(),
                style: Theme.of(context).textTheme.titleMedium,
              ),
              IconButton(
                onPressed: canGoNext() ? _nextStep : null,
                icon: const Icon(Icons.arrow_forward),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
