import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:crm/Services/preference_service.dart';

class EnquiryApi {
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
        'error_msg':
            'Service is currently unavailable. Please try again later.',
      };
    } on FormatException catch (e) {
      debugPrint('JSON decode error: $e\nRaw body: $body');
      return {
        'error': true,
        'error_msg':
            'Service is currently unavailable. Please try again later.',
      };
    }
  }

  static Future<Map<String, dynamic>> addEnquiry(
    Map<String, String> enquiryData,
  ) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      String deviceId = prefs.getString('device_id') ?? '';
      String ln = prefs.getString('ln') ?? '';
      String lt = prefs.getString('lt') ?? '';
      String currentCid = await PreferenceService.getCid();
      String? token = await PreferenceService.getToken();
      String? uid = await PreferenceService.getUid();

      final Map<String, String> body = {
        'type': '2082', // Add Enquiry API Type Updated
        'cid': currentCid,
        'uid': uid ?? '', 
        'assigned_to': uid ?? '',
        'form': 'sm_main_form_20201',
        'lt': lt,
        'ln': ln,
        'device_id': deviceId,
        ...enquiryData,
      };

      debugPrint("------------ ADD ENQUIRY API REQUEST ------------");
      debugPrint("URL: $_apiUrl");
      debugPrint("BODY: $body");

      final response = await http.post(Uri.parse(_apiUrl), body: body);

      debugPrint("------------ ADD ENQUIRY API RESPONSE ------------");
      debugPrint("STATUS: ${response.statusCode}");
      debugPrint("BODY: ${response.body}");

      if (response.statusCode == 200) {
        return _safeDecodeJson(response.body);
      } else {
        return {
          'error': true,
          'error_msg': 'Server error: ${response.statusCode}',
        };
      }
    } catch (e) {
      debugPrint("Error adding enquiry: $e");
      return {'error': true, 'error_msg': 'Connection error: $e'};
    }
  }

  static Future<List<dynamic>> fetchEnquiries() async {
    try {
      String deviceId = await PreferenceService.getDeviceId();
      String ln = await PreferenceService.getLn();
      String lt = await PreferenceService.getLt();
      String currentCid = await PreferenceService.getCid();

      String? uid = await PreferenceService.getUid();
      String activeId = uid ?? '';
      String? token = await PreferenceService.getToken();

      final Map<String, String> body = {
        'type': '2083', // Fetch Enquiry API Type
        'cid': currentCid,
        'uid': activeId,
        'lt': lt,
        'ln': ln,
        'device_id': deviceId,
        'form': 'sm_main_form_20201',
        'select': '*',
        'where': 'enquiry_type=2,assigned_to=$activeId',
        'enquiry_type': '2', // Hardcoded for Enquiry
        'assign_to': activeId,
        'assigned_to': activeId,
        if (token != null) 'token': token,
      };

      debugPrint("------------ FETCH ENQUIRIES API REQUEST ------------");
      debugPrint("URL: $_apiUrl");
      debugPrint("BODY: $body");

      final response = await http.post(Uri.parse(_apiUrl), body: body);

      debugPrint("------------ FETCH ENQUIRIES API RESPONSE ------------");
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
        debugPrint(
          "API Error: ${data['message'] ?? data['error_msg'] ?? 'Unknown error'}",
        );
      }
    } catch (e) {
      debugPrint("Error fetching enquiries: $e");
    }
    return [];
  }
}
