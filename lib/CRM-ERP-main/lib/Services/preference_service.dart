import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PreferenceService {
  static const String _keyCid = 'cid';
  static const String _keyToken = 'token';
  static const String _keyCusId = 'cus_id';
  static const String _keyLedId = 'led_id';
  static const String _keyName = 'name';
  static const String _keyEmail = 'email';
  static const String _keyMobile = 'number';
  static const String _keyUname = 'uname';
  static const String _keyAppSignature = 'app_signature';
  static const String _keyUid = 'uid';
  static const String _keyLt = 'lt';
  static const String _keyLn = 'ln';
  static const String _keyDeviceId = 'device_id';
  static const String _defaultCid = '';

  static Future<String?> getUid() async {
    final prefs = await SharedPreferences.getInstance();
    
    // Debug logging to track down missing UID
    final keys = prefs.getKeys();
    debugPrint("------------ PREFERENCE KEYS: $keys ------------");
    for (String key in keys) {
      debugPrint("KEY: $key, VALUE: ${prefs.get(key)}");
    }

    return prefs.getString(_keyUid) ?? 
           prefs.getString('server_uid') ??
           prefs.getString(_keyCusId) ??
           prefs.getString('login_cus_id') ??
           prefs.getString('user_id'); // Added user_id as fallback
  }

  static Future<void> setUid(String uid) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyUid, uid);
  }

  static Future<String> getLt() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyLt) ?? '';
  }

  static Future<void> setLt(String lt) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyLt, lt);
  }

  static Future<String> getLn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyLn) ?? '';
  }

  static Future<void> setLn(String ln) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyLn, ln);
  }

  static Future<String> getDeviceId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyDeviceId) ?? '';
  }

  static Future<void> setDeviceId(String deviceId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyDeviceId, deviceId);
  }

  static Future<String> getAppSignature() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyAppSignature) ?? '';
  }

  static Future<void> setAppSignature(String signature) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyAppSignature, signature);
  }

  static Future<String> getCid() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyCid) ?? _defaultCid;
  }

  static Future<void> setCid(String cid) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyCid, cid);
  }

  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyToken);
  }

  static Future<void> setToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyToken, token);
  }

  static Future<String?> getCusId() async {
    final prefs = await SharedPreferences.getInstance();
    // Try multiple keys for robustness across CRM and HRM
    return prefs.getString(_keyCusId) ?? 
           prefs.getString('uid') ?? 
           prefs.getString('login_cus_id') ??
           prefs.getString('server_uid');
  }

  static Future<void> setCusId(String cusId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyCusId, cusId);
  }

  static Future<String?> getLedId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyLedId);
  }

  static Future<void> setLedId(String ledId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyLedId, ledId);
  }

  static Future<String?> getName() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyName);
  }

  static Future<void> setName(String name) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyName, name);
  }

  static Future<String?> getEmail() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyEmail);
  }

  static Future<void> setEmail(String email) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyEmail, email);
  }

  static Future<String?> getMobile() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyMobile);
  }

  static Future<void> setMobile(String mobile) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyMobile, mobile);
  }

  static Future<String?> getUname() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyUname);
  }

  static Future<void> setUname(String uname) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyUname, uname);
  }

  // Generic methods for other preferences if needed
  static Future<String?> getString(String key) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(key);
  }

  static Future<void> setString(String key, String value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(key, value);
  }
}
