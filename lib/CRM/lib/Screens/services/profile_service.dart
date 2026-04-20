import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:crm/Services/preference_service.dart';

class ProfileService {
  static const String _apiUrl = 'https://erpsmart.in/total/api/m_api/';

  static Future<Map<String, dynamic>?> fetchProfileData() async {
    try {
      final String? ledId = await PreferenceService.getLedId();
      final prefs = await SharedPreferences.getInstance();
      final String deviceId = prefs.getString('device_id') ?? '3423';
      final String lt = prefs.getString('lt') ?? '3232';
      final String ln = prefs.getString('ln') ?? '332';

      if (ledId == null || ledId.isEmpty) {
        debugPrint(
          "ProfileService: led_id (from led_id/cus_id) is empty, skipping API call.",
        );
        return null;
      }

      String currentCid = await PreferenceService.getCid();
      String? token = await PreferenceService.getToken();

      final Map<String, String> body = {
        'type': '2071',
        'cid': currentCid,
        'device_id': deviceId,
        'lt': lt,
        'ln': ln,
        'id': ledId,
        'token': ?token,
      };

      debugPrint("------------ GET PROFILE API REQUEST ------------");
      debugPrint("URL: $_apiUrl");
      debugPrint("BODY: $body");

      final response = await http.post(Uri.parse(_apiUrl), body: body);

      debugPrint("ProfileService: Response Body: ${response.body}");

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        if (responseData['status'] == 'success') {
          final data = responseData['data'];
          if (data != null) {
            await PreferenceService.setName(data['name']?.toString() ?? '');
            await PreferenceService.setEmail(data['email']?.toString() ?? '');
            await PreferenceService.setMobile(data['mobile']?.toString() ?? '');
            if (data['token'] != null) {
              await PreferenceService.setToken(data['token'].toString());
            }
          }
          return data;
        }
      }
      return null;
    } catch (e) {
      debugPrint("ProfileService Error: $e");
      return null;
    }
  }

  static Future<Map<String, dynamic>?> updateProfileData({
    required String name,
    required String mobile,
    required String email,
  }) async {
    try {
      final String? ledId = await PreferenceService.getLedId();
      final prefs = await SharedPreferences.getInstance();
      final String deviceId = prefs.getString('device_id') ?? '3423';
      final String lt = prefs.getString('lt') ?? '3232';
      final String ln = prefs.getString('ln') ?? '332';

      if (ledId == null || ledId.isEmpty) {
        debugPrint(
          "ProfileService: led_id (from led_id/cus_id) is empty, skipping update API call.",
        );
        return null;
      }

      String currentCid = await PreferenceService.getCid();
      String? token = await PreferenceService.getToken();

      final Map<String, String> body = {
        'type': '3004',
        'cid': currentCid,
        'device_id': deviceId,
        'lt': lt,
        'ln': ln,
        'id': ledId,
        'name': name,
        'mobile': mobile,
        'email': email,
        'token': ?token,
      };

      debugPrint("------------ UPDATE PROFILE API REQUEST ------------");
      debugPrint("URL: $_apiUrl");
      debugPrint("BODY: $body");

      final response = await http.post(Uri.parse(_apiUrl), body: body);

      debugPrint("------------ UPDATE PROFILE API RESPONSE ------------");
      debugPrint("STATUS: ${response.statusCode}");
      debugPrint("BODY: ${response.body}");

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        if (responseData['status'] == 'success') {
          await PreferenceService.setName(name);
          await PreferenceService.setEmail(email);
          await PreferenceService.setMobile(mobile);
        }
        return responseData;
      }
      return null;
    } catch (e) {
      debugPrint("ProfileService Update Error: $e");
      return null;
    }
  }
}
