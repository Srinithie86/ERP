import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:purchase_erp/utils/device_services.dart';
import 'package:purchase_erp/core/api_config.dart';

class QuotationComparisonScreen extends StatefulWidget {
  const QuotationComparisonScreen({super.key});

  @override
  State<QuotationComparisonScreen> createState() =>
      _QuotationComparisonScreenState();
}

class _QuotationComparisonScreenState extends State<QuotationComparisonScreen> {

  String? selectedQuotationNo;
  String? selectedQuotationLabel;
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
    print("================ FETCH QUOTATIONS (4031) ================");
    print("CID: $cid");
    try {
      final response = await http.post(
        Uri.parse(await ApiConfig.getBaseUrl()),
        body: {"type": "4031", "cid": cid!, "device_id": deviceId ?? "", "lt": lt ?? "0", "ln": ln ?? "0"},
      );
      
      print("STATUS: ${response.statusCode}");
      print("BODY: ${response.body}");

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if ((data['error'] == false || data['error']?.toString().toLowerCase() == 'false') && data['data'] != null) {
          setState(() {
            quotationList = List<Map<String, dynamic>>.from(data['data']);
            
            // Fix for crash: 'widget.items!.where((DropdownMenuItem<T> item) => item.value == widget.value).length == 1'
            if (selectedQuotationLabel != null) {
              bool exists = quotationList.any((q) => q['label']?.toString() == selectedQuotationLabel);
              if (!exists) {
                selectedQuotationLabel = null;
                selectedQuotationNo = null;
              }
            }

            if (quotationList.isEmpty) {
               print("⚠️ Quotation list is empty from server.");
            }
          });
        }
      }
    } catch (e) {
      print("Dropdown Fetch Error: $e");
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
        Uri.parse(await ApiConfig.getBaseUrl()),
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

        final response = await http.post(Uri.parse(await ApiConfig.getBaseUrl()), body: body);

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
    const primaryTeal = Color(0xFF1E88E5); // More professional blue-teal
    const accentGreen = Color(0xFF43A047);

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        titleSpacing: 0,
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black87, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Quotation Comparison",
              style: GoogleFonts.outfit(color: Colors.black87, fontWeight: FontWeight.bold, fontSize: 18.sp),
            ),
            if (selectedQuotationNo != null)
              Text(
                "Ref: $selectedQuotationNo",
                style: GoogleFonts.outfit(color: primaryTeal, fontWeight: FontWeight.bold, fontSize: 12.sp),
              ),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSelectionCard(primaryTeal),
                  if (showTable) ...[
                    SizedBox(height: 16.h),
                    _buildSummaryBar(),
                    SizedBox(height: 16.h),
                    _buildGroupedComparison(primaryTeal),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: showTable 
        ? SafeArea(child: _buildBottomAction(accentGreen)) 
        : null,
    );
  }

  Widget _buildSelectionCard(Color primaryColor) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 15,
            offset: const Offset(0, 8),
          )
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.all(16.w),
            decoration: BoxDecoration(
              color: primaryColor.withValues(alpha: 0.05),
              borderRadius: BorderRadius.vertical(top: Radius.circular(16.r)),
            ),
            child: Row(
              children: [
                Icon(Icons.description_outlined, color: primaryColor, size: 20.sp),
                SizedBox(width: 8.w),
                Text(
                  "Select Quotation",
                  style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 15.sp, color: primaryColor),
                ),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.all(16.w),
            child: Column(
              children: [
                DropdownButtonFormField<String>(
                  decoration: InputDecoration(
                    contentPadding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 0),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.r),
                      borderSide: BorderSide(color: Colors.grey.shade200),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.r),
                      borderSide: BorderSide(color: primaryColor),
                    ),
                    filled: true,
                    fillColor: Colors.grey.shade50,
                  ),
                  hint: Text(isLoadingDropdown ? "Loading..." : "Choose Quotation No", 
                    style: GoogleFonts.outfit(fontSize: 14.sp, color: Colors.black54)),
                  value: (quotationList.any((q) => q['label']?.toString() == selectedQuotationLabel)) ? selectedQuotationLabel : null,
                  items: quotationList.map((data) {
                    final qNo = data['quotation_no']?.toString() ?? 'N/A';
                    final label = data['label']?.toString() ?? qNo;
                    return DropdownMenuItem<String>(
                      value: label,
                      child: Text(label, style: GoogleFonts.outfit(fontSize: 13.sp, fontWeight: FontWeight.normal)),
                    );
                  }).toList(),
                  onChanged: (newValue) {
                    if (newValue == null) return;
                    setState(() { 
                      selectedQuotationLabel = newValue; 
                      selectedQuotationNo = quotationList.firstWhere((q) => q['label'] == newValue)['quotation_no'];
                    });
                    _loadComparison();
                  },
                ),
                SizedBox(height: 16.h),
                ElevatedButton(
                  onPressed: isLoadingComparison ? null : _loadComparison,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    foregroundColor: Colors.white,
                    minimumSize: Size(double.infinity, 48.h),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
                    elevation: 0,
                  ),
                  child: isLoadingComparison 
                    ? SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.w))
                    : Text("Load Comparison Data", style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 15.sp)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryBar() {
    String rfqNo = "-";
    if (groupedComparisonData.isNotEmpty) {
      final firstGroup = groupedComparisonData.values.first;
      if (firstGroup.isNotEmpty) rfqNo = firstGroup.first['rfq_no'] ?? "-";
    }

    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: const Color(0xFFE3F2FD)),
        gradient: LinearGradient(
          colors: [Colors.white, const Color(0xFFF1F8FE)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              _buildSummaryHeader("Quotation REF", selectedQuotationNo ?? "-", Icons.tag),
              Container(width: 1, height: 30, color: Colors.grey.shade200),
              _buildSummaryHeader("RFQ REF", rfqNo, Icons.request_quote),
            ],
          ),
          Divider(height: 24.h, color: Colors.grey.shade200),
          Row(
            children: [
              Container(
                padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
                decoration: BoxDecoration(
                  color: Colors.green.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20.r),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.check_circle, color: Colors.green, size: 16),
                    SizedBox(width: 8.w),
                    Text(
                      "${selectedRowKeys.length} Items ready for Approval",
                      style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 12.sp, color: Colors.green.shade700),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryHeader(String label, String value, IconData icon) {
    return Expanded(
      child: Row(
        children: [
          Icon(icon, size: 16.sp, color: Colors.blueGrey),
          SizedBox(width: 8.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: GoogleFonts.outfit(fontSize: 10.sp, color: Colors.blueGrey, letterSpacing: 0.5)),
                Text(value, style: GoogleFonts.outfit(fontSize: 13.sp, fontWeight: FontWeight.w900, color: Colors.black87), overflow: TextOverflow.ellipsis),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomAction(Color green) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, -5))],
      ),
      child: ElevatedButton.icon(
        onPressed: isGeneratingApproval ? null : _generatePurchaseApproval,
        icon: isGeneratingApproval 
          ? SizedBox(width: 18, height: 18, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.w))
          : const Icon(Icons.verified_user_outlined, color: Colors.white, size: 20),
        label: Text(
          isGeneratingApproval ? "GENERAING..." : "GENERATE PURCHASE APPROVAL", 
          style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 14.sp, letterSpacing: 1.0)
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: green,
          minimumSize: Size(double.infinity, 54.h),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
          elevation: 0,
        ),
      ),
    );
  }

  Widget _buildGroupedComparison(Color teal) {
    const Map<String, double> widths = {
      'check': 50, 'supplier': 180, 'qty': 70, 'sku': 60, 'rate': 90,
      'taxP': 60, 'taxA': 90, 'disc': 60, 'other': 70, 'net': 110,
      'pay': 140, 'price': 110,
    };

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: Colors.grey.shade200),
      ),
      clipBehavior: Clip.hardEdge,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 48.h,
              decoration: const BoxDecoration(color: Color(0xFF263238)), // Sleek Dark Header
              child: Row(
                children: [
                  _buildHeaderCell("", widths['check']!),
                  _buildHeaderCell("SUPPLIER", widths['supplier']!),
                  _buildHeaderCell("QTY", widths['qty']!),
                  _buildHeaderCell("UOM", widths['sku']!),
                  _buildHeaderCell("RATE", widths['rate']!),
                  _buildHeaderCell("TAX%", widths['taxP']!),
                  _buildHeaderCell("TAX AMT", widths['taxA']!),
                  _buildHeaderCell("DISC%", widths['disc']!),
                  _buildHeaderCell("OTHER", widths['other']!),
                  _buildHeaderCell("NET RATE", widths['net']!),
                  _buildHeaderCell("DELIVERY", widths['pay']!),
                  _buildHeaderCell("RANK", widths['price']!),
                ],
              ),
            ),
            ...groupedComparisonData.entries.map((group) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: widths.values.reduce((a, b) => a + b),
                    padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
                    color: const Color(0xFFECEFF1),
                    child: Row(
                      children: [
                        const Icon(Icons.inventory_2, size: 14, color: Colors.blueGrey),
                        SizedBox(width: 8.w),
                        Text(
                          group.key.toUpperCase(),
                          style: GoogleFonts.outfit(fontSize: 12.sp, fontWeight: FontWeight.w900, color: Colors.blueGrey.shade800),
                        ),
                      ],
                    ),
                  ),
                  ...group.value.map((offer) {
                    final bool isSelected = selectedRowKeys.contains(offer['key']);
                    final bool isLowest = offer['price_status'] == "LOWEST";
                    return Container(
                      height: 52.h,
                      decoration: BoxDecoration(
                        color: isSelected ? const Color(0xFFFFFDE7) : Colors.white,
                        border: Border(bottom: BorderSide(color: Colors.grey.shade100)),
                      ),
                      child: Row(
                        children: [
                          _buildCheckCell(offer['key'], isSelected, widths['check']!),
                          _buildDataCell(offer['supplier_name'], widths['supplier']!, isBold: true),
                          _buildDataCell(offer['qty'], widths['qty']!),
                          _buildDataCell(offer['sku'], widths['sku']!),
                          _buildDataCell("₹${offer['rate']}", widths['rate']!),
                          _buildDataCell("${offer['taxPerc']}%", widths['taxP']!),
                          _buildDataCell("₹${offer['taxAmt']}", widths['taxA']!),
                          _buildDataCell("${offer['dis']}%", widths['disc']!),
                          _buildDataCell("₹${offer['other']}", widths['other']!),
                          _buildDataCell("₹${offer['netRate']}", widths['net']!, isBold: true, color: teal),
                          _buildDataCell(offer['paymentTerm'], widths['pay']!),
                          _buildStatusCell(offer['price_status'], isLowest, widths['price']!),
                        ],
                      ),
                    );
                  }).toList(),
                ],
              );
            }).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildCheckCell(String key, bool selected, double width) {
    return Container(
      width: width,
      alignment: Alignment.center,
      child: Checkbox(
        value: selected,
        activeColor: const Color(0xFF1E88E5),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
        onChanged: (val) {
          setState(() {
            if (val == true) selectedRowKeys.add(key);
            else selectedRowKeys.remove(key);
          });
        },
      ),
    );
  }

  Widget _buildStatusCell(String status, bool isLowest, double width) {
    return Container(
      width: width,
      alignment: Alignment.center,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
        decoration: BoxDecoration(
          color: isLowest ? Colors.green : Colors.orange.shade800,
          borderRadius: BorderRadius.circular(4),
        ),
        child: Text(
          status,
          style: GoogleFonts.outfit(color: Colors.white, fontSize: 9.sp, fontWeight: FontWeight.w900),
        ),
      ),
    );
  }

  Widget _buildHeaderCell(String label, double width) {
    return Container(
      width: width,
      alignment: Alignment.centerLeft,
      padding: EdgeInsets.symmetric(horizontal: 12.w),
      decoration: BoxDecoration(border: Border(right: BorderSide(color: Colors.white10, width: 0.5))),
      child: Text(
        label,
        style: GoogleFonts.outfit(color: Colors.white, fontSize: 10.sp, fontWeight: FontWeight.w900, letterSpacing: 0.5),
      ),
    );
  }

  Widget _buildDataCell(String value, double width, {bool isBold = false, Color? color}) {
    return Container(
      width: width,
      alignment: Alignment.centerLeft,
      padding: EdgeInsets.symmetric(horizontal: 12.w),
      decoration: BoxDecoration(border: Border(right: BorderSide(color: Colors.grey.shade100, width: 0.5))),
      child: Text(
        value,
        style: GoogleFonts.outfit(
          fontSize: 11.sp, 
          fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
          color: color ?? (isBold ? Colors.black87 : Colors.black54),
        ),
        overflow: TextOverflow.ellipsis,
      ),
    );
  }
}