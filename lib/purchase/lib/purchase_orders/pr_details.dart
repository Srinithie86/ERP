import 'package:flutter/material.dart';
import 'package:purchase_erp/models/pr_model.dart';
import 'package:purchase_erp/purchase_request_pdf_viewer.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PRDetailsScreen extends StatefulWidget {
  final String prId;
  final String department;
  final String status;
  final PrData? prFullData;
  final String? pdfLink;

  const PRDetailsScreen({
    super.key,
    required this.prId,
    required this.department,
    required this.status,
    this.prFullData,
    this.pdfLink,
  });

  @override
  State<PRDetailsScreen> createState() => _PRDetailsScreenState();
}

class _PRDetailsScreenState extends State<PRDetailsScreen> {
  PrData? _currentPrData;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _currentPrData = widget.prFullData;
  }

  double _calculateTotalQty() {
    if (_currentPrData == null) {
      return 0;
    }
    double total = 0;
    if (_currentPrData!.items.isNotEmpty) {
      for (var item in _currentPrData!.items) {
        final qtyStr = item.quantityRequired ?? item.qty ?? '0';
        total += double.tryParse(qtyStr) ?? 0;
      }
    } else {
      total = double.tryParse(_currentPrData!.master.quantityRequired) ?? 0;
    }
    return total;
  }

  Future<void> _sendForApproval() async {
    if (_currentPrData == null) return;
    setState(() => _isLoading = true);

    try {
      final prefs = await SharedPreferences.getInstance();
      final String cid = prefs.getString('cid') ?? '';
      final String uid = prefs.getString('uid') ?? '';
      final String deviceId = prefs.getString('device_id') ?? '';
      final String lt = prefs.getString('lt') ?? '';
      final String ln = prefs.getString('ln') ?? '';

      final master = _currentPrData!.master;
      final items = _currentPrData!.items;

      final List<Map<String, dynamic>> itemsList = [];
      for (var item in items) {
        itemsList.add({
          "item_code": item.itemCode ?? '',
          "product_name": item.productName ?? '',
          "uom": item.uom ?? 'nos',
          "current_order_quantity": item.quantityRequired ?? item.qty ?? '0',
          "current_stock_qty": item.qty ?? '0',
          "dod_date": item.date ?? '',
          "description": item.itemDescription ?? '',
        });
      }

      final Map<String, String> bodyParams = {
        "type": "4011",
        "cid": cid,
        "device_id": deviceId,
        "uid": uid,
        "lt": lt,
        "ln": ln,
        "date": master.reqDate,
        "req_date": master.reqDate,
        "requ_no": widget.prId,
        "department": widget.department,
        "req_by": master.requestedBy ?? 'Admin',
        "priority": master.priority ?? "High",
        "remarks": master.remarks ?? "Resending for approval",
        "items": jsonEncode(itemsList),
      };

      final response = await http.post(
        Uri.parse('https://erpsmart.in/total/api/m_api/'),
        body: bodyParams,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['error'] == false) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("PR Sent For Approval Successfully"),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.pop(context);
        } else {
          _showError(data['message'] ?? "Failed to send for approval");
        }
      } else {
        _showError("Server error: ${response.statusCode}");
      }
    } catch (e) {
      _showError("Network error: $e");
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final width = size.width;

    final master = _currentPrData?.master;
    final items = _currentPrData?.items ?? [];

    // Colors matching the image
    const Color primaryTeal = Color(0xff26A69A);
    const Color primaryPurple = Color(0xff3F1299);
    const Color statusGreen = Color(0xff0F8C2A);
    const Color lightGrey = Color(0xff757575);

    Color statusColor = statusGreen;
    if (widget.status == "Pending") statusColor = const Color(0xFFC89211);
    if (widget.status == "Rejected") statusColor = const Color(0xFFAD0F14);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: primaryTeal,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          "PR Details",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 18.sp,
          ),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: EdgeInsets.all(width * 0.04),
              child: Column(
                children: [
                  /// 1. TOP INFO CARD
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  widget.prId,
                                  style: TextStyle(
                                    color: primaryPurple,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 17.sp,
                                  ),
                                ),
                                Text(
                                  widget.department,
                                  style: TextStyle(
                                    color: lightGrey,
                                    fontSize: 13.sp,
                                  ),
                                ),
                              ],
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: statusColor,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                widget.status == "Approve"
                                    ? "Approved"
                                    : widget.status,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12.sp,
                                ),
                              ),
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "Requested By",
                                    style: TextStyle(color: lightGrey, fontSize: 13.sp),
                                  ),
                                  Text(
                                    (master?.requestedBy != null && master!.requestedBy!.isNotEmpty) ? master.requestedBy! : "Admin",
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 15.sp,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            if (master?.reqDate != null && master!.reqDate.isNotEmpty)
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(
                                    "Requested.Date",
                                    style: TextStyle(color: lightGrey, fontSize: 12.sp),
                                  ),
                                  Text(
                                    master.reqDate,
                                    style: TextStyle(
                                      color: Colors.black54,
                                      fontSize: 13.sp,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "Approver",
                                    style: TextStyle(color: lightGrey, fontSize: 13.sp),
                                  ),
                                  Text(
                                    (master?.approverName != null && master!.approverName!.isNotEmpty) ? master.approverName! : "Manager",
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 15.sp,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(
                                    "Priority",
                                    style: TextStyle(color: lightGrey, fontSize: 13.sp),
                                  ),
                                  Text(
                                    master?.priority ?? "Normal",
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 13.sp,
                                      color: primaryPurple,
                                    ),
                                  ),
                                ],
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  /// 2. REQUESTED ITEM CARD
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Requested Item Details",
                          style: TextStyle(
                            color: primaryPurple,
                            fontWeight: FontWeight.bold,
                            fontSize: 15.sp,
                          ),
                        ),
                        const SizedBox(height: 12),
                        if (items.isEmpty)
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Total Bulk Qty: ${master?.quantityRequired ?? '0'}",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14.sp,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                "No individual item breakdown available",
                                style: TextStyle(
                                  color: Colors.grey,
                                  fontSize: 12.sp,
                                  fontStyle: FontStyle.italic,
                                ),
                              ),
                              const SizedBox(height: 12),
                            ],
                          )
                        else
                          ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: items.length,
                            itemBuilder: (context, index) {
                              final item = items[index];
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 12.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      (item.productName != null && item.productName!.isNotEmpty)
                                          ? item.productName!
                                          : (item.itemCode != null && item.itemCode!.isNotEmpty)
                                              ? item.itemCode!
                                              : "Product: ",
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14.sp,
                                      ),
                                    ),
                                    Text(
                                      "Qty: ${item.quantityRequired ?? item.qty ?? '0'} ${item.uom ?? ''}",
                                      style: TextStyle(
                                        color: lightGrey,
                                        fontSize: 13.sp,
                                      ),
                                    ),
                                    if (item.itemDescription != null &&
                                        item.itemDescription!.isNotEmpty)
                                      Text(
                                        "Notes: ${item.itemDescription!}",
                                        style: TextStyle(
                                          color: lightGrey,
                                          fontSize: 12.sp,
                                        ),
                                      ),
                                  ],
                                ),
                              );
                            },
                          ),
                        const Divider(),
                        Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                "Grand Total QTY",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15.sp,
                                ),
                              ),
                              Text(
                                _calculateTotalQty().toStringAsFixed(0),
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18.sp,
                                  color: primaryTeal,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  /// 3. REMARKS CARD
                  if (master?.remarks != null && master!.remarks!.isNotEmpty)
                    Container(
                      width: double.infinity,
                      margin: const EdgeInsets.only(bottom: 16),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Requester Remarks",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 15.sp,
                              color: primaryPurple,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            master!.remarks!,
                            style: TextStyle(color: Colors.black87, fontSize: 13.sp),
                          ),
                        ],
                      ),
                    ),

                  const SizedBox(height: 16),

                  /// 4. APPROVED BY (BOTTOM CARD)
                  if (widget.status == "Approve" || widget.status == "Approved")
                    Container(
                      width: double.infinity,
                      margin: const EdgeInsets.only(bottom: 24),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xffE8F5E9),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Approved By",
                            style: TextStyle(
                              color: Color(0xff2E7D32),
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            "${master?.approvedByName ?? 'Approver'} ${master?.approvedDate ?? ''}",
                            style: const TextStyle(
                              color: Color(0xff43A047),
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),

                  /// 5. BOTTOM BUTTONS
                  Row(
                    children: [
                      Expanded(
                        child: SizedBox(
                          height: 48,
                          child: ElevatedButton(
                            onPressed: () {
                              if (widget.pdfLink != null && widget.pdfLink!.isNotEmpty) {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => PurchaseRequestPdfViewer(
                                      pdfUrl: widget.pdfLink!,
                                      prNumber: widget.prId,
                                    ),
                                  ),
                                );
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: primaryTeal,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: const Text(
                              "Print DCPDF",
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: SizedBox(
                          height: 48,
                          child: OutlinedButton(
                            onPressed: _sendForApproval,
                            style: OutlinedButton.styleFrom(
                              side: const BorderSide(color: primaryTeal),
                              foregroundColor: primaryTeal,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: const Text(
                              "Send For Approval",
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
    );
  }
}
