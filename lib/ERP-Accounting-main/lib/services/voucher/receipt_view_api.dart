import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import '../local_storage.dart';

// ─── Model ───────────────────────────────────────────────────────────────────

class ReceiptItemModel {
  final int? id;
  final int? uid;
  final int? cid;
  final String? date;
  final String? customerName;
  final String? payType;
  final dynamic dDate;
  final String? payAccount;
  final dynamic amount;
  final String? remarks;
  final String? dtime;

  ReceiptItemModel({
    this.id,
    this.uid,
    this.cid,
    this.date,
    this.customerName,
    this.payType,
    this.dDate,
    this.payAccount,
    this.amount,
    this.remarks,
    this.dtime,
  });

  factory ReceiptItemModel.fromJson(Map<String, dynamic> json) {
    return ReceiptItemModel(
      id: json['id'],
      uid: json['uid'],
      cid: json['cid'],
      date: json['date'],
      customerName: json['customer_name'],
      payType: json['pay_type'],
      dDate: json['d_date'],
      payAccount: json['pay_account'],
      amount: json['amount'],
      remarks: json['remarks'],
      dtime: json['dtime'],
    );
  }
}

// ─── Service ─────────────────────────────────────────────────────────────────

class ReceiptViewApiService {
  static const String _url = 'https://erpsmart.in/total/api/m_api/';

  // ── Load all login-saved SharedPreference values in one place ──
  static Future<Map<String, String>> _loadPrefs() async {
    final uid      = await LocalStorage.getUid();
    final cid      = await LocalStorage.getCid();
    final lat      = await LocalStorage.getLat();
    final lng      = await LocalStorage.getLng();
    final deviceId = await LocalStorage.getDeviceId();
    final roleId   = await LocalStorage.getRoleId();

    final prefs = {
      'uid'      : uid,
      'cid'      : cid,
      'lt'       : lat,
      'ln'       : lng,
      'device_id': deviceId,
      'role_id'  : roleId,
    };

    if (kDebugMode) {
      debugPrint('┌─ [SharedPreferences Loaded] ──────────────────────────');
      prefs.forEach((k, v) => debugPrint('│  $k = $v'));
      debugPrint('└───────────────────────────────────────────────────────');
    }

    return prefs;
  }

  // ─────────────────────────────────────────────────────────────────────────
  // FETCH: type 2083 — Receipt List
  // ─────────────────────────────────────────────────────────────────────────
  static Future<List<ReceiptItemModel>> fetchReceiptList() async {
    final prefs = await _loadPrefs();

    final Map<String, String> body = {
      'type'     : '2083',
      'cid'      : prefs['cid']!,
      'uid'      : prefs['uid']!,
      'role_id'  : prefs['role_id']!,
      'lt'       : prefs['lt']!,
      'ln'       : prefs['ln']!,
      'device_id': prefs['device_id']!,
      'form'     : 'sm_main_form_50201',
      'select'   : '*',
    };

    if (kDebugMode) {
      debugPrint('┌─ [Receipt fetchList REQUEST] ──────────────────────────');
      body.forEach((k, v) => debugPrint('│  $k = $v'));
      debugPrint('└───────────────────────────────────────────────────────');
    }

    try {
      final response = await http.post(Uri.parse(_url), body: body);

      if (kDebugMode) {
        debugPrint('┌─ [Receipt fetchList RESPONSE] ─────────────────────────');
        debugPrint('│  Status : ${response.statusCode}');
        debugPrint('│  Body   : ${response.body}');
        debugPrint('└───────────────────────────────────────────────────────');
      }

      if (response.statusCode == 200) {
        final decoded = json.decode(response.body);
        if (decoded != null && decoded['data'] != null) {
          final List<dynamic> data = decoded['data'];
          return data.map((item) => ReceiptItemModel.fromJson(item)).toList();
        }
      }
    } catch (e, st) {
      if (kDebugMode) {
        debugPrint('⚠ [Receipt fetchList ERROR] $e');
        debugPrint('$st');
      }
    }

    return [];
  }

  // ─────────────────────────────────────────────────────────────────────────
  // INSERT: type 500 — Receipt Voucher
  // ─────────────────────────────────────────────────────────────────────────
  static Future<Map<String, dynamic>> insertReceiptVoucher({
    required String customerName,
    required String payType,
    required String payAccount,
    required String amount,
    String remarks = '',
  }) async {
    final prefs = await _loadPrefs();

    final Map<String, String> body = {
      'type'         : '500',
      'cid'          : prefs['cid']!,
      'uid'          : prefs['uid']!,
      'lt'           : prefs['lt']!,
      'ln'           : prefs['ln']!,
      'device_id'    : prefs['device_id']!,
      'customer_name': customerName,
      'pay_type'     : payType,
      'pay_account'  : payAccount,
      'amount'       : amount,
      'remarks'      : remarks,
    };

    if (kDebugMode) {
      debugPrint('┌─ [Receipt insertVoucher REQUEST] ──────────────────────');
      body.forEach((k, v) => debugPrint('│  $k = $v'));
      debugPrint('└───────────────────────────────────────────────────────');
    }

    try {
      final response = await http.post(Uri.parse(_url), body: body);

      if (kDebugMode) {
        debugPrint('┌─ [Receipt insertVoucher RESPONSE] ─────────────────────');
        debugPrint('│  Status : ${response.statusCode}');
        debugPrint('│  Body   : ${response.body}');
        debugPrint('└───────────────────────────────────────────────────────');
      }

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        return {
          'error'  : true,
          'message': 'HTTP ${response.statusCode}',
        };
      }
    } catch (e, st) {
      if (kDebugMode) {
        debugPrint('⚠ [Receipt insertVoucher ERROR] $e');
        debugPrint('$st');
      }
      return {'error': true, 'message': e.toString()};
    }
  }
}
