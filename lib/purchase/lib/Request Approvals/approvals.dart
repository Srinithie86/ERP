import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import '../dashboard.dart';
import 'request_approval_details.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import 'package:purchase_erp/utils/device_services.dart';
import '../QC/grn_inspection_screen.dart';
import '../QC/modern_qc_inspection_screen.dart';
import '../GRN/create_grn_screen.dart';
import 'package:purchase_erp/purchase_request_pdf_viewer.dart';
import 'package:erp_smart/theme/app_theme.dart'; // Though we use Theme.of(context), keeping as fallback if needed

class RequestApprovals extends StatefulWidget {
  static List<dynamic> cachedApprovals = [];
  static Map<String, String> cachedUserMap = {};
  static bool hasCachedData = false;
  static bool isPreFetching = false;

  static const String apiUrl = 'https://erpsmart.in/total/api/m_api/';

  final bool isEmbedded;

  const RequestApprovals({super.key, this.isEmbedded = false});

  static Future<void> preFetch() async {
    if (isPreFetching) return;
    isPreFetching = true;

    try {
      final prefs = await SharedPreferences.getInstance();
      final cid = prefs.getString('cid') ?? '44555666';
      final uid = prefs.getString('uid') ?? '118';
      final roleId = prefs.getString('role_id') ?? '';

      final results = await Future.wait([
        http.post(
          Uri.parse(apiUrl),
          body: {
            'type': '5001',
            'cid': cid,
            'device_id': '123',
            'ln': '123',
            'lt': '34',
          },
        ),
        http.post(
          Uri.parse(apiUrl),
          body: {
            'type': '4036',
            'cid': cid,
            'uid': uid,
            'role_id': roleId,
            'device_id': '123',
            'ln': '123',
            'lt': '34',
          },
        ),
      ]);

      final userResponse = results[0];
      final prResponse = results[1];

      if (userResponse.statusCode == 200 && userResponse.body.isNotEmpty) {
        try {
          final jsonResponse = json.decode(userResponse.body);
          if (jsonResponse['error'] == false ||
              jsonResponse['error']?.toString().toLowerCase() == 'false') {
            final users = jsonResponse['data'];
            if (users is List) {
              cachedUserMap.clear();
              for (var user in users) {
                cachedUserMap[user['id'].toString()] = user['name'].toString();
              }
            }
          }
        } catch (e) {
          debugPrint("User Pre-fetch JSON error: $e");
        }
      }

      if (prResponse.statusCode == 200 && prResponse.body.isNotEmpty) {
        try {
          final jsonResponse = json.decode(prResponse.body);
          if (jsonResponse['error'] == false ||
              jsonResponse['error']?.toString().toLowerCase() == 'false') {
            final List<dynamic> rawData = jsonResponse['data'] ?? [];
            cachedApprovals = _groupPRItems(rawData);
            hasCachedData = true;
          }
        } catch (e) {
          debugPrint("PR Pre-fetch JSON error: $e");
        }
      }
    } catch (e) {
      debugPrint("Pre-fetch overall error: $e");
    } finally {
      isPreFetching = false;
    }
  }

  static List<Map<String, dynamic>> _groupPOItems(List<dynamic> rawList) {
    if (rawList.isEmpty) return [];
    final Map<String, Map<String, dynamic>> grouped = {};

    for (var item in rawList) {
      final String poNo = (item['po_no'] ?? item['id'] ?? '').toString();
      if (poNo.isEmpty) continue;

      if (!grouped.containsKey(poNo)) {
        grouped[poNo] = {
          'master_po': {
            'id': item['id'],
            'po_no': poNo,
            'po_date': item['po_date'],
            'supplier_name': item['supplier_name'],
            'grand_total': 0.0,
            'status': item['status'],
            'pdf_link': item['pdf_link'],
          },
          'items': [],
        };
      }

      double lineTot = 0.0;
      try {
        lineTot = double.parse((item['tot_amt'] ?? '0').toString());
      } catch (_) {}
      grouped[poNo]!['master_po']['grand_total'] += lineTot;

      grouped[poNo]!['items'].add(item);
    }
    return grouped.values.map((v) => Map<String, dynamic>.from(v)).toList();
  }

  static List<dynamic> _groupPRItems(List<dynamic> rawList) {
    if (rawList.isEmpty) return [];

    // Check if it's already nested (e.g. from API 4018)
    if (rawList.isNotEmpty &&
        rawList[0] is Map &&
        (rawList[0] as Map).containsKey('items')) {
      return rawList.map((item) {
        return {
          'master': {
            'id': item['id'],
            'no': (item['no'] ?? item['requ_no'] ?? item['id'] ?? '').toString(),
            'date': item['req_date'] ?? item['date'] ?? item['dtime'] ?? 'N/A',
            'department': item['department'] ?? 'N/A',
            'requested_by': item['requested_by'] ?? item['name'] ?? 'N/A',
            'status': item['status'],
            'pdf_link': item['pdf_link'],
            'total_qty': item['quantity_required'] ?? item['qty'] ?? '0',
          },
          'items': (item['items'] as List? ?? []).map((i) {
            return {
              'item_code': (i['item_code'] ?? '').toString().isEmpty
                  ? 'N/A'
                  : i['item_code'].toString(),
              'product_name': i['product_name'] ?? i['item_description'] ?? 'N/A',
              'uom': (i['uom'] ?? '').toString().isEmpty ? 'nos' : i['uom'].toString(),
              'qty': i['quantity_required'] ?? i['qty'] ?? i['item_qty'] ?? '0',
              'current_stock_qty': i['stk_qty'] ?? i['current_stock_qty'] ?? '0',
              'dod_date': i['required_date'] ?? i['dod_date'] ?? item['req_date'] ?? 'N/A',
            };
          }).toList(),
        };
      }).toList();
    }

    final Map<String, Map<String, dynamic>> grouped = {};

    for (var item in rawList) {
      final String prNo =
          (item['no'] ?? item['requ_no'] ?? item['id'] ?? '').toString();
      if (prNo.isEmpty) continue;

      if (!grouped.containsKey(prNo)) {
        grouped[prNo] = {
          'master': {
            'id': item['id'],
            'no': prNo,
            'date': item['req_date'] ?? item['date'] ?? item['dtime'] ?? 'N/A',
            'department': item['department'] ?? 'N/A',
            'requested_by': item['requested_by'] ?? item['req_by'] ?? 'N/A',
            'type': item['type'] ?? '',
            'status': item['status'],
            'total_qty': item['qty'] ?? '0',
            'pdf_link': item['pdf_link'],
          },
          'items': [],
          '_itemCodes': <String>{}, // Helper to de-duplicate
        };
      }

      final String code = (item['item_code'] ?? '').toString();
      if (code.isNotEmpty && grouped[prNo]!['_itemCodes'].contains(code)) {
        continue; // Skip duplicate item in same PR
      }
      if (code.isNotEmpty) grouped[prNo]!['_itemCodes'].add(code);

      grouped[prNo]!['items'].add({
        'item_code': code.isEmpty ? 'N/A' : code,
        'product_name': item['product_name'] ?? 'N/A',
        'uom': (item['uom'] ?? '').toString().isEmpty ? 'nos' : item['uom'].toString(),
        'qty': item['item_qty'] ?? '0',
        'current_stock_qty':
            item['current_stock_qty'] ?? item['stock_qty'] ?? '0',
        'dod_date':
            item['dod_date'] ?? item['req_date'] ?? item['date'] ?? 'N/A',
      });
    }
    return grouped.values.map((v) {
      v.remove('_itemCodes'); // Cleanup
      return v;
    }).toList();
  }

  @override
  State<RequestApprovals> createState() => _RequestApprovalsState();
}

class _RequestApprovalsState extends State<RequestApprovals> {
  List<dynamic> prApprovals = List.from(RequestApprovals.cachedApprovals);
  List<Map<String, dynamic>> poApprovals = [];
  List<Map<String, dynamic>> qcApprovals = [];
  Map<String, String> userMap = Map.from(RequestApprovals.cachedUserMap);
  bool isLoading = !RequestApprovals.hasCachedData;
  bool _isSearching = false;
  String _searchQuery = "";
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchAll();
  }

  Future<void> _fetchAll() async {
    if (mounted) setState(() => isLoading = true);
    await Future.wait([
      fetchUsers(),
      _fetchPRApprovals(),
      _fetchPOApprovals(),
      _fetchQCApprovals(),
    ]);
    if (mounted) setState(() => isLoading = false);
  }

  Future<void> fetchUsers() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cid = prefs.getString('cid') ?? '44555666';
      final response = await http.post(
        Uri.parse(RequestApprovals.apiUrl),
        body: {
          'type': '5001',
          'cid': cid,
          'device_id': '123',
          'ln': '123',
          'lt': '34',
        },
      );
      debugPrint("Users Response Code: ${response.statusCode}");
      debugPrint("Users Response Body: ${response.body}");
      if (response.statusCode == 200 && response.body.isNotEmpty) {
        try {
          final data = json.decode(response.body);
          if (data['error'] == false &&
              data['data'] != null &&
              data['data'] is List) {
            userMap.clear();
            for (var user in data['data']) {
              userMap[user['id'].toString()] = user['name'].toString();
            }
            RequestApprovals.cachedUserMap = Map.from(userMap);
          }
        } catch (e) {
          debugPrint("User decode error: $e");
        }
      }
    } catch (e) {
      debugPrint("User fetch error: $e");
    }
  }

  Future<void> _fetchPRApprovals() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cid = prefs.getString('cid') ?? '44555666';
      final response = await http.post(
        Uri.parse(RequestApprovals.apiUrl),
        body: {
          'type': '4036',
          'cid': cid,
          'uid': prefs.getString('uid') ?? '118',
          'role_id': prefs.getString('role_id') ?? '1',
          'device_id': '123',
          'ln': '123',
          'lt': '34',
        },
      );
      debugPrint("PR Response Code: ${response.statusCode}");
      debugPrint("PR Response Body: ${response.body}");
      if (response.statusCode == 200 && response.body.isNotEmpty) {
        try {
          final data = json.decode(response.body);
          if (data['error'] == false &&
              data['data'] != null &&
              data['data'] is List) {
            final List<dynamic> rawData = data['data'];
            if (mounted) {
              setState(() {
                prApprovals = RequestApprovals._groupPRItems(rawData);
                RequestApprovals.cachedApprovals = prApprovals;
                RequestApprovals.hasCachedData = true;
              });
            }
          }
        } catch (e) {
          debugPrint("PR decode error: $e");
        }
      }
    } catch (e) {
      debugPrint("Fetch PR error: $e");
    }
  }

  Future<void> _fetchPOApprovals() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cid = prefs.getString('cid') ?? '44555666';
      final response = await http.post(
        Uri.parse(RequestApprovals.apiUrl),
        body: {
          'type': '4044',
          'cid': cid,
          'device_id': '123',
          'uid': prefs.getString('uid') ?? '118',
          'role_id': '1',
          'lt': '123',
          'ln': '123',
        },
      );
      debugPrint("PO Response Code: ${response.statusCode}");
      debugPrint("PO Response Body: ${response.body}");
      if (response.statusCode == 200 && response.body.isNotEmpty) {
        try {
          final data = json.decode(response.body);
          if (data['error'] == false &&
              data['data'] != null &&
              data['data'] is List) {
            final List<dynamic> rawData = data['data'];
            if (mounted) {
              setState(() {
                poApprovals = RequestApprovals._groupPOItems(rawData);
              });
            }
          }
        } catch (e) {
          debugPrint("PO decode error: $e");
        }
      }
    } catch (e) {
      debugPrint("Fetch PO error: $e");
    }
  }

  Future<void> _fetchQCApprovals() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cid = prefs.getString('cid') ?? '44555666';

      final response = await http.post(
        Uri.parse(RequestApprovals.apiUrl),
        body: {
          "type": "4034",
          "cid": cid,
          "device_id": "123",
          "lt": "123",
          "ln": "123",
          "uid": prefs.getString('uid') ?? '2',
        },
      );

      if (response.statusCode == 200 && response.body.isNotEmpty) {
        final data = json.decode(response.body);
        if (data['error'] == false &&
            data['data'] != null &&
            data['data'] is List) {
          if (mounted) {
            setState(() {
              qcApprovals = List<Map<String, dynamic>>.from(data['data']);
            });
          }
        }
      }
    } catch (e) {
      debugPrint("Fetch QC error: $e");
    }
  }

  Future<void> _handlePOAction(String poId, String status, String poNo) async {
    setState(() => isLoading = true);
    try {
      final prefs = await SharedPreferences.getInstance();
      final deviceData = await DeviceServices.getAndStoreDeviceInfo();
      final response = await http.post(
        Uri.parse(RequestApprovals.apiUrl),
        body: {
          "type": "4030",
          "cid": prefs.getString('cid') ?? '44555666',
          "uid": prefs.getString('uid') ?? '2',
          "role_id": prefs.getString('role_id') ?? '1',
          "device_id": deviceData['device_id'] ?? '123',
          "lt": deviceData['lt'] ?? '0.0',
          "ln": deviceData['ln'] ?? '0.0',
          "po_id": poId,
          "status": status,
        },
      );
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['error'] == false) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text("PO $poNo $status successfully"),
                backgroundColor: Colors.green),
          );
          _fetchAll();
          if (status == "Approved") {
            _showGRNPrompt(poNo);
          }
        }
      }
    } catch (e) {
      debugPrint("PO action error: $e");
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  void _showGRNPrompt(String poNo) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text("Approved Successfully",
            style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
        content: Text(
            "Purchase Order $poNo has been approved. Would you like to create a GRN for this order now?",
            style: GoogleFonts.outfit()),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("Later", style: GoogleFonts.outfit(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => CreateGRNScreen(initialPoNo: poNo)));
            },
            style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF26A69A),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8))),
            child: Text("Create GRN",
                style: GoogleFonts.outfit(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: _tabs.length,
      child: Scaffold(
        backgroundColor: const Color(0xFFF1F5F9),
        appBar: AppBar(
          centerTitle: false,
          leading: widget.isEmbedded
              ? null
              : IconButton(
                  icon: Icon(Icons.arrow_back_ios_new_rounded,
                      color: Colors.white, size: 20.sp),
                  onPressed: () => Navigator.pop(context),
                ),
          title: _isSearching
              ? TextField(
                  controller: _searchController,
                  autofocus: true,
                  style:
                      GoogleFonts.outfit(color: Colors.white, fontSize: 16.sp),
                  decoration: const InputDecoration(
                    hintText: "Search approvals...",
                    hintStyle: TextStyle(color: Colors.white70),
                    border: InputBorder.none,
                  ),
                  onChanged: (val) {
                    setState(() => _searchQuery = val.toLowerCase());
                  },
                )
              : Text(
                  "Approvals",
                  style: GoogleFonts.outfit(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 18.sp),
                ),
          actions: [
            IconButton(
              icon: Icon(_isSearching ? Icons.close : Icons.search,
                  color: Colors.white),
              onPressed: () {
                setState(() {
                  _isSearching = !_isSearching;
                  if (!_isSearching) {
                    _searchQuery = "";
                    _searchController.clear();
                  }
                });
              },
            ),
          ],
          bottom: TabBar(
            onTap: (index) {
              setState(() {
                _currentTab = _tabs[index];
              });
            },
            indicatorColor: Colors.white,
            indicatorWeight: 3,
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white.withOpacity(0.7),
            labelStyle: GoogleFonts.outfit(
                fontWeight: FontWeight.bold, fontSize: 13.sp),
            unselectedLabelStyle: GoogleFonts.outfit(
                fontWeight: FontWeight.w600, fontSize: 13.sp),
            tabs: _tabs.map((tab) => Tab(text: tab)).toList(),
          ),
        ),
        body: _buildMainContent(),
      ),
    );
  }

  String _currentTab = "All";
  final List<String> _tabs = ["All", "PR", "PO", "QC"];

  Widget _buildMainContent() {
    final list = _getFilteredList(_currentTab);

    if (isLoading) {
      return const Center(
          child: CircularProgressIndicator(color: Color(0xFF14B8A6)));
    }

    if (list.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(24.w),
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                      color: Colors.black.withOpacity(0.03), blurRadius: 20),
                ],
              ),
              child: Icon(Icons.assignment_turned_in_rounded,
                  size: 64.sp, color: Colors.teal.shade50),
            ),
            SizedBox(height: 20.h),
            Text(
              "All Caught Up!",
              style: GoogleFonts.outfit(
                  fontWeight: FontWeight.bold,
                  fontSize: 18.sp,
                  color: Colors.blueGrey.shade800),
            ),
            Text(
              "No pending ${_currentTab == 'All' ? 'approvals' : _currentTab} found",
              style: GoogleFonts.outfit(color: Colors.grey, fontSize: 14.sp),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _fetchAll,
      color: const Color(0xFF14B8A6),
      child: ListView.builder(
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
        itemCount: list.length,
        itemBuilder: (context, index) =>
            _buildModernCard(list[index], _currentTab),
      ),
    );
  }

  Widget _buildModernCard(dynamic data, String category) {
    dynamic master = data.containsKey('master')
        ? data['master']
        : (data.containsKey('master_po') ? data['master_po'] : data);
    List items = data.containsKey('items') ? data['items'] : [];

    String itemCode = (items.isNotEmpty)
        ? (items[0]['item_code'] ?? items[0]['item_no'] ?? '').toString()
        : '';
    if (itemCode == 'N/A') itemCode = '';

    String prefix = (master['grn_no'] ??
            master['no'] ??
            master['po_no'] ??
            master['requ_no'] ??
            master['id'] ??
            (itemCode.isNotEmpty ? itemCode : 'N/A'))
        .toString();

    bool isQC = (data['grn_no'] != null || category == "QC");
    bool isPO = !isQC && (data['po_no'] != null || data['master_po'] != null);
    bool isPR =
        !isQC && !isPO && (data['master'] != null || data['requ_no'] != null);

    // Re-evaluate based on specific keys if the tab isn't forced
    if (category == "All") {
      isQC = data['grn_no'] != null;
      isPO = !isQC && (data['po_no'] != null || data['master_po'] != null);
      isPR =
          !isQC && !isPO && (data['master'] != null || data['requ_no'] != null);
    }

    String date = (master['date'] ??
            master['po_date'] ??
            master['dtime'] ??
            master['req_date'] ??
            (items.isNotEmpty
                ? (items[0]['date'] ?? items[0]['req_date'] ?? 'N/A')
                : 'N/A'))
        .toString();
    if (date.contains(' ')) date = date.split(' ')[0];

    String title = "Purchase Request";
    String subtitle = "N/A";
    String meta = "N/A";

    if (isQC) {
      final qcItems = data['items'] ?? [];
      String qcTitle = "QC Inspection";
      if (data['pro_name'] != null && data['pro_name'].toString().isNotEmpty) {
        qcTitle = data['pro_name'].toString();
      } else if (data['product_name'] != null &&
          data['product_name'].toString().isNotEmpty) {
        qcTitle = data['product_name'].toString();
      } else if (qcItems.isNotEmpty && qcItems[0]['product_name'] != null) {
        qcTitle = qcItems[0]['product_name'].toString();
      }
      title = qcTitle;
      subtitle = "GRN: ${(data['grn_no'] ?? 'N/A')}";
      String status = data['qc_status'] ?? 'Pending';
      meta =
          "Status: $status ${data['inspector_name'] != null ? '| By: ' + data['inspector_name'].toString() : ''}";
    } else if (isPO) {
      title = "Purchase Order Request";
      subtitle = master['supplier_name'] ?? 'N/A';
      
      String poStatus = "Pending";
      String rawPOStatus = master['status']?.toString() ?? "";
      if (rawPOStatus == "Approved" || rawPOStatus == "2") poStatus = "Approved";
      else if (rawPOStatus == "Rejected" || rawPOStatus == "3") poStatus = "Rejected";
      else if (rawPOStatus.toLowerCase().contains("approve po generated")) poStatus = "Pending";
      
      meta = "Status: $poStatus | Total: ₹${master['grand_total'] ?? master['tot_amt'] ?? '0'}";
    } else if (isPR) {
      final itemsList = data['items'] ?? [];
      String typeStr = master['type'] != null && master['type'].toString().isNotEmpty 
          ? ' [${master['type']}]' 
          : '';
      title = (itemsList.isNotEmpty
          ? (itemsList[0]['pro_name'] ?? itemsList[0]['product_name'] ?? 'Purchase Item')
          : 'Purchase Item') + typeStr;
      subtitle = master['department'] ?? 'N/A';
      
      String statusStr = "Pending";
      String rawStatus = master['status']?.toString() ?? "";
      if (rawStatus == "2") statusStr = "Approved";
      else if (rawStatus == "3") statusStr = "Rejected";
      else if (rawStatus.toLowerCase().contains("approve po generated")) statusStr = "Pending";
      else statusStr = "Pending"; // Handles "1", null, "", etc.

      String reqBy = userMap[master['requested_by']?.toString()] ??
          master['requested_by']?.toString() ??
          'N/A';
      meta = "Status: $statusStr | By: $reqBy";
    }

    Color accentColor = isPR
        ? const Color(0xFF0EA5E9)
        : (isPO ? const Color(0xFFF59E0B) : const Color(0xFF8B5CF6));
    IconData icon = isPR
        ? Icons.description_rounded
        : (isPO ? Icons.shopping_cart_rounded : Icons.fact_check_rounded);
    
    String typeLabel = isQC ? "QC" : (isPO ? "PO" : "PR");
    if (isPR && master['type'] != null && master['type'].toString().isNotEmpty) {
      typeLabel = "PR (${master['type']})";
    }

    return Container(
      margin: EdgeInsets.only(bottom: 16.h),
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
            padding: EdgeInsets.all(16.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: EdgeInsets.all(8.w),
                          decoration: BoxDecoration(
                            color: accentColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(icon, color: accentColor, size: 18.sp),
                        ),
                        SizedBox(width: 12.w),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(
                                  prefix,
                                  style: GoogleFonts.outfit(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 15.sp,
                                      color: Colors.blueGrey.shade900),
                                ),
                                if (master['pdf_link'] != null && master['pdf_link'].toString().isNotEmpty)
                                  Padding(
                                    padding: EdgeInsets.only(left: 8.w),
                                    child: InkWell(
                                      onTap: () => Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) => PurchaseRequestPdfViewer(
                                            pdfUrl: master['pdf_link'].toString(),
                                            prNumber: prefix,
                                          ),
                                        ),
                                      ),
                                      child: Icon(Icons.picture_as_pdf, color: Colors.red, size: 18.sp),
                                    ),
                                  ),
                              ],
                            ),
                            Text(
                              date,
                              style: GoogleFonts.outfit(
                                  fontSize: 11.sp,
                                  color: Colors.grey,
                                  fontWeight: FontWeight.w500),
                            ),
                          ],
                        ),
                      ],
                    ),
                    Container(
                      padding:
                          EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                      decoration: BoxDecoration(
                        color: accentColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: accentColor.withOpacity(0.2)),
                      ),
                      child: Text(
                        typeLabel,
                        style: GoogleFonts.outfit(
                            color: accentColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 10.sp),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 16.h),
                Text(
                  title,
                  style: GoogleFonts.outfit(
                      fontWeight: FontWeight.w700,
                      fontSize: 16.sp,
                      color: Colors.blueGrey.shade800),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 4.h),
                Row(
                  children: [
                    Icon(Icons.business_center_rounded,
                        size: 14.sp, color: Colors.grey.shade400),
                    SizedBox(width: 6.w),
                    Expanded(
                      child: Text(
                        subtitle,
                        style: GoogleFonts.outfit(
                            color: Colors.grey.shade600,
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w500),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 4.h),
                Row(
                  children: [
                    Icon(Icons.person_pin_rounded,
                        size: 14.sp, color: Colors.grey.shade400),
                    SizedBox(width: 6.w),
                    Expanded(
                      child: Text(
                        meta,
                        style: GoogleFonts.outfit(
                            color: Colors.grey.shade600,
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w500),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(24),
                  bottomRight: Radius.circular(24)),
              border: Border(top: BorderSide(color: Colors.grey.shade100)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      if (isPR || isPO) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => RequestApprovalDetailsScreen(
                              masterData: isPR
                                  ? (data['master'] ?? data)
                                  : (data['master_po'] ?? data),
                              itemsData: data['items'] ?? [],
                              isPO: isPO,
                            ),
                          ),
                        ).then((_) => _fetchAll());
                      } else {
                        Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (_) => ModernQCInspectionScreen(
                                        inspectionData: data)))
                            .then((_) => _fetchAll());
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF26A69A),
                      foregroundColor: Colors.white,
                      elevation: 0,
                      padding: EdgeInsets.symmetric(vertical: 12.h),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                            isQC
                                ? Icons.fact_check_outlined
                                : Icons.check_circle_outline,
                            size: 18.sp),
                        SizedBox(width: 8.w),
                        Text(
                          isQC ? "Inspect Items" : "Review & Approve",
                          style: GoogleFonts.outfit(
                              fontWeight: FontWeight.bold, fontSize: 13.sp),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  List<dynamic> _getFilteredList(String category) {
    List<dynamic> listToFilter = [];
    if (category == "PR") {
      listToFilter = prApprovals;
    } else if (category == "PO") {
      listToFilter = poApprovals;
    } else if (category == "QC") {
      listToFilter = qcApprovals;
    } else {
      listToFilter = [...prApprovals, ...poApprovals, ...qcApprovals];
      listToFilter.sort((a, b) {
        String dateA = (a['date'] ??
                (a['master']?['date']) ??
                (a['master_po']?['po_date']) ??
                a['grn_date'] ??
                a['dtime'] ??
                '0')
            .toString();
        String dateB = (b['date'] ??
                (b['master']?['date']) ??
                (b['master_po']?['po_date']) ??
                b['grn_date'] ??
                b['dtime'] ??
                '0')
            .toString();
        return dateB.compareTo(dateA);
      });
    }

    if (_searchQuery.isEmpty) return listToFilter;

    return listToFilter.where((item) {
      dynamic master = item.containsKey('master')
          ? item['master']
          : (item.containsKey('master_po') ? item['master_po'] : item);
      List items = item.containsKey('items') ? item['items'] : [];

      String searchContent = [
        master['no'],
        master['po_no'],
        master['requ_no'],
        master['id'],
        master['supplier_name'],
        master['department'],
        master['requested_by'],
        item['product_name'],
        item['pro_name'],
        item['item_code'],
        ...items.map((i) => "${i['product_name']} ${i['item_code']}")
      ].join(" ").toLowerCase();

      return searchContent.contains(_searchQuery);
    }).toList();
  }
}
