import 'package:flutter/material.dart';

class InvoiceItem {
  final TextEditingController productNameController = TextEditingController();
  final TextEditingController hsnCodeController = TextEditingController();
  final TextEditingController qtyController = TextEditingController();
  final TextEditingController discountController = TextEditingController();
  final TextEditingController uomController = TextEditingController();
  final TextEditingController unitPriceController = TextEditingController();
  final TextEditingController taxableValueController = TextEditingController();
  final TextEditingController totalAmountController = TextEditingController();

  void dispose() {
    productNameController.dispose();
    hsnCodeController.dispose();
    qtyController.dispose();
    discountController.dispose();
    uomController.dispose();
    unitPriceController.dispose();
    taxableValueController.dispose();
    totalAmountController.dispose();
  }
}

class PurchaseInvoiceScreen extends StatefulWidget {
  const PurchaseInvoiceScreen({super.key});

  @override
  State<PurchaseInvoiceScreen> createState() => _PurchaseInvoiceScreenState();
}

class _PurchaseInvoiceScreenState extends State<PurchaseInvoiceScreen> {
  final List<InvoiceItem> _items = [InvoiceItem()];

  // Header Controllers
  final TextEditingController _invoiceNoController = TextEditingController(text: "SMM/PO-/25-26/0005");
  final TextEditingController _invoiceDateController = TextEditingController(text: "10-04-2026");
  final TextEditingController _customerNameController = TextEditingController();
  final TextEditingController _customerGstinController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
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

  bool _isLoading = false;

  @override
  void dispose() {
    for (var item in _items) {
      item.dispose();
    }
    _invoiceNoController.dispose();
    _invoiceDateController.dispose();
    _customerNameController.dispose();
    _customerGstinController.dispose();
    _addressController.dispose();
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

  void _addItem() {
    setState(() {
      _items.add(InvoiceItem());
    });
  }

  void _removeItem(int index) {
    if (_items.length > 1) {
      setState(() {
        _items[index].dispose();
        _items.removeAt(index);
      });
    }
  }

  Future<void> _saveInvoice() async {
    setState(() => _isLoading = true);
    // Mimic saving logic
    await Future.delayed(const Duration(seconds: 2));
    setState(() => _isLoading = false);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Purchase Invoice saved successfully!")),
      );
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          "Purchase Invoice",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xff26A69A),
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.list_alt_rounded),
            onPressed: () {},
          ),
          const SizedBox(width: 8),
        ],
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
      style: const TextStyle(
        color: Color(0xff512DA8),
        fontWeight: FontWeight.bold,
        fontSize: 18,
      ),
    );
  }

  Widget _buildHeaderCard(double width) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: _cardDecoration(),
      child: Column(
        children: [
          _buildTextField("Invoice No", _invoiceNoController),
          const SizedBox(height: 12),
          _buildTextField("Invoice Date", _invoiceDateController),
          const SizedBox(height: 12),
          _buildTextField("Customer Name", _customerNameController),
          const SizedBox(height: 12),
          _buildTextField("Customer GSTIN", _customerGstinController),
          const SizedBox(height: 12),
          _buildTextField("Address", _addressController, maxLines: 3),
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
          }),
          const SizedBox(height: 12),
          _buildDropdown("Tax Type", _selectedTaxType, ["CGST/SGST", "IGST"], (val) {
            setState(() => _selectedTaxType = val!);
          }),
          const SizedBox(height: 12),
          _buildTextField("GRN NO", _grnNoController),
          const SizedBox(height: 12),
          _buildTextField("DC / Invoice No", _dcNoController),
          const SizedBox(height: 12),
          _buildDropdown("TCS", _selectedTcs, ["NO TCS", "TCS @ 0.1%", "TCS @ 1%"], (val) {
            setState(() => _selectedTcs = val!);
          }),
          const SizedBox(height: 12),
          _buildDropdown("TDS", _selectedTds, ["NO TDS", "TDS @ 1%", "TDS @ 2%"], (val) {
            setState(() => _selectedTds = val!);
          }),
        ],
      ),
    );
  }

  Widget _buildItemTable(double width) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildSectionHeader("Product Details"),
            ElevatedButton.icon(
              onPressed: _addItem,
              icon: const Icon(Icons.add, size: 18, color: Colors.white),
              label: const Text("Add", style: TextStyle(color: Colors.white)),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ..._items.asMap().entries.map((entry) {
          int idx = entry.key;
          InvoiceItem item = entry.value;
          return Container(
            margin: const EdgeInsets.only(bottom: 16),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey[200]!),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    CircleAvatar(
                      radius: 12,
                      backgroundColor: const Color(0xff26A69A),
                      child: Text("${idx + 1}", style: const TextStyle(color: Colors.white, fontSize: 12)),
                    ),
                    if (_items.length > 1)
                      IconButton(
                        icon: const Icon(Icons.delete_outline, color: Colors.red),
                        onPressed: () => _removeItem(idx),
                        constraints: const BoxConstraints(),
                        padding: EdgeInsets.zero,
                      ),
                  ],
                ),
                const SizedBox(height: 12),
                _buildSmallTextField("Product Name", item.productNameController),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(child: _buildSmallTextField("HSN Code", item.hsnCodeController)),
                    const SizedBox(width: 8),
                    Expanded(child: _buildSmallTextField("Quantity", item.qtyController, keyboardType: TextInputType.number)),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(child: _buildSmallTextField("Discount", item.discountController, keyboardType: TextInputType.number)),
                    const SizedBox(width: 8),
                    Expanded(child: _buildSmallTextField("UOM", item.uomController)),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(child: _buildSmallTextField("Unit Price", item.unitPriceController, keyboardType: TextInputType.number)),
                    const SizedBox(width: 8),
                    Expanded(child: _buildSmallTextField("Taxable Value", item.taxableValueController, readOnly: true)),
                  ],
                ),
                const SizedBox(height: 8),
                _buildSmallTextField("Total Amount", item.totalAmountController, readOnly: true),
              ],
            ),
          );
        }),
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
          _buildTotalRow("Grand Total", _grandTotalController),
          const Divider(),
          _buildTotalRow("Taxable Total", _taxableTotalController),
          const Divider(),
          _buildTotalRow("Total GST", _totalGstController),
          const Divider(),
          Row(
            children: [
              Expanded(child: _buildTotalRow("CGST", _cgstController)),
              const SizedBox(width: 8),
              Expanded(child: _buildTotalRow("SGST", _sgstController)),
            ],
          ),
          const Divider(),
          Row(
            children: [
              Expanded(child: _buildTotalRow("IGST", _igstController)),
              const SizedBox(width: 8),
              Expanded(child: _buildTotalRow("TCS", _tcsTotalController)),
            ],
          ),
          const Divider(),
          _buildTotalRow("Round Off", _roundOffController),
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

  Widget _buildTextField(String label, TextEditingController controller, {int maxLines = 1}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(color: Colors.grey[600], fontSize: 13, fontWeight: FontWeight.w500)),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          maxLines: maxLines,
          decoration: InputDecoration(
            isDense: true,
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: Colors.grey[300]!)),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: Colors.grey[300]!)),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Color(0xff26A69A))),
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

  Widget _buildSmallTextField(String label, TextEditingController controller, {bool readOnly = false, TextInputType? keyboardType}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(color: Colors.grey[500], fontSize: 11)),
        const SizedBox(height: 4),
        TextField(
          controller: controller,
          readOnly: readOnly,
          keyboardType: keyboardType,
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

  Widget _buildTotalRow(String label, TextEditingController controller) {
    return Row(
      children: [
        Expanded(child: Text(label, style: const TextStyle(fontWeight: FontWeight.w600, color: Colors.black87))),
        SizedBox(
          width: 100,
          child: TextField(
            controller: controller,
            readOnly: true,
            textAlign: TextAlign.right,
            style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xff26A69A)),
            decoration: const InputDecoration(border: InputBorder.none, isDense: true),
          ),
        ),
      ],
    );
  }
}
