import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class RequestApprovalDetailsScreen extends StatefulWidget {
  final Map<String, dynamic> masterData;
  final List<dynamic> itemsData;
  final String? requestedByName;

  const RequestApprovalDetailsScreen({
    super.key,
    required this.masterData,
    required this.itemsData,
    this.requestedByName,
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
  bool _isProcessing = false;

  @override
  void dispose() {
    _remarksController.dispose();
    _approverNameController.dispose();
    super.dispose();
  }

  double _calculateTotalQty() {
    double total = 0;
    for (var item in widget.itemsData) {
      final qtyStr =
          item['current_order_quantity']?.toString() ??
          item['quantity_required']?.toString() ??
          item['qty']?.toString() ??
          '0';
      total += double.tryParse(qtyStr) ?? 0;
    }
    return total;
  }

  String get rfqNo =>
      widget.masterData['no']?.toString() ??
      widget.masterData['requ_no']?.toString() ??
      'N/A';
  String get date =>
      widget.masterData['date']?.toString() ??
      widget.masterData['req_date']?.toString() ??
      widget.masterData['dtime']?.toString() ??
      'N/A';
  String get reqDate =>
      widget.masterData['req_date']?.toString() ??
      widget.masterData['date']?.toString() ??
      'N/A';
  String get department => widget.masterData['department']?.toString() ?? 'N/A';
  String get requestedBy =>
      widget.requestedByName ??
      widget.masterData['requested_by']?.toString() ??
      widget.masterData['req_by']?.toString() ??
      'N/A';

  String get title => widget.itemsData.isNotEmpty
      ? (widget.itemsData[0]['product_name']?.toString() ??
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

      final Map<String, String> bodyParams = {
        "type": "4011",
        "cid": cid,
        "device_id": deviceId,
        "uid": uid,
        "lt": lt,
        "ln": ln,
        "req_date": reqDate,
        "requ_no": rfqNo,
        "department": department,
        "req_by": requestedBy,
        "priority": "low",
        "remarks": approverRemarks,
      };
      bodyParams.addAll(_buildItemsQueryParams());

      final response = await http.post(
        Uri.parse('https://erpsmart.in/total/api/m_api/'),
        headers: {'Content-Type': 'application/x-www-form-urlencoded'},
        body: bodyParams,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['error'] == false) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Request Approved Successfully"),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.pop(context);
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

  Future<void> _callRejectApi() async {
    setState(() => _isProcessing = true);

    try {
      final prefs = await SharedPreferences.getInstance();
      final String cid = prefs.getString('cid') ?? '44555666';
      final String deviceId = prefs.getString('device_id') ?? '123';
      final String lt = prefs.getString('lt') ?? '123';
      final String ln = prefs.getString('ln') ?? '987';

      final String uid = prefs.getString('uid') ?? '123';

      final Map<String, String> bodyParams = {
        "type": "4012",
        "cid": cid,
        "device_id": deviceId,
        "uid": uid,
        "lt": lt,
        "ln": ln,
        "requ_no": rfqNo,
      };

      final response = await http.post(
        Uri.parse('https://erpsmart.in/total/api/m_api/'),
        headers: {'Content-Type': 'application/x-www-form-urlencoded'},
        body: bodyParams,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['error'] == false) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Request Rejected Successfully"),
              backgroundColor: Colors.red,
            ),
          );
          Navigator.pop(context);
        } else {
          _showError(data['message'] ?? "Rejection failed");
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

  Map<String, String> _buildItemsQueryParams() {
    final Map<String, String> params = {};
    for (int i = 0; i < widget.itemsData.length; i++) {
      final item = widget.itemsData[i];
      params['item_code[]'] = item['item_code']?.toString() ?? '';
      params['product_name[]'] = item['product_name']?.toString() ?? '';
      params['uom[]'] = item['uom']?.toString() ?? 'nos';
      params['current_order_quantity[]'] =
          item['current_order_quantity']?.toString() ??
          item['quantity_required']?.toString() ??
          '0';
      params['current_stock_quantity[]'] =
          item['current_stock_qty']?.toString() ?? '0';
      params['description[]'] = item['description']?.toString() ?? '';
    }
    return params;
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
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: const Color(0xff26A69A),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Request Approval Details",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: width * 0.04, vertical: 16),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade200),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
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
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                          color: Colors.black,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),

                  /// TITLE
                  Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Divider(),
                  const SizedBox(height: 8),

                  Row(
                    children: [
                      Expanded(child: _buildInfoItem("Date", date)),
                      Expanded(child: _buildInfoItem("Request Date", reqDate)),
                    ],
                  ),
                  const SizedBox(height: 16),
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
                const Icon(Icons.list_alt, color: Color(0xff26A69A), size: 20),
                const SizedBox(width: 8),
                Text(
                  "Order Items (${widget.itemsData.length})",
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
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
                final productName = item['product_name']?.toString() ?? 'N/A';
                final quantity =
                    item['current_order_quantity']?.toString() ??
                    item['quantity_required']?.toString() ??
                    item['qty']?.toString() ??
                    '0';

                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.grey.shade200),
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
                                    color: Colors.black,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  quantity,
                                  style: const TextStyle(
                                    color: Color(0xff3F1299),
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      _buildInfoItem("Product Name", productName),
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
              onTap: _isProcessing ? null : () => _showMandatoryConfirmDialog(context),
              child: Container(
                height: 50,
                decoration: BoxDecoration(
                  color: _isProcessing ? Colors.grey : const Color(0xff188E24),
                  borderRadius: BorderRadius.circular(10),
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
                        size: 24,
                      ),
                      const SizedBox(width: 8),
                    ],
                    Text(
                      _isProcessing ? "Approving..." : "Approve",
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
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
            TextField(
              controller: _approverNameController,
              decoration: const InputDecoration(
                labelText: "Approver Name",
                hintText: "Enter Name",
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _remarksController,
              maxLines: 2,
              decoration: const InputDecoration(
                labelText: "Remarks (Mandatory)",
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
              if (_remarksController.text.trim().isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Remarks are mandatory!"), backgroundColor: Colors.orange),
                );
                return;
              }
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
                const Text(
                  "Request Approved Successfully",
                  style: TextStyle(color: Colors.black, fontSize: 14),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                _buildDialogRow("Approved By", displayName),
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 8.0),
                  child: Divider(),
                ),
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
