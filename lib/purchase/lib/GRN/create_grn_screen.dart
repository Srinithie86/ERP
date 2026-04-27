import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:purchase_erp/utils/device_services.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:google_fonts/google_fonts.dart';

class GRNItemData {
  final TextEditingController itemCodeController = TextEditingController();
  final TextEditingController productNameController = TextEditingController();
  final TextEditingController orderedQtyController = TextEditingController(text: "0");
  final TextEditingController receivedQtyController = TextEditingController(text: "0");
  final TextEditingController acceptedQtyController = TextEditingController(text: "0");
  final TextEditingController rejectedQtyController = TextEditingController(text: "0");
  final TextEditingController remarksController = TextEditingController();
  String? color;
  String? qcLabel;

  void dispose() {
    itemCodeController.dispose();
    productNameController.dispose();
    orderedQtyController.dispose();
    receivedQtyController.dispose();
    acceptedQtyController.dispose();
    rejectedQtyController.dispose();
    remarksController.dispose();
  }
}

class CreateGRNScreen extends StatefulWidget {
  final String? initialPoNo;
  const CreateGRNScreen({super.key, this.initialPoNo});

  @override
  State<CreateGRNScreen> createState() => _CreateGRNScreenState();
}

class _CreateGRNScreenState extends State<CreateGRNScreen> {
  // Logic-only controllers (removed from UI)
  final TextEditingController grnNoController = TextEditingController();
  final TextEditingController gnrDateController = TextEditingController();
  final TextEditingController receivedByController = TextEditingController();
  
  // UI Controllers
  final TextEditingController supplierIdController = TextEditingController();
  final TextEditingController supplierNameController = TextEditingController();
  final TextEditingController poNoController = TextEditingController();
  final TextEditingController invoiceNoController = TextEditingController();
  final TextEditingController vehicleNoController = TextEditingController();
  final TextEditingController driverNameController = TextEditingController();
  final TextEditingController warehouseLocationController = TextEditingController();

  List<String> poList = [];
  String? selectedPoNo;
  String? selectedPurchaseType;
  String? selectedTransportType;
  
  bool _isLoadingPos = false;
  bool _isLoadingPoItems = false;
  bool _isSubmitting = false;
  bool _isLoadingSuppliers = true;
  List<Map<String, dynamic>> _allSuppliers = [];
  List<GRNItemData> itemsList = [GRNItemData()];

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      String name = prefs.getString('name') ?? '';
      receivedByController.text = name;
      
      // Auto-set date for backend
      final now = DateTime.now();
      gnrDateController.text = "${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}";
    });

    _fetchGrnNo();
    _fetchAllSuppliers();
    if (widget.initialPoNo != null) {
      setState(() {
        selectedPoNo = widget.initialPoNo;
        poNoController.text = widget.initialPoNo!;
      });
      _fetchPoItems(widget.initialPoNo!);
    }
  }

  Future<void> _fetchAllSuppliers() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cid = prefs.getString('cid') ?? '';
      final deviceData = await DeviceServices.getAndStoreDeviceInfo();
      
      final response = await http.post(
        Uri.parse("https://erpsmart.in/total/api/m_api/"),
        body: {
          "type": "4014",
          "cid": cid,
          "device_id": deviceData['device_id'] ?? 'Unknown',
          "ln": deviceData['ln'] ?? '0.0',
          "lt": deviceData['lt'] ?? '0.0',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['error'] == false && data['data'] != null) {
          if (mounted) {
            setState(() {
              _allSuppliers = List<Map<String, dynamic>>.from(data['data']);
              _isLoadingSuppliers = false;
            });
          }
        }
      }
    } catch (e) {
      debugPrint("Fetch Suppliers Error: $e");
      if (mounted) setState(() => _isLoadingSuppliers = false);
    }
  }

  Future<void> _fetchGrnNo() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cid = prefs.getString('cid') ?? '';
      final deviceData = await DeviceServices.getAndStoreDeviceInfo();

      final response = await http.post(
        Uri.parse("https://erpsmart.in/total/api/m_api/"),
        body: {
          "type": "4026",
          "cid": cid,
          "device_id": deviceData['device_id'] ?? 'Unknown',
          "ln": deviceData['ln'] ?? '0.0',
          "lt": deviceData['lt'] ?? '0.0',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['error'] == false) {
           final grnNoDate = data['grn_no_date']?.toString() ?? '';
           if (grnNoDate.contains(' / ')) {
             final parts = grnNoDate.split(' / ');
             if (mounted) {
               setState(() {
                  grnNoController.text = parts[0].trim();
               });
             }
           } else {
             if (mounted) {
               setState(() {
                  grnNoController.text = grnNoDate;
               });
             }
           }
        }
      }
    } catch (e) {
      debugPrint("Fetch GRN No Error: $e");
    }
  }

  Future<void> _saveGRN() async {
    if (supplierIdController.text.isEmpty) {
      _showSnackBar("Please select a supplier");
      return;
    }
    if (itemsList.isEmpty) {
      _showSnackBar("Please add at least one item");
      return;
    }

    // Confirmation Dialog
    bool? confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Confirm Submission", style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
        content: Text("Are you sure you want to save this Goods Received Note (GRN)?", style: GoogleFonts.outfit()),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: Text("Cancel", style: GoogleFonts.outfit(color: Colors.grey))),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xff22A79A), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
            child: Text("Confirm & Save", style: GoogleFonts.outfit(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    setState(() => _isSubmitting = true);

    try {
      final prefs = await SharedPreferences.getInstance();
      final cid = prefs.getString('cid') ?? '';
      final uid = prefs.getString('uid') ?? prefs.getString('id') ?? '';
      final roleId = prefs.getString('role_id') ?? '';
      final deviceData = await DeviceServices.getAndStoreDeviceInfo();

      final Map<String, String> body = {
        "type": "4025",
        "cid": cid,
        "device_id": deviceData['device_id'] ?? 'Unknown',
        "uid": uid,
        "role_id": roleId,
        "ln": deviceData['ln'] ?? '0.0',
        "lt": deviceData['lt'] ?? '0.0',
        "grn_no": grnNoController.text.trim(),
        "gnr_date": gnrDateController.text.trim(), // API parameter often uses 'gnr' or 'grn'
        "grn_date": gnrDateController.text.trim(), // Adding both for compatibility
        "po_no": poNoController.text.trim(),
        "supplier_id": supplierIdController.text.trim(),
        "invoice_no": invoiceNoController.text.trim(),
        "vehicle_no": vehicleNoController.text.trim(),
        "driver_name": driverNameController.text.trim(),
        "received_by": receivedByController.text.trim(),
        "warehouse_location": warehouseLocationController.text.trim(),
        "purchase_type": selectedPurchaseType ?? '',
        "transport_type": selectedTransportType ?? '',
      };

      for (int i = 0; i < itemsList.length; i++) {
        final item = itemsList[i];
        // Indexed parameters for multiple items
        body["item_code[$i]"] = item.itemCodeController.text.trim();
        body["product_name[$i]"] = item.productNameController.text.trim();
        body["ordered_qty[$i]"] = item.orderedQtyController.text.trim();
        body["received_qty[$i]"] = item.receivedQtyController.text.trim();
        body["accepted_qty[$i]"] = item.acceptedQtyController.text.trim();
        body["rejected_qty[$i]"] = item.rejectedQtyController.text.trim();
        body["remarks[$i]"] = item.remarksController.text.trim();

        // Also send flat parameters for the first item (requested by specification)
        if (i == 0) {
          body["item_code"] = item.itemCodeController.text.trim();
          body["product_name"] = item.productNameController.text.trim();
          body["ordered_qty"] = item.orderedQtyController.text.trim();
          body["received_qty"] = item.receivedQtyController.text.trim();
          body["accepted_qty"] = item.acceptedQtyController.text.trim();
          body["rejected_qty"] = item.rejectedQtyController.text.trim();
          body["remarks"] = item.remarksController.text.trim();
        }
      }

      final response = await http.post(
        Uri.parse("https://erpsmart.in/total/api/m_api/"),
        body: body,
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['error'] == false || data['error'] == "false") {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(data['message'] ?? "GRN Saved Successfully"), backgroundColor: Colors.green),
            );
            Navigator.pop(context, true);
          }
        } else {
          _showSnackBar(data['message'] ?? "Submission failed");
        }
      }
    } catch (e) {
      _showSnackBar("Error: $e");
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  void _showSnackBar(String msg) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
    }
  }

  @override
  void dispose() {
    grnNoController.dispose();
    gnrDateController.dispose();
    supplierIdController.dispose();
    supplierNameController.dispose();
    poNoController.dispose();
    invoiceNoController.dispose();
    vehicleNoController.dispose();
    driverNameController.dispose();
    receivedByController.dispose();
    warehouseLocationController.dispose();
    for (var item in itemsList) { item.dispose(); }
    super.dispose();
  }

  // --- UI Build Helpers ---

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16, top: 8),
      child: Text(
        title,
        style: GoogleFonts.outfit(
          color: const Color(0xff22A79A),
          fontWeight: FontWeight.bold,
          fontSize: 14,
        ),
      ),
    );
  }

  Widget _buildLabeledField(String label, Widget field) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.outfit(
            fontSize: 11,
            color: Colors.grey.shade700,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 6),
        field,
      ],
    );
  }

  Widget _buildTextField(String hint, TextEditingController controller, {bool readOnly = false}) {
    return Container(
      height: 44,
      decoration: BoxDecoration(
        color: readOnly ? Colors.grey.shade50 : Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 4, offset: const Offset(0, 2)),
        ],
      ),
      child: TextField(
        controller: controller,
        readOnly: readOnly,
        style: GoogleFonts.outfit(fontSize: 13, fontWeight: FontWeight.w500),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: GoogleFonts.outfit(fontSize: 13, color: Colors.grey.shade400),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(color: Colors.grey.shade200),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(color: Colors.grey.shade200),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: Color(0xff22A79A), width: 1.5),
          ),
        ),
      ),
    );
  }

  Widget _buildDropdown(String hint, String? value, List<String> items, ValueChanged<String?> onChanged) {
    return Container(
      height: 44,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 4, offset: const Offset(0, 2)),
        ],
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          isExpanded: true,
          value: value,
          hint: Text(hint, style: GoogleFonts.outfit(fontSize: 13, color: Colors.grey.shade400)),
          icon: const Icon(Icons.keyboard_arrow_down, color: Color(0xff22A79A), size: 20),
          items: items.map((val) => DropdownMenuItem(value: val, child: Text(val, style: GoogleFonts.outfit(fontSize: 13)))).toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }

  Widget _buildSupplierSearch() {
    return Container(
      height: 44,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 4, offset: const Offset(0, 2)),
        ],
      ),
      child: TypeAheadField<Map<String, dynamic>>(
        controller: supplierNameController,
        suggestionsCallback: (query) {
          if (query.isEmpty) return _allSuppliers;
          return _allSuppliers.where((s) => s['name'].toString().toLowerCase().contains(query.toLowerCase())).toList();
        },
        builder: (context, controller, focusNode) {
          return TextField(
            controller: controller,
            focusNode: focusNode,
            style: GoogleFonts.outfit(fontSize: 13, fontWeight: FontWeight.w500),
            decoration: InputDecoration(
              hintText: "Search Supplier Name...",
              hintStyle: GoogleFonts.outfit(fontSize: 13, color: Colors.grey.shade400),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: Colors.grey.shade200)),
              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: Colors.grey.shade200)),
              focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Color(0xff22A79A), width: 1.5)),
            ),
          );
        },
        itemBuilder: (context, suggestion) => ListTile(title: Text(suggestion['name'].toString(), style: GoogleFonts.outfit(fontSize: 13))),
        onSelected: (suggestion) {
          setState(() {
            supplierNameController.text = suggestion['name'].toString();
            supplierIdController.text = suggestion['id'].toString();
          });
          _fetchPOsForSupplier(suggestion['name'].toString());
        },
      ),
    );
  }

  Future<void> _fetchPOsForSupplier(String name) async {
    setState(() => _isLoadingPos = true);
    try {
      final prefs = await SharedPreferences.getInstance();
      final cid = prefs.getString('cid') ?? '';
      final deviceData = await DeviceServices.getAndStoreDeviceInfo();
      
      final response = await http.post(
        Uri.parse("https://erpsmart.in/total/api/m_api/"),
        body: {
          "type": "4023",
          "cid": cid,
          "uid": prefs.getString('id') ?? '',
          "supplier_name": name,
          "device_id": deviceData['device_id'] ?? 'Unknown',
          "ln": deviceData['ln'] ?? '0.0',
          "lt": deviceData['lt'] ?? '0.0',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['error'] == false && data['data'] != null) {
          setState(() {
             poList = (data['data'] as List).map((e) => e['po_no'].toString()).toSet().toList();
          });
        }
      }
    } catch (e) {
      debugPrint("Fetch PO Error: $e");
    } finally {
      if (mounted) setState(() => _isLoadingPos = false);
    }
  }

  Future<void> _fetchPoItems(String poNo) async {
    setState(() => _isLoadingPoItems = true);
    try {
      final prefs = await SharedPreferences.getInstance();
      final deviceData = await DeviceServices.getAndStoreDeviceInfo();
      
      final response = await http.post(
        Uri.parse("https://erpsmart.in/total/api/m_api/"),
        body: {
          "type": "4024",
          "cid": prefs.getString('cid') ?? '',
          "po_no": poNo,
          "device_id": deviceData['device_id'] ?? 'Unknown',
          "ln": deviceData['ln'] ?? '0.0',
          "lt": deviceData['lt'] ?? '0.0',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['error'] == false && data['data'] != null) {
          setState(() {
            for (var it in itemsList) it.dispose();
            itemsList.clear();
            for (var row in data['data']) {
              final newItem = GRNItemData();
              newItem.itemCodeController.text = row['item_code']?.toString() ?? '';
              newItem.productNameController.text = row['pro_name']?.toString() ?? '';
              newItem.orderedQtyController.text = row['quantity']?.toString() ?? '0';
              newItem.color = row['color']?.toString();
              newItem.qcLabel = row['qc_label']?.toString();
              itemsList.add(newItem);
            }
          });
        }
      }
    } finally {
      if (mounted) setState(() => _isLoadingPoItems = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF8FAFB),
      appBar: AppBar(
        title: Text("Create New GRN", style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
        backgroundColor: const Color(0xff22A79A),
        elevation: 0,
        centerTitle: false,
        leading: IconButton(icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 20), onPressed: () => Navigator.pop(context)),
      ),
      body: _isLoadingSuppliers 
        ? const Center(child: CircularProgressIndicator(color: Color(0xff22A79A)))
        : Stack(
            children: [
              SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildSectionTitle("SUPPLIER & ORDER INFO"),
                    
                    GridView.count(
                      crossAxisCount: 2,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 16,
                      childAspectRatio: 2.2,
                      children: [
                        _buildLabeledField("SUPPLIER NAME", _buildSupplierSearch()),
                        _buildLabeledField("PO NUMBER", _isLoadingPos 
                            ? const Center(child: CircularProgressIndicator(strokeWidth: 2)) 
                            : _buildDropdown("Select PO", selectedPoNo, poList, (val) {
                                setState(() { selectedPoNo = val; poNoController.text = val ?? ''; });
                                if (val != null) _fetchPoItems(val);
                              })),
                        _buildLabeledField("PURCHASE TYPE", _buildDropdown("Select Type", selectedPurchaseType, ["Import", "Local"], (val) => setState(() => selectedPurchaseType = val))),
                        _buildLabeledField("INVOICE NO", _buildTextField("Enter Invoice No", invoiceNoController)),
                        _buildLabeledField("VEHICLE NO", _buildTextField("Enter Vehicle No", vehicleNoController)),
                        _buildLabeledField("TRANSPORT TYPE", _buildDropdown("Select Mode", selectedTransportType, ["Lorry", "Van", "Courier"], (val) => setState(() => selectedTransportType = val))),
                        _buildLabeledField("DRIVER NAME", _buildTextField("Enter Driver Name", driverNameController)),
                        _buildLabeledField("DC NO / LOCATION", _buildTextField("Enter DC/Location", warehouseLocationController)),
                      ],
                    ),
                    
                    const SizedBox(height: 32),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildSectionTitle("ITEMS TO RECEIVE"),
                        if (_isLoadingPoItems) const SizedBox(height: 16, width: 16, child: CircularProgressIndicator(strokeWidth: 2)),
                      ],
                    ),

                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: itemsList.length,
                      itemBuilder: (context, index) {
                        return _buildItemCard(index);
                      },
                    ),
                  ],
                ),
              ),

              // Bottom Submit Action
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, -5))],
                  ),
                  child: ElevatedButton(
                    onPressed: _isSubmitting ? null : _saveGRN,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xff22A79A),
                      foregroundColor: Colors.white,
                      minimumSize: const Size(double.infinity, 54),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      elevation: 0,
                    ),
                    child: _isSubmitting 
                        ? const CircularProgressIndicator(color: Colors.white)
                        : Text("SUBMIT GRN", style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 0.5)),
                  ),
                ),
              ),
            ],
          ),
    );
  }

  Widget _buildItemCard(int index) {
    final item = itemsList[index];
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: (item.qcLabel != null && item.qcLabel!.isNotEmpty) ? const Color(0xffFFFDE7) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: (item.qcLabel != null && item.qcLabel!.isNotEmpty) ? const Color(0xffF9A825).withOpacity(0.3) : Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Text("ITEM #${index + 1}",
                      style: GoogleFonts.outfit(
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                          color: Colors.grey.shade500)),
                  if (item.qcLabel != null && item.qcLabel!.isNotEmpty) ...[
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: _parseColor(item.color).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(
                            color: _parseColor(item.color).withOpacity(0.5)),
                      ),
                      child: Text(
                        item.qcLabel!,
                        style: GoogleFonts.outfit(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: _parseColor(item.color),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
              if (itemsList.length > 1)
                IconButton(
                    icon: const Icon(Icons.remove_circle_outline,
                        color: Colors.red, size: 20),
                    onPressed: () => setState(() {
                          item.dispose();
                          itemsList.removeAt(index);
                        })),
            ],
          ),
          const SizedBox(height: 12),
          _buildLabeledField("PRODUCT NAME", _buildTextField("Enter Product Name", item.productNameController)),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(child: _buildLabeledField("ITEM CODE", _buildTextField("Code", item.itemCodeController))),
              const SizedBox(width: 12),
              Expanded(child: _buildLabeledField("ORDERED QTY", _buildTextField("0", item.orderedQtyController, readOnly: true))),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(child: _buildLabeledField("RECEIVED QTY", _buildTextField("0", item.receivedQtyController))),
              const SizedBox(width: 12),
              Expanded(child: _buildLabeledField("ACCEPTED QTY", _buildTextField("0", item.acceptedQtyController))),
              const SizedBox(width: 12),
              Expanded(child: _buildLabeledField("REJECTED QTY", _buildTextField("0", item.rejectedQtyController))),
            ],
          ),
          const SizedBox(height: 12),
          _buildLabeledField("REMARKS", _buildTextField("Enter item specific remarks", item.remarksController)),
        ],
      ),
    );
  }

  Color _parseColor(String? hexColor) {
    if (hexColor == null || hexColor.isEmpty) return Colors.grey.shade400;
    try {
      String cleanHex = hexColor.replaceAll('#', '');
      if (cleanHex.length == 6) cleanHex = 'FF$cleanHex';
      return Color(int.parse(cleanHex, radix: 16));
    } catch (e) {
      return Colors.grey.shade400;
    }
  }
}
