import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'modern_qc_inspection_screen.dart';
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
  String selectedFilter = "All";
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

      final response = await http.post(
        Uri.parse("https://erpsmart.in/total/api/m_api/"),
        body: {
          "type": "4034",
          "cid": cid.isEmpty ? '44555666' : cid,
          "device_id": deviceData['device_id'] ?? '123',
          "ln": deviceData['ln'] ?? '123',
          "lt": deviceData['lt'] ?? '123',
        },
      ).timeout(const Duration(seconds: 15));

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

  bool _isSearching = false;
  String _searchQuery = "";
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    List<dynamic> filteredItems = qcItems.where((item) {
      // 1. Status Filter
      if (selectedFilter != "All") {
        String itemStatus = (item['qc_status'] ?? 'Pending').toString().toLowerCase();
        // Handle "Passed" vs "Passed" vs "Approved"
        if (selectedFilter == "Passed" && (itemStatus != "passed" && itemStatus != "approved" && itemStatus != "completed")) return false;
        if (selectedFilter == "Failed" && (itemStatus != "failed" && itemStatus != "rejected")) return false;
        if (selectedFilter == "Pending" && itemStatus != "pending") return false;
      }

      // 2. Search Query Filter
      if (_searchQuery.isEmpty) return true;
      String grn = (item['grn_no'] ?? '').toString().toLowerCase();
      String supplier = (item['supplier_name'] ?? '').toString().toLowerCase();
      String supplierId = (item['supplier_id'] ?? '').toString().toLowerCase();
      String po = (item['po_no'] ?? '').toString().toLowerCase();
      String insId =
          (item['id'] ?? item['inspection_id'] ?? '').toString().toLowerCase();

      return grn.contains(_searchQuery) ||
          supplier.contains(_searchQuery) ||
          supplierId.contains(_searchQuery) ||
          po.contains(_searchQuery) ||
          insId.contains(_searchQuery);
    }).toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: const Color(0xff26A69A),
        elevation: 0,
        centerTitle: false,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded,
              color: Colors.white, size: 20.sp),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          "QC Inspections",
          style: GoogleFonts.outfit(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 18.sp),
        ),
        actions: [
          // "New" button removed as per request
        ],
      ),
      body: Column(
        children: [
          // Filter Chips and Search Bar Section
          Container(
            width: double.infinity,
            padding: EdgeInsets.only(bottom: 16.h),
            decoration: const BoxDecoration(
              color: Color(0xff26A69A),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(24),
                bottomRight: Radius.circular(24),
              ),
            ),
            child: Column(
              children: [
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  padding: EdgeInsets.symmetric(horizontal: 16.w),
                  child: Row(
                    children: [
                      _buildFilterChip("All"),
                      _buildFilterChip("Pending"),
                      _buildFilterChip("Passed"),
                      _buildFilterChip("Failed"),
                    ],
                  ),
                ),
                SizedBox(height: 16.h),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.w),
                  child: Container(
                    height: 48.h,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: TextField(
                      controller: _searchController,
                      onChanged: (val) =>
                          setState(() => _searchQuery = val.toLowerCase()),
                      decoration: InputDecoration(
                        hintText: "Search by GRN, PO No, Supplier...",
                        hintStyle: GoogleFonts.outfit(
                            color: Colors.grey.shade500, fontSize: 13.sp),
                        prefixIcon: Icon(Icons.search,
                            color: Colors.grey.shade500, size: 20.sp),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(vertical: 12.h),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          Expanded(
            child: isLoading
                ? const Center(
                    child: CircularProgressIndicator(color: Color(0xff26A69A)))
                : filteredItems.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.search_off_rounded,
                                size: 64.sp, color: Colors.grey.shade300),
                            SizedBox(height: 16.h),
                            Text("No inspections found",
                                style: GoogleFonts.outfit(
                                    color: Colors.grey, fontSize: 16.sp)),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: EdgeInsets.all(16.w),
                        itemCount: filteredItems.length,
                        itemBuilder: (context, index) {
                          return _buildQCCard(filteredItems[index]);
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
          setState(() => selectedFilter = label);
          _fetchQCInspections();
        }
      },
      child: Container(
        margin: EdgeInsets.only(right: 12.w),
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 6.h),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : Colors.white.withOpacity(0.1),
          borderRadius: BorderRadius.circular(18),
        ),
        child: Text(
          label,
          style: GoogleFonts.outfit(
            color: isSelected ? const Color(0xff26A69A) : Colors.white,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            fontSize: 12.sp,
          ),
        ),
      ),
    );
  }

  Widget _buildQCCard(Map<String, dynamic> item) {
    String grnNo = item['grn_no'] ?? 'N/A';
    String rawStatus = (item['qc_status'] ?? 'Pending').toString();
    String status = rawStatus;
    if (rawStatus == "1" || rawStatus == "" || rawStatus == "null" || rawStatus.toLowerCase().contains("approve po generated")) {
      status = "Pending";
    }
    String date = item['dtime'] ?? '-';
    String id = (item['id'] ?? item['inspection_id'] ?? '').toString();
    String inspector = item['inspector_name'] ?? 'N/A';
    List<dynamic> itemsList = item['items'] ?? [];
    String? pdfLink = item['pdf_link'];

    Color statusColor;
    switch (status.toLowerCase()) {
      case 'passed':
      case 'approved':
      case 'completed':
        statusColor = const Color(0xFF22C55E);
        break;
      case 'failed':
      case 'rejected':
        statusColor = const Color(0xFFEF4444);
        break;
      default:
        statusColor = const Color(0xFFEAB308);
    }

    return Container(
      margin: EdgeInsets.only(bottom: 16.h),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                grnNo,
                style: GoogleFonts.outfit(
                    fontWeight: FontWeight.bold, fontSize: 16.sp),
              ),
              if (pdfLink != null && pdfLink.isNotEmpty) ...[
                SizedBox(width: 8.w),
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
                  child: Icon(Icons.picture_as_pdf_rounded,
                      color: Colors.red, size: 18.sp),
                ),
              ],
            ],
          ),
          SizedBox(height: 4.h),
          Text(
            "ID: $id  $date",
            style: GoogleFonts.outfit(
                color: Colors.grey.shade600, fontSize: 12.sp),
          ),
          SizedBox(height: 16.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Spacer(),
              Text(
                "${itemsList.length} Items",
                style: GoogleFonts.outfit(
                    fontWeight: FontWeight.bold, fontSize: 12.sp),
              ),
            ],
          ),
          SizedBox(height: 16.h),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ModernQCInspectionScreen(
                          inspectionData: item,
                          isReadOnly: true,
                        ),
                      ),
                    );
                  },
                  icon: Icon(Icons.visibility_outlined, size: 16.sp),
                  label: const Text("View Details"),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xff26A69A),
                    side: const BorderSide(color: Color(0xff26A69A)),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8)),
                    padding: EdgeInsets.symmetric(vertical: 10.h),
                  ),
                ),
              ),
              SizedBox(width: 8.w),
              if (status.toLowerCase() == 'pending')
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ModernQCInspectionScreen(
                            inspectionData: item,
                            isReadOnly: false,
                          ),
                        ),
                      ).then((value) {
                        if (value == true) _fetchQCInspections();
                      });
                    },
                    icon: Icon(Icons.fact_check_outlined, size: 16.sp),
                    label: const Text("Inspect"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFEAB308), // Amber for attention
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8)),
                      padding: EdgeInsets.symmetric(vertical: 10.h),
                    ),
                  ),
                )
              else if (pdfLink != null && pdfLink.isNotEmpty)
                Expanded(
                  child: ElevatedButton.icon(
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
                    icon: Icon(Icons.picture_as_pdf_outlined, size: 16.sp),
                    label: const Text("View PDF"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xff26A69A),
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8)),
                      padding: EdgeInsets.symmetric(vertical: 10.h),
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBox(String count, String status, Color color) {
    return Container(
      height: 54.h,
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            count,
            style: GoogleFonts.outfit(
                color: color, fontWeight: FontWeight.bold, fontSize: 16.sp),
          ),
          Text(
            status,
            style: GoogleFonts.outfit(
                color: color, fontSize: 10.sp, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}
