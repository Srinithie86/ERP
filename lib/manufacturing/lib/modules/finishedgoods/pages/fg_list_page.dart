import 'package:flutter/material.dart';
import '../../../core/app_theme.dart';
import '../../../core/shared_widgets.dart';
import '../fg_model.dart';

class QCListPage extends StatelessWidget {
  const QCListPage({super.key});

  @override
  Widget build(BuildContext context) {
    final sw = MediaQuery.of(context).size.width;
    return Scaffold(
      backgroundColor: AppColors.background,
      body: ListView.separated(
        padding: EdgeInsets.all(sw * 0.05),
        itemCount: QcSampleData.qcRecords.length,
        separatorBuilder: (_, __) => SizedBox(height: sw * 0.03),
        itemBuilder: (_, i) {
          final qc = QcSampleData.qcRecords[i];
          final passRate = qc.totalQty > 0
              ? (qc.passQty / qc.totalQty * 100).toStringAsFixed(1)
              : '0.0';
          return AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(children: [
                  Expanded(
                    child: Text(qc.productName,
                        style: TextStyle(
                            fontSize: sw * 0.035,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary)),
                  ),
                  StatusBadge(
                    label: qc.status == 'completed' ? 'Done' : 'Pending',
                    status: qc.status,
                  ),
                ]),
                SizedBox(height: sw * 0.01),
                Text('${qc.id} · ${qc.jobRef}',
                    style: TextStyle(
                        fontSize: sw * 0.03, color: AppColors.textSecondary)),
                SizedBox(height: sw * 0.02),
                Row(children: [
                  _qcStat('Total', '${qc.totalQty}', AppColors.textPrimary, sw),
                  _qcStat('Pass', '${qc.passQty}', AppColors.success, sw),
                  _qcStat('Fail', '${qc.failQty}', AppColors.danger, sw),
                  _qcStat('Rate', '$passRate%', AppColors.inProgress, sw),
                ]),
                SizedBox(height: sw * 0.015),
                ProgressBar(
                  value: qc.totalQty > 0 ? qc.passQty / qc.totalQty : 0.0,
                  color: AppColors.success,
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _qcStat(String label, String val, Color color, double sw) => Expanded(
        child: Column(children: [
          Text(val,
              style: TextStyle(
                  fontSize: sw * 0.038,
                  fontWeight: FontWeight.w800,
                  color: color)),
          Text(label,
              style:
                  TextStyle(fontSize: sw * 0.026, color: AppColors.textSecondary)),
        ]),
      );
}
