import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:frontend/main.dart';
import 'package:frontend/widgets/bar_info_page.dart';
import 'package:frontend/widgets/setup_crawl_page.dart';
import 'package:frontend/widgets/settings_page.dart';
import 'package:hive/hive.dart';
import 'dart:io';
import 'package:frontend/widgets/directions_container.dart';

// Mock the MapPage to prevent network requests
class MockMapPage extends StatelessWidget {
  const MockMapPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}

void main() {
  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    await dotenv.load(fileName: ".env");

    // Initialize Hive with a temporary directory path
    // Initialize Hive with a temporary directory path
    Hive.init(Directory.current.path);
  });

  tearDownAll(() async {
    // Clean up after tests
    await Hive.close();
  });

  group('MyApp Widget Tests', () {
    testWidgets('MyApp initializes with correct theme mode',
        (WidgetTester tester) async {
      await tester.pumpWidget(const MyApp());

      final MaterialApp materialApp = tester.widget(find.byType(MaterialApp));
      expect(materialApp.themeMode, equals(ThemeMode.system));
    });

    testWidgets('MyApp changes theme mode correctly',
        (WidgetTester tester) async {
      await tester.pumpWidget(const MyApp());

      final MainPage mainPage = tester.widget(find.byType(MainPage));
      mainPage.setThemeMode(ThemeMode.dark);
      await tester.pump();

      final MaterialApp updatedMaterialApp =
          tester.widget(find.byType(MaterialApp));
      expect(updatedMaterialApp.themeMode, equals(ThemeMode.dark));
    });
  });

  group('Theme Tests', () {
    testWidgets('Light theme has correct basic properties',
        (WidgetTester tester) async {
      await tester.pumpWidget(const MyApp());

      final MaterialApp materialApp = tester.widget(find.byType(MaterialApp));
      final ThemeData lightTheme = materialApp.theme!;

      expect(lightTheme.brightness, equals(Brightness.light));
      expect(lightTheme.colorScheme, isNotNull);
      expect(lightTheme.colorScheme.primary, isNotNull);
    });

    testWidgets('Dark theme has correct basic properties',
        (WidgetTester tester) async {
      await tester.pumpWidget(const MyApp());

      final MaterialApp materialApp = tester.widget(find.byType(MaterialApp));
      final ThemeData darkTheme = materialApp.darkTheme!;

      expect(darkTheme.brightness, equals(Brightness.dark));
      expect(darkTheme.colorScheme, isNotNull);
      expect(darkTheme.colorScheme.primary, isNotNull);
    });
  });

  group('MainPage Widget Tests', () {
    Widget createTestApp() {
      return MaterialApp(
        home: MainPage(
          setThemeMode: (_) {},
        ),
      );
    }

    testWidgets('MainPage shows correct initial page',
        (WidgetTester tester) async {
      await tester.pumpWidget(createTestApp());

      expect(find.byType(BarInfoPage), findsOneWidget);
      expect(find.byType(SetupCrawlPage), findsNothing);
      expect(find.byType(MockMapPage), findsNothing);
      expect(find.byType(SettingsPage), findsNothing);
    });

    testWidgets('Navigation bar switches pages correctly',
        (WidgetTester tester) async {
      await tester.pumpWidget(createTestApp());

      // Test navigation to Setup page
      await tester.tap(find.byIcon(Icons.add));
      await tester.pump(const Duration(milliseconds: 100));
      expect(find.byType(SetupCrawlPage), findsOneWidget);

      // Test navigation to Directions page
      await tester.tap(find.byIcon(Icons.directions));
      await tester.pump(const Duration(milliseconds: 100));
      expect(find.byType(DirectionsContainer), findsOneWidget);

      // Test navigation to Settings page
      await tester.tap(find.byIcon(Icons.settings));
      await tester.pump(const Duration(milliseconds: 100));
      expect(find.byType(SettingsPage), findsOneWidget);

      // Test navigation back to Search page
      await tester.tap(find.byIcon(Icons.search));
      await tester.pump(const Duration(milliseconds: 100));
      expect(find.byType(BarInfoPage), findsOneWidget);
    });

    testWidgets('Bottom navigation bar has correct items',
        (WidgetTester tester) async {
      await tester.pumpWidget(createTestApp());

      expect(find.byIcon(Icons.search), findsOneWidget);
      expect(find.byIcon(Icons.add), findsOneWidget);
      expect(find.byIcon(Icons.directions), findsOneWidget);
      expect(find.byIcon(Icons.settings), findsOneWidget);

      expect(find.text('Search'), findsOneWidget);
      expect(find.text('Setup'), findsOneWidget);
      expect(find.text('Directions'), findsOneWidget);
      expect(find.text('Settings'), findsOneWidget);
    });
  });

  group('State Management Tests', () {
    testWidgets('MainPage maintains correct page after navigation',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: MainPage(setThemeMode: (_) {}),
        ),
      );

      // Navigate through pages
      final List<IconData> icons = [
        Icons.add,
        Icons.directions,
        Icons.settings,
        Icons.search
      ];
      for (final icon in icons) {
        await tester.tap(find.byIcon(icon));
        await tester.pump(const Duration(milliseconds: 100));
      }

      // Verify we're back on the Search page
      expect(find.byType(BarInfoPage), findsOneWidget);

      // Verify the BottomNavigationBar is showing the correct selected index
      final BottomNavigationBar navigationBar =
          tester.widget(find.byType(BottomNavigationBar));
      expect(navigationBar.currentIndex, equals(0));
    });
  });
}
