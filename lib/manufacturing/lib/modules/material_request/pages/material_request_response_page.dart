import 'package:flutter/material.dart';
import '../../../core/app_theme.dart';
import '../material_request_model.dart';
import '../../job_card/job_card_model.dart';
import '../widgets/material_request_widgets.dart';

class MRResponseDetailPage extends StatelessWidget {
  final MaterialRequest mr;
  const MRResponseDetailPage({super.key, required this.mr});

  bool get _isSteelFrame => mr.jobRef == 'JC-004';

  @override
  Widget build(BuildContext context) {
    final sw = MediaQuery.of(context).size.width;
    final spares = sparesFor(mr.jobRef);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: buildMRAppBar(
        title: _isSteelFrame ? 'Steel Frame – Issue Response' : 'Intent Issue',
        showBack: true,
        context: context,
        actions: [
          const Padding(
            padding: EdgeInsets.only(right: 14),
            child: Center(
              child: MRStatusBadge(label: 'Issued', status: 'completed'),
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
                  child:
                      Icon(Icons.architecture, color: mrTeal, size: sw * 0.05),
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
                        Text(
                            '${spares.where((s) => !s.isSufficient).length} component(s) need procurement',
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
          Text('${mr.jobRef} · By ${mr.requestedBy}',
              style: TextStyle(
                  fontSize: sw * 0.035, color: AppColors.textSecondary)),
          SizedBox(height: sw * 0.04),
          MRSummaryStrip(spares: spares, sw: sw),
          SizedBox(height: sw * 0.05),
          Text('Component Stock Status',
              style: TextStyle(
                  fontSize: sw * 0.042,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary)),
          SizedBox(height: sw * 0.03),
          ...spares.map((s) => Padding(
                padding: EdgeInsets.only(bottom: sw * 0.03),
                child: MRSpareStockCard(spare: s, sw: sw),
              )),
          SizedBox(height: sw * 0.05),
        ]),
      ),
    );
  }
}
