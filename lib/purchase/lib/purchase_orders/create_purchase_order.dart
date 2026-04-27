import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:purchase_erp/utils/device_services.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:google_fonts/google_fonts.dart';
import 'po_item_details_screen.dart';

class CreatePurchaseOrderScreen extends StatefulWidget {
  const CreatePurchaseOrderScreen({super.key});

  @override
  State<CreatePurchaseOrderScreen> createState() => _CreatePurchaseOrderScreenState();
}

class _CreatePurchaseOrderScreenState extends State<CreatePurchaseOrderScreen> {
  final List<Map<String, dynamic>> itemsList = [];

  final TextEditingController poNumberController = TextEditingController();
  final TextEditingController supplierNameController = TextEditingController();
  final TextEditingController quotationRefController = TextEditingController();
  final TextEditingController deliveryAddressController = TextEditingController();
  final TextEditingController deliveryDateController = TextEditingController(
    text: "${DateTime.now().year}-${DateTime.now().month.toString().padLeft(2, '0')}-${DateTime.now().day.toString().padLeft(2, '0')}",
  );
  final TextEditingController taxAmountController = TextEditingController(text: "0.00");

  String? cid;
  String? deviceId;
  String? mid;
  String? selectedSupplierId;
  String? lt;
  String? ln;
  bool isSaving = false;
  bool isLoadingTerms = false;
  String selectedStatus = "Pending";
  String? selectedPaymentTerm;
  List<Map<String, dynamic>> paymentTermsOptions = [];
  String grandTotalValue = "₹0.00";

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
        mid = prefs.getString('mid') ?? '0';
        deviceId = prefs.getString('device_id') ?? 'Unknown';
        lt = prefs.getString('lt') ?? '145';
        ln = prefs.getString('ln') ?? '145';
      });

      _fetchPaymentTerms(); // Fetch payment terms on load

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

  Future<void> _fetchPaymentTerms() async {
    if (cid == null) return;
    setState(() => isLoadingTerms = true);
    try {
      final response = await http.post(
        Uri.parse("https://erpsmart.in/total/api/m_api/"),
        body: {
          "type": "4045",
          "cid": cid!,
          "device_id": deviceId ?? "123",
          "lt": lt ?? "145",
          "ln": ln ?? "145",
        },
      );
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['error'] == false && data['data'] != null) {
          setState(() {
            paymentTermsOptions = List<Map<String, dynamic>>.from(data['data']);
          });
        }
      }
    } catch (e) {
      debugPrint("Fetch payment terms error: $e");
    } finally {
      if (mounted) setState(() => isLoadingTerms = false);
    }
  }

  Future<Map<String, dynamic>> _calculateItem(Map<String, dynamic> input) async {
    if (cid == null) return {};
    try {
      final response = await http.post(
        Uri.parse("https://erpsmart.in/total/api/m_api/"),
        body: {
          "type": "4008",
          "cid": cid!,
          "device_id": deviceId ?? "",
          "ln": ln ?? "0",
          "lt": lt ?? "0",
          "quantity": input['quantity'] ?? "0",
          "unit_rate": input['unit_rate'] ?? "0",
          "discount": input['discount'] ?? "0",
          "tax": input['tax'] ?? "0",
        },
      );
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true && data['items'] != null && data['items'].isNotEmpty) {
          return data['items'][0];
        }
      }
    } catch (e) {
      debugPrint("Item Calc error: $e");
    }
    return {};
  }

  void _calculateGrandTotal() {
    double total = 0.0;
    double taxTotal = 0.0;
    for (var item in itemsList) {
      total += double.tryParse((item['total'] as TextEditingController).text) ?? 0.0;
      taxTotal += double.tryParse((item['taxAmt'] as TextEditingController).text) ?? 0.0;
    }
    setState(() {
      grandTotalValue = "₹${total.toStringAsFixed(2)}";
      taxAmountController.text = taxTotal.toStringAsFixed(2);
    });
  }

  Future<List<Map<String, dynamic>>> _searchItems(String query) async {
    if (query.trim().isEmpty || cid == null) return [];
    try {
      final response = await http.post(
        Uri.parse("https://erpsmart.in/total/api/m_api/"),
        body: {
          "type": "4003",
          "cid": cid!,
          "device_id": deviceId ?? "",
          "lt": lt ?? "0",
          "ln": ln ?? "0",
          "search": query.trim(),
        },
      );
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['error'] == false && data['data'] != null) {
          return List<Map<String, dynamic>>.from(data['data']);
        }
      }
    } catch (e) {
      debugPrint("Search error: $e");
    }
    return [];
  }

  Future<List<Map<String, dynamic>>> _searchSuppliers(String query) async {
    if (cid == null || query.isEmpty) return [];
    try {
      final response = await http.post(
        Uri.parse("https://erpsmart.in/total/api/m_api/"),
        body: {
          "type": "4010",
          "cid": cid!,
          "device_id": deviceId ?? "",
          "lt": lt ?? "0",
          "ln": ln ?? "0",
          "search": query,
        },
      );
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['error'] == false && data['data'] != null) {
          return List<Map<String, dynamic>>.from(data['data']);
        }
      }
    } catch (e) {
      debugPrint("Supplier search error: $e");
    }
    return [];
  }

  Future<void> _savePurchaseOrder() async {
    if (cid == null || cid!.isEmpty) {
      _showSnackBar("CID is missing. Please log in again.");
      return;
    }
    if (itemsList.isEmpty) {
      _showSnackBar("Please add at least one item");
      return;
    }
    if (supplierNameController.text.trim().isEmpty) {
      _showSnackBar("Please select a supplier");
      return;
    }
    if (selectedPaymentTerm == null) {
      _showSnackBar("Please select payment terms");
      return;
    }

    // Confirmation Dialog
    bool? confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Confirm Purchase Order", style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
        content: Text("Are you sure you want to create this Purchase Order? This will notify the supplier and update the records.", style: GoogleFonts.outfit()),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: Text("Cancel", style: GoogleFonts.outfit(color: Colors.grey))),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xff22A79A), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
            child: Text("Confirm & Create", style: GoogleFonts.outfit(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    setState(() => isSaving = true);
    try {
      final prefs = await SharedPreferences.getInstance();
      String uid = prefs.getString('uid') ?? prefs.getString('id') ?? '1';
      final roleId = prefs.getString('role_id') ?? '1';
      
      List<Map<String, dynamic>> itemsJson = [];
      for (var item in itemsList) {
        itemsJson.add({
          "item_code": (item["code"] as TextEditingController).text.trim(),
          "pro_name": (item["name"] as TextEditingController).text.trim(),
          "uom": (item["uom"] as TextEditingController).text.trim(),
          "quantity": (item["qty"] as TextEditingController).text.trim(),
          "unit_rate": (item["rate"] as TextEditingController).text.trim(),
          "discount": (item["discountPerc"] as TextEditingController).text.trim(),
          "tax": (item["taxPerc"] as TextEditingController).text.trim(),
          "tax_amt": (item["taxAmt"] as TextEditingController).text.trim(),
          "tot_amt": (item["total"] as TextEditingController).text.trim(),
        });
      }

      final Map<String, String> body = {
        "cid": cid!,
        "type": "4009",
        "uid": uid,
        "mid": mid ?? "0",
        "role_id": roleId,
        "ln": ln ?? "145",
        "lt": lt ?? "145",
        "device_id": deviceId ?? "123",
        "po_no": poNumberController.text,
        "quotation_ref": quotationRefController.text.trim(),
        "delivery_date": deliveryDateController.text,
        "payment_terms": selectedPaymentTerm ?? "", // Added Payment Terms
        "status": selectedStatus,
        "supplier_id": selectedSupplierId ?? "0",
        "supplier_name": supplierNameController.text.trim(),
        "delivery_address": deliveryAddressController.text.trim(),
        "tax_amount": taxAmountController.text,
        "grand_total": grandTotalValue.replaceAll('₹', '').replaceAll(',', '').trim(),
        "items": jsonEncode(itemsJson),
      };

      final response = await http.post(Uri.parse("https://erpsmart.in/total/api/m_api/"), body: body);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['error'] == false || data['error']?.toString().toLowerCase() == 'false') {
          if (mounted) _showSuccessDialog();
        } else {
          _showSnackBar(data['message'] ?? data['error_msg'] ?? "Error occurred during submission");
        }
      }
    } catch (e) {
      _showSnackBar("Connection error: $e");
    } finally {
      if (mounted) setState(() => isSaving = false);
    }
  }

  void _showSnackBar(String msg) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
    }
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16, top: 8),
      child: Text(
        title,
        style: GoogleFonts.outfit(color: const Color(0xff22A79A), fontWeight: FontWeight.bold, fontSize: 14),
      ),
    );
  }

  Widget _buildLabeledField(String label, Widget field) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: GoogleFonts.outfit(fontSize: 11, color: Colors.grey.shade700, fontWeight: FontWeight.w600)),
        const SizedBox(height: 6),
        field,
      ],
    );
  }

  Widget _buildTextField(String hint, TextEditingController controller, {bool readOnly = false, VoidCallback? onTap}) {
    return Container(
      height: 44,
      decoration: BoxDecoration(
        color: readOnly ? Colors.grey.shade50 : Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 4, offset: const Offset(0, 2))],
      ),
      child: TextField(
        controller: controller,
        readOnly: readOnly,
        onTap: onTap,
        style: GoogleFonts.outfit(fontSize: 13, fontWeight: FontWeight.w500),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: GoogleFonts.outfit(fontSize: 13, color: Colors.grey.shade400),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: Colors.grey.shade200)),
          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: Colors.grey.shade200)),
          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Color(0xff22A79A), width: 1.5)),
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
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 4, offset: const Offset(0, 2))],
      ),
      child: TypeAheadField<Map<String, dynamic>>(
        controller: supplierNameController,
        suggestionsCallback: _searchSuppliers,
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
        itemBuilder: (context, suggestion) => ListTile(
          title: Text(suggestion['Ledger_Name'] ?? 'N/A', style: GoogleFonts.outfit(fontSize: 13, fontWeight: FontWeight.bold)),
          subtitle: Text(suggestion['address'] ?? '', style: GoogleFonts.outfit(fontSize: 11)),
        ),
        onSelected: (suggestion) {
          setState(() {
            supplierNameController.text = suggestion['Ledger_Name'] ?? '';
            selectedSupplierId = suggestion['id']?.toString() ?? '0';
            deliveryAddressController.text = suggestion['address'] ?? '';
          });
        },
      ),
    );
  }

  Future<void> _selectDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null) {
      setState(() {
        deliveryDateController.text = "${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF8FAFB),
      appBar: AppBar(
        title: Text("Create Purchase Order", style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
        backgroundColor: const Color(0xff22A79A),
        elevation: 0,
        centerTitle: false,
        leading: IconButton(icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 20), onPressed: () => Navigator.pop(context)),
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 110),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildSectionTitle("SUPPLIER & DELIVERY INFO"),
                _buildLabeledField("SUPPLIER NAME", _buildSupplierSearch()),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(child: _buildLabeledField("QUOTATION REF", _buildTextField("Enter Ref#", quotationRefController))),
                    const SizedBox(width: 12),
                    Expanded(child: _buildLabeledField("DELIVERY DATE", InkWell(
                      onTap: () => _selectDate(context),
                      child: IgnorePointer(child: _buildTextField("Select Date", deliveryDateController, readOnly: true)),
                    ))),
                  ],
                ),
                const SizedBox(height: 16),
                _buildLabeledField("DELIVERY ADDRESS", _buildTextField("Enter Address", deliveryAddressController)),
                const SizedBox(height: 16),
                _buildLabeledField("PAYMENT TERMS", Container(
                  height: 44,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: isLoadingTerms 
                    ? const Center(child: SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)))
                    : DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          isExpanded: true,
                          hint: Text("Select Terms", style: GoogleFonts.outfit(fontSize: 13, color: Colors.grey)),
                          value: selectedPaymentTerm,
                          items: paymentTermsOptions
                              .map((t) => DropdownMenuItem(value: t['name'].toString(), child: Text(t['name'].toString(), style: GoogleFonts.outfit(fontSize: 13))))
                              .toList(),
                          onChanged: (val) => setState(() => selectedPaymentTerm = val),
                        ),
                      ),
                )),
                
                const SizedBox(height: 32),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildSectionTitle("ORDERED ITEMS"),
                    TextButton.icon(
                      onPressed: () async {
                        final result = await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => POItemDetailsScreen(searchItems: _searchItems, calculateItem: _calculateItem),
                          ),
                        );
                        if (result != null) {
                          setState(() {
                            itemsList.add({
                              "code": TextEditingController(text: result['code']),
                              "name": TextEditingController(text: result['name']),
                              "uom": TextEditingController(text: result['uom']),
                              "qty": TextEditingController(text: result['qty']),
                              "rate": TextEditingController(text: result['rate']),
                              "taxPerc": TextEditingController(text: result['taxPerc']),
                              "taxAmt": TextEditingController(text: result['taxAmt']),
                              "discountPerc": TextEditingController(text: result['discountPerc']),
                              "discountAmt": TextEditingController(text: result['discountAmt']),
                              "total": TextEditingController(text: result['total']),
                            });
                            _calculateGrandTotal();
                          });
                        }
                      },
                      icon: const Icon(Icons.add_circle_outline_rounded, size: 20, color: Color(0xff22A79A)),
                      label: Text("Add Item", style: GoogleFonts.outfit(color: const Color(0xff22A79A), fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
                
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: itemsList.length,
                  itemBuilder: (context, index) => _buildItemCard(index),
                ),
              ],
            ),
          ),
          
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, -5))],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("TAX AMOUNT", style: GoogleFonts.outfit(fontWeight: FontWeight.w500, fontSize: 13, color: Colors.grey.shade600)),
                      Text("₹${taxAmountController.text}", style: GoogleFonts.outfit(fontWeight: FontWeight.w600, fontSize: 13, color: Colors.blueGrey)),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("GRAND TOTAL", style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.grey.shade600)),
                      Text(grandTotalValue, style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 18, color: const Color(0xff22A79A))),
                    ],
                  ),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: isSaving ? null : _savePurchaseOrder,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xff22A79A),
                      foregroundColor: Colors.white,
                      minimumSize: const Size(double.infinity, 54),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      elevation: 0,
                    ),
                    child: isSaving 
                        ? const CircularProgressIndicator(color: Colors.white)
                        : Text("CONFIRM PURCHASE ORDER", style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 0.5)),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildItemCard(int index) {
    final item = itemsList[index];
    final name = (item['name'] as TextEditingController).text;
    final qty = (item['qty'] as TextEditingController).text;
    final total = (item['total'] as TextEditingController).text;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(color: const Color(0xff22A79A).withOpacity(0.1), shape: BoxShape.circle),
                  child: const Icon(Icons.shopping_bag_outlined, color: Color(0xff22A79A), size: 20),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(name, style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 14)),
                      const SizedBox(height: 4),
                      Text("QTY: $qty  |  TOTAL: ₹$total", style: GoogleFonts.outfit(color: Colors.grey, fontSize: 12)),
                    ],
                  ),
                ),
                _buildQuantityControl(index),
              ],
            ),
          ),
          const Divider(height: 1),
          Row(
            children: [
              Expanded(
                child: TextButton(
                  onPressed: () => _editItem(index),
                  child: Text("Edit", style: GoogleFonts.outfit(color: const Color(0xff22A79A), fontWeight: FontWeight.bold, fontSize: 13)),
                ),
              ),
              Container(width: 1, height: 20, color: Colors.grey.shade200),
              Expanded(
                child: TextButton(
                  onPressed: () {
                    setState(() {
                      itemsList.removeAt(index);
                      _calculateGrandTotal();
                    });
                  },
                  child: Text("Remove", style: GoogleFonts.outfit(color: Colors.red, fontWeight: FontWeight.bold, fontSize: 13)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuantityControl(int index) {
    final item = itemsList[index];
    final qtyController = item['qty'] as TextEditingController;

    return Row(
      children: [
        InkWell(
          onTap: () async {
            int val = int.tryParse(qtyController.text) ?? 1;
            if (val > 1) {
              qtyController.text = (val - 1).toString();
              await _updateItemCalculation(index);
            }
          },
          child: Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(border: Border.all(color: Colors.grey.shade300), borderRadius: BorderRadius.circular(4)),
            child: const Icon(Icons.remove, size: 14),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Text(qtyController.text, style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 14)),
        ),
        InkWell(
          onTap: () async {
            int val = int.tryParse(qtyController.text) ?? 1;
            qtyController.text = (val + 1).toString();
            await _updateItemCalculation(index);
          },
          child: Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(color: const Color(0xff22A79A), borderRadius: BorderRadius.circular(4)),
            child: const Icon(Icons.add, size: 14, color: Colors.white),
          ),
        ),
      ],
    );
  }

  Future<void> _updateItemCalculation(int index) async {
    final item = itemsList[index];
    final res = await _calculateItem({
      'quantity': (item['qty'] as TextEditingController).text,
      'unit_rate': (item['rate'] as TextEditingController).text,
      'tax': (item['taxPerc'] as TextEditingController).text,
      'discount': (item['discountPerc'] as TextEditingController).text,
    });
    if (res.isNotEmpty) {
      setState(() {
        (item['taxAmt'] as TextEditingController).text = res['tax_amt']?.toString() ?? '0';
        (item['discountAmt'] as TextEditingController).text = res['discount_amount']?.toString() ?? '0';
        (item['total'] as TextEditingController).text = res['tot_amt']?.toString() ?? '0';
        _calculateGrandTotal();
      });
    }
  }

  Future<void> _editItem(int index) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => POItemDetailsScreen(
          searchItems: _searchItems,
          calculateItem: _calculateItem,
          initialData: itemsList[index],
        ),
      ),
    );
    if (result != null) {
      setState(() {
        itemsList[index].forEach((key, controller) {
           (controller as TextEditingController).text = result[key].toString();
        });
        _calculateGrandTotal();
      });
    }
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.check_circle, color: Color(0xff22A79A), size: 60),
            const SizedBox(height: 16),
            Text("Order Placed!", style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text("Purchase Order has been created successfully.", textAlign: TextAlign.center, style: GoogleFonts.outfit(color: Colors.grey, fontSize: 13)),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xff22A79A), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
                onPressed: () { Navigator.pop(context); Navigator.pop(context); },
                child: Text("DONE", style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    poNumberController.dispose();
    supplierNameController.dispose();
    quotationRefController.dispose();
    deliveryAddressController.dispose();
    deliveryDateController.dispose();
    taxAmountController.dispose();
    for (var item in itemsList) {
      item.values.forEach((v) => (v as TextEditingController).dispose());
    }
    super.dispose();
  }
}
