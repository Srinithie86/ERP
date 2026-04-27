import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:manufacturing_erp/modules/bom/bom_model.dart';
import 'widgets/bom_form_widgets.dart';

class BomProductSuggestion {
  final String name;
  final String code;

  BomProductSuggestion({required this.name, required this.code});

  factory BomProductSuggestion.fromJson(Map<String, dynamic> json) {
    return BomProductSuggestion(
      name: json['product_name'] ?? '',
      code: json['product_code'] ?? '',
    );
  }
}



class BomApiService {
  static const String _baseUrl = 'https://erpsmart.in/total/api/m_api/';

  static Future<List<BomProductSuggestion>> getSuggestions(
      {int subType = 2}) async {
    try {
      final response = await http.post(
        Uri.parse(_baseUrl),
        body: {
          'type': '2083',
          'cid': '44555666',
          'lt': '123',
          'ln': '123',
          'device_id': '123',
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
              .map((json) => BomProductSuggestion.fromJson(json))
              .toList();
        }
      }
    } catch (e) {
      print('Error fetching product suggestions: $e');
    }
    return [];
  }

  static Future<List<BomItem>> fetchBoms() async {
    try {
      final response = await http.post(
        Uri.parse(_baseUrl),
        body: {
          'type': '2083',
          'cid': '44555666',
          'lt': '123',
          'ln': '123',
          'device_id': '123',
          'form': 'sm_main_form_30221',
          'select': '*',
        },
      );

      if (response.statusCode == 200) {
        debugPrint("bom list ${response.body}");
        final Map<String, dynamic> data = json.decode(response.body);
        if (data['error'] == false && data['data'] != null) {
          final List<dynamic> listJson = data['data'];
          return listJson.map((json) => BomItem.fromJson(json)).toList();
        }
      }
    } catch (e) {
      print('Error fetching BOMs: $e');
    }
    return [];
  }

  static Future<List<BomMaterial>> fetchBomComponents(String bomId) async {
    try {
      final response = await http.post(
        Uri.parse(_baseUrl),
        body: {
          'type': '2083',
          'cid': '44555666',
          'lt': '123',
          'ln': '123',
          'device_id': '123',
          'form': 'sm_main_form_30221_1',
          'select': '*',
          'where': 'mid=$bomId',
        },
      );

      if (response.statusCode == 200) {
        debugPrint("bom components ${response.body}");
        final Map<String, dynamic> data = json.decode(response.body);
        if (data['error'] == false && data['data'] != null) {
          final List<dynamic> listJson = data['data'];
          return listJson.map((json) => BomMaterial.fromJson(json)).toList();
        }
      }
    } catch (e) {
      print('Error fetching BOM components: $e');
    }
    return [];
  }

  static Future<Map<String, dynamic>> saveBom({
    required String productName,
    required String productCode,
    required String category,
    required String version,
    required String uom,
    required List<BomEditableRow> rows,
  }) async {
    try {
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
          'cid': '44555666',
          'uid': '1',
          'token': 'jkhfxxv',
          'prd_name': productName,
          'prd_code': productCode,
          'catry': category,
          'modl': '',
          'version': version,
          'uom': uom,
          'products': json.encode(productsList),
          'device_id': 'abc123xyz',
          'ln': '23',
          'lt': '65',
        },
      );

      if (response.statusCode == 200) {
        debugPrint("bom insert ${response.body}");
        return json.decode(response.body);
      }
    } catch (e) {
      print('Error saving BOM: $e');
    }
    return {'error': true, 'message': 'Connection error'};
  }
}
