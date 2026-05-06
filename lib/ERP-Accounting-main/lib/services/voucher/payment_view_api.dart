import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import '../local_storage.dart';

class PaymentItemModel {
  final int? id;
  final int? uid;
  final int? cid;
  final String? date;
  final String? ledgerName;
  final String? payMode;
  final String? dDate;
  final String? payAccount;
  final dynamic total;
  final String? remark;
  final String? dtime;

  PaymentItemModel({
    this.id,
    this.uid,
    this.cid,
    this.date,
    this.ledgerName,
    this.payMode,
    this.dDate,
    this.payAccount,
    this.total,
    this.remark,
    this.dtime,
  });

  factory PaymentItemModel.fromJson(Map<String, dynamic> json) {
    return PaymentItemModel(
      id: json['id'],
      uid: json['uid'],
      cid: json['cid'],
      date: json['date'],
      ledgerName: json['ledger_name'] ?? json['supplier_name'],
      payMode: json['pay_mode'],
      dDate: json['d_date'],
      payAccount: json['pay_account'],
      total: json['total'] ?? json['payment_amt'],
      remark: json['remark'],
      dtime: json['dtime'],
    );
  }
}

class PaymentInvoiceModel {
  final int? sno;
  final int? invoiceId;
  final String? date;
  final String? reference;
  final String? amount;
  final String? leftToAllocate;
  final num? leftRaw;
  final String? thisAllocation;
  final String? type;

  PaymentInvoiceModel({
    this.sno,
    this.invoiceId,
    this.date,
    this.reference,
    this.amount,
    this.leftToAllocate,
    this.leftRaw,
    this.thisAllocation,
    this.type,
  });

  factory PaymentInvoiceModel.fromJson(Map<String, dynamic> json) {
    return PaymentInvoiceModel(
      sno: json['sno'],
      invoiceId: json['invoice_id'],
      date: json['date'],
      reference: json['reference'],
      amount: json['amount'],
      leftToAllocate: json['left_to_allocate'],
      leftRaw: json['left_raw'],
      thisAllocation: json['this_allocation'],
      type: json['type'],
    );
  }
}

class PaymentAutofillModel {
  final int? id;
  final String? name;
  final String? balance;
  final int? invoiceCount;
  final List<PaymentInvoiceModel> invoices;

  PaymentAutofillModel({
    this.id,
    this.name,
    this.balance,
    this.invoiceCount,
    required this.invoices,
  });

  factory PaymentAutofillModel.fromJson(Map<String, dynamic> json) {
    var invList = json['invoices'] as List? ?? [];
    return PaymentAutofillModel(
      id: json['id'],
      name: json['name'],
      balance: json['balance'],
      invoiceCount: json['invoice_count'],
      invoices: invList.map((i) => PaymentInvoiceModel.fromJson(i)).toList(),
    );
  }
}

class PaymentViewApiService {
  static Future<List<PaymentItemModel>> fetchPaymentList() async {
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
      'form': 'sm_main_form_50102',
      'select': '*',
    };

    try {
      final response = await http.post(
        Uri.parse(url),
        body: body,
      );

      if (kDebugMode) {
        print('Payment API Response: ${response.body}');
      }

      if (response.statusCode == 200) {
        final decoded = json.decode(response.body);
        if (decoded != null && decoded['data'] != null) {
          dynamic rawData = decoded['data'];
          List<dynamic> dataList = [];
          if (rawData is List) {
            dataList = rawData;
          } else if (rawData is Map) {
            // PHP API might return a single object or an indexed map instead of an array
            dataList = rawData.values.toList();
          }
          final parsedList = dataList.map((item) => PaymentItemModel.fromJson(item)).toList();
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

  static Future<Map<String, dynamic>> insertPaymentVoucher({
    required String supplierName,
    required String payMode,
    required String paymentAmt,
    required String payAccount,
    String remark = '',
  }) async {
    const String url = 'https://erpsmart.in/total/api/m_api/';

    final String lat = await LocalStorage.getLat();
    final String lng = await LocalStorage.getLng();
    final String cid = await LocalStorage.getCid();
    final String deviceId = await LocalStorage.getDeviceId();
    final String uid = await LocalStorage.getUid();

    final Map<String, String> body = {
      'type': '501',
      'cid': cid,
      'uid': uid,
      'lt': lat,
      'ln': lng,
      'device_id': deviceId,
      'supplier_name': supplierName,
      'pay_mode': payMode,
      'payment_amt': paymentAmt,
      'pay_account': payAccount,
      'remark': remark,
    };

    if (kDebugMode) {
      print('Payment Insert API Request: $body');
    }

    try {
      final response = await http.post(
        Uri.parse(url),
        body: body,
      );

      if (kDebugMode) {
        print('Payment Insert API Response: ${response.body}');
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

  static Future<List<PaymentAutofillModel>> fetchAutofill(String query) async {
    const String url = 'https://erpsmart.in/total/api/m_api/';

    final String lat = await LocalStorage.getLat();
    final String lng = await LocalStorage.getLng();
    final String cid = await LocalStorage.getCid();
    final String deviceId = await LocalStorage.getDeviceId();
    final String uid = await LocalStorage.getUid();
    final String roleId = await LocalStorage.getRoleId();

    final Map<String, String> body = {
      'type': '503',
      'cid': cid,
      'uid': uid,
      'role_id': roleId,
      'lt': lat,
      'ln': lng,
      'device_id': deviceId,
      'search': query,
    };

    try {
      final response = await http.post(Uri.parse(url), body: body);

      if (kDebugMode) {
        print('Payment Autofill API Response: ${response.body}');
      }

      if (response.statusCode == 200) {
        final decoded = json.decode(response.body);
        if (decoded != null && decoded['data'] != null) {
          final List<dynamic> data = decoded['data'];
          return data.map((item) => PaymentAutofillModel.fromJson(item)).toList();
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('Exception in autofill: $e');
      }
    }
    return [];
  }
}
