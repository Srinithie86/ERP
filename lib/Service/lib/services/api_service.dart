import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'device_service.dart';
import 'storage_service.dart';

class ApiService {
  static const String baseUrl = "https://erpsmart.in/total/api/m_api/";

  static Future<dynamic> login({
    required String mobile,
    required String lat,
    required String lon,
  }) async {
    String deviceId = await DeviceService.getDeviceId();

    var response = await http.post(
      Uri.parse(baseUrl),
      body: {
        "type": "5001",
        "lt": lat,
        "ln": lon,
        "device_id": deviceId,
        "mobile": mobile,
      },
    );

    print("LOGIN: ${response.body}");
    return jsonDecode(response.body);
  }

  // VERIFY (5002)
  static Future<dynamic> verifyOtp({
    required String mobile,
    required String otp,
    required String lat,
    required String lon,
    required String cid,
    required String token,
  }) async {
    String deviceId = await DeviceService.getDeviceId();

    var response = await http.post(
      Uri.parse(baseUrl),
      body: {
        "type": "5002",
        "lt": lat,
        "ln": lon,
        "device_id": deviceId,
        "mobile": mobile,
        "cid": cid,
        "otp": otp,
        "token": token,
      },
    );

    print("VERIFY: ${response.body}");
    return jsonDecode(response.body);
  }

  // ALL TICKETS (5021)
  static Future<dynamic> getTickets({
    required String cid,
    required String uid,
    required String roleId,
    required String token,
    required String lat,
    required String lon,
  }) async {
    String deviceId = await DeviceService.getDeviceId();

    var response = await http.post(
      Uri.parse(baseUrl),
      body: {
        "type": "5021",
        "cid": cid,
        "uid": uid,
        "role_id": roleId,
        "token": token,
        "device_id": deviceId,
        "lt": lat,
        "ln": lon,
      },
    );

    print("GET TICKETS (5021): ${response.body}");

    return await compute(jsonDecode, response.body);
  }

  // PRIORITY DROPDOWN (2084)
  static Future<dynamic> getPriorityDropdown() async {
    String deviceId = await DeviceService.getDeviceId();
    String cid = await StorageService.getCid() ?? "";

    var response = await http.post(
      Uri.parse(baseUrl),
      body: {
        "type": "2084",
        "cid": cid,
        "lt": "123",
        "ln": "123",
        "device_id": deviceId,
        "list_id": "10106",
      },
    );

    print("PRIORITY DROPDOWN (2084): ${response.body}");
    return jsonDecode(response.body);
  }

  // ENGINEER DROPDOWN (2083)
  static Future<dynamic> getEngineerDropdown() async {
    String deviceId = await DeviceService.getDeviceId();
    String cid = await StorageService.getCid() ?? "";

    var response = await http.post(
      Uri.parse(baseUrl),
      body: {
        "type": "2083",
        "cid": cid,
        "lt": "123",
        "ln": "123",
        "device_id": deviceId,
        "form": "sm_main_form_10002",
        "select": "Ledger_Name,id",
        "where": "category=2",
      },
    );

    print("ENGINEER DROPDOWN (2083): ${response.body}");
    return jsonDecode(response.body);
  }

  // ASSIGN TICKET (5022)
  static Future<dynamic> assignTicket({
    required String ticketId,
    required String engineerId,
    required String priority,
  }) async {
    String deviceId = await DeviceService.getDeviceId();
    String cid = await StorageService.getCid() ?? "";
    String uid = await StorageService.getUid() ?? "";
    String roleId = await StorageService.getRoleId() ?? "";
    String token = await StorageService.getToken() ?? "";

    var response = await http.post(
      Uri.parse(baseUrl),
      body: {
        "type": "5022",
        "cid": cid,
        "id": ticketId,
        "engineer_id": engineerId,
        "priority": priority,
        "uid": uid,
        "role_id": roleId,
        "token": token,
        "device_id": deviceId,
        "lt": "34",
        "ln": "12",
      },
    );

    print("ASSIGN TICKET (5022): ${response.body}");
    return jsonDecode(response.body);
  }

  // SPARES DATA (5023)
  static Future<dynamic> getSparesData({
    required String cid,
    required String uid,
    required String roleId,
    required String token,
    required String engineerId,
    required String lat,
    required String lon,
  }) async {
    String deviceId = await DeviceService.getDeviceId();

    var response = await http.post(
      Uri.parse(baseUrl),
      body: {
        "type": "5023",
        "cid": cid,
        "uid": uid,
        "role_id": roleId,
        "token": token,
        "engineer_id": engineerId,
        "device_id": deviceId,
        "lt": lat,
        "ln": lon,
      },
    );

    print("GET SPARES DATA (5023): ${response.body}");
    return await compute(jsonDecode, response.body);
  }

  // GET JOBS (5012)
  static Future<dynamic> getJobs({
    required String cid,
    required String uid,
    required String engineerId,
    required String roleId,
    required String token,
    required String lat,
    required String lon,
  }) async {
    String deviceId = await DeviceService.getDeviceId();

    var response = await http.post(
      Uri.parse(baseUrl),
      body: {
        "type": "5012",
        "cid": cid,
        "uid": uid,
        "engineer_id": engineerId,
        "role_id": roleId,
        "token": token,
        "device_id": deviceId,
        "lt": lat,
        "ln": lon,
      },
    );

    print("GET JOBS (5012): ${response.body}");
    return await compute(jsonDecode, response.body);
  }

  // UPDATE JOB STATUS (5026)
  static Future<dynamic> updateJobStatus({
    required String jobId,
    required String status,
  }) async {
    String deviceId = await DeviceService.getDeviceId();
    String cid = await StorageService.getCid() ?? "";
    String uid = await StorageService.getUid() ?? "";
    String roleId = await StorageService.getRoleId() ?? "";
    String token = await StorageService.getToken() ?? "";

    var response = await http.post(
      Uri.parse(baseUrl),
      body: {
        "type": "5026",
        "cid": cid,
        "uid": uid,
        "token": token,
        "role_id": roleId,
        "device_id": deviceId,
        "lt": "123",
        "ln": "987",
        "id": jobId,
        "status": status,
      },
    );

    print("UPDATE JOB STATUS (5026) ID $jobId to $status: ${response.body}");
    return jsonDecode(response.body);
  }

  // SPARES HISTORY / DETAILS (5017)
  static Future<dynamic> getSparesHistory({
    required String cid,
    required String uid,
    required String roleId,
    required String token,
    required String engineerId,
  }) async {
    String deviceId = await DeviceService.getDeviceId();

    var response = await http.post(
      Uri.parse(baseUrl),
      body: {
        "type": "5017",
        "cid": cid,
        "uid": uid,
        "role_id": roleId,
        "token": token,
        "engineer_id": engineerId,
        "device_id": deviceId,
        "lt": "123",
        "ln": "987",
      },
    );

    print("GET SPARES HISTORY (5017): ${response.body}");
    return jsonDecode(response.body);
  }

  // ASSIGN STANDBY (5030)
  static Future<dynamic> assignStandby({
    required String ticketId,
    required String customerId,
    required String returnDate,
    required String issueDate,
    required String standbyId,
    required String charges,
  }) async {
    String deviceId = await DeviceService.getDeviceId();
    String cid = await StorageService.getCid() ?? "";
    String uid = await StorageService.getUid() ?? "";
    String roleId = await StorageService.getRoleId() ?? "";
    String token = await StorageService.getToken() ?? "";
    String engineerId = await StorageService.getEngineerId() ?? "";

    var response = await http.post(
      Uri.parse(baseUrl),
      body: {
        "type": "5030",
        "cid": cid,
        "uid": uid,
        "role_id": roleId,
        "token": token,
        "device_id": deviceId,
        "engineer_id": engineerId,
        "lt": "123",
        "ln": "987",
        "ticket_id": ticketId,
        "customer_id": customerId,
        "return_date": returnDate,
        "issue_date": issueDate,
        "standby_id": standbyId,
        "charges": charges,
      },
    );

    print(
      "ASSIGN STANDBY (5030) BODY: ticket_id=$ticketId, customer_id=$customerId, standby_id=$standbyId",
    );
    print("ASSIGN STANDBY (5030) RESPONSE: ${response.body}");
    return jsonDecode(response.body);
  }

  // GET STANDBY TICKETS (5025)
  static Future<dynamic> getStandbyTickets() async {
    String deviceId = await DeviceService.getDeviceId();
    String cid = await StorageService.getCid() ?? "";
    String uid = await StorageService.getUid() ?? "";
    String roleId = await StorageService.getRoleId() ?? "";
    String token = await StorageService.getToken() ?? "";

    var response = await http.post(
      Uri.parse(baseUrl),
      body: {
        "type": "5025",
        "cid": cid,
        "uid": uid,
        "role_id": roleId,
        "token": token,
        "device_id": deviceId,
        "lt": "123",
        "ln": "987",
      },
    );

    print("GET STANDBY TICKETS (5025): ${response.body}");
    return jsonDecode(response.body);
  }

  // GET TICKET DETAILS (5027)
  static Future<dynamic> getTicketDetails(String search) async {
    String deviceId = await DeviceService.getDeviceId();
    String cid = await StorageService.getCid() ?? "";
    String uid = await StorageService.getUid() ?? "";
    String roleId = await StorageService.getRoleId() ?? "";
    String token = await StorageService.getToken() ?? "";

    var response = await http.post(
      Uri.parse(baseUrl),
      body: {
        "type": "5027",
        "cid": cid,
        "uid": uid,
        "role_id": roleId,
        "token": token,
        "device_id": deviceId,
        "lt": "123",
        "ln": "987",
        "search": search,
      },
    );

    print("GET TICKET DETAILS (5027): ${response.body}");
    return jsonDecode(response.body);
  }

  // GET CUSTOMER SUGGESTIONS (5028)
  static Future<dynamic> getCustomerSuggestions(String query) async {
    String deviceId = await DeviceService.getDeviceId();
    String cid = await StorageService.getCid() ?? "";
    String uid = await StorageService.getUid() ?? "";
    String roleId = await StorageService.getRoleId() ?? "";
    String token = await StorageService.getToken() ?? "";

    var response = await http.post(
      Uri.parse(baseUrl),
      body: {
        "type": "5028",
        "cid": cid,
        "uid": uid,
        "role_id": roleId,
        "token": token,
        "device_id": deviceId,
        "lt": "123",
        "ln": "987",
        "search": query,
      },
    );

    print("GET CUSTOMER SUGGESTIONS (5028): ${response.body}");
    return jsonDecode(response.body);
  }

  // GET AVAILABLE BREAKERS (5029)
  static Future<dynamic> getAvailableBreakers() async {
    String deviceId = await DeviceService.getDeviceId();
    String cid = await StorageService.getCid() ?? "";
    String uid = await StorageService.getUid() ?? "";
    String roleId = await StorageService.getRoleId() ?? "";
    String token = await StorageService.getToken() ?? "";

    var response = await http.post(
      Uri.parse(baseUrl),
      body: {
        "type": "5029",
        "cid": cid,
        "uid": uid,
        "role_id": roleId,
        "token": token,
        "device_id": deviceId,
        "lt": "123",
        "ln": "987",
      },
    );

    print("GET AVAILABLE BREAKERS (5029): ${response.body}");
    return jsonDecode(response.body);
  }
}
