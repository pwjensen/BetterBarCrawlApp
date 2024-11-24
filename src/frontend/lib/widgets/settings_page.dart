import 'package:flutter/material.dart';
import 'package:app_settings/app_settings.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../services/token_storage.dart';
import '../models/user.dart';
import 'dart:io';

final baseUrl = '${dotenv.env['SERVER_HOST']}:${dotenv.env['SERVER_PORT']}';

void _debugEnv() {
  print('[ENV_DEBUG] baseUrl: $baseUrl');
  print('[ENV_DEBUG] SERVER_HOST: ${dotenv.env['SERVER_HOST']}');
  print('[ENV_DEBUG] SERVER_PORT: ${dotenv.env['SERVER_PORT']}');
}

class SettingsPage extends StatefulWidget {
  final Function(ThemeMode) setThemeMode;

  const SettingsPage({super.key, required this.setThemeMode});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool _isLoggedIn = false;
  User? _user;

  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
    _debugEnv();
  }

  Future<void> _checkLoginStatus() async {
    final token = await TokenStorage.getToken();
    final user = await TokenStorage.getUser();
    if (mounted) {
      setState(() {
        _isLoggedIn = token != null;
        _user = user;
      });
    }
  }

  Future<void> _handleLogout(BuildContext context) async {
    try {
      // Show loading indicator
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: CircularProgressIndicator(),
        ),
      );

      // Get the token for the API call
      final token = await TokenStorage.getToken();
      if (token == null) {
        throw Exception('No auth token found');
      }

      final uri = Uri.http(baseUrl, 'api/auth/logout/');
      print('Logout URI: $uri');
      final response = await http.post(
        uri,
        headers: {
          HttpHeaders.acceptHeader: 'application/json',
          HttpHeaders.authorizationHeader: 'Token $token',
        },
      );
      // print(response.body);
      // print(response.request?.headers);

      // Close loading indicator
      if (context.mounted) {
        Navigator.of(context).pop();
      }

      if (response.statusCode == 204) {
        // Successfully logged out from server, now clear local storage
        final tokenSuccess = await TokenStorage.deleteToken();
        final userSuccess = await TokenStorage.deleteUser();

        if (tokenSuccess && userSuccess) {
          setState(() {
            _isLoggedIn = false;
            _user = null;
          });

          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Successfully logged out')),
            );
          }
        } else {
          throw Exception('Failed to clear local storage');
        }
      } else {
        // Handle unsuccessful logout
        throw Exception(
            'Logout failed: Server returned ${response.statusCode}');
      }
    } catch (e) {
      // Close loading indicator if it's still showing
      if (context.mounted && Navigator.canPop(context)) {
        Navigator.of(context).pop();
      }

      // Show error message
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Logout error: $e'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }

      // If the API call failed but we're still logged in locally,
      // we might want to give the user the option to force logout locally
      if (context.mounted) {
        final shouldForceLogout = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Logout Failed'),
            content: const Text(
              'Failed to logout from server. Would you like to logout locally anyway?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: const Text('Logout Locally'),
              ),
            ],
          ),
        );

        if (shouldForceLogout == true) {
          // Force local logout
          final tokenSuccess = await TokenStorage.deleteToken();
          final userSuccess = await TokenStorage.deleteUser();

          if (tokenSuccess && userSuccess) {
            setState(() {
              _isLoggedIn = false;
              _user = null;
            });

            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Logged out locally'),
                ),
              );
            }
          }
        }
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
            leading: const Icon(Icons.person),
            title: Text(_isLoggedIn
                ? '${_user?.firstName} ${_user?.lastName}'
                : 'Sign In'),
            subtitle: Text(_isLoggedIn
                ? 'Manage your account'
                : 'Sign in to access your account'),
            onTap: () async {
              final result = await showDialog<bool>(
                context: context,
                builder: (context) => const LoginDialog(),
              );
              if (result == true) {
                _checkLoginStatus();
              }
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
                    ThemeSelectionDialog(setThemeMode: widget.setThemeMode),
              );
            },
          ),
          const ListTile(
            leading: Icon(Icons.language),
            title: Text('Language'),
            subtitle: Text('Set your preferred language'),
          ),
          const ListTile(
            leading: Icon(Icons.info),
            title: Text('About'),
            subtitle: Text('App information and version'),
          ),
          if (_isLoggedIn)
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
    return Dialog(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Select Theme',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
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
      ),
    );
  }
}

class LoginDialog extends StatefulWidget {
  final String? initialUsername;
  final String? initialPassword;
  final bool autoLogin;

  const LoginDialog({
    super.key,
    this.initialUsername,
    this.initialPassword,
    this.autoLogin = false,
  });

  @override
  State<LoginDialog> createState() => _LoginDialogState();
}

class _LoginDialogState extends State<LoginDialog> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _initializeStorage();
    _usernameController.text = widget.initialUsername ?? '';
    _passwordController.text = widget.initialPassword ?? '';

    if (widget.autoLogin) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _handleSubmit();
      });
    }
  }

  Future<void> _initializeStorage() async {
    try {
      await TokenStorage.initialize();
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Error initializing storage: $e';
        });
      }
    }
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<User?> _fetchUserData(String token) async {
    try {
      final uri = Uri.http(baseUrl, 'api/user/');
      print('User Data URI: $uri');

      final response = await http.get(
        uri,
        headers: {
          HttpHeaders.acceptHeader: 'application/json',
          HttpHeaders.authorizationHeader: 'Token $token',
        },
      );

      if (response.statusCode == 200) {
        final userData = jsonDecode(response.body);
        return User(
          username: userData['username'],
          email: userData['email'],
          firstName: userData['first_name'],
          lastName: userData['last_name'],
        );
      }
      return null;
    } catch (e) {
      debugPrint('Error fetching user data: $e');
      return null;
    }
  }

  Future<void> _handleSubmit() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final credentials = base64Encode(utf8
          .encode('${_usernameController.text}:${_passwordController.text}'));

      final uri = Uri.http(baseUrl, 'api/auth/login/');
      print('Login URI: $uri');

      final response = await http.post(
        uri,
        headers: {
          HttpHeaders.acceptHeader: 'application/json',
          HttpHeaders.authorizationHeader: 'Basic $credentials',
        },
      );

      if (!mounted) return;

      final responseData = jsonDecode(response.body);

      if (response.statusCode == 200) {
        final token = responseData['token'];
        final expiry = responseData['expiry'];

        if (token == null) throw Exception('No token received');
        if (expiry == null) throw Exception('No expiry received');

        final tokenStored = await TokenStorage.storeToken(token, expiry);
        if (!tokenStored) throw Exception('Failed to store token');

        // Fetch user data after successful login
        final userData = await _fetchUserData(token);
        if (userData == null) throw Exception('Failed to fetch user data');

        final userStored = await TokenStorage.storeUser(userData);
        if (!userStored) throw Exception('Failed to store user data');

        if (!mounted) return;
        Navigator.of(context)
            .pop(true); // Return true to indicate successful login
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Successfully logged in')),
        );
      } else if (response.statusCode == 400) {
        setState(() {
          _errorMessage = responseData['detail'] ??
              responseData['error'] ??
              'Invalid credentials';
        });
      } else if (response.statusCode == 401) {
        setState(() {
          _errorMessage = 'Invalid username or password';
        });
      } else {
        setState(() {
          _errorMessage =
              responseData['detail'] ?? 'Server error (${response.statusCode})';
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error: $e';
      });
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.only(
            top: 16,
            left: 16,
            right: 16,
            bottom: MediaQuery.of(context).viewInsets.bottom + 16,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Login',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              if (_isLoading)
                const Center(child: CircularProgressIndicator())
              else ...[
                TextField(
                  controller: _usernameController,
                  decoration: const InputDecoration(
                    labelText: 'Username',
                    hintText: 'Enter your username',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.text,
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _passwordController,
                  decoration: const InputDecoration(
                    labelText: 'Password',
                    hintText: 'Enter your password',
                    border: OutlineInputBorder(),
                  ),
                  obscureText: true,
                ),
                if (_errorMessage != null) ...[
                  const SizedBox(height: 16),
                  Text(
                    _errorMessage!,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.error,
                      fontSize: 12,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ],
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                      showDialog(
                        context: context,
                        builder: (context) => const RegisterDialog(),
                      );
                    },
                    child: const Text('Switch to Register'),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: _handleSubmit,
                    child: const Text('Login'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class RegisterDialog extends StatefulWidget {
  const RegisterDialog({super.key});

  @override
  State<RegisterDialog> createState() => _RegisterDialogState();
}

class _RegisterDialogState extends State<RegisterDialog> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _password2Controller = TextEditingController();
  final _emailController = TextEditingController();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  bool _isLoading = false;
  String? _errorMessage;

  // Regular expression for email validation
  final _emailRegex = RegExp(
    r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    caseSensitive: false,
  );

  // List of common passwords to check against
  final Set<String> _commonPasswords = {
    'password',
    'password123',
    '123456',
    '12345678',
    'qwerty',
    'abc123',
    'letmein',
    'welcome',
    'monkey',
    'dragon',
    'baseball',
    'football',
    'admin',
    'password1',
    'master',
    '111111',
    '123123',
    'superman',
    'iloveyou',
    '1234567',
    'trustno1',
    // Add more common passwords as needed
  };

  // Password strength validation
  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password required';
    }

    if (value.length < 8) {
      return 'Password must be at least 8 characters';
    }

    if (int.tryParse(value) != null) {
      return 'Password cannot be all numbers';
    }

    // Check if password is in common password list
    if (_commonPasswords.contains(value.toLowerCase())) {
      return 'This password is too common';
    }

    // Check for password complexity
    bool hasUppercase = value.contains(RegExp(r'[A-Z]'));
    bool hasLowercase = value.contains(RegExp(r'[a-z]'));
    bool hasNumbers = value.contains(RegExp(r'[0-9]'));
    bool hasSpecialCharacters =
        value.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'));

    int strengthScore = 0;
    if (hasUppercase) strengthScore++;
    if (hasLowercase) strengthScore++;
    if (hasNumbers) strengthScore++;
    if (hasSpecialCharacters) strengthScore++;

    if (strengthScore < 3) {
      return 'Password must contain at least 3 of the following:\nUppercase letters, lowercase letters, numbers, special characters';
    }

    // Check if password contains parts of username or email
    final username = _usernameController.text.toLowerCase();
    final email = _emailController.text.toLowerCase();
    if (username.isNotEmpty && value.toLowerCase().contains(username)) {
      return 'Password cannot contain your username';
    }
    if (email.isNotEmpty) {
      final emailUsername = email.split('@')[0];
      if (value.toLowerCase().contains(emailUsername)) {
        return 'Password cannot contain parts of your email';
      }
    }

    return null;
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    _password2Controller.dispose();
    _emailController.dispose();
    _firstNameController.dispose();
    _lastNameController.dispose();
    super.dispose();
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final uri = Uri.http(baseUrl, 'api/user/');
      print('Register URI: $uri');

      // Store context and navigator before async operation
      final currentContext = context;
      final navigator = Navigator.of(currentContext);

      final response = await http.post(
        uri,
        headers: {
          HttpHeaders.acceptHeader: 'application/json',
          HttpHeaders.contentTypeHeader: 'application/json',
        },
        body: jsonEncode({
          'username': _usernameController.text,
          'password': _passwordController.text,
          'password2': _password2Controller.text,
          'email': _emailController.text,
          'first_name': _firstNameController.text,
          'last_name': _lastNameController.text,
        }),
      );

      if (response.statusCode == 201) {
        if (!mounted) return;
        navigator.pop();

        // Store credentials for later use
        final username = _usernameController.text;
        final password = _passwordController.text;

        if (!mounted) return;
        final result = await showDialog<bool>(
          context: context,
          builder: (context) => LoginDialog(
            initialUsername: username,
            initialPassword: password,
            autoLogin: true,
          ),
        );

        // Handle login result
        if (result == true) {
          if (!mounted) return;
          Navigator.of(context).pop(true);
        }

        // Show success message
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Successfully registered')),
        );
      } else {
        final error = jsonDecode(response.body);
        throw Exception(error['detail'] ?? 'Registration failed');
      }
    } catch (e) {
      if (mounted) {
        setState(() => _errorMessage = 'Error: $e');
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.only(
            top: 16,
            left: 16,
            right: 16,
            bottom: MediaQuery.of(context).viewInsets.bottom + 16,
          ),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  'Register',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                if (_isLoading)
                  const Center(child: CircularProgressIndicator())
                else ...[
                  TextFormField(
                    controller: _usernameController,
                    decoration: const InputDecoration(
                      labelText: 'Username',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) =>
                        value?.isEmpty ?? true ? 'Username required' : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _passwordController,
                    decoration: const InputDecoration(
                      labelText: 'Password',
                      border: OutlineInputBorder(),
                      helperText:
                          'Use at least 8 characters with a mix of letters, numbers, and symbols',
                    ),
                    obscureText: true,
                    validator: _validatePassword,
                    onChanged: (value) {
                      // Trigger form validation on password change
                      _formKey.currentState?.validate();
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _password2Controller,
                    decoration: const InputDecoration(
                      labelText: 'Confirm Password',
                      border: OutlineInputBorder(),
                    ),
                    obscureText: true,
                    validator: (value) => value != _passwordController.text
                        ? 'Passwords must match'
                        : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _emailController,
                    decoration: const InputDecoration(
                      labelText: 'Email',
                      hintText: 'Enter a valid email address',
                      border: OutlineInputBorder(),
                      helperText: 'Example: user@example.com',
                    ),
                    keyboardType: TextInputType.emailAddress,
                    autocorrect: false,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Email required';
                      }
                      if (!_emailRegex.hasMatch(value)) {
                        return 'Please enter a valid email address';
                      }
                      return null;
                    },
                    onChanged: (value) {
                      // Revalidate password when email changes
                      if (_passwordController.text.isNotEmpty) {
                        _formKey.currentState?.validate();
                      }
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _firstNameController,
                    decoration: const InputDecoration(
                      labelText: 'First Name',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) =>
                        value?.isEmpty ?? true ? 'First name required' : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _lastNameController,
                    decoration: const InputDecoration(
                      labelText: 'Last Name',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) =>
                        value?.isEmpty ?? true ? 'Last name required' : null,
                  ),
                  if (_errorMessage != null) ...[
                    const SizedBox(height: 16),
                    Text(
                      _errorMessage!,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.error,
                        fontSize: 12,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ],
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                        showDialog(
                          context: context,
                          builder: (context) => const LoginDialog(),
                        );
                      },
                      child: const Text('Switch to Login'),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: _handleSubmit,
                      child: const Text('Register'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
