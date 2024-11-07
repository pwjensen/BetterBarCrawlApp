import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:frontend/main.dart';
import 'package:frontend/widgets/bar_info_page.dart';
import 'package:frontend/widgets/setup_crawl_page.dart';
import 'package:frontend/widgets/map_page.dart';
import 'package:frontend/widgets/settings_page.dart';

void main() {
  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    await dotenv.load(fileName: ".env");
  });

  group('MyApp Widget Tests', () {
    testWidgets('MyApp initializes with correct theme properties',
        (WidgetTester tester) async {
      await tester.pumpWidget(const MyApp());

      final MaterialApp materialApp = tester.widget(find.byType(MaterialApp));
      expect(materialApp.title, equals('Bar Crawl App'));
      expect(materialApp.debugShowCheckedModeBanner, isFalse);
      expect(materialApp.themeMode, equals(ThemeMode.system));
    });

    testWidgets('MyApp has correct theme data', (WidgetTester tester) async {
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

    testWidgets('Theme mode can be changed', (WidgetTester tester) async {
      await tester.pumpWidget(const MyApp());
      
      // Find MainPage
      final mainPage = tester.widget<MainPage>(find.byType(MainPage));
      
      // Test theme mode changes
      mainPage.setThemeMode(ThemeMode.dark);
      await tester.pump();
      expect(
        tester.widget<MaterialApp>(find.byType(MaterialApp)).themeMode,
        equals(ThemeMode.dark),
      );

      mainPage.setThemeMode(ThemeMode.light);
      await tester.pump();
      expect(
        tester.widget<MaterialApp>(find.byType(MaterialApp)).themeMode,
        equals(ThemeMode.light),
      );
    });
  });

  group('MainPage Navigation Tests', () {
    testWidgets('MainPage initializes with BarInfoPage',
        (WidgetTester tester) async {
      await tester.pumpWidget(const MyApp());

      expect(find.byType(BarInfoPage), findsOneWidget);
      expect(find.byType(SetupCrawlPage), findsNothing);
      expect(find.byType(MapPage), findsNothing);
      expect(find.byType(SettingsPage), findsNothing);
    });

    testWidgets('Bottom navigation bar has correct items',
        (WidgetTester tester) async {
      await tester.pumpWidget(const MyApp());

      final bottomNavBar = tester.widget<BottomNavigationBar>(
        find.byType(BottomNavigationBar),
      );

      expect(bottomNavBar.items.length, equals(4));
      expect(bottomNavBar.items[0].label, equals('Bar Info'));
      expect(bottomNavBar.items[1].label, equals('Setup Crawl'));
      expect(bottomNavBar.items[2].label, equals('Map'));
      expect(bottomNavBar.items[3].label, equals('Settings'));

      expect((bottomNavBar.items[0].icon as Icon).icon, equals(Icons.local_bar));
      expect((bottomNavBar.items[1].icon as Icon).icon, equals(Icons.route));
      expect((bottomNavBar.items[2].icon as Icon).icon, equals(Icons.map));
      expect((bottomNavBar.items[3].icon as Icon).icon, equals(Icons.settings));
    });

    testWidgets('Navigation between pages works correctly',
        (WidgetTester tester) async {
      await tester.pumpWidget(const MyApp());

      // Initially on BarInfoPage
      expect(find.byType(BarInfoPage), findsOneWidget);

      // Navigate to Setup Crawl
      await tester.tap(find.byIcon(Icons.route));
      await tester.pumpAndSettle();
      expect(find.byType(SetupCrawlPage), findsOneWidget);

      // Navigate to Map
      await tester.tap(find.byIcon(Icons.map));
      await tester.pumpAndSettle();
      expect(find.byType(MapPage), findsOneWidget);

      // Navigate to Settings
      await tester.tap(find.byIcon(Icons.settings));
      await tester.pumpAndSettle();
      expect(find.byType(SettingsPage), findsOneWidget);

      // Navigate back to Bar Info
      await tester.tap(find.byIcon(Icons.local_bar));
      await tester.pumpAndSettle();
      expect(find.byType(BarInfoPage), findsOneWidget);
    });

    testWidgets('Bottom navigation bar updates current index',
        (WidgetTester tester) async {
      await tester.pumpWidget(const MyApp());

      // Initially should be at index 0
      BottomNavigationBar bottomNavBar = tester.widget(find.byType(BottomNavigationBar));
      expect(bottomNavBar.currentIndex, equals(0));

      // Navigate to Setup Crawl (index 1)
      await tester.tap(find.byIcon(Icons.route));
      await tester.pumpAndSettle();
      bottomNavBar = tester.widget(find.byType(BottomNavigationBar));
      expect(bottomNavBar.currentIndex, equals(1));

      // Navigate to Map (index 2)
      await tester.tap(find.byIcon(Icons.map));
      await tester.pumpAndSettle();
      bottomNavBar = tester.widget(find.byType(BottomNavigationBar));
      expect(bottomNavBar.currentIndex, equals(2));

      // Navigate to Settings (index 3)
      await tester.tap(find.byIcon(Icons.settings));
      await tester.pumpAndSettle();
      bottomNavBar = tester.widget(find.byType(BottomNavigationBar));
      expect(bottomNavBar.currentIndex, equals(3));
    });
  });
}