import 'dart:convert';
import 'package:http/http.dart' as http;
import '../Utils/shared_prefs_util.dart';

class PermissionRequestResponse {
  final bool error;
  final String message;
  final int count;
  final List<PermissionRequestData> data;
  final PermissionSummary? summary;

  PermissionRequestResponse({
    required this.error,
    required this.message,
    required this.count,
    required this.data,
    this.summary,
  });

  factory PermissionRequestResponse.fromJson(Map<String, dynamic> json) {
    List<dynamic> rawData = [];
    PermissionSummary? summary;

    if (json.containsKey('team_permissions')) {
      rawData = json['team_permissions']['data'] ?? [];
      if (json['team_permissions']['summary'] != null) {
        summary = PermissionSummary.fromJson(json['team_permissions']['summary']);
      }
    } else {
      rawData = json['data'] ?? [];
    }

    return PermissionRequestResponse(
      error: json['error'] ?? false,
      message: json['message'] ?? "",
      count: summary?.total ?? json['count'] ?? rawData.length,
      data: rawData.map((e) => PermissionRequestData.fromJson(e)).toList(),
      summary: summary,
    );
  }
}

class PermissionSummary {
  final int total;
  final int pending;
  final int approved;
  final int rejected;

  PermissionSummary({
    required this.total,
    required this.pending,
    required this.approved,
    required this.rejected,
  });

  factory PermissionSummary.fromJson(Map<String, dynamic> json) {
    int parseInt(dynamic val) {
      if (val == null) return 0;
      if (val is int) return val;
      return int.tryParse(val.toString()) ?? 0;
    }

    return PermissionSummary(
      total: parseInt(json['total']),
      pending: parseInt(json['pending']),
      approved: parseInt(json['approved']),
      rejected: parseInt(json['rejected']),
    );
  }
}

class PermissionRequestData {
  final int id;
  final int? aid;
  final int? uid;
  final dynamic bid;
  final int? cid;
  final dynamic did;
  final String employeeName;
  final String? employeeCode;
  final String? department;
  final String? leaveType;
  final String? reason;
  final String? reportingManager;
  final String? permissionType;
  final String? startTime;
  final String? endDate;
  final String? totalDays;
  final String? appDate;
  final dynamic maxMonth;
  final dynamic perTaken;
  final dynamic balPermission;
  final dynamic del;
  final dynamic isD;
  final dynamic act;
  final String dtime;
  final String? employeeFullName;
  final String? empEmployeeCode;
  final String? empDepartment;
  final String? empContactNumber;
  final String? status;
  final String? appBy;
  final String? approvalDate;

  PermissionRequestData({
    required this.id,
    this.aid,
    this.uid,
    this.bid,
    this.cid,
    this.did,
    required this.employeeName,
    this.employeeCode,
    this.department,
    this.leaveType,
    this.reason,
    this.reportingManager,
    this.permissionType,
    this.startTime,
    this.endDate,
    this.totalDays,
    this.appDate,
    this.maxMonth,
    this.perTaken,
    this.balPermission,
    this.del,
    this.isD,
    this.act,
    required this.dtime,
    this.employeeFullName,
    this.empEmployeeCode,
    this.empDepartment,
    this.empContactNumber,
    this.status,
    this.appBy,
    this.approvalDate,
  });

  factory PermissionRequestData.fromJson(Map<String, dynamic> json) {
    int parseId(dynamic val) {
      if (val == null) return 0;
      if (val is int) return val;
      return int.tryParse(val.toString()) ?? 0;
    }

    return PermissionRequestData(
      id: parseId(json['id']),
      aid: json['aid'] != null ? parseId(json['aid']) : null,
      uid: json['uid'] != null ? parseId(json['uid']) : null,
      bid: json['bid'],
      cid: json['cid'] != null ? parseId(json['cid']) : null,
      did: json['did'],
      employeeName: json['employee_name'] ?? json['e_name'] ?? "Unknown",
      employeeCode: json['employee_code']?.toString(),
      department: json['department']?.toString(),
      leaveType: json['leave_type']?.toString(),
      reason: json['reason'],
      reportingManager: json['reporting_manager']?.toString(),
      permissionType: json['permission_type']?.toString(),
      startTime: json['start_time']?.toString(),
      endDate: json['end_date']?.toString(),
      totalDays: json['total_days']?.toString(),
      appDate: json['app_date'] ?? json['date']?.toString(),
      maxMonth: json['Max_month'],
      perTaken: json['per_taken'],
      balPermission: json['bal_permission']?.toString(),
      del: json['del'],
      isD: json['is_d'],
      act: json['act'],
      dtime: json['dtime'] ?? "",
      employeeFullName: json['employee_full_name']?.toString(),
      empEmployeeCode: json['emp_employee_code']?.toString(),
      empDepartment: json['emp_department']?.toString(),
      empContactNumber: json['emp_contact_number']?.toString(),
      status: json['status']?.toString(),
      appBy: json['app_by']?.toString(),
      approvalDate: json['approval_date']?.toString(),
    );
  }
}

class PermissionApi {
  static const String _baseUrl = "https://erpsmart.in/total/api/m_api/";

  static Future<PermissionRequestResponse> fetchPermissionRequests({String? reportingManager}) async {
    try {
      final params = await SharedPrefsUtil.getCommonParams();

      final Map<String, String> body = {
        'type': '2094',
        'cid': params['cid']!,
        'lt': params['lt']!,
        'ln': params['ln']!,
        'device_id': params['device_id']!,
        'token': params['token']!,
        'uid': params['uid']!,
        if (reportingManager != null && reportingManager.isNotEmpty)
          'reporting_manager': reportingManager,
      };

      print("Permission Request Request body: $body");

      final response = await http.post(
        Uri.parse(_baseUrl),
        body: body,
      );

      print("Permission Request response Status Code: ${response.statusCode}");
      print("Permission Request response body: ${response.body}");

      if (response.statusCode == 200) {
        final Map<String, dynamic> decodedData = jsonDecode(response.body);
        return PermissionRequestResponse.fromJson(decodedData);
      } else {
        throw Exception("Failed to load permission requests: ${response.statusCode}");
      }
    } catch (e) {
      print("Error fetching permission requests: $e");
      throw Exception("Error fetching permission requests: $e");
    }
  }

  static Future<Map<String, dynamic>> updatePermissionStatus({
    required String permissionId,
    required String status,
    String? rejectReason,
  }) async {
    try {
      final params = await SharedPrefsUtil.getCommonParams();
      final String adminUid = params['uid']!;

      final Map<String, String> body = {
        'type': '2091',
        'cid': params['cid']!,
        'lt': params['lt']!,
        'ln': params['ln']!,
        'device_id': params['device_id']!,
        'token': params['token']!,
        'form': 'sm_main_form_16143',
        'permission_id': permissionId,
        'uid': adminUid.isEmpty ? "0" : adminUid,
        'id': adminUid.isEmpty ? "0" : adminUid,
        'status': status,
        if (rejectReason != null && rejectReason.isNotEmpty) 'remarks': rejectReason,
      };

      print("--- UPDATING PERMISSION STATUS ---");
      print("URL: $_baseUrl");
      print("BODY: $body");

      final response = await http.post(
        Uri.parse(_baseUrl),
        body: body,
      );

      print("Update Permission Status Response: ${response.body}");
      return jsonDecode(response.body);
    } catch (e) {
      print("Error updating permission status: $e");
      return {"error": true, "message": e.toString()};
    }
  }
}
