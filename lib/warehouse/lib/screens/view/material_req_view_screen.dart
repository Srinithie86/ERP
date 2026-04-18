import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/warehouse_provider.dart';
import '../../models/warehouse_models.dart';
import '../../widgets/common_widgets.dart';
import '../entry/request_indent_screen.dart';

class MaterialReqViewScreen extends StatefulWidget {
  const MaterialReqViewScreen({super.key});

  @override
  State<MaterialReqViewScreen> createState() => _MaterialReqViewScreenState();
}

class _MaterialReqViewScreenState extends State<MaterialReqViewScreen> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          'Indent & Issue',
          style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFF26A69A),
        elevation: 0,
        centerTitle: false,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: const BoxDecoration(
              color: Color(0xFF26A69A),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(24),
                bottomRight: Radius.circular(24),
              ),
            ),
            child: Container(
              height: 46,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.all(4),
              child: Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => _selectedIndex = 0),
                      child: Container(
                        decoration: BoxDecoration(
                          color: _selectedIndex == 0 ? Colors.white : Colors.transparent,
                          borderRadius: BorderRadius.circular(8),
                          boxShadow: _selectedIndex == 0
                              ? [BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 4)]
                              : [],
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          'Material Indent',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: _selectedIndex == 0 ? const Color(0xFF26A69A) : Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => _selectedIndex = 1),
                      child: Container(
                        decoration: BoxDecoration(
                          color: _selectedIndex == 1 ? Colors.white : Colors.transparent,
                          borderRadius: BorderRadius.circular(8),
                          boxShadow: _selectedIndex == 1
                              ? [BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 4)]
                              : [],
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          'Material Issue',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: _selectedIndex == 1 ? const Color(0xFF26A69A) : Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              child: _selectedIndex == 0 ? const _PendingRequestsTab() : const _IssuedRequestsTab(),
            ),
          ),
        ],
      ),
      floatingActionButton: _selectedIndex == 0 ? FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const RequestIndentScreen()),
          );
        },
        backgroundColor: const Color(0xFF26A69A),
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('New Indent', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ) : null,
    );
  }
}

class _PendingRequestsTab extends StatelessWidget {
  const _PendingRequestsTab();

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<WarehouseProvider>();
    final pendingRequests = provider.requests.where((r) => r.status != RequestStatus.issued && r.status != RequestStatus.rejected).toList();

    if (pendingRequests.isEmpty) {
      return const EmptyState(
        title: 'No Pending Requests',
        subtitle: 'All department requests have been solved.',
        icon: Icons.history,
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: pendingRequests.length,
      itemBuilder: (context, index) {
        final req = pendingRequests[index];
        return Card(
          elevation: 2,
          margin: const EdgeInsets.only(bottom: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Req ID: ${req.id}',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Color(0xFF26A69A)),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.orange.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.orange),
                      ),
                      child: Text(
                        req.status.name.toUpperCase(),
                        style: const TextStyle(color: Colors.orange, fontSize: 10, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    const Icon(Icons.business, size: 16, color: Colors.grey),
                    const SizedBox(width: 8),
                    Text(
                      'Department: ',
                      style: TextStyle(color: Colors.grey[700], fontSize: 13, fontWeight: FontWeight.w500),
                    ),
                    Expanded(
                      child: Text(
                        req.requestedBy,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                      ),
                    ),
                  ],
                ),
                const Divider(height: 24),
                const Text('Items Requested:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                const SizedBox(height: 8),
                ...req.items.map((item) => Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('• ${item.itemName}', style: const TextStyle(fontSize: 13, color: Colors.black87)),
                      Text('${item.quantity} ${item.unit}', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                    ],
                  ),
                )),
                const SizedBox(height: 20),
                _buildStatusTimeline(req.status),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF26A69A),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    onPressed: () {
                      _markAsIssued(context, provider, req);
                    },
                    child: const Text('Mark as Solved / Issued', style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _markAsIssued(BuildContext context, WarehouseProvider provider, IndentRequest req) {
    // Show confirmation dialog before marking as issued
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Issue Material?'),
        content: Text('Are you sure you want to mark request ${req.id} from ${req.requestedBy} as completely solved and issued?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF26A69A), foregroundColor: Colors.white),
            onPressed: () {
              // Issue items and deduct stock
              for (var item in req.items) {
                 provider.confirmIssue(
                   requestId: req.id,
                   itemName: item.itemName,
                   issuedQty: item.quantity,
                   issuedTo: req.requestedBy,
                 );
              }
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Materials Issued Successfully!')),
              );
            },
            child: const Text('Confirm Issue'),
          ),
        ],
      ),
    );
  }
}

class _IssuedRequestsTab extends StatelessWidget {
  const _IssuedRequestsTab();

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<WarehouseProvider>();
    final issuedRequests = provider.requests.where((r) => r.status == RequestStatus.issued).toList();

    if (issuedRequests.isEmpty) {
      return const EmptyState(
        title: 'No Issued Requests',
        subtitle: 'No department requests have been marked as solved yet.',
        icon: Icons.check_circle_outline,
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: issuedRequests.length,
      itemBuilder: (context, index) {
        final req = issuedRequests[index];
        return Card(elevation: 1,
          margin: const EdgeInsets.only(bottom: 16),
          color: Colors.green.shade50,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(color: Colors.green.shade200, width: 1),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Req ID: ${req.id}',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Colors.green.shade800),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.green,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Text(
                        'ISSUED',
                        style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    const Icon(Icons.business, size: 16, color: Colors.grey),
                    const SizedBox(width: 8),
                    Text(
                      'Department: ',
                      style: TextStyle(color: Colors.grey[700], fontSize: 13, fontWeight: FontWeight.w500),
                    ),
                    Expanded(
                      child: Text(
                        req.requestedBy,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                      ),
                    ),
                  ],
                ),
                const Divider(height: 24),
                const Text('Issued Items:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                const SizedBox(height: 8),
                ...req.items.map((item) => Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('• ${item.itemName}', style: const TextStyle(fontSize: 13, color: Colors.black87)),
                      Text('${item.quantity} ${item.unit}', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.green.shade700)),
                    ],
                  ),
                )),
                const SizedBox(height: 20),
                _buildStatusTimeline(req.status),
              ],
            ),
          ),
        );
      },
    );
  }
}

Widget _buildStatusTimeline(RequestStatus status) {
  int currentStep = 0;
  if (status == RequestStatus.approved) currentStep = 1;
  if (status == RequestStatus.issued) currentStep = 2;
  if (status == RequestStatus.rejected) currentStep = -1;

  return Row(
    children: [
      _timelineNode('Requested', true, currentStep >= 0),
      _timelineLine(currentStep >= 1),
      if (currentStep != -1) ...[
        _timelineNode('Approved', currentStep >= 1, currentStep >= 1),
        _timelineLine(currentStep >= 2),
        _timelineNode('Solved', currentStep >= 2, currentStep >= 2),
      ] else ...[
        _timelineNode('Rejected', true, true, isError: true),
        _timelineLine(false),
        _timelineNode('Solved', false, false),
      ]
    ],
  );
}

Widget _timelineNode(String label, bool isActive, bool isCompleted, {bool isError = false}) {
  final color = isError ? Colors.red : (isActive ? const Color(0xFF26A69A) : Colors.grey.shade300);
  return Column(
    children: [
      Container(
        width: 24,
        height: 24,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: isCompleted || isError ? color : Colors.white,
          border: Border.all(color: color, width: 2),
        ),
        child: isCompleted || isError
            ? Icon(isError ? Icons.close : Icons.check, size: 14, color: Colors.white)
            : null,
      ),
      const SizedBox(height: 4),
      Text(
        label,
        style: TextStyle(
          fontSize: 10,
          fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
          color: isActive ? Colors.black87 : Colors.grey,
        ),
      ),
    ],
  );
}

Widget _timelineLine(bool isActive) {
  return Expanded(
    child: Container(
      height: 2,
      margin: const EdgeInsets.only(bottom: 16), // offset for text below node
      color: isActive ? const Color(0xFF26A69A) : Colors.grey.shade300,
    ),
  );
}
