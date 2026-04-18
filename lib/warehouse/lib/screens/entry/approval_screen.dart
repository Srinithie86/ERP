import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/warehouse_provider.dart';
import '../../widgets/common_widgets.dart';
import '../../models/warehouse_models.dart';
import 'picking_screen.dart';
import '../view/dashboard_screen.dart';

class ApprovalScreen extends StatelessWidget {
  const ApprovalScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<WarehouseProvider>();
    final pending = provider.pendingRequests;

    return Scaffold(
      appBar: const WmsAppBar(
        title: 'Indent Approvals',
        screenType: ScreenType.entry,
      ),
      body: pending.isEmpty
          ? const EmptyState(
              title: 'No Pending Requests',
              subtitle: 'All indents have been processed.',
              icon: Icons.done_all,
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: pending.length,
              itemBuilder: (context, index) {
                final req = pending[index];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: SectionCard(
                    title: 'Req ID: ${req.id}',
                    icon: Icons.contact_page_outlined,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        InfoRow(label: 'Requested By:', value: req.requestedBy),
                        InfoRow(label: 'Total Items:', value: '${req.items.length}'),
                        const Divider(height: 24),
                        const Text('Items:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                        const SizedBox(height: 8),
                        ...req.items.map((item) => Padding(
                          padding: const EdgeInsets.only(bottom: 4),
                          child: Text('• ${item.itemName} (${item.quantity} ${item.unit})', style: const TextStyle(fontSize: 13)),
                        )),
                        const SizedBox(height: 24),
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton(
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: Colors.red,
                                  side: const BorderSide(color: Colors.red),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                ),
                                onPressed: () {
                                  _showRejectDialog(context, req, provider);
                                },
                                child: const Text('Reject'),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.green,
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                ),
                                onPressed: () {
                                  provider.updateRequestStatus(req.id, RequestStatus.approved);
                                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Request Approved!')));
                                  Navigator.pushReplacement(
                                    context,
                                    MaterialPageRoute(builder: (context) => PickingScreen(requestId: req.id)),
                                  );
                                },
                                child: const Text('Approve'),
                              ),
                            ),
                          ],
                        )
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }

  void _showRejectDialog(BuildContext context, IndentRequest req, WarehouseProvider provider) {
    final remarksController = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Reject Request'),
        content: TextField(
          controller: remarksController,
          decoration: const InputDecoration(
            hintText: 'Enter reason for rejection',
            labelText: 'Remarks (Optional)',
          ),
          maxLines: 2,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
            onPressed: () {
              provider.updateRequestStatus(req.id, RequestStatus.rejected, remarks: remarksController.text);
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Request Rejected')));
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => const DashboardScreen()),
                (route) => false,
              );
            },
            child: const Text('Reject'),
          ),
        ],
      ),
    );
  }
}
