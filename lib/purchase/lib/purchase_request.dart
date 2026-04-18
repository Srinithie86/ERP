import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:purchase_erp/dashboard.dart';
import 'package:purchase_erp/purchase_orders/pr_details.dart';
import 'package:purchase_erp/purchase_request_pdf_viewer.dart';
import 'package:purchase_erp/models/pr_model.dart';

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
        Uri.parse("https://erpsmart.in/total/api/m_api/"),
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
          leading: widget.isEmbedded ? null : IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const Dashboard())),
          ),
          title: const Text("Purchase Request", style: TextStyle(fontWeight: FontWeight.w600, color: Colors.white)),
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
                      : allData.where((pr) => pr["status"] == (selectedFilter == "Approved" ? "1" : (selectedFilter == "Rejected" ? "2" : "0"))).toList();

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
                hintText: "Search PR number or department....",
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
          itemBuilder: (context) => ["All", "Approved", "Rejected", "Pending"].map((e) => PopupMenuItem(value: e, child: Text(e))).toList(),
        ),
      ],
    );
  }

  Widget _buildErrorState(String error) => Center(child: Text(error, style: const TextStyle(color: Colors.red)));
  Widget _buildEmptyState() => const Center(child: Text("No purchase requests found"));

  Widget prCard(BuildContext context, double width, Map<String, dynamic> fullData) {
    String id = (fullData["no"] ?? fullData["requ_no"] ?? fullData["pr_no"] ?? "N/A").toString();
    String dept = (fullData["department"] ?? fullData["dept_name"] ?? "N/A").toString();
    String status = "Pending";
    if (fullData["status"]?.toString() == "1") status = "Approved";
    else if (fullData["status"]?.toString() == "2" || fullData["status"]?.toString() == "3") status = "Rejected";
    
    String pdfLink = fullData["pdf_link"] ?? "";
    Color bgColor = status == "Approved" ? const Color(0xFF0F8C2A) : (status == "Rejected" ? const Color(0xFFAD0F14) : const Color(0xFFC89211));

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 4))],
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(width: 40, height: 40, decoration: const BoxDecoration(color: Color(0xFF26A69A), shape: BoxShape.circle), child: const Icon(Icons.description, color: Colors.white, size: 20)),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(id, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                    Text(dept, style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
                  ],
                ),
              ),
              if (pdfLink.isNotEmpty) 
                IconButton(
                  icon: const Icon(Icons.picture_as_pdf, color: Colors.red, size: 24),
                  onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => PurchaseRequestPdfViewer(pdfUrl: pdfLink, prNumber: id))),
                ),
              Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4), decoration: BoxDecoration(color: bgColor, borderRadius: BorderRadius.circular(20)), child: Text(status, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 10))),
            ],
          ),
          const SizedBox(height: 12),
          InkWell(
            onTap: () {
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
            child: Container(width: double.infinity, height: 40, alignment: Alignment.center, decoration: BoxDecoration(borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.grey.shade300)), child: const Text("View Details", style: TextStyle(fontWeight: FontWeight.w500, fontSize: 13))),
          ),
        ],
      ),
    );
  }
}
