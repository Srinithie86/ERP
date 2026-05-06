import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:purchase_erp/core/api_config.dart';

class InvoiceItemDetailsScreen extends StatefulWidget {
  final Map<String, dynamic>? initialData;
  const InvoiceItemDetailsScreen({super.key, this.initialData});

  @override
  State<InvoiceItemDetailsScreen> createState() => _InvoiceItemDetailsScreenState();
}

class _InvoiceItemDetailsScreenState extends State<InvoiceItemDetailsScreen> {
  final TextEditingController _productNameController = TextEditingController();
  final TextEditingController _productIdController = TextEditingController();
  final TextEditingController _hsnCodeController = TextEditingController();
  final TextEditingController _qtyController = TextEditingController(text: "1");
  final TextEditingController _discountController = TextEditingController(text: "0");
  final TextEditingController _uomController = TextEditingController(text: "NOS");
  final TextEditingController _unitPriceController = TextEditingController(text: "0");
  final TextEditingController _taxPercentageController = TextEditingController(text: "0");
  
  final TextEditingController _taxableValueController = TextEditingController(text: "0.00");
  final TextEditingController _totalAmountController = TextEditingController(text: "0.00");

  bool _isLoading = false;

  Future<List<dynamic>> _getProductNameSuggestions(String query) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cid = prefs.getString('cid') ?? '44555666';
      final response = await http.post(
        Uri.parse(await ApiConfig.getBaseUrl()),
        body: {
          "cid": cid,
          "type": "4003",
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
      debugPrint("Product suggestions error: $e");
    }
    return [];
  }

  @override
  void initState() {
    super.initState();
    if (widget.initialData != null) {
      _productNameController.text = widget.initialData!['productName'] ?? '';
      _productIdController.text = widget.initialData!['productId'] ?? '';
      _hsnCodeController.text = widget.initialData!['hsnCode'] ?? '';
      _qtyController.text = widget.initialData!['qty'] ?? '1';
      _discountController.text = widget.initialData!['discount'] ?? '0';
      _uomController.text = widget.initialData!['uom'] ?? 'NOS';
      _unitPriceController.text = widget.initialData!['unitPrice'] ?? '0';
      _taxPercentageController.text = widget.initialData!['taxPercentage'] ?? '0';
      _taxableValueController.text = widget.initialData!['taxableValue'] ?? '0.00';
      _totalAmountController.text = widget.initialData!['totalAmount'] ?? '0.00';
    }
  }

  void _calculateLocal() {
    double qty = double.tryParse(_qtyController.text) ?? 0;
    double rate = double.tryParse(_unitPriceController.text) ?? 0;
    double disc = double.tryParse(_discountController.text) ?? 0;
    double taxPer = double.tryParse(_taxPercentageController.text) ?? 0;

    double taxable = (qty * rate) - disc;
    double taxAmount = taxable * (taxPer / 100);
    double total = taxable + taxAmount;

    setState(() {
      _taxableValueController.text = taxable.toStringAsFixed(2);
      _totalAmountController.text = total.toStringAsFixed(2);
    });
  }

  @override
  Widget build(BuildContext context) {
    const primaryTeal = Color(0xff26A69A);
    const lightTeal = Color(0xffE0F2F1);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: primaryTeal,
        title: Text(
          widget.initialData == null ? "Add Invoice Item" : "Edit Invoice Item",
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildLabeledField(
              "Product Name", 
              TypeAheadField<dynamic>(
                builder: (context, controller, focusNode) {
                  return TextField(
                    controller: controller,
                    focusNode: focusNode,
                    style: const TextStyle(fontSize: 14),
                    decoration: InputDecoration(
                      hintText: "Enter Product Name",
                      hintStyle: const TextStyle(color: Colors.grey, fontSize: 13),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      filled: true,
                      fillColor: Colors.white,
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: Colors.grey.shade300),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(color: Color(0xff26A69A), width: 1.5),
                      ),
                    ),
                  );
                },
                controller: _productNameController,
                suggestionsCallback: (search) => _getProductNameSuggestions(search),
                debounceDuration: const Duration(milliseconds: 300),
                loadingBuilder: (context) => const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xff26A69A)),
                ),
                emptyBuilder: (context) => const Padding(
                  padding: EdgeInsets.all(12),
                  child: Text('No products found', style: TextStyle(color: Colors.grey)),
                ),
                itemBuilder: (context, suggestion) => ListTile(
                  title: Text(suggestion['Item name'] ?? suggestion['Item Code'] ?? "", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                  subtitle: Text("Code: ${suggestion['Item Code']} | Stock: ${suggestion['Current Stock QTY']}", style: const TextStyle(fontSize: 11)),
                ),
                onSelected: (suggestion) {
                  setState(() {
                    _productNameController.text = suggestion['Item name'] ?? "";
                    _productIdController.text = suggestion['Item Code'] ?? "";
                    if (suggestion['UOM'] != null && suggestion['UOM'].toString().isNotEmpty) {
                      _uomController.text = suggestion['UOM'];
                    }
                    if (suggestion['Tax Rate'] != null) {
                      _taxPercentageController.text = suggestion['Tax Rate'].toString();
                    }
                  });
                  _calculateLocal();
                },
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildLabeledField(
                    "Product ID", 
                    TypeAheadField<dynamic>(
                      builder: (context, controller, focusNode) {
                        return TextField(
                          controller: controller,
                          focusNode: focusNode,
                          style: const TextStyle(fontSize: 14),
                          decoration: InputDecoration(
                            isDense: true,
                            hintText: "ID",
                            hintStyle: const TextStyle(color: Colors.grey, fontSize: 13),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                            filled: true,
                            fillColor: Colors.white,
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide(color: Colors.grey.shade300),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: const BorderSide(color: Color(0xff26A69A), width: 1.5),
                            ),
                          ),
                        );
                      },
                      controller: _productIdController,
                      suggestionsCallback: (search) => _getProductNameSuggestions(search),
                      debounceDuration: const Duration(milliseconds: 300),
                      loadingBuilder: (context) => const Padding(
                        padding: EdgeInsets.all(8.0),
                        child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xff26A69A)),
                      ),
                      emptyBuilder: (context) => const Padding(
                        padding: EdgeInsets.all(12),
                        child: Text('Not found', style: TextStyle(color: Colors.grey, fontSize: 12)),
                      ),
                      itemBuilder: (context, suggestion) => ListTile(
                        dense: true,
                        title: Text(suggestion['Item Code'] ?? "", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                        subtitle: Text(suggestion['Item name'] ?? "", style: const TextStyle(fontSize: 11)),
                      ),
                      onSelected: (suggestion) {
                        setState(() {
                          _productNameController.text = suggestion['Item name'] ?? "";
                          _productIdController.text = suggestion['Item Code'] ?? "";
                          if (suggestion['UOM'] != null && suggestion['UOM'].toString().isNotEmpty) {
                            _uomController.text = suggestion['UOM'];
                          }
                          if (suggestion['Tax Rate'] != null) {
                            _taxPercentageController.text = suggestion['Tax Rate'].toString();
                          }
                        });
                        _calculateLocal();
                      },
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(child: _buildLabeledField("HSN Code", _buildTextField("HSN", controller: _hsnCodeController))),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(child: _buildLabeledField("Quantity", _buildTextField("0", controller: _qtyController, keyboardType: TextInputType.number, onChanged: (_) => _calculateLocal()))),
                const SizedBox(width: 16),
                Expanded(child: _buildLabeledField("UOM", _buildTextField("NOS", controller: _uomController))),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(child: _buildLabeledField("Unit Rate (₹)", _buildTextField("0.00", controller: _unitPriceController, keyboardType: TextInputType.number, onChanged: (_) => _calculateLocal()))),
                const SizedBox(width: 16),
                Expanded(child: _buildLabeledField("Discount (₹)", _buildTextField("0.00", controller: _discountController, keyboardType: TextInputType.number, onChanged: (_) => _calculateLocal()))),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(child: _buildLabeledField("Tax (%)", _buildTextField("0", controller: _taxPercentageController, keyboardType: TextInputType.number, onChanged: (_) => _calculateLocal()))),
                const SizedBox(width: 16),
                Expanded(child: _buildLabeledField("Taxable Value", _buildTextField("0.00", controller: _taxableValueController, readOnly: true))),
              ],
            ),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: lightTeal,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text("Total Amount", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  Text("₹${_totalAmountController.text}", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Color(0xff00695C))),
                ],
              ),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context, {
                    'productName': _productNameController.text,
                    'productId': _productIdController.text,
                    'hsnCode': _hsnCodeController.text,
                    'qty': _qtyController.text,
                    'discount': _discountController.text,
                    'uom': _uomController.text,
                    'unitPrice': _unitPriceController.text,
                    'taxPercentage': _taxPercentageController.text,
                    'taxableValue': _taxableValueController.text,
                    'totalAmount': _totalAmountController.text,
                  });
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryTeal,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                child: Text(
                  widget.initialData == null ? "Add to Invoice" : "Update Item",
                  style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLabeledField(String label, Widget field) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 8.0),
          child: Text(
            label,
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.black87),
          ),
        ),
        field,
      ],
    );
  }

  Widget _buildTextField(
    String hint, {
    TextEditingController? controller,
    bool readOnly = false,
    TextInputType keyboardType = TextInputType.text,
    ValueChanged<String>? onChanged,
  }) {
    return TextField(
      controller: controller,
      readOnly: readOnly,
      keyboardType: keyboardType,
      onChanged: onChanged,
      style: const TextStyle(fontSize: 14),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Colors.grey, fontSize: 13),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        filled: true,
        fillColor: readOnly ? Colors.grey.shade100 : Colors.white,
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0xff26A69A), width: 1.5),
        ),
      ),
    );
  }
}