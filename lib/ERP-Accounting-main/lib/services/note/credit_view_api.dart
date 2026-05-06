import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import '../local_storage.dart';

class CreditNoteItemModel {
  final int? id;
  final int? uid;
  final int? cid;
  final String? assetName;
  final String? category;
  final String? purchaseDate;
  final String? purchaseValue;
  final String? dtime;

  CreditNoteItemModel({
    this.id,
    this.uid,
    this.cid,
    this.assetName,
    this.category,
    this.purchaseDate,
    this.purchaseValue,
    this.dtime,
  });

  factory CreditNoteItemModel.fromJson(Map<String, dynamic> json) {
    return CreditNoteItemModel(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id']?.toString() ?? ''),
      uid: json['uid'] is int ? json['uid'] : int.tryParse(json['uid']?.toString() ?? ''),
      cid: json['cid'] is int ? json['cid'] : int.tryParse(json['cid']?.toString() ?? ''),
      assetName: json['asset_name'] ?? json['customer_name'],
      category: json['category'],
      purchaseDate: json['purchase_date'],
      purchaseValue: json['purchase_value'] ?? json['amount'],
      dtime: json['dtime'],
    );
  }
}

class CreditViewApiService {
  static Future<List<CreditNoteItemModel>> fetchCreditNoteList() async {
    const String url = 'https://erpsmart.in/total/api/m_api/';

    final String lat = await LocalStorage.getLat();
    final String lng = await LocalStorage.getLng();
    final String cid = await LocalStorage.getCid();
    final String deviceId = await LocalStorage.getDeviceId();
    final String uid = await LocalStorage.getUid();
    final String roleId = await LocalStorage.getRoleId();

    final Map<String, String> body = {
      'type': '2083',
      'cid': cid,
      'uid': uid,
      'role_id': roleId,
      'ln': lng,
      'lt': lat,
      'device_id': deviceId,
      'form': 'sm_main_form_50501',
      'select': '*',
    };

    try {
      final response = await http.post(
        Uri.parse(url),
        body: body,
      );

      if (kDebugMode) {
        print('Credit Note API Response: ${response.body}');
      }

      if (response.statusCode == 200) {
        final decoded = json.decode(response.body);
        if (decoded != null && decoded['data'] != null) {
          dynamic rawData = decoded['data'];
          List<dynamic> dataList = [];
          if (rawData is List) {
            dataList = rawData;
          } else if (rawData is Map) {
            dataList = rawData.values.toList();
          }
          final parsedList = dataList.map((item) => CreditNoteItemModel.fromJson(item)).toList();
          return parsedList.reversed.toList();
        }
      } else {
        if (kDebugMode) {
          print('Error: Status code ${response.statusCode}');
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('Exception occurred: $e');
      }
    }
    return [];
  }

  static Future<Map<String, dynamic>> insertCreditNote({
    required String customerName,
    required String amount,
  }) async {
    const String url = 'https://erpsmart.in/total/api/m_api/';

    final String lat = await LocalStorage.getLat();
    final String lng = await LocalStorage.getLng();
    final String cid = await LocalStorage.getCid();
    final String deviceId = await LocalStorage.getDeviceId();
    final String uid = await LocalStorage.getUid();

    final Map<String, String> body = {
      'type': '502',
      'cid': cid,
      'uid': uid,
      'lt': lat,
      'ln': lng,
      'device_id': deviceId,
      // The backend validates 'customer_name' and 'amount'
      'customer_name': customerName,
      'amount': amount,
      // But the backend's SQL query likely looks for these keys to insert!
      'asset_name': customerName,
      'purchase_value': amount,
      // Just in case it shares code with Payment/Receipt vouchers:
      'supplier_name': customerName,
      'payment_amt': amount,
    };

    if (kDebugMode) {
      print('Credit Note Insert API Request: $body');
    }

    try {
      final response = await http.post(
        Uri.parse(url),
        body: body,
      );

      if (kDebugMode) {
        print('Credit Note Insert API Response: ${response.body}');
      }

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        return {'error': true, 'message': 'HTTP Error: ${response.statusCode}'};
      }
    } catch (e) {
      if (kDebugMode) {
        print('Exception occurred during insert: $e');
      }
      return {'error': true, 'message': e.toString()};
    }
  }
}
