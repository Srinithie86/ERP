import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../Services/preference_service.dart';

class ScheduleApi {
  static const String _apiUrl = 'https://erpsmart.in/total/api/m_api/';

  /// Fetches schedule data for a specific enquiry type (Lead, Enquiry, Referral).
  static Future<List<dynamic>> fetchSchedules({required String enquiryType}) async {
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
        'form': 'sm_main_form_20209',
        'select': '*',
        'where': 'Uid=${uid ?? ""},cus_status=Schedule,enquiry_type=$enquiryType',
      };
      
      if (token != null) body['token'] = token;

      debugPrint('>>> Fetch Schedule API REQUEST ($enquiryType): $body');
      final response = await http.post(Uri.parse(_apiUrl), body: body);

      if (response.statusCode == 200) {
        debugPrint('>>> Fetch Schedule API RESPONSE ($enquiryType): ${response.body}');
        final data = _decodeJson(response.body);
        if (data['error'] == false && data['data'] != null) {
          return List<dynamic>.from(data['data']);
        }
      }
    } catch (e) {
      debugPrint('Error in fetchSchedules ($enquiryType): $e');
    }
    return [];
  }

  static Map<String, dynamic> _decodeJson(String body) {
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
}
