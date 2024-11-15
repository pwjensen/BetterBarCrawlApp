import 'package:flutter/material.dart';
import 'package:app_settings/app_settings.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../services/token_storage.dart';

class SettingsPage extends StatelessWidget {
  final Function(ThemeMode) setThemeMode;

  const SettingsPage({super.key, required this.setThemeMode});

  Future<void> _handleLogout(BuildContext context) async {
    try {
      final success = await TokenStorage.deleteToken();
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              success ? 'Successfully logged out' : 'Logout failed',
            ),
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

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
            onTap: () {
              showDialog(
                context: context,
                builder: (context) => const LoginDialog(),
              );
            },
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
          ListTile(
            leading: const Icon(Icons.logout),
            title: const Text('Logout'),
            onTap: () => _handleLogout(context),
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

class LoginDialog extends StatefulWidget {
  const LoginDialog({super.key});

  @override
  State<LoginDialog> createState() => _LoginDialogState();
}

class _LoginDialogState extends State<LoginDialog> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isRegistering = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _initializeStorage();
  }

  Future<void> _initializeStorage() async {
    try {
      await TokenStorage.initialize();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error initializing storage: $e')),
        );
      }
    }
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  String _createBasicAuthHeader(String username, String password) {
    final credentials = base64Encode(utf8.encode('$username:$password'));
    return 'Basic $credentials';
  }

  Future<void> _handleSubmit() async {
    setState(() => _isLoading = true);

    try {
      final url = _isRegistering
          ? 'http://127.0.0.1:8000/api/auth/register/'
          : 'http://127.0.0.1:8000/api/auth/login/';

      final response = await http.post(
        Uri.parse(url),
        headers: {
          'authorization': _createBasicAuthHeader(
            _usernameController.text,
            _passwordController.text,
          ),
        },
      );

      if (response.statusCode == 200) {
        final token = jsonDecode(response.body)['token'];
        final success = await TokenStorage.storeToken(token);

        if (!success) {
          throw Exception('Failed to store token');
        }

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Successfully logged in')),
          );
          Navigator.of(context).pop();
        }
      } else {
        throw Exception('Server returned ${response.statusCode}');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(_isRegistering ? 'Register' : 'Login'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (_isLoading)
            const CircularProgressIndicator()
          else ...[
            TextField(
              controller: _usernameController,
              decoration: const InputDecoration(
                labelText: 'Username',
                hintText: 'Enter your username',
              ),
              keyboardType: TextInputType.text,
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _passwordController,
              decoration: const InputDecoration(
                labelText: 'Password',
                hintText: 'Enter your password',
              ),
              obscureText: true,
            ),
          ],
        ],
      ),
      actions: [
        TextButton(
          onPressed: () {
            setState(() {
              _isRegistering = !_isRegistering;
            });
          },
          child:
              Text(_isRegistering ? 'Switch to Login' : 'Switch to Register'),
        ),
        TextButton(
          onPressed: _handleSubmit,
          child: Text(_isRegistering ? 'Register' : 'Login'),
        ),
      ],
    );
  }
}
