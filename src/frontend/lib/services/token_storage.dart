import 'package:hive/hive.dart';
import 'dart:typed_data';

class TokenStorage {
  static const _boxName = 'auth';
  static const _tokenKey = 'auth_token';
  static Box? _box;

  // Initialize storage
  static Future<void> initialize() async {
    // Initialize an in-memory box
    _box = await Hive.openBox(_boxName, bytes: Uint8List(0));
  }

  // Store token
  static Future<bool> storeToken(String token) async {
    try {
      if (_box == null || !(_box?.isOpen ?? false)) {
        await initialize();
      }
      await _box?.put(_tokenKey, token);
      return true;
    } catch (e) {
      return false;
    }
  }

  // Retrieve token
  static Future<String?> getToken() async {
    try {
      if (_box == null || !(_box?.isOpen ?? false)) {
        await initialize();
      }
      return _box?.get(_tokenKey);
    } catch (e) {
      return null;
    }
  }

  // Delete token (for logout)
  static Future<bool> deleteToken() async {
    try {
      if (_box == null || !(_box?.isOpen ?? false)) {
        await initialize();
      }
      await _box?.delete(_tokenKey);
      return true;
    } catch (e) {
      return false;
    }
  }

  // Close box when app terminates
  static Future<void> dispose() async {
    await _box?.close();
    _box = null;
  }
}
