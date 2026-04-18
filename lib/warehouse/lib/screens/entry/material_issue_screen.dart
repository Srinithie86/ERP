import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/warehouse_provider.dart';
import '../../widgets/common_widgets.dart';
import '../view/dashboard_screen.dart';

class MaterialIssueScreen extends StatefulWidget {
  final String requestId;
  final String itemName;

  const MaterialIssueScreen({
    super.key,
    required this.requestId,
    required this.itemName,
  });

  @override
  State<MaterialIssueScreen> createState() => _MaterialIssueScreenState();
}

class _MaterialIssueScreenState extends State<MaterialIssueScreen> {
  final _formKey = GlobalKey<FormState>();
  final _qtyController = TextEditingController();
  final _issuedToController = TextEditingController();

  @override
  void dispose() {
    _qtyController.dispose();
    _issuedToController.dispose();
    super.dispose();
  }

  void _confirmIssue() {
    if (_formKey.currentState!.validate()) {
      final provider = context.read<WarehouseProvider>();
      
      provider.confirmIssue(
        requestId: widget.requestId,
        itemName: widget.itemName,
        issuedQty: double.parse(_qtyController.text),
        issuedTo: _issuedToController.text,
      );

      showSuccessDialog(
        context,
        title: 'Material Issued',
        message: 'Stock has been deducted and issued successfully.',
        continueLabel: 'Go to Dashboard',
        onContinue: () {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => const DashboardScreen()),
            (route) => false,
          );
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const WmsAppBar(
        title: 'Material Issue',
        screenType: ScreenType.entry,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              const WorkflowStep(label: 'Issue\nMaterial', isActive: true, isDone: false, stepNumber: 2),
              const SizedBox(height: 24),
              SectionCard(
                title: 'Review Issue Details',
                icon: Icons.outbox_outlined,
                child: Column(
                  children: [
                    InfoRow(label: 'Ref Indent:', value: widget.requestId),
                    InfoRow(label: 'Item:', value: widget.itemName),
                    const SizedBox(height: 16),
                    WField(
                      label: 'Issue Quantity',
                      controller: _qtyController,
                      keyboardType: TextInputType.number,
                      hint: '0.0',
                      validator: (v) => v!.isEmpty ? 'Required' : null,
                    ),
                    const SizedBox(height: 16),
                    WField(
                      label: 'Issued To (Person/Dept)',
                      controller: _issuedToController,
                      hint: 'Enter recipient name',
                      validator: (v) => v!.isEmpty ? 'Required' : null,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              PrimaryButton(
                label: 'Confirm Issue',
                icon: Icons.check,
                onPressed: _confirmIssue,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
