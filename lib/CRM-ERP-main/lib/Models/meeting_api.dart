import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:crm/Services/preference_service.dart';

class MeetingModel {
  final int? id;
  final int? uid;
  final int? cid;
  final String? dtime;
  final String? meetDate;
  final String? type;
  final String? cusName;
  final String? mobile1;
  final String? mobile2;
  final String? modeOfMeet;
  final String? loc;
  final String? address;
  final String? time;
  final String? attendedBy;
  final String? feedback;

  MeetingModel({
    this.id,
    this.uid,
    this.cid,
    this.dtime,
    this.meetDate,
    this.type,
    this.cusName,
    this.mobile1,
    this.mobile2,
    this.modeOfMeet,
    this.loc,
    this.address,
    this.time,
    this.attendedBy,
    this.feedback,
  });

  factory MeetingModel.fromJson(Map<String, dynamic> json) {
    return MeetingModel(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id']?.toString() ?? ''),
      uid: json['uid'] is int ? json['uid'] : int.tryParse(json['uid']?.toString() ?? ''),
      cid: json['cid'] is int ? json['cid'] : int.tryParse(json['cid']?.toString() ?? ''),
      dtime: json['dtime']?.toString(),
      meetDate: json['meet_date']?.toString(),
      type: json['type']?.toString(),
      cusName: json['cus_name']?.toString(),
      mobile1: json['mobile_1']?.toString(),
      mobile2: json['mobile_2']?.toString(),
      modeOfMeet: json['mode_of_meet']?.toString(),
      loc: json['loc']?.toString(),
      address: json['address']?.toString(),
      time: json['time']?.toString(),
      attendedBy: json['attended_by']?.toString(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'uid': uid,
      'cid': cid,
      'dtime': dtime,
      'meet_date': meetDate,
      'type': type,
      'cus_name': cusName,
      'mobile_1': mobile1,
      'mobile_2': mobile2,
      'mode_of_meet': modeOfMeet,
      'loc': loc,
      'address': address,
      'time': time,
      'attended_by': attendedBy,
      'feedback': feedback,
    };
  }
}

class MeetingApi {
  static const String _apiUrl = 'https://erpsmart.in/total/api/m_api/';

  static Future<List<MeetingModel>> fetchMeetings({String? enquiryType}) async {
    try {
      final deviceId = await PreferenceService.getDeviceId();
      final ln = await PreferenceService.getLn();
      final lt = await PreferenceService.getLt();
      final currentCid = await PreferenceService.getCid();
      final uid = await PreferenceService.getUid();
      final token = await PreferenceService.getToken();

      String whereClause = 'uid=${uid ?? ''}';

      final body = {
        'type': '2083',
        'cid': currentCid,
        'uid': uid ?? '',
        'lt': lt,
        'ln': ln,
        'device_id': deviceId,
        'form': 'sm_main_form_21003',
        'select': '*',
        'where': whereClause,
        if (token != null) 'token': token,
      };

      debugPrint("------------ FETCH MEETINGS API REQUEST ------------");
      debugPrint("URL: $_apiUrl");
      debugPrint("BODY: $body");

      final response = await http.post(Uri.parse(_apiUrl), body: body);

      debugPrint("------------ FETCH MEETINGS API RESPONSE ------------");
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
        if (data['error'] == false && data['data'] is List) {
          return (data['data'] as List)
              .map((item) => MeetingModel.fromJson(item))
              .toList();
        }
      }
    } catch (e) {
      debugPrint("Error fetching meetings: $e");
    }
    return [];
  }

  static Future<Map<String, dynamic>> submitMeetingDetails(Map<String, String> formData) async {
    try {
      final deviceId = await PreferenceService.getDeviceId();
      final ln = await PreferenceService.getLn();
      final lt = await PreferenceService.getLt();
      final currentCid = await PreferenceService.getCid();
      final token = await PreferenceService.getToken();
      final uid = await PreferenceService.getUid();

      final body = {
        'type': '2082',
        'cid': currentCid,
        'uid': uid ?? '',
        'lt': lt,
        'ln': ln,
        'device_id': deviceId,
        'form': 'sm_main_form_21003',
        ...formData,
      };

      debugPrint("------------ SUBMIT MEETING API REQUEST ------------");
      debugPrint("URL: $_apiUrl");
      debugPrint("BODY: $body");

      final response = await http.post(Uri.parse(_apiUrl), body: body);
      debugPrint("------------ SUBMIT MEETING API RESPONSE ------------");
      debugPrint("STATUS: ${response.statusCode}");
      debugPrint("BODY: ${response.body}");

      if (response.statusCode == 200) {
        String bodyText = response.body;
        int startIndex = bodyText.indexOf('{');
        int endIndex = bodyText.lastIndexOf('}');
        if (startIndex != -1 && endIndex != -1) {
          bodyText = bodyText.substring(startIndex, endIndex + 1);
        }
        return json.decode(bodyText);
      }
      return {'error': true, 'message': 'HTTP error ${response.statusCode}'};
    } catch (e) {
      debugPrint("Error submitting meeting: $e");
      return {'error': true, 'message': 'Exception: $e'};
    }
  }
}
