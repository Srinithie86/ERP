import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/warehouse_provider.dart';
import '../../widgets/common_widgets.dart';
import 'material_issue_screen.dart';

class PickingScreen extends StatefulWidget {
  final String requestId;

  const PickingScreen({super.key, required this.requestId});

  @override
  State<PickingScreen> createState() => _PickingScreenState();
}

class _PickingScreenState extends State<PickingScreen> {
  final _formKey = GlobalKey<FormState>();
  final _itemBarcodeController = TextEditingController();
  final _locationBarcodeController = TextEditingController();
  final _qtyController = TextEditingController();

  @override
  void dispose() {
    _itemBarcodeController.dispose();
    _locationBarcodeController.dispose();
    _qtyController.dispose();
    super.dispose();
  }

  void _confirmPicking() {
    if (_formKey.currentState!.validate()) {
      final provider = context.read<WarehouseProvider>();
      
      provider.savePicking(
        requestId: widget.requestId,
        itemBarcode: _itemBarcodeController.text,
        locationBarcode: _locationBarcodeController.text,
        pickedQty: double.parse(_qtyController.text),
      );

      // In real scenario, we might iterate over multiple items
      // For this flow, we assume single item or picking completed.
      showSuccessDialog(
        context,
        title: 'Picking Confirmed',
        message: 'Items picked successfully',
        continueLabel: 'Proceed to Issue',
        onContinue: () {
          // Pass the requested itemName back based on the request
          final req = provider.requests.firstWhere((r) => r.id == widget.requestId);
          final itemName = req.items.isNotEmpty ? req.items.first.itemName : 'Unknown';

          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => MaterialIssueScreen(
                requestId: widget.requestId,
                itemName: itemName,
              ),
            ),
          );
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const WmsAppBar(
        title: 'Order Picking',
        screenType: ScreenType.entry,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              const WorkflowStep(label: 'Pick\nItems', isActive: true, isDone: false, stepNumber: 1),
              const SizedBox(height: 24),
              SectionCard(
                title: 'Ref Indent: ${widget.requestId}',
                icon: Icons.inventory_2_outlined,
                child: Column(
                  children: [
                    WField(
                      label: 'Scan Location Barcode',
                      controller: _locationBarcodeController,
                      hint: 'Scan BIN/RACK barcode',
                      suffixIcon: const Icon(Icons.qr_code_scanner),
                      validator: (v) => v!.isEmpty ? 'Required' : null,
                    ),
                    const SizedBox(height: 16),
                    WField(
                      label: 'Scan Item Barcode',
                      controller: _itemBarcodeController,
                      hint: 'Scan Product barcode',
                      suffixIcon: const Icon(Icons.qr_code_scanner),
                      validator: (v) => v!.isEmpty ? 'Required' : null,
                    ),
                    const SizedBox(height: 16),
                    WField(
                      label: 'Picked Quantity',
                      controller: _qtyController,
                      keyboardType: TextInputType.number,
                      hint: 'Enter quantity',
                      validator: (v) => v!.isEmpty ? 'Required' : null,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              PrimaryButton(
                label: 'Confirm Pick & Validate',
                icon: Icons.check_circle_outline,
                onPressed: _confirmPicking,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
