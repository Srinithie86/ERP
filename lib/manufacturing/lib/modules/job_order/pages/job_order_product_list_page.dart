import 'package:flutter/material.dart';
import '../job_order_model.dart';
import '../widgets/job_order_widgets.dart';
import 'production_planning_page.dart';

class JobOrderProductListPage extends StatefulWidget {
  final JobOrder order;
  final String initials;
  final VoidCallback onRefresh;

  const JobOrderProductListPage({
    super.key,
    required this.order,
    required this.initials,
    required this.onRefresh,
  });

  @override
  State<JobOrderProductListPage> createState() => _JobOrderProductListPageState();
}

class _JobOrderProductListPageState extends State<JobOrderProductListPage> {
  JobOrder get order => widget.order;

  int get _completedCount => order.planning.where((p) => p.done).length;
  int get _pendingCount => order.products.length - _completedCount;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: buildTealAppBar(
        title: order.customer,
        subtitle: order.id,
        showBack: true,
        context: context,
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 14, top: 12, bottom: 12),
            padding: const EdgeInsets.symmetric(horizontal: 10),
            decoration: BoxDecoration(
              color: Colors.white24,
              borderRadius: BorderRadius.circular(20),
            ),
            alignment: Alignment.center,
            child: JOStatusBadge(status: order.status, light: true),
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            color: joTeal.withOpacity(0.08),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Row(
              children: [
                Expanded(
                  child: JOSummaryChip(
                      label: 'Total Products',
                      value: '${order.products.length}'),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: JOSummaryChip(
                      label: 'Completed', value: '$_completedCount'),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: JOSummaryChip(
                      label: 'Pending', value: '$_pendingCount'),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.fromLTRB(12, 12, 12, 80),
              itemCount: order.products.length,
              itemBuilder: (ctx, i) => _ProductCard(
                product: order.products[i],
                plan: order.planning[i],
                productIndex: i,
                onTapPlanning: () => _openPlanning(i),
                isLast: i == order.products.length - 1,
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: joTeal,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text('Add Product',
            style: TextStyle(fontWeight: FontWeight.w600)),
        onPressed: _addProduct,
      ),
    );
  }

  void _openPlanning(int prodIdx) async {
    final plan = order.planning[prodIdx];
    final product = order.products[prodIdx];
    final available = product.qty - plan.planned > 0
        ? product.qty - plan.planned
        : product.qty;

    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ProductionPlanningPage(
          order: order,
          prodIdx: prodIdx,
          availableQty: available,
          onCreated: (split) {
            setState(() {
              plan.splits.add(split);
              plan.done = true;
            });
            widget.onRefresh();
          },
        ),
      ),
    );
    setState(() {});
  }

  void _addProduct() async {
    final nameCtrl = TextEditingController();
    final qtyCtrl = TextEditingController();
    final idCtrl = TextEditingController();

    await showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Add Product',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: idCtrl,
              decoration: const InputDecoration(
                labelText: 'Product ID',
                hintText: 'e.g. PRD-0005',
                isDense: true,
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: nameCtrl,
              decoration: const InputDecoration(
                labelText: 'Product Name *',
                hintText: 'e.g. Steel Rod',
                isDense: true,
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: qtyCtrl,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Quantity *',
                hintText: 'e.g. 100',
                isDense: true,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: joTeal),
            onPressed: () {
              final name = nameCtrl.text.trim();
              final qty = int.tryParse(qtyCtrl.text.trim()) ?? 0;
              if (name.isEmpty || qty <= 0) return;
              setState(() {
                final newIdx = order.products.length;
                order.products.add(OrderProduct(
                  name: name,
                  qty: qty,
                  productId: idCtrl.text.trim().isEmpty
                      ? 'PRD-${(newIdx + 1).toString().padLeft(4, '0')}'
                      : idCtrl.text.trim(),
                ));
                order.planning.add(ProductPlan());
              });
              widget.onRefresh();
              Navigator.pop(ctx);
            },
            child: const Text('Add', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}

class _ProductCard extends StatelessWidget {
  final OrderProduct product;
  final ProductPlan plan;
  final VoidCallback onTapPlanning;
  final bool isLast;
  final int productIndex;

  const _ProductCard({
    required this.product,
    required this.plan,
    required this.onTapPlanning,
    required this.productIndex,
    this.isLast = false,
  });

  String get _displayId => product.productId.isNotEmpty
      ? product.productId
      : 'PRD-${(productIndex + 1).toString().padLeft(4, '0')}';

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(14, 12, 10, 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: plan.done ? joTeal : Colors.grey.shade400,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            product.name,
                            style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                                color: Colors.black87),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 5),
                    Row(
                      children: [
                        const Icon(Icons.tag, size: 12, color: Colors.grey),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            _displayId,
                            style: TextStyle(
                                fontSize: 11,
                                color: Colors.grey.shade500,
                                fontWeight: FontWeight.w500),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Icons.inventory_2_outlined,
                            size: 13, color: Colors.grey),
                        const SizedBox(width: 4),
                        const Text('Qty: ',
                            style: TextStyle(fontSize: 12, color: Colors.grey)),
                        Text(
                          '${product.qty}',
                          style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: Colors.black87),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            GestureDetector(
              onTap: onTapPlanning,
              child: Container(
                width: 88,
                decoration: BoxDecoration(
                  color: plan.done
                      ? const Color(0xFFF1FAF9)
                      : const Color(0xFFF9F9F9),
                  borderRadius: const BorderRadius.only(
                    topRight: Radius.circular(14),
                    bottomRight: Radius.circular(14),
                  ),
                  border:
                      const Border(left: BorderSide(color: Color(0xFFEEEEEE))),
                ),
                alignment: Alignment.center,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: plan.done ? joTealLight : joTeal,
                        shape: BoxShape.circle,
                      ),
                      alignment: Alignment.center,
                      child: Icon(
                        plan.done ? Icons.check : Icons.event_note_outlined,
                        size: 18,
                        color: plan.done ? joTealDark : Colors.white,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      plan.done ? 'Re-plan' : 'Planning',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: plan.done ? joTealDark : joTeal,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
