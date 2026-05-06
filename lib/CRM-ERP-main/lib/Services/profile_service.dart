import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'preference_service.dart';

class ProfileService {
  static const String _apiUrl = 'https://erpsmart.in/total/api/m_api/';

  static Future<Map<String, dynamic>?> fetchProfileData() async {
    try {
      String deviceId = await PreferenceService.getDeviceId();
      String ln = await PreferenceService.getLn();
      String lt = await PreferenceService.getLt();
      
      String? uid = await PreferenceService.getUid();
      String activeId = uid ?? '';

      if (activeId.isEmpty) {
        debugPrint(
          "ProfileService: activeId is empty, skipping API call.",
        );
        return null;
      }

      String currentCid = await PreferenceService.getCid();
      String? token = await PreferenceService.getToken();

      final Map<String, String> body = {
        'type': '2071',
        'cid': currentCid,
        'uid': activeId,
        'device_id': deviceId,
        'lt': lt,
        'ln': ln,
        'id': activeId,
        if (token != null) 'token': token,
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
      String deviceId = await PreferenceService.getDeviceId();
      String ln = await PreferenceService.getLn();
      String lt = await PreferenceService.getLt();
      
      String? uid = await PreferenceService.getUid();
      String activeId = uid ?? '';

      if (activeId.isEmpty) {
        debugPrint(
          "ProfileService: activeId is empty, skipping update API call.",
        );
        return null;
      }

      String currentCid = await PreferenceService.getCid();
      String? token = await PreferenceService.getToken();

      final Map<String, String> body = {
        'type': '3004',
        'cid': currentCid,
        'uid': activeId,
        'device_id': deviceId,
        'lt': lt,
        'ln': ln,
        'id': activeId,
        'name': name,
        'mobile': mobile,
        'email': email,
        if (token != null) 'token': token,
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
