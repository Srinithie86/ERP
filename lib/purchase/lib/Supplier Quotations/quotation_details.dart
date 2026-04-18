import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'quotation_comparison.dart';
import '../purchase_request_pdf_viewer.dart';

class QuotationDetailsScreen extends StatefulWidget {
  final Map<String, dynamic> quotationData;
  const QuotationDetailsScreen({super.key, required this.quotationData});

  @override
  State<QuotationDetailsScreen> createState() => _QuotationDetailsScreenState();
}

class _QuotationDetailsScreenState extends State<QuotationDetailsScreen> {
  late Map<String, dynamic> currentData;

  @override
  void initState() {
    super.initState();
    currentData = widget.quotationData;
  }

  void _viewPdf() {
    final String? pdfUrl = currentData['pdf_link'];
    if (pdfUrl == null || pdfUrl.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("PDF link not available")),
      );
      return;
    }
    
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PurchaseRequestPdfViewer(
          pdfUrl: pdfUrl, 
          prNumber: currentData['quotation_no'] ?? "Quotation",
        ),
      ),
    );
  }

  Future<void> _approveQuotation() async {
    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Confirm Selection"),
          content: Text("Are you sure you want to select ${currentData['supplier_name'] ?? 'this supplier'} and approve this quotation?"),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xff26A69A)),
              onPressed: () => Navigator.pop(context, true),
              child: const Text("Yes, Select", style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );

    if (confirmed != true) return;

    try {
      final prefs = await SharedPreferences.getInstance();
      final String? cid = prefs.getString('cid');
      final String? deviceId = prefs.getString('device_id');
      final String? lt = prefs.getString('lt');
      final String? ln = prefs.getString('ln');

      final url = Uri.parse("https://erpsmart.in/total/api/m_api/");
      final response = await http.post(
        url,
        body: {
          "type": "4033",
          "cid": cid ?? "44555666",
          "lt": lt ?? "123",
          "ln": ln ?? "123",
          "device_id": deviceId ?? "123",
          "id": currentData['id'].toString(),
          "status": "Approved",
        },
      );

      final Map<String, dynamic> result = json.decode(response.body);
      if (result['error'] == false) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Approved Successfully!")),
        );
        setState(() {
           currentData['status'] = "Approved";
        });
        
        // Navigate to Compare Menu
        Future.delayed(const Duration(seconds: 1), () {
          if (mounted) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const QuotationComparisonScreen()),
            );
          }
        });
      } else {
        throw result['message'] ?? "Failed to approve quotation";
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    }
  }

  double _calculateGrandTotal() {
    double total = 0;
    final items = currentData['items'] as List?;
    if (items != null) {
      for (var item in items) {
        final rate = double.tryParse(item['unit_rate']?.toString() ?? "0") ?? 0;
        final qty = double.tryParse(item['quoted_qty']?.toString() ?? "0") ?? 0;
        final tax = double.tryParse(item['taxes']?.toString() ?? "0") ?? 0;
        final discount = double.tryParse(item['discount']?.toString() ?? "0") ?? 0;
        
        double subtotal = rate * qty;
        subtotal -= (subtotal * discount / 100);
        subtotal += (subtotal * tax / 100);
        total += subtotal;
      }
    }
    return total;
  }

  @override
  Widget build(BuildContext context) {
    final items = currentData['items'] as List? ?? [];
    final status = currentData['status']?.toString() ?? "Received";
    Color statusColor = const Color(0xffC09624);
    if (status == "Approved") statusColor = const Color(0xff188E24);
    else if (status == "PO Generated") statusColor = Colors.blue;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color(0xff26A69A),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          "Quotation Details",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 18.sp,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xff22A79A),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                   Expanded(
                     child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          currentData['quotation_no'] ?? "",
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 20.sp,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          "Date: ${currentData['dtime']?.toString().split(' ')[0] ?? ''}",
                          style: TextStyle(color: Colors.white70, fontSize: 13.sp),
                        ),
                      ],
                                       ),
                   ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: statusColor,
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Text(
                      status,
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 12.sp,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            Row(
              children: [
                Expanded(child: infoBox("SUPPLIER", currentData['supplier_name'] ?? "")),
                const SizedBox(width: 12),
                Expanded(child: infoBox("DELIVERY", currentData['delivery_period'] ?? "")),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(child: infoBox("VALID TILL", currentData['valid_till']?.toString() ?? "")),
                const SizedBox(width: 12),
                Expanded(child: infoBox("RFQ REF", currentData['rfq_no'] ?? "")),
              ],
            ),

            const SizedBox(height: 24),

            Text(
              "PRODUCT RATES",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16.sp,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 12),

            Container(
              decoration: BoxDecoration(
                border: Border.all(color: const Color(0xff22A79A)),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Column(
                children: [
                  Container(
                    color: const Color(0xff22A79A),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Expanded(flex: 2, child: centerText("PRODUCT", isHeader: true)),
                        Expanded(child: centerText("RATE", isHeader: true)),
                        Expanded(child: centerText("QTY", isHeader: true)),
                        Expanded(child: centerText("DIS %", isHeader: true)),
                        Expanded(child: centerText("GST %", isHeader: true)),
                        Expanded(flex: 2, child: centerText("TOTAL", isHeader: true)),
                      ],
                    ),
                  ),

                  if (items.isEmpty)
                    const Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Text("No items available"),
                    ),

                  for (var item in items) ...[
                    tableRow(
                      item['item_description'] ?? "",
                      "₹${item['unit_rate'] ?? '0'}",
                      "${item['quoted_qty'] ?? '0'}",
                      "${item['discount'] ?? '0'}%",
                      "${item['taxes'] ?? '0'}%",
                      "₹${((double.tryParse(item['unit_rate']?.toString() ?? '0') ?? 0) * (double.tryParse(item['quoted_qty']?.toString() ?? '0') ?? 0)).toStringAsFixed(2)}",
                    ),
                    const Divider(height: 1, color: Color(0xff22A79A)),
                  ]
                ],
              ),
            ),

            const SizedBox(height: 16),

            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: const Color(0xffE6FFFF),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Grand Total (incl. GST)",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15.sp,
                      color: Colors.blueGrey,
                    ),
                  ),
                  Text(
                    "₹ ${_calculateGrandTotal().toStringAsFixed(2)}",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18.sp,
                      color: Color(0xff097A1C),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            if (status != "Approved")
            InkWell(
              onTap: _approveQuotation,
              child: Container(
                width: double.infinity,
                height: 48,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: const Color(0xff046259), width: 1.5),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.check, color: Color(0xff046259), size: 18),
                    const SizedBox(width: 8),
                    Text(
                      "Select this Supplier",
                      style: TextStyle(
                        color: Color(0xff046259),
                        fontWeight: FontWeight.bold,
                        fontSize: 14.sp,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            Row(
              children: [
                Expanded(
                  child: InkWell(
                    onTap: _viewPdf,
                    child: Container(
                      height: 44,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: const Color(0xff22A79A),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        "Export PDF",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 15.sp,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const QuotationComparisonScreen(),
                        ),
                      );
                    },
                    child: Container(
                      height: 44,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: const Color(0xff22A79A)),
                      ),
                      child: Text(
                        "Compare All",
                        style: TextStyle(
                          color: Color(0xff22A79A),
                          fontWeight: FontWeight.bold,
                          fontSize: 15.sp,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget infoBox(String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: TextStyle(color: Colors.grey, fontSize: 11.sp)),
          const SizedBox(height: 6),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.bold,
              fontSize: 14.sp,
            ),
          ),
        ],
      ),
    );
  }

  static Widget centerText(String text, {bool isHeader = false}) {
    return Text(
      text,
      textAlign: TextAlign.center,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: TextStyle(
        color: isHeader ? Colors.white : Colors.black87,
        fontWeight: isHeader ? FontWeight.bold : FontWeight.normal,
        fontSize: isHeader ? 12.sp : 11.sp,
      ),
    );
  }

  Widget tableRow(String p, String r, String q, String d, String g, String t) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Expanded(flex: 2, child: centerText(p)),
          Expanded(child: centerText(r)),
          Expanded(child: centerText(q)),
          Expanded(child: centerText(d)),
          Expanded(child: centerText(g)),
          Expanded(flex: 2, child: centerText(t)),
        ],
      ),
    );
  }
}
