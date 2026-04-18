import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/warehouse_provider.dart';
import '../../widgets/common_widgets.dart';
import '../view/stock_view_screen.dart';

class StockAdjustmentScreen extends StatefulWidget {
  const StockAdjustmentScreen({super.key});

  @override
  State<StockAdjustmentScreen> createState() => _StockAdjustmentScreenState();
}

class _StockAdjustmentScreenState extends State<StockAdjustmentScreen> {
  // Adjustment state
  final _adjFormKey = GlobalKey<FormState>();
  final _adjQtyController = TextEditingController();
  final _adjReasonController = TextEditingController();
  String? _adjSelectedItem;

  // Transfer state
  final _transFormKey = GlobalKey<FormState>();
  final _transQtyController = TextEditingController();
  String? _transSelectedItem;
  String? _transFromLocation;
  String? _transToLocation;

  bool _isAdjustment = true;

  @override
  void dispose() {
    _adjQtyController.dispose();
    _adjReasonController.dispose();
    _transQtyController.dispose();
    super.dispose();
  }

  void _submitAdjustment() {
    if (_adjFormKey.currentState!.validate()) {
      final provider = context.read<WarehouseProvider>();
      
      provider.submitAdjustment(
        itemName: _adjSelectedItem!,
        adjustedQty: double.parse(_adjQtyController.text),
        reason: _adjReasonController.text,
      );

      _showSuccess('Stock adjustment applied.');
    }
  }

  void _confirmTransfer() {
    if (_transFormKey.currentState!.validate()) {
      if (_transFromLocation == _transToLocation) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('From and To locations cannot be identical.')));
        return;
      }
      
      final provider = context.read<WarehouseProvider>();
      
      provider.confirmTransfer(
        itemName: _transSelectedItem!,
        fromLocation: _transFromLocation!,
        toLocation: _transToLocation!,
        quantity: double.parse(_transQtyController.text),
      );

      _showSuccess('Stock moved to $_transToLocation.');
    }
  }

  void _showSuccess(String message) {
    showSuccessDialog(
      context,
      title: 'Success',
      message: message,
      continueLabel: 'Back to Stock View',
      onContinue: () {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const StockViewScreen()),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF26A69A),
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          'Stock Management',
          style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Custom Toggle Buttons
            Container(
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => _isAdjustment = true),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          color: _isAdjustment ? const Color(0xFF26A69A) : Colors.transparent,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          'Stock Adjustment',
                          style: TextStyle(
                            color: _isAdjustment ? Colors.white : Colors.black87,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => _isAdjustment = false),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          color: !_isAdjustment ? const Color(0xFF26A69A) : Colors.transparent,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          'Stock Transfer',
                          style: TextStyle(
                            color: !_isAdjustment ? Colors.white : Colors.black87,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            
            // Dynamic Form Body
            _isAdjustment ? _buildAdjustmentForm() : _buildTransferForm(),
          ],
        ),
      ),
    );
  }

  Widget _buildAdjustmentForm() {
    final provider = context.read<WarehouseProvider>();
    final items = provider.stock.map((s) => s.itemName).toSet().toList();
    
    return Form(
      key: _adjFormKey,
      child: Column(
        children: [
          SectionCard(
            title: 'Adjustment Details',
            icon: Icons.tune_outlined,
            child: Column(
              children: [
                WDropdown(
                  label: 'Select Item',
                  value: _adjSelectedItem,
                  items: items,
                  hint: 'Select Item',
                  onChanged: (v) => setState(() => _adjSelectedItem = v),
                  validator: (v) => v == null ? 'Required' : null,
                ),
                const SizedBox(height: 16),
                WField(
                  label: 'Adjusted Quantity (+ or -)',
                  controller: _adjQtyController,
                  keyboardType: const TextInputType.numberWithOptions(signed: true, decimal: true),
                  hint: 'e.g. -5 or 10',
                  validator: (v) => v!.isEmpty ? 'Required' : null,
                ),
                const SizedBox(height: 16),
                WField(
                  label: 'Reason for Adjustment',
                  controller: _adjReasonController,
                  maxLines: 2,
                  hint: 'e.g. Damage, audit variance...',
                  validator: (v) => v!.isEmpty ? 'Required' : null,
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),
          PrimaryButton(
            label: 'Save Adjustment',
            icon: Icons.save,
            onPressed: _submitAdjustment,
          ),
        ],
      ),
    );
  }

  Widget _buildTransferForm() {
    final provider = context.read<WarehouseProvider>();
    final items = provider.stock.map((s) => s.itemName).toSet().toList();
    
    return Form(
      key: _transFormKey,
      child: Column(
        children: [
          SectionCard(
            title: 'Transfer Details',
            icon: Icons.swap_horiz_outlined,
            child: Column(
              children: [
                WDropdown(
                  label: 'Select Item',
                  value: _transSelectedItem,
                  items: items,
                  hint: 'Select Item to Transfer',
                  onChanged: (v) => setState(() {
                    _transSelectedItem = v;
                    final stock = provider.stock.firstWhere((s) => s.itemName == v);
                    _transFromLocation = stock.location;
                  }),
                  validator: (v) => v == null ? 'Required' : null,
                ),
                const SizedBox(height: 16),
                WField(
                  label: 'From Location',
                  controller: TextEditingController(text: _transFromLocation ?? ''),
                  readOnly: true,
                ),
                const SizedBox(height: 16),
                WDropdown(
                  label: 'To Location (Warehouse)',
                  value: _transToLocation,
                  items: provider.warehouses,
                  hint: 'Select Destination Warehouse',
                  onChanged: (v) => setState(() => _transToLocation = v),
                  validator: (v) => v == null ? 'Required' : null,
                ),
                const SizedBox(height: 16),
                WField(
                  label: 'Transfer Quantity',
                  controller: _transQtyController,
                  keyboardType: TextInputType.number,
                  hint: '0.0',
                  validator: (v) => v!.isEmpty ? 'Required' : null,
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),
          PrimaryButton(
            label: 'Confirm Transfer',
            icon: Icons.check,
            onPressed: _confirmTransfer,
          ),
        ],
      ),
    );
  }
}
