import 'dart:convert';
import 'package:http/http.dart' as http;
import '../Utils/shared_prefs_util.dart';

class ExpenseApi {
  static const String _baseUrl = "https://erpsmart.in/total/api/m_api/";

  static Future<Map<String, dynamic>> fetchExpenseRequests({String? reportingManager}) async {
    try {
      final params = await SharedPrefsUtil.getCommonParams();

      final Map<String, String> body = {
        'type': '2095',
        'cid': params['cid']!,
        'lt': params['lt']!,
        'ln': params['ln']!,
        'device_id': params['device_id']!,
        'token': params['token']!,
        'uid': params['uid']!,
        if (reportingManager != null && reportingManager.isNotEmpty)
          'reporting_manager': reportingManager,
      };

      print("Expense Request body: $body");

      final response = await http.post(
        Uri.parse(_baseUrl),
        body: body,
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> decoded = jsonDecode(response.body);
        
        // Handle new team_expenses structure
        if (decoded.containsKey('team_expenses')) {
          final teamExp = decoded['team_expenses'];
          return {
            "error": decoded['error'] ?? false,
            "data": teamExp['data'] ?? [],
            "summary": teamExp['summary'],
            "message": decoded['message'] ?? ""
          };
        }
        
        return decoded;
      } else {
        return {"error": true, "message": "Failed to load expenses: ${response.statusCode}"};
      }
    } catch (e) {
      print("Error fetching expense requests: $e");
      return {"error": true, "message": e.toString()};
    }
  }

  // Updated status API for expense
  static Future<Map<String, dynamic>> updateExpenseStatus({
    required String expenseId,
    required String status,
    String? amount,
    String? reason,
  }) async {
    try {
      final params = await SharedPrefsUtil.getCommonParams();

      final Map<String, String> body = {
        'type': '2085', // Updated type as per user request
        'cid': params['cid']!,
        'lt': params['lt']!,
        'ln': params['ln']!,
        'device_id': params['device_id']!,
        'token': params['token']!,
        'form': 'sm_main_form_16521',
        'id': expenseId,
        'uid': params['uid']!,
        'status': status,
        if (amount != null) 'approved_amt': amount, // Updated parameter name
        if (reason != null) 'reject_reason': reason,
      };

      print("Update Expense body: $body");

      final response = await http.post(
        Uri.parse(_baseUrl),
        body: body,
      );

      return jsonDecode(response.body);
    } catch (e) {
      return {"error": true, "message": e.toString()};
    }
  }
}
