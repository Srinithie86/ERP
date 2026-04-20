import 'package:flutter/material.dart';
import '../dashboard.dart';
import 'request_approval_details.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:purchase_erp/utils/device_services.dart';
import '../QC/grn_inspection_screen.dart';

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
            'type': '4006',
            'cid': cid,
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
            cachedApprovals = jsonResponse['data'] ?? [];
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

  @override
  State<RequestApprovals> createState() => _RequestApprovalsState();
}

class _RequestApprovalsState extends State<RequestApprovals> {
  List<dynamic> prApprovals = List.from(RequestApprovals.cachedApprovals);
  List<Map<String, dynamic>> poApprovals = [];
  List<Map<String, dynamic>> qcApprovals = [];
  Map<String, String> userMap = Map.from(RequestApprovals.cachedUserMap);
  bool isLoading = !RequestApprovals.hasCachedData;

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
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['error'] == false) {
          userMap.clear();
          for (var user in data['data']) {
            userMap[user['id'].toString()] = user['name'].toString();
          }
          RequestApprovals.cachedUserMap = Map.from(userMap);
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
          'type': '4006',
          'cid': cid,
          'device_id': '123',
          'ln': '123',
          'lt': '34',
        },
      );
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['error'] == false) {
          if (mounted) {
            setState(() {
              prApprovals = data['data'] ?? [];
              RequestApprovals.cachedApprovals = prApprovals;
              RequestApprovals.hasCachedData = true;
            });
          }
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
          'type': '4027',
          'cid': cid,
          'device_id': '123',
          'uid': prefs.getString('uid') ?? '2',
          'role_id': '1',
          'lt': '123',
          'ln': '123',
        },
      );
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['error'] == false) {
          if (mounted) {
            setState(() {
              poApprovals = List<Map<String, dynamic>>.from(data['data'] ?? []);
            });
          }
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
      
      // Fetch from both PO (25601) and PR (25001) sources for QC
      final results = await Future.wait([
        http.post(
          Uri.parse("https://erpsmart.in/total/api/m_api/"),
          body: {
            "type": "2083",
            "cid": cid,
            "device_id": "123",
            "lt": "123",
            "ln": "123",
            "form": "sm_main_form_25601",
            "select": "*",
            "where": "qc_status like '%Pend%'",
          },
        ),
        http.post(
          Uri.parse("https://erpsmart.in/total/api/m_api/"),
          body: {
            "type": "2083",
            "cid": cid,
            "device_id": "123",
            "lt": "123",
            "ln": "123",
            "form": "sm_main_form_25001",
            "select": "*",
            "where": "qc_status like '%Pend%'",
          },
        ),
      ]);

      List<Map<String, dynamic>> combinedQC = [];
      for (var response in results) {
        if (response.statusCode == 200) {
          final data = json.decode(response.body);
          if (data['error'] == false && data['data'] != null) {
            combinedQC.addAll(List<Map<String, dynamic>>.from(data['data']));
          }
        }
      }

      if (mounted) {
        setState(() {
          qcApprovals = combinedQC;
        });
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
            SnackBar(content: Text("PO $poNo $status successfully"), backgroundColor: Colors.green),
          );
          _fetchAll();
        }
      }
    } catch (e) {
      debugPrint("PO action error: $e");
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 4,
      child: PopScope(
        canPop: !widget.isEmbedded,
        onPopInvokedWithResult: (didPop, result) {
          if (didPop) return;
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const Dashboard()));
        },
        child: Scaffold(
          backgroundColor: const Color(0xffF8FAFB),
          appBar: AppBar(
            elevation: 0,
            backgroundColor: const Color(0xFF26A69A),
            leading: widget.isEmbedded ? null : IconButton(
              icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 20),
              onPressed: () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const Dashboard())),
            ),
            title: Text("Approvals", style: GoogleFonts.outfit(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 20)),
            bottom: TabBar(
              indicatorColor: Colors.white,
              indicatorWeight: 3,
              labelColor: Colors.white,
              unselectedLabelColor: Colors.white.withOpacity(0.7),
              labelStyle: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 13),
              unselectedLabelStyle: GoogleFonts.outfit(fontWeight: FontWeight.w500, fontSize: 13),
              tabs: const [
                Tab(text: "PR"),
                Tab(text: "PO"),
                Tab(text: "QC"),
                Tab(text: "All"),
              ],
            ),
          ),
          body: TabBarView(
            children: [
              _buildApprovalList("PR"),
              _buildApprovalList("PO"),
              _buildApprovalList("QC"),
              _buildApprovalList("All"),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildApprovalList(String category) {
    final list = _getFilteredList(category);
    if (isLoading) return const Center(child: CircularProgressIndicator(color: Color(0xFF26A69A)));
    if (list.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.assignment_turned_in_outlined, size: 64, color: Colors.grey.shade300),
            const SizedBox(height: 16),
            Text("No $category pending", style: GoogleFonts.outfit(color: Colors.grey, fontSize: 16)),
          ],
        ),
      );
    }
    return RefreshIndicator(
      onRefresh: _fetchAll,
      color: const Color(0xFF26A69A),
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: list.length,
        itemBuilder: (context, index) => _buildCard(list[index]),
      ),
    );
  }

  Widget _buildCard(dynamic data) {
    String prefix = (data['no'] ?? data['po_no'] ?? data['grn_no'] ?? 'N/A').toString();
    bool isPR = data.containsKey('master') || (prefix.startsWith("PR"));
    bool isPO = prefix.contains("PO") && !data.containsKey('grn_no');
    bool isQC = data.containsKey('grn_no');

    String date = (data['date'] ?? data['po_date'] ?? data['dtime'] ?? 'N/A').toString();
    if (date.contains(' ')) date = date.split(' ')[0];

    String title = "Purchase Request";
    String dept = "N/A";
    String requester = "N/A";

    if (isPR) {
      final master = data['master'] ?? data;
      final items = data['items'] ?? [];
      title = items.isNotEmpty ? (items[0]['product_name'] ?? 'Purchase Item') : 'Purchase Item';
      dept = master['department'] ?? 'N/A';
      requester = userMap[master['requested_by']?.toString()] ?? master['requested_by']?.toString() ?? 'N/A';
    } else if (isPO) {
      title = "Purchase Order Request";
      dept = data['supplier_name'] ?? 'N/A';
      requester = "Total: ₹${data['tot_amt'] ?? '0'}";
    } else if (isQC) {
      title = (data['pro_name'] ?? data['product_name'] ?? "QC Inspection").toString();
      dept = (data['supplier_name'] ?? data['po_no'] ?? data['no'] ?? 'N/A').toString();
      String amount = data['tot_amt'] != null ? " | ₹${data['tot_amt']}" : "";
      requester = "Qty: ${data['qty'] ?? data['quantity_required'] ?? '0'}$amount";
    }

    Color accentColor = isPR ? const Color(0xFF26A69A) : (isPO ? const Color(0xFF5C6BC0) : const Color(0xFFFFA726));
    IconData icon = isPR ? Icons.description : (isPO ? Icons.shopping_bag : Icons.fact_check);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Column(
        children: [
          ListTile(
            leading: CircleAvatar(
              backgroundColor: accentColor.withOpacity(0.1),
              child: Icon(icon, color: accentColor, size: 20),
            ),
            title: Text(prefix, style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 15)),
            subtitle: Text(date, style: GoogleFonts.outfit(fontSize: 12, color: Colors.grey)),
            trailing: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(color: accentColor.withOpacity(0.1), borderRadius: BorderRadius.circular(20)),
              child: Text(isPR ? "PR" : (isPO ? "PO" : "QC"), style: GoogleFonts.outfit(color: accentColor, fontWeight: FontWeight.bold, fontSize: 10)),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: GoogleFonts.outfit(fontWeight: FontWeight.w600, fontSize: 14)),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(Icons.business, size: 14, color: Colors.grey.shade400),
                    const SizedBox(width: 4),
                    Flexible(
                      child: Text(
                        dept,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.outfit(fontSize: 12, color: Colors.grey.shade600),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Icon(Icons.person_outline, size: 14, color: Colors.grey.shade400),
                    const SizedBox(width: 4),
                    Flexible(
                      child: Text(
                        requester,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.outfit(fontSize: 12, color: Colors.grey.shade600),
                        textAlign: TextAlign.right,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      if (isPR) {
                        Navigator.push(context, MaterialPageRoute(builder: (_) => RequestApprovalDetailsScreen(masterData: data['master'] ?? data, itemsData: data['items'] ?? []))).then((_) => _fetchAll());
                      } else if (isPO) {
                        _handlePOAction(data['id']?.toString() ?? '', "Approved", prefix);
                      } else if (isQC) {
                        Navigator.push(context, MaterialPageRoute(builder: (_) => GrnInspectionScreen(inspectionData: data))).then((_) => _fetchAll());
                      }
                    },
                    style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF43A047), foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)), elevation: 0),
                    child: Text(isQC ? "Inspect" : "Approve", style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
                  ),
                ),
                const SizedBox(width: 12),
                if (!isQC) ...[
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        if (isPR) {
                          Navigator.push(context, MaterialPageRoute(builder: (_) => RequestApprovalDetailsScreen(masterData: data['master'] ?? data, itemsData: data['items'] ?? []))).then((_) => _fetchAll());
                        } else if (isPO) {
                          _handlePOAction(data['id']?.toString() ?? '', "Rejected", prefix);
                        }
                      },
                      style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFE53935), foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)), elevation: 0),
                      child: Text("Reject", style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
                const SizedBox(width: 12),
                GestureDetector(
                  onTap: () {
                    if (isPR) {
                      Navigator.push(context, MaterialPageRoute(builder: (_) => RequestApprovalDetailsScreen(masterData: data['master'] ?? data, itemsData: data['items'] ?? []))).then((_) => _fetchAll());
                    } else if (isQC) {
                      Navigator.push(context, MaterialPageRoute(builder: (_) => GrnInspectionScreen(inspectionData: data))).then((_) => _fetchAll());
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(border: Border.all(color: Colors.grey.shade300), borderRadius: BorderRadius.circular(10)),
                    child: const Icon(Icons.visibility_outlined, size: 20, color: Colors.grey),
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
    if (category == "PR") return prApprovals;
    if (category == "PO") return poApprovals;
    if (category == "QC") return qcApprovals;

    List<dynamic> all = [];
    all.addAll(prApprovals);
    all.addAll(poApprovals);
    all.addAll(qcApprovals);
    all.sort((a, b) {
      String dateA = (a['date'] ?? a['po_date'] ?? a['dtime'] ?? '0').toString();
      String dateB = (b['date'] ?? b['po_date'] ?? b['dtime'] ?? '0').toString();
      return dateB.compareTo(dateA);
    });
    return all;
  }
}
