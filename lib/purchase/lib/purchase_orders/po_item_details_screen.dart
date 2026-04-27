import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';

class POItemDetailsScreen extends StatefulWidget {
  final Future<List<Map<String, dynamic>>> Function(String) searchItems;
  final Future<Map<String, dynamic>> Function(Map<String, dynamic>) calculateItem;
  final Map<String, dynamic>? initialData;

  const POItemDetailsScreen({
    super.key,
    required this.searchItems,
    required this.calculateItem,
    this.initialData,
  });

  @override
  State<POItemDetailsScreen> createState() => _POItemDetailsScreenState();
}

class _POItemDetailsScreenState extends State<POItemDetailsScreen> {
  final TextEditingController _itemNameController = TextEditingController();
  final TextEditingController _itemCodeController = TextEditingController();
  final TextEditingController _uomController = TextEditingController();
  final TextEditingController _qtyController = TextEditingController(text: "0");
  final TextEditingController _rateController = TextEditingController(text: "0");
  final TextEditingController _taxPercController = TextEditingController(text: "0");
  final TextEditingController _taxAmtController = TextEditingController(text: "0");
  final TextEditingController _discountPercController = TextEditingController(text: "0");
  final TextEditingController _discountAmtController = TextEditingController(text: "0");
  final TextEditingController _totalController = TextEditingController(text: "0");

  bool _isCalculating = false;

  @override
  void initState() {
    super.initState();
    if (widget.initialData != null) {
      _itemNameController.text = widget.initialData!['name']?.text ?? '';
      _itemCodeController.text = widget.initialData!['code']?.text ?? '';
      _uomController.text = widget.initialData!['uom']?.text ?? '';
      _qtyController.text = widget.initialData!['qty']?.text ?? '1';
      _rateController.text = widget.initialData!['rate']?.text ?? '0';
      _taxPercController.text = widget.initialData!['taxPerc']?.text ?? '0';
      _taxAmtController.text = widget.initialData!['taxAmt']?.text ?? '0';
      _discountPercController.text = widget.initialData!['discountPerc']?.text ?? '0';
      _discountAmtController.text = widget.initialData!['discountAmt']?.text ?? '0';
      _totalController.text = widget.initialData!['total']?.text ?? '0';
    }
  }

  Future<void> _performCalculation() async {
    setState(() => _isCalculating = true);
    try {
      final input = {
        'quantity': _qtyController.text,
        'unit_rate': _rateController.text,
        'tax': _taxPercController.text,
        'discount': _discountPercController.text,
      };
      
      final result = await widget.calculateItem(input);
      
      if (mounted) {
        setState(() {
          _taxAmtController.text = result['tax_amt']?.toString() ?? '0';
          _discountAmtController.text = result['discount_amount']?.toString() ?? '0';
          _totalController.text = result['tot_amt']?.toString() ?? '0';
        });
      }
    } catch (e) {
      debugPrint("Calculation error: $e");
    } finally {
      if (mounted) setState(() => _isCalculating = false);
    }
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
          widget.initialData == null ? "Add Item to PO" : "Edit Item",
          style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildLabel("Item Description"),
            TypeAheadField<Map<String, dynamic>>(
              controller: _itemNameController,
              suggestionsCallback: widget.searchItems,
              builder: (context, controller, focusNode) {
                return _buildTextField("Search & Select Item", controller: controller, focusNode: focusNode);
              },
              itemBuilder: (context, suggestion) {
                return ListTile(
                  title: Text(suggestion['Item name'] ?? 'Unknown'),
                  subtitle: Text(suggestion['Item Code'] ?? 'N/A'),
                );
              },
              onSelected: (suggestion) {
                setState(() {
                  _itemNameController.text = suggestion['Item name'] ?? '';
                  _itemCodeController.text = suggestion['Item Code'] ?? '';
                  _uomController.text = suggestion['UOM'] ?? '';
                  // Autofilled rate, tax and discount from the item, but they are fully editable
                  _rateController.text = (suggestion['rate'] ?? suggestion['Rate'] ?? suggestion['unit_rate'] ?? suggestion['price'] ?? '0').toString(); 
                  _taxPercController.text = (suggestion['Tax'] ?? suggestion['tax'] ?? '0').toString();
                  _discountPercController.text = (suggestion['Discount'] ?? suggestion['discount'] ?? '0').toString();
                });
                _performCalculation();
              },
            ),

            const SizedBox(height: 16),
            _buildLabel("Item Code"),
            _buildTextField("Item Code", controller: _itemCodeController, readOnly: true),

            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildLabel("UOM"),
                      _buildTextField("UOM", controller: _uomController, readOnly: true),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildLabel("Quantity"),
                      _buildTextField("0", controller: _qtyController, keyboardType: TextInputType.number, onChanged: (_) => _performCalculation()),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildLabel("Unit Rate (₹)"),
                      _buildTextField("0.00", controller: _rateController, keyboardType: TextInputType.number, readOnly: false, onChanged: (_) => _performCalculation()),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                       _buildLabel("Tax (%)"),
                      _buildTextField("0", controller: _taxPercController, keyboardType: TextInputType.number, readOnly: false, onChanged: (_) => _performCalculation()),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                       _buildLabel("Discount (%)"),
                      _buildTextField("0", controller: _discountPercController, keyboardType: TextInputType.number, readOnly: false, onChanged: (_) => _performCalculation()),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildLabel("Discount Amt"),
                      _buildTextField("0.00", controller: _discountAmtController, readOnly: true),
                    ],
                  ),
                ),
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
                  Text("Total Amount", style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 16)),
                  if (_isCalculating)
                    const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
                  else
                    Text("₹${_totalController.text}", style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 18, color: const Color(0xff00695C))),
                ],
              ),
            ),

            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _isCalculating ? null : () async {
                  // Ensure calculation is completely finished before adding to the list
                  await _performCalculation();
                  if (!mounted) return;
                  
                  Navigator.pop(context, {
                    'name': _itemNameController.text,
                    'code': _itemCodeController.text,
                    'uom': _uomController.text,
                    'qty': _qtyController.text,
                    'rate': _rateController.text,
                    'taxPerc': _taxPercController.text,
                    'taxAmt': _taxAmtController.text,
                    'discountPerc': _discountPercController.text,
                    'discountAmt': _discountAmtController.text,
                    'total': _totalController.text,
                  });
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryTeal,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                child: _isCalculating
                    ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                    : Text(
                        widget.initialData == null ? "Add to List" : "Update Item",
                        style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(
        text,
        style: GoogleFonts.outfit(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: Colors.black87,
        ),
      ),
    );
  }

  Widget _buildTextField(
    String hint, {
    TextEditingController? controller,
    bool readOnly = false,
    TextInputType keyboardType = TextInputType.text,
    ValueChanged<String>? onChanged,
    FocusNode? focusNode,
  }) {
    return TextField(
      controller: controller,
      readOnly: readOnly,
      keyboardType: keyboardType,
      onChanged: onChanged,
      focusNode: focusNode,
      style: GoogleFonts.outfit(fontSize: 15),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: GoogleFonts.outfit(color: Colors.grey, fontSize: 14),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        filled: true,
        fillColor: readOnly ? Colors.grey.shade50 : Colors.white,
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
