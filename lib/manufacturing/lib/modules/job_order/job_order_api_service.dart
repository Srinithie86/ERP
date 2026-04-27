import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'job_order_model.dart';

class JobOrderApiService {
  static const String _baseUrl = 'https://erpsmart.in/total/api/m_api/';

  static Future<List<DropdownItem>> fetchDropdown(String listId) async {
    try {
      final response = await http.post(
        Uri.parse(_baseUrl),
        body: {
          'type': '2084',
          'cid': '44555666',
          'lt': '123',
          'ln': '123',
          'device_id': '123',
          'list_id': listId,
        },
      );

      if (response.statusCode == 200) {
        debugPrint("Dropdown $listId response: ${response.body}");
        final Map<String, dynamic> data = json.decode(response.body);
        if (data['error'] == false && data['dropdown'] != null) {
          final List<dynamic> dropdownJson = data['dropdown'];
          return dropdownJson.map((json) => DropdownItem.fromJson(json)).toList();
        }
      }
    } catch (e) {
      debugPrint('Error fetching dropdown $listId: $e');
    }
    return [];
  }

  static Future<List<StaffMember>> fetchStaffSuggestions() async {
    try {
      final response = await http.post(
        Uri.parse(_baseUrl),
        body: {
          'type': '2083',
          'cid': '44555666',
          'lt': '123',
          'ln': '123',
          'device_id': '123',
          'form': 'sm_main_form_15521',
          'select': 'id,name',
          'where': 'department=1',
        },
      );

      if (response.statusCode == 200) {
        debugPrint("Staff response: ${response.body}");
        final Map<String, dynamic> data = json.decode(response.body);
        if (data['error'] == false && data['data'] != null) {
          final List<dynamic> staffJson = data['data'];
          return staffJson.map((json) => StaffMember.fromJson(json)).toList();
        }
      }
    } catch (e) {
      debugPrint('Error fetching staff suggestions: $e');
    }
    return [];
  }
}
