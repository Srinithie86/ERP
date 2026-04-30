import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:purchase_erp/dashboard.dart';
import 'package:purchase_erp/purchase_orders/po_opens.dart';
import 'package:purchase_erp/purchase_orders/create_purchase_order.dart';
import 'package:purchase_erp/utils/device_services.dart';
import 'package:purchase_erp/purchase_request_pdf_viewer.dart';
import 'package:google_fonts/google_fonts.dart';

class PurchaseOrdersScreen extends StatefulWidget {
  final bool isEmbedded;
  const PurchaseOrdersScreen({super.key, this.isEmbedded = false});

  @override
  State<PurchaseOrdersScreen> createState() => _PurchaseOrdersScreenState();
}

class _PurchaseOrdersScreenState extends State<PurchaseOrdersScreen> {
  String selectedFilter = "All";
  bool isLoading = true;
  List<dynamic> poData = [];
  final TextEditingController _searchController = TextEditingController();
  Map<String, dynamic> summary = {
    "total_po": 0,
    "approved": 0,
    "rejected": 0,
    "pending": 0,
    "total_value": 0,
  };

  @override
  void initState() {
    super.initState();
    _fetchPOs();
  }

  Future<void> _fetchPOs() async {
    if (!mounted) return;
    setState(() => isLoading = true);
    try {
      final prefs = await SharedPreferences.getInstance();
      final String cid = prefs.getString('cid') ?? '';
      final String uid = prefs.getString('uid') ?? prefs.getString('id') ?? '';
      final String roleId = prefs.getString('role_id') ?? '';
      
      final deviceInfo = await DeviceServices.getAndStoreDeviceInfo();
      final String deviceId = deviceInfo['device_id'] ?? 'unknown';
      final String ln = deviceInfo['ln'] ?? "0.0"; 
      final String lt = deviceInfo['lt'] ?? "0.0";

      if (cid.isEmpty) {
        _showError("Company session expired. Please login again.");
        return;
      }

      final response = await http.post(
        Uri.parse("https://erpsmart.in/total/api/m_api/"),
        body: {
          "type": "4027",
          "cid": cid,
          "device_id": deviceId,
          "uid": uid,
          "role_id": roleId,
          "ln": ln,
          "lt": lt,
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['error'] == false || data['error'].toString().toLowerCase() == 'false') {
          setState(() {
            poData = data['data'] ?? [];
            summary = data['summary'] ?? {
              "total_po": poData.length,
              "approved": 0,
              "rejected": 0,
              "pending": 0,
              "total_value": 0,
            };
            isLoading = false;
          });
        } else {
          _showError(data['message'] ?? "Failed to fetch POs");
        }
      }
    } catch (e) {
      _showError("Connection error: $e");
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message), backgroundColor: Colors.red));
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    const primaryTeal = Color(0xff26A69A);

    final searchQuery = _searchController.text.toLowerCase();
    final filteredData = poData.where((po) {
      final statusMatch = selectedFilter == "All" || po["status_text"] == selectedFilter;
      final poNo = (po["po_no"] ?? "").toString().toLowerCase();
      final supplier = (po["supplier_name"] ?? "").toString().toLowerCase();
      final searchMatch = searchQuery.isEmpty || poNo.contains(searchQuery) || supplier.contains(searchQuery);
      return statusMatch && searchMatch;
    }).toList();

    return PopScope(
      canPop: !widget.isEmbedded,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        if (!widget.isEmbedded) {
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const Dashboard()));
        }
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          titleSpacing: 0,
          backgroundColor: primaryTeal,
          elevation: 0,
          centerTitle: false,
          title: Text("Purchase Orders", style: GoogleFonts.outfit(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 18)),
          leading: widget.isEmbedded ? null : IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const Dashboard())),
          ),
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: 12),
              child: Center(
                child: InkWell(
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const CreatePurchaseOrderScreen())).then((_) => _fetchPOs()),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
                    child: Row(
                      children: [
                        const Icon(Icons.add, size: 16, color: primaryTeal),
                        const SizedBox(width: 4),
                        Text("New", style: GoogleFonts.outfit(color: primaryTeal, fontWeight: FontWeight.bold, fontSize: 12)),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
        body: Padding(
          padding: EdgeInsets.symmetric(horizontal: width * 0.04, vertical: 10),
          child: Column(
            children: [
              // Search & Filter
              Row(
                children: [
                  Expanded(
                    child: Container(
                      height: 50,
                      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10), border: Border.all(color: Colors.grey.shade200)),
                      child: TextField(
                        controller: _searchController,
                        onChanged: (value) => setState(() {}),
                        decoration: InputDecoration(
                          hintText: "Search PO Number....",
                          hintStyle: GoogleFonts.outfit(color: Colors.grey.shade500, fontSize: 14),
                          prefixIcon: const Icon(Icons.search, color: Colors.black54),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  PopupMenuButton<String>(
                    icon: const Icon(Icons.filter_list, size: 28, color: Colors.black87),
                    onSelected: (val) => setState(() => selectedFilter = val),
                    itemBuilder: (context) => [
                      const PopupMenuItem(value: "All", child: Text("All")),
                      const PopupMenuItem(value: "Approved", child: Text("Approved")),
                      const PopupMenuItem(value: "Rejected", child: Text("Rejected")),
                      const PopupMenuItem(value: "Pending", child: Text("Pending")),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Stats
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _statCard(width, "Total POs", summary['total_po']?.toString() ?? "0", const Color(0xff9E8B1E), Icons.inventory_2),
                  _statCard(width, "Approved", summary['approved']?.toString() ?? "0", const Color(0xff088C29), Icons.unarchive),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _statCard(width, "Rejected", summary['rejected']?.toString() ?? "0", const Color(0xffAF1616), Icons.inventory),
                  _statCard(width, "Total Value", "₹${summary['total_value'] ?? '0'}", const Color(0xffB9187D), Icons.account_balance_wallet),
                ],
              ),
              const SizedBox(height: 20),

              Expanded(
                child: isLoading
                    ? const Center(child: CircularProgressIndicator(color: primaryTeal))
                    : RefreshIndicator(
                        onRefresh: _fetchPOs,
                        color: primaryTeal,
                        child: filteredData.isEmpty
                            ? Center(child: Text("No records found", style: GoogleFonts.outfit(color: Colors.grey)))
                            : ListView.builder(
                                padding: EdgeInsets.zero,
                                itemCount: filteredData.length,
                                itemBuilder: (context, index) {
                                  final item = filteredData[index];
                                  final rawStatus = (item["status_text"] ?? "Pending").toString();
                                  String displayStatus = rawStatus;
                                  if (rawStatus == "1" || rawStatus == "" || rawStatus == "null" || rawStatus.toLowerCase().contains("approve po generated")) {
                                    displayStatus = "Pending";
                                  }

                                  return OrderCard(
                                    orderId: item["po_no"] ?? "N/A",
                                    supplier: item["supplier_name"] ?? "Unknown",
                                    price: "₹${item["tot_amt"] ?? "0"}",
                                    status: displayStatus,
                                    date: item["po_date"] ?? "",
                                    pdfLink: item["pdf_link"],
                                    item: item,
                                  );
                                },
                              ),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _statCard(double width, String label, String value, Color color, IconData icon) {
    return Container(
      width: width * 0.44,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(12), boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4, offset: const Offset(0, 2))]),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), shape: BoxShape.circle),
            child: Icon(icon, size: 18, color: Colors.white),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(label, style: GoogleFonts.outfit(color: Colors.white70, fontSize: 11, fontWeight: FontWeight.w500)),
                Text(value, style: GoogleFonts.outfit(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold), overflow: TextOverflow.ellipsis),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class OrderCard extends StatelessWidget {
  final String orderId;
  final String supplier;
  final String price;
  final String status;
  final String date;
  final String? pdfLink;
  final Map<String, dynamic> item;

  const OrderCard({
    super.key, 
    required this.orderId, 
    required this.supplier, 
    required this.price, 
    required this.status, 
    required this.date,
    required this.item,
    this.pdfLink,
  });

  Color _statusColor() {
    final s = status.toLowerCase();
    if (s.contains("approve")) return const Color(0xFF10B981);
    if (s.contains("reject")) return const Color(0xFFEF4444);
    return const Color(0xFFF59E0B);
  }

  @override
  Widget build(BuildContext context) {
    const accentColor = Color(0xFF26A69A);
    final statusColor = _statusColor();

    // Parse items to get title and count
    final List<dynamic> itemsList = item['items'] ?? [];
    final String title = itemsList.isNotEmpty 
        ? (itemsList[0]['pro_name'] ?? itemsList[0]['product_name'] ?? 'Purchase Order')
        : 'Purchase Order';

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: accentColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(Icons.description_rounded, color: accentColor, size: 18),
                        ),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              orderId.isNotEmpty ? orderId : "No PO#",
                              style: GoogleFonts.outfit(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                  color: Colors.blueGrey.shade900),
                            ),
                            Text(
                              date,
                              style: GoogleFonts.outfit(
                                  fontSize: 11,
                                  color: Colors.grey,
                                  fontWeight: FontWeight.w500),
                            ),
                          ],
                        ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: statusColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: statusColor.withOpacity(0.2)),
                      ),
                      child: Text(
                        status,
                        style: GoogleFonts.outfit(
                            color: statusColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 10),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  title,
                  style: GoogleFonts.outfit(
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
                      color: Colors.blueGrey.shade800),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (itemsList.length > 1) ...[
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          "+${itemsList.length - 1} more items",
                          style: GoogleFonts.outfit(
                              fontSize: 11,
                              color: Colors.grey.shade700,
                              fontWeight: FontWeight.w600),
                        ),
                      ),
                    ],
                  ),
                ],
                const SizedBox(height: 8),
                Text(
                  "Supplier: $supplier",
                  style: GoogleFonts.outfit(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                      fontWeight: FontWeight.w500),
                ),
                Text(
                  "Ref: ${item['quotation_ref'] ?? 'N/A'}",
                  style: GoogleFonts.outfit(
                      fontSize: 12,
                      color: Colors.grey.shade400,
                      fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 12),
                Text(
                  price,
                  style: GoogleFonts.outfit(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      color: accentColor),
                ),
              ],
            ),
          ),
          Container(
            height: 1,
            color: Colors.grey.shade100,
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                if (pdfLink != null && pdfLink!.isNotEmpty) ...[
                  TextButton.icon(
                    onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => PurchaseRequestPdfViewer(pdfUrl: pdfLink!, prNumber: orderId))),
                    icon: const Icon(Icons.picture_as_pdf_rounded, color: Colors.redAccent, size: 18),
                    label: Text(
                      "PDF",
                      style: GoogleFonts.outfit(
                          color: Colors.redAccent,
                          fontWeight: FontWeight.w600,
                          fontSize: 13),
                    ),
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                  ),
                  const SizedBox(width: 8),
                ],
                ElevatedButton(
                  onPressed: () async {
                    final result = await Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => PODetailsScreen(poData: item)),
                    );
                    if (result == true) {
                      final state = context.findAncestorStateOfType<_PurchaseOrdersScreenState>();
                      state?._fetchPOs();
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: accentColor,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    "View Details",
                    style: GoogleFonts.outfit(
                        fontWeight: FontWeight.w600, fontSize: 13),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
