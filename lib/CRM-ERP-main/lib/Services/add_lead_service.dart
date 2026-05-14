import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'preference_service.dart';

class AddLeadService {
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

  /// Adds a new Lead, Enquiry, or Referral.
  static Future<Map<String, dynamic>> submitLead(
      Map<String, String> leadData) async {
    try {
      String deviceId = await PreferenceService.getDeviceId();
      String ln = await PreferenceService.getLn();
      String lt = await PreferenceService.getLt();
      String currentCid = await PreferenceService.getCid();
      String? token = await PreferenceService.getToken();
      String? uid = await PreferenceService.getUid();

      final now = DateTime.now();
      final formattedDate =
          "${now.day.toString().padLeft(2, '0')}-${now.month.toString().padLeft(2, '0')}-${now.year}";

      final Map<String, String> body = {
        'type': '2082',
        'cid': currentCid,
        'lt': lt,
        'ln': ln,
        'device_id': deviceId,
        'form': 'sm_main_form_20201',
        'uid': uid ?? '',
        //'role_id': await PreferenceService.getRoleId(),
        'enquiry_date': formattedDate,
        'attended_by': uid ?? '',
        'assigned_to': uid ?? '',
        ...leadData,
      };
      if (token != null) body['token'] = token;

      debugPrint('>>> add lead API REQUEST : $body');
      final response = await http.post(Uri.parse(_apiUrl), body: body);

      if (response.statusCode == 200) {
        debugPrint('>>> add lead API RESPONSE: ${response.body}');
        final data = _safeDecodeJson(response.body);
        return data;
      } else {
        return {
          'error': true,
          'message': 'Server error: ${response.statusCode}'
        };
      }
    } catch (e) {
      debugPrint('Error in submitLead: $e');
      return {'error': true, 'message': e.toString()};
    }
  }
}
