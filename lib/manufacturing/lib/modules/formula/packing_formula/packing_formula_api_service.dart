import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:manufacturing_erp/modules/formula/packing_formula/packing_formula_model.dart';
import 'widgets/packing_formula_form_widgets.dart';

class PackingFormulaProductSuggestion {
  final String name;
  final String code;

  PackingFormulaProductSuggestion({required this.name, required this.code});

  factory PackingFormulaProductSuggestion.fromJson(Map<String, dynamic> json) {
    return PackingFormulaProductSuggestion(
      name: json['product_name'] ?? '',
      code: json['product_code'] ?? '',
    );
  }
}



class PackingFormulaApiService {
  static const String _baseUrl = 'https://erpsmart.in/total/api/m_api/';

  static Future<List<PackingFormulaProductSuggestion>> getSuggestions(
      {int subType = 2}) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final response = await http.post(
        Uri.parse(_baseUrl),
        body: {
          'type': '2083',
          'cid': prefs.getString('cid') ?? '44555666',
          'lt': prefs.getString('lt') ?? '123',
          'ln': prefs.getString('ln') ?? '123',
          'device_id': prefs.getString('device_id') ?? '123',
          'form': 'sm_main_form_10106',
          'select': '*',
          'where': 'sub_type=$subType',
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);

        if (data['error'] == false && data['data'] != null) {
          final List<dynamic> productsJson = data['data'];
          return productsJson
              .map((json) => PackingFormulaProductSuggestion.fromJson(json))
              .toList();
        }
      }
    } catch (e) {
      print('Error fetching product suggestions: $e');
    }
    return [];
  }

  static Future<List<PackingFormulaItem>> fetchPackingFormulas() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final response = await http.post(
        Uri.parse(_baseUrl),
        body: {
          'type': '2083',
          'cid': prefs.getString('cid') ?? '44555666',
          'lt': prefs.getString('lt') ?? '123',
          'ln': prefs.getString('ln') ?? '123',
          'device_id': prefs.getString('device_id') ?? '123',
          'form': 'sm_main_form_39033',
          'select': '*',
        },
      );

      if (response.statusCode == 200) {
        debugPrint("bom list ${response.body}");
        final Map<String, dynamic> data = json.decode(response.body);
        if (data['error'] == false && data['data'] != null) {
          final List<dynamic> listJson = data['data'];
          return listJson.map((json) => PackingFormulaItem.fromJson(json)).toList();
        }
      }
    } catch (e) {
      print('Error fetching Packing Formulas: $e');
    }
    return [];
  }

  static Future<List<PackingFormulaMaterial>> fetchPackingFormulaComponents(String packingFormulaId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final response = await http.post(
        Uri.parse(_baseUrl),
        body: {
          'type': '2083',
          'cid': prefs.getString('cid') ?? '44555666',
          'lt': prefs.getString('lt') ?? '123',
          'ln': prefs.getString('ln') ?? '123',
          'device_id': prefs.getString('device_id') ?? '123',
          'form': 'sm_main_form_30221_1',
          'select': '*',
          'where': 'mid=$packingFormulaId',
        },
      );

      if (response.statusCode == 200) {
        debugPrint("bom components ${response.body}");
        final Map<String, dynamic> data = json.decode(response.body);
        if (data['error'] == false && data['data'] != null) {
          final List<dynamic> listJson = data['data'];
          return listJson.map((json) => PackingFormulaMaterial.fromJson(json)).toList();
        }
      }
    } catch (e) {
      print('Error fetching Packing Formula components: $e');
    }
    return [];
  }

  static Future<Map<String, dynamic>> savePackingFormula({
    required String productName,
    required String productCode,
    required String category,
    required String version,
    required String uom,
    required List<PackingFormulaEditableRow> rows,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final List<Map<String, dynamic>> productsList = rows.map((row) {
        return {
          "itm_code": row.itemCodeCtrl.text,
          "components": row.nameCtrl.text,
          "category": category,
          "qty": double.tryParse(row.qtyCtrl.text) ?? 0,
          "totl_qty": double.tryParse(row.qtyCtrl.text) ?? 0,
          "uom": row.uom,
          "um": row.uom,
          "sze": ""
        };
      }).toList();

      final response = await http.post(
        Uri.parse(_baseUrl),
        body: {
          'type': '9002',
          'cid': prefs.getString('cid') ?? '44555666',
          'uid': prefs.getString('uid') ?? '1',
          'token': prefs.getString('token') ?? 'jkhfxxv',
          'prd_name': productName,
          'prd_code': productCode,
          'catry': category,
          'modl': '',
          'version': version,
          'uom': uom,
          'products': json.encode(productsList),
          'device_id': prefs.getString('device_id') ?? 'abc123xyz',
          'ln': prefs.getString('ln') ?? '23',
          'lt': prefs.getString('lt') ?? '65',
        },
      );

      if (response.statusCode == 200) {
        debugPrint("bom insert ${response.body}");
        return json.decode(response.body);
      }
    } catch (e) {
      print('Error saving Packing Formula: $e');
    }
    return {'error': true, 'message': 'Connection error'};
  }
}
