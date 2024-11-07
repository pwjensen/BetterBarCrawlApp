import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/main.dart';
import 'package:frontend/widgets/bar_info_page.dart';
import 'package:frontend/widgets/setup_crawl_page.dart';
import 'package:frontend/widgets/map_page.dart';
import 'package:frontend/widgets/settings_page.dart';

void main() {
  group('MyApp Widget Tests', () {
    testWidgets('MyApp initializes with correct theme properties', (WidgetTester tester) async {
      await tester.pumpWidget(const MyApp());
      
      final MaterialApp materialApp = tester.widget(find.byType(MaterialApp));
      expect(materialApp.title, equals('Bar Crawl App'));
      expect(materialApp.debugShowCheckedModeBanner, isFalse);
      expect(materialApp.themeMode, equals(ThemeMode.system));
    });

    testWidgets('MyApp theme data has correct properties', (WidgetTester tester) async {
      await tester.pumpWidget(const MyApp());
      
      final MaterialApp materialApp = tester.widget(find.byType(MaterialApp));
      
      // Test light theme
      final ThemeData lightTheme = materialApp.theme!;
      expect(lightTheme.colorScheme.brightness, equals(Brightness.light));
      expect(lightTheme.colorScheme.primary, isNotNull);

      // Test dark theme
      final ThemeData darkTheme = materialApp.darkTheme!;
      expect(darkTheme.colorScheme.brightness, equals(Brightness.dark));
      expect(darkTheme.colorScheme.primary, isNotNull);
    });
  });

  group('MainPage Widget Tests', () {
    testWidgets('MainPage shows correct initial page', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: MainPage(setThemeMode: (ThemeMode mode) {}),
        ),
      );
      
      // Verify initial page is BarInfoPage
      expect(find.byType(BarInfoPage), findsOneWidget);
      expect(find.byType(SetupCrawlPage), findsNothing);
      expect(find.byType(MapPage), findsNothing);
      expect(find.byType(SettingsPage), findsNothing);
    });

    testWidgets('Bottom navigation bar has correct items', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: MainPage(setThemeMode: (ThemeMode mode) {}),
        ),
      );
      
      final bottomNavBar = tester.widget<BottomNavigationBar>(
        find.byType(BottomNavigationBar),
      );
      
      expect(bottomNavBar.items.length, equals(4));
      expect(bottomNavBar.items[0].label, equals('Bar Info'));
      expect(bottomNavBar.items[1].label, equals('Setup Crawl'));
      expect(bottomNavBar.items[2].label, equals('Map'));
      expect(bottomNavBar.items[3].label, equals('Settings'));
    });

    testWidgets('Navigation changes pages correctly', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: MainPage(setThemeMode: (ThemeMode mode) {}),
        ),
      );
      
      // Initially should show BarInfoPage
      expect(find.byType(BarInfoPage), findsOneWidget);
      
      // Tap Setup Crawl
      await tester.tap(find.byIcon(Icons.route));
      await tester.pumpAndSettle();
      expect(find.byType(SetupCrawlPage), findsOneWidget);
      
      // Tap Map
      await tester.tap(find.byIcon(Icons.map));
      await tester.pumpAndSettle();
      expect(find.byType(MapPage), findsOneWidget);
      
      // Tap Settings
      await tester.tap(find.byIcon(Icons.settings));
      await tester.pumpAndSettle();
      expect(find.byType(SettingsPage), findsOneWidget);
    });

    testWidgets('Settings page can change theme mode', (WidgetTester tester) async {
      bool callbackCalled = false;
      ThemeMode? passedMode;

      await tester.pumpWidget(
        MaterialApp(
          home: MainPage(
            setThemeMode: (ThemeMode mode) {
              callbackCalled = true;
              passedMode = mode;
            },
          ),
        ),
      );

      // Navigate to settings page
      await tester.tap(find.byIcon(Icons.settings));
      await tester.pumpAndSettle();

      // Get the SettingsPage widget
      final settingsPage = tester.widget<SettingsPage>(find.byType(SettingsPage));
      
      // Trigger theme change through the callback
      settingsPage.setThemeMode(ThemeMode.dark);
      
      // Verify callback was called with correct mode
      expect(callbackCalled, isTrue);
      expect(passedMode, equals(ThemeMode.dark));
    });
  });
}