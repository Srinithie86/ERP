import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'quotation_comparison.dart';
import '../purchase_request_pdf_viewer.dart';
import 'package:erp_localization/erp_localization.dart';
import 'approve_quotation_screen.dart';

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
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ApproveQuotationScreen(quotationData: currentData),
      ),
    );
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
          AppLocalization.of("Quotation Details"),
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
                          "${AppLocalization.of('Date')}: ${currentData['dtime']?.toString().split(' ')[0] ?? ''}",
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
                Expanded(child: infoBox(AppLocalization.of("SUPPLIER"), currentData['supplier_name'] ?? "")),
                const SizedBox(width: 12),
                Expanded(child: infoBox(AppLocalization.of("DELIVERY"), currentData['delivery_period'] ?? "")),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(child: infoBox(AppLocalization.of("VALID TILL"), currentData['valid_till']?.toString() ?? "")),
                const SizedBox(width: 12),
                Expanded(child: infoBox(AppLocalization.of("RFQ REF"), currentData['rfq_no'] ?? "")),
              ],
            ),

            const SizedBox(height: 24),

            Text(
              AppLocalization.of("PRODUCT RATES"),
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
                        Expanded(flex: 2, child: centerText(AppLocalization.of("PRODUCT"), isHeader: true)),
                        Expanded(child: centerText(AppLocalization.of("RATE"), isHeader: true)),
                        Expanded(child: centerText(AppLocalization.of("QTY"), isHeader: true)),
                        Expanded(child: centerText(AppLocalization.of("DIS %"), isHeader: true)),
                        Expanded(child: centerText(AppLocalization.of("GST %"), isHeader: true)),
                        Expanded(flex: 2, child: centerText(AppLocalization.of("TOTAL"), isHeader: true)),
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
                    AppLocalization.of("Grand Total (incl. GST)"),
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
                      AppLocalization.of("Select this Supplier"),
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
                        AppLocalization.of("Export PDF"),
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
                        AppLocalization.of("Compare All"),
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
