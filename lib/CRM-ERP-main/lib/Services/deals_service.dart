import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'preference_service.dart';

class DealsService {
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

  /// Fetches deals data (Active, Won, Lost).
  static Future<Map<String, dynamic>> fetchDeals({String? date}) async {
    try {
      String? uid = await PreferenceService.getUid();
      String cid = await PreferenceService.getCid();
      String lt = await PreferenceService.getLt();
      String ln = await PreferenceService.getLn();
      String deviceId = await PreferenceService.getDeviceId();
      String? token = await PreferenceService.getToken();

      final Map<String, String> body = {
        'type': '3042',
        'cid': cid,
        'lt': lt,
        'ln': ln,
        'device_id': deviceId,
        'uid': uid ?? '',
      };

      if (date != null && date.isNotEmpty) {
        body['date'] = date;
      }

      if (token != null) body['token'] = token;

      debugPrint('>>> Deals API Request: $body');
      final response = await http.post(Uri.parse(_apiUrl), body: body);

      if (response.statusCode == 200) {
        debugPrint('>>> Deals API Response: ${response.body}');
        return _safeDecodeJson(response.body);
      } else {
        debugPrint('Deals API HTTP Error: ${response.statusCode}');
        return {
          'error': true,
          'message': 'Server error: ${response.statusCode}'
        };
      }
    } catch (e) {
      debugPrint('Error in fetchDeals: $e');
      return {'error': true, 'message': e.toString()};
    }
  }
}
