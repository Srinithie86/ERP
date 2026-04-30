import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'utils/device_services.dart';
import 'invoice_item_details_screen.dart';

class InvoiceItem {
  final TextEditingController productNameController = TextEditingController();
  final TextEditingController productIdController = TextEditingController();
  final TextEditingController hsnCodeController = TextEditingController();
  final TextEditingController qtyController = TextEditingController();
  final TextEditingController discountController = TextEditingController();
  final TextEditingController uomController = TextEditingController();
  final TextEditingController unitPriceController = TextEditingController();
  final TextEditingController taxableValueController = TextEditingController();
  final TextEditingController taxPercentageController = TextEditingController(text: "0");
  final TextEditingController totalAmountController = TextEditingController();

  void dispose() {
    productNameController.dispose();
    productIdController.dispose();
    hsnCodeController.dispose();
    qtyController.dispose();
    discountController.dispose();
    uomController.dispose();
    unitPriceController.dispose();
    taxableValueController.dispose();
    taxPercentageController.dispose();
    totalAmountController.dispose();
  }
}

class PurchaseInvoiceScreen extends StatefulWidget {
  const PurchaseInvoiceScreen({super.key});

  @override
  State<PurchaseInvoiceScreen> createState() => _PurchaseInvoiceScreenState();
}

class _PurchaseInvoiceScreenState extends State<PurchaseInvoiceScreen> {
  final List<InvoiceItem> _items = [];

  // Header Controllers
  final TextEditingController _invoiceNoController = TextEditingController();
  final TextEditingController _invoiceDateController = TextEditingController();
  final TextEditingController _supplierNameController = TextEditingController();
  final TextEditingController _supplierGstinController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _cusIdController = TextEditingController();
  final TextEditingController _transTypeController = TextEditingController(text: "1");
  final TextEditingController _transNameController = TextEditingController();
  final TextEditingController _bLocController = TextEditingController();
  final TextEditingController _bPinController = TextEditingController();
  final TextEditingController _bScodeController = TextEditingController();
  final TextEditingController _grnNoController = TextEditingController();
  final TextEditingController _dcNoController = TextEditingController();

  // Totals Controllers
  final TextEditingController _grandTotalController = TextEditingController(text: "0.00");
  final TextEditingController _taxableTotalController = TextEditingController(text: "0.00");
  final TextEditingController _roundOffController = TextEditingController(text: "0.00");
  final TextEditingController _totalGstController = TextEditingController(text: "0.00");
  final TextEditingController _cgstController = TextEditingController(text: "0.00");
  final TextEditingController _sgstController = TextEditingController(text: "0.00");
  final TextEditingController _igstController = TextEditingController(text: "0.00");
  final TextEditingController _tcsTotalController = TextEditingController(text: "0.00");

  String _selectedPriceType = "Exclude Tax";
  String _selectedTaxType = "CGST/SGST";
  String _selectedTcs = "NO TCS";
  String _selectedTds = "NO TDS";

  List<Map<String, dynamic>> _suppliers = [];
  bool _isLoadingSuppliers = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _invoiceDateController.text = "${DateTime.now().year}-${DateTime.now().month.toString().padLeft(2, '0')}-${DateTime.now().day.toString().padLeft(2, '0')}";
    _fetchSuppliersForDropdown();
    _calculateAll();
  }

  Future<void> _fetchSuppliersForDropdown() async {
    setState(() => _isLoadingSuppliers = true);
    try {
      final prefs = await SharedPreferences.getInstance();
      final cid = prefs.getString('cid') ?? '44555666';
      final response = await http.post(
        Uri.parse("https://erpsmart.in/total/api/m_api/"),
        body: {
          "cid": cid,
          "type": "4010",
          "device_id": "123",
          "ln": "145",
          "lt": "145",
          "search": "",
        },
      );
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['error'] == false) {
          setState(() {
            _suppliers = List<Map<String, dynamic>>.from(data['data'] ?? []);
          });
        }
      }
    } catch (e) {
      debugPrint("Fetch suppliers error: $e");
    } finally {
      if (mounted) setState(() => _isLoadingSuppliers = false);
    }
  }

  @override
  void dispose() {
    for (var item in _items) {
      item.dispose();
    }
    _invoiceNoController.dispose();
    _invoiceDateController.dispose();
    _supplierNameController.dispose();
    _supplierGstinController.dispose();
    _addressController.dispose();
    _cusIdController.dispose();
    _transTypeController.dispose();
    _transNameController.dispose();
    _bLocController.dispose();
    _grnNoController.dispose();
    _dcNoController.dispose();
    _grandTotalController.dispose();
    _taxableTotalController.dispose();
    _roundOffController.dispose();
    _totalGstController.dispose();
    _cgstController.dispose();
    _sgstController.dispose();
    _igstController.dispose();
    _tcsTotalController.dispose();
    super.dispose();
  }

  void _calculateAll() {
    double totalTaxable = 0;
    double totalCgst = 0;
    double totalSgst = 0;
    double totalIgst = 0;
    double grandTotal = 0;

    for (var item in _items) {
      double qty = double.tryParse(item.qtyController.text) ?? 0;
      double rate = double.tryParse(item.unitPriceController.text) ?? 0;
      double disc = double.tryParse(item.discountController.text) ?? 0;
      double taxPer = double.tryParse(item.taxPercentageController.text) ?? 0;

      double taxable = (qty * rate) - disc;
      double taxAmount = taxable * (taxPer / 100);
      double total = taxable + taxAmount;

      item.taxableValueController.text = taxable.toStringAsFixed(2);
      item.totalAmountController.text = total.toStringAsFixed(2);

      totalTaxable += taxable;
      if (_selectedTaxType == "CGST/SGST") {
        totalCgst += taxAmount / 2;
        totalSgst += taxAmount / 2;
      } else {
        totalIgst += taxAmount;
      }
    }

    grandTotal = totalTaxable + totalCgst + totalSgst + totalIgst;

    _taxableTotalController.text = totalTaxable.toStringAsFixed(2);
    _cgstController.text = totalCgst.toStringAsFixed(2);
    _sgstController.text = totalSgst.toStringAsFixed(2);
    _igstController.text = totalIgst.toStringAsFixed(2);
    _totalGstController.text = (totalCgst + totalSgst + totalIgst).toStringAsFixed(2);
    _grandTotalController.text = grandTotal.toStringAsFixed(2);
  }

  void _addItem() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const InvoiceItemDetailsScreen(),
      ),
    );
    if (result != null) {
      setState(() {
        final newItem = InvoiceItem();
        newItem.productNameController.text = result['productName'];
        newItem.productIdController.text = result['productId'];
        newItem.hsnCodeController.text = result['hsnCode'];
        newItem.qtyController.text = result['qty'];
        newItem.discountController.text = result['discount'];
        newItem.uomController.text = result['uom'];
        newItem.unitPriceController.text = result['unitPrice'];
        newItem.taxPercentageController.text = result['taxPercentage'];
        newItem.taxableValueController.text = result['taxableValue'];
        newItem.totalAmountController.text = result['totalAmount'];
        _items.add(newItem);
        _calculateAll();
      });
    }
  }

  void _editItem(int index) async {
    final item = _items[index];
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => InvoiceItemDetailsScreen(
          initialData: {
            'productName': item.productNameController.text,
            'productId': item.productIdController.text,
            'hsnCode': item.hsnCodeController.text,
            'qty': item.qtyController.text,
            'discount': item.discountController.text,
            'uom': item.uomController.text,
            'unitPrice': item.unitPriceController.text,
            'taxPercentage': item.taxPercentageController.text,
            'taxableValue': item.taxableValueController.text,
            'totalAmount': item.totalAmountController.text,
          },
        ),
      ),
    );

    if (result != null) {
      setState(() {
        item.productNameController.text = result['productName'];
        item.productIdController.text = result['productId'];
        item.hsnCodeController.text = result['hsnCode'];
        item.qtyController.text = result['qty'];
        item.discountController.text = result['discount'];
        item.uomController.text = result['uom'];
        item.unitPriceController.text = result['unitPrice'];
        item.taxPercentageController.text = result['taxPercentage'];
        item.taxableValueController.text = result['taxableValue'];
        item.totalAmountController.text = result['totalAmount'];
        _calculateAll();
      });
    }
  }

  void _removeItem(int index) {
    if (index >= 0 && index < _items.length) {
      setState(() {
        _items[index].dispose();
        _items.removeAt(index);
        _calculateAll();
      });
    }
  }

  Future<void> _fetchGRNDetails() async {
    final grnNo = _grnNoController.text.trim();
    if (grnNo.isEmpty) {
      _selectGRN(); // If empty, open selection dialog
      return;
    }

    setState(() => _isLoading = true);

    try {
      final prefs = await SharedPreferences.getInstance();
      final cid = prefs.getString('cid') ?? '44555666';
      
      final Map<String, String> body = {
        "cid": cid,
        "type": "4043",
        "device_id": "123",
        "ln": "145",
        "lt": "145",
        "grn_no": grnNo,
      };

      final response = await http.post(
        Uri.parse("https://erpsmart.in/total/api/m_api/"),
        body: body,
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['error'] == false && data['data'] != null) {
          final grnSource = data['data'];
          final master = grnSource['master'] ?? grnSource;
          final List<dynamic> fetchedItems = grnSource['items'] ?? master['items'] ?? [];
          
          setState(() {
            // Autofill Header Data from master or root
            _supplierNameController.text = master['supplier_name']?.toString() ?? master['b_name']?.toString() ?? master['vendor_name']?.toString() ?? _supplierNameController.text;
            _supplierGstinController.text = master['gst_no']?.toString() ?? master['b_gst']?.toString() ?? master['vendor_gst']?.toString() ?? _supplierGstinController.text;
            _addressController.text = master['address']?.toString() ?? master['b_add1']?.toString() ?? master['vendor_address']?.toString() ?? _addressController.text;
            _cusIdController.text = master['supplier_id']?.toString() ?? master['cus_id']?.toString() ?? master['vendor_id']?.toString() ?? _cusIdController.text;
            _dcNoController.text = master['invoice_no']?.toString() ?? master['dc_no']?.toString() ?? _dcNoController.text;

            // Clear existing items before autofilling
            for (var item in _items) {
              item.dispose();
            }
            _items.clear();

            for (var itemData in fetchedItems) {
              final newItem = InvoiceItem();
              newItem.productNameController.text = itemData['product_name']?.toString() ?? itemData['p_name']?.toString() ?? "";
              newItem.productIdController.text = itemData['item_code']?.toString() ?? itemData['product_id']?.toString() ?? "";
              
              // Qty priority: Accepted Qty > Received Qty > Ordered Qty
              newItem.qtyController.text = itemData['acc_qty']?.toString() ?? itemData['rec_qty']?.toString() ?? itemData['qty']?.toString() ?? "0";
              
              newItem.uomController.text = itemData['uom']?.toString() ?? "nos";
              newItem.taxPercentageController.text = itemData['tax']?.toString() ?? itemData['tax_per']?.toString() ?? "0";
              
              // Rate priority: unit_rate > rate > price
              newItem.unitPriceController.text = itemData['unit_rate']?.toString() ?? itemData['rate']?.toString() ?? itemData['price']?.toString() ?? "0.00";
              
              _items.add(newItem);
            }
            _calculateAll();
          });

          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text("Autofilled ${fetchedItems.length} items from GRN"), backgroundColor: Colors.green),
            );
          }
        } else {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(data['message'] ?? "No data found for this GRN"), backgroundColor: Colors.red),
            );
          }
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error fetching GRN: $e"), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _selectGRN() async {
    final selectedGRN = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const _GRNSelectionSheet(),
    );

    if (selectedGRN != null) {
      if (mounted) {
        setState(() {
          _grnNoController.text = selectedGRN;
        });
        _fetchGRNDetails();
      }
    }
  }

  Future<void> _selectSupplier() async {
    final selectedSupplier = await showModalBottomSheet<Map<String, dynamic>>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const _SupplierSelectionSheet(),
    );

    if (selectedSupplier != null) {
      setState(() {
        _supplierNameController.text = selectedSupplier['Ledger_Name']?.toString() ?? "";
        _supplierGstinController.text = selectedSupplier['gst']?.toString() ?? "";
        _addressController.text = selectedSupplier['address']?.toString() ?? "";
        _cusIdController.text = selectedSupplier['id']?.toString() ?? "";
        _bPinController.text = selectedSupplier['pincode']?.toString() ?? "";
        _bScodeController.text = selectedSupplier['state']?.toString() ?? "";
      });
    }
  }

  Future<List<dynamic>> _getSupplierSuggestions(String query) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cid = prefs.getString('cid') ?? '44555666';
      final response = await http.post(
        Uri.parse("https://erpsmart.in/total/api/m_api/"),
        body: {
          "cid": cid,
          "type": "4010",
          "device_id": "123",
          "ln": "145",
          "lt": "145",
          "search": query,
        },
      );
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['error'] == false) return data['data'] ?? [];
      }
    } catch (e) {
      debugPrint("Supplier suggestions error: $e");
    }
    return [];
  }

  Future<List<dynamic>> _getGRNSuggestions(String query) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cid = prefs.getString('cid') ?? '44555666';
      final response = await http.post(
        Uri.parse("https://erpsmart.in/total/api/m_api/"),
        body: {
          "cid": cid,
          "type": "4046",
          "device_id": "123",
          "ln": "145",
          "lt": "145",
          "search": query,
        },
      );
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['error'] == false) return data['data'] ?? [];
      }
    } catch (e) {
      debugPrint("GRN suggestions error: $e");
    }
    return [];
  }

  Future<void> _saveInvoice() async {
    setState(() => _isLoading = true);
    
    try {
      final prefs = await SharedPreferences.getInstance();
      final cid = prefs.getString('cid') ?? '44555666';
      final deviceData = await DeviceServices.getAndStoreDeviceInfo();
      
      final Map<String, String> body = {
        "cid": cid,
        "type": "4020",
        "invoice_no": _invoiceNoController.text,
        "date": _invoiceDateController.text,
        "cus_id": _cusIdController.text,
        "trans_type": _transTypeController.text,
        "trans_name": _transNameController.text,
        "b_name": _supplierNameController.text,
        "b_gst": _supplierGstinController.text,
        "b_add1": _addressController.text,
        "b_loc": _bLocController.text,
        "b_pin": _bPinController.text,
        "b_scode": _bScodeController.text,
        "taxable_total": _taxableTotalController.text,
        "cgst": _cgstController.text,
        "sgst": _sgstController.text,
        "igst": _igstController.text,
        "taxtotal": _totalGstController.text,
        "g_total": _grandTotalController.text,
        "ln": deviceData['ln'] ?? '1',
        "lt": deviceData['lt'] ?? '1',
        "device_id": deviceData['device_id'] ?? '11',
      };

      for (int i = 0; i < _items.length; i++) {
        body["pro_name[$i]"] = _items[i].productNameController.text;
        body["product_id[$i]"] = _items[i].productIdController.text;
        body["hsn[$i]"] = _items[i].hsnCodeController.text;
        body["qty[$i]"] = _items[i].qtyController.text;
        body["uom[$i]"] = _items[i].uomController.text;
        body["rate[$i]"] = _items[i].unitPriceController.text;
        body["taxable[$i]"] = _items[i].taxableValueController.text;
        body["tax[$i]"] = _items[i].taxPercentageController.text;
        body["total[$i]"] = _items[i].totalAmountController.text;
      }

      debugPrint("PURCHASE INVOICE REQUEST: $body");

      final response = await http.post(
        Uri.parse("https://erpsmart.in/total/api/m_api/"),
        body: body,
      );

      debugPrint("PURCHASE INVOICE RESPONSE: ${response.body}");

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['error'] == false) {
          if (mounted) {
            _showSuccessDialog(data['message'] ?? "Invoice Inserted Successfully", data['items'] ?? []);
          }
        } else {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(data['message'] ?? "Failed to save invoice"), backgroundColor: Colors.red),
            );
          }
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Server Error: ${response.statusCode}"), backgroundColor: Colors.red),
          );
        }
      }
    } catch (e) {
      debugPrint("Save Invoice Error: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error: $e"), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showSuccessDialog(String message, List<dynamic> items) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.check_circle, color: Colors.green),
            SizedBox(width: 10),
            Text("Success"),
          ],
        ),
        content: SizedBox(
          width: double.maxFinite,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(message, style: const TextStyle(fontWeight: FontWeight.bold)),
              const Divider(),
              const Text("Returned Item Details (Cleaned):", style: TextStyle(fontSize: 12, color: Colors.grey)),
              const SizedBox(height: 8),
              Flexible(
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: items.length,
                  itemBuilder: (context, idx) {
                    final item = items[idx];
                    // Clean the high precision decimals for display
                    double taxAmt = double.tryParse(item['tax_amount']?.toString() ?? "0") ?? 0;
                    double cgst = double.tryParse(item['cgst']?.toString() ?? "0") ?? 0;
                    double sgst = double.tryParse(item['sgst']?.toString() ?? "0") ?? 0;
                    
                    return Card(
                      color: Colors.grey[50],
                      margin: const EdgeInsets.only(bottom: 8),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("${item['pname']}", style: const TextStyle(fontWeight: FontWeight.bold)),
                            Text("Qty: ${item['qty']} ${item['uom']} | Total: ${item['total']}"),
                            Text("Tax: ${taxAmt.toStringAsFixed(2)} (CGST: ${cgst.toStringAsFixed(2)}, SGST: ${sgst.toStringAsFixed(2)})", 
                              style: const TextStyle(fontSize: 11, color: Colors.blueGrey)),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Close dialog
              Navigator.pop(context); // Back to previous screen
            },
            child: const Text("OK"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: Text(
          "Purchase Invoice",
          style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18.sp),
        ),
        backgroundColor: const Color(0xff26A69A),
        centerTitle: false,
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSectionHeader("Invoice Details"),
                    const SizedBox(height: 12),
                    _buildHeaderCard(width),
                    const SizedBox(height: 24),
                    _buildSectionHeader("Tax & Compliance"),
                    const SizedBox(height: 12),
                    _buildComplianceCard(width),
                    const SizedBox(height: 24),
                    _buildItemTable(width),
                    const SizedBox(height: 24),
                    _buildTotalsCard(width),
                    const SizedBox(height: 100), // Space for footer
                  ],
                ),
              ),
            ),
            _buildFooter(width),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: GoogleFonts.outfit(
        color: const Color(0xFF1E293B),
        fontWeight: FontWeight.bold,
        fontSize: 16.sp,
      ),
    );
  }

  Widget _buildHeaderCard(double width) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: _cardDecoration(),
      child: Column(
        children: [
          _buildSupplierDropdown(),
          const SizedBox(height: 12),
          _buildTextField("Supplier GSTIN", _supplierGstinController),
          const SizedBox(height: 12),
          _buildTextField("Address", _addressController, maxLines: 2),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildTypeAheadField(
                  "GRN NO", 
                  _grnNoController,
                  _getGRNSuggestions,
                  (suggestion) {
                    setState(() {
                      _grnNoController.text = suggestion['grn_no']?.toString() ?? "";
                    });
                    _fetchGRNDetails();
                  },
                  itemBuilder: (context, suggestion) => ListTile(
                    title: Text(suggestion['grn_no'] ?? "", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                    subtitle: Text("ID: ${suggestion['id']}", style: const TextStyle(fontSize: 11)),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(child: _buildTextField("DC / Inv No", _dcNoController)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildComplianceCard(double width) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: _cardDecoration(),
      child: Column(
        children: [
          _buildDropdown("Price Type", _selectedPriceType, ["Exclude Tax", "Include Tax"], (val) {
            setState(() => _selectedPriceType = val!);
            _calculateAll();
          }),
          const SizedBox(height: 12),
          _buildDropdown("Tax Type", _selectedTaxType, ["CGST/SGST", "IGST"], (val) {
            setState(() => _selectedTaxType = val!);
            _calculateAll();
          }),
        ],
      ),
    );
  }

  Widget _buildItemCard(int index) {
    final item = _items[index];
    final name = item.productNameController.text;
    final qty = item.qtyController.text;
    final total = item.totalAmountController.text;

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
                  decoration: BoxDecoration(color: const Color(0xff26A69A).withOpacity(0.1), shape: BoxShape.circle),
                  child: const Icon(Icons.shopping_bag_outlined, color: Color(0xff26A69A), size: 20),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(name.isEmpty ? "Unnamed Product" : name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                      const SizedBox(height: 4),
                      Text("QTY: $qty  |  TOTAL: ₹$total", style: const TextStyle(color: Colors.grey, fontSize: 12)),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          Row(
            children: [
              Expanded(
                child: TextButton(
                  onPressed: () => _editItem(index),
                  child: const Text("Edit", style: TextStyle(color: Color(0xff26A69A), fontWeight: FontWeight.bold, fontSize: 13)),
                ),
              ),
              Container(width: 1, height: 20, color: Colors.grey.shade200),
              Expanded(
                child: TextButton(
                  onPressed: () => _removeItem(index),
                  child: const Text("Remove", style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold, fontSize: 13)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildItemTable(double width) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader("Product Details"),
        const SizedBox(height: 12),
        if (_items.isEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade100),
            ),
            child: Column(
              children: [
                Icon(Icons.add_shopping_cart_outlined, size: 48, color: Colors.grey.shade300),
                const SizedBox(height: 16),
                Text("No products added yet", style: TextStyle(color: Colors.grey.shade400, fontWeight: FontWeight.w500)),
              ],
            ),
          )
        else
          ...List.generate(_items.length, (index) => _buildItemCard(index)),
        const SizedBox(height: 16),
        Center(
          child: InkWell(
            onTap: _addItem,
            borderRadius: BorderRadius.circular(30),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
              decoration: BoxDecoration(
                color: const Color(0xff26A69A).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(30),
                border: Border.all(color: const Color(0xff26A69A), width: 1.5),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.add_circle_outline, color: Color(0xff26A69A), size: 20),
                  SizedBox(width: 8),
                  Text("Add More Product", style: TextStyle(color: Color(0xff26A69A), fontWeight: FontWeight.bold, fontSize: 14)),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTotalsCard(double width) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xff26A69A).withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xff26A69A).withValues(alpha: 0.2)),
      ),
      child: Column(
        children: [
          _buildTotalRow("Grand Total", _grandTotalController, readOnly: false),
          const Divider(),
          _buildTotalRow("Taxable Total", _taxableTotalController, readOnly: false),
          const Divider(),
          _buildTotalRow("Total GST", _totalGstController, readOnly: false),
          const Divider(),
          _buildTotalRow("CGST", _cgstController, readOnly: false),
          const Divider(),
          _buildTotalRow("SGST", _sgstController, readOnly: false),
          const Divider(),
          _buildTotalRow("IGST", _igstController, readOnly: false),
        ],
      ),
    );
  }

  Widget _buildFooter(double width) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10, offset: const Offset(0, -4))],
      ),
      child: SizedBox(
        width: double.infinity,
        height: 50,
        child: ElevatedButton(
          onPressed: _isLoading ? null : _saveInvoice,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xff26A69A),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
          child: _isLoading
              ? const CircularProgressIndicator(color: Colors.white)
              : const Text("Save Invoice", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
        ),
      ),
    );
  }

  // Helper Widgets
  BoxDecoration _cardDecoration() {
    return BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: Colors.grey[100]!),
      boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 4))],
    );
  }

  Widget _buildTextField(
    String label, 
    TextEditingController controller, {
    int maxLines = 1, 
    TextInputType? keyboardType, 
    Widget? suffixIcon,
    VoidCallback? onTap,
    bool readOnly = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(color: Colors.grey[600], fontSize: 11, fontWeight: FontWeight.bold)),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          maxLines: maxLines,
          keyboardType: keyboardType,
          readOnly: readOnly,
          onTap: onTap,
          style: const TextStyle(fontSize: 13),
          decoration: InputDecoration(
            isDense: true,
            suffixIcon: suffixIcon,
            contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: Colors.grey[200]!)),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: Colors.grey[200]!)),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Color(0xff26A69A))),
            fillColor: const Color(0xffFDFDFD),
            filled: true,
          ),
        ),
      ],
    );
  }

  Widget _buildDropdown(String label, String value, List<String> items, ValueChanged<String?> onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(color: Colors.grey[600], fontSize: 13, fontWeight: FontWeight.w500)),
        const SizedBox(height: 6),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey[300]!),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              isExpanded: true,
              value: value,
              items: items.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
              onChanged: onChanged,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSmallTextField(String label, TextEditingController controller, {bool readOnly = false, TextInputType? keyboardType, ValueChanged<String>? onChanged}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(color: Colors.grey[500], fontSize: 11)),
        const SizedBox(height: 4),
        TextField(
          controller: controller,
          readOnly: readOnly,
          keyboardType: keyboardType,
          onChanged: onChanged,
          style: const TextStyle(fontSize: 14),
          decoration: InputDecoration(
            isDense: true,
            filled: readOnly,
            fillColor: readOnly ? Colors.grey[100] : Colors.white,
            contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: Colors.grey[200]!)),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: Colors.grey[200]!)),
          ),
        ),
      ],
    );
  }

  Widget _buildTotalRow(String label, TextEditingController controller, {bool readOnly = true}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label, 
              style: GoogleFonts.outfit(
                fontWeight: FontWeight.w600, 
                color: const Color(0xFF334155),
                fontSize: 14,
              )
            )
          ),
          Container(
            width: 140,
            height: 40,
            decoration: BoxDecoration(
              color: readOnly ? const Color(0xFFF1F5F9) : Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: readOnly ? Colors.transparent : const Color(0xFFCBD5E1)),
            ),
            child: TextField(
              controller: controller,
              readOnly: readOnly,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              textAlign: TextAlign.right,
              style: GoogleFonts.outfit(
                fontWeight: FontWeight.bold, 
                color: const Color(0xff26A69A),
                fontSize: 14,
              ),
              decoration: InputDecoration(
                prefixText: "₹ ",
                prefixStyle: TextStyle(color: Colors.grey[600], fontWeight: FontWeight.normal),
                border: InputBorder.none, 
                isDense: true,
                contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSupplierDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Supplier Name", style: TextStyle(color: Colors.grey[600], fontSize: 11, fontWeight: FontWeight.bold)),
        const SizedBox(height: 6),
        Container(
          height: 50,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: const Color(0xffFDFDFD),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey[200]!),
          ),
          child: _isLoadingSuppliers
              ? const Center(child: SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)))
              : DropdownButtonHideUnderline(
                  child: DropdownButtonFormField<String>(
                    isExpanded: true,
                    value: _cusIdController.text.isEmpty ? null : _cusIdController.text,
                    hint: Text("Select Supplier", style: TextStyle(color: Colors.grey[400], fontSize: 13)),
                    decoration: const InputDecoration(border: InputBorder.none, contentPadding: EdgeInsets.zero),
                    items: _suppliers.map((s) {
                      return DropdownMenuItem<String>(
                        value: s['id']?.toString(),
                        child: Text(s['Ledger_Name'] ?? "N/A", style: const TextStyle(fontSize: 13)),
                      );
                    }).toList(),
                    onChanged: (val) {
                      final selected = _suppliers.firstWhere((s) => s['id']?.toString() == val);
                      setState(() {
                        _cusIdController.text = val!;
                        _supplierNameController.text = selected['Ledger_Name']?.toString() ?? "";
                        _supplierGstinController.text = selected['gst']?.toString() ?? "";
                        _addressController.text = selected['address']?.toString() ?? "";
                        _bPinController.text = selected['pincode']?.toString() ?? "";
                        _bScodeController.text = selected['state']?.toString() ?? "";
                      });
                    },
                  ),
                ),
        ),
      ],
    );
  }

  Widget _buildTypeAheadField(
    String label, 
    TextEditingController controller,
    Future<List<dynamic>> Function(String) suggestionsCallback,
    void Function(dynamic) onSuggestionSelected, {
    required Widget Function(BuildContext, dynamic) itemBuilder,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(color: Colors.grey[600], fontSize: 11, fontWeight: FontWeight.bold)),
        const SizedBox(height: 6),
        TypeAheadField<dynamic>(
          builder: (context, controller, focusNode) {
            return TextField(
              controller: controller,
              focusNode: focusNode,
              style: const TextStyle(fontSize: 13),
              decoration: InputDecoration(
                isDense: true,
                hintText: "Type to search...",
                contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: Colors.grey[200]!)),
                enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: Colors.grey[200]!)),
                focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Color(0xff26A69A))),
                fillColor: const Color(0xffFDFDFD),
                filled: true,
              ),
            );
          },
          controller: controller,
          suggestionsCallback: (search) => suggestionsCallback(search),
          itemBuilder: itemBuilder,
          onSelected: onSuggestionSelected,
          loadingBuilder: (context) => const Padding(
            padding: EdgeInsets.all(8.0),
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
          emptyBuilder: (context) => const Padding(
            padding: EdgeInsets.all(8.0),
            child: Text('No results found'),
          ),
          decorationBuilder: (context, child) => Material(
            elevation: 8,
            borderRadius: BorderRadius.circular(8),
            child: child,
          ),
        ),
      ],
    );
  }
}

class _GRNSelectionSheet extends StatefulWidget {
  const _GRNSelectionSheet();

  @override
  State<_GRNSelectionSheet> createState() => _GRNSelectionSheetState();
}

class _GRNSelectionSheetState extends State<_GRNSelectionSheet> {
  final TextEditingController _searchController = TextEditingController();
  List<dynamic> _allGRNs = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _fetchGRNs("");
  }

  Future<void> _fetchGRNs(String query) async {
    setState(() => _isLoading = true);
    try {
      final prefs = await SharedPreferences.getInstance();
      final cid = prefs.getString('cid') ?? '44555666';
      
      final response = await http.post(
        Uri.parse("https://erpsmart.in/total/api/m_api/"),
        body: {
          "cid": cid,
          "type": "4046",
          "device_id": "123",
          "ln": "145",
          "lt": "145",
          "search": query,
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['error'] == false) {
          setState(() {
            _allGRNs = data['data'] ?? [];
          });
        }
      }
    } catch (e) {
      debugPrint("Fetch GRN List Error: $e");
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.75,
      decoration: const BoxDecoration(
        color: Color(0xFFF8FAFC),
        borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
      ),
      child: Column(
        children: [
          const SizedBox(height: 12),
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2)),
          ),
          const SizedBox(height: 20),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.w),
            child: Row(
              children: [
                Text(
                  "Select GRN Number",
                  style: GoogleFonts.outfit(fontSize: 20.sp, fontWeight: FontWeight.bold, color: const Color(0xFF1E293B)),
                ),
                const Spacer(),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: Icon(Icons.close, color: Colors.grey[400]),
                ),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.all(20.w),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10, offset: const Offset(0, 4)),
                ],
              ),
              child: TextField(
                controller: _searchController,
                style: GoogleFonts.outfit(fontSize: 14.sp),
                decoration: InputDecoration(
                  hintText: "Search by GRN Number...",
                  hintStyle: GoogleFonts.outfit(color: Colors.grey[400]),
                  prefixIcon: const Icon(Icons.search, color: Color(0xff26A69A)),
                  suffixIcon: _searchController.text.isNotEmpty 
                    ? IconButton(onPressed: () { _searchController.clear(); _fetchGRNs(""); }, icon: const Icon(Icons.clear)) 
                    : null,
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
                ),
                onChanged: _fetchGRNs,
              ),
            ),
          ),
          Expanded(
            child: _isLoading && _allGRNs.isEmpty
              ? const Center(child: CircularProgressIndicator(color: Color(0xff26A69A)))
              : _allGRNs.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.receipt_outlined, size: 60.sp, color: Colors.grey[200]),
                        SizedBox(height: 16.h),
                        Text(
                          "No GRNs Found",
                          style: GoogleFonts.outfit(color: Colors.grey[400], fontWeight: FontWeight.w600, fontSize: 16.sp),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: EdgeInsets.symmetric(horizontal: 20.w),
                    itemCount: _allGRNs.length,
                    itemBuilder: (context, index) {
                      final grn = _allGRNs[index];
                      return Container(
                        margin: EdgeInsets.only(bottom: 12.h),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: const Color(0xFFF1F5F9)),
                        ),
                        child: ListTile(
                          contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                          onTap: () => Navigator.pop(context, grn['grn_no']),
                          leading: Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: const Color(0xff26A69A).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(Icons.description_outlined, color: Color(0xff26A69A), size: 22),
                          ),
                          title: Text(
                            grn['grn_no'] ?? "N/A",
                            style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 15.sp, color: const Color(0xFF334155)),
                          ),
                          subtitle: Text(
                            "ID: ${grn['id']}",
                            style: GoogleFonts.outfit(fontSize: 12.sp, color: Colors.grey[500]),
                          ),
                          trailing: Icon(Icons.chevron_right, color: Colors.grey[300]),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

class _SupplierSelectionSheet extends StatefulWidget {
  const _SupplierSelectionSheet();

  @override
  State<_SupplierSelectionSheet> createState() => _SupplierSelectionSheetState();
}

class _SupplierSelectionSheetState extends State<_SupplierSelectionSheet> {
  final TextEditingController _searchController = TextEditingController();
  List<dynamic> _allSuppliers = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _fetchSuppliers("");
  }

  Future<void> _fetchSuppliers(String query) async {
    setState(() => _isLoading = true);
    try {
      final prefs = await SharedPreferences.getInstance();
      final cid = prefs.getString('cid') ?? '44555666';
      
      final response = await http.post(
        Uri.parse("https://erpsmart.in/total/api/m_api/"),
        body: {
          "cid": cid,
          "type": "4010",
          "device_id": "123",
          "ln": "145",
          "lt": "145",
          "search": query,
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['error'] == false) {
          setState(() {
            _allSuppliers = data['data'] ?? [];
          });
        }
      }
    } catch (e) {
      debugPrint("Fetch Supplier List Error: $e");
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.75,
      decoration: const BoxDecoration(
        color: Color(0xFFF8FAFC),
        borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
      ),
      child: Column(
        children: [
          const SizedBox(height: 12),
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2)),
          ),
          const SizedBox(height: 20),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.w),
            child: Row(
              children: [
                Text(
                  "Select Supplier",
                  style: GoogleFonts.outfit(fontSize: 20.sp, fontWeight: FontWeight.bold, color: const Color(0xFF1E293B)),
                ),
                const Spacer(),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: Icon(Icons.close, color: Colors.grey[400]),
                ),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.all(20.w),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10, offset: const Offset(0, 4)),
                ],
              ),
              child: TextField(
                controller: _searchController,
                style: GoogleFonts.outfit(fontSize: 14.sp),
                decoration: InputDecoration(
                  hintText: "Search by Name or Mobile...",
                  hintStyle: GoogleFonts.outfit(color: Colors.grey[400]),
                  prefixIcon: const Icon(Icons.search, color: Color(0xff26A69A)),
                  suffixIcon: _searchController.text.isNotEmpty 
                    ? IconButton(onPressed: () { _searchController.clear(); _fetchSuppliers(""); }, icon: const Icon(Icons.clear)) 
                    : null,
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
                ),
                onChanged: _fetchSuppliers,
              ),
            ),
          ),
          Expanded(
            child: _isLoading && _allSuppliers.isEmpty
              ? const Center(child: CircularProgressIndicator(color: Color(0xff26A69A)))
              : _allSuppliers.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.people_outline_rounded, size: 60.sp, color: Colors.grey[200]),
                        SizedBox(height: 16.h),
                        Text(
                          "No Suppliers Found",
                          style: GoogleFonts.outfit(color: Colors.grey[400], fontWeight: FontWeight.w600, fontSize: 16.sp),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: EdgeInsets.symmetric(horizontal: 20.w),
                    itemCount: _allSuppliers.length,
                    itemBuilder: (context, index) {
                      final supplier = _allSuppliers[index];
                      return Container(
                        margin: EdgeInsets.only(bottom: 12.h),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: const Color(0xFFF1F5F9)),
                        ),
                        child: ListTile(
                          contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                          onTap: () => Navigator.pop(context, supplier),
                          leading: Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: const Color(0xff26A69A).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(Icons.storefront_outlined, color: Color(0xff26A69A), size: 22),
                          ),
                          title: Text(
                            supplier['Ledger_Name'] ?? "N/A",
                            style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 15.sp, color: const Color(0xFF334155)),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (supplier['gst'] != null && supplier['gst'] != "0")
                                Text("GST: ${supplier['gst']}", style: GoogleFonts.outfit(fontSize: 12.sp, color: const Color(0xff26A69A))),
                              if (supplier['address'] != null && supplier['address'].toString().isNotEmpty)
                                Text(
                                  supplier['address'],
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: GoogleFonts.outfit(fontSize: 12.sp, color: Colors.grey[500]),
                                ),
                            ],
                          ),
                          trailing: Icon(Icons.chevron_right, color: Colors.grey[300]),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
