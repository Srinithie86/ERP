import 'package:flutter/material.dart';
import '../../../core/app_theme.dart';
import '../../../core/shared_widgets.dart';
import '../job_card_model.dart';
import '../widgets/job_card_widgets.dart';
import '../widgets/job_card_item_widgets.dart';
import '../../material_request/material_request_screen.dart'
    hide StatusBadge;

class JobCardDetailPage extends StatelessWidget {
  final JobCard job;
  const JobCardDetailPage({super.key, required this.job});

  @override
  Widget build(BuildContext context) {
    final sw = MediaQuery.of(context).size.width;
    final spares = sparesFor(job.id);
    final shortCount = spares.where((s) => !s.isSufficient).length;

    return Scaffold(
      backgroundColor: const Color(0xFFF2F4F7),
      appBar: AppBar(
        backgroundColor: jcTeal,
        elevation: 0,
        leading: IconButton(
          icon:
              const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Job Card',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
        actions: [
          Padding(
            padding: EdgeInsets.only(right: sw * 0.03),
            child: Center(
              child: JCStatusBadge(
                label: job.status == 'inprogress' ? 'In Progress' : 'Pending',
                status: job.status,
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: double.infinity,
                      margin: EdgeInsets.all(sw * 0.04),
                      padding: EdgeInsets.all(sw * 0.04),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE8F5E9),
                        border: Border.all(
                            color: const Color(0xFF81C784), width: 1.2),
                        borderRadius: BorderRadius.circular(sw * 0.03),
                      ),
                      child: Row(children: [
                        const Icon(Icons.check_circle_outline,
                            color: Color(0xFF43A047), size: 22),
                        SizedBox(width: sw * 0.025),
                        Expanded(
                          child: Text(
                            'Job Card: ${job.id} — ${job.productName}',
                            style: TextStyle(
                              fontSize: sw * 0.037,
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFF2E7D32),
                            ),
                          ),
                        ),
                      ]),
                    ),
                    JCSectionCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          JCFullFormField(
                              label: 'JOB CARD NO', value: 'JC001', sw: sw),
                          JCFullFormField(
                              label: 'PRODUCT CODE',
                              value: 'PRD-0001',
                              sw: sw),
                          JCFullFormField(
                              label: 'PRODUCT NAME',
                              value: job.productName,
                              sw: sw),
                          JCFullFormField(
                              label: 'ASSIGNED TO',
                              value: job.assignedTo,
                              sw: sw),
                          JCFullFormField(
                              label: 'QUANTITY',
                              value: '${job.qty} units',
                              sw: sw),
                          JCFullFormField(
                            label: 'DELIVERY DATE',
                            value:
                                '${job.startDate.day}/${job.startDate.month}/${job.startDate.year}',
                            sw: sw,
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.fromLTRB(
                          sw * 0.04, sw * 0.04, sw * 0.04, 0),
                      child: Row(children: [
                        Text('Items',
                            style: TextStyle(
                                fontSize: sw * 0.042,
                                fontWeight: FontWeight.w700,
                                color: AppColors.textPrimary)),
                        const Spacer(),
                        if (shortCount > 0)
                          Container(
                            padding: EdgeInsets.symmetric(
                                horizontal: sw * 0.025, vertical: sw * 0.01),
                            decoration: BoxDecoration(
                              color: AppColors.dangerLight,
                              borderRadius: BorderRadius.circular(sw * 0.015),
                            ),
                            child: Text(
                              '$shortCount Short',
                              style: const TextStyle(
                                  color: AppColors.danger,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700),
                            ),
                          ),
                      ]),
                    ),
                    SizedBox(height: sw * 0.03),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: sw * 0.04),
                      child: Column(
                        children: spares
                            .map((s) => Padding(
                                  padding: EdgeInsets.only(bottom: sw * 0.03),
                                  child: JCSpareRow(spare: s, sw: sw),
                                ))
                            .toList(),
                      ),
                    ),
                    SizedBox(height: sw * 0.04),
                  ]),
            ),
          ),
          SafeArea(
            child: Padding(
              padding: EdgeInsets.fromLTRB(
                  sw * 0.04, sw * 0.02, sw * 0.04, sw * 0.03),
              child: Row(children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                            const MaterialRequestScreen(showBack: true),
                      ),
                    ),
                    icon: Icon(Icons.list_alt_outlined, size: sw * 0.05),
                    label: Text('Material Request',
                        style: TextStyle(fontSize: sw * 0.04)),
                    style: OutlinedButton.styleFrom(
                      backgroundColor: jcTeal,
                      foregroundColor: Colors.white,
                      side: const BorderSide(color: jcTeal),
                      padding: EdgeInsets.symmetric(vertical: sw * 0.035),
                      textStyle: const TextStyle(fontWeight: FontWeight.w500),
                    ),
                  ),
                ),
              ]),
            ),
          ),
        ],
      ),
    );
  }
}
