import 'package:hive/hive.dart';
import 'location.dart';

class SavedLocations {
  static const String _boxName = 'saved_locations';

  static Future<void> saveLocations(List<Location> locations) async {
    final box = await Hive.openBox(_boxName);
    final locationList = locations.map((loc) => loc.toJson()).toList();
    await box.put('locations', locationList);
  }

  static Future<List<Location>> getSavedLocations() async {
    final box = await Hive.openBox(_boxName);
    final locationList = box.get('locations', defaultValue: []) as List;
    return locationList
        .map((json) => Location.fromJson(Map<String, dynamic>.from(json)))
        .toList();
  }

  static Future<void> clearSavedLocations() async {
    final box = await Hive.openBox(_boxName);
    await box.clear();
  }
}
