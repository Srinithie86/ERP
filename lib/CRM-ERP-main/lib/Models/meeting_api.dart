import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../Services/preference_service.dart';

class MeetingApi {
  static const String _apiUrl = 'https://erpsmart.in/total/api/m_api/';

  // --- DROPDOWN API PRESERVED ---

  static Future<List<dynamic>> fetchVirtualMeetingModes() async {
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
        'list_id': '1503',
        'role_id': await PreferenceService.getRoleId(),
        if (token != null) 'token': token,
      };

      final response = await http.post(Uri.parse(_apiUrl), body: body);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['error'] == false && data['dropdown'] is List) {
          return List<dynamic>.from(data['dropdown']);
        }
      }
    } catch (e) {
      debugPrint("Dropdown error: $e");
    }
    return [];
  }

  static Future<List<dynamic>> fetchMeetings({required String enquiryType}) async {
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
        'uid': uid ?? '',
        'lt': lt,
        'ln': ln,
        'device_id': deviceId,
        'form': 'sm_main_form_21005',
        'select': '*',
        'where': 'Uid=${uid ?? ''},cus_status=Meeting,enquiry_type=$enquiryType',
      };
      if (token != null) body['token'] = token;

      debugPrint('>>> Meeting Fetch REQUEST : $body');
      final response = await http.post(Uri.parse(_apiUrl), body: body);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['error'] == false && data['data'] is List) {
          return data['data'];
        }
      }
    } catch (e) {
      debugPrint("Meeting Fetch error: $e");
    }
    return [];
  }

  static Future<Map<String, dynamic>> submitMeetingDetails(
      Map<String, String> data, {String form = 'sm_main_form_20209'}) async {
    try {
      String deviceId = await PreferenceService.getDeviceId();
      String ln = await PreferenceService.getLn();
      String lt = await PreferenceService.getLt();
      String currentCid = await PreferenceService.getCid();
      String? token = await PreferenceService.getToken();

      final Map<String, String> body = {
        'type': '2082',
        'cid': currentCid,
        'lt': lt,
        'ln': ln,
        'device_id': deviceId,
        'form': form,
        'cus_status':'Schedule',
        ...data,
      };
      if (token != null) body['token'] = token;

      debugPrint('>>> Meeting API REQUEST : $body');
      final response = await http.post(Uri.parse(_apiUrl), body: body);

      if (response.statusCode == 200) {
        debugPrint('>>> Meeting API RESPONSE: ${response.body}');
        return json.decode(response.body);
      }
    } catch (e) {
      debugPrint("Meeting Submission error: $e");
    }
    return {'error': 'true', 'message': 'Network error'};
  }
}
