import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:purchase_erp/utils/device_services.dart';

class QuotationComparisonScreen extends StatefulWidget {
  const QuotationComparisonScreen({super.key});

  @override
  State<QuotationComparisonScreen> createState() =>
      _QuotationComparisonScreenState();
}

class _QuotationComparisonScreenState extends State<QuotationComparisonScreen> {
  String? selectedQuotationId;
  String? selectedQuotationNo;
  bool showTable = false;
  bool isLoadingDropdown = true;
  bool isLoadingComparison = false;
  bool isGeneratingApproval = false;
  
  List<Map<String, dynamic>> quotationList = [];
  Map<String, List<Map<String, dynamic>>> groupedComparisonData = {};
  Set<String> selectedRowKeys = {}; // Key format: "supplierId_itemId"

  String? cid;
  String? deviceId;
  String? lt;
  String? ln;
  String? uid;
  String? roleId;

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      if (!mounted) return;
      setState(() {
        cid = prefs.getString('cid') ?? '';
        uid = prefs.getString('uid') ?? prefs.getString('id') ?? '';
        roleId = prefs.getString('role_id') ?? '';
        deviceId = prefs.getString('device_id') ?? 'Unknown';
        lt = prefs.getString('lt') ?? '0';
        ln = prefs.getString('ln') ?? '0';
      });
      if (cid != null && cid!.isNotEmpty) _fetchQuotationDropdown();
      DeviceServices.getAndStoreDeviceInfo().then((deviceData) {
        if (mounted) {
          setState(() {
            deviceId = deviceData['device_id'] ?? deviceId;
            lt = deviceData['lt'] ?? lt;
            ln = deviceData['ln'] ?? ln;
          });
        }
      });
    } catch (e) {
      debugPrint("Error loading initial data: $e");
    }
  }

  Future<void> _fetchQuotationDropdown() async {
    if (cid == null) return;
    setState(() => isLoadingDropdown = true);
    try {
      final response = await http.post(
        Uri.parse("https://erpsmart.in/total/api/m_api/"),
        body: {"type": "4031", "cid": cid!, "device_id": deviceId ?? "", "lt": lt ?? "0", "ln": ln ?? "0"},
      );
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['error'] == false && data['data'] != null) {
          setState(() {
            quotationList = List<Map<String, dynamic>>.from(data['data']);
          });
        }
      }
    } catch (e) {
      debugPrint("Dropdown Fetch Error: $e");
    } finally {
      if (mounted) setState(() => isLoadingDropdown = false);
    }
  }

  Future<void> _loadComparison() async {
    if (cid == null || selectedQuotationNo == null) return;
    setState(() {
      isLoadingComparison = true;
      showTable = false;
      groupedComparisonData = {};
      selectedRowKeys = {};
    });

    try {
      final response = await http.post(
        Uri.parse("https://erpsmart.in/total/api/m_api/"),
        body: {
          "type": "4029",
          "cid": cid!,
          "lt": lt ?? "0",
          "ln": ln ?? "0",
          "device_id": deviceId ?? "",
          "uid": uid ?? "",
          "quotation_no": selectedQuotationNo!,
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['error'] == false && data['data'] != null) {
          final List rawData = data['data'];
          Map<String, List<Map<String, dynamic>>> grouped = {};

          for (var supplierEntry in rawData) {
            final items = supplierEntry['items'] as List;
            for (var item in items) {
              String itemName = (item['item_description']?.toString() ?? "").trim();
              if (itemName.isEmpty || itemName == "|" || itemName == "|") {
                itemName = item['item_code']?.toString() ?? "";
              }
              if (itemName.isEmpty) {
                itemName = "Item Ref: ${item['id']}";
              }

              final rate = double.tryParse(item['unit_rate']?.toString() ?? "0") ?? 0;
              final rowKey = "${supplierEntry['supplier_id']}_${item['id']}";

              if (!grouped.containsKey(itemName)) grouped[itemName] = [];
              grouped[itemName]!.add({
                "key": rowKey,
                "supplier_id": supplierEntry['supplier_id'],
                "supplier_name": supplierEntry['supplier_name'] ?? "Supplier ${supplierEntry['supplier_id']}",
                "qty": item['quoted_qty']?.toString() ?? "0",
                "sku": "Nos.",
                "rate": rate.toStringAsFixed(2),
                "taxPerc": item['taxes']?.toString() ?? "0",
                "taxAmt": item['tax_amount']?.toString() ?? "0",
                "dis": item['discount']?.toString() ?? "0",
                "other": item['other_charges']?.toString() ?? "0.00",
                "netRate": item['net_amount']?.toString() ?? "0",
                "paymentTerm": item['delivery_period']?.toString() ?? "-",
                "rfq_no": item['rfq_no']?.toString() ?? "",
                "original_data": item,
              });
            }
          }

          // Auto-Select processing
          grouped.forEach((itemName, offers) {
            double minRate = -1;
            for (var offer in offers) {
              final r = double.tryParse(offer['netRate']) ?? 0;
              if (r > 0) {
                if (minRate == -1 || r < minRate) {
                  minRate = r;
                }
              }
            }
            
            // If all are 0 or none > 0, we don't mark as lowest automatically 
            // but we might mark the first one as a fallback or if rate is the same.
            // For now, only mark if minRate discovered > 0.
            for (var offer in offers) {
              final r = double.tryParse(offer['netRate']) ?? 0;
              final isLowest = (minRate != -1 && r == minRate);
              offer['price_status'] = isLowest ? "LOWEST" : "HIGHER";
              if (isLowest) selectedRowKeys.add(offer['key']);
            }
          });

          setState(() {
            groupedComparisonData = grouped;
            showTable = true;
          });
        }
      }
    } catch (e) {
      debugPrint("Load Error: $e");
    } finally {
      if (mounted) setState(() => isLoadingComparison = false);
    }
  }

  Future<void> _generatePurchaseApproval() async {
    if (selectedRowKeys.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Please select at least one item")));
      return;
    }

    setState(() => isGeneratingApproval = true);

    try {
      Map<String, List<Map<String, dynamic>>> supplierGroups = {};
      Map<String, String> supplierNames = {};
      Map<String, String> rfqNumbers = {};

      for (var group in groupedComparisonData.values) {
        for (var offer in group) {
          if (selectedRowKeys.contains(offer['key'])) {
            final sId = offer['supplier_id'].toString();
            if (!supplierGroups.containsKey(sId)) supplierGroups[sId] = [];
            
            final original = offer['original_data'] as Map<String, dynamic>;
            supplierGroups[sId]!.add({
              "item_code": original['item_code'] ?? "",
              "pro_name": original['item_description'] ?? "",
              "quantity": original['quoted_qty'] ?? "0",
              "unit_rate": original['unit_rate'] ?? "0",
              "discount": original['discount'] ?? "0",
              "tax": original['taxes'] ?? "0",
              "tot_amt": original['net_amount'] ?? "0",
              "delivery_period": original['delivery_period'] ?? "7 Days",
              "quotation_ref": original['quotation_no'] ?? selectedQuotationNo,
            });
            supplierNames[sId] = offer['supplier_name'];
            rfqNumbers[sId] = offer['rfq_no'];
          }
        }
      }

      int successCount = 0;
      for (var sId in supplierGroups.keys) {
        final body = {
          "type": "4028",
          "cid": cid!,
          "uid": uid!,
          "role_id": roleId!,
          "device_id": deviceId ?? "",
          "ln": ln ?? "0",
          "lt": lt ?? "0",
          "supplier_id": sId,
          "supplier_name": supplierNames[sId]!,
          "quotation_ref": selectedQuotationNo!,
          "rfq_no": rfqNumbers[sId]!,
          "items": jsonEncode(supplierGroups[sId]),
        };

        final response = await http.post(Uri.parse("https://erpsmart.in/total/api/m_api/"), body: body);

        if (response.statusCode == 200) {
          final data = json.decode(response.body);
          if (data['error'] == false || data['error'] == 'false') successCount++;
        }
      }

      if (successCount > 0) _showSuccessDialog();
      else ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Failed to generate approvals")));
    } catch (e) {
      debugPrint("Approval Error: $e");
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e")));
    } finally {
      if (mounted) setState(() => isGeneratingApproval = false);
    }
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.check_circle, color: Color(0xff26A69A), size: 60),
            const SizedBox(height: 16),
            Text("Success!", style: GoogleFonts.outfit(fontSize: 20.sp, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text("Purchase Approval generated successfully", textAlign: TextAlign.center, style: GoogleFonts.outfit(color: Colors.grey, fontSize: 13.sp)),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 45,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xff26A69A), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.pop(context);
                },
                child: Text("Done", style: GoogleFonts.outfit(color: Colors.white)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    const primaryTeal = Color(0xff26A69A);
    const primaryBlue = Color(0xFF1976D2);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        titleSpacing: 0,
        backgroundColor: primaryTeal,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text(
          selectedQuotationNo == null 
            ? "Quotation Comparison" 
            : "Comparison: $selectedQuotationNo", 
          style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18.sp)
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSelectionCard(primaryTeal),
                  const SizedBox(height: 24),
                  if (showTable) ...[
                    _buildSummaryBar(primaryBlue),
                    const SizedBox(height: 16),
                    _buildGroupedComparison(primaryTeal),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: showTable 
        ? SafeArea(child: _buildBottomAction(primaryTeal)) 
        : null,
    );
  }

  Widget _buildSelectionCard(Color primaryTeal) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 4))],
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Select Quotation No", style: GoogleFonts.outfit(fontWeight: FontWeight.w600, fontSize: 14.sp, color: Colors.black87)),
          const SizedBox(height: 10),
          Container(
            height: 50.h,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(color: Colors.grey.shade50, border: Border.all(color: Colors.grey.shade300), borderRadius: BorderRadius.circular(8)),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                isExpanded: true,
                hint: Text(isLoadingDropdown ? "Loading quotations..." : "Choose Quotation", style: GoogleFonts.outfit(fontSize: 14.sp, color: Colors.black54)),
                value: selectedQuotationId,
                icon: isLoadingDropdown ? const SizedBox(width: 14, height: 14, child: CircularProgressIndicator(strokeWidth: 2)) : const Icon(Icons.keyboard_arrow_down, color: Colors.black),
                items: quotationList.map((data) {
                  final qNo = data['quotation_no']?.toString() ?? 'N/A';
                  return DropdownMenuItem<String>(
                    value: data['id']?.toString(),
                    onTap: () => selectedQuotationNo = qNo,
                    child: Text(qNo, style: GoogleFonts.outfit(fontSize: 14.sp)),
                  );
                }).toList(),
                onChanged: (newValue) => setState(() => selectedQuotationId = newValue),
              ),
            ),
          ),
          const SizedBox(height: 20),
          InkWell(
            onTap: isLoadingComparison ? null : _loadComparison,
            child: Container(
              width: double.infinity,
              height: 50,
              decoration: BoxDecoration(color: primaryTeal, borderRadius: BorderRadius.circular(8)),
              child: Center(
                child: isLoadingComparison 
                  ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                  : Text("Load Comparison", style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryBar(Color blue) {
    // Extract RFQ No from the first item found
    String rfqNo = "-";
    if (groupedComparisonData.isNotEmpty) {
      final firstGroup = groupedComparisonData.values.first;
      if (firstGroup.isNotEmpty) {
        rfqNo = firstGroup.first['rfq_no'] ?? "-";
      }
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      decoration: BoxDecoration(
        color: blue.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: blue.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Quotation Ref", style: GoogleFonts.outfit(fontSize: 11.sp, color: Colors.grey.shade600)),
                    Text(selectedQuotationNo ?? "-", style: GoogleFonts.outfit(fontSize: 14.sp, fontWeight: FontWeight.bold, color: Colors.black87)),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("RFQ Reference", style: GoogleFonts.outfit(fontSize: 11.sp, color: Colors.grey.shade600)),
                    Text(rfqNo, style: GoogleFonts.outfit(fontSize: 14.sp, fontWeight: FontWeight.bold, color: Colors.black87)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              const Icon(Icons.check_circle_outline, color: Colors.green, size: 16),
              const SizedBox(width: 8),
              Text(
                "${selectedRowKeys.length} items selected for approval",
                style: GoogleFonts.outfit(fontWeight: FontWeight.w600, fontSize: 13.sp, color: Colors.green.shade700),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBottomAction(Color teal) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10, offset: const Offset(0, -2))]),
      child: SizedBox(
        width: double.infinity,
        height: 50,
        child: ElevatedButton.icon(
          onPressed: isGeneratingApproval ? null : _generatePurchaseApproval,
          icon: isGeneratingApproval 
            ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
            : const Icon(Icons.check_circle_outline, color: Colors.white, size: 20),
          label: Text(isGeneratingApproval ? "Processing..." : "Generate Purchase Approval", style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16.sp)),
          style: ElevatedButton.styleFrom(backgroundColor: const Color(0xff4CAF50), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
        ),
      ),
    );
  }

  Widget _buildGroupedComparison(Color teal) {
    // Column widths matching the reference image scale
    const double colBase = 90;
    const Map<String, double> widths = {
      'check': 50,
      'supplier': 200,
      'qty': 70,
      'sku': 60,
      'rate': 90,
      'taxP': 60,
      'taxA': 100,
      'disc': 60,
      'other': 70,
      'net': 130,
      'pay': 150,
      'price': 110,
    };

    final double totalWidth = widths.values.reduce((a, b) => a + b);

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. MAIN HEADER ROW (Dark Blue)
          Container(
            width: totalWidth,
            height: 45,
            decoration: const BoxDecoration(
              color: Color(0xff122E50),
              borderRadius: BorderRadius.vertical(top: Radius.circular(4)),
            ),
            child: Row(
              children: [
                _buildHeaderCell("", widths['check']!),
                _buildHeaderCell("Supplier", widths['supplier']!),
                _buildHeaderCell("Qty", widths['qty']!),
                _buildHeaderCell("SKU", widths['sku']!),
                _buildHeaderCell("Rate (₹)", widths['rate']!),
                _buildHeaderCell("Tax %", widths['taxP']!),
                _buildHeaderCell("Tax Amt (₹)", widths['taxA']!),
                _buildHeaderCell("Disc %", widths['disc']!),
                _buildHeaderCell("Other", widths['other']!),
                _buildHeaderCell("Net Rate (₹)\nQty*Rate+Tax", widths['net']!, isSmall: true),
                _buildHeaderCell("Payment Term", widths['pay']!),
                _buildHeaderCell("Price", widths['price']!),
              ],
            ),
          ),

          // 2. DATA GROUPS
          ...groupedComparisonData.entries.map((group) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ITEM GROUP HEADER
                Container(
                  width: totalWidth,
                  height: 35,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: const Color(0xffDEE6F1),
                    border: Border(
                      bottom: BorderSide(color: Colors.grey.shade300),
                      left: BorderSide(color: Colors.grey.shade300),
                      right: BorderSide(color: Colors.grey.shade300),
                    ),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.inventory_2, size: 14, color: Color(0xff122E50)),
                      const SizedBox(width: 8),
                      Text(
                        "Item : ${group.key.toUpperCase()}",
                        style: GoogleFonts.outfit(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xff122E50),
                        ),
                      ),
                    ],
                  ),
                ),

                // SUPPLIER ROWS FOR THIS ITEM
                ...group.value.map((offer) {
                  final bool isSelected = selectedRowKeys.contains(offer['key']);
                  final bool isLowest = offer['price_status'] == "LOWEST";
                  
                  // Row Colors matching image (Selected = Light Yellow)
                  final Color rowBg = isSelected ? const Color(0xffFFFFE1) : Colors.white;

                  return Container(
                    width: totalWidth,
                    height: 52,
                    clipBehavior: Clip.hardEdge,
                    decoration: BoxDecoration(
                      color: rowBg,
                      border: Border(
                        bottom: BorderSide(color: Colors.grey.shade300),
                        left: BorderSide(color: Colors.grey.shade300),
                        right: BorderSide(color: Colors.grey.shade300),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Checkbox Cell
                        SizedBox(
                          width: widths['check'],
                          child: Center(
                            child: Checkbox(
                              value: isSelected,
                              activeColor: const Color(0xff1976D2),
                              onChanged: (val) {
                                setState(() {
                                  if (val == true) selectedRowKeys.add(offer['key']);
                                  else selectedRowKeys.remove(offer['key']);
                                });
                              },
                            ),
                          ),
                        ),
                        _buildDataCell(offer['supplier_name'], widths['supplier']!, isBold: true),
                        _buildDataCell(offer['qty'], widths['qty']!),
                        _buildDataCell(offer['sku'], widths['sku']!),
                        _buildDataCell(offer['rate'], widths['rate']!),
                        _buildDataCell(offer['taxPerc'], widths['taxP']!),
                        _buildDataCell(offer['taxAmt'], widths['taxA']!),
                        _buildDataCell(offer['dis'], widths['disc']!),
                        _buildDataCell(offer['other'], widths['other']!),
                        _buildDataCell(offer['netRate'], widths['net']!, isBold: true),
                        _buildDataCell(offer['paymentTerm'], widths['pay']!),
                        
                        // Price Status Badge
                        SizedBox(
                          width: widths['price']!,
                          child: Center(
                            child: Container(
                              height: 22,
                              width: 80,
                              decoration: BoxDecoration(
                                color: isLowest ? const Color(0xff4CAF50) : const Color(0xffE53935),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(isLowest ? Icons.check : Icons.arrow_upward, size: 10, color: Colors.white),
                                  const SizedBox(width: 4),
                                  Text(
                                    offer['price_status'],
                                    style: GoogleFonts.outfit(
                                      color: Colors.white,
                                      fontSize: 8.sp,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }),
              ],
            );
          }),
        ],
      ),
    );
  }

  Widget _buildHeaderCell(String label, double width, {bool isSmall = false}) {
    return Container(
      width: width,
      height: double.infinity,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        border: Border(right: BorderSide(color: Colors.white.withValues(alpha: 0.1), width: 0.5)),
      ),
      child: Text(
        label,
        textAlign: TextAlign.center,
        style: GoogleFonts.outfit(
          color: Colors.white,
          fontSize: isSmall ? 9.sp : 11.sp,
          fontWeight: FontWeight.bold,
          height: 1.1,
        ),
      ),
    );
  }

  Widget _buildDataCell(String value, double width, {bool isBold = false}) {
    return Container(
      width: width,
      height: double.infinity,
      alignment: Alignment.centerLeft,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        border: Border(right: BorderSide(color: Colors.grey.shade200, width: 0.5)),
      ),
      child: Text(
        value,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: GoogleFonts.outfit(
          fontSize: 11.sp,
          fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
          color: Colors.black87,
        ),
      ),
    );
  }
}
