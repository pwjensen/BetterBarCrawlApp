import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:hive/hive.dart';
import 'dart:io';
import 'widgets/bar_info_page.dart';
import 'widgets/setup_crawl_page.dart';
import 'widgets/settings_page.dart';
import 'services/token_storage.dart';
import 'package:logging/logging.dart';
import 'widgets/directions_container.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    final directory = await Directory.systemTemp.create();
    Hive.init(directory.path);

    await Hive.openBox('saved_locations');
  } catch (e) {
    Logger('Main').severe('Error initializing storage: $e');
  }

  await dotenv.load(fileName: ".env");
  await TokenStorage.initialize();

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  ThemeMode _themeMode = ThemeMode.system;

  void setThemeMode(ThemeMode themeMode) {
    setState(() {
      _themeMode = themeMode;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Bar Crawl App',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        brightness: Brightness.light,
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue,
          brightness: Brightness.dark,
        ),
      ),
      themeMode: _themeMode,
      debugShowCheckedModeBanner: false,
      home: MainPage(setThemeMode: setThemeMode),
    );
  }
}

class MainPage extends StatefulWidget {
  final void Function(ThemeMode) setThemeMode;

  const MainPage({super.key, required this.setThemeMode});

  @override
  MainPageState createState() => MainPageState();
}

class MainPageState extends State<MainPage> {
  int _selectedIndex = 0;
  final GlobalKey<SetupCrawlPageState> setupCrawlKey = GlobalKey();

  void setIndex(int index) {
    setState(() {
      _selectedIndex = index;
      if (index == 1) {
        setupCrawlKey.currentState?.refresh();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: [
          const BarInfoPage(),
          SetupCrawlPage(key: setupCrawlKey),
          DirectionsContainer(),
          SettingsPage(setThemeMode: widget.setThemeMode),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _selectedIndex,
        onTap: setIndex,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.search),
            label: 'Search',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.add),
            label: 'Setup',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.directions),
            label: 'Directions',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
      ),
    );
  }
}
