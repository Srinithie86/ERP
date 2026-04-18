import 'package:flutter/material.dart';
import 'app_theme.dart';
import 'shared_widgets.dart';
import 'models.dart';

// ─── Production Planning ───────────────────────────────────────────────────────
class ProductionPlanningScreen extends StatefulWidget {
  final List<JobOrder> orders;
  const ProductionPlanningScreen({super.key, required this.orders});

  @override
  State<ProductionPlanningScreen> createState() => _ProdPlanState();
}

class _ProdPlanState extends State<ProductionPlanningScreen> {
  List<_ProductEntry> get _entries {
    final list = <_ProductEntry>[];
    for (final order in widget.orders) {
      for (int i = 0; i < order.products.length; i++) {
        list.add(_ProductEntry(
          order: order,
          product: order.products[i],
          plan: order.planning[i],
          productIndex: i,
        ));
      }
    }
    return list;
  }

  int get _plannedCount =>
      _entries.where((e) => e.plan.done).length;
  int get _pendingCount =>
      _entries.where((e) => !e.plan.done && e.plan.splits.isEmpty).length;
  int get _inProgressCount =>
      _entries.where((e) => !e.plan.done && e.plan.splits.isNotEmpty).length;

  @override
  Widget build(BuildContext context) {
    final sw = MediaQuery.of(context).size.width;
    final entries = _entries;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(children: [
        // ── Header ──
        Container(
          color: AppColors.surface,
          padding: EdgeInsets.all(sw * 0.05),
          child: Text(
            'Production Planning',
            style: TextStyle(
              fontSize: sw * 0.05,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
            ),
          ),
        ),

        // ── Body ──
        Expanded(
          child: SingleChildScrollView(
            padding: EdgeInsets.all(sw * 0.05),
            child: Column(children: [
              _summaryRow(sw),
              SizedBox(height: sw * 0.05),
              ...entries.map((entry) => Padding(
                padding: EdgeInsets.only(bottom: sw * 0.03),
                child: _ProductPlanCard(
                  entry: entry,
                  onTap: () async {
                    await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ProductPlanningScreen(
                          order: entry.order,
                          initialProdIdx: entry.productIndex,
                          onDone: () => setState(() {}),
                        ),
                      ),
                    );
                    setState(() {});
                  },
                ),
              )),
            ]),
          ),
        ),

        // ── Bottom button ──
        Container(
          color: AppColors.surface,
          padding: EdgeInsets.all(sw * 0.04),
          child: const SizedBox(
            width: double.infinity,
          ),
        ),
      ]),
    );
  }

  Widget _summaryRow(double sw) => Row(children: [
    _miniStat('Planned', '$_plannedCount', AppColors.primary,
        AppColors.primaryLight, sw),
    SizedBox(width: sw * 0.025),
    _miniStat('In Progress', '$_inProgressCount', AppColors.warning,
        AppColors.warningLight, sw),
    SizedBox(width: sw * 0.025),
    _miniStat('Pending', '$_pendingCount', AppColors.success,
        AppColors.successLight, sw),
  ]);

  Widget _miniStat(
      String label, String val, Color color, Color bg, double sw) =>
      Expanded(
        child: Container(
          padding: EdgeInsets.all(sw * 0.03),
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(sw * 0.025),
          ),
          child: Column(children: [
            Text(val,
                style: TextStyle(
                    fontSize: sw * 0.055,
                    fontWeight: FontWeight.w800,
                    color: color)),
            Text(
              label,
              style: TextStyle(
                  fontSize: sw * 0.028,
                  color: color,
                  fontWeight: FontWeight.w500),
              textAlign: TextAlign.center,
            ),
          ]),
        ),
      );
}

// ─── Data holder ──────────────────────────────────────────────────────────────
class _ProductEntry {
  final JobOrder order;
  final OrderProduct product;
  final ProductPlan plan;
  final int productIndex;

  const _ProductEntry({
    required this.order,
    required this.product,
    required this.plan,
    required this.productIndex,
  });
}

// ─── Product Plan Card ────────────────────────────────────────────────────────
class _ProductPlanCard extends StatelessWidget {
  final _ProductEntry entry;
  final VoidCallback onTap;

  const _ProductPlanCard({required this.entry, required this.onTap});

  String get _statusStr {
    if (entry.plan.done) return 'completed';
    if (entry.plan.splits.isNotEmpty) return 'inprogress';
    return 'pending';
  }

  String get _statusLabel {
    if (entry.plan.done) return 'Planned';
    if (entry.plan.splits.isNotEmpty) return 'In Progress';
    return 'Pending';
  }

  @override
  Widget build(BuildContext context) {
    final sw = MediaQuery.of(context).size.width;
    final pct = entry.product.qty > 0
        ? (entry.plan.planned / entry.product.qty).clamp(0.0, 1.0)
        : 0.0;

    final priority = entry.plan.splits.isNotEmpty
        ? entry.plan.splits.first.priority
        : 'High';

    final deadline = entry.plan.splits.isNotEmpty
        ? entry.plan.splits.first.deadline
        : null;

    final priorityColor = priority == 'High'
        ? AppColors.danger
        : priority == 'Medium'
        ? AppColors.warning
        : AppColors.success;

    final priorityBg = priority == 'High'
        ? AppColors.dangerLight
        : priority == 'Medium'
        ? AppColors.warningLight
        : AppColors.successLight;

    return AppCard(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Top row: priority badge + status badge ──
          Row(children: [
            Container(
              padding: EdgeInsets.symmetric(
                  horizontal: sw * 0.02, vertical: sw * 0.01),
              decoration: BoxDecoration(
                color: priorityBg,
                borderRadius: BorderRadius.circular(sw * 0.015),
              ),
              child: Text(
                priority,
                style: TextStyle(
                  fontSize: sw * 0.028,
                  fontWeight: FontWeight.w700,
                  color: priorityColor,
                ),
              ),
            ),
            const Spacer(),
            StatusBadge(label: _statusLabel, status: _statusStr),
          ]),
          SizedBox(height: sw * 0.025),

          // ── Product name ──
          Row(children: [
            Container(
              width: 9,
              height: 9,
              decoration: BoxDecoration(
                color: entry.plan.done
                    ? AppColors.primary
                    : Colors.grey.shade400,
                shape: BoxShape.circle,
              ),
            ),
            SizedBox(width: sw * 0.02),
            Expanded(
              child: Text(
                entry.product.name,
                style: TextStyle(
                  fontSize: sw * 0.045,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
          ]),
          SizedBox(height: sw * 0.01),

          // ── Order + qty info ──
          Row(children: [
            Icon(Icons.inventory_2_outlined,
                size: sw * 0.032, color: AppColors.textSecondary),
            SizedBox(width: sw * 0.01),
            Text(
              'Qty: ',
              style: TextStyle(
                  fontSize: sw * 0.03, color: AppColors.textSecondary),
            ),
            Text(
              '${entry.product.qty}',
              style: TextStyle(
                fontSize: sw * 0.03,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            const Spacer(),
            Text(
              '${entry.order.id}${entry.order.ref.isNotEmpty ? ' · ${entry.order.ref}' : ''}',
              style: TextStyle(
                  fontSize: sw * 0.028, color: AppColors.textSecondary),
            ),
          ]),
          SizedBox(height: sw * 0.025),

          // ── Deadline row ──
          Row(children: [
            Icon(Icons.calendar_today_outlined,
                size: sw * 0.032, color: AppColors.textSecondary),
            SizedBox(width: sw * 0.01),
            Text(
              deadline != null
                  ? 'Due: ${deadline.day}/${deadline.month}/${deadline.year}'
                  : 'No deadline set',
              style: TextStyle(
                fontSize: sw * 0.03,
                color: AppColors.textSecondary,
              ),
            ),
            const Spacer(),
            Text(
              '${entry.plan.planned}/${entry.product.qty} units',
              style: TextStyle(
                fontSize: sw * 0.03,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
          ]),
          SizedBox(height: sw * 0.02),

          // ── Progress bar ──
          ProgressBar(
            value: pct,
            color: entry.plan.done
                ? AppColors.success
                : AppColors.primary,
          ),

          // ── Splits count ──
          if (entry.plan.splits.isNotEmpty) ...[
            SizedBox(height: sw * 0.015),
            Text(
              '${entry.plan.splits.length} split${entry.plan.splits.length > 1 ? 's' : ''} assigned',
              style: TextStyle(
                  fontSize: sw * 0.028, color: AppColors.primary),
            ),
          ],
        ],
      ),
    );
  }
}

// ─── Product Planning Detail Screen ──────────────────────────────────────────
class ProductPlanningScreen extends StatelessWidget {
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
  Widget build(BuildContext context) {
    final sw = MediaQuery.of(context).size.width;
    final product = order.products[initialProdIdx];
    final plan = order.planning[initialProdIdx];
    final pct = product.qty > 0
        ? (plan.planned / product.qty).clamp(0.0, 1.0)
        : 0.0;

    final priority =
    plan.splits.isNotEmpty ? plan.splits.first.priority : 'High';
    final deadline =
    plan.splits.isNotEmpty ? plan.splits.first.deadline : null;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('Product Planning', style: TextStyle(fontSize: sw * 0.042)),
        backgroundColor: AppColors.surface,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          Padding(
            padding: EdgeInsets.only(right: sw * 0.03),
            child: Center(
              child: StatusBadge(
                label: plan.done
                    ? 'Planned'
                    : plan.splits.isNotEmpty
                    ? 'In Progress'
                    : 'Pending',
                status: plan.done
                    ? 'completed'
                    : plan.splits.isNotEmpty
                    ? 'inprogress'
                    : 'pending',
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(sw * 0.05),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          // Product name
          Text(
            product.name,
            style: TextStyle(
              fontSize: sw * 0.055,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: sw * 0.01),
          Text(
            '${order.id} · ${order.ref}',
            style:
            TextStyle(fontSize: sw * 0.035, color: AppColors.textSecondary),
          ),
          SizedBox(height: sw * 0.05),

          // Info card
          AppCard(
            color: AppColors.background,
            child: Column(children: [
              InfoRow(label: 'Order ID', value: order.id),
              InfoRow(label: 'Reference', value: order.ref),
              InfoRow(
                label: 'Priority',
                value: priority,
                valueColor: priority == 'High'
                    ? AppColors.danger
                    : priority == 'Medium'
                    ? AppColors.warning
                    : AppColors.success,
              ),
              InfoRow(label: 'Total Qty', value: '${product.qty} units'),
              InfoRow(label: 'Planned', value: '${plan.planned} units'),
              InfoRow(
                label: 'Deadline',
                value: deadline != null
                    ? '${deadline.day}/${deadline.month}/${deadline.year}'
                    : 'Not set',
              ),
            ]),
          ),
          SizedBox(height: sw * 0.05),

          // Progress
          Text(
            'Progress',
            style: TextStyle(
              fontSize: sw * 0.038,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: sw * 0.02),
          ProgressBar(
            value: pct,
            color: plan.done ? AppColors.success : AppColors.primary,
          ),
          SizedBox(height: sw * 0.01),
          Text(
            '${plan.planned} / ${product.qty} units · ${(pct * 100).toStringAsFixed(0)}%',
            style:
            TextStyle(fontSize: sw * 0.03, color: AppColors.textSecondary),
          ),

          // Splits
          if (plan.splits.isNotEmpty) ...[
            SizedBox(height: sw * 0.05),
            Text(
              'Splits (${plan.splits.length})',
              style: TextStyle(
                fontSize: sw * 0.038,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            SizedBox(height: sw * 0.02),
            ...plan.splits.asMap().entries.map((e) {
              final split = e.value;
              return Padding(
                padding: EdgeInsets.only(bottom: sw * 0.02),
                child: AppCard(
                  child: Row(children: [
                    Container(
                      width: sw * 0.08,
                      height: sw * 0.08,
                      decoration: BoxDecoration(
                        color: AppColors.primaryLight,
                        borderRadius: BorderRadius.circular(sw * 0.02),
                      ),
                      child: Center(
                        child: Text(
                          '${e.key + 1}',
                          style: TextStyle(
                            fontSize: sw * 0.035,
                            fontWeight: FontWeight.w700,
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: sw * 0.03),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Priority: ${split.priority}',
                            style: TextStyle(
                              fontSize: sw * 0.032,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          if (split.deadline != null)
                            Text(
                              'Due: ${split.deadline!.day}/${split.deadline!.month}/${split.deadline!.year}',
                              style: TextStyle(
                                fontSize: sw * 0.03,
                                color: AppColors.textSecondary,
                              ),
                            ),
                        ],
                      ),
                    ),
                  ]),
                ),
              );
            }),
          ],

          SizedBox(height: sw * 0.05),
          Row(children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () => Navigator.pop(context),
                icon: Icon(Icons.arrow_back, size: sw * 0.04),
                label:
                Text('Back', style: TextStyle(fontSize: sw * 0.035)),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.primary,
                  side: const BorderSide(color: AppColors.primary),
                ),
              ),
            ),
            SizedBox(width: sw * 0.03),
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () {
                  onDone();
                  Navigator.pop(context);
                },
                icon: Icon(Icons.check, size: sw * 0.04),
                label: Text('Mark Done',
                    style: TextStyle(fontSize: sw * 0.035)),
              ),
            ),
          ]),
          SizedBox(height: sw * 0.05),
        ]),
      ),
    );
  }
}

// ─── Plan Detail Page ──────────────────────────────────────────────────────────
class PlanDetailPage extends StatelessWidget {
  final ProductionPlan plan;
  const PlanDetailPage({super.key, required this.plan});

  @override
  Widget build(BuildContext context) {
    final sw = MediaQuery.of(context).size.width;
    final pct =
    plan.plannedQty > 0 ? plan.completedQty / plan.plannedQty : 0.0;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('Production Plan',
            style: TextStyle(fontSize: sw * 0.042)),
        backgroundColor: AppColors.surface,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          Padding(
            padding: EdgeInsets.only(right: sw * 0.03),
            child: Center(
                child: StatusBadge(
                  label: _statusLabel(plan.status),
                  status: plan.status,
                )),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(sw * 0.05),
        child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(plan.productName,
                  style: TextStyle(
                    fontSize: sw * 0.055,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                  )),
              SizedBox(height: sw * 0.01),
              Text(plan.id,
                  style: TextStyle(
                      fontSize: sw * 0.035,
                      color: AppColors.textSecondary)),
              SizedBox(height: sw * 0.05),
              AppCard(
                  color: AppColors.background,
                  child: Column(children: [
                    InfoRow(label: 'BOM Reference', value: plan.bomRef),
                    InfoRow(
                      label: 'Priority',
                      value: plan.priority,
                      valueColor: plan.priority == 'High'
                          ? AppColors.danger
                          : AppColors.warning,
                    ),
                    InfoRow(
                        label: 'Planned Qty',
                        value: '${plan.plannedQty} units'),
                    InfoRow(
                        label: 'Completed',
                        value: '${plan.completedQty} units'),
                    InfoRow(
                        label: 'Deadline',
                        value:
                        '${plan.deadline.day}/${plan.deadline.month}/${plan.deadline.year}'),
                  ])),
              SizedBox(height: sw * 0.05),
              Text('Progress',
                  style: TextStyle(
                    fontSize: sw * 0.038,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  )),
              SizedBox(height: sw * 0.02),
              ProgressBar(value: pct, color: AppColors.primary),
              SizedBox(height: sw * 0.01),
              Text(
                '${plan.completedQty} / ${plan.plannedQty} units · ${(pct * 100).toStringAsFixed(0)}%',
                style: TextStyle(
                    fontSize: sw * 0.03, color: AppColors.textSecondary),
              ),
              SizedBox(height: sw * 0.05),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {},
                  icon: Icon(Icons.assignment_outlined, size: sw * 0.04),
                  label: Text('Generate Job Cards',
                      style: TextStyle(fontSize: sw * 0.035)),
                ),
              ),
              SizedBox(height: sw * 0.05),
            ]),
      ),
    );
  }

  String _statusLabel(String s) => s == 'inprogress'
      ? 'In Progress'
      : s == 'pending'
      ? 'Pending'
      : 'Completed';
}

// ─── Plan Create Page ──────────────────────────────────────────────────────────
class PlanCreatePage extends StatelessWidget {
  const PlanCreatePage({super.key});

  @override
  Widget build(BuildContext context) {
    final sw = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('New Production Plan',
            style: TextStyle(fontSize: sw * 0.042)),
        backgroundColor: AppColors.surface,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(sw * 0.05),
        child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const AppDropdown(
                label: 'Select BOM',
                items: [
                  'BOM-001 · Solar Panel 400W Mono',
                  'BOM-002 · Solar Street Light 60W',
                  'BOM-003 · Solar Water Pump 1HP',
                ],
                onChanged: _noop,
              ),
              SizedBox(height: sw * 0.035),
              const Row(children: [
                Expanded(
                    child: AppTextField(
                        label: 'Planned Qty',
                        hint: '0',
                        prefixIcon: Icons.numbers)),
                SizedBox(width: 12),
                Expanded(
                    child: AppDropdown(
                      label: 'Priority',
                      value: 'High',
                      items: ['High', 'Medium', 'Low'],
                      onChanged: _noop,
                    )),
              ]),
              SizedBox(height: sw * 0.035),
              const AppTextField(
                label: 'Deadline',
                hint: 'Select date',
                prefixIcon: Icons.calendar_today_outlined,
                readOnly: true,
              ),
              SizedBox(height: sw * 0.05),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text('Create Plan',
                      style: TextStyle(fontSize: sw * 0.035)),
                ),
              ),
            ]),
      ),
    );
  }

  static void _noop(dynamic _) {}
}

// ─── Job Card Screen ───────────────────────────────────────────────────────────
class JobCardScreen extends StatelessWidget {
  const JobCardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final sw = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(children: [
        Container(
          color: AppColors.surface,
          padding: EdgeInsets.all(sw * 0.05),
          child: Text('Job Cards',
              style: TextStyle(
                fontSize: sw * 0.05,
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary,
              )),
        ),
        Expanded(
            child: ListView.separated(
              padding: EdgeInsets.all(sw * 0.05),
              itemCount: SampleData.jobCards.length,
              separatorBuilder: (_, __) => SizedBox(height: sw * 0.03),
              itemBuilder: (_, i) => _JobCardTile(
                job: SampleData.jobCards[i],
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) =>
                        JobDetailPage(job: SampleData.jobCards[i]),
                  ),
                ),
              ),
            )),
      ]),
    );
  }
}

// ─── Job Detail Page ───────────────────────────────────────────────────────────
class JobDetailPage extends StatelessWidget {
  final JobCard job;
  const JobDetailPage({super.key, required this.job});

  @override
  Widget build(BuildContext context) {
    final sw = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('Job Card', style: TextStyle(fontSize: sw * 0.042)),
        backgroundColor: AppColors.surface,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          Padding(
            padding: EdgeInsets.only(right: sw * 0.03),
            child: Center(
                child: StatusBadge(
                  label: job.status == 'inprogress' ? 'In Progress' : 'Pending',
                  status: job.status,
                )),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(sw * 0.05),
        child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(job.productName,
                  style: TextStyle(
                    fontSize: sw * 0.055,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                  )),
              SizedBox(height: sw * 0.01),
              Text(job.id,
                  style: TextStyle(
                      fontSize: sw * 0.035,
                      color: AppColors.textSecondary)),
              SizedBox(height: sw * 0.05),
              AppCard(
                  color: AppColors.background,
                  child: Column(children: [
                    InfoRow(label: 'Plan Reference', value: job.planRef),
                    InfoRow(label: 'Quantity', value: '${job.qty} units'),
                    InfoRow(label: 'Assigned To', value: job.assignedTo),
                    InfoRow(label: 'Machine', value: job.machine),
                    InfoRow(
                        label: 'Start Date',
                        value:
                        '${job.startDate.day}/${job.startDate.month}/${job.startDate.year}'),
                    InfoRow(
                        label: 'End Date',
                        value:
                        '${job.endDate.day}/${job.endDate.month}/${job.endDate.year}'),
                  ])),
              SizedBox(height: sw * 0.05),
              Text('Operations',
                  style: TextStyle(
                    fontSize: sw * 0.042,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  )),
              SizedBox(height: sw * 0.03),
              _opRow('1', 'Washing & Sorting', 'completed',
                  job.assignedTo, sw),
              _opRow('2', 'Cooking / Processing', job.status,
                  job.machine, sw),
              _opRow('3', 'Filling & Sealing', 'pending', '—', sw),
              _opRow('4', 'Labelling & Packing', 'pending', '—', sw),
              SizedBox(height: sw * 0.05),
              Row(children: [
                Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {},
                      icon: Icon(Icons.list_alt_outlined, size: sw * 0.04),
                      label: Text('Material Request',
                          style: TextStyle(fontSize: sw * 0.03)),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.primary,
                        side: const BorderSide(color: AppColors.primary),
                      ),
                    )),
                SizedBox(width: sw * 0.03),
                Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {},
                      icon: Icon(Icons.play_circle_outline, size: sw * 0.04),
                      label: Text('Update Status',
                          style: TextStyle(fontSize: sw * 0.03)),
                    )),
              ]),
              SizedBox(height: sw * 0.05),
            ]),
      ),
    );
  }

  Widget _opRow(String num, String name, String status,
      String resource, double sw) =>
      Padding(
        padding: EdgeInsets.only(bottom: sw * 0.02),
        child: AppCard(
            child: Row(children: [
              Container(
                width: sw * 0.07,
                height: sw * 0.07,
                decoration: BoxDecoration(
                  color: status == 'completed'
                      ? AppColors.successLight
                      : status == 'inprogress'
                      ? AppColors.inProgressLight
                      : AppColors.border,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: status == 'completed'
                      ? Icon(Icons.check,
                      size: sw * 0.035, color: AppColors.success)
                      : Text(num,
                      style: TextStyle(
                        fontSize: sw * 0.03,
                        fontWeight: FontWeight.w700,
                        color: status == 'inprogress'
                            ? AppColors.inProgress
                            : AppColors.textSecondary,
                      )),
                ),
              ),
              SizedBox(width: sw * 0.03),
              Expanded(
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(name,
                            style: TextStyle(
                              fontSize: sw * 0.032,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary,
                            )),
                        Text(resource,
                            style: TextStyle(
                                fontSize: sw * 0.03,
                                color: AppColors.textSecondary)),
                      ])),
              StatusBadge(
                label: status == 'completed'
                    ? 'Done'
                    : status == 'inprogress'
                    ? 'Active'
                    : 'Pending',
                status: status == 'completed' ? 'completed' : status,
              ),
            ])),
      );
}

class _JobCardTile extends StatelessWidget {
  final JobCard job;
  final VoidCallback onTap;
  const _JobCardTile({required this.job, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final sw = MediaQuery.of(context).size.width;

    return AppCard(
        onTap: onTap,
        child: Column(children: [
          Row(children: [
            Container(
              width: sw * 0.105,
              height: sw * 0.105,
              decoration: BoxDecoration(
                color: AppColors.inProgressLight,
                borderRadius: BorderRadius.circular(sw * 0.025),
              ),
              child: Icon(Icons.assignment_outlined,
                  color: AppColors.inProgress, size: sw * 0.055),
            ),
            SizedBox(width: sw * 0.03),
            Expanded(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(job.productName,
                          style: TextStyle(
                            fontSize: sw * 0.035,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                          )),
                      Text('${job.id} · ${job.planRef}',
                          style: TextStyle(
                            fontSize: sw * 0.03,
                            color: AppColors.textSecondary,
                          )),
                    ])),
            StatusBadge(
              label:
              job.status == 'inprogress' ? 'In Progress' : 'Pending',
              status: job.status,
            ),
          ]),
          SizedBox(height: sw * 0.03),
          const Divider(color: AppColors.border, height: 1),
          SizedBox(height: sw * 0.025),
          Row(children: [
            Icon(Icons.person_outline,
                size: sw * 0.035, color: AppColors.textSecondary),
            SizedBox(width: sw * 0.01),
            Expanded(
                child: Text(job.assignedTo,
                    style: TextStyle(
                      fontSize: sw * 0.03,
                      color: AppColors.textSecondary,
                    ))),
            Icon(Icons.settings_outlined,
                size: sw * 0.035, color: AppColors.textSecondary),
            SizedBox(width: sw * 0.01),
            Text(job.machine,
                style: TextStyle(
                    fontSize: sw * 0.03,
                    color: AppColors.textSecondary)),
            SizedBox(width: sw * 0.03),
            Text('${job.qty} units',
                style: TextStyle(
                  fontSize: sw * 0.03,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                )),
          ]),
        ]));
  }
}