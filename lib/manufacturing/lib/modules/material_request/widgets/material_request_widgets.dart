import 'package:flutter/material.dart';
import '../../../core/app_theme.dart';
import '../../../core/shared_widgets.dart';
import '../material_request_model.dart';
import '../../job_card/job_card_model.dart';

const Color mrTeal = Color(0xFF26A69A);

PreferredSizeWidget buildMRAppBar({
  required String title,
  List<Widget>? actions,
  bool showBack = true,
  BuildContext? context,
}) {
  return AppBar(
    backgroundColor: mrTeal,
    elevation: 0,
    leading: showBack && context != null
        ? IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          )
        : null,
    automaticallyImplyLeading: false,
    title: Text(title,
        style: const TextStyle(
            color: Colors.white, fontWeight: FontWeight.w700)),
    actions: actions,
  );
}

class MRStatusBadge extends StatelessWidget {
  final String label, status;
  const MRStatusBadge({super.key, required this.label, required this.status});

  @override
  Widget build(BuildContext context) {
    final sw = MediaQuery.of(context).size.width;
    Color bg, fg;
    switch (status) {
      case 'completed':
        bg = const Color(0xFFE0F2F1);
        fg = mrTeal;
        break;
      case 'inprogress':
        bg = const Color(0xFFE3F2FD);
        fg = const Color(0xFF1565C0);
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

class MRSummaryStrip extends StatelessWidget {
  final List<SpareItem> spares;
  final double sw;
  const MRSummaryStrip({super.key, required this.spares, required this.sw});

  @override
  Widget build(BuildContext context) {
    final total = spares.length;
    final available = spares.where((s) => s.isSufficient).length;
    final shortage = total - available;

    return Container(
      padding: EdgeInsets.symmetric(vertical: sw * 0.02),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(sw * 0.03),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _StatBox('Total', '$total', Colors.black, sw),
          _Divider(sw),
          _StatBox('In Stock', '$available', Colors.green, sw),
          _Divider(sw),
          _StatBox('Shortage', '$shortage',
              shortage > 0 ? AppColors.danger : Colors.black, sw),
        ],
      ),
    );
  }

  Widget _Divider(double sw) =>
      Container(width: 1, height: sw * 0.12, color: mrTeal.withOpacity(0.2));

  Widget _StatBox(String label, String val, Color color, double sw) => Expanded(
        child: Column(children: [
          Text(val,
              style: TextStyle(
                  fontSize: sw * 0.055,
                  fontWeight: FontWeight.w800,
                  color: color)),
          Text(label,
              style: TextStyle(
                  fontSize: sw * 0.028,
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w500)),
        ]),
      );
}

class MRSpareStockCard extends StatelessWidget {
  final SpareItem spare;
  final double sw;
  const MRSpareStockCard({super.key, required this.spare, required this.sw});

  @override
  Widget build(BuildContext context) {
    final sufficient = spare.isSufficient;

    return AppCard(
      color: AppColors.surface,
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Container(
            width: sw * 0.09,
            height: sw * 0.09,
            decoration: BoxDecoration(
              color: sufficient
                  ? const Color(0xFFE8F5E9)
                  : const Color(0xFFFFEBEE),
              borderRadius: BorderRadius.circular(sw * 0.02),
            ),
            child: Icon(
              sufficient
                  ? Icons.check_circle_outline
                  : Icons.warning_amber_outlined,
              color: sufficient ? AppColors.success : AppColors.danger,
              size: sw * 0.05,
            ),
          ),
          SizedBox(width: sw * 0.025),
          Expanded(
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(spare.name,
                  style: TextStyle(
                      fontSize: sw * 0.035,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary)),
              Text(spare.partNo,
                  style: TextStyle(
                      fontSize: sw * 0.028, color: AppColors.textSecondary)),
            ]),
          ),
          Container(
            padding: EdgeInsets.symmetric(
                horizontal: sw * 0.025, vertical: sw * 0.01),
            decoration: BoxDecoration(
              color: sufficient
                  ? const Color(0xFFE8F5E9)
                  : const Color(0xFFFFEBEE),
              borderRadius: BorderRadius.circular(sw * 0.015),
            ),
            child: Text(
              sufficient ? 'Issue' : 'Short',
              style: TextStyle(
                  fontSize: sw * 0.028,
                  fontWeight: FontWeight.w700,
                  color: sufficient ? AppColors.success : AppColors.danger),
            ),
          ),
        ]),
        SizedBox(height: sw * 0.03),
        const Divider(color: AppColors.border, height: 1),
        SizedBox(height: sw * 0.025),
        Row(children: [
          _StatCol('Required', '${spare.required} ${spare.uom}',
              AppColors.textPrimary, sw),
          Container(width: 1, height: sw * 0.08, color: AppColors.border),
          _StatCol('Issue', '${spare.inStock} ${spare.uom}',
              sufficient ? AppColors.success : Colors.black, sw),
          Container(width: 1, height: sw * 0.08, color: AppColors.border),
          _StatCol(
            'Remaining',
            sufficient ? '—' : '${spare.gap} short',
            sufficient ? AppColors.success : AppColors.danger,
            sw,
          ),
        ]),
      ]),
    );
  }

  Widget _StatCol(String label, String val, Color valColor, double sw) =>
      Expanded(
        child: Column(children: [
          Text(label,
              style: TextStyle(
                  fontSize: sw * 0.028, color: AppColors.textSecondary)),
          SizedBox(height: sw * 0.005),
          Text(val,
              style: TextStyle(
                  fontSize: sw * 0.035,
                  fontWeight: FontWeight.w800,
                  color: valColor)),
        ]),
      );
}
