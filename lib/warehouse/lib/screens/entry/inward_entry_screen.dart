import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/warehouse_provider.dart';
import '../../widgets/common_widgets.dart';
import 'putaway_screen.dart';

class InwardEntryScreen extends StatefulWidget {
  const InwardEntryScreen({super.key});

  @override
  State<InwardEntryScreen> createState() => _InwardEntryScreenState();
}

class _InwardEntryScreenState extends State<InwardEntryScreen> {
  final _formKey = GlobalKey<FormState>();
  final _itemController = TextEditingController();
  final _qtyController = TextEditingController();
  
  String? _selectedUnit;
  String? _selectedSupplier;

  @override
  void dispose() {
    _itemController.dispose();
    _qtyController.dispose();
    super.dispose();
  }

  void _saveEntry() {
    if (_formKey.currentState!.validate()) {
      final provider = context.read<WarehouseProvider>();
      
      final entry = provider.saveGrn(
        itemName: _itemController.text,
        quantity: double.parse(_qtyController.text),
        unit: _selectedUnit!,
        supplierRef: _selectedSupplier!,
      );

      showSuccessDialog(
        context,
        title: 'GRN Saved',
        message: 'Inward entry saved successfully!\nBarcode: ${entry.barcode}',
        continueLabel: 'Proceed to Putaway',
        onContinue: () {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => PutawayScreen(grnId: entry.id, itemName: entry.itemName, quantity: entry.quantity, unit: entry.unit,),
            ),
          );
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.read<WarehouseProvider>();
    return Scaffold(
      appBar: const WmsAppBar(
        title: 'Inward Entry (GRN)',
        screenType: ScreenType.entry,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              const WorkflowStep(label: 'Receive\nGoods', isActive: true, isDone: false, stepNumber: 1),
              const SizedBox(height: 24),
              SectionCard(
                title: 'Item Details',
                icon: Icons.inventory_2_outlined,
                child: Column(
                  children: [
                    WField(
                      label: 'Item Name',
                      controller: _itemController,
                      hint: 'Enter item name',
                      validator: (v) => v!.isEmpty ? 'Required' : null,
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          flex: 2,
                          child: WField(
                            label: 'Quantity',
                            controller: _qtyController,
                            keyboardType: TextInputType.number,
                            hint: '0.0',
                            validator: (v) => v!.isEmpty ? 'Required' : null,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          flex: 1,
                          child: WDropdown(
                            label: 'Unit',
                            value: _selectedUnit,
                            items: provider.units,
                            hint: 'UoM',
                            onChanged: (v) => setState(() => _selectedUnit = v),
                            validator: (v) => v == null ? 'Required' : null,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              SectionCard(
                title: 'Source Information',
                icon: Icons.local_shipping_outlined,
                child: WDropdown(
                  label: 'Supplier / Production Ref',
                  value: _selectedSupplier,
                  items: provider.suppliers,
                  hint: 'Select Source',
                  onChanged: (v) => setState(() => _selectedSupplier = v),
                  validator: (v) => v == null ? 'Required' : null,
                ),
              ),
              const SizedBox(height: 32),
              PrimaryButton(
                label: 'Save & Generate Barcode',
                icon: Icons.qr_code_scanner,
                onPressed: _saveEntry,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
