import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:erp_smart/CRM-ERP-main/lib/Services/preference_service.dart';

class FollowUpApi {
  static const String _apiUrl = 'https://erpsmart.in/total/api/m_api/';

  static Map<String, dynamic> _safeDecode(String body) {
    try {
      int start = body.indexOf('{');
      int end = body.lastIndexOf('}');
      if (start != -1 && end != -1) {
        return json.decode(body.substring(start, end + 1));
      }
    } catch (e) {}
    return {'error': true};
  }

  // --- DROPDOWN APIS PRESERVED ---

  static Future<List<dynamic>> fetchFollowUpModes() async {
    return _fetchDropdown('1509');
  }

  static Future<List<dynamic>> fetchCallOutcomes() async {
    return _fetchDropdown('1500');
  }

  static Future<List<dynamic>> fetchLeadStatuses() async {
    return _fetchDropdown('1502');
  }

  /// Submits the call outcome and follow-up data (API Type 3032).
  static Future<Map<String, dynamic>> followupInsert(
      Map<String, String> data) async {
    try {
      String deviceId = await PreferenceService.getDeviceId();
      String ln = await PreferenceService.getLn();
      String lt = await PreferenceService.getLt();
      String cid = await PreferenceService.getCid();
      String? token = await PreferenceService.getToken();

      final Map<String, String> body = {
        'type': '3032',
        'cid': cid,
        'lt': lt,
        'ln': ln,
        'device_id': deviceId,
        ...data,
      };
      if (token != null) body['token'] = token;

      debugPrint('>>> followupInsert API REQUEST : $body');
      final response = await http.post(Uri.parse(_apiUrl), body: body);

      if (response.statusCode == 200) {
        debugPrint('>>> followupInsert API RESPONSE: ${response.body}');
        return _safeDecode(response.body);
      }
    } catch (e) {
      debugPrint('Error in followupInsert: $e');
    }
    return {'error': true, 'message': 'Network Error'};
  }

  static Future<List<dynamic>> _fetchDropdown(String listId) async {
    try {
      String deviceId = await PreferenceService.getDeviceId();
      String ln = await PreferenceService.getLn();
      String lt = await PreferenceService.getLt();
      String currentCid = await PreferenceService.getCid();
      String? token = await PreferenceService.getToken();
      String? uid = await PreferenceService.getUid();

      final Map<String, String> body = {
        'type': '2084',
        'cid': currentCid,
        'uid': uid ?? '',
        'lt': lt,
        'ln': ln,
        'device_id': deviceId,
        'list_id': listId,
        'role_id': await PreferenceService.getRoleId(),
        if (token != null) 'token': token,
      };

      final response = await http.post(Uri.parse(_apiUrl), body: body);
      if (response.statusCode == 200) {
        final data = _safeDecode(response.body);
        if (data['error'] == false && data['dropdown'] is List) {
          return List<dynamic>.from(data['dropdown']);
        }
      }
    } catch (e) {
      debugPrint("Dropdown error: $e");
    }
    return [];
  }
}
