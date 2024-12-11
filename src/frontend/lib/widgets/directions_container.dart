import 'package:flutter/material.dart';
import 'directions_page.dart';
import '../models/location.dart';

class DirectionsContainer extends StatefulWidget {
  static final GlobalKey<DirectionsContainerState> globalKey = GlobalKey();

  DirectionsContainer() : super(key: globalKey);

  static void updateRouteData(Map<String, dynamic> data) {
    globalKey.currentState?.updateRouteData(data);
  }

  @override
  DirectionsContainerState createState() => DirectionsContainerState();
}

class DirectionsContainerState extends State<DirectionsContainer> {
  Map<String, dynamic> routeData = {};
  List<Location> orderedLocations = [];

  void updateRouteData(Map<String, dynamic> data) {
    print('Received route data: $data'); // Debug print
    print(
        'GeoJSON features: ${data['geo_json']?['features']?.length ?? 0}'); // Debug print

    setState(() {
      routeData = Map<String, dynamic>.from(data);

      // Convert the JSON locations to Location objects
      orderedLocations = (data['ordered_locations'] as List?)
              ?.map<Location>((loc) => Location(
                    id: loc['id'] ?? '',
                    name: loc['name'] ?? '',
                    address: loc['address'] ?? '',
                    latitude:
                        double.tryParse(loc['latitude'].toString()) ?? 0.0,
                    longitude:
                        double.tryParse(loc['longitude'].toString()) ?? 0.0,
                    rating: double.tryParse(loc['rating']?.toString() ?? '0') ??
                        0.0,
                    userRatingsTotal: loc['user_ratings_total'] ?? 0,
                    placeId: loc['place_id'] ?? '',
                  ))
              .toList() ??
          [];

      // Debug print the structure of geo_json
      if (data.containsKey('geo_json')) {
        print('GeoJSON structure: ${data['geo_json'].keys}');
        final features = data['geo_json']['features'] as List?;
        if (features != null) {
          for (var i = 0; i < features.length; i++) {
            print(
                'Feature $i segments: ${features[i]['properties']?['segments']?.length ?? 0}');
          }
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (routeData.isEmpty || orderedLocations.isEmpty) {
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

    return DirectionsPage(
      routeData: routeData,
      orderedLocations: orderedLocations,
    );
  }
}
