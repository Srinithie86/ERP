import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/warehouse_provider.dart';
import '../../widgets/common_widgets.dart';
import '../view/stock_view_screen.dart';

class PutawayScreen extends StatefulWidget {
  final String grnId;
  final String itemName;
  final double quantity;
  final String unit;

  const PutawayScreen({
    super.key,
    required this.grnId,
    required this.itemName,
    required this.quantity,
    required this.unit,
  });

  @override
  State<PutawayScreen> createState() => _PutawayScreenState();
}

class _PutawayScreenState extends State<PutawayScreen> {
  final _formKey = GlobalKey<FormState>();
  
  String? _selectedWarehouse;
  String? _selectedRack;
  String? _selectedBin;
  String? _selectedShelf;

  void _confirmPutaway() {
    if (_formKey.currentState!.validate()) {
      final provider = context.read<WarehouseProvider>();
      
      provider.confirmPutaway(
        grnId: widget.grnId,
        itemName: widget.itemName,
        quantity: widget.quantity,
        unit: widget.unit,
        warehouse: _selectedWarehouse!,
        rack: _selectedRack!,
        bin: _selectedBin!,
        shelf: _selectedShelf!,
      );

      showSuccessDialog(
        context,
        title: 'Putaway Confirmed',
        message: 'Items placed in $_selectedWarehouse / $_selectedRack',
        continueLabel: 'Go to Stock View',
        onContinue: () {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => const StockViewScreen()),
            (route) => route.isFirst,
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
        title: 'Putaway Assignment',
        screenType: ScreenType.entry,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              const WorkflowStep(label: 'Assign\nLocation', isActive: true, isDone: false, stepNumber: 2),
              const SizedBox(height: 24),
              // Read-only info section inside Entry Screen
              SectionCard(
                title: 'Item to Putaway',
                icon: Icons.info_outline,
                child: Column(
                  children: [
                    InfoRow(label: 'Ref GRN:', value: widget.grnId),
                    InfoRow(label: 'Item:', value: widget.itemName),
                    InfoRow(label: 'Qty to Place:', value: '${widget.quantity} ${widget.unit}'),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              SectionCard(
                title: 'Select Destination',
                icon: Icons.place_outlined,
                child: Column(
                  children: [
                    WDropdown(
                      label: 'Warehouse',
                      value: _selectedWarehouse,
                      items: provider.warehouses,
                      hint: 'Select Warehouse',
                      onChanged: (v) => setState(() => _selectedWarehouse = v),
                      validator: (v) => v == null ? 'Required' : null,
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: WDropdown(
                            label: 'Rack',
                            value: _selectedRack,
                            items: provider.racks,
                            hint: 'Rack',
                            onChanged: (v) => setState(() => _selectedRack = v),
                            validator: (v) => v == null ? 'Required' : null,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: WDropdown(
                            label: 'Bin',
                            value: _selectedBin,
                            items: provider.bins,
                            hint: 'Bin',
                            onChanged: (v) => setState(() => _selectedBin = v),
                            validator: (v) => v == null ? 'Required' : null,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    WDropdown(
                      label: 'Shelf',
                      value: _selectedShelf,
                      items: provider.shelves,
                      hint: 'Select Shelf',
                      onChanged: (v) => setState(() => _selectedShelf = v),
                      validator: (v) => v == null ? 'Required' : null,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              PrimaryButton(
                label: 'Confirm Location',
                icon: Icons.check_circle_outline,
                onPressed: _confirmPutaway,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
