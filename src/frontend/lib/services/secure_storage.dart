import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStorage {
  static const _storage = FlutterSecureStorage();
  static const _tokenKey = 'auth_token';

  // Store token
  static Future<void> storeToken(String token) async {
    await _storage.write(key: _tokenKey, value: token);
  }

  // Retrieve token
  static Future<String?> getToken() async {
    return await _storage.read(key: _tokenKey);
  }

  // Delete token (for logout)
  static Future<void> deleteToken() async {
    await _storage.delete(key: _tokenKey);
  }
}
