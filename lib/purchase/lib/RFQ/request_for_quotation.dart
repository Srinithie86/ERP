import 'package:flutter/material.dart';
import 'package:purchase_erp/RFQ/create_rfq.dart';
import 'package:purchase_erp/RFQ/rfq_selection.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:purchase_erp/utils/device_services.dart';

class RFQScreen extends StatefulWidget {
  const RFQScreen({super.key});

  @override
  State<RFQScreen> createState() => _RFQScreenState();
}

class _RFQScreenState extends State<RFQScreen> {
  List<dynamic> rfqList = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchRFQs();
  }

  Future<void> _fetchRFQs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cid = prefs.getString('cid') ?? '';
      final uid = prefs.getString('id') ?? '';
      final roleId = prefs.getString('role_id') ?? '';
      final deviceData = await DeviceServices.getAndStoreDeviceInfo();
      final ln = deviceData['ln'] ?? '0.0';
      final lt = deviceData['lt'] ?? '0.0';
      final deviceId = deviceData['device_id'] ?? 'Unknown';

      final Map<String, dynamic> body = {
        "type": "4016",
        "cid": cid,
        "device_id": deviceId,
        "role_id": roleId,
        "uid": uid,
        "ln": ln,
        "lt": lt,
      };

      debugPrint("API 4016 REQUEST BODY: $body");

      final response = await http.post(
        Uri.parse("https://erpsmart.in/total/api/m_api/"),
        body: body,
      );

      debugPrint("API 4016 RESPONSE BODY: ${response.body}");

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['error'] == false) {
          if (mounted) {
            setState(() {
              rfqList = data['data'] ?? [];
              isLoading = false;
            });
          }
        }
      }
    } catch (e) {
      debugPrint("Fetch RFQ Error: $e");
      if (mounted) setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final width = size.width;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color(0xff26A69A),
        elevation: 0,
        centerTitle: false,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Request for Quotation",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        actions: [
          // "Add New" button hidden temporarily per user request (API not ready)
          /*
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: TextButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const CreateRFQScreen(),
                  ),
                );
              },
              icon: const Icon(Icons.add_circle_outline, color: Colors.white, size: 20),
              label: const Text(
                "New",
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ),
          ),
          */
        ],
      ),
      body: Column(
        children: [
          const SizedBox(height: 8),

          /// RFQ LIST
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator(color: Color(0xff26A69A)))
                : rfqList.isEmpty
                    ? const Center(child: Text("No RFQs Found", style: TextStyle(color: Colors.grey)))
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: rfqList.length,
                        itemBuilder: (context, index) {
                          final item = rfqList[index];
                          String id = item['requ_no']?.toString() ?? "N/A";
                          String status = "Sent"; // Static for now based on UI
                          String deadlineDate = item['delivery_date']?.toString() ?? 'N/A';
                          
                          // Handle dynamic items length for suppliers or products
                          List<dynamic> itemsList = item['items'] ?? [];
                          String requestedText = "${itemsList.length} Products requested";
                          
                          // Collect suppliers safely
                          List<String> suppliers = [];
                          if (item['supplier_name'] != null && item['supplier_name'].toString().isNotEmpty) {
                            suppliers.add(item['supplier_name'].toString());
                          } else {
                            suppliers.add("No Supplier Configured");
                          }

                          String deadline = "Deadline: $deadlineDate - ${suppliers.length} Suppliers";

                          return Padding(
                            padding: const EdgeInsets.only(bottom: 16),
                            child: rfqCard(
                              width,
                              context,
                              id: id,
                              status: status,
                              deadline: deadline,
                              suppliers: suppliers,
                              requestedText: requestedText,
                              statusColor: const Color(0xff188E24), // Green
                              isHighlighted: index == 0,
                              items: itemsList,
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }

  Widget rfqCard(
    double width,
    BuildContext context, {
    required String id,
    required String status,
    required String deadline,
    required List<String> suppliers,
    required String requestedText,
    required Color statusColor,
    required bool isHighlighted,
    required List<dynamic> items,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.grey.shade200,
          width: isHighlighted ? 2.5 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// TOP ROW
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                id,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: Colors.black,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: statusColor,
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Text(
                  status,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            deadline,
            style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
          ),
          const SizedBox(height: 12),

          /// GREY BOX FOR SUPPLIERS
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: suppliers.map((supplier) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 6.0),
                  child: Row(
                    children: [
                      const Text(
                        "• ",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: Colors.black54,
                        ),
                      ),
                      Expanded(
                        child: Text(
                          supplier,
                          style: TextStyle(
                            color: Colors.grey.shade800,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),

          const SizedBox(height: 12),

          /// REQUESTED INFO
          Text(
            requestedText,
            style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
          ),

          const SizedBox(height: 16),

          /// VIEW RFQ BUTTON
          InkWell(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => RFQSelectionScreen(
                    items: items,
                    rfqNo: id, // Pass the RFQ Number (id)
                  ),
                ),
              );
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
                "View RFQ",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
