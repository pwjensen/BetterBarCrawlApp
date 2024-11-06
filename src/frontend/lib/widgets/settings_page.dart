import 'package:flutter/material.dart';
import 'package:app_settings/app_settings.dart';

class SettingsPage extends StatelessWidget {
  final Function(ThemeMode) setThemeMode;

  const SettingsPage({super.key, required this.setThemeMode});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: ListView(
        children: [
          ListTile(
            leading: Icon(Icons.person),
            title: Text('Account'),
            subtitle: Text('Manage your account details'),
          ),
          ListTile(
            leading: const Icon(Icons.notifications),
            title: const Text('Notifications'),
            subtitle: const Text('Configure app notifications'),
            onTap: () {
              AppSettings.openAppSettings(type: AppSettingsType.notification);
            },
          ),
          ListTile(
            leading: const Icon(Icons.color_lens),
            title: const Text('Theme'),
            subtitle: const Text('Change app appearance'),
            onTap: () {
              showDialog(
                context: context,
                builder: (context) =>
                    ThemeSelectionDialog(setThemeMode: setThemeMode),
              );
            },
          ),
          ListTile(
            leading: Icon(Icons.language),
            title: Text('Language'),
            subtitle: Text('Set your preferred language'),
          ),
          ListTile(
            leading: Icon(Icons.info),
            title: Text('About'),
            subtitle: Text('App information and version'),
          ),
        ],
      ),
    );
  }
}

class ThemeSelectionDialog extends StatelessWidget {
  final Function(ThemeMode) setThemeMode;

  const ThemeSelectionDialog({super.key, required this.setThemeMode});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Select Theme'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            title: const Text('Light'),
            onTap: () {
              setThemeMode(ThemeMode.light);
              Navigator.of(context).pop();
            },
          ),
          ListTile(
            title: const Text('Dark'),
            onTap: () {
              setThemeMode(ThemeMode.dark);
              Navigator.of(context).pop();
            },
          ),
        ],
      ),
    );
  }
}
