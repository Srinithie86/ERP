import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class StorageService {
  static const String _keyCid = 'cid';
  static const String _keyToken = 'token';
  static const String _keyUserId = 'uid';
  static const String _keyRoleId = 'role_id';
  static const String _keyEngineerId = 'engineer_id';
  static const String _keyCusId = 'cus_id';
  static const String _keyName = 'user_name';
  static const String _keyEmail = 'user_email';
  static const String _keyPhone = 'user_phone';
  static const String _keyAddress = 'user_address';
  static const String _keyCity = 'user_city';
  static const String _keyState = 'user_state';
  static const String _keyPincode = 'user_pincode';
  static const String _keyCountry = 'user_country';

  static Future<void> saveUser(Map<String, dynamic> data) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // Extract IDs safely from various possible keys
      final userId = (data["user_id"] ?? data["uid"] ?? data["id"] ?? data["data"]?[0]?["id"])?.toString();
      final roleId = (data["role_id"] ?? data["data"]?[0]?["role_id"])?.toString();
      final token = (data["token"] ?? data["data"]?[0]?["token"])?.toString();
      final cid = (data["cid"] ?? data["data"]?[0]?["cid"])?.toString();
      final cusId = (data["cus_id"] ?? data["engineer_id"] ?? data["eg_id"] ?? data["data"]?[0]?["cus_id"])?.toString();
      final name = (data["name"] ?? data["user_name"] ?? data["data"]?[0]?["name"])?.toString();
      final email = (data["email"] ?? data["user_email"] ?? data["data"]?[0]?["email"])?.toString();
      final phone = (data["mobile"] ?? data["phone"] ?? data["user_phone"] ?? data["data"]?[0]?["mobile"])?.toString();
      final address = (data["address"] ?? data["data"]?[0]?["address"])?.toString();
      final city = (data["city"] ?? data["data"]?[0]?["city"])?.toString();
      final state = (data["state"] ?? data["data"]?[0]?["state"])?.toString();
      final pincode = (data["pincode"] ?? data["data"]?[0]?["pincode"])?.toString();
      final country = (data["country"] ?? data["data"]?[0]?["country"])?.toString();

      if (token != null && token.isNotEmpty) await prefs.setString("token", token);
      if (cid != null && cid.isNotEmpty) await prefs.setString("cid", cid);
      if (userId != null && userId.isNotEmpty) await prefs.setString("uid", userId);
      if (roleId != null && roleId.isNotEmpty) await prefs.setString("role_id", roleId);
      if (name != null && name.isNotEmpty) await prefs.setString(_keyName, name);
      if (email != null && email.isNotEmpty) await prefs.setString(_keyEmail, email);
      if (phone != null && phone.isNotEmpty) await prefs.setString(_keyPhone, phone);
      if (address != null && address.isNotEmpty) await prefs.setString(_keyAddress, address);
      if (city != null && city.isNotEmpty) await prefs.setString(_keyCity, city);
      if (state != null && state.isNotEmpty) await prefs.setString(_keyState, state);
      if (pincode != null && pincode.isNotEmpty) await prefs.setString(_keyPincode, pincode);
      if (country != null && country.isNotEmpty) await prefs.setString(_keyCountry, country);
      
      // Priority for technician ID: cus_id -> engineer_id -> uid
      final techId = cusId ?? userId;
      if (techId != null && techId.isNotEmpty) {
        await prefs.setString("engineer_id", techId);
        await prefs.setString("cus_id", techId);
      }

      await prefs.setBool("logged_in", true);
      debugPrint("StorageService: session saved (uid: $userId, cid: $cid, name: $name)");
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
    return prefs.getString(_keyEngineerId);
  }

  static Future<String?> getCusId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyCusId);
  }

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

  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }

  static Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool("logged_in") ?? false;
  }
}
