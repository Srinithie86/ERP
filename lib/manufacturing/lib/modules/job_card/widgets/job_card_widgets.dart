import 'package:flutter/material.dart';
import '../../../core/app_theme.dart';
import '../job_card_model.dart';

const Color jcTeal = Color(0xFF26A69A);

class JCStatusBadge extends StatelessWidget {
  final String label, status;
  const JCStatusBadge({super.key, required this.label, required this.status});

  @override
  Widget build(BuildContext context) {
    final sw = MediaQuery.of(context).size.width;
    Color bg, fg;
    switch (status) {
      case 'inprogress':
        bg = const Color(0xFFE3F2FD);
        fg = const Color(0xFF1565C0);
        break;
      case 'completed':
        bg = const Color(0xFFE0F2F1);
        fg = jcTeal;
        break;
      case 'pending':
        bg = const Color(0xFFF5F5F5);
        fg = const Color(0xFF757575);
        break;
      default:
        bg = AppColors.border;
        fg = AppColors.textSecondary;
    }
    return Container(
      padding: EdgeInsets.symmetric(
          horizontal: sw * 0.025, vertical: sw * 0.008),
      decoration: BoxDecoration(
          color: bg, borderRadius: BorderRadius.circular(sw * 0.015)),
      child: Text(label,
          style: TextStyle(
              fontSize: sw * 0.028, fontWeight: FontWeight.w700, color: fg)),
    );
  }
}

class JCFullFormField extends StatelessWidget {
  final String label;
  final String value;
  final double sw;
  final Color? valueColor;

  const JCFullFormField({
    super.key,
    required this.label,
    required this.value,
    required this.sw,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: sw * 0.025),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: sw * 0.35,
            child: Text(
              label,
              style: TextStyle(
                fontSize: sw * 0.03,
                fontWeight: FontWeight.w600,
                color: AppColors.textSecondary,
                letterSpacing: 0.3,
              ),
            ),
          ),
          Text(
            ':',
            style: TextStyle(
              fontSize: sw * 0.03,
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(width: sw * 0.03),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: sw * 0.033,
                color: valueColor ?? AppColors.textPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class JCSectionCard extends StatelessWidget {
  final Widget child;
  const JCSectionCard({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final sw = MediaQuery.of(context).size.width;
    return Container(
      margin: EdgeInsets.symmetric(horizontal: sw * 0.04, vertical: sw * 0.01),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(sw * 0.03),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 2)),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(sw * 0.04),
        child: child,
      ),
    );
  }
}

class JCJobCardTile extends StatelessWidget {
  final JobCard job;
  final VoidCallback onTap;
  const JCJobCardTile({super.key, required this.job, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final sw = MediaQuery.of(context).size.width;
    final spares = sparesFor(job.id);
    final hasShortage = spares.any((s) => !s.isSufficient);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(sw * 0.03),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 2)),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(sw * 0.03),
          child: Padding(
            padding: EdgeInsets.all(sw * 0.04),
            child: Column(children: [
              Row(children: [
                Container(
                  width: sw * 0.12,
                  height: sw * 0.12,
                  decoration: BoxDecoration(
                    color: AppColors.inProgressLight,
                    borderRadius: BorderRadius.circular(sw * 0.025),
                  ),
                  child: Icon(Icons.assignment_outlined,
                      color: AppColors.inProgress, size: sw * 0.06),
                ),
                SizedBox(width: sw * 0.035),
                Expanded(
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(job.productName,
                            style: TextStyle(
                                fontSize: sw * 0.036,
                                fontWeight: FontWeight.w700,
                                color: AppColors.textPrimary)),
                        SizedBox(height: sw * 0.005),
                        Text('${job.id} · ${job.planRef}',
                            style: TextStyle(
                                fontSize: sw * 0.03,
                                color: AppColors.textSecondary)),
                      ]),
                ),
                Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                  JCStatusBadge(
                    label:
                        job.status == 'inprogress' ? 'In Progress' : 'Pending',
                    status: job.status,
                  ),
                  if (hasShortage) ...[
                    SizedBox(height: sw * 0.01),
                    Container(
                      padding: EdgeInsets.symmetric(
                          horizontal: sw * 0.02, vertical: sw * 0.007),
                      decoration: BoxDecoration(
                        color: AppColors.dangerLight,
                        borderRadius: BorderRadius.circular(sw * 0.015),
                      ),
                      child: const Text('Parts Short',
                          style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              color: AppColors.danger)),
                    ),
                  ],
                ]),
              ]),
              SizedBox(height: sw * 0.03),
              const Divider(color: Color(0xFFF0F0F0), height: 1),
              SizedBox(height: sw * 0.025),
              Row(children: [
                Icon(Icons.person_outline,
                    size: sw * 0.035, color: AppColors.textSecondary),
                SizedBox(width: sw * 0.01),
                Expanded(
                  child: Text(job.assignedTo,
                      style: TextStyle(
                          fontSize: sw * 0.03, color: AppColors.textSecondary)),
                ),
                Icon(Icons.settings_outlined,
                    size: sw * 0.035, color: AppColors.textSecondary),
                SizedBox(width: sw * 0.01),
                Text(job.machine,
                    style: TextStyle(
                        fontSize: sw * 0.03, color: AppColors.textSecondary)),
                SizedBox(width: sw * 0.03),
                Text('${job.qty} units',
                    style: TextStyle(
                        fontSize: sw * 0.03,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary)),
              ]),
            ]),
          ),
        ),
      ),
    );
  }
}
