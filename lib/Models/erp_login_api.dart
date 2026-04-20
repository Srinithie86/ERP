import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class ErpLoginApi {
  static const String baseUrl = "https://erpsmart.in/total/api/m_api/";

  /// 1. Type 5001: Login with User ID & Password (Multipart/Form-Data)
  static Future<Map<String, dynamic>> loginWithUserPass({
    required String userId,
    required String password,
    required String deviceId,
    required String lat,
    required String lng,
    String cid = "44555666",
  }) async {
    debugPrint("\n================ LOGIN REQUEST (Type 5001) ================");
    debugPrint("URL: $baseUrl");
    
    try {
      var request = http.MultipartRequest('POST', Uri.parse(baseUrl));
      request.fields['type'] = '5001';
      request.fields['cid'] = cid;
      request.fields['user_id'] = userId;
      request.fields['password'] = password;
      request.fields['device_id'] = deviceId;
      request.fields['lt'] = lat;
      request.fields['ln'] = lng;

      debugPrint("FIELDS: ${request.fields}");

      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);
      
      final decoded = json.decode(response.body);
      debugPrint("\n================ LOGIN RESPONSE (Type 5001) ================");
      debugPrint("RESULT: $decoded");
      debugPrint("============================================================\n");
      return decoded;
    } catch (e) {
      debugPrint("ErpLoginApi => ERROR [Type 5001]: $e");
      return {"error": true, "message": "Connection Failed: $e"};
    }
  }

  /// 2. Type 5001: Send OTP for Mobile (Multipart/Form-Data)
  static Future<Map<String, dynamic>> sendOtp({
    required String mobile,
    required String cid,
    required String deviceId,
    required String lat,
    required String lng,
    String? appSignature,
  }) async {
    debugPrint("\n================ SEND OTP REQUEST (Type 5001) ================");
    debugPrint("URL: $baseUrl");

    try {
      var request = http.MultipartRequest('POST', Uri.parse(baseUrl));
      request.fields['type'] = '5001';
      request.fields['cid'] = cid.isEmpty ? "44555666" : cid;
      request.fields['mobile'] = mobile;
      request.fields['user_id'] = mobile; // Backend often needs both
      request.fields['device_id'] = deviceId;
      request.fields['lt'] = lat;
      request.fields['ln'] = lng;
      if (appSignature != null) {
        request.fields['app_signature'] = appSignature;
      }

      debugPrint("FIELDS: ${request.fields}");

      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);
      
      final decoded = json.decode(response.body);
      debugPrint("\n================ SEND OTP RESPONSE (Type 5001) ================");
      debugPrint("RESULT: $decoded");
      debugPrint("===================================================\n");
      return decoded;
    } catch (e) {
      debugPrint("ErpLoginApi => ERROR [Type 5001]: $e");
      return {"error": true, "message": "Connection Failed: $e"};
    }
  }

  /// 3. Type 5002: Verify OTP (Multipart/Form-Data)
  static Future<Map<String, dynamic>> verifyOtp({
    required String mobile,
    required String otp,
    required String cid,
    required String token,
    required String deviceId,
    required String lat,
    required String lng,
  }) async {
    debugPrint("\n================ VERIFY OTP REQUEST (Type 5002) ================");
    debugPrint("URL: $baseUrl");

    try {
      var request = http.MultipartRequest('POST', Uri.parse(baseUrl));
      request.fields['type'] = '5002';
      request.fields['cid'] = cid;
      request.fields['mobile'] = mobile;
      request.fields['otp'] = otp;
      request.fields['token'] = token;
      request.fields['device_id'] = deviceId;
      request.fields['lt'] = lat;
      request.fields['ln'] = lng;

      debugPrint("FIELDS: ${request.fields}");

      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);
      
      final decoded = json.decode(response.body);
      debugPrint("\n================ VERIFY OTP RESPONSE (Type 5002) ================");
      debugPrint("RESULT: $decoded");
      debugPrint("====================================================\n");
      return decoded;
    } catch (e) {
      debugPrint("ErpLoginApi => ERROR [Type 5002]: $e");
      return {"error": true, "message": "Connection Failed: $e"};
    }
  }

  /// 4. Type 5003: Fetch Menu
  static Future<Map<String, dynamic>> fetchMenu({
    required String cid,
    required String roleId,
    required String deviceId,
    required String lat,
    required String lng,
  }) async {
    try {
      var request = http.MultipartRequest('POST', Uri.parse(baseUrl));
      request.fields['type'] = '5003';
      request.fields['cid'] = cid;
      request.fields['role_id'] = roleId;
      request.fields['device_id'] = deviceId;
      request.fields['lt'] = lat;
      request.fields['ln'] = lng;

      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);
      return json.decode(response.body);
    } catch (e) {
      debugPrint("ErpLoginApi => ERROR [Type 5003]: $e");
      return {"error": true, "message": "Connection Failed"};
    }
  }

  /// 5. Type 5006: Switch Company / Fetch Linked Companies
  static Future<Map<String, dynamic>> switchCompany({
    required String uid,
    required String deviceId,
    required String lat,
    required String lng,
    String? token,
  }) async {
    try {
      var request = http.MultipartRequest('POST', Uri.parse(baseUrl));
      request.fields['type'] = '5006';
      request.fields['uid'] = uid;
      request.fields['device_id'] = deviceId;
      request.fields['lt'] = lat;
      request.fields['ln'] = lng;
      if (token != null) request.fields['token'] = token;

      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);
      return json.decode(response.body);
    } catch (e) {
      debugPrint("ErpLoginApi => ERROR [Type 5006]: $e");
      return {"error": true, "message": "Connection Failed: $e"};
    }
  }
}
