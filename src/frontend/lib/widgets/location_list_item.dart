// lib/widgets/location_list_item.dart
import 'package:flutter/material.dart';
import '../models/location.dart';

class LocationListItem extends StatelessWidget {
  final Location location;
  final double currentLat;
  final double currentLng;

  const LocationListItem({
    super.key,
    required this.location,
    required this.currentLat,
    required this.currentLng,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        title: Text(location.name),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(location.formattedAddress),
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(
                  Icons.star,
                  size: 16,
                  color: location.getRatingColor(),
                ),
                const SizedBox(width: 4),
                Text(
                  location.formattedRating,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ],
        ),
        trailing: Text(
          location.getDistanceString(currentLat, currentLng),
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ),
    );
  }
}
