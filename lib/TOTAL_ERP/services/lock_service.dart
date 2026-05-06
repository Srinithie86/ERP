import 'package:shared_preferences/shared_preferences.dart';

class LockService {
  static const String _keyAppPin = 'app_pin';
  static const String _keyIsLockEnabled = 'is_lock_enabled';

  static Future<void> savePin(String pin) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyAppPin, pin);
    await prefs.setBool(_keyIsLockEnabled, true);
  }

  static Future<void> disableLock() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyAppPin);
    await prefs.setBool(_keyIsLockEnabled, false);
  }

  static Future<bool> isLockEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyIsLockEnabled) ?? false;
  }

  static Future<bool> verifyPin(String enteredPin) async {
    final prefs = await SharedPreferences.getInstance();
    final savedPin = prefs.getString(_keyAppPin);
    return savedPin == enteredPin;
  }
}
