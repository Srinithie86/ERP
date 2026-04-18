import 'package:flutter/material.dart';
import 'grn_inspection_screen.dart';
import 'create_qc_inspection.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:purchase_erp/utils/device_services.dart';
import '../purchase_request_pdf_viewer.dart';

class QCInspectionsScreen extends StatefulWidget {
  const QCInspectionsScreen({super.key});

  @override
  State<QCInspectionsScreen> createState() => _QCInspectionsScreenState();
}

class _QCInspectionsScreenState extends State<QCInspectionsScreen> {
  String selectedFilter = "Pending";
  List<dynamic> qcItems = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchQCInspections();
  }

  Future<void> _fetchQCInspections() async {
    setState(() => isLoading = true);
    try {
      final prefs = await SharedPreferences.getInstance();
      final cid = prefs.getString('cid') ?? '';
      final deviceData = await DeviceServices.getAndStoreDeviceInfo();
      final ln = deviceData['ln'] ?? '123';
      final lt = deviceData['lt'] ?? '123';
      final deviceId = deviceData['device_id'] ?? '123';

      final response = await http.post(
        Uri.parse("https://erpsmart.in/total/api/m_api/"),
        body: {
          "type": "4034",
          "cid": cid.isEmpty ? "44555666" : cid,
          "device_id": deviceId,
          "ln": ln,
          "lt": lt,
          "status": selectedFilter.toLowerCase(),
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['error'] == false) {
          if (mounted) {
            setState(() {
              qcItems = data['data'] ?? [];
              isLoading = false;
            });
          }
        } else {
          if (mounted) setState(() => isLoading = false);
        }
      } else {
        if (mounted) setState(() => isLoading = false);
      }
    } catch (e) {
      debugPrint("Fetch QC Error: $e");
      if (mounted) setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color(0xff26A69A),
        elevation: 0,
        titleSpacing: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          "QC Inspections",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
        ),
        actions: [
          Container(
            margin: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            height: 32,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: const Color(0xff26A69A),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                elevation: 0,
                padding: const EdgeInsets.symmetric(horizontal: 14),
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const CreateQCInspectionScreen()),
                );
              },
              icon: const Icon(Icons.add, size: 16),
              label: const Text("New", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          const SizedBox(height: 12),

          /// Filters Row
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                _buildFilterChip("Pending"),
                _buildFilterChip("Passed"),
                _buildFilterChip("Failed"),
              ],
            ),
          ),

          const SizedBox(height: 16),

          /// QC List
          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) {
                double w = constraints.maxWidth;
                int crossAxisCount = w > 900 ? 3 : (w > 600 ? 2 : 1);

                if (isLoading) {
                  return const Center(child: CircularProgressIndicator(color: Color(0xff26A69A)));
                }

                if (qcItems.isEmpty) {
                  return const Center(child: Text("No QC Inspections Found", style: TextStyle(color: Colors.grey)));
                }

                return GridView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: crossAxisCount,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    mainAxisExtent: 260, // Adjusted for premium look
                  ),
                  itemCount: qcItems.length,
                  itemBuilder: (context, index) {
                    return _buildQCCard(qcItems[index]);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label) {
    bool isSelected = selectedFilter == label;
    return GestureDetector(
      onTap: () {
        if (!isSelected) {
          setState(() {
            selectedFilter = label;
          });
          _fetchQCInspections();
        }
      },
      child: Container(
        margin: const EdgeInsets.only(right: 12),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xff26A69A) : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? Colors.transparent : Colors.grey.shade400,
          ),
        ),
        child: Text( label,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.grey.shade600,
            fontWeight: FontWeight.w500,
            fontSize: 13,
          ),
        ),
      ),
    );
  }

  Widget _buildQCCard(Map<String, dynamic> item) {
    String grnNo = item['grn_no'] ?? 'N/A';
    String status = item['qc_status'] ?? 'Pending';
    String date = item['dtime'] ?? '';
    List<dynamic> itemsList = item['items'] ?? [];
    
    int totalItems = itemsList.length;
    int passed = 0;
    int partial = 0;
    int failed = 0;

    for (var it in itemsList) {
      String res = (it['qc_test_result'] ?? '').toString().toLowerCase();
      if (res == 'pass') passed++;
      else if (res == 'fail' || res == 'rejected') failed++;
      else partial++;
    }

    String? pdfLink = item['pdf_link'];

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => GrnInspectionScreen(inspectionData: item)),
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
              Expanded(
                child: Text(
                  "GRN: $grnNo",
                  style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 15),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (pdfLink != null && pdfLink.isNotEmpty)
                IconButton(
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  icon: const Icon(Icons.picture_as_pdf, color: Color(0xff26A69A), size: 20),
                  onPressed: () {
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
                ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: status.toLowerCase() == 'passed' ? const Color(0xff12832F) : (status.toLowerCase() == 'failed' ? Colors.red : const Color(0xffA3920F)),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Text(
                  status,
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 11),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            "Date: $date",
            style: TextStyle(color: Colors.grey.shade700, fontSize: 13),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          Text(
            "100% Inspection",
            style: TextStyle(color: Colors.grey.shade700, fontSize: 13),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildStatusBox(passed.toString(), "Pass", const Color(0xff119E4B)),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatusBox(partial.toString(), "Partial", const Color(0xffA3920F)),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatusBox(failed.toString(), "Fail", const Color(0xffAD1414)),
              ),
            ],
          ),
        ],
      ),
    ),
  );
}

  Widget _buildStatusBox(String count, String status, Color color) {
    return Container(
      height: 60,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            count,
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
          ),
          Text(
            status,
            style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }
}
