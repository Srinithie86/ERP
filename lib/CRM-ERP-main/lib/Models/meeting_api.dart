import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:erp_smart/CRM-ERP-main/lib/Services/preference_service.dart';

class MeetingModel {
  final int? id;
  final int? uid;   // user who created
  final int? cid;   // company id
  final int? aid;   // linked lead id (enquiry_type=1)
  final int? bid;   // linked enquiry id (enquiry_type=2)
  final int? did;   // linked referral id (enquiry_type=3)
  final String? dtime;
  final String? meetDate;
  final String? type;
  final String? enquiryType;
  final String? cusName;
  final String? mobile1;
  final String? mobile2;
  final String? modeOfMeet;
  final String? loc;
  final String? address;
  final String? time;
  final String? attendedBy;
  final String? feedback;
  final String? leCode;


  MeetingModel({
    this.id,
    this.uid,
    this.cid,
    this.aid,
    this.bid,
    this.did,
    this.dtime,
    this.meetDate,
    this.type,
    this.enquiryType,
    this.cusName,
    this.mobile1,
    this.mobile2,
    this.modeOfMeet,
    this.loc,
    this.address,
    this.time,
    this.attendedBy,
    this.feedback,
    this.leCode,
  });

  factory MeetingModel.fromJson(Map<String, dynamic> json) {
    return MeetingModel(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id']?.toString() ?? ''),
      uid: json['uid'] is int ? json['uid'] : int.tryParse(json['uid']?.toString() ?? ''),
      cid: json['cid'] is int ? json['cid'] : int.tryParse(json['cid']?.toString() ?? ''),
      aid: json['aid'] is int ? json['aid'] : int.tryParse(json['aid']?.toString() ?? ''),
      bid: json['bid'] is int ? json['bid'] : int.tryParse(json['bid']?.toString() ?? ''),
      did: json['did'] is int ? json['did'] : int.tryParse(json['did']?.toString() ?? ''),
      dtime: json['dtime']?.toString(),
      meetDate: json['meet_date']?.toString(),
      type: json['type']?.toString(),
      enquiryType: json['enquiry_type']?.toString(),
      cusName: json['cus_name']?.toString(),
      mobile1: json['mobile_1']?.toString(),
      mobile2: json['mobile_2']?.toString(),
      modeOfMeet: json['mode_of_meet']?.toString(),
      loc: json['loc']?.toString(),
      address: json['address']?.toString(),
      time: json['time']?.toString(),
      attendedBy: json['attended_by']?.toString(),
      feedback: json['feedback']?.toString(),
      leCode: json['le_code']?.toString(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'uid': uid,
      'cid': cid,
      'aid': aid,
      'bid': bid,
      'did': did,
      'dtime': dtime,
      'meet_date': meetDate,
      'type': type,
      'enquiry_type': enquiryType,
      'cus_name': cusName,
      'mobile_1': mobile1,
      'mobile_2': mobile2,
      'mode_of_meet': modeOfMeet,
      'loc': loc,
      'address': address,
      'time': time,
      'attended_by': attendedBy,
      'feedback': feedback,
      'le_code': leCode,
    };
  }

  /// Returns the lead/enquiry/referral ID that this meeting is linked to
  String? get linkedLeadId {
    if (aid != null && aid != 0) return aid.toString();
    if (bid != null && bid != 0) return bid.toString();
    if (did != null && did != 0) return did.toString();
    return null;
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

      final Map<String, String> body = {
        'type': '2083',
        'cid': currentCid,
        'uid': uid ?? '',
        'lt': lt,
        'ln': ln,
        'device_id': deviceId,
       // 'form': 'sm_main_form_21003',
        'select': '*',
        'where': 'uid=${uid ?? ''}', // filter meetings for this user
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

        // Handle both boolean false and string 'false' for error field
        final bool isSuccess = data['error'] == false || data['error'].toString() == 'false';
        // Handle both 'data' and 'details' response keys
        final dynamic listData = data['data'] ?? data['details'];

        if (isSuccess && listData is List) {
          debugPrint("Meetings returned: ${listData.length}");
          return listData.map((item) => MeetingModel.fromJson(item)).toList();
        }
        debugPrint("Meetings API error/empty: error=${data['error']}, data=${data['data']}, details=${data['details']}, message=${data['message']}");
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

      // Build as Map<String, String> so http.post encodes correctly as form data
      final Map<String, String> body = {
        'type': '2082',
        'cid': currentCid,
        'uid': uid ?? '',
        'lt': lt,
        'ln': ln,
        'device_id': deviceId,
        'form': 'sm_main_form_21003',
        // NOTE: role_id is NOT included — sm_main_form_21003 table has no role_id column
        if (token != null) 'token': token,
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
