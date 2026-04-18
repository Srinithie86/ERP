import 'package:flutter/material.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:google_fonts/google_fonts.dart';

class ItemDetailsScreen extends StatefulWidget {
  final Map<String, dynamic>? initialData;
  final Future<List<Map<String, dynamic>>> Function(String query) searchItems;

  const ItemDetailsScreen({
    super.key,
    this.initialData,
    required this.searchItems,
  });

  @override
  State<ItemDetailsScreen> createState() => _ItemDetailsScreenState();
}

class _ItemDetailsScreenState extends State<ItemDetailsScreen> {
  final TextEditingController _itemNameController = TextEditingController();
  final TextEditingController _itemCodeController = TextEditingController();
  final TextEditingController _uomController = TextEditingController();
  final TextEditingController _stockQtyController = TextEditingController();
  final TextEditingController _orderQtyController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.initialData != null) {
      _itemNameController.text = widget.initialData!['item_name'] ?? '';
      _itemCodeController.text = widget.initialData!['item_code'] ?? '';
      _uomController.text = widget.initialData!['uom'] ?? '';
      _stockQtyController.text = widget.initialData!['stock_qty'] ?? '';
      _orderQtyController.text = widget.initialData!['order_qty'] ?? '';
      _descriptionController.text = widget.initialData!['description'] ?? '';
    }
  }

  @override
  void dispose() {
    _itemNameController.dispose();
    _itemCodeController.dispose();
    _uomController.dispose();
    _stockQtyController.dispose();
    _orderQtyController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const primaryTeal = Color(0xFF26A69A);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          "Item Details",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: primaryTeal,
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Item Details",
              style: GoogleFonts.outfit(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: const Color(0xff3F1299),
              ),
            ),
            const SizedBox(height: 20),

            _buildLabel("Item Name"),
            TypeAheadField<Map<String, dynamic>>(
              controller: _itemNameController,
              suggestionsCallback: widget.searchItems,
              builder: (context, controller, focusNode) {
                return _buildTextField("Enter Item Name", controller: controller, focusNode: focusNode);
              },
              itemBuilder: (context, suggestion) {
                return ListTile(
                  title: Text(suggestion['Item name'] ?? suggestion['item_name'] ?? 'Unknown'),
                  subtitle: Text(suggestion['Item Code'] ?? suggestion['item_code'] ?? 'N/A'),
                );
              },
              onSelected: (suggestion) {
                setState(() {
                  _itemNameController.text = suggestion['Item name'] ?? suggestion['item_name'] ?? '';
                  _itemCodeController.text = suggestion['Item Code'] ?? suggestion['item_code'] ?? '';
                  _uomController.text = suggestion['UOM'] ?? suggestion['uom'] ?? '';
                  _stockQtyController.text = suggestion['Current Stock QTY'] ?? suggestion['stock'] ?? '';
                });
              },
            ),

            const SizedBox(height: 16),
            _buildLabel("UOM"),
            _buildTextField("UOM", controller: _uomController, readOnly: true),

            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildLabel("Cur Stock QTY"),
                      _buildTextField("Stock QTY", controller: _stockQtyController, readOnly: true),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildLabel("Cur Order QTY"),
                      _buildTextField("Order QTY", controller: _orderQtyController),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),
            _buildLabel("Description"),
            _buildTextField("Description", controller: _descriptionController, maxLines: 3),

            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context, {
                    'item_name': _itemNameController.text,
                    'item_code': _itemCodeController.text,
                    'uom': _uomController.text,
                    'stock_qty': _stockQtyController.text,
                    'order_qty': _orderQtyController.text,
                    'description': _descriptionController.text,
                  });
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryTeal,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                child: Text(
                  widget.initialData == null ? "Add Item" : "Update Item",
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

  Widget _buildTextField(String hint, {TextEditingController? controller, FocusNode? focusNode, int maxLines = 1, bool readOnly = false}) {
    return TextField(
      controller: controller,
      focusNode: focusNode,
      maxLines: maxLines,
      readOnly: readOnly,
      style: TextStyle(color: readOnly ? Colors.grey : Colors.black),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 13),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.grey.shade400),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0xFF26A69A), width: 1.5),
        ),
      ),
    );
  }
}
