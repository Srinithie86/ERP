import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:crm/services/preference_service.dart';

class ReferralApi {
  static const String _apiUrl = 'https://erpsmart.in/total/api/m_api/';

  static Map<String, dynamic> _safeDecodeJson(String body) {
    try {
      int startIndex = body.indexOf('{');
      int endIndex = body.lastIndexOf('}');
      if (startIndex != -1 && endIndex != -1 && endIndex >= startIndex) {
        return json.decode(body.substring(startIndex, endIndex + 1));
      }
      debugPrint('Non-JSON response received: $body');
      return {
        'error': true,
        'error_msg': 'Service is currently unavailable. Please try again later.',
      };
    } on FormatException catch (e) {
      debugPrint('JSON decode error: $e\nRaw body: $body');
      return {
        'error': true,
        'error_msg': 'Service is currently unavailable. Please try again later.',
      };
    }
  }

  static Future<Map<String, dynamic>> addReferral(Map<String, String> referralData) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      String deviceId = prefs.getString('device_id') ?? '';
      String ln = prefs.getString('ln') ?? '';
      String lt = prefs.getString('lt') ?? '';
      String? custId = prefs.getString('login_cus_id') ?? prefs.getString('uid');

      String currentCid = await PreferenceService.getCid();
      String? token = await PreferenceService.getToken();
      String? ledId = await PreferenceService.getLedId();

      final Map<String, String> body = {
        'type': '2083', // Add Referral API Type
        'cid': currentCid.isEmpty ? '21472147' : currentCid,
        'uid': ledId ?? '',
        'assign_to': custId ?? ledId ?? '',
        'assignTo': custId ?? ledId ?? '',
        'lt': lt,
        'ln': ln,
        'device_id': deviceId,
        'token': ?token,
        ...referralData,
        'enquiry_type': '3', // Hardcoded for Referral
      };

      debugPrint("------------ ADD REFERRAL API REQUEST ------------");
      debugPrint("URL: $_apiUrl");
      debugPrint("BODY: $body");

      final response = await http.post(Uri.parse(_apiUrl), body: body);

      debugPrint("------------ ADD REFERRAL API RESPONSE ------------");
      debugPrint("STATUS: ${response.statusCode}");
      debugPrint("BODY: ${response.body}");

      if (response.statusCode == 200) {
        return _safeDecodeJson(response.body);
      } else {
        return {'error': true, 'error_msg': 'Server error: ${response.statusCode}'};
      }
    } catch (e) {
      debugPrint("Error adding referral: $e");
      return {'error': true, 'error_msg': 'Connection error: $e'};
    }
  }

  static Future<List<dynamic>> fetchReferrals() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      String deviceId = prefs.getString('device_id') ?? '';
      String ln = prefs.getString('ln') ?? '';
      String lt = prefs.getString('lt') ?? '';
      String? custId = prefs.getString('login_cus_id') ?? prefs.getString('uid');

      String currentCid = await PreferenceService.getCid();
      if (currentCid.isEmpty) currentCid = '21472147';

      String? token = await PreferenceService.getToken();
      String? ledId = await PreferenceService.getLedId();

      final Map<String, String> body = {
        'type': '2083', // Fetch API Type
        'cid': currentCid,
        'lt': lt,
        'ln': ln,
        'device_id': deviceId,
        'form': 'sm_main_form_20201',
        'select': '*',
        'where': 'enquiry_type=3,assigned_to=${custId ?? ledId ?? ""}',
        'enquiry_type': '3', // Hardcoded for Referral
        'assign_to': custId ?? ledId ?? '',
        'assignTo': custId ?? ledId ?? '',
        'token': ?token,
      };

      debugPrint("------------ FETCH REFERRALS API REQUEST ------------");
      debugPrint("URL: $_apiUrl");
      debugPrint("BODY: $body");

      final response = await http.post(Uri.parse(_apiUrl), body: body);

      debugPrint("------------ FETCH REFERRALS API RESPONSE ------------");
      debugPrint("STATUS: ${response.statusCode}");
      debugPrint("BODY: ${response.body}");

      if (response.statusCode == 200) {
        String bodyText = response.body;

        int startIndex = bodyText.indexOf('{');
        int endIndex = bodyText.lastIndexOf('}');
        if (startIndex != -1 && endIndex != -1) {
          bodyText = bodyText.substring(startIndex, endIndex + 1);
        }

        final Map<String, dynamic> data = json.decode(bodyText);

        if (data['error'] == false) {
          var listData = data['data'] ?? data['details'];
          if (listData is List) {
            return List<dynamic>.from(listData);
          }
        }
        debugPrint("API Error: ${data['message'] ?? data['error_msg'] ?? 'Unknown error'}");
      }
    } catch (e) {
      debugPrint("Error fetching referrals: $e");
    }
    return [];
  }
}
