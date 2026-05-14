import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:erp_smart/CRM-ERP-main/lib/Services/preference_service.dart';

class ReferralApi {
  // --- REMOVED FOR REBINDING ---

  static Future<Map<String, dynamic>> addReferral(Map<String, String> data) async {
    return {'error': false, 'message': 'API Binding required'};
  }

  static Future<List<dynamic>> fetchReferrals() async {
    return [];
  }
}
