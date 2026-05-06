import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:manufacturing_erp/core/api_config.dart';
import 'production_order_model.dart';

class ProductionOrderFetchResult {
  final List<ProductionOrder> orders;
  final int total;
  ProductionOrderFetchResult({required this.orders, required this.total});
}

class ProductionOrderApiService {
  
  static List<Map<String, dynamic>>? _cachedBoms;
  static List<StaffMember>? _cachedStaff;
  static List<Map<String, dynamic>>? _cachedCustomers;
  static List<ProductionOrder>? _cachedOrders;

  static Future<ProductionOrderFetchResult> fetchProductionOrders({int page = 1, int limit = 10}) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final response = await http.post(
        Uri.parse(await ApiConfig.getBaseUrl()),
        body: {
          'type': '9006',
          'cid': prefs.getString('cid') ?? '44555666',
          'uid': prefs.getString('uid') ?? '1',
          'role_id': prefs.getString('role_id') ?? '111',
          'token': prefs.getString('token') ?? '234demo',
          'device_id': prefs.getString('device_id') ?? 'abc123',
          'ln': prefs.getString('ln') ?? '22',
          'lt': prefs.getString('lt') ?? '1',
        },
      ).timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        debugPrint("Production Orders response: ${response.body}");
        final Map<String, dynamic> data = json.decode(response.body);
        if (data['error'] == false && data['data'] != null) {
          final List<dynamic> ordersJson = data['data'];
          final orders = ordersJson.map((json) => ProductionOrder.fromJson(json)).toList();
          final total = int.tryParse(data['total']?.toString() ?? '0') ?? 0;

          if (page == 1) _cachedOrders = orders;
          return ProductionOrderFetchResult(orders: orders, total: total);
        }
      }
    } catch (e) {
      debugPrint('Error fetching Production Orders: $e');
    }
    return ProductionOrderFetchResult(orders: [], total: 0);
  }

  static Future<List<DropdownItem>> fetchDropdown(String listId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final response = await http.post(
        Uri.parse(await ApiConfig.getBaseUrl()),
        body: {
          "type": "2084",
          "cid": prefs.getString('cid') ?? '44555666',
          "lt": prefs.getString('lt') ?? '123',
          "ln": prefs.getString('ln') ?? '123',
          "device_id": prefs.getString('device_id') ?? '123',
          "list_id": listId,
        },
      ).timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        debugPrint("Dropdown $listId response: ${response.body}");
        final Map<String, dynamic> data = json.decode(response.body);
        if (data['error'] == false && data['dropdown'] != null) {
          final List<dynamic> dropdownJson = data['dropdown'];
          return dropdownJson
              .map((json) => DropdownItem.fromJson(json))
              .toList();
        }
      }
    } catch (e) {
      debugPrint('Error fetching dropdown $listId: $e');
    }
    return [];
  }

  static Future<List<StaffMember>> fetchStaffSuggestions() async {
    if (_cachedStaff != null) return _cachedStaff!;
    try {
      final prefs = await SharedPreferences.getInstance();
      final response = await http.post(
        Uri.parse(await ApiConfig.getBaseUrl()),
        body: {
          'type': '2083',
          'cid': prefs.getString('cid') ?? '44555666',
          'uid': prefs.getString('uid') ?? '1',
          'role_id': prefs.getString('role_id') ?? '111',
          'token': prefs.getString('token') ?? '234demo',
          'lt': prefs.getString('lt') ?? '123',
          'ln': prefs.getString('ln') ?? '123',
          'device_id': prefs.getString('device_id') ?? '123',
          'form': 'sm_main_form_15521',
          'select': 'id,name',
          'where': 'department=1',
        },
      ).timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        debugPrint("Staff response: ${response.body}");
        final Map<String, dynamic> data = json.decode(response.body);
        if (data['error'] == false && data['data'] != null) {
          final List<dynamic> staffJson = data['data'];
          _cachedStaff =
              staffJson.map((json) => StaffMember.fromJson(json)).toList();
          return _cachedStaff!;
        }
      }
    } catch (e) {
      debugPrint('Error fetching staff suggestions: $e');
    }
    return [];
  }

  static Future<BomData?> fetchBomDetails(String bomId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final response = await http.post(
        Uri.parse(await ApiConfig.getBaseUrl()),
        body: {
          'type': '9008',
          'cid': prefs.getString('cid') ?? '44555666',
          'uid': prefs.getString('uid') ?? '1',
          'role_id': prefs.getString('role_id') ?? '111',
          'token': prefs.getString('token') ?? '234demo',
          'lt': prefs.getString('lt') ?? '123',
          'ln': prefs.getString('ln') ?? '123',
          'device_id': prefs.getString('device_id') ?? '123',
          'bom_id': bomId,
        },
      ).timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        debugPrint("Bom Details $bomId response: ${response.body}");
        final Map<String, dynamic> data = json.decode(response.body);
        if (data['error'] == false && data['bom_details'] != null) {
          final bomDetails = data['bom_details'];
          final List<dynamic> componentsJson = data['components'] ?? [];

          final items = componentsJson.map((c) => BomItem(
                itemCode: (c['itm_code'] ?? '').toString(),
                itemName: (c['components'] ?? 'Unknown').toString(),
                qtyPerUnit: int.tryParse(c['qty']?.toString() ?? '0') ?? 0,
                stock: 0, // Stock is not provided in 9008 response list
              )).toList();

          return BomData(
            bomId: bomId,
            bomLabel: 'BOM-${bomId.padLeft(3, '0')} · ${bomDetails['prd_name'] ?? 'Production'}',
            items: items,
          );
        }
      }
    } catch (e) {
      debugPrint('Error fetching BOM details for $bomId: $e');
    }
    return null;
  }

  static Future<Map<String, dynamic>?> saveProductionPlan({
    required String jobId,
    required String bomId,
    required String bomCode,
    required String productCode,
    required String productName,
    required int planQuantity,
    required String cusName,
    required String operator,
    required String priority,
    required String productionType,
    required String planDescription,
    required String startDate,
    required List<BomItem> items,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      final List<Map<String, dynamic>> itemsJson = items.map((i) => {
        "item_code": i.itemCode,
        "item_name": i.itemName,
        "qty": i.qtyPerUnit,
        "stock": i.stock,
      }).toList();

      final response = await http.post(
        Uri.parse(await ApiConfig.getBaseUrl()),
        body: {
          'type': '9009',
          'cid': prefs.getString('cid') ?? '44555666',
          'uid': prefs.getString('uid') ?? '1',
          'role_id': prefs.getString('role_id') ?? '2',
          'token': prefs.getString('token') ?? 'jkhfxxv',
          'job_id': jobId,
          'bom_id': bomId,
          'bom_code': bomCode,
          'product_code': productCode,
          'product_name': productName,
          'plan_quantity': planQuantity.toString(),
          'cus_name': cusName,
          'operator': operator,
          'priority': priority,
          'production_type': productionType,
          'plan_description': planDescription,
          'start_date': startDate,
          'device_id': prefs.getString('device_id') ?? '123',
          'ln': prefs.getString('ln') ?? '123',
          'lt': prefs.getString('lt') ?? '123',
          'items': json.encode(itemsJson),
        },
      ).timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        debugPrint("Save Production Plan response: ${response.body}");
        return json.decode(response.body);
      }
    } catch (e) {
      debugPrint('Error saving production plan: $e');
    }
    return null;
  }

  static Future<List<Map<String, dynamic>>> fetchBoms() async {
    if (_cachedBoms != null) return _cachedBoms!;
    try {
      final prefs = await SharedPreferences.getInstance();
      final response = await http.post(
        Uri.parse(await ApiConfig.getBaseUrl()),
        body: {
          'type': '2083',
          'cid': prefs.getString('cid') ?? '44555666',
          'uid': prefs.getString('uid') ?? '1',
          'role_id': prefs.getString('role_id') ?? '111',
          'token': prefs.getString('token') ?? '234demo',
          'lt': prefs.getString('lt') ?? '123',
          'ln': prefs.getString('ln') ?? '123',
          'device_id': prefs.getString('device_id') ?? '123',
          'form': 'sm_main_form_30221',
          'select': '*',
        },
      ).timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        debugPrint("BOMs response: ${response.body}");
        final Map<String, dynamic> data = json.decode(response.body);
        if (data['error'] == false && data['data'] != null) {
          _cachedBoms = List<Map<String, dynamic>>.from(data['data']);
          return _cachedBoms!;
        }
      }
    } catch (e) {
      debugPrint('Error fetching BOMs: $e');
    }
    return [];
  }

  static Future<List<Map<String, dynamic>>> fetchProductSuggestions() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final response = await http.post(
        Uri.parse(await ApiConfig.getBaseUrl()),
        body: {
          'type': '2083',
          'cid': prefs.getString('cid') ?? '44555666',
          'uid': prefs.getString('uid') ?? '1',
          'role_id': prefs.getString('role_id') ?? '111',
          'token': prefs.getString('token') ?? '234demo',
          'lt': prefs.getString('lt') ?? '123',
          'ln': prefs.getString('ln') ?? '123',
          'device_id': prefs.getString('device_id') ?? '123',
          'form': 'sm_main_form_10106',
          'select': '*',
          'where': 'sub_type=2',
        },
      ).timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        debugPrint("Product suggestions response: ${response.body}");
        final Map<String, dynamic> data = json.decode(response.body);
        if (data['error'] == false && data['data'] != null) {
          return List<Map<String, dynamic>>.from(data['data']);
        }
      }
    } catch (e) {
      debugPrint('Error fetching product suggestions: $e');
    }
    return [];
  }

  static Future<int> fetchProductStock(String productCode) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final bodyParams = {
        'type': '2083',
        'cid': prefs.getString('cid') ?? '44555666',
        'uid': prefs.getString('uid') ?? '1',
        'role_id': prefs.getString('role_id') ?? '111',
        'token': prefs.getString('token') ?? '234demo',
        'lt': prefs.getString('lt') ?? '123',
        'ln': prefs.getString('ln') ?? '123',
        'device_id': prefs.getString('device_id') ?? '123',
        'form': 'sm_main_form_10106',
        'select': 'product_code,product_name,stock_qty',
        'where': 'sub_type=2,product_code=$productCode',
      };
      
      final response = await http.post(
        Uri.parse(await ApiConfig.getBaseUrl()),
        body: bodyParams,
      ).timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        debugPrint("Stock for $productCode response: ${response.body}");
        final Map<String, dynamic> data = json.decode(response.body);
        if (data['error'] == false && data['data'] != null) {
          final List<dynamic> stockData = data['data'];
          if (stockData.isNotEmpty) {
            String stockStr = stockData[0]['stock_qty']?.toString() ?? '0';
            return double.tryParse(stockStr)?.toInt() ?? 0;
          }
        }
      }
    } catch (e) {
      debugPrint('Error fetching product stock: $e');
    }
    return 0;
  }

  static Future<List<Map<String, dynamic>>> fetchCustomers() async {
    if (_cachedCustomers != null) return _cachedCustomers!;
    try {
      final prefs = await SharedPreferences.getInstance();
      final response = await http.post(
        Uri.parse(await ApiConfig.getBaseUrl()),
        body: {
          'type': '2083',
          'cid': prefs.getString('cid') ?? '44555666',
          'uid': prefs.getString('uid') ?? '1',
          'role_id': prefs.getString('role_id') ?? '111',
          'token': prefs.getString('token') ?? '234demo',
          'lt': prefs.getString('lt') ?? '123',
          'ln': prefs.getString('ln') ?? '123',
          'device_id': prefs.getString('device_id') ?? '123',
          'form': 'sm_main_form_10002',
          'select': 'id,Ledger_Name',
          'where': 'category=8',
        },
      ).timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        debugPrint("Customers response: ${response.body}");
        final Map<String, dynamic> data = json.decode(response.body);
        if (data['error'] == false && data['data'] != null) {
          _cachedCustomers = List<Map<String, dynamic>>.from(data['data']);
          return _cachedCustomers!;
        }
      }
    } catch (e) {
      debugPrint('Error fetching customers: $e');
    }
    return [];
  }

  static Future<Map<String, dynamic>> saveProductionOrder({
    required String productionType,
    required String priority,
    required String dueDate,
    required String customerId,
    required List<OrderProduct> products,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final List<Map<String, dynamic>> productsJson = products.map((p) {
        return {
          "product_code": p.code,
          "product_name": p.name,
          "bom_id": p.bomId,
          "quantity": p.qty,
          "stock_qty": p.stockQty,
        };
      }).toList();

      final response = await http.post(
        Uri.parse(await ApiConfig.getBaseUrl()),
        body: {
          'type': '9004',
          'cid': prefs.getString('cid') ?? '44555666',
          'uid': prefs.getString('uid') ?? '1',
          'role_id': prefs.getString('role_id') ?? '1',
          'token': prefs.getString('token') ?? 'jkhfxxv',
          'prodcution_type': productionType,
          'prity': priority,
          'due_date': dueDate,
          'cus_name': customerId,
          'products': json.encode(productsJson),
          'device_id': prefs.getString('device_id') ?? '123',
          'ln': prefs.getString('ln') ?? '123',
          'lt': prefs.getString('lt') ?? '123',
        },
      ).timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        debugPrint("Production Order Save response: ${response.body}");
        return json.decode(response.body);
      }
    } catch (e) {
      debugPrint('Error saving Production Order: $e');
    }
    return {'error': true, 'message': 'Connection error'};
  }
}
