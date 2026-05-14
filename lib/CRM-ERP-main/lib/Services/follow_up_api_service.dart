import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'preference_service.dart';

class FollowUpApiService {
  static const String _apiUrl = 'https://erpsmart.in/total/api/m_api/';

  /// Safely attempts to decode a JSON response.
  static Map<String, dynamic> _safeDecodeJson(String body) {
    try {
      int startIndex = body.indexOf('{');
      int endIndex = body.lastIndexOf('}');
      if (startIndex != -1 && endIndex != -1 && endIndex >= startIndex) {
        return json.decode(body.substring(startIndex, endIndex + 1));
      }
      return {'error': true, 'message': 'Invalid JSON format'};
    } catch (e) {
      return {'error': true, 'message': 'JSON Decode Error'};
    }
  }

  /// Fetches follow-ups for the current user.
  static Future<List<dynamic>> fetchFollowUps() async {
    try {
      String? uid = await PreferenceService.getUid();
      String cid = await PreferenceService.getCid();
      String lt = await PreferenceService.getLt();
      String ln = await PreferenceService.getLn();
      String deviceId = await PreferenceService.getDeviceId();
      String? token = await PreferenceService.getToken();

      final Map<String, String> body = {
        'type': '2083',
        'cid': cid,
        'lt': lt,
        'ln': ln,
        'device_id': deviceId,
        'form': 'sm_main_form_21004',
        'select': '*',
        'where': 'call_by=${uid ?? ""},cus_status=follow_up',
      };
      if (token != null) body['token'] = token;

      debugPrint('>>> FollowUp API Request: $body');
      final response = await http.post(Uri.parse(_apiUrl), body: body);

      if (response.statusCode == 200) {
        debugPrint('>>> FollowUp API Response: ${response.body}');
        final decoded = _safeDecodeJson(response.body);
        if (decoded['error'] == false && decoded['data'] != null) {
          return decoded['data'] as List<dynamic>;
        }
        return [];
      } else {
        debugPrint('FollowUp API HTTP Error: ${response.statusCode}');
        return [];
      }
    } catch (e) {
      debugPrint('Error in fetchFollowUps: $e');
      return [];
    }
  }
}
