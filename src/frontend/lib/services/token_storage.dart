import 'package:hive/hive.dart';
import 'dart:typed_data';
import 'dart:convert';
import '../models/user.dart';

class TokenStorage {
  static const _boxName = 'auth';
  static const _tokenKey = 'auth_token';
  static const _expiryKey = 'token_expiry';
  static const _userKey = 'user_data';
  static Box? _box;

  // Initialize storage
  static Future<void> initialize() async {
    if (_box == null || !(_box?.isOpen ?? false)) {
      _box = await Hive.openBox(_boxName, bytes: Uint8List(0));
    }
  }

  // Store token with expiry
  static Future<bool> storeToken(String token, String expiry) async {
    try {
      await initialize();
      await _box?.put(_tokenKey, token);
      await _box?.put(_expiryKey, expiry);
      return true;
    } catch (e) {
      return false;
    }
  }

  // Retrieve token
  static Future<String?> getToken() async {
    try {
      await initialize();
      return _box?.get(_tokenKey);
    } catch (e) {
      return null;
    }
  }

  // Retrieve token expiry
  static Future<String?> getTokenExpiry() async {
    try {
      await initialize();
      return _box?.get(_expiryKey);
    } catch (e) {
      return null;
    }
  }

  // Delete token (for logout)
  static Future<bool> deleteToken() async {
    try {
      await initialize();
      await _box?.delete(_tokenKey);
      await _box?.delete(_expiryKey);
      return true;
    } catch (e) {
      return false;
    }
  }

  // Store user data
  static Future<bool> storeUser(User user) async {
    try {
      await initialize();
      await _box?.put(_userKey, jsonEncode(user.toJson()));
      return true;
    } catch (e) {
      return false;
    }
  }

  // Retrieve user data
  static Future<User?> getUser() async {
    try {
      await initialize();
      final userStr = _box?.get(_userKey);
      if (userStr == null) return null;
      return User.fromJson(jsonDecode(userStr));
    } catch (e) {
      return null;
    }
  }

  // Delete user data
  static Future<bool> deleteUser() async {
    try {
      await initialize();
      await _box?.delete(_userKey);
      return true;
    } catch (e) {
      return false;
    }
  }

  // Clear all data (for logout)
  static Future<bool> clearAll() async {
    try {
      await initialize();
      await _box?.clear();
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
