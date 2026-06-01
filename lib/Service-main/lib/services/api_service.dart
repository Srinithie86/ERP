import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:dio/dio.dart' as dio_pkg;
import 'package:shared_preferences/shared_preferences.dart';
import 'device_service.dart';
import 'storage_service.dart';

class ApiService {
  static const String _defaultBaseUrl = "https://erpsmart.in/total/api/m_api/";

  static Future<String> getBaseUrl() async {
    final prefs = await SharedPreferences.getInstance();
    String? url = prefs.getString("company_domain_url");
    if (url == null || url.isEmpty) return _defaultBaseUrl;

    // Normalize URL
    if (!url.startsWith("http")) url = "https://$url";
    if (!url.endsWith("/")) url = "$url/";
    if (!url.endsWith("api/m_api/")) {
      if (url.endsWith("api/"))
        url = "${url}m_api/";
      else
        url = "${url}api/m_api/";
    }
    return url;
  }

  static String get baseUrl => _defaultBaseUrl; // Legacy support

  static Future<dynamic> login({
    required String mobile,
    required String lat,
    required String lon,
  }) async {
    String deviceId = await DeviceService.getDeviceId();
    print("DEVICE ID: $deviceId");

    var response = await http.post(
      Uri.parse(await getBaseUrl()),
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
      Uri.parse(await getBaseUrl()),
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
      Uri.parse(await getBaseUrl()),
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
      Uri.parse(await getBaseUrl()),
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
      Uri.parse(await getBaseUrl()),
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
    String locationVerify = "No",
    String warranty = "No",
    String approxCharge = "",
    String expense = "",
  }) async {
    String deviceId = await DeviceService.getDeviceId();
    String cid = await StorageService.getCid() ?? "";
    String uid = await StorageService.getUid() ?? "";
    String roleId = await StorageService.getRoleId() ?? "";
    String token = await StorageService.getToken() ?? "";

    final baseUrl = await getBaseUrl();
    final body = {
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
      "locat_verify": locationVerify,
      "waranty": warranty,
      "apro_change": approxCharge,
      "expence": expense,
    };

    debugPrint("\n========== ASSIGN TICKET REQUEST (5022) ==========");
    debugPrint("URL: $baseUrl");
    debugPrint("FIELDS: $body");

    var response = await http.post(Uri.parse(baseUrl), body: body);

    debugPrint("========== ASSIGN TICKET RESPONSE (5022) ==========");
    debugPrint("RESULT: ${response.body}");
    debugPrint("===================================================\n");
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
      Uri.parse(await getBaseUrl()),
      body: {
        "type": "5023",
        "cid": cid,
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

  static List<dynamic>? _cachedJobs;

  // GET JOBS (5012)
  static Future<dynamic> getJobs({
    required String cid,
    required String uid,
    required String engineerId,
    required String roleId,
    required String token,
    required String lat,
    required String lon,
    bool ignoreCache = false,
  }) async {
    String deviceId = await DeviceService.getDeviceId();

    Map<String, String> body = {
      "type": "5012",
      "cid": cid,
      "led_id": engineerId,
      "engineer_id": engineerId,
      "cus_id": engineerId,
      "role_id": roleId,
      "token": token,
      "device_id": deviceId,
      "lt": lat,
      "ln": lon,
      "date": "all",
    };
    print("Job request : $body`");

    if (_cachedJobs != null && !ignoreCache) {
      _fetchAndCacheJobs(body);
      return {"error": false, "records": _cachedJobs, "isCache": true};
    }

    var response = await http.post(Uri.parse(await getBaseUrl()), body: body);

    print("GET JOBS (5012): ${response.body}");
    var decoded = await compute(jsonDecode, response.body);

    if (decoded != null && decoded["error"] == false) {
      _cachedJobs = decoded["records"];
      decoded["isCache"] = false;
    }

    return decoded;
  }

  static void _fetchAndCacheJobs(Map<String, String> body) async {
    try {
      var response = await http.post(Uri.parse(await getBaseUrl()), body: body);
      var decoded = await compute(jsonDecode, response.body);
      if (decoded != null && decoded["error"] == false) {
        _cachedJobs = decoded["records"];
      }
    } catch (e) {
      print("Background jobs cache update failed: $e");
    }
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
      Uri.parse(await getBaseUrl()),
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

  static Future<dynamic> getSparesHistory({
    required String cid,
    required String uid,
    required String roleId,
    required String token,
    required String engineerId,
  }) async {
    String deviceId = await DeviceService.getDeviceId();

    var response = await http.post(
      Uri.parse(await getBaseUrl()),
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
      Uri.parse(await getBaseUrl()),
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
      Uri.parse(await getBaseUrl()),
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

  // GET STANDBY SCREEN DATA (5033)
  static Future<dynamic> getStandbyScreenData() async {
    String deviceId = await DeviceService.getDeviceId();
    String cid = await StorageService.getCid() ?? "";
    String uid = await StorageService.getUid() ?? "";
    String roleId = await StorageService.getRoleId() ?? "";
    String token = await StorageService.getToken() ?? "";
    String engineerId = await StorageService.getEngineerId() ?? "";
    String cusId = await StorageService.getCusId() ?? "";

    var response = await http.post(
      Uri.parse(await getBaseUrl()),
      body: {
        "type": "5033",
        "cid": cid,
        "uid": uid,
        "role_id": roleId,
        "token": token,
        "engineer_id": engineerId,
        "cus_id": cusId,
        "device_id": deviceId,
        "lt": "123",
        "ln": "123",
      },
    );

    print("GET STANDBY SCREEN DATA (5033): ${response.body}");
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
      Uri.parse(await getBaseUrl()),
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
      Uri.parse(await getBaseUrl()),
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
      Uri.parse(await getBaseUrl()),
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

  static List<dynamic>? _cachedDispatch;
  static int _cachedTotal = 0;

  // ALL DISPATCH (5031)
  static Future<dynamic> getDispatchData({String? date}) async {
    String deviceId = await DeviceService.getDeviceId();
    String cid = await StorageService.getCid() ?? "";
    String uid = await StorageService.getUid() ?? "";
    String roleId = await StorageService.getRoleId() ?? "";
    String token = await StorageService.getToken() ?? "";
    String engineerId = await StorageService.getEngineerId() ?? "";

    Map<String, String> body = {
      "type": "5031",
      "cid": cid,
      "uid": uid,
      "role_id": roleId,
      "token": token,
      "engineer_id": engineerId,
      "device_id": deviceId,
      "lt": "145",
      "ln": "145",
    };

    if (date != null && date.isNotEmpty) {
      body["date"] = date;
    }

    if (date == null && _cachedDispatch != null) {
      _fetchAndCacheDispatch(body);
      return {"error": false, "total": _cachedTotal, "data": _cachedDispatch};
    }

    var response = await http.post(Uri.parse(await getBaseUrl()), body: body);

    print("GET DISPATCH DATA (5031): ${response.body}");
    var decoded = await compute(jsonDecode, response.body);

    if (date == null && decoded != null && decoded["error"] == false) {
      _cachedDispatch = decoded["data"];
      _cachedTotal = decoded["total"] is int
          ? decoded["total"]
          : int.tryParse(decoded["total"].toString()) ?? 0;
    }

    return decoded;
  }

  static void _fetchAndCacheDispatch(Map<String, String> body) async {
    try {
      var response = await http.post(Uri.parse(await getBaseUrl()), body: body);
      var decoded = await compute(jsonDecode, response.body);
      if (decoded != null && decoded["error"] == false) {
        _cachedDispatch = decoded["data"];
        _cachedTotal = decoded["total"] is int
            ? decoded["total"]
            : int.tryParse(decoded["total"].toString()) ?? 0;
      }
    } catch (e) {
      print("Background cache update failed: $e");
    }
  }

  // VERIFY HAPPY CODE (5032)
  static Future<dynamic> verifyHappyCode({
    required String complaintId,
    required String otp,
  }) async {
    String deviceId = await DeviceService.getDeviceId();
    String cid = await StorageService.getCid() ?? "";
    String uid = await StorageService.getUid() ?? "";
    String roleId = await StorageService.getRoleId() ?? "";
    String token = await StorageService.getToken() ?? "";

    var response = await http.post(
      Uri.parse(await getBaseUrl()),
      body: {
        "type": "5032",
        "cid": cid,
        "uid": uid,
        "token": token,
        "role_id": roleId,
        "device_id": deviceId,
        "lt": "145",
        "ln": "145",
        "complaint_id": complaintId,
        "otp": otp,
      },
    );

    print("VERIFY HAPPY CODE (5032) RESP: ${response.body}");
    return jsonDecode(response.body);
  }

  // SUBMIT EOD REPORT (5038)
  static Future<dynamic> submitEodReport({
    required String date,
    required String eodReport,
  }) async {
    String deviceId = await DeviceService.getDeviceId();
    String cid = await StorageService.getCid() ?? "";
    String uid = await StorageService.getUid() ?? "";
    String roleId = await StorageService.getRoleId() ?? "";
    String token = await StorageService.getToken() ?? "";
    String engineerId = await StorageService.getEngineerId() ?? "";
    String name = await StorageService.getName() ?? "";

    var response = await http.post(
      Uri.parse(await getBaseUrl()),
      body: {
        "type": "5038",
        "cid": cid,
        "uid": uid,
        "role_id": roleId,
        "token": token,
        "device_id": deviceId,
        "eng_id": engineerId,
        "name": name,
        "date": date,
        "eod_report": eodReport,
        "lt": "22",
        "ln": "22",
      },
    );

    print("SUBMIT EOD REPORT (5038) RESP: ${response.body}");
    return jsonDecode(response.body);
  }

  // GET EVALUATION REPORT (5037)
  static Future<dynamic> getEvaluationReport() async {
    String deviceId = await DeviceService.getDeviceId();
    String cid = await StorageService.getCid() ?? "";
    String uid = await StorageService.getUid() ?? "";
    String roleId = await StorageService.getRoleId() ?? "";
    String token = await StorageService.getToken() ?? "";
    String engineerId = await StorageService.getEngineerId() ?? "";

    var response = await http.post(
      Uri.parse(await getBaseUrl()),
      body: {
        "type": "5037",
        "cid": cid,
        "uid": uid,
        "role_id": roleId,
        "token": token,
        "device_id": deviceId,
        "engineer_id": engineerId,
        "lt": "145",
        "ln": "145",
      },
    );

    print("GET EVALUATION REPORT (5037) RESP: ${response.body}");
    return jsonDecode(response.body);
  }

  static Future<dynamic> requestSpares({
    required String ticketId,
    required String cusId,
    required String customerName,
    required String address,
    required List<Map<String, String>> items,
  }) async {
    final dio = dio_pkg.Dio();
    String deviceId = await DeviceService.getDeviceId();
    String cid = await StorageService.getCid() ?? "";
    String uid = await StorageService.getUid() ?? "";
    String roleId = await StorageService.getRoleId() ?? "";
    String token = await StorageService.getToken() ?? "";
    final String encodedItems = jsonEncode(items);

    final Map<String, String> body = {
      "type": "5036",
      "cid": cid,
      "uid": uid,
      "role_id": roleId,
      "token": token,
      "device_id": deviceId,
      "lt": "123",
      "ln": "987",
      "ticket_id": ticketId,
      "cus_id": cusId,
      "customer_id": customerName,
      "customer_name": customerName,
      "address": address,
      "items": encodedItems,
    };

    print("REQUEST SPARES (5036) SENDING BODY: $body");

    try {
      final response = await dio.post(
        await getBaseUrl(),
        data: dio_pkg.FormData.fromMap(body),
      );

      print("REQUEST SPARES (5036) RESP: ${response.data}");
      return response.data;
    } catch (e) {
      print("REQUEST SPARES (5036) ERROR: $e");
      return {"error": true, "message": e.toString()};
    }
  }
}
