import 'dart:convert';
import 'package:http/http.dart' as http;
import '../Utils/shared_prefs_util.dart';

class LeaveRequestResponse {
  final bool error;
  final String message;
  final int count;
  final List<LeaveRequestData> data;
  final LeaveSummary? summary;

  LeaveRequestResponse({
    required this.error,
    required this.message,
    required this.count,
    required this.data,
    this.summary,
  });

  factory LeaveRequestResponse.fromJson(Map<String, dynamic> json) {
    List<dynamic> rawData = [];
    LeaveSummary? summary;

    if (json.containsKey('team_leaves')) {
      rawData = json['team_leaves']['data'] ?? [];
      if (json['team_leaves']['summary'] != null) {
        summary = LeaveSummary.fromJson(json['team_leaves']['summary']);
      }
    } else {
      rawData = json['data'] ?? [];
    }

    final List<LeaveRequestData> parsedData = rawData
        .map((e) => LeaveRequestData.fromJson(e))
        .where((item) {
          // Filter out deleted records
          final String delFlag = item.del?.toString() ?? "";
          final String isDFlag = item.isD?.toString() ?? "";
          return delFlag != "1" && isDFlag != "1";
        })
        .toList();

    return LeaveRequestResponse(
      error: json['error'] ?? false,
      message: json['message'] ?? "",
      count: summary?.total ?? parsedData.length,
      data: parsedData,
      summary: summary,
    );
  }
}

class LeaveSummary {
  final int total;
  final int pending;
  final int approved;
  final int rejected;

  LeaveSummary({
    required this.total,
    required this.pending,
    required this.approved,
    required this.rejected,
  });

  factory LeaveSummary.fromJson(Map<String, dynamic> json) {
    int parseInt(dynamic val) {
      if (val == null) return 0;
      if (val is int) return val;
      return int.tryParse(val.toString()) ?? 0;
    }

    return LeaveSummary(
      total: parseInt(json['total']),
      pending: parseInt(json['pending']),
      approved: parseInt(json['approved']),
      rejected: parseInt(json['rejected']),
    );
  }
}

class LeaveRequestData {
  final int id;
  final int? aid;
  final int? uid;
  final dynamic bid;
  final int? cid;
  final dynamic did;
  final String employeeName;
  final String? employeeId;
  final String? department;
  final String? reportingManager;
  final String leaveType;
  final String? maxLeaveMonth;
  final String? maxLeaveYear;
  final String? leaveTaken;
  final String? balanceLeave;
  final String? appBy;
  final dynamic leaveDur;
  final String? leaveDuration;
  final String? rejectReason;
  final String? leaveStartDate;
  final String? leaveEndDate;
  final String? totalDays;
  final String? reason;
  final String? status;
  final String? appDate;
  final String? appliedDate;
  final String? attachment;
  final dynamic del;
  final dynamic isD;
  final dynamic act;
  final String dtime;
  final String? employeeFullName;
  final String? empEmployeeCode;
  final String? empDepartment;
  final String? empContactNumber;

  LeaveRequestData({
    required this.id,
    this.aid,
    this.uid,
    this.bid,
    this.cid,
    this.did,
    required this.employeeName,
    this.employeeId,
    this.department,
    this.reportingManager,
    required this.leaveType,
    this.maxLeaveMonth,
    this.maxLeaveYear,
    this.leaveTaken,
    this.balanceLeave,
    this.appBy,
    this.leaveDur,
    this.leaveDuration,
    this.rejectReason,
    this.leaveStartDate,
    this.leaveEndDate,
    this.totalDays,
    this.reason,
    this.status,
    this.appDate,
    this.appliedDate,
    this.attachment,
    this.del,
    this.isD,
    this.act,
    required this.dtime,
    this.employeeFullName,
    this.empEmployeeCode,
    this.empDepartment,
    this.empContactNumber,
  });

  factory LeaveRequestData.fromJson(Map<String, dynamic> json) {
    int parseId(dynamic val) {
      if (val == null) return 0;
      if (val is int) return val;
      return int.tryParse(val.toString()) ?? 0;
    }

    return LeaveRequestData(
      id: parseId(json['id']),
      aid: json['aid'] != null ? parseId(json['aid']) : null,
      uid: parseId(json['uid']),
      bid: json['bid'],
      cid: json['cid'] != null ? parseId(json['cid']) : null,
      did: json['did'],
      employeeName: json['employee_name'] ?? "",
      employeeId: json['employee_id']?.toString(),
      department: json['department']?.toString(),
      reportingManager: json['reporting_manager']?.toString(),
      leaveType: json['leave_type'] ?? "",
      maxLeaveMonth: json['max_leave_month']?.toString(),
      maxLeaveYear: json['max_leave_year']?.toString(),
      leaveTaken: json['leave_taken']?.toString(),
      balanceLeave: json['balance_leave']?.toString(),
      appBy: json['app_by']?.toString(),
      leaveDur: json['leave_dur'],
      leaveDuration: json['leave_duration']?.toString(),
      rejectReason: json['reject_reason']?.toString(),
      leaveStartDate: json['leave_start_date'],
      leaveEndDate: json['leave_end_date'],
      totalDays: json['total_days']?.toString(),
      reason: json['reason'],
      status: json['status'],
      appDate: json['app_date'],
      appliedDate: json['applied_date'],
      attachment: json['attachment'],
      del: json['del'],
      isD: json['is_d'],
      act: json['act'],
      dtime: json['dtime'] ?? "",
      employeeFullName: json['employee_full_name'] ?? "",
      empEmployeeCode: json['emp_employee_code']?.toString(),
      empDepartment: json['emp_department']?.toString(),
      empContactNumber: json['emp_contact_number']?.toString(),
    );
  }
}

class LeaveApi {
  static const String _baseUrl = "https://erpsmart.in/total/api/m_api/";

  static Future<LeaveRequestResponse> fetchLeaveRequests({String? reportingManager}) async {
    try {
      final params = await SharedPrefsUtil.getCommonParams();

      final Map<String, String> body = {
        'type': '2093',
        'cid': params['cid']!,
        'lt': params['lt']!,
        'ln': params['ln']!,
        'device_id': params['device_id']!,
        'token': params['token']!,
        'uid': params['uid']!,
        if (reportingManager != null && reportingManager.isNotEmpty)
          'reporting_manager': reportingManager,
      };

      final response = await http.post(Uri.parse(_baseUrl), body: body);
      if (response.statusCode == 200) {
        return LeaveRequestResponse.fromJson(jsonDecode(response.body));
      }
      throw Exception("Failed to load leave requests: ${response.statusCode}");
    } catch (e) {
      throw Exception("Error fetching leave requests: $e");
    }
  }

  static Future<Map<String, dynamic>> updateLeaveStatus({
    required String leaveId,
    required String status,
    String? rejectReason,
  }) async {
    try {
      final params = await SharedPrefsUtil.getCommonParams();
      final String adminUid = params['uid']!;

      final Map<String, String> body = {
        'type': '2090',
        'cid': params['cid']!,
        'lt': params['lt']!,
        'ln': params['ln']!,
        'device_id': params['device_id']!,
        'token': params['token']!,
        'form': 'sm_main_form_16112',
        'leave_id': leaveId,
        'uid': adminUid.isEmpty ? "0" : adminUid,
        'id': adminUid.isEmpty ? "0" : adminUid,
        'status': status,
        if (rejectReason != null) 'reject_reason': rejectReason,
      };

      final response = await http.post(Uri.parse(_baseUrl), body: body);
      return jsonDecode(response.body);
    } catch (e) {
      return {"error": true, "message": e.toString()};
    }
  }
}
