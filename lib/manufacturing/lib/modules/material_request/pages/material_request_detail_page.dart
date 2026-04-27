import 'package:flutter/material.dart';
import '../../../core/app_theme.dart';
import '../../../core/shared_widgets.dart';
import '../material_request_model.dart';
import '../../job_card/job_card_model.dart';
import '../widgets/material_request_widgets.dart';

class MRDetailPage extends StatelessWidget {
  final MaterialRequest mr;
  const MRDetailPage({super.key, required this.mr});

  bool get _isSteelFrame => mr.jobRef == 'JC-004';

  @override
  Widget build(BuildContext context) {
    final sw = MediaQuery.of(context).size.width;
    final spares = sparesFor(mr.jobRef);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: buildMRAppBar(
        title: 'Intent Request Detail',
        showBack: true,
        context: context,
        actions: [
          Padding(
            padding: EdgeInsets.only(right: sw * 0.03),
            child: Center(
              child: MRStatusBadge(
                label: mr.status == 'approved' ? 'Approved' : 'Pending',
                status: mr.status == 'approved' ? 'completed' : 'pending',
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(sw * 0.05),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          if (_isSteelFrame)
            Container(
              margin: EdgeInsets.only(bottom: sw * 0.04),
              padding: EdgeInsets.all(sw * 0.04),
              decoration: BoxDecoration(
                color: const Color(0xFFE0F2F1),
                borderRadius: BorderRadius.circular(sw * 0.03),
                border: Border.all(color: mrTeal.withOpacity(0.3)),
              ),
              child: Row(children: [
                Container(
                  padding: EdgeInsets.all(sw * 0.025),
                  decoration: BoxDecoration(
                    color: mrTeal.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(sw * 0.02),
                  ),
                  child: Icon(Icons.architecture,
                      color: mrTeal, size: sw * 0.05),
                ),
                SizedBox(width: sw * 0.03),
                Expanded(
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Steel Frame Structure',
                            style: TextStyle(
                                fontSize: sw * 0.035,
                                fontWeight: FontWeight.w700,
                                color: mrTeal)),
                        Text('JC-004 · Fabrication Job',
                            style: TextStyle(
                                fontSize: sw * 0.028,
                                color: AppColors.textSecondary)),
                      ]),
                ),
              ]),
            ),
          Text(mr.id,
              style: TextStyle(
                  fontSize: sw * 0.055,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary)),
          SizedBox(height: sw * 0.01),
          Text(mr.jobRef,
              style: TextStyle(
                  fontSize: sw * 0.035, color: AppColors.textSecondary)),
          SizedBox(height: sw * 0.05),
          AppCard(
            color: AppColors.background,
            child: Column(children: [
              InfoRow(label: 'Requested By', value: mr.requestedBy),
              InfoRow(label: 'Job Card', value: mr.jobRef),
              InfoRow(
                  label: 'Date',
                  value:
                      '${mr.requestDate.day}/${mr.requestDate.month}/${mr.requestDate.year}'),
            ]),
          ),
          SizedBox(height: sw * 0.04),
          MRSummaryStrip(spares: spares, sw: sw),
          SizedBox(height: sw * 0.03),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(sw * 0.025),
              boxShadow: [
                BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 8,
                    offset: const Offset(0, 2)),
              ],
            ),
            child: Column(children: [
              Container(
                padding: EdgeInsets.symmetric(
                    horizontal: sw * 0.04, vertical: sw * 0.025),
                decoration: const BoxDecoration(
                  color: Color(0xFFF5F5F5),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(12),
                    topRight: Radius.circular(12),
                  ),
                ),
                child: Row(children: [
                  Expanded(
                    flex: 5,
                    child: Text('COMPONENT',
                        style: TextStyle(
                            fontSize: sw * 0.026,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textSecondary,
                            letterSpacing: 0.4)),
                  ),
                  SizedBox(
                    width: sw * 0.22,
                    child: Text('REQUIRED',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            fontSize: sw * 0.026,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textSecondary,
                            letterSpacing: 0.4)),
                  ),
                ]),
              ),
              ...spares.asMap().entries.map((entry) {
                final idx = entry.key;
                final s = entry.value;
                final isLast = idx == spares.length - 1;
                return Container(
                  padding: EdgeInsets.symmetric(
                      horizontal: sw * 0.04, vertical: sw * 0.03),
                  decoration: BoxDecoration(
                    color: idx % 2 == 0 ? Colors.white : const Color(0xFFFAFAFA),
                    borderRadius: isLast
                        ? const BorderRadius.only(
                            bottomLeft: Radius.circular(12),
                            bottomRight: Radius.circular(12),
                          )
                        : null,
                    border: isLast
                        ? null
                        : const Border(
                            bottom: BorderSide(
                                color: Color(0xFFF0F0F0), width: 0.8)),
                  ),
                  child: Row(children: [
                    Expanded(
                      flex: 5,
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(children: [
                              Icon(Icons.circle_outlined,
                                  size: sw * 0.033, color: mrTeal),
                              SizedBox(width: sw * 0.01),
                              Expanded(
                                child: Text(s.name,
                                    style: TextStyle(
                                        fontSize: sw * 0.034,
                                        fontWeight: FontWeight.w600,
                                        color: AppColors.textPrimary)),
                              ),
                            ]),
                            Padding(
                              padding: EdgeInsets.only(left: sw * 0.043),
                              child: Text(s.partNo,
                                  style: TextStyle(
                                      fontSize: sw * 0.032,
                                      color: AppColors.textSecondary)),
                            ),
                          ]),
                    ),
                    SizedBox(
                      width: sw * 0.24,
                      child: Text(
                        '${s.required} ${s.uom}',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            fontSize: sw * 0.034,
                            fontWeight: FontWeight.w800,
                            color: mrTeal),
                      ),
                    ),
                  ]),
                );
              }),
            ]),
          ),
          SizedBox(height: sw * 0.05),
        ]),
      ),
    );
  }
}
