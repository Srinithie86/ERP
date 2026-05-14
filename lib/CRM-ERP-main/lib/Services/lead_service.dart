import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'preference_service.dart';

class LeadService {
  static const String _apiUrl = 'https://erpsmart.in/total/api/m_api/';

  /// Safely attempts to decode a JSON response.
  static Map<String, dynamic> _safeDecodeJson(String body) {
    try {
      int startIndex = body.indexOf('{');
      int endIndex = body.lastIndexOf('}');
      if (startIndex != -1 && endIndex != -1 && endIndex >= startIndex) {
        return json.decode(body.substring(startIndex, endIndex + 1));
      }
      return {'error': true, 'error_msg': 'Invalid JSON'};
    } catch (e) {
      return {'error': true, 'error_msg': 'Decode error'};
    }
  }

  // --- REMOVED LIST FETCHING AND SUBMISSION FOR REBINDING ---

  static Future<List<dynamic>> fetchLeads({required String enquiryType}) async {
    try {
      String deviceId = await PreferenceService.getDeviceId();
      String ln = await PreferenceService.getLn();
      String lt = await PreferenceService.getLt();
      String currentCid = await PreferenceService.getCid();
      String? token = await PreferenceService.getToken();
      String? uid = await PreferenceService.getUid();

      final Map<String, String> body = {
        'type': '2083',
        'cid': currentCid,
        'lt': lt,
        'ln': ln,
        'device_id': deviceId,
        'form': 'sm_main_form_20201',
        'select': '*',
        'where': 'enquiry_type=$enquiryType,assigned_to=${uid ?? ""},cus_status=new',
      };
      if (token != null) body['token'] = token;

      debugPrint('>>> Fetch Leads API REQUEST : $body');
      final response = await http.post(Uri.parse(_apiUrl), body: body);

      if (response.statusCode == 200) {
        debugPrint('>>> Fetch Leads API RESPONSE: ${response.body}');
        final data = _safeDecodeJson(response.body);
        if (data['error'] == false && data['data'] != null) {
          return List<dynamic>.from(data['data']);
        }
      }
    } catch (e) {
      debugPrint('Error in fetchLeads: $e');
    }
    return [];
  }

  static Future<Map<String, dynamic>> addLead(
    Map<String, String> leadData, {
    String apiType = '2083',
  }) async {
    // Placeholder for new binding
    return {'error': false, 'message': 'API Binding required'};
  }

  // --- DROPDOWN API PRESERVED ---

  static Future<List<dynamic>> fetchDropdownData({
    required String type,
    String? form,
    String? select,
    String? listId,
  }) async {
    try {
      String deviceId = await PreferenceService.getDeviceId();
      String ln = await PreferenceService.getLn();
      String lt = await PreferenceService.getLt();
      String currentCid = await PreferenceService.getCid();
      String? token = await PreferenceService.getToken();
      String? uid = await PreferenceService.getUid();

      final Map<String, String> body = {
        'type': type,
        'cid': currentCid,
        'lt': lt,
        'ln': ln,
        'device_id': deviceId,
        'uid': uid ?? '',
        'role_id': await PreferenceService.getRoleId(),
        if (form != null) 'form': form,
        if (select != null) 'select': select,
        if (listId != null) 'list_id': listId,
        if (token != null) 'token': token,
      };

      final response = await http.post(Uri.parse(_apiUrl), body: body);

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = _safeDecodeJson(response.body);
        if (data['error'] == false) {
          var listData = data['data'] ?? data['dropdown'] ?? data['details'];
          
          if (listData is Map) {
            // If it's a map, try to find the first list inside it (e.g. transport_types)
            listData = listData.values.firstWhere((v) => v is List, orElse: () => []);
          }
          
          if (listData is List) {
            return List<dynamic>.from(listData);
          }
        }
      }
    } catch (e) {
      debugPrint("Error fetching dropdown data: $e");
    }
    return [];
  }
}
