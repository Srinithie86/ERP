import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'preference_service.dart';

class LeadService {
  static const String _apiUrl = 'https://erpsmart.in/total/api/m_api/';

  /// Safely attempts to decode a JSON response.
  /// Returns an error map if the body is not valid JSON.
  static Map<String, dynamic> _safeDecodeJson(String body) {
    try {
      // Extract JSON substring if there's extra content before/after
      int startIndex = body.indexOf('{');
      int endIndex = body.lastIndexOf('}');
      if (startIndex != -1 && endIndex != -1 && endIndex >= startIndex) {
        return json.decode(body.substring(startIndex, endIndex + 1));
      }
      // No JSON structure found — body is a plain text error
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

  static Future<List<dynamic>> fetchFollowUpHistory({
    required String leadNo,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      String deviceId = prefs.getString('device_id') ?? '';
      String ln = prefs.getString('ln') ?? '';
      String lt = prefs.getString('lt') ?? '';

      String currentCid = await PreferenceService.getCid();
      String? token = await PreferenceService.getToken();
      String? uid = await PreferenceService.getUid();

      final Map<String, String> body = {
        'type': '2083',
        'cid': currentCid,
        'lt': lt,
        'ln': ln,
        'device_id': deviceId,
        'uid': uid ?? '',
        'no': leadNo,
        if (token != null) 'token': token,
      };

      debugPrint("------------ FETCH FOLLOW-UP HISTORY REQUEST ------------");
      debugPrint("URL: $_apiUrl");
      debugPrint("BODY: $body");

      final response = await http.post(Uri.parse(_apiUrl), body: body);

      debugPrint("------------ FETCH FOLLOW-UP HISTORY RESPONSE ------------");
      debugPrint("STATUS: ${response.statusCode}");
      debugPrint("BODY: ${response.body}");

      if (response.statusCode == 200) {
        String bodyText = response.body;

        // Robust sanitization
        int startIndex = bodyText.indexOf('{');
        int endIndex = bodyText.lastIndexOf('}');

        if (startIndex != -1 && endIndex != -1) {
          bodyText = bodyText.substring(startIndex, endIndex + 1);
        }

        final Map<String, dynamic> data = json.decode(bodyText);

        if (data['error'] == false && data['details'] != null) {
          return List<dynamic>.from(data['details']);
        } else {
          debugPrint("API Error: ${data['error_msg'] ?? 'Unknown error'}");
        }
      }
    } catch (e) {
      debugPrint("Error fetching follow-up history: $e");
    }
    return [];
  }

  static Future<Map<String, dynamic>> addLead(
    Map<String, String> leadData, {
    String apiType = '2083',
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      String deviceId = prefs.getString('device_id') ?? '';
      String ln = prefs.getString('ln') ?? '';
      String lt = prefs.getString('lt') ?? '';
      String? uid = await PreferenceService.getUid();
      String currentCid = await PreferenceService.getCid();
      String? token = await PreferenceService.getToken();

      final Map<String, String> body = {
        'type': apiType,
        'cid': currentCid,
        'uid': uid ?? '',
        'assign_to': uid ?? '',
        'assignTo': uid ?? '',
        'lt': lt,
        'ln': ln,
        'device_id': deviceId,
        if (token != null) 'token': token,
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
        return {
          'error': true,
          'error_msg': 'Server error: ${response.statusCode}',
        };
      }
    } catch (e) {
      debugPrint("Error adding lead: $e");
      return {'error': true, 'error_msg': 'Connection error: $e'};
    }
  }

  static Future<List<dynamic>> fetchLeads({required String enquiryType}) async {
    try {
      String deviceId = await PreferenceService.getDeviceId();
      String ln = await PreferenceService.getLn();
      String lt = await PreferenceService.getLt();
      String? uid = await PreferenceService.getUid();
      String activeId = uid ?? '';

      String currentCid = await PreferenceService.getCid();

      String? token = await PreferenceService.getToken();

      // Mapping enquiryType to integer ID for the 'where' clause
      // Lead: 1, Enquiry: 2, Referral: 3
      String enquiryTypeId = '1';
      if (enquiryType.toLowerCase() == 'enquiry') {
        enquiryTypeId = '2';
      } else if (enquiryType.toLowerCase() == 'referral') {
        enquiryTypeId = '3';
      }

      final Map<String, String> body = {
        'type': '2083',
        'cid': currentCid,
        'uid': activeId,
        'lt': lt,
        'ln': ln,
        'device_id': deviceId,
        'form': 'sm_main_form_20201',
        'select': '*',
        'where': 'enquiry_type=$enquiryTypeId,assigned_to=$activeId',
        'enquiry_type': enquiryTypeId,
        'assign_to': activeId,
        'assigned_to': activeId,
        if (token != null) 'token': token,
      };

      debugPrint(
        "------------ FETCH LEADS API REQUEST (2083 - $enquiryType) ------------",
      );
      debugPrint("URL: $_apiUrl");
      debugPrint("BODY: $body");

      final response = await http.post(Uri.parse(_apiUrl), body: body);

      debugPrint("------------ FETCH LEADS API RESPONSE (2083) ------------");
      debugPrint("STATUS: ${response.statusCode}");
      debugPrint("BODY: ${response.body}");

      if (response.statusCode == 200) {
        String bodyText = response.body;

        // Robust sanitization
        int startIndex = bodyText.indexOf('{');
        int endIndex = bodyText.lastIndexOf('}');
        if (startIndex != -1 && endIndex != -1) {
          bodyText = bodyText.substring(startIndex, endIndex + 1);
        }

        final Map<String, dynamic> data = json.decode(bodyText);

        // Check for 'data' key as provided in the sample response, fallback to 'details'
        if (data['error'] == false) {
          var listData = data['data'] ?? data['details'];
          if (listData is List) {
            return List<dynamic>.from(listData);
          }
        }
        debugPrint("API Error: ${data['message'] ?? data['error_msg'] ?? 'Unknown error'}");
      }
    } catch (e) {
      debugPrint("Error fetching leads via 2083: $e");
    }
    return [];
  }

  static Future<List<dynamic>> fetchFollowUpHistoryAll() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      String deviceId = prefs.getString('device_id') ?? '';
      String ln = prefs.getString('ln') ?? '';
      String lt = prefs.getString('lt') ?? '';

      String currentCid = await PreferenceService.getCid();
      String? token = await PreferenceService.getToken();
      String? uid = await PreferenceService.getUid();

      final Map<String, String> body = {
        'type': '3016',
        'cid': currentCid,
        'led_id': uid ?? '',
        'uid': uid ?? '',
        'lt': lt,
        'ln': ln,
        'device_id': deviceId,
        if (token != null) 'token': token,
      };

      debugPrint(
        "------------ FETCH FOLLOW-UP HISTORY ALL REQUEST ------------",
      );
      debugPrint("URL: $_apiUrl");
      debugPrint("BODY: $body");

      final response = await http.post(Uri.parse(_apiUrl), body: body);

      debugPrint(
        "------------ FETCH FOLLOW-UP HISTORY ALL RESPONSE ------------",
      );
      debugPrint("STATUS: ${response.statusCode}");
      debugPrint("BODY: ${response.body}");

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = _safeDecodeJson(response.body);

        if (data['error'] == false && data['details'] != null) {
          return List<dynamic>.from(data['details']);
        } else {
          debugPrint("API Error: ${data['error_msg'] ?? 'Unknown error'}");
        }
      }
    } catch (e) {
      debugPrint("Error fetching follow-up history (3016): $e");
    }
    return [];
  }

  static Future<List<dynamic>> fetchCallSummary(String leadUid) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      String deviceId = prefs.getString('device_id') ?? '';
      String ln = prefs.getString('ln') ?? '';
      String lt = prefs.getString('lt') ?? '';
      String? token = await PreferenceService.getToken();
      String cid = await PreferenceService.getCid();
      String? uid = await PreferenceService.getUid();

      final Map<String, String> body = {
        'type': '2083',
        'cid': cid,
        'uid': uid ?? '', 
        'lt': lt,
        'ln': ln,
        'device_id': deviceId,
        'form': 'sm_main_form_80013',
        'select': '*',
        'where': 'uid=$leadUid',
        if (token != null) 'token': token,
      };

      debugPrint("------------ FETCH CALL SUMMARY REQUEST (2083) ------------");
      debugPrint("URL: $_apiUrl");
      debugPrint("BODY: $body");

      final response = await http.post(Uri.parse(_apiUrl), body: body);

      debugPrint(
        "------------ FETCH CALL SUMMARY RESPONSE (2083) ------------",
      );
      debugPrint("STATUS: ${response.statusCode}");
      debugPrint("BODY: ${response.body}");

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = _safeDecodeJson(response.body);

        if (data['error'] == false) {
          var listData = data['data'];
          if (listData is List) {
            return List<dynamic>.from(listData);
          }
        }
      }
    } catch (e) {
      debugPrint("Error fetching call summary (2083): $e");
    }
    return [];
  }

  static Future<Map<String, dynamic>> addFollowUp(
    Map<String, dynamic> followUpData,
  ) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      String deviceId = prefs.getString('device_id') ?? '';
      String ln = prefs.getString('ln') ?? '';
      String lt = prefs.getString('lt') ?? '';

      String currentCid = await PreferenceService.getCid();
      String? token = await PreferenceService.getToken();
      String? uid = await PreferenceService.getUid();

      // For 3008 (Add):
      // led_id = current user's id (performing the action)
      // no = lead id (the target lead)
      String? leadIdFromData = followUpData['led_id']?.toString();

      final Map<String, String> body = {
        'type': '3008',
        'cid': currentCid,
        'led_id': (uid ?? '').toString(),
        if (leadIdFromData != null && leadIdFromData != 'null')
          'no': leadIdFromData,
        'lt': lt,
        'ln': ln,
        'device_id': deviceId,
        if (token != null) 'token': token,
        ...followUpData.map((key, value) {
          if (key == 'led_id') return MapEntry('none', ''); // skip
          String val = value.toString();
          return MapEntry(key, val == 'null' ? '' : val);
        }),
      };

      debugPrint("------------ ADD FOLLOW-UP API REQUEST ------------");
      debugPrint("URL: $_apiUrl");
      debugPrint("BODY: $body");

      final response = await http.post(Uri.parse(_apiUrl), body: body);

      debugPrint("------------ ADD FOLLOW-UP API RESPONSE ------------");
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
      debugPrint("Error adding follow-up: $e");
      return {'error': true, 'error_msg': 'Connection error: $e'};
    }
  }

  static Future<Map<String, dynamic>> updateFollowUp(
    Map<String, dynamic> followUpData,
  ) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      String deviceId = prefs.getString('device_id') ?? '';
      String ln = prefs.getString('ln') ?? '';
      String lt = prefs.getString('lt') ?? '';

      String currentCid = await PreferenceService.getCid();
      String? token = await PreferenceService.getToken();
      String? uid = await PreferenceService.getUid();

      // For updates (3017):
      // id = followup record id (must come from followUpData)
      // led_id = current user's id (performing the action)
      String? recordId = followUpData['id']?.toString();

      final Map<String, String> body = {
        'type': '3017',
        'cid': currentCid,
        'led_id': (uid ?? '').toString(),
        'id': (recordId ?? '').toString(),
        'lt': lt,
        'ln': ln,
        'device_id': deviceId,
        if (token != null) 'token': token,
        ...followUpData.map((key, value) {
          if (key == 'led_id' || key == 'id') {
            return MapEntry('none', ''); // skip
          }
          String val = value.toString();
          return MapEntry(key, val == 'null' ? '' : val);
        }),
      };

      debugPrint("------------ UPDATE FOLLOW-UP API REQUEST ------------");
      debugPrint("URL: $_apiUrl");
      debugPrint("BODY: $body");

      final response = await http.post(Uri.parse(_apiUrl), body: body);

      debugPrint("------------ UPDATE FOLLOW-UP API RESPONSE ------------");
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
      debugPrint("Error updating follow-up: $e");
      return {'error': true, 'error_msg': 'Connection error: $e'};
    }
  }

  static Future<List<dynamic>> fetchDropdownData({required String type}) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      String deviceId = prefs.getString('device_id') ?? '';
      String ln = prefs.getString('ln') ?? '';
      String lt = prefs.getString('lt') ?? '';

      String currentCid = await PreferenceService.getCid();
      String? token = await PreferenceService.getToken();
      String? uid = await PreferenceService.getUid();

      final Map<String, String> body = {
        'type': type,
        'cid': currentCid, // Dynamically use session CID
        'uid': uid ?? '',
        'lt': lt,
        'ln': ln,
        'device_id': deviceId,
        if (token != null) 'token': token,
      };

      debugPrint(
        "------------ FETCH DROPDOWN DATA REQUEST (Type: $type) ------------",
      );
      debugPrint("URL: $_apiUrl");
      debugPrint("BODY: $body");

      final response = await http.post(Uri.parse(_apiUrl), body: body);

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = _safeDecodeJson(response.body);

        if (data['error'] == false) {
          var listData = data['details'] ?? data['data'];

          // Handle if the list is nested inside a map (e.g., transport_types)
          if (listData is Map) {
            listData = listData.values.firstWhere(
              (v) => v is List,
              orElse: () => [],
            );
          }

          if (listData is List) {
            return listData;
          }
        }
        debugPrint("API Error: ${data['error_msg'] ?? 'Unknown error'}");
      }
    } catch (e) {
      debugPrint("Error fetching dropdown data (Type: $type): $e");
    }
    return [];
  }

  static Future<List<dynamic>> fetchMeetings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      String deviceId = prefs.getString('device_id') ?? '';
      String ln = prefs.getString('ln') ?? '';
      String lt = prefs.getString('lt') ?? '';

      String currentCid = await PreferenceService.getCid();
      String? token = await PreferenceService.getToken();
      String? uid = await PreferenceService.getUid();

      final Map<String, String> body = {
        'type': '3027',
        'cid': currentCid,
        'lt': lt,
        'ln': ln,
        'device_id': deviceId,
        'uid': uid ?? '',
        'led_id': uid ?? '',
        'enquiry_type': '1',
        if (token != null) 'token': token,
      };

      debugPrint("------------ FETCH MEETINGS API REQUEST (3027) ------------");
      debugPrint("URL: $_apiUrl");
      debugPrint("BODY: $body");

      final response = await http.post(Uri.parse(_apiUrl), body: body);

      debugPrint(
        "------------ FETCH MEETINGS API RESPONSE (3027) ------------",
      );
      debugPrint("STATUS: ${response.statusCode}");
      debugPrint("BODY: ${response.body}");

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = _safeDecodeJson(response.body);

        // Check both 'details' and 'data' as keys
        var listData = data['details'] ?? data['data'];

        if (listData is List) {
          return listData;
        } else {
          debugPrint("API Error: No data/details list found in response");
        }
      }
    } catch (e) {
      debugPrint("Error fetching meetings (3027): $e");
    }
    return [];
  }
}
