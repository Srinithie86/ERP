import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:crm/services/preference_service.dart';

class FollowUpApi {
  static const String _apiUrl = 'https://erpsmart.in/total/api/m_api/';

  static Future<List<dynamic>> fetchFollowUpModes() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      String deviceId = prefs.getString('device_id') ?? '';
      String ln = prefs.getString('ln') ?? '';
      String lt = prefs.getString('lt') ?? '';

      String currentCid = await PreferenceService.getCid();
      String? token = await PreferenceService.getToken();

      final Map<String, String> body = {
        'type': '2084',
        'cid': '1', // Hardcoded as requested
        'lt': lt,
        'ln': ln,
        'device_id': deviceId,
        'list_id': '1501',
        'token': ?token,
      };

      debugPrint("------------ FETCH FOLLOW UP MODES API REQUEST ------------");
      debugPrint("URL: $_apiUrl");
      debugPrint("BODY: $body");

      final response = await http.post(Uri.parse(_apiUrl), body: body);

      debugPrint("------------ FETCH FOLLOW UP MODES API RESPONSE ------------");
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
          var dropdown = data['dropdown'];
          if (dropdown is List) {
            return List<dynamic>.from(dropdown);
          }
        }
      }
    } catch (e) {
      debugPrint("Error fetching follow up modes: $e");
    }
    return [];
  }

  static Future<List<dynamic>> fetchCallOutcomes() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      String deviceId = prefs.getString('device_id') ?? '';
      String ln = prefs.getString('ln') ?? '';
      String lt = prefs.getString('lt') ?? '';

      // We still need token if available
      String? token = await PreferenceService.getToken();

      final Map<String, String> body = {
        'type': '2084',
        'cid': '1', // Hardcoded as requested
        'lt': lt,
        'ln': ln,
        'device_id': deviceId,
        'list_id': '1500', // Call Outcomes List ID
        'token': ?token,
      };

      debugPrint("------------ FETCH CALL OUTCOMES API REQUEST ------------");
      debugPrint("URL: $_apiUrl");
      debugPrint("BODY: $body");

      final response = await http.post(Uri.parse(_apiUrl), body: body);

      debugPrint("------------ FETCH CALL OUTCOMES API RESPONSE ------------");
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
          var dropdown = data['dropdown'];
          if (dropdown is List) {
            return List<dynamic>.from(dropdown);
          }
        }
      }
    } catch (e) {
      debugPrint("Error fetching call outcomes: $e");
    }
    return [];
  }

  static Future<List<dynamic>> fetchLeadStatuses() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      String deviceId = prefs.getString('device_id') ?? '';
      String ln = prefs.getString('ln') ?? '';
      String lt = prefs.getString('lt') ?? '';

      // We still need token if available
      String? token = await PreferenceService.getToken();

      final Map<String, String> body = {
        'type': '2084',
        'cid': '1', // Hardcoded as requested
        'lt': lt,
        'ln': ln,
        'device_id': deviceId,
        'list_id': '1502', // Lead Statuses List ID
        'token': ?token,
      };

      debugPrint("------------ FETCH LEAD STATUSES API REQUEST ------------");
      debugPrint("URL: $_apiUrl");
      debugPrint("BODY: $body");

      final response = await http.post(Uri.parse(_apiUrl), body: body);

      debugPrint("------------ FETCH LEAD STATUSES API RESPONSE ------------");
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
          var dropdown = data['dropdown'];
          if (dropdown is List) {
            return List<dynamic>.from(dropdown);
          }
        }
      }
    } catch (e) {
      debugPrint("Error fetching lead statuses: $e");
    }
    return [];
  }

  static Future<Map<String, dynamic>> submitCallOutcome(Map<String, String> formData) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      String deviceId = prefs.getString('device_id') ?? '';
      String ln = prefs.getString('ln') ?? '';
      String lt = prefs.getString('lt') ?? '';
      String? token = await PreferenceService.getToken();

      // Dynamic cid matching their exact payload requirement, but defaulting to preference
      String currentCid = await PreferenceService.getCid();
      if (currentCid.isEmpty) currentCid = '44555666'; // fallback to their postman cid if empty

      final Map<String, String> body = {
        'type': '2082',
        'cid': currentCid,
        'lt': lt,
        'ln': ln,
        'device_id': deviceId,
        'form': 'sm_main_form_21004',
        ...formData,
      };

      debugPrint("------------ SUBMIT CALL OUTCOME API REQUEST ------------");
      debugPrint("URL: $_apiUrl");
      debugPrint("BODY: $body");

      final response = await http.post(Uri.parse(_apiUrl), body: body);

      debugPrint("------------ SUBMIT CALL OUTCOME API RESPONSE ------------");
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
        return data;
      }
      return {'error': true, 'message': 'HTTP error ${response.statusCode}'};
    } catch (e) {
      debugPrint("Error submitting call outcome: $e");
      return {'error': true, 'message': 'Exception: $e'};
    }
  }

  static Future<List<dynamic>> fetchFollowUpLeads() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      String deviceId = prefs.getString('device_id') ?? '';
      String ln = prefs.getString('ln') ?? '';
      String lt = prefs.getString('lt') ?? '';
      String? token = await PreferenceService.getToken();

      String currentCid = await PreferenceService.getCid();
      if (currentCid.isEmpty) currentCid = '44555666'; // fallback

      final Map<String, String> body = {
        'type': '2083',
        'cid': currentCid,
        'lt': lt,
        'ln': ln,
        'device_id': deviceId,
        'form': 'sm_main_form_21004',
        'select': '*',
        'token': ?token,
      };

      debugPrint("------------ FETCH FOLLOW UP LEADS API REQUEST ------------");
      debugPrint("URL: $_apiUrl");
      debugPrint("BODY: $body");

      final response = await http.post(Uri.parse(_apiUrl), body: body);

      debugPrint("------------ FETCH FOLLOW UP LEADS API RESPONSE ------------");
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
          var listData = data['data'];
          if (listData is List) {
            return List<dynamic>.from(listData);
          }
        }
      }
    } catch (e) {
      debugPrint("Error fetching follow up leads: $e");
    }
    return [];
  }
}
