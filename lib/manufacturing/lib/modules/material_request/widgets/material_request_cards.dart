import 'package:flutter/material.dart';
import '../../../core/app_theme.dart';
import '../../../core/shared_widgets.dart';
import '../material_request_model.dart';
import '../../job_card/job_card_model.dart';
import 'material_request_widgets.dart';

class MRCard extends StatelessWidget {
  final MaterialRequest mr;
  final VoidCallback onTap;
  const MRCard({super.key, required this.mr, required this.onTap});

  bool get _isSteelFrame => mr.jobRef == 'JC-004';

  @override
  Widget build(BuildContext context) {
    final sw = MediaQuery.of(context).size.width;

    return AppCard(
      onTap: onTap,
      color: AppColors.surface,
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Container(
            width: sw * 0.105,
            height: sw * 0.105,
            decoration: BoxDecoration(
              color: const Color(0xFFE0F2F1),
              borderRadius: BorderRadius.circular(sw * 0.025),
            ),
            child: Icon(
              _isSteelFrame
                  ? Icons.architecture
                  : mr.status == 'approved'
                      ? Icons.check_circle_outline
                      : Icons.pending_outlined,
              color: mrTeal,
              size: sw * 0.055,
            ),
          ),
          SizedBox(width: sw * 0.03),
          Expanded(
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('${mr.id} · ${mr.jobRef}',
                  style: TextStyle(
                      fontSize: sw * 0.035,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary)),
              Text('${mr.items.length} items · By ${mr.requestedBy}',
                  style: TextStyle(
                      fontSize: sw * 0.03, color: AppColors.textSecondary)),
              if (_isSteelFrame)
                Padding(
                  padding: EdgeInsets.only(top: sw * 0.006),
                  child: const Text('Steel Frame Structure',
                      style: TextStyle(
                          fontSize: 10,
                          color: mrTeal,
                          fontWeight: FontWeight.w600)),
                ),
            ]),
          ),
          MRStatusBadge(
            label: mr.status == 'approved' ? 'Approved' : 'Pending',
            status: mr.status == 'approved' ? 'completed' : 'pending',
          ),
        ]),
      ]),
    );
  }
}

class MRResponseCard extends StatelessWidget {
  final MaterialRequest mr;
  final VoidCallback onTap;
  const MRResponseCard({super.key, required this.mr, required this.onTap});

  bool get _isSteelFrame => mr.jobRef == 'JC-004';

  @override
  Widget build(BuildContext context) {
    final sw = MediaQuery.of(context).size.width;
    final spares = sparesFor(mr.jobRef);
    final shortage = spares.any((s) => !s.isSufficient);

    return AppCard(
      onTap: onTap,
      color: AppColors.surface,
      child: Row(children: [
        Container(
          width: sw * 0.105,
          height: sw * 0.105,
          decoration: BoxDecoration(
            color: shortage ? const Color(0xFFFFEBEE) : const Color(0xFFE8F5E9),
            borderRadius: BorderRadius.circular(sw * 0.025),
          ),
          child: Icon(
            _isSteelFrame
                ? Icons.architecture
                : shortage
                    ? Icons.warning_amber_outlined
                    : Icons.check_circle_outline,
            color: shortage ? AppColors.danger : AppColors.success,
            size: sw * 0.055,
          ),
        ),
        SizedBox(width: sw * 0.03),
        Expanded(
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('${mr.id} · ${mr.jobRef}',
                style: TextStyle(
                    fontSize: sw * 0.035,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary)),
            SizedBox(height: sw * 0.005),
            Text('${spares.length} components · By ${mr.requestedBy}',
                style: TextStyle(
                    fontSize: sw * 0.03, color: AppColors.textSecondary)),
            if (_isSteelFrame)
              Padding(
                padding: EdgeInsets.only(top: sw * 0.006),
                child: const Text('Steel Frame Structure',
                    style: TextStyle(
                        fontSize: 10,
                        color: mrTeal,
                        fontWeight: FontWeight.w600)),
              ),
            if (shortage) ...[
              SizedBox(height: sw * 0.01),
              Text(
                '${spares.where((s) => !s.isSufficient).length} item(s) short',
                style: TextStyle(
                    fontSize: sw * 0.03,
                    fontWeight: FontWeight.w700,
                    color: AppColors.danger),
              ),
            ],
          ]),
        ),
        Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
          const MRStatusBadge(label: 'Issued', status: 'completed'),
          SizedBox(height: sw * 0.01),
          Text('Tap to view stock',
              style:
                  TextStyle(fontSize: sw * 0.027, color: AppColors.textHint)),
        ]),
      ]),
    );
  }
}
