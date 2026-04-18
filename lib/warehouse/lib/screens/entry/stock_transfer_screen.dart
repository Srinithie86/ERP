import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/warehouse_provider.dart';
import '../../widgets/common_widgets.dart';
import '../view/stock_view_screen.dart';

class StockTransferScreen extends StatefulWidget {
  const StockTransferScreen({super.key});

  @override
  State<StockTransferScreen> createState() => _StockTransferScreenState();
}

class _StockTransferScreenState extends State<StockTransferScreen> {
  final _formKey = GlobalKey<FormState>();
  final _qtyController = TextEditingController();
  
  String? _selectedItem;
  String? _fromLocation;
  String? _toLocation;

  @override
  void dispose() {
    _qtyController.dispose();
    super.dispose();
  }

  void _confirmTransfer() {
    if (_formKey.currentState!.validate()) {
      if (_fromLocation == _toLocation) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('From and To locations cannot be identical.')));
        return;
      }
      
      final provider = context.read<WarehouseProvider>();
      
      provider.confirmTransfer(
        itemName: _selectedItem!,
        fromLocation: _fromLocation!,
        toLocation: _toLocation!,
        quantity: double.parse(_qtyController.text),
      );

      showSuccessDialog(
        context,
        title: 'Transfer Successful',
        message: 'Stock moved to $_toLocation.',
        continueLabel: 'Back to Stock View',
        onContinue: () {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const StockViewScreen()),
          );
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.read<WarehouseProvider>();
    final items = provider.stock.map((s) => s.itemName).toSet().toList();

    return Scaffold(
      appBar: const WmsAppBar(
        title: 'Stock Transfer',
        screenType: ScreenType.entry,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              SectionCard(
                title: 'Transfer Details',
                icon: Icons.swap_horiz_outlined,
                child: Column(
                  children: [
                    WDropdown(
                      label: 'Select Item',
                      value: _selectedItem,
                      items: items,
                      hint: 'Select Item to Transfer',
                      onChanged: (v) => setState(() {
                        _selectedItem = v;
                        final stock = provider.stock.firstWhere((s) => s.itemName == v);
                        _fromLocation = stock.location;
                      }),
                      validator: (v) => v == null ? 'Required' : null,
                    ),
                    const SizedBox(height: 16),
                    WField(
                      label: 'From Location',
                      controller: TextEditingController(text: _fromLocation ?? ''),
                      readOnly: true,
                    ),
                    const SizedBox(height: 16),
                    WDropdown(
                      label: 'To Location (Warehouse)',
                      value: _toLocation,
                      items: provider.warehouses,
                      hint: 'Select Destination Warehouse',
                      onChanged: (v) => setState(() => _toLocation = v),
                      validator: (v) => v == null ? 'Required' : null,
                    ),
                    const SizedBox(height: 16),
                    WField(
                      label: 'Transfer Quantity',
                      controller: _qtyController,
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
        ),
      ),
    );
  }
}
