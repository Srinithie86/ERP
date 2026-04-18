import 'package:flutter/material.dart';
import 'package:purchase_erp/purchase_request_pdf_viewer.dart';

class GrnDetailsScreen extends StatelessWidget {
  final Map<String, dynamic> grnData;
  const GrnDetailsScreen({super.key, required this.grnData});

  @override
  Widget build(BuildContext context) {
    const Color primaryColor = Color(0xff22A79A);
    const Color borderColor = Color(0xffE2E2E2);

    // Dynamic data mapping
    String grnNo = grnData['grn_no'] ?? 'N/A';
    String grnDate = grnData['dtime'] ?? grnData['gnr_date'] ?? 'N/A';
    String poNo = grnData['po_no'] ?? 'N/A';
    String poDate = grnData['po_date'] ?? 'N/A';
    String supplierName = grnData['supplier_name'] ?? grnData['supplier'] ?? 'N/A';
    String invoiceNo = grnData['invoice_no'] ?? 'N/A';
    String purchaseType = grnData['purchase_type'] ?? 'N/A';
    String transportType = grnData['transport_type'] ?? 'N/A';
    String vehicleNo = grnData['vehicle_no'] ?? 'N/A';
    String driverName = grnData['driver_name'] ?? 'N/A';
    String dcNo = grnData['supplier_dc_no'] ?? grnData['warehouse_location'] ?? 'N/A';
    String remarks = grnData['remarks'] ?? 'No remarks';
    String? pdfLink = grnData['pdf_link'];
    List<dynamic> items = grnData['items'] ?? [];

    Widget buildDetailRow(
      String label,
      String value, {
      bool isRed = false,
      bool isLast = false,
    }) {
      return Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  flex: 4,
                  child: Text(
                    label,
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                Expanded(
                  flex: 6,
                  child: Text(
                    value,
                    style: TextStyle(
                      color: isRed ? const Color(0xffD32F2F) : Colors.black87,
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (!isLast) Divider(color: borderColor, height: 1, thickness: 1),
        ],
      );
    }

    Widget buildTableHeader(String text) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
        child: Text(
          text,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 11,
            fontWeight: FontWeight.bold,
          ),
        ),
      );
    }

    Widget buildTableCell(
      String text, {
      bool isBold = false,
      TextAlign align = TextAlign.center,
    }) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
        child: Text(
          text,
          textAlign: align,
          style: TextStyle(
            color: Colors.black87,
            fontSize: 11,
            fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      );
    }

    Widget buildStatusBadge(String status) {
      Color color = Colors.grey;
      if (status.toLowerCase().contains('pass') || status.toLowerCase().contains('accept')) color = Colors.green;
      else if (status.toLowerCase().contains('fail') || status.toLowerCase().contains('reject')) color = Colors.red;
      else if (status.toLowerCase().contains('pend')) color = const Color(0xffC09624);

      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
        decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(4), border: Border.all(color: color.withOpacity(0.5))),
        child: Text(status, style: TextStyle(color: color, fontSize: 9, fontWeight: FontWeight.bold)),
      );
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          "GRN Details",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
        ),
        backgroundColor: primaryColor,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          if (pdfLink != null && pdfLink.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.share, color: Colors.white),
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => PurchaseRequestPdfViewer(pdfUrl: pdfLink!, prNumber: grnNo)));
              },
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            /// Top Green Card
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(color: primaryColor, borderRadius: BorderRadius.circular(8)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(grnNo, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(12)),
                        child: Text(grnData['qc_status'] ?? 'Pending', style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  const Text("Good Receipt Note (Expanded View)", style: TextStyle(color: Colors.white70, fontSize: 12)),
                ],
              ),
            ),
            const SizedBox(height: 16),

            /// Details Card
            Container(
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8), border: Border.all(color: borderColor)),
              child: Column(
                children: [
                  buildDetailRow("GRN No", grnNo),
                  buildDetailRow("GRN Date", grnDate),
                  buildDetailRow("PO No.", poNo, isRed: true),
                  buildDetailRow("PO Date", poDate),
                  buildDetailRow("Supplier", supplierName),
                  buildDetailRow("Invoice No.", invoiceNo),
                  buildDetailRow("Purchase Type", purchaseType),
                  buildDetailRow("Transport Type", transportType),
                  buildDetailRow("Vehicle No.", vehicleNo),
                  buildDetailRow("Driver Name", driverName),
                  buildDetailRow("DC No / Loc.", dcNo, isLast: true),
                ],
              ),
            ),
            const SizedBox(height: 16),

            /// Items Table Header
            const Padding(
              padding: EdgeInsets.only(left: 4, bottom: 8),
              child: Text("PRODUCT INSPECTION DETAILS", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: primaryColor)),
            ),

            /// Items Table
            Container(
              decoration: BoxDecoration(borderRadius: BorderRadius.circular(8)),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: ConstrainedBox(
                    constraints: BoxConstraints(minWidth: MediaQuery.of(context).size.width - 32),
                    child: Table(
                      border: TableBorder.all(color: primaryColor.withOpacity(0.3), width: 1, borderRadius: BorderRadius.circular(8)),
                      columnWidths: const {
                        0: IntrinsicColumnWidth(), // S.No
                        1: FlexColumnWidth(3),     // Product Name
                        2: IntrinsicColumnWidth(), // Ord
                        3: IntrinsicColumnWidth(), // Rcv
                        4: IntrinsicColumnWidth(), // Acc
                        5: IntrinsicColumnWidth(), // Rej
                        6: IntrinsicColumnWidth(), // Status
                      },
                      children: [
                        TableRow(
                          decoration: const BoxDecoration(color: primaryColor),
                          children: [
                            buildTableHeader("S.No"),
                            buildTableHeader("Product Name"),
                            buildTableHeader("Ord"),
                            buildTableHeader("Rcv"),
                            buildTableHeader("Acc"),
                            buildTableHeader("Rej"),
                            buildTableHeader("Status"),
                          ],
                        ),
                        ...items.asMap().entries.map((entry) {
                          int idx = entry.key;
                          var it = entry.value;
                          return TableRow(
                            children: [
                              buildTableCell((idx + 1).toString()),
                              buildTableCell(it['product_name'] ?? it['item_code'] ?? 'N/A', align: TextAlign.left),
                              buildTableCell(it['odr_qty']?.toString() ?? '0'),
                              buildTableCell(it['rec_qty']?.toString() ?? '0'),
                              buildTableCell(it['acc_qty']?.toString() ?? '0', isBold: true),
                              buildTableCell(it['rejected_qty']?.toString() ?? '0', isBold: true),
                              Padding(
                                padding: const EdgeInsets.all(4.0),
                                child: buildStatusBadge(it['qc_status'] ?? 'Pending'),
                              ),
                            ],
                          );
                        }),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),

            /// Remarks
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(color: const Color(0xffF1F8E9), borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.green.withOpacity(0.2))),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("General Remarks", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.black)),
                  const SizedBox(height: 6),
                  Text(remarks, style: const TextStyle(fontSize: 13, color: Colors.black54, fontWeight: FontWeight.w400)),
                ],
              ),
            ),
            const SizedBox(height: 24),

            /// Print GRN Button
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(6),
                ),
                elevation: 0,
              ),
              onPressed: () {
                if (pdfLink != null && pdfLink!.isNotEmpty) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => PurchaseRequestPdfViewer(
                        pdfUrl: pdfLink!,
                        prNumber: grnNo,
                      ),
                    ),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("PDF link not available for this GRN")),
                  );
                }
              },
              child: const Text(
                "Print / View PDF",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
