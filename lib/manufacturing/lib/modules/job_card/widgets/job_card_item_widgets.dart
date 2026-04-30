import 'package:flutter/material.dart';
import '../../../core/app_theme.dart';
import '../job_card_model.dart';
import 'job_card_widgets.dart';

class JCSpareRow extends StatelessWidget {
  final SpareItem spare;
  final double sw;
  const JCSpareRow({super.key, required this.spare, required this.sw});

  @override
  Widget build(BuildContext context) {
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
      child: Padding(
        padding: EdgeInsets.all(sw * 0.04),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          JCFullFormField(label: 'ITEM NAME', value: spare.name, sw: sw),
          JCFullFormField(label: 'ITEM NO', value: spare.partNo, sw: sw),
          JCFullFormField(
              label: 'REQUIRED',
              value: '${spare.required} ${spare.uom}',
              sw: sw),
        ]),
      ),
    );
  }
}
