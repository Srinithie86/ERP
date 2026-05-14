import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:erp_smart/CRM-ERP-main/lib/Services/preference_service.dart';

class LeadApi {
  // --- REMOVED FOR REBINDING ---

  static Future<Map<String, dynamic>> addLead(Map<String, String> leadData) async {
    return {'error': false, 'message': 'API Binding required'};
  }

  static Future<List<dynamic>> fetchLeads() async {
    return [];
  }
}
