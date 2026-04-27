import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class StorageService {
  static const String _keyCid = 'cid';
  static const String _keyToken = 'token';
  static const String _keyUserId = 'uid';
  static const String _keyRoleId = 'role_id';
  static const String _keyEngineerId = 'engineer_id';
  static const String _keyCusId = 'cus_id';

  static Future<void> saveUser(Map<String, dynamic> data) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // Extract IDs safely from various possible keys
      final userId = (data["user_id"] ?? data["uid"] ?? data["id"] ?? data["data"]?[0]?["id"])?.toString();
      final roleId = (data["role_id"] ?? data["data"]?[0]?["role_id"])?.toString();
      final token = (data["token"] ?? data["data"]?[0]?["token"])?.toString();
      final cid = (data["cid"] ?? data["data"]?[0]?["cid"])?.toString();
      final cusId = (data["cus_id"] ?? data["engineer_id"] ?? data["eg_id"] ?? data["data"]?[0]?["cus_id"])?.toString();

      if (token != null && token.isNotEmpty) await prefs.setString("token", token);
      if (cid != null && cid.isNotEmpty) await prefs.setString("cid", cid);
      if (userId != null && userId.isNotEmpty) await prefs.setString("uid", userId);
      if (roleId != null && roleId.isNotEmpty) await prefs.setString("role_id", roleId);
      
      // Priority for technician ID: cus_id -> engineer_id -> uid
      final techId = cusId ?? userId;
      if (techId != null && techId.isNotEmpty) {
        await prefs.setString("engineer_id", techId);
        await prefs.setString("cus_id", techId);
      }

      await prefs.setBool("logged_in", true);
      debugPrint("StorageService: session saved (uid: $userId, cid: $cid)");
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

  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }

  static Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool("logged_in") ?? false;
  }
}
