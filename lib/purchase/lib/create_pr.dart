import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:purchase_erp/utils/device_services.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:purchase_erp/item_details_screen.dart';
import 'package:purchase_erp/purchase_orders/pr_details.dart';
import 'package:purchase_erp/models/pr_model.dart' as model;

class ItemData {
  final TextEditingController itemCodeController = TextEditingController();
  final TextEditingController itemNameController = TextEditingController();
  final TextEditingController uomController = TextEditingController();
  final TextEditingController stockQtyController = TextEditingController();
  final TextEditingController orderQtyController = TextEditingController();
  final TextEditingController todDateController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();

  void dispose() {
    itemCodeController.dispose();
    itemNameController.dispose();
    uomController.dispose();
    stockQtyController.dispose();
    orderQtyController.dispose();
    todDateController.dispose();
    descriptionController.dispose();
  }
}

class CreatePurchaseRequestScreen extends StatefulWidget {
  const CreatePurchaseRequestScreen({super.key});

  @override
  State<CreatePurchaseRequestScreen> createState() =>
      _CreatePurchaseRequestScreenState();
}

class _CreatePurchaseRequestScreenState
    extends State<CreatePurchaseRequestScreen> {
  List<ItemData> itemsList = [];

  String? selectedDepartment;
  String? selectedDeptId;
  String? selectedReqBy;
  String? selectedPriority;
  String? selectedPriorityId;
  final TextEditingController prNumberController = TextEditingController(
    text: "Auto-Generated",
  );
  final TextEditingController reqByController = TextEditingController();
  final TextEditingController remarksController = TextEditingController();
  final TextEditingController _searchController = TextEditingController();

  // New: Dynamic departments from API
  List<Map<String, dynamic>> departmentList = [];
  List<Map<String, dynamic>> priorityList = [];
  bool isLoadingDepartments = true;
  bool isLoadingPriorities = true;
  bool _isSubmitting = false;
  String? cid;
  String? deviceId;
  String? lt;
  String? ln;

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // Get what we have instantly
      String prefCid = prefs.getString('cid') ?? '';
      String prefDeviceId = prefs.getString('device_id') ?? 'Unknown';
      String prefLt = prefs.getString('lt') ?? '0.0';
      String prefLn = prefs.getString('ln') ?? '0.0';

      setState(() {
        cid = prefCid;
        deviceId = prefDeviceId;
        lt = prefLt;
        ln = prefLn;
      });

      _loadUserInfo(prefs);

      // ⚡ TRIGGER API CALLS IMMEDIATELY if we have CID
      if (prefCid.isNotEmpty) {
        _fetchInitialAPIData();
      }

      // Ensure we have device info even if not in prefs (run in background, don't block API calls)
      if (prefDeviceId == 'Unknown' || prefLt == '0.0') {
        DeviceServices.getAndStoreDeviceInfo().then((deviceData) {
          if (mounted) {
            setState(() {
              deviceId = deviceData['device_id'] ?? deviceId;
              lt = deviceData['lt'] ?? lt;
              ln = deviceData['ln'] ?? ln;
            });
            // If API calls weren't triggered yet because cid was empty (rare), try again
            if (cid != null && cid!.isNotEmpty && departmentList.isEmpty) {
              _fetchInitialAPIData();
            }
          }
        });
      }
    } catch (e) {
      debugPrint("Error loading initial data: $e");
    }
  }

  void _fetchInitialAPIData() {
    if (cid == null || cid!.isEmpty) {
      debugPrint("⚠️ Skipping initial API calls: cid is empty.");
      return;
    }
    // Parallelize all initial fetches
    _fetchDepartments();
    _fetchPriorities();
    _fetchPRNumber('');
  }

  Future<void> _fetchPRNumber(String itemCode) async {
    if (cid == null || cid!.isEmpty) {
      return;
    }
    try {
      final response = await http.post(
        Uri.parse("https://erpsmart.in/total/api/m_api/"),
        body: {
          "type": "4004",
          "cid": cid ?? '',
          "device_id": deviceId ?? 'Unknown',
          "lt": lt ?? '0.0',
          "ln": ln ?? '0.0',
          "item_code": itemCode,
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['error'] == false || data['error'] == 'false') {
          if (!mounted) {
            return;
          }
          setState(() {
            prNumberController.text =
                data['pr_number']?.toString() ?? 'Auto-Generated';
          });
          debugPrint("✅ PR Number Updated: ${data['pr_number']}");
        }
      }
    } catch (e) {
      debugPrint("Failed to fetch PR number: $e");
    }
  }

  Future<void> _loadUserInfo(SharedPreferences prefs) async {
    try {
      if (!mounted) {
        return;
      }
      setState(() {
        String name = prefs.getString('name') ?? 'Admin';
        name = name[0].toUpperCase() + name.substring(1);
        selectedReqBy = name;
        reqByController.text = selectedReqBy!;
      });
    } catch (e) {
      debugPrint("Error loading user info: $e");
    }
  }

  // Fetch departments from API
  Future<void> _fetchDepartments() async {
    if (cid == null || cid!.isEmpty) {
      return;
    }

    final prefs = await SharedPreferences.getInstance();
    final cachedData = prefs.getString('cached_departments');

    if (cachedData != null) {
      try {
        final decoded = json.decode(cachedData);
        if (!mounted) {
          return;
        }
        setState(() {
          departmentList = List<Map<String, dynamic>>.from(decoded);
          isLoadingDepartments = false;
        });
        debugPrint("⚡ Loaded Departments from Cache");
      } catch (e) {
        debugPrint("Error decoding cached departments: $e");
      }
    } else {
      if (!mounted) {
        return;
      }
      setState(() {
        isLoadingDepartments = true;
      });
    }

    try {
      final response = await http.post(
        Uri.parse("https://erpsmart.in/total/api/m_api/"),
        body: {
          "type": "4000",
          "cid": cid ?? '',
          "device_id": deviceId ?? 'Unknown',
          "lt": lt ?? '0.0',
          "ln": ln ?? '0.0',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if ((data['error'] == false || data['error'] == 'false') &&
            data['data'] != null) {
          final newList = List<Map<String, dynamic>>.from(data['data']);
          // Only update and save if data changed or was empty
          if (newList.toString() != departmentList.toString()) {
            if (!mounted) {
              return;
            }
            setState(() {
              departmentList = newList;
            });
            await prefs.setString('cached_departments', json.encode(newList));
            debugPrint("✅ Departments Fetched & Cached");
          }
        }
      }
    } catch (e) {
      debugPrint("Failed to fetch departments: $e");
    } finally {
      if (mounted) {
        setState(() {
          isLoadingDepartments = false;
        });
      }
    }
  }

  // Fetch Priorities from API (type: 4001)
  Future<void> _fetchPriorities() async {
    if (cid == null || cid!.isEmpty) {
      return;
    }

    final prefs = await SharedPreferences.getInstance();
    final cachedData = prefs.getString('cached_priorities');

    if (cachedData != null) {
      try {
        final decoded = json.decode(cachedData);
        if (!mounted) {
          return;
        }
        setState(() {
          priorityList = List<Map<String, dynamic>>.from(decoded);
          isLoadingPriorities = false;
        });
        debugPrint("⚡ Loaded Priorities from Cache");
      } catch (e) {
        debugPrint("Error decoding cached priorities: $e");
      }
    } else {
      if (!mounted) {
        return;
      }
      setState(() {
        isLoadingPriorities = true;
      });
    }

    try {
      final response = await http.post(
        Uri.parse("https://erpsmart.in/total/api/m_api/"),
        body: {
          "type": "4001",
          "cid": cid ?? '',
          "device_id": deviceId ?? 'Unknown',
          "lt": lt ?? '0.0',
          "ln": ln ?? '0.0',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if ((data['error'] == false || data['error'] == 'false') &&
            data['data'] != null) {
          final newList = List<Map<String, dynamic>>.from(data['data']);
          if (newList.toString() != priorityList.toString()) {
            if (!mounted) {
              return;
            }
            setState(() {
              priorityList = newList;
            });
            await prefs.setString('cached_priorities', json.encode(newList));
            debugPrint("✅ Priorities Fetched & Cached");
          }
        }
      }
    } catch (e) {
      debugPrint("Failed to fetch priorities: $e");
    } finally {
      if (mounted) {
        setState(() {
          isLoadingPriorities = false;
        });
      }
    }
  }

  Future<List<Map<String, dynamic>>> _searchItems(String query) async {
    if (query.trim().isEmpty) return [];
    if (cid == null || cid!.isEmpty) {
      debugPrint("⚠️ Cannot search: cid is missing");
      return [];
    }

    try {
      debugPrint("🔍 Searching for: '$query' (cid: $cid, device: $deviceId)");
      final response = await http.post(
        Uri.parse("https://erpsmart.in/total/api/m_api/"),
        body: {
          "type": "4003",
          "cid": cid ?? '',
          "device_id": deviceId ?? '123',
          "lt": lt ?? '0.0',
          "ln": ln ?? '0.0',
          "search": query.trim(),
        },
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['error'] == false && data['data'] != null) {
          debugPrint("✅ Found ${data['data'].length} items for '$query'");
          return List<Map<String, dynamic>>.from(data['data']);
        } else {
          debugPrint(
            "⚠️ Item Search API returned error or no data: ${data['message'] ?? 'No error message'}",
          );
        }
      } else {
        debugPrint("❌ Item Search API Fail: Status ${response.statusCode}");
      }
    } catch (e) {
      debugPrint("❌ Search Exception: $e");
    }
    return [];
  }

  Future<void> _submitPurchaseRequest() async {
    if (selectedDeptId == null || selectedDeptId!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please select a Department")),
      );
      return;
    }
    if (selectedPriorityId == null || selectedPriorityId!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please select a Priority")),
      );
      return;
    }

    if (itemsList.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please add at least one item")),
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      final prefs = await SharedPreferences.getInstance();
      final cid = prefs.getString('cid') ?? '';
      final uid = prefs.getString('uid') ?? prefs.getString('id') ?? '1';
      final name = prefs.getString('name') ?? '';
      final did = prefs.getString('did') ?? '1';
      final bid = prefs.getString('bid') ?? '1';
      final roleId = prefs.getString('role_id') ?? '';
      final deviceData = await DeviceServices.getAndStoreDeviceInfo();

      final ln = deviceData['ln'] ?? '0.0';
      final lt = deviceData['lt'] ?? '0.0';
      final deviceId = deviceData['device_id'] ?? 'Unknown';

      // Current Date for 'date' param
      final date =
          "${DateTime.now().year}-${DateTime.now().month.toString().padLeft(2, '0')}-${DateTime.now().day.toString().padLeft(2, '0')}";

      // Prepare request body with indexed item keys
      final Map<String, String> body = {
        "type": "4005",
        "cid": cid,
        "device_id": deviceId,
        "uid": uid,
        "did": did,
        "bid": bid,
        "role_id": roleId,
        "lt": lt,
        "ln": ln,
        "date": date,
        "department": selectedDeptId ?? '',
        "req_by": name, // Use stored login name
        "priority": selectedPriorityId ?? '',
        "remarks": remarksController.text, // Global remarks
      };

      for (int i = 0; i < itemsList.length; i++) {
        final item = itemsList[i];

        debugPrint("====== ITEM $i ======");
        debugPrint("Code: ${item.itemCodeController.text}");
        debugPrint("Name: ${item.itemNameController.text}");
        debugPrint("UOM: ${item.uomController.text}");
        debugPrint("Stock: ${item.stockQtyController.text}");
        debugPrint("Order Qty: ${item.orderQtyController.text}");
        debugPrint("Date: ${item.todDateController.text}");
        debugPrint("Desc: ${item.descriptionController.text}");

        body["item_code[$i]"] = item.itemCodeController.text;
        body["product_name[$i]"] = item.itemNameController.text;
        body["uom[$i]"] = item.uomController.text;
        body["current_order_quantity[$i]"] = item.orderQtyController.text;
        body["current_stock_qty[$i]"] = item.stockQtyController.text;
        body["dod_date[$i]"] = item.todDateController.text;
        body["description[$i]"] = item.descriptionController.text;
      }
      debugPrint("=========== REQUEST START ===========");
      debugPrint("URL: https://erpsmart.in/total/api/m_api/");
      body.forEach((key, value) {
        debugPrint("$key : $value");
      });

      final response = await http.post(
        Uri.parse("https://erpsmart.in/total/api/m_api/"),
        body: body,
      );
      debugPrint("=========== RESPONSE START ===========");
      debugPrint("STATUS CODE: ${response.statusCode}");
      debugPrint("RESPONSE BODY: ${response.body}");
      debugPrint("=========== RESPONSE END ===========");

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['error'] == false || data['error'] == "false") {
          final prNumber = data['pr_number'] ?? "";
          if (mounted) {
            setState(() {
              prNumberController.text = prNumber;
            });
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  "Purchase Request Saved Successfully. PR No: $prNumber",
                ),
                backgroundColor: Colors.green,
              ),
            );

            // Navigate back after a small delay
            Future.delayed(const Duration(seconds: 2), () {
              if (mounted) {
                Navigator.pop(context);
              }
            });
          }
        } else {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  data['message'] ?? data['error_msg'] ?? "Submission failed",
                ),
              ),
            );
          }
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Server error. Please try again.")),
          );
        }
      }
    } catch (e) {
      debugPrint("Submission Error: $e");
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Error: $e")));
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  @override
  void dispose() {
    for (var item in itemsList) {
      item.dispose();
    }
    remarksController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final width = size.width;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          "Create Purchase Request",
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: false,
        backgroundColor: Colors.transparent,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.centerRight,
              end: Alignment.centerLeft,
              colors: [Color(0xFF26A69A), Color(0xFF26A69A)],
            ),
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Search Bar matching the image
            Padding(
              padding: EdgeInsets.symmetric(horizontal: width * 0.04, vertical: 8),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: "Search by PR number or department....",
                    hintStyle: GoogleFonts.outfit(color: Colors.grey, fontSize: 13),
                    prefixIcon: const Icon(Icons.search, color: Colors.black),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(
                  horizontal: width * 0.04,
                  vertical: 8,
                ),
                child: Column(
                  children: [
                    _buildMasterDetails(width),
                    SizedBox(height: width * 0.04),
                    _buildAddItemButton(width),
                    SizedBox(height: width * 0.04),
                    _buildItemsList(width),
                    SizedBox(height: width * 0.04),
                  ],
                ),
              ),
            ),
            _buildBottomButtons(width),
          ],
        ),
      ),
    );
  }

  Widget _buildMasterDetails(double width) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Hidden from UI but functional for logic
          _buildInputLabel("Requested By"),
          _buildTextField("Requested By", controller: reqByController, readOnly: true),
          const SizedBox(height: 16),
          _buildInputLabel("Department"),
          _buildDepartmentDropdown(width),
          const SizedBox(height: 16),
          _buildInputLabel("Priority"),
          _buildPriorityDropdown(width),
          const SizedBox(height: 16),
          _buildInputLabel("Remarks"),
          _buildTextField("Enter Remarks", controller: remarksController, maxLines: 2),
        ],
      ),
    );
  }

  Widget _buildInputLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(
        label,
        style: GoogleFonts.outfit(
          fontWeight: FontWeight.w600,
          fontSize: 14,
          color: Colors.black87,
        ),
      ),
    );
  }

  Widget _buildDepartmentDropdown(double width) {
    if (isLoadingDepartments) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(12.0),
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
      );
    }

    final List<String> deptNames = departmentList
        .map((dept) => dept['department']?.toString() ?? '')
        .where((name) => name.isNotEmpty)
        .toList();

    return _buildDropdownField(
      "Enter Department Name",
      selectedDepartment,
      deptNames,
      (val) {
        setState(() {
          selectedDepartment = val;
          if (val != null) {
            final selectedDept = departmentList.firstWhere(
              (dept) => dept['department'] == val,
              orElse: () => {},
            );
            selectedDeptId = selectedDept['id']?.toString();
            debugPrint("Selected Department: $val (ID: $selectedDeptId)");
          }
        });
      },
    );
  }

  Widget _buildDropdownField(
    String hint,
    String? value,
    List<String> items,
    ValueChanged<String?> onChanged,
  ) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          isExpanded: true,
          value: items.contains(value) ? value : null,
          hint: Text(
            hint,
            style: TextStyle(color: Colors.grey.shade400, fontSize: 13),
          ),
          icon: const Icon(Icons.keyboard_arrow_down, color: Colors.black),
          items: items.map((String val) {
            return DropdownMenuItem<String>(
              value: val,
              child: Text(
                val,
                style: const TextStyle(fontSize: 14, color: Colors.black87),
              ),
            );
          }).toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }

  Widget _buildPriorityDropdown(double width) {
    if (isLoadingPriorities) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(12.0),
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
      );
    }

    final List<String> priorityNames = priorityList
        .map((p) => p['name']?.toString() ?? '')
        .where((name) => name.isNotEmpty)
        .toList();

    return _buildDropdownField(
      "Select Priority",
      selectedPriority,
      priorityNames,
      (val) {
        setState(() {
          selectedPriority = val;
          if (val != null) {
            final selectedPri = priorityList.firstWhere(
              (p) => p['name'] == val,
              orElse: () => {},
            );
            selectedPriorityId = selectedPri['id']?.toString();
            debugPrint("Selected Priority: $val (ID: $selectedPriorityId)");
          }
        });
      },
    );
  }

  Widget _buildAddItemButton(double width) {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton.icon(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ItemDetailsScreen(
                searchItems: _searchItems,
              ),
            ),
          );

          if (result != null && result is Map<String, dynamic>) {
            setState(() {
              final newItem = ItemData();
              newItem.itemNameController.text = result['item_name'] ?? '';
              newItem.itemCodeController.text = result['item_code'] ?? '';
              newItem.uomController.text = result['uom'] ?? '';
              newItem.stockQtyController.text = result['stock_qty'] ?? '';
              newItem.orderQtyController.text = result['order_qty'] ?? '';
              newItem.descriptionController.text = result['description'] ?? '';
              itemsList.add(newItem);
            });
          }
        },
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text(
          "Add Item",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF26A69A),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),
    );
  }

  Widget _buildItemsList(double width) {
    if (itemsList.isEmpty) return const SizedBox.shrink();

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: itemsList.length,
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final item = itemsList[index];
        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: const BoxDecoration(
                        color: Color(0xFF26A69A),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.description, color: Colors.white, size: 24),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.itemNameController.text.isEmpty ? "No Name" : item.itemNameController.text,
                            style: GoogleFonts.outfit(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            "Dept: ${selectedDepartment ?? 'N/A'}",
                            style: GoogleFonts.outfit(
                              color: Colors.grey,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Row(
                      children: [
                        IconButton(
                          onPressed: () {
                            setState(() {
                              int qty = int.tryParse(item.orderQtyController.text) ?? 0;
                              if (qty > 0) {
                                item.orderQtyController.text = (qty - 1).toString();
                              }
                            });
                          },
                          icon: const Icon(Icons.remove_circle, color: Color(0xFF26A69A)),
                        ),
                        Text(
                          item.orderQtyController.text.isEmpty ? "0" : item.orderQtyController.text,
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                        IconButton(
                          onPressed: () {
                            setState(() {
                              int qty = int.tryParse(item.orderQtyController.text) ?? 0;
                              item.orderQtyController.text = (qty + 1).toString();
                            });
                          },
                          icon: const Icon(Icons.add_circle, color: Color(0xFF26A69A)),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const Divider(height: 1),
              IntrinsicHeight(
                child: Row(
                  children: [
                    Expanded(
                      child: TextButton(
                        onPressed: () {
                          // View logic to PRDetailsScreen
                          // We pass dummy data for preview
                          final modelItems = itemsList.map((e) => model.PrItem(
                            id: 0,
                            no: prNumberController.text,
                            mid: 0,
                            date: "${DateTime.now().day}-${DateTime.now().month}-${DateTime.now().year}",
                            itemCode: e.itemCodeController.text,
                            productName: e.itemNameController.text,
                            qty: e.orderQtyController.text,
                            itemDescription: e.descriptionController.text,
                          )).toList();

                          final prData = model.PrData(
                            master: model.PrMaster(
                              id: 0,
                              no: prNumberController.text,
                              requestedBy: selectedReqBy,
                              priority: selectedPriority,
                              department: selectedDepartment ?? "",
                              quantityRequired: "0",
                              dtime: "",
                              reqDate: "${DateTime.now().day}-${DateTime.now().month}-${DateTime.now().year}",
                            ),
                            items: modelItems,
                          );

                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => PRDetailsScreen(
                                prId: prNumberController.text,
                                department: selectedDepartment ?? "",
                                status: "Draft",
                                prFullData: prData,
                              ),
                            ),
                          );
                        },
                        child: const Text("View", style: TextStyle(color: Color(0xFF26A69A), fontWeight: FontWeight.bold)),
                      ),
                    ),
                    const VerticalDivider(width: 1),
                    Expanded(
                      child: TextButton(
                        onPressed: () async {
                          final result = await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ItemDetailsScreen(
                                searchItems: _searchItems,
                                initialData: {
                                  'item_name': item.itemNameController.text,
                                  'item_code': item.itemCodeController.text,
                                  'uom': item.uomController.text,
                                  'stock_qty': item.stockQtyController.text,
                                  'order_qty': item.orderQtyController.text,
                                  'description': item.descriptionController.text,
                                },
                              ),
                            ),
                          );

                          if (result != null && result is Map<String, dynamic>) {
                            setState(() {
                              item.itemNameController.text = result['item_name'] ?? '';
                              item.itemCodeController.text = result['item_code'] ?? '';
                              item.uomController.text = result['uom'] ?? '';
                              item.stockQtyController.text = result['stock_qty'] ?? '';
                              item.orderQtyController.text = result['order_qty'] ?? '';
                              item.descriptionController.text = result['description'] ?? '';
                            });
                          }
                        },
                        child: const Text("Edit", style: TextStyle(color: Color(0xFF26A69A), fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildBottomButtons(double width) {
    return Container(
      padding: EdgeInsets.all(width * 0.04),
      decoration: const BoxDecoration(color: Colors.white),
      child: Column(
        children: [
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF26A69A),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                disabledBackgroundColor: const Color(
                  0xFF26A69A,
                ).withValues(alpha: 0.6),
              ),
              onPressed: _isSubmitting ? null : _submitPurchaseRequest,
              child: _isSubmitting
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                  : const Text(
                      "Submit For Approval",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }



  Widget _buildTextField(
    String hint, {
    int maxLines = 1,
    TextEditingController? controller,
    bool readOnly = false,
  }) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      readOnly: readOnly,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 13),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 12,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(6),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(6),
          borderSide: const BorderSide(color: Color(0xFF26A69A)),
        ),
        filled: true,
        fillColor: readOnly ? Colors.grey.shade50 : Colors.white,
      ),
    );
  }
}
