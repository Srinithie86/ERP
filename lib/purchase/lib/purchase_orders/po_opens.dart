import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:purchase_erp/utils/device_services.dart';
import 'package:purchase_erp/purchase_request_pdf_viewer.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:purchase_erp/core/api_config.dart';

class PODetailsScreen extends StatefulWidget {
  final Map<String, dynamic> poData;
  const PODetailsScreen({super.key, required this.poData});

  @override
  State<PODetailsScreen> createState() => _PODetailsScreenState();
}

class _PODetailsScreenState extends State<PODetailsScreen> {
  bool isActionLoading = false;

  Future<void> _updatePOStatus(String status) async {
    setState(() => isActionLoading = true);
    try {
      final prefs = await SharedPreferences.getInstance();
      final String cid = prefs.getString('cid') ?? '';
      final String uid = prefs.getString('uid') ?? prefs.getString('id') ?? '';
      final String roleId = prefs.getString('role_id') ?? '';
      
      final deviceInfo = await DeviceServices.getAndStoreDeviceInfo();
      final String deviceId = deviceInfo['device_id'] ?? 'unknown';
      final String ln = deviceInfo['ln'] ?? "0.0";
      final String lt = deviceInfo['lt'] ?? "0.0";

      final response = await http.post(
        Uri.parse(await ApiConfig.getBaseUrl()),
        body: {
          "type": "4030",
          "cid": cid,
          "device_id": deviceId,
          "uid": uid,
          "role_id": roleId,
          "lt": lt,
          "ln": ln,
          "po_id": widget.poData["id"].toString(),
          "status": status, // "Approved" or "Rejected"
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['error'] == false || data['error'].toString().toLowerCase() == 'false') {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(data['message'] ?? "PO $status successfully"), backgroundColor: Colors.green),
          );
          Navigator.pop(context, true); // Return true to refresh list
        } else {
          _showError(data['message'] ?? "Failed to update status");
        }
      } else {
        _showError("Server error: ${response.statusCode}");
      }
    } catch (e) {
      _showError("Connection error: $e");
    } finally {
      if (mounted) setState(() => isActionLoading = false);
    }
  }

  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  @override
  Widget build(BuildContext context) {
    final item = widget.poData;
    final String rawStatus = (item["status_text"] ?? "Pending").toString();
    String displayStatus = rawStatus;
    if (rawStatus == "1" || rawStatus == "" || rawStatus == "null" || rawStatus.toLowerCase().contains("approve po generated")) {
      displayStatus = "Pending";
    }
    final pdfLink = item["pdf_link"];
    const primaryTeal = Color(0xFF26A69A);

    return Scaffold(
      backgroundColor: const Color(0xffF8F9FA),
      appBar: AppBar(
        backgroundColor: primaryTeal,
        elevation: 0,
        title: Text("PO Details", style: GoogleFonts.outfit(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 18)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(item, displayStatus, primaryTeal),
            const SizedBox(height: 16),
            _buildDetailsCard(item),
            const SizedBox(height: 16),
            _buildItemCard(item, primaryTeal),
            const SizedBox(height: 24),
            if (pdfLink != null && pdfLink.toString().isNotEmpty)
              ElevatedButton.icon(
                onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => PurchaseRequestPdfViewer(pdfUrl: pdfLink, prNumber: item["po_no"] ?? "PO"))),
                icon: const Icon(Icons.picture_as_pdf),
                label: const Text("View PDF Document"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red.shade700,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            const SizedBox(height: 16),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(Map<String, dynamic> item, String status, Color teal) {
    Color statusColor = status.toLowerCase().contains("approve") ? Colors.green : (status.toLowerCase().contains("reject") ? Colors.red : Colors.orange);
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: teal.withOpacity(0.1), shape: BoxShape.circle),
            child: Icon(Icons.assignment, color: teal),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item["po_no"] ?? "N/A", style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold)),
                Text(item["po_date"] ?? "", style: GoogleFonts.outfit(color: Colors.grey)),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(color: statusColor.withOpacity(0.1), borderRadius: BorderRadius.circular(20)),
            child: Text(status, style: GoogleFonts.outfit(color: statusColor, fontWeight: FontWeight.bold, fontSize: 12)),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailsCard(Map<String, dynamic> item) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
      ),
      child: Column(
        children: [
          _detailRow("Supplier", (item["supplier_name"] ?? "N/A").toString()),
          const Divider(height: 24),
          _detailRow("Quotation Ref", (item["quotation_ref"] ?? "N/A").toString()),
          const Divider(height: 24),
          _detailRow("Payment Terms", (item["payment_terms"] ?? "N/A").toString()),
          const Divider(height: 24),
          _detailRow("Delivery Date", (item["delivery_date"] ?? "N/A").toString()),
        ],
      ),
    );
  }

  Widget _buildItemCard(Map<String, dynamic> poData, Color teal) {
    final List<dynamic> items = poData["items"] ?? [];
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Order Items", style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 16),
          
          if (items.isEmpty)
            Text("No items found", style: GoogleFonts.outfit(color: Colors.grey))
          else
            Column(
              children: items.map((item) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text((item["pro_name"] ?? "Unknown Product").toString(), 
                        style: GoogleFonts.outfit(fontWeight: FontWeight.w600)),
                      Text("Code: ${(item["item_code"] ?? "N/A").toString()}", 
                        style: GoogleFonts.outfit(color: Colors.grey, fontSize: 13)),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _itemStat("Qty", (item["qty"] ?? item["quantity"] ?? "0").toString()),
                          _itemStat("Rate", "₹${(item["unit_rate"] ?? "0").toString()}"),
                          _itemStat("Tax", "${(item["tax"] ?? "0").toString()}%"),
                          _itemStat("Discount", "${(item["discount"] ?? "0").toString()}%"),
                        ],
                      ),
                      if (items.indexOf(item) != items.length - 1)
                        const Padding(
                          padding: EdgeInsets.only(top: 16),
                          child: Divider(height: 1),
                        ),
                    ],
                  ),
                );
              }).toList(),
            ),
            
          const Divider(height: 32),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("Total Amount", style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 16)),
              Text("₹${(poData["tot_amt"] ?? "0").toString()}", 
                style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 20, color: teal)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _detailRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: GoogleFonts.outfit(color: Colors.grey.shade600)),
        const SizedBox(width: 8),
        Expanded(child: Text(value, textAlign: TextAlign.end, style: GoogleFonts.outfit(fontWeight: FontWeight.w600), overflow: TextOverflow.ellipsis)),
      ],
    );
  }

  Widget _itemStat(String label, String value) {
    return Column(
      children: [
        Text(label, style: GoogleFonts.outfit(color: Colors.grey, fontSize: 12)),
        Text(value, style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
      ],
    );
  }
}