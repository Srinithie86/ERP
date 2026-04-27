import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:crm/Services/preference_service.dart';

class LeadApi {
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

  static Future<Map<String, dynamic>> addLead(Map<String, String> leadData) async {
    try {
      String deviceId = await PreferenceService.getDeviceId();
      String ln = await PreferenceService.getLn();
      String lt = await PreferenceService.getLt();
      String currentCid = await PreferenceService.getCid();
      String? token = await PreferenceService.getToken();

      String? uid = await PreferenceService.getUid();
      String activeId = uid ?? '';

      final Map<String, String> body = {
        'type': '2082', // Add Lead API Type Updated
        'cid': currentCid,
        'uid': activeId,
        'assigned_to': activeId,
        'form': 'sm_main_form_20201',
        'lt': lt,
        'ln': ln,
        'device_id': deviceId,
        ...leadData,
      };

      debugPrint("------------ ADD LEAD API REQUEST ------------");
      debugPrint("URL: $_apiUrl");
      debugPrint("BODY: $body");

      final response = await http.post(Uri.parse(_apiUrl), body: body);

      debugPrint("------------ ADD LEAD API RESPONSE ------------");
      debugPrint("STATUS: ${response.statusCode}");
      debugPrint("BODY: ${response.body}");

      if (response.statusCode == 200) {
        return _safeDecodeJson(response.body);
      } else {
        return {'error': true, 'error_msg': 'Server error: ${response.statusCode}'};
      }
    } catch (e) {
      debugPrint("Error adding lead: $e");
      return {'error': true, 'error_msg': 'Connection error: $e'};
    }
  }

  static Future<List<dynamic>> fetchLeads() async {
    try {
      String deviceId = await PreferenceService.getDeviceId();
      String ln = await PreferenceService.getLn();
      String lt = await PreferenceService.getLt();

      String currentCid = await PreferenceService.getCid();

      String? uid = await PreferenceService.getUid();
      String activeId = uid ?? '';
      String? token = await PreferenceService.getToken();

      final Map<String, String> body = {
        'type': '2083', // Fetch Lead API Type
        'cid': currentCid,
        'uid': activeId,
        'lt': lt,
        'ln': ln,
        'device_id': deviceId,
        'form': 'sm_main_form_20201',
        'select': '*',
        'where': 'enquiry_type=1,assigned_to=$activeId',
        'enquiry_type': '1', // Hardcoded for Lead
        'assign_to': activeId,
        'assigned_to': activeId,
        if (token != null) 'token': token,
      };

      debugPrint("------------ FETCH LEADS API REQUEST ------------");
      debugPrint("URL: $_apiUrl");
      debugPrint("BODY: $body");

      final response = await http.post(Uri.parse(_apiUrl), body: body);

      debugPrint("------------ FETCH LEADS API RESPONSE ------------");
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
      debugPrint("Error fetching leads: $e");
    }
    return [];
  }
}
