import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'quotation_comparison.dart';
import 'package:purchase_erp/core/api_config.dart';

class ApproveQuotationScreen extends StatefulWidget {
  final Map<String, dynamic> quotationData;

  const ApproveQuotationScreen({super.key, required this.quotationData});

  @override
  State<ApproveQuotationScreen> createState() => _ApproveQuotationScreenState();
}

class _ApproveQuotationScreenState extends State<ApproveQuotationScreen> {
  List<Map<String, dynamic>> itemsList = [];
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    final items = widget.quotationData['items'] as List? ?? [];
    for (var item in items) {
      itemsList.add({
        ...item,
        'unit_rate_ctrl': TextEditingController(text: item['unit_rate']?.toString() ?? ''),
        'discount_ctrl': TextEditingController(text: item['discount']?.toString() ?? ''),
        'taxes_ctrl': TextEditingController(text: item['taxes']?.toString() ?? ''),
      });
    }
  }

  @override
  void dispose() {
    for (var item in itemsList) {
      item['unit_rate_ctrl'].dispose();
      item['discount_ctrl'].dispose();
      item['taxes_ctrl'].dispose();
    }
    super.dispose();
  }

  double _calcFinalRate(Map<String, dynamic> item) {
    double qty = double.tryParse(item['quoted_qty']?.toString() ?? '0') ?? 0;
    double rate = double.tryParse(item['unit_rate_ctrl'].text) ?? 0;
    double disc = double.tryParse(item['discount_ctrl'].text) ?? 0;
    double tax = double.tryParse(item['taxes_ctrl'].text) ?? 0;

    double subtotal = rate * qty;
    subtotal -= (subtotal * disc / 100);
    subtotal += (subtotal * tax / 100);
    return subtotal;
  }

  double _calcGrandTotal() {
    double g = 0;
    for (var item in itemsList) {
      g += _calcFinalRate(item);
    }
    return g;
  }

  Future<void> _submitApproval() async {
    setState(() => _isSubmitting = true);
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? cid = prefs.getString('cid');
      final String? deviceId = prefs.getString('device_id');
      final String? lt = prefs.getString('lt');
      final String? ln = prefs.getString('ln');

      List<Map<String, dynamic>> updatedItems = [];
      for (var item in itemsList) {
        updatedItems.add({
          "item_code": item["item_code"],
          "status": "Approved",
          "unit_rate": item["unit_rate_ctrl"].text,
          "discount": item["discount_ctrl"].text,
          "taxes": item["taxes_ctrl"].text,
        });
      }

      final url = Uri.parse(await ApiConfig.getBaseUrl());
      final response = await http.post(
        url,
        body: {
          "type": "4033",
          "cid": cid ?? "44555666",
          "lt": lt ?? "123",
          "ln": ln ?? "123",
          "device_id": deviceId ?? "123",
          "id": widget.quotationData['id'].toString(),
          "status": "Approved",
          "items": jsonEncode(updatedItems),
        },
      );

      final Map<String, dynamic> result = json.decode(response.body);
      if (result['error'] == false) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Quotation Approved & Updated Successfully!"),
              backgroundColor: Color(0xFF26A69A),
            ),
          );
          Navigator.popUntil(context, (route) => route.isFirst);
        }
      } else {
        throw result['message'] ?? "Failed to approve quotation";
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error: $e"), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: const Color(0xFF26A69A),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          "Review & Approve",
          style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18.sp),
        ),
      ),
      body: Column(
        children: [
          // Header Info Card
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(16.w),
            decoration: const BoxDecoration(
              color: Color(0xFF26A69A),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(32),
                bottomRight: Radius.circular(32),
              ),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Expanded(child: _buildHeaderStat("QUOTATION", widget.quotationData['quotation_no'] ?? "-")),
                    Expanded(child: _buildHeaderStat("RFQ REF", widget.quotationData['rfq_no'] ?? "-")),
                    Expanded(child: _buildHeaderStat("SUPPLIER", widget.quotationData['supplier_name'] ?? "-")),
                  ],
                ),
                SizedBox(height: 16.h),
              ],
            ),
          ),

          Expanded(
            child: ListView.builder(
              padding: EdgeInsets.all(16.w),
              itemCount: itemsList.length,
              itemBuilder: (context, index) {
                return _buildItemCard(itemsList[index], index);
              },
            ),
          ),

          // Bottom Action Bar
          Container(
            padding: EdgeInsets.all(20.w),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, -5),
                ),
              ],
            ),
            child: SafeArea(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Grand Total",
                            style: GoogleFonts.outfit(color: Colors.grey, fontSize: 14.sp),
                          ),
                          Text(
                            "₹ ${_calcGrandTotal().toStringAsFixed(2)}",
                            style: GoogleFonts.outfit(
                              color: const Color(0xFF1E293B),
                              fontWeight: FontWeight.bold,
                              fontSize: 22.sp,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(
                        width: 180.w,
                        height: 50.h,
                        child: ElevatedButton(
                          onPressed: _isSubmitting ? null : _submitApproval,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF26A69A),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            elevation: 0,
                          ),
                          child: _isSubmitting
                              ? const SizedBox(
                                  width: 24,
                                  height: 24,
                                  child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                                )
                              : Text(
                                  "Approve & Update",
                                  style: GoogleFonts.outfit(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14.sp,
                                  ),
                                ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderStat(String label, String value) {
    return Column(
      children: [
        Text(label, style: GoogleFonts.outfit(color: Colors.white.withOpacity(0.8), fontSize: 10.sp)),
        SizedBox(height: 4.h),
        Text(
          value,
          style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13.sp),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }

  Widget _buildItemCard(Map<String, dynamic> item, int index) {
    return Container(
      margin: EdgeInsets.only(bottom: 16.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Item Header
          Container(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
            decoration: BoxDecoration(
              color: const Color(0xFFF1F5F9),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 12,
                  backgroundColor: const Color(0xFF26A69A),
                  child: Text(
                    "${index + 1}",
                    style: TextStyle(color: Colors.white, fontSize: 10.sp, fontWeight: FontWeight.bold),
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item['item_code'] ?? "-",
                        style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 14.sp),
                      ),
                      Text(
                        item['item_description'] ?? "-",
                        style: GoogleFonts.outfit(color: Colors.grey, fontSize: 11.sp),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                Text(
                  "Qty: ${item['quoted_qty']}",
                  style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 13.sp, color: const Color(0xFF26A69A)),
                ),
              ],
            ),
          ),

          Padding(
            padding: EdgeInsets.all(16.w),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(child: _buildEditField("Unit Rate (₹)", item['unit_rate_ctrl'])),
                    SizedBox(width: 12.w),
                    Expanded(child: _buildEditField("Discount (%)", item['discount_ctrl'])),
                    SizedBox(width: 12.w),
                    Expanded(child: _buildEditField("Tax (%)", item['taxes_ctrl'])),
                  ],
                ),
                const Divider(height: 32),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Final Subtotal",
                      style: GoogleFonts.outfit(color: Colors.grey, fontSize: 12.sp),
                    ),
                    Text(
                      "₹ ${_calcFinalRate(item).toStringAsFixed(2)}",
                      style: GoogleFonts.outfit(
                        color: const Color(0xFF1E293B),
                        fontWeight: FontWeight.bold,
                        fontSize: 16.sp,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEditField(String label, TextEditingController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: GoogleFonts.outfit(color: Colors.grey, fontSize: 10.sp)),
        SizedBox(height: 6.h),
        TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          onChanged: (v) => setState(() {}),
          style: GoogleFonts.outfit(fontSize: 13.sp, fontWeight: FontWeight.w600),
          decoration: InputDecoration(
            isDense: true,
            contentPadding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 12.h),
            fillColor: const Color(0xFFF8FAFC),
            filled: true,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Color(0xFF26A69A)),
            ),
          ),
        ),
      ],
    );
  }
}