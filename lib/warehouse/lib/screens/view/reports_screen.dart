import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../providers/warehouse_provider.dart';
import '../../widgets/common_widgets.dart';

class ReportsScreen extends StatelessWidget {
  const ReportsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<WarehouseProvider>();
    final history = provider.movementHistory;

    return Scaffold(
      appBar: const WmsAppBar(
        title: 'Movement History',
        screenType: ScreenType.viewOnly,
      ),
      body: Column(
        children: [
          const ViewOnlyBanner(),
          Expanded(
            child: history.isEmpty
                ? const EmptyState(title: 'No Movement Data Found')
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: history.length,
                    itemBuilder: (context, index) {
                      final req = history[index];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: SectionCard(
                          padding: const EdgeInsets.all(16),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              CircleAvatar(
                                backgroundColor: req.typeColor.withValues(alpha: 0.2),
                                child: Icon(req.typeIcon, color: req.typeColor),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(req.type, style: TextStyle(color: req.typeColor, fontWeight: FontWeight.bold)),
                                        Text(
                                          DateFormat('dd MMM, HH:mm').format(req.timestamp),
                                          style: const TextStyle(color: Colors.grey, fontSize: 12),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 4),
                                    Text(req.itemName, style: const TextStyle(fontWeight: FontWeight.bold)),
                                    Text('Qty: ${req.quantity}', style: const TextStyle(fontSize: 13)),
                                    const SizedBox(height: 8),
                                    Row(
                                      children: [
                                        const Icon(Icons.place, size: 14, color: Colors.grey),
                                        const SizedBox(width: 4),
                                        Expanded(child: Text('${req.fromLocation}  →  ${req.toLocation}', style: const TextStyle(fontSize: 12))),
                                      ],
                                    )
                                  ],
                                ),
                              )
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
