import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:purchase_erp/purchase_request_pdf_viewer.dart';
import 'package:purchase_erp/utils/location_helper.dart';

class RequestApprovalDetailsScreen extends StatefulWidget {
  final Map<String, dynamic> masterData;
  final List<dynamic> itemsData;
  final String? requestedByName;
  final bool isPO;

  const RequestApprovalDetailsScreen({
    super.key,
    required this.masterData,
    required this.itemsData,
    this.requestedByName,
    this.isPO = false,
  });

  @override
  State<RequestApprovalDetailsScreen> createState() =>
      _RequestApprovalDetailsScreenState();
}

class _RequestApprovalDetailsScreenState
    extends State<RequestApprovalDetailsScreen> {
  String? selectedValue = "Request For Quotations";
  final TextEditingController _remarksController = TextEditingController();
  final TextEditingController _approverNameController = TextEditingController();
  final List<TextEditingController> _qtyControllers = [];
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    _initQtyControllers();
  }

  void _initQtyControllers() {
    for (var item in widget.itemsData) {
      final qtyStr =
          item['quantity']?.toString() ??
          item['item_qty']?.toString() ??
          item['qty']?.toString() ??
          item['current_order_quantity']?.toString() ??
          item['quantity_required']?.toString() ??
          '0';
      _qtyControllers.add(TextEditingController(text: qtyStr));
    }
  }

  @override
  void dispose() {
    _remarksController.dispose();
    _approverNameController.dispose();
    for (var controller in _qtyControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  double _calculateTotalQty() {
    double total = 0;
    for (var controller in _qtyControllers) {
      total += double.tryParse(controller.text) ?? 0;
    }
    return total;
  }

  String get rfqNo =>
      widget.masterData['po_no']?.toString() ??
      widget.masterData['no']?.toString() ??
      widget.masterData['requ_no']?.toString() ??
      'N/A';
  String get date =>
      widget.masterData['po_date']?.toString() ??
      widget.masterData['date']?.toString() ??
      widget.masterData['req_date']?.toString() ??
      widget.masterData['dtime']?.toString() ??
      'N/A';
  String get reqDate =>
      widget.masterData['po_date']?.toString() ??
      widget.masterData['req_date']?.toString() ??
      widget.masterData['date']?.toString() ??
      'N/A';
  String get department => widget.masterData['department']?.toString() ?? 'N/A';
  String get requestedBy =>
      widget.requestedByName ??
      widget.masterData['requested_by']?.toString() ??
      widget.masterData['req_by']?.toString() ??
      widget.masterData['supplier_name']?.toString() ??
      'N/A';

  String get title => widget.isPO
      ? "Purchase Order Approval"
      : widget.itemsData.isNotEmpty
          ? (widget.itemsData[0]['product_name']?.toString() ??
                widget.itemsData[0]['pro_name']?.toString() ??
                widget.itemsData[0]['item_description']?.toString() ??
                'Purchase Request')
          : 'Purchase Request';

  Future<void> _callApproveApi() async {
    setState(() => _isProcessing = true);

    final String approverRemarks = _remarksController.text.trim().isNotEmpty
        ? _remarksController.text.trim()
        : "muralii";

    try {
      final prefs = await SharedPreferences.getInstance();
      final String cid = prefs.getString('cid') ?? '123';
      final String deviceId = prefs.getString('device_id') ?? '123';
      final String lt = prefs.getString('lt') ?? '123';
      final String ln = prefs.getString('ln') ?? '987';

      final String uid = prefs.getString('uid') ?? '123';

      final List<Map<String, dynamic>> itemsList = [];
      for (int i = 0; i < widget.itemsData.length; i++) {
        final item = widget.itemsData[i];
        itemsList.add({
          "item_code": item['item_code']?.toString() ?? '',
          "product_name": item['product_name']?.toString() ?? item['pro_name']?.toString() ?? '',
          "uom": item['uom']?.toString() ?? 'nos',
          "current_order_quantity": _qtyControllers[i].text,
          "current_stock_qty": item['current_stock_qty']?.toString() ?? item['qty']?.toString() ?? '0',
          "dod_date": item['dod_date']?.toString() ?? item['date']?.toString() ?? '',
          "description": item['description']?.toString() ?? '',
        });
      }

      final Map<String, String> bodyParams = widget.isPO
          ? {
              "type": "4030",
              "cid": cid,
              "lt": lt,
              "ln": ln,
              "device_id": deviceId,
              "po_id": widget.masterData['id']?.toString() ?? '',
              "uid": uid,
              "role_id": "1",
              "status": "Approved",
              "remarks": approverRemarks,
            }
          : {
              "type": "4011",
              "cid": cid,
              "device_id": deviceId,
              "uid": uid,
              "lt": lt,
              "ln": ln,
              "date": date,
              "req_date": reqDate,
              "requ_no": rfqNo,
              "department": department,
              "req_by": requestedBy,
              "priority": "High",
              "remarks": approverRemarks,
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
            SnackBar(
              content: Text("${widget.isPO ? 'PO' : 'Request'} Approved Successfully"),
              backgroundColor: Colors.green,
            ),
          );
          if (widget.isPO) {
            // Navigator.pop(context, "showGRN"); // Could handle GRN here
            Navigator.pop(context);
          } else {
            Navigator.pop(context);
          }
        } else {
          _showError(data['message'] ?? "Approval failed");
        }
      } else {
        _showError("Server error: ${response.statusCode}");
      }
    } catch (e) {
      _showError("Network error: $e");
    } finally {
      if (mounted) { setState(() => _isProcessing = false); }
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

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: const Color(0xff26A69A),
        elevation: 0,
        centerTitle: false,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              widget.isPO ? "Purchase Order Approval" : "Request Approval",
              style: GoogleFonts.outfit(
                fontWeight: FontWeight.bold,
                color: Colors.white,
                fontSize: 18.sp,
              ),
            ),
            Text(
              "Review details and submit approval",
              style: GoogleFonts.outfit(
                color: Colors.white.withOpacity(0.8),
                fontSize: 11.sp,
                fontWeight: FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: width * 0.04, vertical: 16),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Theme.of(context).dividerColor.withOpacity(0.1)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(Theme.of(context).brightness == Brightness.dark ? 0.2 : 0.04),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        rfqNo,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                      ),
                      if (widget.masterData['pdf_link'] != null && widget.masterData['pdf_link'].toString().isNotEmpty)
                        IconButton(
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                          icon: const Icon(Icons.picture_as_pdf, color: Colors.red, size: 28),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => PurchaseRequestPdfViewer(
                                  pdfUrl: widget.masterData['pdf_link'].toString(),
                                  prNumber: rfqNo,
                                ),
                              ),
                            );
                          },
                        ),
                    ],
                  ),
                  const SizedBox(height: 8),

                  /// TITLE
                  Text(
                    title,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Divider(),
                  const SizedBox(height: 8),

                  _buildInfoItem("Request Date", reqDate),
                  const SizedBox(height: 16),
                  if (widget.isPO)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildInfoItem("Supplier Name", requestedBy, isPurple: true),
                        const SizedBox(height: 16),
                        _buildInfoItem("Supplier GSTIN", widget.masterData['supplier_gstin']?.toString() ?? widget.masterData['gstin']?.toString() ?? 'N/A', isPurple: true),
                        if (widget.masterData['grn_no'] != null && widget.masterData['grn_no'].toString().isNotEmpty) ...[
                          const SizedBox(height: 16),
                          _buildInfoItem("GRN No", widget.masterData['grn_no'].toString(), isPurple: true),
                        ],
                      ],
                    )
                  else
                    Row(
                      children: [
                        Expanded(
                          child: _buildInfoItem(
                            "Department",
                            department,
                            isPurple: true,
                          ),
                        ),
                        Expanded(
                          child: _buildInfoItem(
                            "Requested By",
                            requestedBy,
                            isPurple: true,
                          ),
                        ),
                      ],
                    ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            /// 2. ITEMS LIST SECTION
            Row(
              children: [
                Icon(Icons.list_alt, color: Theme.of(context).primaryColor, size: 20),
                const SizedBox(width: 8),
                Text(
                  "Order Items (${widget.itemsData.length})",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: widget.itemsData.length,
              itemBuilder: (context, index) {
                final item = widget.itemsData[index];
                final itemCode = item['item_code']?.toString() ?? 'N/A';
                final productName = item['product_name']?.toString() ?? item['pro_name']?.toString() ?? 'N/A';
                final uom = (item['uom']?.toString() ?? '').isEmpty ? 'nos' : item['uom'].toString();
                final description = item['description']?.toString() ?? item['item_description']?.toString() ?? '';
                final quantity =
                    item['quantity']?.toString() ??
                    item['item_qty']?.toString() ??
                    item['qty']?.toString() ??
                    item['current_order_quantity']?.toString() ??
                    item['quantity_required']?.toString() ??
                    '0';

                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surface,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Theme.of(context).dividerColor.withOpacity(0.1)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: _buildInfoItem("Item Code", itemCode),
                          ),
                          Container(
                            width: 100.w,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                const Text(
                                  "Quantity",
                                  style: TextStyle(
                                    color: Colors.grey,
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                TextField(
                                  controller: _qtyControllers[index],
                                  textAlign: TextAlign.right,
                                  keyboardType: TextInputType.number,
                                  onChanged: (val) => setState(() {}),
                                  style: const TextStyle(
                                    color: Color(0xff3F1299),
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                  decoration: const InputDecoration(
                                    isDense: true,
                                    border: InputBorder.none,
                                    contentPadding: EdgeInsets.zero,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(child: _buildInfoItem("Product Name", productName)),
                          const SizedBox(width: 16),
                          _buildInfoItem("UOM", uom),
                        ],
                      ),
                      if (description.isNotEmpty) ...[
                        const SizedBox(height: 12),
                        _buildInfoItem("Details", description),
                      ],
                    ],
                  ),
                );
              },
            ),

            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xff3F1299).withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: const Color(0xff3F1299).withValues(alpha: 0.2),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Total QTY",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Colors.black87,
                    ),
                  ),
                  Text(
                    _calculateTotalQty().toStringAsFixed(0),
                    style: const TextStyle(
                      color: Color(0xff3F1299),
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Removed old TextField from here as it's now in the mandatory dialog

            const SizedBox(height: 16),

            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xffD1D1D1), width: 1),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: selectedValue,
                  isExpanded: true,
                  icon: const Icon(
                    Icons.keyboard_arrow_down,
                    color: Colors.black,
                    size: 28,
                  ),
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                  items: ["Request For Quotations"].map((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                  onChanged: (newValue) {
                    setState(() {
                      selectedValue = newValue;
                    });
                  },
                ),
              ),
            ),

            const SizedBox(height: 24),

            InkWell(
              onTap: _isProcessing ? null : () async {
                final hasLocation = await LocationHelper.checkLocationEnabled(context);
                if (!hasLocation) return;
                _showMandatoryConfirmDialog(context);
              },
              child: Container(
                height: 52,
                decoration: BoxDecoration(
                  color: _isProcessing ? Colors.grey : const Color(0xff26A69A),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    if (!_isProcessing)
                      BoxShadow(
                        color: const Color(0xff26A69A).withOpacity(0.3),
                        blurRadius: 12,
                        offset: const Offset(0, 6),
                      ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (_isProcessing)
                      const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    else ...[
                      const Icon(
                        Icons.check_circle_outline,
                        color: Colors.white,
                        size: 22,
                      ),
                      const SizedBox(width: 10),
                    ],
                    Text(
                      _isProcessing ? "Processing..." : "Approve Now",
                      style: GoogleFonts.outfit(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 17,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // Rejected button removed
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  void _showMandatoryConfirmDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => AlertDialog(
        title: const Text("Confirm Approval", style: TextStyle(fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (!widget.isPO) ...[
              TextField(
                controller: _approverNameController,
                decoration: const InputDecoration(
                  labelText: "Approver Name",
                  hintText: "Enter Name",
                ),
              ),
              const SizedBox(height: 16),
            ],
            TextField(
              controller: _remarksController,
              maxLines: 2,
              decoration: const InputDecoration(
                labelText: "Remarks",
                hintText: "Enter Remarks",
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xff26A69A)),
            onPressed: () {
              Navigator.pop(context);
              _showApproveDialog(context);
            },
            child: const Text("Confirm", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoItem(String label, String value, {bool isPurple = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Colors.black, fontSize: 12)),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            color: isPurple ? const Color(0xff3F1299) : Colors.black87,
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
      ],
    );
  }

  void _showApproveDialog(BuildContext context) {
    final approver = _approverNameController.text.trim();
    final remarks = _remarksController.text.trim();
    final displayName = approver.isNotEmpty ? approver : "Admin";

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: const Color(0xff188E24).withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.check_circle,
                    color: Color(0xff188E24),
                    size: 60,
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  "Approved !",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 24,
                    color: Colors.black,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  "${widget.isPO ? 'PO' : 'Request'} Approved Successfully",
                  style: const TextStyle(color: Colors.black, fontSize: 14),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                _buildDialogRow(
                  widget.isPO ? "PO No" : "PR No",
                  rfqNo,
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 8.0),
                  child: Divider(),
                ),
                if (!widget.isPO) ...[
                  _buildDialogRow("Approved By", displayName),
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 8.0),
                    child: Divider(),
                  ),
                ],
                _buildDialogRow(
                  "Total Items",
                  widget.itemsData.length.toString(),
                ),
                const SizedBox(height: 32),
                InkWell(
                  onTap: () {
                    Navigator.pop(context);
                    _callApproveApi();
                  },
                  child: Container(
                    width: double.infinity,
                    height: 44,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: const Color(0xff26A69A),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text(
                      "Ok",
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // Removed _showRejectDialog as reject flow is removed

  Widget _buildDialogRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontWeight: FontWeight.w500,
            fontSize: 14,
            color: Colors.black,
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 14,
            color: Colors.black,
          ),
        ),
      ],
    );
  }
}
