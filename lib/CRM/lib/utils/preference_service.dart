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
  static const String _defaultCid = '21472147';

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
    return prefs.getString(_keyCusId);
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
