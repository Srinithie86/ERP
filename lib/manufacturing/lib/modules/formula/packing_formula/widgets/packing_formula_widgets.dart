import 'package:flutter/material.dart';
import '../../../../core/app_theme.dart';
import '../../../../core/shared_widgets.dart';
import '../packing_formula_model.dart';

const Color packingFormulaTeal = Color(0xFF26A69A);
const Color packingFormulaTealLight = Color(0xFFE0F2F1);
const Color packingFormulaTealDark = Color(0xFF00695C);

PreferredSizeWidget buildPackingFormulaAppBar({
  required String title,
  String? subtitle,
  List<Widget>? actions,
  bool showBack = true,
  BuildContext? context,
  PreferredSizeWidget? bottom,
}) {
  return AppBar(
    backgroundColor: packingFormulaTeal,
    elevation: 0,
    leading: showBack && context != null
        ? IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          )
        : null,
    automaticallyImplyLeading: false,
    title: subtitle != null
        ? Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: 15,
                ),
              ),
              Text(
                subtitle,
                style: const TextStyle(color: Colors.white70, fontSize: 11),
              ),
            ],
          )
        : Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w700,
            ),
          ),
    actions: actions,
    bottom: bottom,
  );
}

class PackingFormulaBottomSheet extends StatelessWidget {
  final String title;
  final String? subtitle;
  final Widget child;
  final double heightFactor;
  final List<Widget>? actions;

  const PackingFormulaBottomSheet({
    super.key,
    required this.title,
    this.subtitle,
    required this.child,
    this.heightFactor = 0.92,
    this.actions,
  });

  @override
  Widget build(BuildContext context) {
    final sw = MediaQuery.of(context).size.width;
    final mq = MediaQuery.of(context);

    return Container(
      height: mq.size.height * heightFactor,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          Container(
            margin: const EdgeInsets.only(top: 10),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(
              sw * 0.04,
              sw * 0.02,
              sw * 0.04,
              sw * 0.02,
            ),
            child: Row(
              children: [
                Expanded(
                  child: subtitle != null
                      ? Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              title,
                              style: TextStyle(
                                color: AppColors.textPrimary,
                                fontWeight: FontWeight.w700,
                                fontSize: 18,
                              ),
                            ),
                            Text(
                              subtitle!,
                              style: TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        )
                      : Text(
                          title,
                          style: TextStyle(
                            color: AppColors.textPrimary,
                            fontWeight: FontWeight.w700,
                            fontSize: 18,
                          ),
                        ),
                ),
                if (actions != null) ...actions!,
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Icon(Icons.close,
                      color: AppColors.textSecondary, size: 24),
                ),
              ],
            ),
          ),
          const Divider(color: AppColors.border, height: 1),
          Expanded(child: child),
        ],
      ),
    );
  }
}

class PackingFormulaSummaryCard extends StatelessWidget {
  final PackingFormulaItem packingFormula;
  final VoidCallback onTap;

  const PackingFormulaSummaryCard({super.key, required this.packingFormula, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final sw = MediaQuery.of(context).size.width;
    return AppCard(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  packingFormula.productName,
                  style: TextStyle(
                    fontSize: sw * 0.038,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              StatusBadge(
                label: packingFormula.status.toUpperCase(),
                status: packingFormula.status,
              ),
            ],
          ),
          SizedBox(height: sw * 0.01),
          Text(
            ' ID : ${packingFormula.id}   ${packingFormula.version}',
            style: TextStyle(
              fontSize: sw * 0.03,
              color: AppColors.textSecondary,
            ),
          ),
          SizedBox(height: sw * 0.03),
          Row(
            children: [
              _Stat(Icons.layers_outlined, '${packingFormula.materialCount} Mats', sw),
              SizedBox(width: sw * 0.04),
              _Stat(Icons.inventory_2_outlined, '${packingFormula.noOfCase} Cases', sw),
              SizedBox(width: sw * 0.04),
              _Stat(Icons.history, '${packingFormula.dtime}', sw),
            ],
          ),
        ],
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  final IconData icon;
  final String val;
  final double sw;
  const _Stat(this.icon, this.val, this.sw);

  @override
  Widget build(BuildContext context) => Row(
        children: [
          Icon(icon, size: sw * 0.035, color: AppColors.textHint),
          SizedBox(width: sw * 0.01),
          Text(
            val,
            style: TextStyle(
              fontSize: sw * 0.028,
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      );
}
