import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter/material.dart';
import '../production_order_model.dart';
import '../widgets/production_order_widgets.dart';
import 'production_planning_page.dart';

class ProductionOrderProductListPage extends StatefulWidget {
  final ProductionOrder order;
  final String initials;
  final VoidCallback onRefresh;

  const ProductionOrderProductListPage({
    super.key,
    required this.order,
    required this.initials,
    required this.onRefresh,
  });

  @override
  State<ProductionOrderProductListPage> createState() => _ProductionOrderProductListPageState();
}

class _ProductionOrderProductListPageState extends State<ProductionOrderProductListPage> {
  ProductionOrder get order => widget.order;

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
            margin: EdgeInsets.only(right: 14.w, top: 12.h, bottom: 12.h),
            padding: EdgeInsets.symmetric(horizontal: 10.w),
            decoration: BoxDecoration(
              color: Colors.white24,
              borderRadius: BorderRadius.circular(20.r),
            ),
            alignment: Alignment.center,
            child: JOStatusBadge(status: order.statusLabel, light: true),
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            color: joTeal.withOpacity(0.08),
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
            child: Row(
              children: [
                Expanded(
                  child: JOSummaryChip(
                      label: 'Total Products',
                      value: '${order.products.length}'),
                ),
                SizedBox(width: 8.w),
                Expanded(
                  child: JOSummaryChip(
                      label: 'Completed', value: '$_completedCount'),
                ),
                SizedBox(width: 8.w),
                Expanded(
                  child: JOSummaryChip(
                      label: 'Pending', value: '$_pendingCount'),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: EdgeInsets.fromLTRB(12, 12, 12, 80),
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
      // floatingActionButton: FloatingActionButton.extended(
      //   backgroundColor: joTeal,
      //   foregroundColor: Colors.white,
      //   icon: Icon(Icons.add),
      //   label: const Text('Add Product',
      //       style: TextStyle(fontWeight: FontWeight.w600)),
      //   onPressed: _addProduct,
      // ),
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
            if (mounted) {
              setState(() {
                plan.splits.add(split);
                plan.done = true;
              });
            }
            widget.onRefresh();
          },
        ),
      ),
    );
    if (mounted) setState(() {});
  }

  void _addProduct() async {
    final nameCtrl = TextEditingController();
    final qtyCtrl = TextEditingController();
    final idCtrl = TextEditingController();

    await showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Add Product',
            style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w700)),
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
            SizedBox(height: 10.h),
            TextField(
              controller: nameCtrl,
              decoration: const InputDecoration(
                labelText: 'Product Name *',
                hintText: 'e.g. Steel Rod',
                isDense: true,
              ),
            ),
            SizedBox(height: 10.h),
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
                final prodId = idCtrl.text.trim().isEmpty
                      ? 'PRD-${(newIdx + 1).toString().padLeft(4, '0')}'
                      : idCtrl.text.trim();
                order.products.add(OrderProduct(
                  name: name,
                  code: prodId,
                  qty: qty,
                  productId: prodId,
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

  String get _displayId => product.code.isNotEmpty
      ? product.code
      : 'PRD-${(productIndex + 1).toString().padLeft(4, '0')}';

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 10.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14.r),
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
                padding: EdgeInsets.fromLTRB(14, 12, 10, 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 8.w,
                          height: 8.h,
                          decoration: BoxDecoration(
                            color: plan.done ? joTeal : Colors.grey.shade400,
                            shape: BoxShape.circle,
                          ),
                        ),
                        SizedBox(width: 8.w),
                        Expanded(
                          child: Text(
                            product.name,
                            style: TextStyle(
                                fontSize: 15.sp,
                                fontWeight: FontWeight.w700,
                                color: Colors.black87),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 5.h),
                    Row(
                      children: [
                        Icon(Icons.tag, size: 12.sp, color: Colors.grey),
                        SizedBox(width: 4.w),
                        Expanded(
                          child: Text(
                            _displayId,
                            style: TextStyle(
                                fontSize: 11.sp,
                                color: Colors.grey.shade500,
                                fontWeight: FontWeight.w500),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 4.h),
                    Row(
                      children: [
                        Icon(Icons.inventory_2_outlined,
                            size: 13.sp, color: Colors.grey),
                        SizedBox(width: 4.w),
                        Text('Qty: ',
                            style: TextStyle(fontSize: 12.sp, color: Colors.grey)),
                        Text(
                          '${product.qty}',
                          style: TextStyle(
                              fontSize: 12.sp,
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
                width: 88.w,
                decoration: BoxDecoration(
                  color: plan.done
                      ? const Color(0xFFF1FAF9)
                      : const Color(0xFFF9F9F9),
                  borderRadius: BorderRadius.only(
                    topRight: Radius.circular(14.r),
                    bottomRight: Radius.circular(14.r),
                  ),
                  border:
                      const Border(left: BorderSide(color: Color(0xFFEEEEEE))),
                ),
                alignment: Alignment.center,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 36.w,
                      height: 36.h,
                      decoration: BoxDecoration(
                        color: plan.done ? joTealLight : joTeal,
                        shape: BoxShape.circle,
                      ),
                      alignment: Alignment.center,
                      child: Icon(
                        plan.done ? Icons.check : Icons.event_note_outlined,
                        size: 18.sp,
                        color: plan.done ? joTealDark : Colors.white,
                      ),
                    ),
                    SizedBox(height: 5.h),
                    Text(
                      plan.done ? 'Re-plan' : 'Planning',
                      style: TextStyle(
                        fontSize: 11.sp,
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
