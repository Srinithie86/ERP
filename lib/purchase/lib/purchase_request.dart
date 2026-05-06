import 'dart:convert';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:purchase_erp/dashboard.dart';
import 'package:purchase_erp/purchase_orders/pr_details.dart';
import 'package:purchase_erp/purchase_request_pdf_viewer.dart';
import 'package:purchase_erp/models/pr_model.dart';
import 'package:purchase_erp/core/api_config.dart';
import 'package:erp_localization/erp_localization.dart';

class PurchaseRequestScreen extends StatefulWidget {
  final bool isEmbedded;
  const PurchaseRequestScreen({super.key, this.isEmbedded = false});

  @override
  State<PurchaseRequestScreen> createState() => _PurchaseRequestScreenState();
}

class _PurchaseRequestScreenState extends State<PurchaseRequestScreen> {
  String selectedFilter = "All";
  late Future<List<Map<String, dynamic>>> prFuture = fetchPurchaseRequests();

  @override
  void initState() {
    super.initState();
  }

  Future<List<Map<String, dynamic>>> fetchPurchaseRequests() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? cid = prefs.getString('cid');

      if (cid == null || cid.isEmpty) throw Exception("CID not found");

      final String deviceId = prefs.getString('device_id') ?? '';
      final String lt = prefs.getString('lt') ?? '0';
      final String ln = prefs.getString('ln') ?? '0';
      final String uid = prefs.getString('uid') ?? prefs.getString('id') ?? '';
      final String roleId = prefs.getString('role_id') ?? '';

      final response = await http.post(
        Uri.parse(await ApiConfig.getBaseUrl()),
        body: {
          "type": "4018",
          "cid": cid,
          "uid": uid,
          "role_id": roleId,
          "ln": ln,
          "lt": lt,
          "device_id": deviceId,
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonData = json.decode(response.body);
        if (jsonData['error'] == false && jsonData['data'] != null) {
          final List<dynamic> dataList = jsonData['data'];
          return dataList.map((item) => Map<String, dynamic>.from(item)).toList();
        } else {
          throw Exception(jsonData['error_msg'] ?? "Failed to load data");
        }
      } else {
        throw Exception("Server error: ${response.statusCode}");
      }
    } catch (e) {
      throw Exception("Error fetching data: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    return PopScope(
      canPop: !widget.isEmbedded,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        if (!widget.isEmbedded) {
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const Dashboard()));
        }
      },
      child: Scaffold(
        backgroundColor: const Color(0xffF2F2F2),
        appBar: AppBar(
          elevation: 0,
          backgroundColor: const Color(0xFF26A69A),
          centerTitle: false,
          leading: widget.isEmbedded ? null : IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const Dashboard())),
          ),
          title: Text(AppLocalization.of("Purchase Request"), style: const TextStyle(fontWeight: FontWeight.w600, color: Colors.white)),
        ),
        body: Padding(
          padding: EdgeInsets.symmetric(horizontal: width * 0.04, vertical: 16),
          child: Column(
            children: [
              _buildSearchAndFilterRow(),
              const SizedBox(height: 16),
              Expanded(
                child: FutureBuilder<List<Map<String, dynamic>>>(
                  future: prFuture,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
                    if (snapshot.hasError) return _buildErrorState(snapshot.error.toString());
                    if (!snapshot.hasData || snapshot.data!.isEmpty) return _buildEmptyState();

                    List<Map<String, dynamic>> allData = snapshot.data!;
                    final filteredData = selectedFilter == "All"
                        ? allData
                        : allData.where((pr) {
                            final s = pr["status"]?.toString();
                            if (selectedFilter == "Approved") return s == "2";
                            if (selectedFilter == "Rejected") return s == "3";
                            if (selectedFilter == "Pending") return s == null || s == "0" || s == "";
                            return false;
                          }).toList();

                    return ListView.builder(
                      itemCount: filteredData.length,
                      itemBuilder: (context, index) {
                        final item = filteredData[index];
                        return prCard(
                          context,
                          width,
                          item,
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSearchAndFilterRow() {
    return Row(
      children: [
        Expanded(
          child: Container(
            height: 50,
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10), border: Border.all(color: Colors.grey.shade300)),
            child: TextField(
              decoration: InputDecoration(
                hintText: AppLocalization.of("Search PR number or department...."),
                hintStyle: TextStyle(color: Colors.grey.shade500, fontSize: 13),
                prefixIcon: const Icon(Icons.search, color: Colors.black, size: 22),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),
        PopupMenuButton<String>(
          icon: const Icon(Icons.filter_list, size: 28),
          onSelected: (val) => setState(() => selectedFilter = val),
          itemBuilder: (context) => ["All", "Approved", "Rejected", "Pending"].map((e) => PopupMenuItem(value: e, child: Text(AppLocalization.of(e)))).toList(),
        ),
      ],
    );
  }

  Widget _buildErrorState(String error) => Center(child: Text(error, style: const TextStyle(color: Colors.red)));
  Widget _buildEmptyState() => Center(child: Text(AppLocalization.of("No purchase requests found")));

  Widget prCard(BuildContext context, double width, Map<String, dynamic> fullData) {
    String id = (fullData["no"] ?? fullData["requ_no"] ?? fullData["pr_no"] ?? "N/A").toString();
    String dept = (fullData["department"] ?? fullData["dept_name"] ?? "N/A").toString();
    String status = "Pending";
    final apiStatus = fullData["status"]?.toString();
    if (apiStatus == "2") {
      status = "Approved";
    } else if (apiStatus == "3") {
      status = "Rejected";
    } else if (apiStatus == null || apiStatus == "0" || apiStatus == "") {
      status = "Pending";
    }

    String pdfLink = fullData["pdf_link"] ?? "";
    
    // Parse items to get a better title
    List itemsList = fullData['items'] ?? [];
    String title = itemsList.isNotEmpty 
        ? (itemsList[0]['product_name'] ?? 'Purchase Request') 
        : 'Purchase Request';
        
    // Date
    String date = (fullData['date'] ?? fullData['req_date'] ?? 'N/A').toString();
    if (date.contains(' ')) date = date.split(' ')[0];

    Color statusColor = status == "Approved"
        ? const Color(0xFF10B981)
        : (status == "Rejected" ? const Color(0xFFEF4444) : const Color(0xFFF59E0B));
        
    Color accentColor = const Color(0xFF26A69A);

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
                              id,
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
                const SizedBox(height: 8),
                if (itemsList.length > 1) ...[
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
                if (pdfLink.isNotEmpty) ...[
                  TextButton.icon(
                    onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => PurchaseRequestPdfViewer(pdfUrl: pdfLink, prNumber: id))),
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
                  onPressed: () {
                    // Convert to PrData object using the updated model
                    PrData prFullData = PrData.fromJson(fullData);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => PRDetailsScreen(
                          prId: id,
                          department: dept,
                          status: status,
                          pdfLink: pdfLink,
                          prFullData: prFullData,
                        ),
                      ),
                    );
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
                    AppLocalization.of("View Details"),
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