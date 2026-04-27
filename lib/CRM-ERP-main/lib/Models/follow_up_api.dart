import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:crm/Services/preference_service.dart';

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
        if (token != null) 'token': token,
      };

      final response = await http.post(Uri.parse(_apiUrl), body: body);
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
        if (token != null) 'token': token,
      };

      final response = await http.post(Uri.parse(_apiUrl), body: body);
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
        if (token != null) 'token': token,
      };

      final response = await http.post(Uri.parse(_apiUrl), body: body);
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

      final Map<String, String> body = {
        'type': '2082',
        'cid': currentCid,
        'uid': uid ?? '',
        'lt': lt,
        'ln': ln,
        'device_id': deviceId,
        'form': 'sm_main_form_21004',
        ...formData,
      };

      debugPrint("------------ SUBMIT FOLLOW UP API REQUEST ------------");
      debugPrint("URL: $_apiUrl");
      debugPrint("BODY: $body");

      final response = await http.post(Uri.parse(_apiUrl), body: body);
      if (response.statusCode == 200) {
        return _safeDecode(response.body);
      }
    } catch (e) {
      debugPrint("Error: $e");
    }
    return {'error': true, 'message': 'Failed to submit'};
  }

  static Future<List<FollowUpModel>> fetchFollowUpLeads({String? enquiryType}) async {
    try {
      String deviceId = await PreferenceService.getDeviceId();
      String ln = await PreferenceService.getLn();
      String lt = await PreferenceService.getLt();
      String currentCid = await PreferenceService.getCid();
      String? token = await PreferenceService.getToken();
      String? uid = await PreferenceService.getUid();

      String whereClause = 'uid=${uid ?? ''}';
      // We don't filter enquiry_type in where clause if many are null in DB
      // but the UI filters matches leads anyway.

      final Map<String, String> body = {
        'type': '2083',
        'cid': currentCid,
        'uid': uid ?? '',
        'lt': lt,
        'ln': ln,
        'device_id': deviceId,
        'form': 'sm_main_form_21004',
        'select': '*',
        'where': whereClause,
        if (token != null) 'token': token,
      };

      debugPrint("------------ FETCH FOLLOW UP API REQUEST ------------");
      debugPrint("URL: $_apiUrl");
      debugPrint("BODY: $body");

      final response = await http.post(Uri.parse(_apiUrl), body: body);
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
