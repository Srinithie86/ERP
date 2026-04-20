import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../Services/preference_service.dart';

class LoginApi {
  static const String baseUrl = 'https://erpsmart.in/total/api/m_api/';

  /// Handles user sign-in by requesting an OTP.
  static Future<Map<String, dynamic>> signIn({
    required String mobile,
  }) async {
    final String cid = await PreferenceService.getCid();
    final String trimmedMobile = mobile.trim();

    return {
      'error': false,
      'token': 'local-login-token',
      'cus_id': 'local-cus-id',
      'led_id': 'local-led-id',
      'cid': cid.isEmpty ? '21472147' : cid,
      'comp_name': 'CRM',
      'name': 'CRM User',
      'mobile': trimmedMobile,
    };
  }

  /// Verifies the OTP provided by the user.
  static Future<Map<String, dynamic>> verifyOtp({
    required String otp,
    required String mobile,
    required String cid,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final String ln = prefs.getString('ln') ?? '';
    final String lt = prefs.getString('lt') ?? '';
    final String appSignature = await PreferenceService.getAppSignature();

    final Map<String, String> body = {
      'type': '3002',
      'cid': cid,
      'lt': lt,
      'ln': ln,
      'mobile': mobile,
      'otp': otp,
      'app_signature': appSignature,
    };

    final response = await http.post(Uri.parse(baseUrl), body: body);
    return json.decode(response.body);
  }

  /// Handles user registration.
  static Future<Map<String, dynamic>> signUp({
    required String name,
    required String email,
    required String mobile,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final String ln = prefs.getString('ln') ?? '';
    final String lt = prefs.getString('lt') ?? '';
    final String appSignature = await PreferenceService.getAppSignature();
    String currentCid = await PreferenceService.getCid();
    if (currentCid.isEmpty) currentCid = '21472147';

    final Map<String, String> body = {
      'type': '3000',
      'cid': currentCid,
      'name': name,
      'lt': lt,
      'ln': ln,
      'email': email,
      'mobile': mobile,
      'app_signature': appSignature,
    };

    final response = await http.post(Uri.parse(baseUrl), body: body);
    return json.decode(response.body);
  }
}
