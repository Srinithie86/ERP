import 'package:flutter/material.dart';
import 'app_theme.dart';
import 'shared_widgets.dart';
import 'models.dart';

// ─── Material Request ──────────────────────────────────────────────────────────
class MaterialRequestScreen extends StatelessWidget {
  const MaterialRequestScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context);
    final sw = mq.size.width;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(children: [
        Container(
          color: AppColors.surface,
          padding: EdgeInsets.all(sw * 0.05),
          child: Text('Material Requests', style: TextStyle(
            fontSize: sw * 0.05,
            fontWeight: FontWeight.w800,
            color: AppColors.textPrimary,
          )),
        ),
        Expanded(child: ListView.separated(
          padding: EdgeInsets.all(sw * 0.05),
          itemCount: SampleData.materialRequests.length,
          separatorBuilder: (_, __) => SizedBox(height: sw * 0.03),
          itemBuilder: (_, i) => _MRCard(
            mr: SampleData.materialRequests[i],
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => _MRDetailPage(mr: SampleData.materialRequests[i]),
              ),
            ),
          ),
        )),
        Container(
          color: AppColors.surface,
          padding: EdgeInsets.all(sw * 0.04),
          child: SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const _MRCreatePage()),
              ),
              icon: Icon(Icons.add, size: sw * 0.045),
              label: Text('New Material Request', style: TextStyle(fontSize: sw * 0.035)),
            ),
          ),
        ),
      ]),
    );
  }
}

// ─── MR Detail Page ────────────────────────────────────────────────────────────
class _MRDetailPage extends StatelessWidget {
  final MaterialRequest mr;
  const _MRDetailPage({required this.mr});

  @override
  Widget build(BuildContext context) {
    final sw = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('Material Request', style: TextStyle(fontSize: sw * 0.042)),
        backgroundColor: AppColors.surface,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          Padding(
            padding: EdgeInsets.only(right: sw * 0.03),
            child: StatusBadge(
              label: mr.status == 'approved' ? 'Approved' : 'Pending',
              status: mr.status == 'approved' ? 'completed' : 'pending',
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(sw * 0.05),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(mr.id, style: TextStyle(
            fontSize: sw * 0.055,
            fontWeight: FontWeight.w800,
            color: AppColors.textPrimary,
          )),
          SizedBox(height: sw * 0.01),
          Text(mr.jobRef, style: TextStyle(fontSize: sw * 0.035, color: AppColors.textSecondary)),
          SizedBox(height: sw * 0.05),
          AppCard(color: AppColors.background, child: Column(children: [
            InfoRow(label: 'Requested By', value: mr.requestedBy),
            InfoRow(label: 'Job Card', value: mr.jobRef),
            InfoRow(label: 'Date', value: '${mr.requestDate.day}/${mr.requestDate.month}/${mr.requestDate.year}'),
          ])),
          SizedBox(height: sw * 0.05),
          Text('Material Items', style: TextStyle(
            fontSize: sw * 0.042,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          )),
          SizedBox(height: sw * 0.03),
          ...mr.items.map((item) {
            final sufficient = item.available >= item.required;
            return Padding(
              padding: EdgeInsets.only(bottom: sw * 0.025),
              child: AppCard(
                color: sufficient ? AppColors.surface : AppColors.dangerLight,
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Row(children: [
                    Container(
                      width: sw * 0.09,
                      height: sw * 0.09,
                      decoration: BoxDecoration(
                        color: sufficient ? AppColors.successLight : AppColors.dangerLight,
                        borderRadius: BorderRadius.circular(sw * 0.02),
                      ),
                      child: Icon(
                        sufficient ? Icons.check_circle_outline : Icons.warning_amber_outlined,
                        color: sufficient ? AppColors.success : AppColors.danger,
                        size: sw * 0.05,
                      ),
                    ),
                    SizedBox(width: sw * 0.025),
                    Expanded(child: Text(item.name, style: TextStyle(
                      fontSize: sw * 0.035,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ))),
                    Text(item.uom, style: TextStyle(fontSize: sw * 0.03, color: AppColors.textSecondary)),
                  ]),
                  SizedBox(height: sw * 0.025),
                  Row(children: [
                    Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text('Required', style: TextStyle(fontSize: sw * 0.028, color: AppColors.textSecondary)),
                      Text('${item.required}', style: TextStyle(
                        fontSize: sw * 0.038,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary,
                      )),
                    ])),
                    Container(width: 1, height: sw * 0.075, color: AppColors.border),
                    Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.center, children: [
                      Text('Available', style: TextStyle(fontSize: sw * 0.028, color: AppColors.textSecondary)),
                      Text('${item.available}', style: TextStyle(
                        fontSize: sw * 0.038,
                        fontWeight: FontWeight.w800,
                        color: sufficient ? AppColors.success : AppColors.danger,
                      )),
                    ])),
                    Container(width: 1, height: sw * 0.075, color: AppColors.border),
                    Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                      Text('Gap', style: TextStyle(fontSize: sw * 0.028, color: AppColors.textSecondary)),
                      Text(
                        sufficient ? '—' : '${(item.required - item.available).toStringAsFixed(0)} short',
                        style: TextStyle(
                          fontSize: sw * 0.032,
                          fontWeight: FontWeight.w700,
                          color: sufficient ? AppColors.textHint : AppColors.danger,
                        ),
                      ),
                    ])),
                  ]),
                ]),
              ),
            );
          }),
          if (mr.status == 'pending') ...[
            SizedBox(height: sw * 0.05),
            Row(children: [
              Expanded(child: OutlinedButton(
                onPressed: () => Navigator.pop(context),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.danger,
                  side: const BorderSide(color: AppColors.danger),
                ),
                child: Text('Reject', style: TextStyle(fontSize: sw * 0.035)),
              )),
              SizedBox(width: sw * 0.03),
              Expanded(child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: Text('Approve & Issue', style: TextStyle(fontSize: sw * 0.032)),
              )),
            ]),
          ],
          SizedBox(height: sw * 0.05),
        ]),
      ),
    );
  }
}

// ─── MR Create Page ────────────────────────────────────────────────────────────
class _MRCreatePage extends StatelessWidget {
  const _MRCreatePage();

  @override
  Widget build(BuildContext context) {
    final sw = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('New Material Request', style: TextStyle(fontSize: sw * 0.042)),
        backgroundColor: AppColors.surface,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(sw * 0.05),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const AppDropdown(
            label: 'Job Card',
            items: ['JC-001 · Tomato Sauce 500ml', 'JC-002 · Tomato Sauce 500ml', 'JC-003 · Chilli Paste'],
            onChanged: _noop,
          ),
          SizedBox(height: sw * 0.035),
          const AppTextField(label: 'Requested By', hint: 'Your name', prefixIcon: Icons.person_outline),
          SizedBox(height: sw * 0.035),
          const AppTextField(label: 'Notes', hint: 'Any special instructions...', maxLines: 2),
          SizedBox(height: sw * 0.05),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Create & Auto-fetch Materials', style: TextStyle(fontSize: sw * 0.035)),
            ),
          ),
        ]),
      ),
    );
  }

  static void _noop(dynamic _) {}
}

class _MRCard extends StatelessWidget {
  final MaterialRequest mr;
  final VoidCallback onTap;
  const _MRCard({required this.mr, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final sw = MediaQuery.of(context).size.width;
    final hasShortage = mr.items.any((i) => i.available < i.required);

    return AppCard(
      onTap: onTap,
      color: hasShortage ? AppColors.dangerLight : AppColors.surface,
      child: Row(children: [
        Container(
          width: sw * 0.105,
          height: sw * 0.105,
          decoration: BoxDecoration(
            color: mr.status == 'approved' ? AppColors.successLight : AppColors.pendingLight,
            borderRadius: BorderRadius.circular(sw * 0.025),
          ),
          child: Icon(
            mr.status == 'approved' ? Icons.check_circle_outline : Icons.pending_outlined,
            color: mr.status == 'approved' ? AppColors.success : AppColors.pending,
            size: sw * 0.055,
          ),
        ),
        SizedBox(width: sw * 0.03),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('${mr.id} · ${mr.jobRef}', style: TextStyle(
            fontSize: sw * 0.035,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          )),
          Text('${mr.items.length} items · By ${mr.requestedBy}', style: TextStyle(
            fontSize: sw * 0.03,
            color: AppColors.textSecondary,
          )),
        ])),
        Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
          StatusBadge(
            label: mr.status == 'approved' ? 'Approved' : 'Pending',
            status: mr.status == 'approved' ? 'completed' : 'pending',
          ),
          if (hasShortage) ...[
            SizedBox(height: sw * 0.01),
            Container(
              padding: EdgeInsets.symmetric(horizontal: sw * 0.02, vertical: sw * 0.008),
              decoration: BoxDecoration(
                color: AppColors.dangerLight,
                borderRadius: BorderRadius.circular(sw * 0.015),
              ),
              child: Text('Stock Short', style: TextStyle(
                fontSize: sw * 0.028,
                fontWeight: FontWeight.w700,
                color: AppColors.danger,
              )),
            ),
          ],
        ]),
      ]),
    );
  }
}

// ─── Quality Control Screen ────────────────────────────────────────────────────
class QcScreen extends StatelessWidget {
  const QcScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final sw = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(children: [
        Container(
          color: AppColors.surface,
          padding: EdgeInsets.all(sw * 0.05),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('Quality Control', style: TextStyle(
              fontSize: sw * 0.05,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
            )),
            SizedBox(height: sw * 0.04),
            Row(children: [
              _qcStat('Pass Rate', '96%', AppColors.success, AppColors.successLight, sw),
              SizedBox(width: sw * 0.025),
              _qcStat('Inspected', '350', AppColors.primary, AppColors.primaryLight, sw),
              SizedBox(width: sw * 0.025),
              _qcStat('Rejected', '14', AppColors.danger, AppColors.dangerLight, sw),
            ]),
          ]),
        ),
        Expanded(child: ListView.separated(
          padding: EdgeInsets.all(sw * 0.05),
          itemCount: SampleData.qcRecords.length,
          separatorBuilder: (_, __) => SizedBox(height: sw * 0.03),
          itemBuilder: (_, i) => _QcCard(
            record: SampleData.qcRecords[i],
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => _QcDetailPage(rec: SampleData.qcRecords[i]),
              ),
            ),
          ),
        )),
        Container(
          color: AppColors.surface,
          padding: EdgeInsets.all(sw * 0.04),
          child: SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const _QcCreatePage()),
              ),
              icon: Icon(Icons.add, size: sw * 0.045),
              label: Text('New QC Inspection', style: TextStyle(fontSize: sw * 0.035)),
            ),
          ),
        ),
      ]),
    );
  }

  Widget _qcStat(String label, String val, Color color, Color bg, double sw) => Expanded(
    child: Container(
      padding: EdgeInsets.symmetric(vertical: sw * 0.025, horizontal: sw * 0.03),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(sw * 0.025)),
      child: Column(children: [
        Text(val, style: TextStyle(fontSize: sw * 0.05, fontWeight: FontWeight.w800, color: color)),
        Text(label, style: TextStyle(fontSize: sw * 0.028, color: color, fontWeight: FontWeight.w500), textAlign: TextAlign.center),
      ]),
    ),
  );
}

// ─── QC Detail Page ────────────────────────────────────────────────────────────
class _QcDetailPage extends StatelessWidget {
  final QcRecord rec;
  const _QcDetailPage({required this.rec});

  @override
  Widget build(BuildContext context) {
    final sw = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('QC Inspection', style: TextStyle(fontSize: sw * 0.042)),
        backgroundColor: AppColors.surface,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          Padding(
            padding: EdgeInsets.only(right: sw * 0.03),
            child: StatusBadge(
              label: rec.status == 'completed' ? 'Done' : 'Pending',
              status: rec.status == 'completed' ? 'completed' : 'pending',
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(sw * 0.05),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(rec.productName, style: TextStyle(
            fontSize: sw * 0.055,
            fontWeight: FontWeight.w800,
            color: AppColors.textPrimary,
          )),
          SizedBox(height: sw * 0.01),
          Text('${rec.id} · ${rec.jobRef}', style: TextStyle(
            fontSize: sw * 0.035,
            color: AppColors.textSecondary,
          )),
          SizedBox(height: sw * 0.05),
          if (rec.status == 'completed') ...[
            AppCard(color: AppColors.background, child: Column(children: [
              InfoRow(label: 'Inspector', value: rec.inspector),
              InfoRow(label: 'Total Inspected', value: '${rec.totalQty} units'),
              InfoRow(label: 'Passed', value: '${rec.passQty} units', valueColor: AppColors.success),
              InfoRow(label: 'Rejected', value: '${rec.failQty} units', valueColor: AppColors.danger),
              InfoRow(
                label: 'Pass Rate',
                value: '${((rec.passQty / rec.totalQty) * 100).toStringAsFixed(1)}%',
                valueColor: AppColors.success,
              ),
            ])),
            SizedBox(height: sw * 0.05),
            Text('QC Parameters', style: TextStyle(
              fontSize: sw * 0.042,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            )),
            SizedBox(height: sw * 0.03),
            _paramRow('Colour', 'Deep Red', 'pass', sw),
            _paramRow('Viscosity (cP)', '850', 'pass', sw),
            _paramRow('pH Level', '4.2', 'pass', sw),
            _paramRow('Moisture %', '78%', 'pass', sw),
            _paramRow('Microbial Count', '< 100 CFU', 'fail', sw),
          ],
          SizedBox(height: sw * 0.05),
        ]),
      ),
    );
  }

  Widget _paramRow(String param, String value, String result, double sw) => Padding(
    padding: EdgeInsets.only(bottom: sw * 0.02),
    child: AppCard(child: Row(children: [
      Expanded(child: Text(param, style: TextStyle(fontSize: sw * 0.032, color: AppColors.textSecondary))),
      Text(value, style: TextStyle(
        fontSize: sw * 0.032,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
      )),
      SizedBox(width: sw * 0.03),
      Icon(
        result == 'pass' ? Icons.check_circle : Icons.cancel,
        color: result == 'pass' ? AppColors.success : AppColors.danger,
        size: sw * 0.045,
      ),
    ])),
  );
}

// ─── QC Create Page ────────────────────────────────────────────────────────────
class _QcCreatePage extends StatelessWidget {
  const _QcCreatePage();

  @override
  Widget build(BuildContext context) {
    final sw = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('New QC Inspection', style: TextStyle(fontSize: sw * 0.042)),
        backgroundColor: AppColors.surface,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(sw * 0.05),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const AppTextField(label: 'Inspector Name', hint: 'QC Inspector', prefixIcon: Icons.person_outline),
          SizedBox(height: sw * 0.035),
          const Row(children: [
            Expanded(child: AppTextField(label: 'Total Qty', hint: '0', prefixIcon: Icons.numbers)),
            SizedBox(width: 12),
            Expanded(child: AppTextField(label: 'Pass Qty', hint: '0', prefixIcon: Icons.check_circle_outline)),
          ]),
          SizedBox(height: sw * 0.035),
          const AppTextField(label: 'Fail Qty', hint: '0', prefixIcon: Icons.cancel_outlined),
          SizedBox(height: sw * 0.035),
          const AppTextField(
            label: 'Rejection Reason',
            hint: 'e.g. colour deviation, viscosity low',
            maxLines: 2,
          ),
          SizedBox(height: sw * 0.05),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Submit QC Report', style: TextStyle(fontSize: sw * 0.035)),
            ),
          ),
        ]),
      ),
    );
  }
}

class _QcCard extends StatelessWidget {
  final QcRecord record;
  final VoidCallback onTap;
  const _QcCard({required this.record, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final sw = MediaQuery.of(context).size.width;
    final passRate = record.totalQty > 0 ? record.passQty / record.totalQty : 0.0;

    return AppCard(onTap: onTap, child: Column(children: [
      Row(children: [
        Container(
          width: sw * 0.105,
          height: sw * 0.105,
          decoration: BoxDecoration(
            color: record.status == 'completed' ? AppColors.successLight : AppColors.pendingLight,
            borderRadius: BorderRadius.circular(sw * 0.025),
          ),
          child: Icon(
            record.status == 'completed' ? Icons.verified_outlined : Icons.pending_outlined,
            color: record.status == 'completed' ? AppColors.success : AppColors.pending,
            size: sw * 0.055,
          ),
        ),
        SizedBox(width: sw * 0.03),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(record.productName, style: TextStyle(
            fontSize: sw * 0.035,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          )),
          Text('${record.id} · ${record.jobRef} · ${record.inspector}', style: TextStyle(
            fontSize: sw * 0.03,
            color: AppColors.textSecondary,
          )),
        ])),
        StatusBadge(
          label: record.status == 'completed' ? 'Done' : 'Pending',
          status: record.status == 'completed' ? 'completed' : 'pending',
        ),
      ]),
      if (record.status == 'completed') ...[
        SizedBox(height: sw * 0.03),
        const Divider(color: AppColors.border, height: 1),
        SizedBox(height: sw * 0.025),
        Row(children: [
          Expanded(child: Column(children: [
            Text('${record.passQty}', style: TextStyle(
              fontSize: sw * 0.04,
              fontWeight: FontWeight.w800,
              color: AppColors.success,
            )),
            Text('Passed', style: TextStyle(fontSize: sw * 0.028, color: AppColors.textSecondary)),
          ])),
          Container(width: 1, height: sw * 0.075, color: AppColors.border),
          Expanded(child: Column(children: [
            Text('${record.failQty}', style: TextStyle(
              fontSize: sw * 0.04,
              fontWeight: FontWeight.w800,
              color: AppColors.danger,
            )),
            Text('Rejected', style: TextStyle(fontSize: sw * 0.028, color: AppColors.textSecondary)),
          ])),
          Container(width: 1, height: sw * 0.075, color: AppColors.border),
          Expanded(child: Column(children: [
            Text('${(passRate * 100).toStringAsFixed(0)}%', style: TextStyle(
              fontSize: sw * 0.04,
              fontWeight: FontWeight.w800,
              color: AppColors.primary,
            )),
            Text('Pass Rate', style: TextStyle(fontSize: sw * 0.028, color: AppColors.textSecondary)),
          ])),
        ]),
      ],
    ]));
  }
}