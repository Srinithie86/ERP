import 'package:flutter/material.dart';
import '../job_order_model.dart';
import '../widgets/job_order_widgets.dart';
import 'job_order_product_list_page.dart';
import 'job_order_create_page.dart';

class JobOrderListPage extends StatefulWidget {
  const JobOrderListPage({super.key});

  @override
  State<JobOrderListPage> createState() => _JobOrderListPageState();
}

class _JobOrderListPageState extends State<JobOrderListPage> {
  final List<JobOrder> _orders = List.from(JobOrderSampleData.jobOrders);

  String _initials(String name) =>
      name.trim().split(' ').take(2).map((w) => w[0].toUpperCase()).join();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: Column(
        children: [
          _OrderSummaryBar(orders: _orders),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.fromLTRB(12, 8, 12, 80),
              itemCount: _orders.length,
              itemBuilder: (ctx, idx) {
                final order = _orders[idx];
                return _CustomerNameCard(
                  order: order,
                  initials: _initials(order.customer),
                  onTap: () async {
                    await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => JobOrderProductListPage(
                          order: order,
                          initials: _initials(order.customer),
                          onRefresh: () => setState(() {}),
                        ),
                      ),
                    );
                    setState(() {});
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: joTeal,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text('New Order',
            style: TextStyle(fontWeight: FontWeight.w600)),
        onPressed: () async {
          final newOrder = await Navigator.push<JobOrder>(
            context,
            MaterialPageRoute(builder: (_) => const JobOrderCreatePage()),
          );
          if (newOrder != null) setState(() => _orders.add(newOrder));
        },
      ),
    );
  }
}

class _OrderSummaryBar extends StatelessWidget {
  final List<JobOrder> orders;
  const _OrderSummaryBar({required this.orders});

  @override
  Widget build(BuildContext context) {
    final total = orders.length;
    final active = orders.where((o) => o.status == 'active').length;
    final pending = orders.where((o) => o.status == 'pending').length;

    return Container(
      margin: const EdgeInsets.fromLTRB(12, 12, 12, 4),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _StatItem(label: 'Total', value: '$total', color: joTeal),
          _DividerLine(),
          _StatItem(
              label: 'Active', value: '$active', color: Colors.green.shade600),
          _DividerLine(),
          _StatItem(
              label: 'Pending',
              value: '$pending',
              color: Colors.orange.shade600),
        ],
      ),
    );
  }
}

class _DividerLine extends StatelessWidget {
  @override
  Widget build(BuildContext context) =>
      Container(height: 28, width: 1, color: Colors.grey.shade200);
}

class _StatItem extends StatelessWidget {
  final String label, value;
  final Color color;
  const _StatItem(
      {required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) => Column(
        children: [
          Text(value,
              style: TextStyle(
                  fontSize: 18, fontWeight: FontWeight.w800, color: color)),
          Text(label,
              style: TextStyle(fontSize: 11, color: Colors.grey.shade500)),
        ],
      );
}

class _CustomerNameCard extends StatelessWidget {
  final JobOrder order;
  final String initials;
  final VoidCallback onTap;

  const _CustomerNameCard({
    required this.order,
    required this.initials,
    required this.onTap,
  });

  String _fmt(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
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
        child: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: const BoxDecoration(
                  color: joTealLight, shape: BoxShape.circle),
              alignment: Alignment.center,
              child: Text(
                initials,
                style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: joTealDark),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                   Text(
                    order.id,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    order.customer,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: Colors.grey.shade600,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 5),
                  Row(
                    children: [
                      const Icon(Icons.local_shipping_outlined,
                          size: 12, color: joTeal),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          'Delivery: ${_fmt(order.deliveryDate)}',
                          style: const TextStyle(
                              fontSize: 11,
                              color: joTealDark,
                              fontWeight: FontWeight.w600),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  if (order.plannedCount > 0) ...[
                    const SizedBox(height: 6),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: order.plannedCount / order.products.length,
                        backgroundColor: Colors.grey.shade200,
                        valueColor: const AlwaysStoppedAnimation(joTeal),
                        minHeight: 4,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      '${order.plannedCount}/${order.products.length} planned',
                      style: const TextStyle(fontSize: 10, color: joTeal),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                JOStatusBadge(status: order.status),
                const SizedBox(height: 6),
                const Icon(Icons.chevron_right, color: Colors.grey, size: 18),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
