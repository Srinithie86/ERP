import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class StorageService {
  static const String _keyCid = 'cid';
  static const String _keyToken = 'token';
  static const String _keyUserId = 'uid';
  static const String _keyRoleId = 'role_id';
  static const String _keyEngineerId = 'engineer_id';
  static const String _keyCusId = 'cus_id';
  static const String _keyName = 'name';
  static const String _keyEmail = 'email';
  static const String _keyPhone = 'mobile';
  static const String _keyAddress = 'address';
  static const String _keyCity = 'city';
  static const String _keyState = 'state';
  static const String _keyPincode = 'pincode';
  static const String _keyCountry = 'country';

  /// Highly aggressive search for technician ID (led_id or cus_id)
  static String resolveTechnicianId(Map<String, dynamic> data) {
    // 1. Check all possible keys at top level
    final keys = [
      'led_id', ' led_id', 'ledid',
      'cus_id', ' cus_id', 'cusid',
      'engineer_id', ' engineer_id', 'eng_id', 'eg_id'
    ];
    
    for (var key in keys) {
      final val = data[key]?.toString().trim() ?? '';
      if (val.isNotEmpty && val != "0" && val != "null") return val;
    }

    // 2. Check inside "data" list if it exists
    if (data['data'] is List && (data['data'] as List).isNotEmpty) {
      final first = data['data'][0];
      if (first is Map) {
        for (var key in keys) {
          final val = first[key]?.toString().trim() ?? '';
          if (val.isNotEmpty && val != "0" && val != "null") return val;
        }
      }
    }
    
    return '';
  }

  static Future<void> saveUser(Map<String, dynamic> data) async {
    try {
      final prefs = await SharedPreferences.getInstance();

      final userId =
          (data["user_id"] ??
                  data["uid"] ??
                  data["id"] ??
                  data["data"]?[0]?["uid"])
              ?.toString();
      final roleId = (data["role_id"] ?? data["data"]?[0]?["role_id"])
          ?.toString();
      final token = (data["token"] ?? data["data"]?[0]?["token"])?.toString();
      final cid = (data["cid"] ?? data["data"]?[0]?["cid"])?.toString();

      // Use the aggressive resolver
      final techId = resolveTechnicianId(data);

      debugPrint("DEBUG: StorageService.saveUser => Aggressive resolve techId: '$techId' from input keys: ${data.keys.take(10).toList()}");

      if (techId.isNotEmpty) {
        await prefs.setString(_keyEngineerId, techId);
        await prefs.setString(_keyCusId, techId);
        debugPrint("DEBUG: StorageService.saveUser => SAVED TechId: $techId");
      } else {
        debugPrint("DEBUG: StorageService.saveUser => techId resolved as empty, preserving existing identity.");
      }

      final name =
          (data["name"] ?? data["user_name"] ?? data["data"]?[0]?["name"])
              ?.toString();
      final email =
          (data["email"] ?? data["user_email"] ?? data["data"]?[0]?["email"])
              ?.toString();
      final phone =
          (data["mobile"] ??
                  data["phone"] ??
                  data["user_phone"] ??
                  data["data"]?[0]?["mobile"])
              ?.toString();
      final address = (data["address"] ?? data["data"]?[0]?["address"])
          ?.toString();
      final city = (data["city"] ?? data["data"]?[0]?["city"])?.toString();
      final state = (data["state"] ?? data["data"]?[0]?["state"])?.toString();
      final pincode = (data["pincode"] ?? data["data"]?[0]?["pincode"])
          ?.toString();
      final country = (data["country"] ?? data["data"]?[0]?["country"])
          ?.toString();

      if (token != null && token.isNotEmpty)
        await prefs.setString("token", token);
      if (cid != null && cid.isNotEmpty) await prefs.setString("cid", cid);
      if (userId != null && userId.isNotEmpty)
        await prefs.setString("uid", userId);
      if (roleId != null && roleId.isNotEmpty)
        await prefs.setString("role_id", roleId);
      if (name != null && name.isNotEmpty)
        await prefs.setString(_keyName, name);
      if (email != null && email.isNotEmpty)
        await prefs.setString(_keyEmail, email);
      if (phone != null && phone.isNotEmpty)
        await prefs.setString(_keyPhone, phone);
      if (address != null && address.isNotEmpty)
        await prefs.setString(_keyAddress, address);
      if (city != null && city.isNotEmpty)
        await prefs.setString(_keyCity, city);
      if (state != null && state.isNotEmpty)
        await prefs.setString(_keyState, state);
      if (pincode != null && pincode.isNotEmpty)
        await prefs.setString(_keyPincode, pincode);
      if (country != null && country.isNotEmpty)
        await prefs.setString(_keyCountry, country);

      await prefs.setBool("is_logged_in", true);
      debugPrint(
        "StorageService: session saved (uid: $userId, cid: $cid, name: $name)",
      );
    } catch (e) {
      debugPrint("StorageService Error: $e");
    }
  }

  static Future<String?> getCid() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyCid);
  }

  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyToken);
  }

  static Future<String?> getUid() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyUserId);
  }

  static Future<String?> getRoleId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyRoleId);
  }

  static Future<String?> getEngineerId() async {
    final prefs = await SharedPreferences.getInstance();

    String? id = prefs.getString(_keyCusId);
    if (id != null && id.isNotEmpty) {
      debugPrint(
        "DEBUG: StorageService => Found Engineer ID in 'cus_id' key: $id",
      );
      return id;
    }

    id = prefs.getString(_keyEngineerId);
    if (id != null && id.isNotEmpty) {
      debugPrint(
        "DEBUG: StorageService => Found Engineer ID in 'engineer_id' key: $id",
      );
      return id;
    }

    final loginRes = prefs.getString('login_response');
    if (loginRes != null) {
      try {
        final Map<String, dynamic> data = jsonDecode(loginRes);
        final rawLed = data['led_id']?.toString() ?? '';
        final rawCus = data['cus_id']?.toString() ?? '';
        final rawEng = data['engineer_id']?.toString() ?? '';

        if (rawLed.isNotEmpty && rawLed != "0") return rawLed;
        if (rawCus.isNotEmpty && rawCus != "0") return rawCus;
        if (rawEng.isNotEmpty && rawEng != "0") return rawEng;
      } catch (e) {
        debugPrint("DEBUG: StorageService => login_response parse error: $e");
      }
    }

    final fallback = prefs.getString(_keyUserId);
    debugPrint("DEBUG: StorageService => Falling back to UID: $fallback");
    return fallback;
  }

  static Future<String?> getCusId() async => getEngineerId();

  static Future<String?> getName() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyName);
  }

  static Future<String?> getPhone() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyPhone);
  }

  static Future<String?> getEmail() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyEmail);
  }

  static Future<String?> getAddress() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyAddress);
  }

  static Future<String?> getCity() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyCity);
  }

  static Future<String?> getState() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyState);
  }

  static Future<String?> getPincode() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyPincode);
  }

  static Future<String?> getCountry() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyCountry);
  }

  static Future<void> saveCusId(String cusId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyCusId, cusId);
  }

  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }

  static Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool("is_logged_in") ?? false;
  }
}
