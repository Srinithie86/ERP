import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'quotation_details.dart';
import '../purchase_request_pdf_viewer.dart';

class SupplierQuotationsScreen extends StatefulWidget {
  const SupplierQuotationsScreen({super.key});

  @override
  State<SupplierQuotationsScreen> createState() => _SupplierQuotationsScreenState();
}

class _SupplierQuotationsScreenState extends State<SupplierQuotationsScreen> {
  String selectedFilter = "All";
  late Future<List<Map<String, dynamic>>> quotationsFuture;

  @override
  void initState() {
    super.initState();
    quotationsFuture = fetchQuotations();
  }

  Future<List<Map<String, dynamic>>> fetchQuotations() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? cid = prefs.getString('cid');
      final String? uid = prefs.getString('uid');
      final String? roleId = prefs.getString('role_id');
      final String? deviceId = prefs.getString('device_id');
      final String? lt = prefs.getString('lt');
      final String? ln = prefs.getString('ln');

      final url = Uri.parse("https://erpsmart.in/total/api/m_api/");
      final response = await http.post(
        url,
        body: {
          "type": "4032",
          "cid": cid ?? "44555666",
          "lt": lt ?? "123",
          "ln": ln ?? "123",
          "device_id": deviceId ?? "123",
          "uid": uid ?? "2",
          "role_id": roleId ?? "0",
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        if (data['error'] == false && data['data'] != null) {
          return List<Map<String, dynamic>>.from(data['data']);
        } else {
          throw data['message'] ?? "Failed to load quotations";
        }
      } else {
        throw "Server error: ${response.statusCode}";
      }
    } catch (e) {
      debugPrint("API Error: $e");
      rethrow;
    }
  }

  List<Map<String, dynamic>> _filterQuotations(List<Map<String, dynamic>> allQuotations) {
    if (selectedFilter == "All") return allQuotations;
    return allQuotations.where((q) {
      final status = q['status']?.toString() ?? "";
      return status.toLowerCase() == selectedFilter.toLowerCase();
    }).toList();
  }

  Future<void> _showSelectionConfirm(Map<String, dynamic> item) async {
    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Confirm Selection"),
          content: Text("Are you sure you want to select ${item['supplier_name'] ?? 'this supplier'} and approve this quotation?"),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xff26A69A)),
              onPressed: () => Navigator.pop(context, true),
              child: const Text("Yes, Select", style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );

    if (confirmed == true) {
      await _approveQuotation(item['id'].toString());
    }
  }

  Future<void> _approveQuotation(String quotId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? cid = prefs.getString('cid');
      final String? deviceId = prefs.getString('device_id');
      final String? lt = prefs.getString('lt');
      final String? ln = prefs.getString('ln');

      final url = Uri.parse("https://erpsmart.in/total/api/m_api/");
      final response = await http.post(
        url,
        body: {
          "type": "4033",
          "cid": cid ?? "44555666",
          "lt": lt ?? "123",
          "ln": ln ?? "123",
          "device_id": deviceId ?? "123",
          "id": quotId,
          "status": "Approved",
        },
      );

      final Map<String, dynamic> result = json.decode(response.body);
      if (result['error'] == false) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Quotation approved successfully!")),
        );
        setState(() {
          quotationsFuture = fetchQuotations();
        });
      } else {
        throw result['message'] ?? "Failed to approve quotation";
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
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
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Supplier Quotations",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      body: Column(
        children: [
          const SizedBox(height: 12),

          /// TOP FILTERS ROW
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                filterChip("All"),
                filterChip("Approved"),
                filterChip("PO Generated"),
              ],
            ),
          ),

          const SizedBox(height: 12),

          /// LIST OF QUOTATIONS
          Expanded(
            child: FutureBuilder<List<Map<String, dynamic>>>(
              future: quotationsFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator(color: Color(0xff26A69A)));
                } else if (snapshot.hasError) {
                  return Center(child: Text("Error: ${snapshot.error}"));
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(child: Text("No quotations found."));
                }

                final filteredList = _filterQuotations(snapshot.data!);

                if (filteredList.isEmpty) {
                  return const Center(child: Text("No data matching this filter."));
                }

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: filteredList.length,
                  itemBuilder: (context, index) {
                    final item = filteredList[index];
                    
                    double totalAmount = 0;
                    final items = item['items'] as List?;
                    String firstItemName = "No Items";
                    String firstItemRate = "₹0";
                    
                    if (items != null && items.isNotEmpty) {
                      firstItemName = items[0]['item_description'] ?? "N/A";
                      firstItemRate = "₹${items[0]['unit_rate'] ?? '0'}";
                      
                      for (var subItem in items) {
                        final rate = double.tryParse(subItem['unit_rate']?.toString() ?? "0") ?? 0;
                        final qty = double.tryParse(subItem['quoted_qty']?.toString() ?? "0") ?? 0;
                        totalAmount += (rate * qty);
                      }
                    }

                    return Column(
                      children: [
                        quotationCard(
                          width,
                          supplierName: item['supplier_name'] ?? "Unknown",
                          status: item['status'] ?? "Received",
                          quotNo: item['quotation_no'] ?? "N/A",
                          validUntil: item['dtime']?.toString().split(' ')[0] ?? "N/A",
                          itemName: firstItemName,
                          itemRate: firstItemRate,
                          delivery: item['rfq_no'] ?? "", 
                          amount: "₹ ${totalAmount.toStringAsFixed(2)}",
                          isSelected: (item['status'] == "PO Generated" || item['status'] == "Approved"),
                          pdfLink: item['pdf_link'],
                          fullData: item,
                        ),
                        const SizedBox(height: 16),
                      ],
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget filterChip(String label) {
    bool isSelected = selectedFilter == label;
    return GestureDetector(
      onTap: () {
        setState(() {
          selectedFilter = label;
        });
      },
      child: Container(
        margin: const EdgeInsets.only(right: 12),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xff26A69A) : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? Colors.transparent : Colors.grey.shade400,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.grey.shade600,
            fontWeight: FontWeight.w500,
            fontSize: 14,
          ),
        ),
      ),
    );
  }

  Widget quotationCard(
    double width, {
    required String supplierName,
    required String status,
    required String quotNo,
    required String validUntil,
    required String itemName,
    required String itemRate,
    required String delivery,
    required String amount,
    required bool isSelected,
    String? pdfLink,
    required Map<String, dynamic> fullData,
  }) {
    Color statusColor = const Color(0xffC09624); 
    if (status == "Approved") {
      statusColor = const Color(0xff188E24); 
    } else if (status == "PO Generated") {
       statusColor = Colors.blue;
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey.shade300),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  supplierName,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Colors.black,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Row(
                children: [
                  if (pdfLink != null && pdfLink.isNotEmpty)
                    IconButton(
                      icon: const Icon(Icons.picture_as_pdf, color: Color(0xff26A69A), size: 22),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => PurchaseRequestPdfViewer(
                              pdfUrl: pdfLink,
                              prNumber: quotNo,
                            ),
                          ),
                        );
                      },
                    ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
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
            ],
          ),
          const SizedBox(height: 4),
          Text(
            "$quotNo , Date: $validUntil",
            style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
          ),
          const SizedBox(height: 12),

          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    itemName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(color: Colors.grey.shade700, fontSize: 13, fontWeight: FontWeight.w500),
                  ),
                ),
                Text(
                  itemRate,
                  style: const TextStyle(color: Colors.black, fontSize: 14, fontWeight: FontWeight.w500),
                ),
              ],
            ),
          ),

          const SizedBox(height: 12),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  "RFQ: $delivery",
                  style: TextStyle(color: Colors.grey.shade500, fontSize: 12),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Text(
                amount,
                style: const TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          if (status != "PO Generated" && status != "Approved")
          InkWell(
            onTap: () => _showSelectionConfirm(fullData),
            child: Container(
              height: 42,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: isSelected ? const Color(0xffC6FFD0) : Colors.white,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(
                  color: isSelected ? Colors.transparent : const Color(0xff26A69A),
                  width: 1.2,
                ),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.check,
                    color: Color(0xff26A69A),
                    size: 20,
                  ),
                  SizedBox(width: 6),
                  Text(
                    "Select this Supplier",
                    style: TextStyle(
                      color: Color(0xff26A69A),
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 12),

          InkWell(
            onTap: () {
               Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => QuotationDetailsScreen(
                    quotationData: fullData,
                  ),
                ),
              );
            },
            child: Container(
              height: 42,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: const Color(0xff26A69A),
                borderRadius: BorderRadius.circular(6),
              ),
              child: const Text(
                "View Details",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ),
          ), 
        ],
      ),
    );
  }
}
