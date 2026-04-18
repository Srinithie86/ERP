import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/warehouse_provider.dart';
import '../../widgets/common_widgets.dart';
import 'putaway_screen.dart';

class FinishedGoodsEntryScreen extends StatefulWidget {
  const FinishedGoodsEntryScreen({super.key});

  @override
  State<FinishedGoodsEntryScreen> createState() => _FinishedGoodsEntryScreenState();
}

class _FinishedGoodsEntryScreenState extends State<FinishedGoodsEntryScreen> {
  final _formKey = GlobalKey<FormState>();
  final _refController = TextEditingController();
  final _itemController = TextEditingController();
  final _qtyController = TextEditingController();
  
  String? _selectedUnit;

  @override
  void dispose() {
    _refController.dispose();
    _itemController.dispose();
    _qtyController.dispose();
    super.dispose();
  }

  void _saveEntry() {
    if (_formKey.currentState!.validate()) {
      final provider = context.read<WarehouseProvider>();
      
      final entry = provider.saveFG(
        productionRef: _refController.text,
        fgItemName: _itemController.text,
        quantity: double.parse(_qtyController.text),
        unit: _selectedUnit!,
      );

      showSuccessDialog(
        context,
        title: 'FG Received',
        message: 'Finished goods received successfully!\nBarcode: ${entry.barcode}',
        continueLabel: 'Assign to Location (Putaway)',
        onContinue: () {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => PutawayScreen(
                grnId: entry.id, // Treating FG ID as GRN ID for putaway purposes
                itemName: entry.fgItemName,
                quantity: entry.quantity,
                unit: entry.unit,
              ),
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
        title: 'Finished Goods Entry',
        screenType: ScreenType.entry,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              SectionCard(
                title: 'Production Details',
                icon: Icons.factory_outlined,
                child: WField(
                  label: 'Production Reference / Batch No',
                  controller: _refController,
                  hint: 'e.g. PRD-2024-10-01',
                  validator: (v) => v!.isEmpty ? 'Required' : null,
                ),
              ),
              const SizedBox(height: 16),
              SectionCard(
                title: 'Item Details',
                icon: Icons.inventory_2_outlined,
                child: Column(
                  children: [
                    WField(
                      label: 'Finished Good Item Name',
                      controller: _itemController,
                      hint: 'Enter FG item name',
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
              const SizedBox(height: 32),
              PrimaryButton(
                label: 'Save & Generate Barcode',
                icon: Icons.qr_code,
                onPressed: _saveEntry,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
