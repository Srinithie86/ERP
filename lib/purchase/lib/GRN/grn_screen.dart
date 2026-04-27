import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:purchase_erp/utils/device_services.dart';
import 'package:purchase_erp/purchase_request_pdf_viewer.dart';
import '../QC/grn_inspection_screen.dart';
import '../QC/create_qc_inspection.dart';
import 'create_grn_screen.dart';
import 'grn_details_screen.dart';

class GRNScreen extends StatefulWidget {
  const GRNScreen({super.key});

  @override
  State<GRNScreen> createState() => _GRNScreenState();
}

class _GRNScreenState extends State<GRNScreen> {
  List<dynamic> grnList = [];
  bool isLoading = true;
  String? errorMessage;

  final TextEditingController _searchController = TextEditingController();
  String searchQuery = "";

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _fetchGRNData();
  }

  Future<void> _fetchGRNData() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      final prefs = await SharedPreferences.getInstance();
      final cid = prefs.getString('cid') ?? '44555666';
      final uid = prefs.getString('uid') ?? '';
      final deviceData = await DeviceServices.getAndStoreDeviceInfo();
      final ln = deviceData['ln'] ?? '123';
      final lt = deviceData['lt'] ?? '123';
      final deviceId = deviceData['device_id'] ?? '123';

      // Tabs removed, fetch all statuses by passing empty string or generic status.
      // (Using empty string '' to fetch without a specific status override, or whatever the API accepts)
      String statusParam = "";

      final Map<String, String> body = {
        "type": "4034",
        "cid": cid,
        "lt": lt,
        "ln": ln,
        "device_id": deviceId,
        "status": statusParam,
      };

      debugPrint("API 4034 REQUEST BODY: $body");

      final response = await http.post(
        Uri.parse("https://erpsmart.in/total/api/m_api/"),
        body: body,
      );

      debugPrint("API 4034 RESPONSE BODY: ${response.body}");

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['error'] == false) {
          setState(() {
            grnList = data['data'] ?? [];
            isLoading = false;
          });
        } else {
          setState(() {
            errorMessage = data['error_msg'] ?? "Failed to fetch data";
            isLoading = false;
          });
        }
      } else {
        setState(() {
          errorMessage = "Server Error: ${response.statusCode}";
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = "Error: $e";
        isLoading = false;
      });
      debugPrint("GRN Fetch Error: $e");
    }
  }

  Future<void> _approveGRN(dynamic id) async {
    // Show a confirmation dialog or just do it?
    // User message says "here shoiw the list andehe i clcik fopr apppriove"
    // confirming is better for premium UX.
    bool? confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Confirm Approval"),
        content: const Text(
            "Are you sure you want to approve and forward this GRN to store?"),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text("Cancel")),
          TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text("Approve",
                  style: TextStyle(
                      color: Color(0xff22A79A), fontWeight: FontWeight.bold))),
        ],
      ),
    );

    if (confirm != true) return;

    setState(() {
      isLoading = true;
    });

    try {
      final prefs = await SharedPreferences.getInstance();
      final cid = prefs.getString('cid') ?? '44555666';
      final uid = prefs.getString('uid') ?? '2';
      final deviceData = await DeviceServices.getAndStoreDeviceInfo();
      final ln = deviceData['ln'] ?? '123';
      final lt = deviceData['lt'] ?? '123';
      final deviceId = deviceData['device_id'] ?? '123';

      final response = await http.post(
        Uri.parse("https://erpsmart.in/total/api/m_api/"),
        body: {
          "type": "4035",
          "cid": cid,
          "uid": uid,
          "lt": lt,
          "ln": ln,
          "device_id": deviceId,
          "id": id.toString(),
          "status": "Approved",
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == "success") {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                  content: Text("GRN Approved Successfully"),
                  backgroundColor: Color(0xff22A79A)),
            );
            _fetchGRNData(); // Refresh list
          }
        } else {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                  content: Text(data['error_msg'] ?? "Approval failed"),
                  backgroundColor: Colors.red),
            );
            setState(() => isLoading = false);
          }
        }
      } else {
        if (mounted) setState(() => isLoading = false);
      }
    } catch (e) {
      if (mounted) {
        setState(() => isLoading = false);
        debugPrint("Approval Error: $e");
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final filteredList = grnList.where((item) {
      final query = searchQuery.toLowerCase();
      final grnNo = (item['grn_no'] ?? '').toString().toLowerCase();
      final poNo = (item['po_no'] ?? '').toString().toLowerCase();
      final supplier = (item['supplier_name'] ?? item['supplier'] ?? '')
          .toString()
          .toLowerCase();
      final vehicle = (item['vehicle_no'] ?? '').toString().toLowerCase();

      return grnNo.contains(query) ||
          poNo.contains(query) ||
          supplier.contains(query) ||
          vehicle.contains(query);
    }).toList();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color(0xff22A79A),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "GRN",
          style: TextStyle(
              color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
        ),
        centerTitle: false,
        actions: [
          Container(
            margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: const Color(0xff22A79A),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20)),
                elevation: 0,
                padding: const EdgeInsets.symmetric(horizontal: 14),
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const CreateGRNScreen()),
                ).then((_) => _fetchGRNData());
              },
              icon: const Icon(Icons.add, size: 18),
              label: const Text("New",
                  style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          const SizedBox(height: 12),

          /// SEARCH BAR
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
            child: TextField(
              controller: _searchController,
              onChanged: (val) {
                setState(() {
                  searchQuery = val;
                });
              },
              decoration: InputDecoration(
                hintText: ' PO No, Supplier...',
                prefixIcon: const Icon(Icons.search, color: Color(0xff22A79A)),
                suffixIcon: searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, color: Colors.grey),
                        onPressed: () {
                          _searchController.clear();
                          setState(() {
                            searchQuery = "";
                          });
                        },
                      )
                    : null,
                contentPadding:
                    const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
                filled: true,
                fillColor: Colors.grey.shade100,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),

          const SizedBox(height: 12),

          /// 2. GRN LIST
          Expanded(
            child: isLoading
                ? const Center(
                    child: CircularProgressIndicator(color: Color(0xff22A79A)))
                : errorMessage != null
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(errorMessage!,
                                style: const TextStyle(color: Colors.red)),
                            const SizedBox(height: 10),
                            ElevatedButton(
                              onPressed: _fetchGRNData,
                              child: const Text("Retry"),
                            )
                          ],
                        ),
                      )
                    : RefreshIndicator(
                        onRefresh: _fetchGRNData,
                        color: const Color(0xff22A79A),
                        child: grnList.isEmpty
                            ? const Center(child: Text("No GRN records found"))
                            : filteredList.isEmpty
                                ? Center(
                                    child:
                                        Text('No results for "$searchQuery"'))
                                : ListView.builder(
                                    padding: const EdgeInsets.all(16),
                                    itemCount: filteredList.length,
                                    itemBuilder: (context, index) {
                                      final item = filteredList[index];
                                      return Padding(
                                        padding:
                                            const EdgeInsets.only(bottom: 16),
                                        child: grnCard(item),
                                      );
                                    },
                                  ),
                      ),
          ),
        ],
      ),
    );
  }

  Widget grnCard(Map<String, dynamic> item) {
    String grnNo = item['grn_no'] ?? 'N/A';
    String status = item['qc_status'] ?? 'Pending';
    String date = item['dtime'] ?? 'N/A';
    String? pdfLink = item['pdf_link'];
    List<dynamic> itemsData = item['items'] ?? [];

    Color statusColor = const Color(0xffC09624); // Pending
    if (status.toLowerCase() == "accepted" ||
        status.toLowerCase() == "passed") {
      statusColor = const Color(0xff0F8C2A);
    } else if (status.toLowerCase() == "rejected" ||
        status.toLowerCase() == "failed") {
      statusColor = const Color(0xffAD0F14);
    }

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => GrnDetailsScreen(grnData: item),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade200),
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
                Row(
                  children: [
                    Text(
                      grnNo,
                      style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: Colors.black),
                    ),
                    if (pdfLink != null && pdfLink.isNotEmpty) ...[
                      const SizedBox(width: 8),
                      InkWell(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => PurchaseRequestPdfViewer(
                                pdfUrl: pdfLink,
                                prNumber: grnNo,
                              ),
                            ),
                          );
                        },
                        child: const Icon(Icons.picture_as_pdf,
                            color: Colors.red, size: 24),
                      ),
                    ],
                  ],
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusColor,
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Text(
                    status,
                    style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 12),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Text("ID: ${item['id']}  ",
                    style: TextStyle(
                        color: Colors.grey.shade800,
                        fontSize: 13,
                        fontWeight: FontWeight.w500)),
                Text(date,
                    style:
                        TextStyle(color: Colors.grey.shade600, fontSize: 13)),
              ],
            ),
            const SizedBox(height: 12),

            /// GREY BOX FOR ITEMS
            if (itemsData.isNotEmpty)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  children: itemsData.map((it) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              it['product_name'] ??
                                  it['item_code'] ??
                                  'Unknown Item',
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                  color: Colors.grey.shade800,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w400),
                            ),
                          ),
                          Text(
                            "Rcvd: ${it['rec_qty'] ?? '0'}/PO: ${it['odr_qty'] ?? '0'}",
                            style: const TextStyle(
                                color: Colors.black,
                                fontSize: 13,
                                fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ),

            const SizedBox(height: 12),

            /// VEHICLE INFO ROW
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    "Inspector: ${item['inspector_name'] ?? 'Not Assigned'}",
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                  ),
                ),
                Text(
                  "${itemsData.length} Items",
                  style: TextStyle(
                      color: Colors.grey.shade800,
                      fontSize: 13,
                      fontWeight: FontWeight.bold),
                ),
              ],
            ),

            const SizedBox(height: 16),

            /// ACTIONS BUTTONS
            Row(
              children: [
                Expanded(
                  child: InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => GrnDetailsScreen(grnData: item),
                        ),
                      );
                    },
                    child: Container(
                      height: 42,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: const Color(0xff22A79A)),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          Icon(Icons.remove_red_eye_outlined,
                              color: Color(0xff22A79A), size: 18),
                          SizedBox(width: 8),
                          Text(
                            "View Details",
                            style: TextStyle(
                                color: Color(0xff22A79A),
                                fontWeight: FontWeight.bold,
                                fontSize: 13),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                if (pdfLink != null && pdfLink.isNotEmpty) ...[
                  const SizedBox(width: 12),
                  Expanded(
                    child: InkWell(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => PurchaseRequestPdfViewer(
                              pdfUrl: pdfLink,
                              prNumber: grnNo,
                            ),
                          ),
                        );
                      },
                      child: Container(
                        height: 42,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: const Color(0xff22A79A),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: const [
                            Icon(Icons.picture_as_pdf_outlined,
                                color: Colors.white, size: 18),
                            SizedBox(width: 8),
                            Text(
                              "View PDF",
                              style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}
