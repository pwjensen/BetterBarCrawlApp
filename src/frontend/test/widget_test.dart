import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:frontend/main.dart';
import 'package:frontend/widgets/bar_info_page.dart';
import 'package:frontend/widgets/setup_crawl_page.dart';
import 'package:frontend/widgets/settings_page.dart';

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
  });

  group('MyApp Widget Tests', () {
    testWidgets('MyApp initializes with correct theme mode', (WidgetTester tester) async {
      await tester.pumpWidget(const MyApp());

      final MaterialApp materialApp = tester.widget(find.byType(MaterialApp));
      expect(materialApp.themeMode, equals(ThemeMode.system));
    });

    testWidgets('MyApp changes theme mode correctly', (WidgetTester tester) async {
      await tester.pumpWidget(const MyApp());

      final MainPage mainPage = tester.widget(find.byType(MainPage));
      mainPage.setThemeMode(ThemeMode.dark);
      await tester.pump();

      final MaterialApp updatedMaterialApp = tester.widget(find.byType(MaterialApp));
      expect(updatedMaterialApp.themeMode, equals(ThemeMode.dark));
    });
  });

  group('Theme Tests', () {
    testWidgets('Light theme has correct basic properties', (WidgetTester tester) async {
      await tester.pumpWidget(const MyApp());

      final MaterialApp materialApp = tester.widget(find.byType(MaterialApp));
      final ThemeData lightTheme = materialApp.theme!;

      expect(lightTheme.brightness, equals(Brightness.light));
      expect(lightTheme.colorScheme, isNotNull);
      expect(lightTheme.colorScheme.primary, isNotNull);
    });

    testWidgets('Dark theme has correct basic properties', (WidgetTester tester) async {
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

    testWidgets('MainPage shows correct initial page', (WidgetTester tester) async {
      await tester.pumpWidget(createTestApp());

      expect(find.byType(BarInfoPage), findsOneWidget);
      expect(find.byType(SetupCrawlPage), findsNothing);
      expect(find.byType(MockMapPage), findsNothing);
      expect(find.byType(SettingsPage), findsNothing);
    });

    testWidgets('Navigation bar switches pages correctly', (WidgetTester tester) async {
      await tester.pumpWidget(createTestApp());

      // Test navigation to Setup Crawl page
      await tester.tap(find.byIcon(Icons.route));
      await tester.pumpAndSettle();
      expect(find.byType(SetupCrawlPage), findsOneWidget);

      // Skip map page test to avoid network requests

      // Test navigation to Settings page
      await tester.tap(find.byIcon(Icons.settings));
      await tester.pumpAndSettle();
      expect(find.byType(SettingsPage), findsOneWidget);

      // Test navigation back to Bar Info page
      await tester.tap(find.byIcon(Icons.local_bar));
      await tester.pumpAndSettle();
      expect(find.byType(BarInfoPage), findsOneWidget);
    });

    testWidgets('Bottom navigation bar has correct items', (WidgetTester tester) async {
      await tester.pumpWidget(createTestApp());

      expect(find.byIcon(Icons.local_bar), findsOneWidget);
      expect(find.byIcon(Icons.route), findsOneWidget);
      expect(find.byIcon(Icons.map), findsOneWidget);
      expect(find.byIcon(Icons.settings), findsOneWidget);

      expect(find.text('Bar Info'), findsOneWidget);
      expect(find.text('Setup Crawl'), findsOneWidget);
      expect(find.text('Map'), findsOneWidget);
      expect(find.text('Settings'), findsOneWidget);
    });
  });

  group('State Management Tests', () {
    testWidgets('MainPage maintains correct page after navigation', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: MainPage(setThemeMode: (_) {}),
        ),
      );

      // Navigate through pages except map
      final List<IconData> icons = [Icons.route, Icons.settings, Icons.local_bar];
      for (final icon in icons) {
        await tester.tap(find.byIcon(icon));
        await tester.pumpAndSettle();
      }

      // Verify we're back on the Bar Info page
      expect(find.byType(BarInfoPage), findsOneWidget);

      // Verify the BottomNavigationBar is showing the correct selected index
      final BottomNavigationBar navigationBar = tester.widget(find.byType(BottomNavigationBar));
      expect(navigationBar.currentIndex, equals(0));
    });
  });
}