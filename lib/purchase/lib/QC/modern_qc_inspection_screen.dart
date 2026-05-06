import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:purchase_erp/utils/device_services.dart';
import 'package:purchase_erp/core/api_config.dart';

class ModernQCInspectionScreen extends StatefulWidget {
  final Map<String, dynamic> inspectionData;
  final bool isReadOnly;

  const ModernQCInspectionScreen({super.key, required this.inspectionData, this.isReadOnly = false});

  @override
  State<ModernQCInspectionScreen> createState() => _ModernQCInspectionScreenState();
}

class _ModernQCInspectionScreenState extends State<ModernQCInspectionScreen> {
  List<Map<String, dynamic>> itemsList = [];
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _parseData();
  }

  void _parseData() {
    itemsList.clear();
    final dataRoot = widget.inspectionData.containsKey('data') ? widget.inspectionData['data'] : widget.inspectionData;
    final items = dataRoot['items'] as List? ?? [];
    
    for (var item in items) {
      double received = double.tryParse((item['received_qty'] ?? item['rec_qty'] ?? '0').toString()) ?? 0;
      double accepted = double.tryParse((item['accepted_qty'] ?? item['acc_qty'] ?? '0').toString()) ?? 0;
      double rejected = double.tryParse((item['rejected_qty'] ?? '0').toString()) ?? 0;
      String result = 'Pass';
      
      if (item['qc_test_result'] != null) {
        result = (item['qc_test_result'].toString().toLowerCase() == 'fail') ? 'Fail' : 'Pass';
      } else if (rejected > 0) {
        result = 'Fail';
      }

      itemsList.add({
        ...Map<String, dynamic>.from(item),
        'acc_qty_ctrl': TextEditingController(text: (accepted > 0 ? accepted : received).toString()),
        'rej_qty_ctrl': TextEditingController(text: rejected.toString()),
        'remarks_ctrl': TextEditingController(text: (item['remarks'] ?? '').toString()),
        'result': result,
      });
    }
  }

  @override
  void dispose() {
    for (var item in itemsList) {
      item['acc_qty_ctrl'].dispose();
      item['rej_qty_ctrl'].dispose();
      item['remarks_ctrl'].dispose();
    }
    super.dispose();
  }

  Future<void> _submitInspection() async {
    // Confirmation Dialog
    bool? confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Confirm Inspection", style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
        content: Text("Are you sure you want to submit this QC inspection? This action will update the item status.", style: GoogleFonts.outfit()),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: Text("Cancel", style: GoogleFonts.outfit(color: Colors.grey))),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xff22A79A), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
            child: Text("Confirm & Submit", style: GoogleFonts.outfit(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    setState(() => _isSubmitting = true);
    try {
      final prefs = await SharedPreferences.getInstance();
      final cid = prefs.getString('cid') ?? '44555666';
      final uid = prefs.getString('uid') ?? '';
      final deviceData = await DeviceServices.getAndStoreDeviceInfo();
      
      List<Map<String, dynamic>> updatedItems = [];
      for (var item in itemsList) {
        updatedItems.add({
          "item_code": item["item_code"]?.toString() ?? '',
          "acc_qty": item["acc_qty_ctrl"].text.trim(),
          "rej_qty": item["rej_qty_ctrl"].text.trim(),
          "result": item["result"] ?? 'Pass',
          "status": "Approved", // As per user sample
          "remarks": item["remarks_ctrl"].text.trim(),
        });
      }

      final url = Uri.parse(await ApiConfig.getBaseUrl());
      final response = await http.post(
        url,
        body: {
          "type": "4048",
          "cid": cid,
          "lt": deviceData['lt'] ?? "123",
          "ln": deviceData['ln'] ?? "123",
          "device_id": deviceData['device_id'] ?? "123",
          "uid": uid,
          "id": widget.inspectionData['inspection_id']?.toString() ?? widget.inspectionData['id']?.toString() ?? '',
          "items": jsonEncode(updatedItems),
        },
      );

      final Map<String, dynamic> result = json.decode(response.body);
      if (result['error'] == false) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("QC Inspection Submitted Successfully!"),
              backgroundColor: Color(0xFF26A69A),
            ),
          );
          Navigator.pop(context, true);
        }
      } else {
        throw result['message'] ?? result['status'] ?? "Failed to submit inspection";
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
    final dataRoot = widget.inspectionData.containsKey('data') ? widget.inspectionData['data'] : widget.inspectionData;
    final master = dataRoot.containsKey('master') ? dataRoot['master'] : dataRoot;
    
    final grnNo = master['grn_no'] ?? 'N/A';
    final date = master['grn_date'] ?? master['gnr_date'] ?? master['dtime'] ?? '-';
    final String rawStatus = (master['qc_status'] ?? 'Pending').toString();
    String status = rawStatus;
    if (rawStatus == "1" || rawStatus == "" || rawStatus == "null" || rawStatus.toLowerCase().contains("approve po generated")) {
      status = "Pending";
    }
    final supplierId = master['supplier_id']?.toString() ?? 'N/A';
    final vehicleNo = master['vehicle_no'] ?? '-';
    final driverName = master['driver_name'] ?? '-';
    final purchaseType = master['purchase_type'] ?? '-';
    final transportType = master['transport_type'] ?? '-';
    final invoiceNo = master['invoice_no'] ?? '-';
    
    return Scaffold(
      backgroundColor: const Color(0xFFF1F5F9),
      appBar: AppBar(
        backgroundColor: const Color(0xff26A69A),
        elevation: 0,
        centerTitle: false,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          "QC Inspection",
          style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18.sp),
        ),
      ),
      body: Column(
        children: [
          // Expanded Header Info Container
          Container(
            width: double.infinity,
            padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 20.h),
            decoration: const BoxDecoration(
              color: Color(0xFF26A69A),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(24),
                bottomRight: Radius.circular(24),
              ),
            ),
            child: Column(
              children: [
                // Summary row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(grnNo, style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 20.sp)),
                        Text("Date: $date", style: GoogleFonts.outfit(color: Colors.white70, fontSize: 12.sp)),
                      ],
                    ),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        status,
                        style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12.sp),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 16.h),
                // Detailed info card
                Container(
                  padding: EdgeInsets.all(12.w),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: GridView.count(
                    crossAxisCount: 2,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    childAspectRatio: 3,
                    children: [
                      _buildInfoTile("Supplier ID", supplierId),
                      _buildInfoTile("Purchase", purchaseType),
                      _buildInfoTile("Vehicle No", vehicleNo),
                      _buildInfoTile("Driver Name", driverName),
                      _buildInfoTile("Invoice No", invoiceNo),
                      _buildInfoTile("Transport", transportType),
                    ],
                  ),
                ),
              ],
            ),
          ),

          Expanded(
            child: ListView.builder(
              padding: EdgeInsets.all(16.w),
              itemCount: itemsList.length,
              itemBuilder: (context, index) {
                return _buildItemInspectionCard(itemsList[index], index);
              },
            ),
          ),

          // Bottom Action Bar
          widget.isReadOnly ? const SizedBox.shrink() : Container(
            padding: EdgeInsets.fromLTRB(20.w, 10.h, 20.w, 20.h),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, -5)),
              ],
            ),
            child: SafeArea(
              child: SizedBox(
                width: double.infinity,
                height: 50.h,
                child: ElevatedButton(
                  onPressed: _isSubmitting ? null : _submitInspection,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF26A69A),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    elevation: 0,
                  ),
                  child: _isSubmitting
                      ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                      : Text(
                          "SUBMIT INSPECTION",
                          style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15.sp),
                        ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoTile(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(label, style: GoogleFonts.outfit(color: Colors.grey, fontSize: 10.sp, fontWeight: FontWeight.w500)),
        Text(
          value,
          style: GoogleFonts.outfit(color: Colors.black87, fontWeight: FontWeight.bold, fontSize: 12.sp),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }

  Widget _buildHeaderStat(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: Colors.white60, size: 14.sp),
        SizedBox(height: 6.h),
        Text(label, style: GoogleFonts.outfit(color: Colors.white70, fontSize: 8.sp, fontWeight: FontWeight.w600, letterSpacing: 0.5)),
        SizedBox(height: 2.h),
        Text(
          value,
          style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 11.sp),
        ),
      ],
    );
  }

  Widget _buildItemInspectionCard(Map<String, dynamic> item, int index) {
    return Container(
      margin: EdgeInsets.only(bottom: 16.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 12,
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
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
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
                        style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 13.sp),
                      ),
                      Text(
                        item['product_name'] ?? "-",
                        style: GoogleFonts.outfit(color: Colors.grey.shade600, fontSize: 11.sp),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                _buildResultToggle(item),
              ],
            ),
          ),

          Padding(
            padding: EdgeInsets.all(16.w),
            child: Column(
              children: [
                // Quantities Info
                Row(
                  children: [
                    _buildSmallQtyInfo("Ordered", (item['odr_qty'] ?? item['ordered_qty'] ?? '0').toString(), Colors.blue.shade700),
                    Spacer(),
                    _buildSmallQtyInfo("Received", (item['rec_qty'] ?? item['received_qty'] ?? '0').toString(), Colors.orange.shade700),
                    Spacer(),
                    _buildSmallQtyInfo("Accepted", (item['acc_qty'] ?? item['accepted_qty'] ?? '0').toString(), Colors.green.shade700),
                  ],
                ),
                SizedBox(height: 16.h),
                
                // Editable Qty Fields
                Row(
                  children: [
                    Expanded(child: _buildEditField("Accepted Qty", item['acc_qty_ctrl'], Icons.check_circle_outline, Colors.green)),
                    SizedBox(width: 12.w),
                    Expanded(child: _buildEditField("Rejected Qty", item['rej_qty_ctrl'], Icons.cancel_outlined, Colors.red)),
                  ],
                ),
                SizedBox(height: 16.h),
                
                // Remarks Field
                _buildRemarkField(item['remarks_ctrl']),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResultToggle(Map<String, dynamic> item) {
    bool isPass = item['result'] == 'Pass';
    return GestureDetector(
      onTap: widget.isReadOnly ? null : () => setState(() => item['result'] = isPass ? 'Fail' : 'Pass'),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
        decoration: BoxDecoration(
          color: isPass ? const Color(0xFFDCFCE7) : const Color(0xFFFEE2E2),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: isPass ? const Color(0xFF22C55E) : const Color(0xFFEF4444)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isPass ? Icons.check_circle : Icons.error,
              size: 14.sp,
              color: isPass ? const Color(0xFF16A34A) : const Color(0xFFDC2626),
            ),
            SizedBox(width: 4.w),
            Text(
              item['result'],
              style: GoogleFonts.outfit(
                color: isPass ? const Color(0xFF16A34A) : const Color(0xFFDC2626),
                fontWeight: FontWeight.bold,
                fontSize: 11.sp,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSmallQtyInfo(String label, String value, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: GoogleFonts.outfit(color: Colors.grey, fontSize: 10.sp)),
        Text(value, style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 13.sp, color: color)),
      ],
    );
  }

  Widget _buildEditField(String label, TextEditingController controller, IconData icon, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: GoogleFonts.outfit(color: Colors.grey, fontSize: 10.sp)),
        SizedBox(height: 6.h),
        TextField(
          controller: controller,
          readOnly: widget.isReadOnly,
          keyboardType: TextInputType.number,
          style: GoogleFonts.outfit(fontSize: 13.sp, fontWeight: FontWeight.w600),
          decoration: InputDecoration(
            isDense: true,
            prefixIcon: Icon(icon, size: 16.sp, color: color),
            contentPadding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 12.h),
            fillColor: const Color(0xFFF8FAFC),
            filled: true,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: color)),
          ),
        ),
      ],
    );
  }

  Widget _buildRemarkField(TextEditingController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Remarks", style: GoogleFonts.outfit(color: Colors.grey, fontSize: 10.sp)),
        SizedBox(height: 6.h),
        TextField(
          controller: controller,
          readOnly: widget.isReadOnly,
          style: GoogleFonts.outfit(fontSize: 12.sp),
          decoration: InputDecoration(
            isDense: true,
            hintText: "Add observation details...",
            hintStyle: GoogleFonts.outfit(color: Colors.grey.shade400, fontSize: 12.sp),
            contentPadding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
            fillColor: const Color(0xFFF8FAFC),
            filled: true,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFF26A69A))),
          ),
        ),
      ],
    );
  }
}