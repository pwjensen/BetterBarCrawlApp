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
