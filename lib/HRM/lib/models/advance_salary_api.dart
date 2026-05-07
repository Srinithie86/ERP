import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/api_client.dart';

class AdvanceSalaryApi {
  static final ApiClient _apiClient = ApiClient();

  /// ===============================
  /// GET EMPLOYEE ID
  /// ===============================
  static Future<String?> getEmployeeId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('uid') ?? 
           prefs.getString('login_cus_id') ?? 
           prefs.get('uid')?.toString();
  }

  /// ===============================
  /// SUBMIT ADVANCE SALARY REQUEST (Type: 2067)
  /// ===============================
  static Future<Map<String, dynamic>> submitAdvanceRequest({
    required String amount,
    required String reason,
    required String date,
    required String deviceId,
    required String lt,
    required String ln,
    required String employeeName,
    required String employeeCode,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final String? empId = await getEmployeeId();

    final Map<String, dynamic> body = {
      "type": "2082",
      "cid": (prefs.get('cid') ?? prefs.get('cid_str') ?? "").toString(),
      "uid": empId ?? "",
      "lt": lt,
      "ln": ln,
      "device_id": deviceId,
      "form": "sm_main_form_16322",
      "advance_amount": amount,
      "reason": reason,
      "employee_name": employeeName,
      "employee_id": employeeCode,
      "request_date": date,
    };

    try {
      final response = await _apiClient.post(body);
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        return {"error": true, "error_msg": "Server error: ${response.statusCode}"};
      }
    } catch (e) {
      debugPrint("ADVANCE REQUEST ERROR: $e");
      return {"error": true, "error_msg": e.toString()};
    }
  }

  /// ===============================
  /// GET ADVANCE HISTORY (Type: 2068)
  /// ===============================
  static Future<Map<String, dynamic>> getAdvanceHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final String? empId = await getEmployeeId();
    final String cid = (prefs.get('cid') ?? prefs.get('cid_str') ?? "").toString();
    final String deviceId = prefs.getString('device_id') ?? "";
    final String lat = (prefs.getDouble('lat') ?? 0.0).toString();
    final String lng = (prefs.getDouble('lng') ?? 0.0).toString();

    final Map<String, dynamic> body = {
      "type": "2083",
      "cid": cid,
      "uid": empId ?? "",
      "lt": lat,
      "ln": lng,
      "device_id": deviceId,
      "form": "sm_main_form_16322",
      "select": "*",
      "where": "uid=${empId ?? ''}",
    };

    try {
      final response = await _apiClient.post(body);
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        return {"error": true, "error_msg": "Server error: ${response.statusCode}"};
      }
    } catch (e) {
      debugPrint("ADVANCE HISTORY ERROR: $e");
      return {"error": true, "error_msg": e.toString()};
    }
  }
}
