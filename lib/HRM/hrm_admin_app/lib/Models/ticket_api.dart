import 'dart:convert';
import 'package:http/http.dart' as http;
import '../Utils/shared_prefs_util.dart';

class TicketResponse {
  final bool error;
  final String message;
  final int count;
  final List<TicketData> data;

  TicketResponse({
    required this.error,
    required this.message,
    required this.count,
    required this.data,
  });

  factory TicketResponse.fromJson(Map<String, dynamic> json) {
    var list = json['data'] as List? ?? [];
    List<TicketData> ticketList = list.map((i) => TicketData.fromJson(i)).toList();

    return TicketResponse(
      error: json['error'] ?? false,
      message: json['message'] ?? "",
      count: json['count'] ?? 0,
      data: ticketList,
    );
  }
}

class TicketData {
  final int id;
  final String employeeName;
  final String employeeId;
  final String department;
  final String complaintType;
  final String complaintDate;
  final String description;
  final String dtime;
  final String? status;
  final String? priority;

  TicketData({
    required this.id,
    required this.employeeName,
    required this.employeeId,
    required this.department,
    required this.complaintType,
    required this.complaintDate,
    required this.description,
    required this.dtime,
    this.status,
    this.priority,
  });

  factory TicketData.fromJson(Map<String, dynamic> json) {
    return TicketData(
      id: json['id'] ?? 0,
      employeeName: json['employee_name'] ?? "",
      employeeId: json['employee_id']?.toString() ?? "",
      department: json['department'] ?? "",
      complaintType: json['complaint_type'] ?? "",
      complaintDate: json['complaint_date'] ?? "",
      description: json['description'] ?? "",
      dtime: json['dtime'] ?? "",
      status: json['investigation_status']?.toString(),
      priority: json['priority']?.toString(),
    );
  }
}

class TicketApi {
  static const String _baseUrl = "https://erpsmart.in/total/api/m_api/";

  static Future<TicketResponse> fetchTickets() async {
    try {
      final params = await SharedPrefsUtil.getCommonParams();

      final Map<String, String> body = {
        'type': '2083',
        'cid': params['cid'] ?? '99994444',
        'lt': params['lt'] ?? '123',
        'ln': params['ln'] ?? '123',
        'device_id': params['device_id'] ?? '1237',
        'token': params['token'] ?? '',
        'form': 'sm_main_form_17321',
        'select': '*',
      };

      final response = await http.post(Uri.parse(_baseUrl), body: body);
      if (response.statusCode == 200) {
        return TicketResponse.fromJson(jsonDecode(response.body));
      }
      throw Exception("Failed to load tickets: ${response.statusCode}");
    } catch (e) {
      throw Exception("Error fetching tickets: $e");
    }
  }
}
