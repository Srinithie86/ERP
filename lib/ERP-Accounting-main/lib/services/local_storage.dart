import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Reads login-session values saved by the main ERP app.
/// Keys match exactly what the main app writes:
///   lt / ln       → saved as String by device_service.dart
///   uid / cid     → saved as String by sign_in_screen.dart / verify_with_otp.dart
///   role_id       → saved as String by login screens
///   device_id     → saved as String by device_service.dart
class LocalStorage {
  static const String _keyLat      = 'lt';
  static const String _keyLng      = 'ln';
  static const String _keyUid      = 'uid';
  static const String _keyCid      = 'cid';
  static const String _keyRoleId   = 'role_id';
  static const String _keyDeviceId = 'device_id';

  // ── Read latitude (saved as String by main app's device_service) ─────────
  static Future<String> getLat() async {
    final prefs = await SharedPreferences.getInstance();
    final value = prefs.getString(_keyLat) ?? prefs.get(_keyLat)?.toString() ?? '';
    if (kDebugMode && value.isEmpty) {
      debugPrint('⚠ LocalStorage: "lt" is empty — ensure the main ERP login has completed.');
    }
    return value;
  }

  // ── Read longitude ────────────────────────────────────────────────────────
  static Future<String> getLng() async {
    final prefs = await SharedPreferences.getInstance();
    final value = prefs.getString(_keyLng) ?? prefs.get(_keyLng)?.toString() ?? '';
    if (kDebugMode && value.isEmpty) {
      debugPrint('⚠ LocalStorage: "ln" is empty — ensure the main ERP login has completed.');
    }
    return value;
  }

  // ── Read uid ─────────────────────────────────────────────────────────────
  static Future<String> getUid() async {
    final prefs = await SharedPreferences.getInstance();
    final value = prefs.getString(_keyUid) ?? '';
    if (kDebugMode && value.isEmpty) {
      debugPrint('⚠ LocalStorage: "uid" is empty — user may not be logged in.');
    }
    return value;
  }

  // ── Read cid ─────────────────────────────────────────────────────────────
  static Future<String> getCid() async {
    final prefs = await SharedPreferences.getInstance();
    final value = prefs.getString(_keyCid) ?? '';
    if (kDebugMode && value.isEmpty) {
      debugPrint('⚠ LocalStorage: "cid" is empty — user may not be logged in.');
    }
    return value;
  }

  // ── Read role_id ─────────────────────────────────────────────────────────
  static Future<String> getRoleId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyRoleId) ?? '1';
  }

  // ── Read device_id ───────────────────────────────────────────────────────
  static Future<String> getDeviceId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyDeviceId) ?? '';
  }
}
