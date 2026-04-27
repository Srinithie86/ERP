import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:purchase_erp/utils/device_services.dart';
import '../purchase_request_pdf_viewer.dart';

class GrnInspectionScreen extends StatefulWidget {
  final Map<String, dynamic> inspectionData;
  const GrnInspectionScreen({super.key, required this.inspectionData});

  @override
  State<GrnInspectionScreen> createState() => _GrnInspectionScreenState();
}

class _GrnInspectionScreenState extends State<GrnInspectionScreen> {
  int selectedProductIndex = 0;
  List<TextEditingController> acceptQtyControllers = [];
  List<TextEditingController> rejectQtyControllers = [];
  List<TextEditingController> remarksControllers = [];
  bool isUpdating = false;

  @override
  void initState() {
    super.initState();
    final items = widget.inspectionData['items'] as List? ?? [];
    for (var item in items) {
      acceptQtyControllers.add(TextEditingController(text: (item['acc_qty'] ?? '0').toString()));
      rejectQtyControllers.add(TextEditingController(text: (item['rejected_qty'] ?? '0').toString()));
      remarksControllers.add(TextEditingController(text: (item['remarks'] ?? '').toString()));
    }
  }

  @override
  void dispose() {
    for (var c in acceptQtyControllers) { c.dispose(); }
    for (var c in rejectQtyControllers) { c.dispose(); }
    for (var c in remarksControllers) { c.dispose(); }
    super.dispose();
  }

  Widget _buildStatCard(String title, String value, Color bgColor, Color textColor, {bool isReversed = false}) {
    return Container(
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(8),
      ),
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      alignment: Alignment.center,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Flexible(
            child: Text(
              isReversed ? value : title,
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: textColor,
                fontWeight: isReversed ? FontWeight.bold : FontWeight.w600,
                fontSize: isReversed ? 16 : 10,
              ),
            ),
          ),
          const SizedBox(height: 4),
          Flexible(
            child: Text(
              isReversed ? title : value,
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: textColor,
                fontWeight: isReversed ? FontWeight.bold : FontWeight.w600, // Normalized
                fontSize: isReversed ? 11 : 16,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInputField(String label, TextEditingController controller, {bool isHint = false, String? hint}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Colors.black87),
        ),
        const SizedBox(height: 6),
        SizedBox(
          height: 38,
          child: TextField(
            controller: controller,
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: const TextStyle(color: Colors.grey, fontSize: 13),
              contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 0),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(4),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(4),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
            ),
          ),
        ),
      ],
    );
  }
  Future<void> _updateInspection() async {
    setState(() => isUpdating = true);
    try {
      final prefs = await SharedPreferences.getInstance();
      final cid = prefs.getString('cid') ?? '';
      final uid = prefs.getString('uid') ?? '';
      final deviceData = await DeviceServices.getAndStoreDeviceInfo();
      final ln = deviceData['ln'] ?? '123';
      final lt = deviceData['lt'] ?? '123';
      final deviceId = deviceData['device_id'] ?? '123';

      final List<Map<String, dynamic>> updatedItems = [];
      final items = widget.inspectionData['items'] as List? ?? [];
      
      for (int i = 0; i < items.length; i++) {
        updatedItems.add({
          "item_code": items[i]['item_code']?.toString() ?? '',
          "acc_qty": acceptQtyControllers[i].text.trim(),
          "rej_qty": rejectQtyControllers[i].text.trim(),
          "result": "Pass", // Default
          "status": "Approved",
          "remarks": remarksControllers[i].text.trim(),
        });
      }

      final response = await http.post(
        Uri.parse("https://erpsmart.in/total/api/m_api/"),
        body: {
          "type": "4048",
          "cid": cid.isEmpty ? "44555666" : cid,
          "device_id": deviceId,
          "ln": ln,
          "lt": lt,
          "uid": uid,
          "id": widget.inspectionData['id']?.toString() ?? '',
          "items": jsonEncode(updatedItems),
        },
      );

      if (response.statusCode == 200) {
        final resData = json.decode(response.body);
        if (resData['error'] == false) {
          if (mounted) {
            _showSuccessDialog();
          }
        } else {
          _showError(resData['status'] ?? "Update failed");
        }
      } else {
        _showError("Server error: ${response.statusCode}");
      }
    } catch (e) {
      _showError("Update failed: $e");
    } finally {
      if (mounted) setState(() => isUpdating = false);
    }
  }

  void _showError(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message), backgroundColor: Colors.red),
      );
    }
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        contentPadding: const EdgeInsets.all(24),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.check_circle, color: Color(0xff2AAA98), size: 64),
            const SizedBox(height: 16),
            const Text(
              "Updated Successfully",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 44,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xff2AAA98),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                  elevation: 0,
                ),
                onPressed: () {
                  Navigator.pop(context); // Close dialog
                  Navigator.pop(context, true); // Go back with success flag
                },
                child: const Text(
                  "OK",
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    const Color primaryColor = Color(0xff2AAA98);
    final data = widget.inspectionData;
    final grnNo = data['grn_no'] ?? 'N/A';
    final items = data['items'] as List? ?? [];
    
    if (items.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text("GRN Inspection"), backgroundColor: primaryColor),
        body: const Center(child: Text("No items to inspect")),
      );
    }

    final currentItem = items[selectedProductIndex];
    final productName = currentItem['product_name'] ?? 'N/A';
    final productCode = currentItem['item_code'] ?? 'N/A';
    final orderedQty = currentItem['odr_qty'] ?? '0';
    final receivedQty = currentItem['rec_qty'] ?? '0';
    final acceptedQty = currentItem['acc_qty'] ?? '0';
    final rejectedQty = currentItem['rejected_qty'] ?? '0';
    final qcStatus = currentItem['qc_status'] ?? 'Pending';
    final qcResult = currentItem['qc_test_result'] ?? 'N/A';

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color(0xff26A69A),
        elevation: 0,
        centerTitle: false,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 20.sp),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          "GRN Inspection",
          style: GoogleFonts.outfit(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 18.sp,
          ),
        ),
        actions: [
          if (data['pdf_link'] != null && data['pdf_link'].toString().isNotEmpty)
            IconButton(
              icon: const Icon(Icons.picture_as_pdf),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => PurchaseRequestPdfViewer(
                      pdfUrl: data['pdf_link'],
                      prNumber: grnNo,
                    ),
                  ),
                );
              },
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            /// GRN NUMBER Card
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: primaryColor,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "GRN NUMBER",
                    style: TextStyle(color: Colors.white70, fontSize: 11, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    decoration: const BoxDecoration(
                      border: Border(
                        bottom: BorderSide(color: Colors.cyanAccent, width: 2),
                      ),
                    ),
                    child: Text(
                      grnNo,
                      style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),

            Row(
              children: [
                Text(
                  "${items.length} Products",
                  style: const TextStyle(color: primaryColor, fontWeight: FontWeight.bold, fontSize: 13),
                ),
                Text(
                  "  -  Quick Inspection",
                  style: TextStyle(color: Colors.grey.shade800, fontSize: 13, fontWeight: FontWeight.w500),
                ),
              ],
            ),
            const SizedBox(height: 12),

            /// Product Chips
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: List.generate(items.length, (index) {
                  bool isSelected = selectedProductIndex == index;
                  String pName = items[index]['product_name'] ?? 'Item ${index+1}';
                  if (pName.length > 15) pName = "${pName.substring(0, 12)}...";
                  
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        selectedProductIndex = index;
                      });
                    },
                    child: Container(
                      margin: const EdgeInsets.only(right: 10),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                      decoration: BoxDecoration(
                        color: isSelected ? primaryColor : Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: isSelected ? Colors.transparent : Colors.grey.shade300,
                        ),
                      ),
                      child: Text(
                        pName,
                        style: TextStyle(
                          color: isSelected ? Colors.white : Colors.grey.shade400,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  );
                }),
              ),
            ),
            const SizedBox(height: 16),

            /// Product Box
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                boxShadow: [
                  BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8, offset: const Offset(0, 2)),
                ],
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "PRODUCT NAME",
                        style: TextStyle(color: Colors.grey, fontSize: 10, fontWeight: FontWeight.w600),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                        decoration: BoxDecoration(
                          color: qcStatus.toLowerCase() == 'pending' ? const Color(0xffB18428) : Colors.green,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          qcStatus,
                          style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    productName,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.black),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "Code : $productCode",
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                  ),
                  const SizedBox(height: 16),

                  /// Stats Row
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          children: [
                            _buildStatCard("ORDERED QTY", orderedQty.toString(), const Color(0xffE9F5FB), const Color(0xff226CA3)),
                            const SizedBox(height: 12),
                            _buildStatCard("Accepted", acceptedQty.toString(), const Color(0xffE6F9EE), const Color(0xff16A84F), isReversed: true),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          children: [
                            _buildStatCard("RECEIVED QTY", receivedQty.toString(), const Color(0xffFAEBFA), const Color(0xffB52B90)),
                            const SizedBox(height: 12),
                            _buildStatCard("Rejected", rejectedQty.toString(), const Color(0xffFAEEEE), const Color(0xffC62828), isReversed: true),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  
                  Text(
                    "Result : $qcResult",
                    style: const TextStyle(color: Color(0xff3B187B), fontWeight: FontWeight.bold, fontSize: 13),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    "Product Details & Inspection",
                    style: TextStyle(color: primaryColor, fontWeight: FontWeight.bold, fontSize: 12),
                  ),
                  const SizedBox(height: 12),

                  /// Input Fields
                  Row(
                    children: [
                      Expanded(child: _buildInputField("Accept Qty", acceptQtyControllers[selectedProductIndex])),
                      const SizedBox(width: 12),
                      Expanded(child: _buildInputField("Rejected Qty", rejectQtyControllers[selectedProductIndex])),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _buildInputField("Remarks", remarksControllers[selectedProductIndex], hint: "Enter remarks"),
                ],
              ),
            ),
            const SizedBox(height: 24),

            SizedBox(
              width: double.infinity,
              height: 44,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                  elevation: 0,
                ),
                onPressed: isUpdating ? null : _updateInspection,
                child: isUpdating 
                  ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                  : const Text(
                      "UPDATE INSPECTION",
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                    ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
