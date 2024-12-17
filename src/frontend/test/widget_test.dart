import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:frontend/main.dart';
import 'package:frontend/widgets/bar_info_page.dart';
import 'package:frontend/widgets/setup_crawl_page.dart';
import 'package:frontend/widgets/settings_page.dart';
import 'package:frontend/widgets/directions_container.dart';
import 'package:frontend/models/location.dart';
import 'package:frontend/models/search_response.dart';
import 'package:frontend/models/search_params.dart';
import 'package:frontend/models/sort_option.dart';
import 'package:hive/hive.dart';
import 'dart:io';
import 'package:frontend/widgets/location_list_item.dart';

// Mock classes
class MockLocation extends Location {
  const MockLocation({
    required super.id,
    required super.name,
    required super.latitude,
    required super.longitude,
  }) : super(
          address: 'Test Address',
          rating: 4.5,
          userRatingsTotal: 100,
          placeId: 'test_place_id',
        );
}

void main() {
  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    await dotenv.load(fileName: ".env");
    Hive.init(Directory.current.path);
  });

  tearDownAll(() async {
    await Hive.close();
  });

  group('Model Tests', () {
    test('SearchResponse sorts locations correctly', () {
      final locations = [
        const MockLocation(
          id: '1',
          name: 'Bar C',
          latitude: 0,
          longitude: 0,
        ),
        const MockLocation(
          id: '2',
          name: 'Bar A',
          latitude: 0,
          longitude: 0,
        ),
        const MockLocation(
          id: '3',
          name: 'Bar B',
          latitude: 0,
          longitude: 0,
        ),
      ];

      final searchResponse = SearchResponse(
        locations: locations,
        searchParams: const SearchParams(
          longitude: '0',
          latitude: '0',
          radiusMiles: 1.0,
          type: 'bar',
        ),
        totalLocations: locations.length,
      );

      final sortedByName = searchResponse.getSortedLocations(SortOption.name);
      expect(sortedByName[0].name, 'Bar A');
      expect(sortedByName[1].name, 'Bar B');
      expect(sortedByName[2].name, 'Bar C');
    });

    test('SearchParams creates valid object', () {
      const params = SearchParams(
        longitude: '-122.4194',
        latitude: '37.7749',
        radiusMiles: 1.0,
        type: 'bar',
      );

      expect(params.longitude, '-122.4194');
      expect(params.latitude, '37.7749');
      expect(params.radiusMiles, 1.0);
      expect(params.type, 'bar');
    });

    test('Location sorting works with different options', () {
      final locations = [
        const MockLocation(
          id: '1',
          name: 'Bar C',
          latitude: 0,
          longitude: 0,
        ),
        const MockLocation(
          id: '2',
          name: 'Bar A',
          latitude: 1,
          longitude: 1,
        ),
        const MockLocation(
          id: '3',
          name: 'Bar B',
          latitude: 2,
          longitude: 2,
        ),
      ];

      final searchResponse = SearchResponse(
        locations: locations,
        searchParams: const SearchParams(
          longitude: '0',
          latitude: '0',
          radiusMiles: 1.0,
          type: 'bar',
        ),
        totalLocations: locations.length,
      );

      // Test name sorting
      final sortedByName = searchResponse.getSortedLocations(SortOption.name);
      expect(sortedByName[0].name, 'Bar A');
      expect(sortedByName[1].name, 'Bar B');
      expect(sortedByName[2].name, 'Bar C');

      // Test distance sorting
      final sortedByDistance = searchResponse.getSortedLocations(
        SortOption.distance,
        currentLat: 0,
        currentLng: 0,
      );
      expect(sortedByDistance[0].id, '1'); // Closest to 0,0
      expect(sortedByDistance[2].id, '3'); // Furthest from 0,0

      // Test rating sorting
      final sortedByRating =
          searchResponse.getSortedLocations(SortOption.rating);
      expect(sortedByRating.length, 3);
    });
  });

  group('Widget Tests', () {
    testWidgets('DirectionsContainer shows placeholder when empty',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DirectionsContainer(),
          ),
        ),
      );

      await tester.pump();
      await tester.pumpAndSettle();

      expect(
        find.text(
            'No directions available.\nCreate a crawl to see directions.'),
        findsOneWidget,
      );
    });

    testWidgets('BarInfoPage shows initial state', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: BarInfoPage(),
        ),
      );

      expect(find.text('Bar Info'), findsOneWidget);
      expect(find.byType(TextField), findsNWidgets(2));
      expect(find.text('Get Current Location'), findsOneWidget);
    });

    testWidgets('SetupCrawlPage shows empty state',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: SetupCrawlPage(),
        ),
      );

      expect(find.text('Setup Crawl'), findsOneWidget);
      expect(find.text('Create Your Bar Crawl'), findsOneWidget);
      expect(find.byType(TextField), findsOneWidget); // Crawl name field
    });

    testWidgets('SettingsPage shows theme dialog', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: SettingsPage(
            setThemeMode: (_) {},
          ),
        ),
      );

      // Find and tap the theme tile
      await tester.tap(find.text('Theme'));
      await tester.pumpAndSettle();

      // Verify dialog appears with options
      expect(find.text('Select Theme'), findsOneWidget);
      expect(find.text('Light'), findsOneWidget);
      expect(find.text('Dark'), findsOneWidget);
    });

    testWidgets('SetupCrawlPage shows initial empty state',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: SetupCrawlPage(),
        ),
      );

      expect(find.text('Setup Crawl'), findsOneWidget);
      expect(find.text('Create Your Bar Crawl'), findsOneWidget);
      expect(find.byType(TextField), findsOneWidget);
      expect(find.text('Add Bar'), findsOneWidget);
      expect(find.text('Create Crawl'), findsOneWidget);
    });

    testWidgets('LocationListItem displays location information correctly',
        (WidgetTester tester) async {
      const location = MockLocation(
        id: 'test_id',
        name: 'Test Bar',
        latitude: 0,
        longitude: 0,
      );

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: LocationListItem(
              location: location,
              currentLat: 0,
              currentLng: 0,
            ),
          ),
        ),
      );

      expect(find.text('Test Bar'), findsOneWidget);
      expect(find.text('Test Address'), findsOneWidget);
      expect(find.byIcon(Icons.star), findsOneWidget);
    });
  });

  group('Navigation Tests', () {
    testWidgets('Bottom navigation works correctly',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: MainPage(
            setThemeMode: (_) {},
          ),
        ),
      );

      // Verify initial page
      expect(find.byType(BarInfoPage), findsOneWidget);

      // Test navigation to Setup page
      await tester.tap(find.byIcon(Icons.add));
      await tester.pump();
      expect(find.byType(SetupCrawlPage), findsOneWidget);

      // Test navigation to Directions page
      await tester.tap(find.byIcon(Icons.directions));
      await tester.pump();
      expect(find.byType(DirectionsContainer), findsOneWidget);

      // Test navigation to Settings page
      await tester.tap(find.byIcon(Icons.settings));
      await tester.pump();
      expect(find.byType(SettingsPage), findsOneWidget);
    });
  });

  group('Theme Tests', () {
    testWidgets('Theme mode changes correctly', (WidgetTester tester) async {
      await tester.pumpWidget(const MyApp());

      // Find settings page
      await tester.tap(find.byIcon(Icons.settings));
      await tester.pump();

      // Open theme dialog
      await tester.tap(find.text('Theme'));
      await tester.pump();

      // Select dark theme
      await tester.tap(find.text('Dark'));
      await tester.pump();

      final MaterialApp materialApp = tester.widget(find.byType(MaterialApp));
      expect(materialApp.themeMode, equals(ThemeMode.dark));
    });
  });

  group('Navigation and Integration Tests', () {
    testWidgets('Can navigate between main pages and maintain state',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: MainPage(
            setThemeMode: (_) {},
          ),
        ),
      );

      // Start at BarInfoPage
      expect(find.byType(BarInfoPage), findsOneWidget);

      // Navigate to SetupCrawlPage
      await tester.tap(find.byIcon(Icons.add));
      await tester.pump();
      expect(find.byType(SetupCrawlPage), findsOneWidget);

      // Navigate to DirectionsContainer
      await tester.tap(find.byIcon(Icons.directions));
      await tester.pump();
      expect(find.byType(DirectionsContainer), findsOneWidget);

      // Navigate back to BarInfoPage
      await tester.tap(find.byIcon(Icons.search));
      await tester.pump();
      expect(find.byType(BarInfoPage), findsOneWidget);
    });
  });
}
