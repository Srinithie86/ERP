import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:erp_smart/CRM-ERP-main/lib/Services/preference_service.dart';

class FollowUpModel {
  final int? id;
  final int? uid;
  final int? cid;
  final String? cusName;
  final String? callOutcome;
  final String? followUpMode;
  final String? requiredProject;
  final String? otherRequired;
  final double? customerBudget;
  final String? nextFollowUpDate;
  final String? nextFollowUpTime;
  final String? callSummary;
  final String? leadStatus;
  final String? enquiryType;
  final String? dtime;
  final int? aid;
  final int? bid;
  final int? did;
  final String? callDate;
  final String? callBy;
  final String? callTime;
  final String? leCode;
  final int? isA;

  FollowUpModel({
    this.id,
    this.uid,
    this.cid,
    this.cusName,
    this.callOutcome,
    this.followUpMode,
    this.requiredProject,
    this.otherRequired,
    this.customerBudget,
    this.nextFollowUpDate,
    this.nextFollowUpTime,
    this.callSummary,
    this.leadStatus,
    this.enquiryType,
    this.dtime,
    this.aid,
    this.bid,
    this.did,
    this.callDate,
    this.callBy,
    this.callTime,
    this.leCode,
    this.isA,
  });

  factory FollowUpModel.fromJson(Map<String, dynamic> json) {
    return FollowUpModel(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id']?.toString() ?? ''),
      uid: json['uid'] is int ? json['uid'] : int.tryParse(json['uid']?.toString() ?? ''),
      cid: json['cid'] is int ? json['cid'] : int.tryParse(json['cid']?.toString() ?? ''),
      cusName: json['cus_name']?.toString(),
      callOutcome: json['call_outcome']?.toString(),
      followUpMode: json['follow_up_mode']?.toString(),
      requiredProject: json['required_project']?.toString(),
      otherRequired: json['other_required']?.toString(),
      customerBudget: double.tryParse(json['customer_budget']?.toString() ?? '0'),
      nextFollowUpDate: json['next_follow_up_date']?.toString(),
      nextFollowUpTime: json['next_follow_up_time']?.toString(),
      callSummary: json['call_summary']?.toString(),
      leadStatus: json['lead_status']?.toString(),
      enquiryType: json['enquiry_type']?.toString(),
      dtime: json['dtime']?.toString(),
      aid: json['aid'] is int ? json['aid'] : int.tryParse(json['aid']?.toString() ?? ''),
      bid: json['bid'] is int ? json['bid'] : int.tryParse(json['bid']?.toString() ?? ''),
      did: json['did'] is int ? json['did'] : int.tryParse(json['did']?.toString() ?? ''),
      callDate: json['call_date']?.toString(),
      callBy: json['call_by']?.toString(),
      callTime: json['call_time']?.toString(),
      leCode: json['le_code']?.toString(),
      isA: json['is_a'] is int ? json['is_a'] : int.tryParse(json['is_a']?.toString() ?? ''),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'uid': uid,
      'cid': cid,
      'cus_name': cusName,
      'call_outcome': callOutcome,
      'follow_up_mode': followUpMode,
      'required_project': requiredProject,
      'other_required': otherRequired,
      'customer_budget': customerBudget,
      'next_follow_up_date': nextFollowUpDate,
      'next_follow_up_time': nextFollowUpTime,
      'call_summary': callSummary,
      'lead_status': leadStatus,
      'enquiry_type': enquiryType,
      'dtime': dtime,
      'aid': aid,
      'bid': bid,
      'did': did,
      'call_date': callDate,
      'call_by': callBy,
      'call_time': callTime,
      'le_code': leCode,
      'is_a': isA,
    };
  }
}

class FollowUpApi {
  static const String _apiUrl = 'https://erpsmart.in/total/api/m_api/';

  static Future<List<dynamic>> fetchFollowUpModes() async {
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
        'list_id': '1501',
        'role_id': await PreferenceService.getRoleId(),
        if (token != null) 'token': token,
      };

      debugPrint("------------ FETCH FOLLOW UP MODES API REQUEST ------------");
      debugPrint("URL: $_apiUrl");
      debugPrint("BODY: $body");

      final response = await http.post(Uri.parse(_apiUrl), body: body);

      debugPrint("------------ FETCH FOLLOW UP MODES API RESPONSE ------------");
      debugPrint("STATUS: ${response.statusCode}");
      debugPrint("BODY: ${response.body}");

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = _safeDecode(response.body);
        if (data['error'] == false && data['dropdown'] is List) {
          return List<dynamic>.from(data['dropdown']);
        }
      }
    } catch (e) {
      debugPrint("Error: $e");
    }
    return [];
  }

  static Future<List<dynamic>> fetchCallOutcomes() async {
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
        'list_id': '1500',
        'role_id': await PreferenceService.getRoleId(),
        if (token != null) 'token': token,
      };

      debugPrint("------------ FETCH CALL OUTCOMES API REQUEST ------------");
      debugPrint("URL: $_apiUrl");
      debugPrint("BODY: $body");

      final response = await http.post(Uri.parse(_apiUrl), body: body);

      debugPrint("------------ FETCH CALL OUTCOMES API RESPONSE ------------");
      debugPrint("STATUS: ${response.statusCode}");
      debugPrint("BODY: ${response.body}");

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = _safeDecode(response.body);
        if (data['error'] == false && data['dropdown'] is List) {
          return List<dynamic>.from(data['dropdown']);
        }
      }
    } catch (e) {
      debugPrint("Error: $e");
    }
    return [];
  }

  static Future<List<dynamic>> fetchLeadStatuses() async {
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
        'list_id': '1502',
        'role_id': await PreferenceService.getRoleId(),
        if (token != null) 'token': token,
      };

      debugPrint("------------ FETCH LEAD STATUSES API REQUEST ------------");
      debugPrint("URL: $_apiUrl");
      debugPrint("BODY: $body");

      final response = await http.post(Uri.parse(_apiUrl), body: body);

      debugPrint("------------ FETCH LEAD STATUSES API RESPONSE ------------");
      debugPrint("STATUS: ${response.statusCode}");
      debugPrint("BODY: ${response.body}");

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = _safeDecode(response.body);
        if (data['error'] == false && data['dropdown'] is List) {
          return List<dynamic>.from(data['dropdown']);
        }
      }
    } catch (e) {
      debugPrint("Error: $e");
    }
    return [];
  }

  static Future<Map<String, dynamic>> submitCallOutcome(Map<String, String> formData) async {
    try {
      String deviceId = await PreferenceService.getDeviceId();
      String ln = await PreferenceService.getLn();
      String lt = await PreferenceService.getLt();
      String currentCid = await PreferenceService.getCid();
      String? uid = await PreferenceService.getUid();

      // Extract lead ID from aid, bid, or did for the led_id parameter in 3032
      String leadId = formData['aid'] ?? formData['bid'] ?? formData['did'] ?? formData['led_id'] ?? '';
      final Map<String, String> body = {
        'type': '3032',
        'cid': currentCid,
        'uid': uid ?? '',
        'led_id': leadId,
        'role_id': await PreferenceService.getRoleId(),
        'lt': lt,
        'ln': ln,
        'device_id': deviceId,
        ...formData,
      };

      debugPrint("------------ SUBMIT FOLLOW UP API REQUEST (3032) ------------");
      debugPrint("URL: $_apiUrl");
      debugPrint("BODY: $body");

      final response = await http.post(Uri.parse(_apiUrl), body: body);

      debugPrint("------------ SUBMIT FOLLOW UP API RESPONSE (3032) ------------");
      debugPrint("STATUS: ${response.statusCode}");
      debugPrint("BODY: ${response.body}");

      if (response.statusCode == 200) {
        return _safeDecode(response.body);
      }
    } catch (e) {
      debugPrint("Error: $e");
    }
    return {'error': true, 'message': 'Failed to submit'};
  }

  static Future<List<FollowUpModel>> fetchFollowUpLeads({String? enquiryType, String? uid}) async {
    try {
      String deviceId = await PreferenceService.getDeviceId();
      String ln = await PreferenceService.getLn();
      String lt = await PreferenceService.getLt();
      String currentCid = await PreferenceService.getCid();
      String? token = await PreferenceService.getToken();
      String? loggedInUid = await PreferenceService.getUid();

      final Map<String, String> body = {
        'type': '2083',
        'cid': currentCid,
        'uid': loggedInUid ?? '',
        'lt': lt,
        'ln': ln,
        'device_id': deviceId,
        'form': 'sm_main_form_21004',
        'select': '*',
        'where': 'uid=${loggedInUid ?? ''}${enquiryType != null ? ",enquiry_type=$enquiryType" : ""}',
        'role_id': await PreferenceService.getRoleId(),
        if (token != null) 'token': token,
      };

      debugPrint("------------ FETCH FOLLOW UP API REQUEST (2083) ------------");
      debugPrint("URL: $_apiUrl");
      debugPrint("BODY: $body");

      final response = await http.post(Uri.parse(_apiUrl), body: body);

      debugPrint("------------ FETCH FOLLOW UP API RESPONSE (2083) ------------");
      debugPrint("STATUS: ${response.statusCode}");
      debugPrint("BODY: ${response.body}");

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = _safeDecode(response.body);
        if (data['error'] == false && data['data'] is List) {
          return (data['data'] as List)
              .map((item) => FollowUpModel.fromJson(item))
              .toList();
        }
      }
    } catch (e) {
      debugPrint("Error fetching follow up: $e");
    }
    return [];
  }





  static Map<String, dynamic> _safeDecode(String body) {
    try {
      int start = body.indexOf('{');
      int end = body.lastIndexOf('}');
      if (start != -1 && end != -1) {
        return json.decode(body.substring(start, end + 1));
      }
    } catch (e) {
      debugPrint("JSON Decode Error: $e");
    }
    return {'error': true};
  }
}
