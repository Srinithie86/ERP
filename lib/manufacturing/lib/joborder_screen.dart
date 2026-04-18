import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

const _teal = Color(0xFF26A69A);
const _tealLight = Color(0xFFE0F2F1);
const _tealDark = Color(0xFF00695C);
const _amber = Color(0xFFF57F17);
const _amberLight = Color(0xFFFFF8E1);

// ─────────────────────────────────────────
// MODELS
// ─────────────────────────────────────────

class ProductSplit {
  String label;
  int qty;
  String priority;
  DateTime? deadline;

  ProductSplit({
    this.label = '',
    this.qty = 0,
    this.priority = 'High',
    this.deadline,
  });
}

class ProductPlan {
  List<ProductSplit> splits;
  bool done;
  ProductPlan() : splits = [], done = false;
  int get planned => splits.fold(0, (a, s) => a + s.qty);
}

class OrderProduct {
  String name;
  int qty;
  OrderProduct({required this.name, required this.qty});
}

class JobOrder {
  final String id;
  final String customer;
  final String ref;
  String status;
  final List<OrderProduct> products;
  final List<ProductPlan> planning;

  JobOrder({
    required this.id,
    required this.customer,
    this.ref = '',
    this.status = 'pending',
    required this.products,
  }) : planning = List.generate(products.length, (_) => ProductPlan());

  int get totalQty => products.fold(0, (a, p) => a + p.qty);
  int get plannedCount => planning.where((p) => p.done).length;
}

// ─────────────────────────────────────────
// LEVEL 1 — JOB ORDER LIST
// ─────────────────────────────────────────

class JobOrderScreen extends StatefulWidget {
  const JobOrderScreen({super.key});
  @override
  State<JobOrderScreen> createState() => _JobOrderScreenState();
}

class _JobOrderScreenState extends State<JobOrderScreen> {
  final List<JobOrder> _orders = [
    JobOrder(
      id: 'JO-001',
      customer: 'Rajan Industries',
      ref: 'RI-2024-88',
      status: 'active',
      products: [
        OrderProduct(name: 'Steel Frame', qty: 100),
        OrderProduct(name: 'Bolt Set', qty: 500),
      ],
    ),
    JobOrder(
      id: 'JO-002',
      customer: 'Tamil Tech Pvt Ltd',
      ref: 'TT-99',
      status: 'pending',
      products: [
        OrderProduct(name: 'Control Panel', qty: 40),
        OrderProduct(name: 'Wire Harness', qty: 120),
      ],
    ),
  ];

  String _initials(String name) =>
      name.trim().split(' ').take(2).map((w) => w[0].toUpperCase()).join();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: _teal,
        elevation: 0,
        systemOverlayStyle: const SystemUiOverlayStyle(
          statusBarColor: _teal,
          statusBarIconBrightness: Brightness.light,
        ),
        title: const Text(
          'Job Orders',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.event_note_outlined, color: Colors.white),
            tooltip: 'Production Planning',
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => JobOrderSplitsScreen(orders: _orders),
              ),
            ),
          ),
          Container(
            margin: const EdgeInsets.only(right: 14, top: 12, bottom: 12),
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: Colors.white24,
              borderRadius: BorderRadius.circular(20),
            ),
            alignment: Alignment.center,
            child: Text(
              '${_orders.length} order${_orders.length != 1 ? 's' : ''}',
              style: const TextStyle(color: Colors.white, fontSize: 12),
            ),
          ),
        ],
      ),
      body: ListView.builder(
        padding: const EdgeInsets.fromLTRB(12, 12, 12, 80),
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
                  builder: (_) => _ProductListScreen(
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
    );
  }

  void _openCreate() async {
    final newOrder = await Navigator.push<JobOrder>(
      context,
      MaterialPageRoute(builder: (_) => const CreateJobOrderScreen()),
    );
    if (newOrder != null) setState(() => _orders.add(newOrder));
  }
}

// ─────────────────────────────────────────
// CUSTOMER NAME CARD
// ─────────────────────────────────────────

class _CustomerNameCard extends StatelessWidget {
  final JobOrder order;
  final String initials;
  final VoidCallback onTap;

  const _CustomerNameCard({
    required this.order,
    required this.initials,
    required this.onTap,
  });

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
              color: Colors.black.withValues(alpha: 0.03),
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
              decoration:
              const BoxDecoration(color: _tealLight, shape: BoxShape.circle),
              alignment: Alignment.center,
              child: Text(
                initials,
                style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: _tealDark),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    order.customer,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    '${order.id}${order.ref.isNotEmpty ? ' · ${order.ref}' : ''} · ${order.products.length} product${order.products.length != 1 ? 's' : ''}',
                    style: const TextStyle(fontSize: 11, color: Colors.grey),
                  ),
                  if (order.plannedCount > 0) ...[
                    const SizedBox(height: 6),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: order.plannedCount / order.products.length,
                        backgroundColor: Colors.grey.shade200,
                        valueColor: const AlwaysStoppedAnimation(_teal),
                        minHeight: 4,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      '${order.plannedCount}/${order.products.length} planned',
                      style: const TextStyle(fontSize: 10, color: _teal),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                _StatusBadge(status: order.status),
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

// ─────────────────────────────────────────
// LEVEL 2 — PRODUCT LIST
// ─────────────────────────────────────────

class _ProductListScreen extends StatefulWidget {
  final JobOrder order;
  final String initials;
  final VoidCallback onRefresh;

  const _ProductListScreen({
    required this.order,
    required this.initials,
    required this.onRefresh,
  });

  @override
  State<_ProductListScreen> createState() => _ProductListScreenState();
}

class _ProductListScreenState extends State<_ProductListScreen> {
  JobOrder get order => widget.order;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: _teal,
        elevation: 0,
        systemOverlayStyle: const SystemUiOverlayStyle(
          statusBarColor: _teal,
          statusBarIconBrightness: Brightness.light,
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              order.customer,
              style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: 15),
            ),
            Text(
              '${order.id}${order.ref.isNotEmpty ? ' · ${order.ref}' : ''}',
              style: const TextStyle(color: Colors.white70, fontSize: 11),
            ),
          ],
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 14, top: 12, bottom: 12),
            padding: const EdgeInsets.symmetric(horizontal: 10),
            decoration: BoxDecoration(
              color: Colors.white24,
              borderRadius: BorderRadius.circular(20),
            ),
            alignment: Alignment.center,
            child: _StatusBadge(status: order.status, light: true),
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            color: _teal.withValues(alpha: 0.08),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Row(
              children: [
                _SummaryChip(
                    label: 'Products', value: '${order.products.length}'),
                const SizedBox(width: 8),
                _SummaryChip(label: 'Total Qty', value: '${order.totalQty}'),
                const SizedBox(width: 8),
                _SummaryChip(
                    label: 'Planned',
                    value: '${order.plannedCount}/${order.products.length}'),
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
                onTapPlanning: () => _openPlanning(i),
                isLast: i == order.products.length - 1,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _openPlanning(int prodIdx) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ProductPlanningScreen(
          order: order,
          initialProdIdx: prodIdx,
          onDone: () {
            setState(() {});
            widget.onRefresh();
          },
        ),
      ),
    );
    setState(() {});
  }
}

// ─────────────────────────────────────────
// PRODUCT CARD
// ─────────────────────────────────────────

class _ProductCard extends StatelessWidget {
  final OrderProduct product;
  final ProductPlan plan;
  final VoidCallback onTapPlanning;
  final bool isLast;

  const _ProductCard({
    required this.product,
    required this.plan,
    required this.onTapPlanning,
    this.isLast = false,
  });

  @override
  Widget build(BuildContext context) {
    final pct = plan.done
        ? 1.0
        : (product.qty > 0
        ? (plan.planned / product.qty).clamp(0.0, 1.0)
        : 0.0);

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
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
                            color: plan.done ? _teal : Colors.grey.shade400,
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
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        const Icon(Icons.inventory_2_outlined,
                            size: 13, color: Colors.grey),
                        const SizedBox(width: 4),
                        const Text('Qty: ',
                            style: TextStyle(fontSize: 12, color: Colors.grey)),
                        Text('${product.qty}',
                            style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: Colors.black87)),
                      ],
                    ),
                    const SizedBox(height: 8),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: pct,
                        backgroundColor: Colors.grey.shade200,
                        valueColor: const AlwaysStoppedAnimation(_teal),
                        minHeight: 5,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      plan.done
                          ? '✓ Fully planned'
                          : 'Planned: ${plan.planned} / ${product.qty}',
                      style: TextStyle(
                          fontSize: 10,
                          color: plan.done ? _teal : Colors.grey),
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
                        color: plan.done ? _tealLight : _teal,
                        shape: BoxShape.circle,
                      ),
                      alignment: Alignment.center,
                      child: Icon(
                        plan.done ? Icons.check : Icons.event_note_outlined,
                        size: 18,
                        color: plan.done ? _tealDark : Colors.white,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      plan.done ? 'Planned' : 'Planning',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: plan.done ? _tealDark : _teal,
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

// ─────────────────────────────────────────
// LEVEL 3 — PRODUCT PLANNING SCREEN
// ─────────────────────────────────────────

class ProductPlanningScreen extends StatefulWidget {
  final JobOrder order;
  final int initialProdIdx;
  final VoidCallback onDone;

  const ProductPlanningScreen({
    super.key,
    required this.order,
    required this.initialProdIdx,
    required this.onDone,
  });

  @override
  State<ProductPlanningScreen> createState() => _ProductPlanningScreenState();
}

class _ProductPlanningScreenState extends State<ProductPlanningScreen> {
  late int _prodIdx;

  @override
  void initState() {
    super.initState();
    _prodIdx = widget.initialProdIdx;
  }

  JobOrder get order => widget.order;
  OrderProduct get product => order.products[_prodIdx];
  ProductPlan get plan => order.planning[_prodIdx];
  int get remaining => product.qty - plan.planned;
  double get pct =>
      product.qty > 0 ? (plan.planned / product.qty).clamp(0.0, 1.0) : 0.0;

  bool get _allLabelled =>
      plan.splits.every((s) => s.label.trim().isNotEmpty);
  bool get _canConfirm =>
      plan.splits.isNotEmpty && remaining == 0 && _allLabelled;

  void _openAddSplitSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _CreateSplitSheet(
        availableQty: remaining,
        onCreated: (split) {
          setState(() => plan.splits.add(split));
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // ✅ AnnotatedRegion — status bar color to _teal, icons white
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor:Colors.teal,
        statusBarIconBrightness: Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: Colors.grey[100],
        body: Column(
          children: [
            // ── Header (replaces AppBar, so we handle SafeArea manually) ──
            SafeArea(
              bottom: false,
              child: Container(
                color: _teal,
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        GestureDetector(
                          onTap: () => Navigator.pop(context),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 6),
                            decoration: BoxDecoration(
                              color: Colors.white24,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(Icons.arrow_back,
                                color: Colors.white, size: 18),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(order.customer,
                                  style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 15,
                                      fontWeight: FontWeight.w700)),
                              Text(
                                '${order.id} · Product ${_prodIdx + 1} of ${order.products.length}',
                                style: const TextStyle(
                                    color: Colors.white70, fontSize: 11),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white24,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(product.name,
                                  style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600)),
                              Text('Total: ${product.qty}',
                                  style: const TextStyle(
                                      color: Colors.white70, fontSize: 13)),
                            ],
                          ),
                          const SizedBox(height: 8),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(4),
                            child: LinearProgressIndicator(
                              value: pct,
                              backgroundColor: Colors.white30,
                              valueColor:
                              const AlwaysStoppedAnimation(Colors.white),
                              minHeight: 6,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('Planned: ${plan.planned}',
                                  style: const TextStyle(
                                      color: Colors.white70, fontSize: 11)),
                              Text('Remaining: $remaining',
                                  style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 11,
                                      fontWeight: FontWeight.w700)),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // ── Body ──
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(14),
                children: [
                  const Text(
                    'PRODUCTION SPLITS',
                    style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey,
                        letterSpacing: 0.5),
                  ),
                  const SizedBox(height: 10),

                  ...List.generate(
                    plan.splits.length,
                        (i) => _SplitCard(
                      index: i,
                      split: plan.splits[i],
                      onDelete: () =>
                          setState(() => plan.splits.removeAt(i)),
                    ),
                  ),

                  if (remaining > 0)
                    GestureDetector(
                      onTap: _openAddSplitSheet,
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 14),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          border:
                          Border.all(color: _teal.withValues(alpha: 0.4)),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        alignment: Alignment.center,
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.add_circle_outline,
                                size: 18, color: _teal),
                            SizedBox(width: 6),
                            Text('Add Split',
                                style: TextStyle(
                                    fontSize: 13,
                                    color: _teal,
                                    fontWeight: FontWeight.w600)),
                          ],
                        ),
                      ),
                    )
                  else
                    const SizedBox(height: 14),

                  if (plan.splits.isNotEmpty) ...[
                    if (remaining > 0)
                      _Banner(
                        color: _amberLight,
                        textColor: _amber,
                        text: '⚠  $remaining units still unassigned',
                      )
                    else
                      _Banner(
                        color: _tealLight,
                        textColor: _tealDark,
                        text:
                        '✓  All ${product.qty} units assigned across ${plan.splits.length} split${plan.splits.length > 1 ? 's' : ''}',
                      ),
                    const SizedBox(height: 14),
                  ],

                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                        _canConfirm ? _teal : Colors.grey[300],
                        foregroundColor: Colors.white,
                        padding:
                        const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                        elevation: 0,
                      ),
                      onPressed:
                      _canConfirm ? _confirm : _onDisabledTap,
                      child: Text(
                        _canConfirm ? 'Confirm & Next' : 'Save Planning',
                        style: const TextStyle(
                            fontSize: 15, fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),

                  if (plan.splits.isNotEmpty &&
                      (remaining > 0 || !_allLabelled)) ...[
                    const SizedBox(height: 8),
                    Text(
                      remaining > 0
                          ? '⚠  Assign all $remaining remaining units to enable confirm'
                          : '⚠  Enter batch name for all splits to enable confirm',
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 11, color: _amber),
                    ),
                  ],

                  const SizedBox(height: 20),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _onDisabledTap() {
    if (plan.splits.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Add at least one production split first.'),
          backgroundColor: _amber,
          duration: Duration(seconds: 2),
        ),
      );
    } else if (remaining > 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              '⚠  $remaining units still unassigned. Assign all units to confirm.'),
          backgroundColor: _amber,
          duration: const Duration(seconds: 3),
        ),
      );
    } else if (!_allLabelled) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content:
          Text('⚠  Enter batch name for all splits before confirming.'),
          backgroundColor: _amber,
          duration: Duration(seconds: 3),
        ),
      );
    }
  }

  void _confirm() {
    setState(() {
      plan.done = true;
      order.status = 'active';
    });
    widget.onDone();

    final next = _nextUnplanned();
    if (next != -1) {
      setState(() => _prodIdx = next);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Moving to ${order.products[next].name}...'),
          backgroundColor: _teal,
          duration: const Duration(seconds: 2),
        ),
      );
    } else {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (dialogCtx) => AlertDialog(
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: const BoxDecoration(
                    color: _tealLight, shape: BoxShape.circle),
                alignment: Alignment.center,
                child: const Text('✓',
                    style: TextStyle(fontSize: 28, color: _teal)),
              ),
              const SizedBox(height: 14),
              const Text('All Products Planned!',
                  style: TextStyle(
                      fontSize: 17, fontWeight: FontWeight.w700)),
              const SizedBox(height: 8),
              Text(
                '${order.products.length} products planned for ${order.customer}',
                textAlign: TextAlign.center,
                style:
                const TextStyle(fontSize: 13, color: Colors.grey),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogCtx);
                Navigator.pop(context);
              },
              child: const Text('OK',
                  style: TextStyle(
                      color: _teal, fontWeight: FontWeight.w700)),
            ),
          ],
        ),
      );
    }
  }

  int _nextUnplanned() {
    for (int i = 0; i < order.products.length; i++) {
      if (!order.planning[i].done) return i;
    }
    return -1;
  }
}

// ─────────────────────────────────────────
// SPLIT CARD
// ─────────────────────────────────────────

class _SplitCard extends StatelessWidget {
  final int index;
  final ProductSplit split;
  final VoidCallback onDelete;

  const _SplitCard({
    required this.index,
    required this.split,
    required this.onDelete,
  });

  Color _priorityColor(String p) {
    switch (p) {
      case 'High':
        return Colors.red.shade400;
      case 'Medium':
        return _amber;
      default:
        return Colors.green.shade500;
    }
  }

  @override
  Widget build(BuildContext context) {
    final priorityColor = _priorityColor(split.priority);
    final deadlineStr = split.deadline != null
        ? '${split.deadline!.day}/${split.deadline!.month}/${split.deadline!.year}'
        : '—';

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 26,
            height: 26,
            decoration:
            const BoxDecoration(color: _teal, shape: BoxShape.circle),
            alignment: Alignment.center,
            child: Text('${index + 1}',
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.w700)),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  split.label,
                  style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: Colors.black87),
                ),
                const SizedBox(height: 6),
                Wrap(
                  spacing: 8,
                  runSpacing: 4,
                  children: [
                    _InfoChip(
                      icon: Icons.inventory_2_outlined,
                      label: '${split.qty} units',
                      color: _teal,
                      bg: _tealLight,
                    ),
                    _InfoChip(
                      icon: Icons.flag_outlined,
                      label: split.priority,
                      color: priorityColor,
                      bg: priorityColor.withValues(alpha: 0.1),
                    ),
                    _InfoChip(
                      icon: Icons.calendar_today_outlined,
                      label: deadlineStr,
                      color: Colors.grey.shade600,
                      bg: Colors.grey.shade100,
                    ),
                  ],
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: onDelete,
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                shape: BoxShape.circle,
              ),
              child:
              Icon(Icons.close, color: Colors.red.shade300, size: 16),
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final Color bg;

  const _InfoChip({
    required this.icon,
    required this.label,
    required this.color,
    required this.bg,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 11, color: color),
          const SizedBox(width: 4),
          Text(label,
              style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: color)),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────
// CREATE SPLIT BOTTOM SHEET
// ─────────────────────────────────────────

class _CreateSplitSheet extends StatefulWidget {
  final int availableQty;
  final void Function(ProductSplit) onCreated;

  const _CreateSplitSheet({
    required this.availableQty,
    required this.onCreated,
  });

  @override
  State<_CreateSplitSheet> createState() => _CreateSplitSheetState();
}

class _CreateSplitSheetState extends State<_CreateSplitSheet> {
  final List<String> _bomOptions = [
    'BOM-001 · Steel Frame Assembly',
    'BOM-002 · Bolt Set Pack',
    'BOM-003 · Control Panel Unit',
    'BOM-004 · Wire Harness Kit',
  ];

  final List<String> _priorityOptions = ['High', 'Medium', 'Low'];

  String? _selectedBom;
  String _priority = 'High';
  DateTime? _deadline;
  int _qty = 0;

  final _qtyCtrl = TextEditingController();

  bool get _canCreate =>
      _selectedBom != null &&
          _qty > 0 &&
          _qty <= widget.availableQty &&
          _deadline != null;

  @override
  void dispose() {
    _qtyCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: now,
      lastDate: DateTime(now.year + 2),
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
          colorScheme: const ColorScheme.light(primary: _teal),
        ),
        child: child!,
      ),
    );
    if (picked != null) setState(() => _deadline = picked);
  }

  Color _priorityColor(String p) {
    switch (p) {
      case 'High':
        return Colors.red.shade400;
      case 'Medium':
        return _amber;
      default:
        return Colors.green.shade500;
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottomPad = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      margin: const EdgeInsets.fromLTRB(12, 0, 12, 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      padding: EdgeInsets.fromLTRB(20, 8, 20, 20 + bottomPad),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: 16, top: 8),
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          Row(
            children: [
              const Expanded(
                child: Text(
                  'Create Production Split',
                  style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                      color: Colors.black87),
                ),
              ),
              Container(
                padding:
                const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: _tealLight,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '${widget.availableQty} available',
                  style: const TextStyle(
                      fontSize: 11,
                      color: _tealDark,
                      fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          const _SheetLabel('Select BOM'),
          const SizedBox(height: 6),
          _DropdownField(
            hint: 'Select BOM',
            value: _selectedBom,
            items: _bomOptions,
            onChanged: (v) => setState(() => _selectedBom = v),
          ),
          const SizedBox(height: 16),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const _SheetLabel('Planned Qty'),
                    const SizedBox(height: 6),
                    _QtyField(
                      controller: _qtyCtrl,
                      maxQty: widget.availableQty,
                      onChanged: (v) => setState(() => _qty = v),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const _SheetLabel('Priority'),
                    const SizedBox(height: 6),
                    _DropdownField(
                      hint: 'Priority',
                      value: _priority,
                      items: _priorityOptions,
                      itemColor: (item) => _priorityColor(item),
                      onChanged: (v) =>
                          setState(() => _priority = v ?? 'High'),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const _SheetLabel('Deadline'),
          const SizedBox(height: 6),
          GestureDetector(
            onTap: _pickDate,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
              decoration: BoxDecoration(
                color: const Color(0xFFF4F6F8),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.calendar_today_outlined,
                    size: 18,
                    color: _deadline != null ? _teal : Colors.grey,
                  ),
                  const SizedBox(width: 10),
                  Text(
                    _deadline == null
                        ? 'Select date'
                        : '${_deadline!.day}/${_deadline!.month}/${_deadline!.year}',
                    style: TextStyle(
                      fontSize: 14,
                      color:
                      _deadline == null ? Colors.grey : Colors.black87,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor:
                _canCreate ? const Color(0xFF2563EB) : Colors.grey[300],
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                elevation: 0,
              ),
              onPressed: _canCreate
                  ? () {
                final split = ProductSplit(
                  label: _selectedBom!,
                  qty: _qty,
                  priority: _priority,
                  deadline: _deadline,
                );
                Navigator.pop(context);
                widget.onCreated(split);
              }
                  : null,
              child: const Text(
                'Create Plan',
                style:
                TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────
// SHEET HELPER WIDGETS
// ─────────────────────────────────────────

class _SheetLabel extends StatelessWidget {
  final String text;
  const _SheetLabel(this.text);

  @override
  Widget build(BuildContext context) => Text(
    text,
    style: const TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        color: Colors.black87),
  );
}

class _DropdownField extends StatelessWidget {
  final String hint;
  final String? value;
  final List<String> items;
  final void Function(String?) onChanged;
  final Color Function(String)? itemColor;

  const _DropdownField({
    required this.hint,
    required this.value,
    required this.items,
    required this.onChanged,
    this.itemColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: const Color(0xFFF4F6F8),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          isExpanded: true,
          hint: Text(hint,
              style: const TextStyle(fontSize: 14, color: Colors.grey)),
          icon:
          const Icon(Icons.keyboard_arrow_down, color: Colors.grey),
          items: items
              .map((item) => DropdownMenuItem(
            value: item,
            child: Text(
              item,
              style: TextStyle(
                fontSize: 14,
                color: itemColor != null
                    ? itemColor!(item)
                    : Colors.black87,
                fontWeight: itemColor != null
                    ? FontWeight.w600
                    : FontWeight.normal,
              ),
            ),
          ))
              .toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }
}

class _QtyField extends StatelessWidget {
  final TextEditingController controller;
  final int maxQty;
  final void Function(int) onChanged;

  const _QtyField({
    required this.controller,
    required this.maxQty,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF4F6F8),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: TextField(
        controller: controller,
        keyboardType: TextInputType.number,
        decoration: const InputDecoration(
          hintText: '0',
          hintStyle: TextStyle(fontSize: 14, color: Colors.grey),
          prefixIcon: Icon(Icons.tag, size: 18, color: Colors.grey),
          border: InputBorder.none,
          contentPadding:
          EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        ),
        onChanged: (v) {
          int parsed = int.tryParse(v) ?? 0;
          if (parsed > maxQty) {
            parsed = maxQty;
            controller.value = TextEditingValue(
              text: '$parsed',
              selection:
              TextSelection.collapsed(offset: '$parsed'.length),
            );
          }
          onChanged(parsed);
        },
      ),
    );
  }
}

// ─────────────────────────────────────────
// CREATE JOB ORDER SCREEN
// ─────────────────────────────────────────

class CreateJobOrderScreen extends StatefulWidget {
  const CreateJobOrderScreen({super.key});
  @override
  State<CreateJobOrderScreen> createState() => _CreateJobOrderScreenState();
}

class _CreateJobOrderScreenState extends State<CreateJobOrderScreen> {
  final _customerCtrl = TextEditingController();
  final _refCtrl = TextEditingController();
  final List<_TempProduct> _products = [_TempProduct()];
  static int _counter = 3;

  @override
  void dispose() {
    _customerCtrl.dispose();
    _refCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: _teal,
        elevation: 0,
        systemOverlayStyle: const SystemUiOverlayStyle(
          statusBarColor: _teal,
          statusBarIconBrightness: Brightness.light,
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('New Job Order',
            style: TextStyle(
                color: Colors.white, fontWeight: FontWeight.w700)),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _label('Customer Details'),
          _field(_customerCtrl, 'Customer Name'),
          _field(_refCtrl, 'Order Reference (optional)'),
          const SizedBox(height: 8),
          _label('Products'),
          ...List.generate(
            _products.length,
                (i) => _ProductInputRow(
              product: _products[i],
              onDelete: _products.length > 1
                  ? () => setState(() => _products.removeAt(i))
                  : null,
            ),
          ),
          GestureDetector(
            onTap: () => setState(() => _products.add(_TempProduct())),
            child: Container(
              margin: const EdgeInsets.only(bottom: 16),
              padding: const EdgeInsets.symmetric(vertical: 10),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(9),
              ),
              alignment: Alignment.center,
              child: const Text('+ Add Product',
                  style: TextStyle(fontSize: 13, color: Colors.grey)),
            ),
          ),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: _teal,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
                elevation: 0,
              ),
              onPressed: _create,
              child: const Text('Create Job Order',
                  style:
                  TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _label(String t) => Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: Text(t.toUpperCase(),
        style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: Colors.grey,
            letterSpacing: 0.5)),
  );

  Widget _field(TextEditingController c, String hint) => Padding(
    padding: const EdgeInsets.only(bottom: 12),
    child: TextField(
      controller: c,
      decoration: InputDecoration(
        hintText: hint,
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(
            horizontal: 13, vertical: 12),
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(9),
            borderSide: BorderSide(color: Colors.grey.shade300)),
        enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(9),
            borderSide: BorderSide(color: Colors.grey.shade300)),
        focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(9),
            borderSide:
            const BorderSide(color: _teal, width: 1.5)),
      ),
    ),
  );

  void _create() {
    final name = _customerCtrl.text.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Customer name required')));
      return;
    }
    final prods =
    _products.where((p) => p.name.isNotEmpty && p.qty > 0).toList();
    if (prods.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content:
          Text('Add at least one product with quantity')));
      return;
    }
    _counter++;
    Navigator.pop(
      context,
      JobOrder(
        id: 'JO-${_counter.toString().padLeft(3, '0')}',
        customer: name,
        ref: _refCtrl.text.trim(),
        products: prods
            .map((p) => OrderProduct(name: p.name, qty: p.qty))
            .toList(),
      ),
    );
  }
}

class _TempProduct {
  String name = '';
  int qty = 0;
}

class _ProductInputRow extends StatelessWidget {
  final _TempProduct product;
  final VoidCallback? onDelete;
  const _ProductInputRow({required this.product, this.onDelete});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              decoration: _dec('Product Name'),
              onChanged: (v) => product.name = v,
            ),
          ),
          const SizedBox(width: 8),
          SizedBox(
            width: 80,
            child: TextField(
              keyboardType: TextInputType.number,
              decoration: _dec('Qty'),
              onChanged: (v) => product.qty = int.tryParse(v) ?? 0,
            ),
          ),
          if (onDelete != null)
            IconButton(
              icon: const Icon(Icons.close,
                  color: Colors.redAccent, size: 20),
              onPressed: onDelete,
              padding: EdgeInsets.zero,
              constraints:
              const BoxConstraints(minWidth: 32, minHeight: 32),
            )
          else
            const SizedBox(width: 32),
        ],
      ),
    );
  }

  InputDecoration _dec(String hint) => InputDecoration(
    hintText: hint,
    hintStyle: const TextStyle(fontSize: 13, color: Colors.grey),
    filled: true,
    fillColor: Colors.white,
    contentPadding:
    const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
    isDense: true,
    border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: Colors.grey.shade300)),
    enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: Colors.grey.shade300)),
    focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: _teal, width: 1.5)),
  );
}

// ─────────────────────────────────────────
// REUSABLE SMALL WIDGETS
// ─────────────────────────────────────────

class _StatusBadge extends StatelessWidget {
  final String status;
  final bool light;
  const _StatusBadge({required this.status, this.light = false});

  @override
  Widget build(BuildContext context) {
    final isActive = status == 'active';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
      decoration: BoxDecoration(
        color: light
            ? Colors.white24
            : isActive
            ? _tealLight
            : _amberLight,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        status,
        style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: light
                ? Colors.white
                : isActive
                ? _tealDark
                : _amber),
      ),
    );
  }
}

class _SummaryChip extends StatelessWidget {
  final String label, value;
  const _SummaryChip({required this.label, required this.value});

  @override
  Widget build(BuildContext context) => Expanded(
    child: Container(
      padding:
      const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        children: [
          Text(value,
              style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: _teal)),
          Text(label,
              style:
              const TextStyle(fontSize: 9, color: Colors.grey)),
        ],
      ),
    ),
  );
}

class _Banner extends StatelessWidget {
  final Color color, textColor;
  final String text;
  const _Banner(
      {required this.color,
        required this.textColor,
        required this.text});

  @override
  Widget build(BuildContext context) => Container(
    padding:
    const EdgeInsets.symmetric(horizontal: 13, vertical: 10),
    decoration: BoxDecoration(
        color: color, borderRadius: BorderRadius.circular(9)),
    child: Text(text, style: TextStyle(fontSize: 12, color: textColor)),
  );
}

// ─────────────────────────────────────────
// PRODUCTION PLANNING SCREEN (All Splits View)
// ─────────────────────────────────────────

class JobOrderSplitsScreen extends StatelessWidget {
  final List<JobOrder> orders;
  const JobOrderSplitsScreen({super.key, required this.orders});

  @override
  Widget build(BuildContext context) {
    final List<_SplitEntry> entries = [];
    for (final order in orders) {
      for (int i = 0; i < order.products.length; i++) {
        final plan = order.planning[i];
        if (!plan.done) continue;
        for (final split in plan.splits) {
          entries.add(_SplitEntry(
            order: order,
            productName: order.products[i].name,
            totalQty: order.products[i].qty,
            split: split,
          ));
        }
      }
    }

    final totalSplits = entries.length;
    final totalUnits = entries.fold(0, (a, e) => a + e.split.qty);
    final uniqueProducts =
        entries.map((e) => e.productName).toSet().length;

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: _teal,
        elevation: 0,
        systemOverlayStyle: const SystemUiOverlayStyle(
          statusBarColor: _teal,
          statusBarIconBrightness: Brightness.light,
        ),
        title: const Text(
          'Production Planning',
          style:
          TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
        ),
      ),
      body: entries.isEmpty
          ? _EmptyState()
          : Column(
        children: [
          Container(
            color: _teal.withValues(alpha: 0.08),
            padding: const EdgeInsets.symmetric(
                horizontal: 16, vertical: 10),
            child: Row(
              children: [
                _SummaryChip(
                    label: 'Splits', value: '$totalSplits'),
                const SizedBox(width: 8),
                _SummaryChip(
                    label: 'Total Units', value: '$totalUnits'),
                const SizedBox(width: 8),
                _SummaryChip(
                    label: 'Products', value: '$uniqueProducts'),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding:
              const EdgeInsets.fromLTRB(12, 12, 12, 30),
              itemCount: entries.length,
              itemBuilder: (ctx, i) =>
                  _ProdSplitCard(entry: entries[i]),
            ),
          ),
        ],
      ),
    );
  }
}

class _SplitEntry {
  final JobOrder order;
  final String productName;
  final int totalQty;
  final ProductSplit split;
  const _SplitEntry({
    required this.order,
    required this.productName,
    required this.totalQty,
    required this.split,
  });
}

class _ProdSplitCard extends StatelessWidget {
  final _SplitEntry entry;
  const _ProdSplitCard({required this.entry});

  Color _priorityColor(String p) {
    switch (p) {
      case 'High':
        return Colors.red.shade400;
      case 'Medium':
        return _amber;
      default:
        return Colors.green.shade500;
    }
  }

  @override
  Widget build(BuildContext context) {
    final pct = entry.totalQty > 0
        ? (entry.split.qty / entry.totalQty).clamp(0.0, 1.0)
        : 0.0;
    final deadlineStr = entry.split.deadline != null
        ? '${entry.split.deadline!.day}/${entry.split.deadline!.month}/${entry.split.deadline!.year}'
        : '—';
    final priorityColor = _priorityColor(entry.split.priority);

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 9, vertical: 4),
                decoration: BoxDecoration(
                  color: _tealLight,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.layers_outlined,
                        size: 12, color: _tealDark),
                    const SizedBox(width: 4),
                    Text(
                      entry.split.label,
                      style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: _tealDark),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: priorityColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  entry.split.priority,
                  style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: priorityColor),
                ),
              ),
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: _teal,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '${entry.split.qty} units',
                  style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: Colors.white),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            entry.productName,
            style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: Colors.black87),
          ),
          const SizedBox(height: 3),
          Row(
            children: [
              Expanded(
                child: Text(
                  '${entry.order.id}${entry.order.ref.isNotEmpty ? ' · ${entry.order.ref}' : ''} · ${entry.order.customer}',
                  style:
                  const TextStyle(fontSize: 11, color: Colors.grey),
                ),
              ),
              if (entry.split.deadline != null)
                Row(
                  children: [
                    const Icon(Icons.calendar_today_outlined,
                        size: 11, color: Colors.grey),
                    const SizedBox(width: 3),
                    Text(deadlineStr,
                        style: const TextStyle(
                            fontSize: 11, color: Colors.grey)),
                  ],
                ),
            ],
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: pct,
              backgroundColor: Colors.grey.shade200,
              valueColor: const AlwaysStoppedAnimation(_teal),
              minHeight: 5,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '${entry.split.qty} of ${entry.totalQty} total units (${(pct * 100).toStringAsFixed(0)}%)',
            style: const TextStyle(fontSize: 10, color: Colors.grey),
          ),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 72,
          height: 72,
          decoration: const BoxDecoration(
              color: _tealLight, shape: BoxShape.circle),
          alignment: Alignment.center,
          child: const Icon(Icons.event_note_outlined,
              size: 34, color: _teal),
        ),
        const SizedBox(height: 16),
        const Text(
          'No splits confirmed yet',
          style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: Colors.black87),
        ),
        const SizedBox(height: 6),
        const Text(
          'Plan products in Job Orders\nto see splits here',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 12, color: Colors.grey),
        ),
      ],
    ),
  );
}