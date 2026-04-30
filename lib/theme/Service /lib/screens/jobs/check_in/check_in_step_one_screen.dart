import 'package:flutter/material.dart';
import 'package:service_ticket/core/size_utils.dart';

import '../../../data/app_data.dart';
import 'check_in_step_two_screen.dart';
import 'check_in_widgets.dart';

class CheckInStepOneScreen extends StatelessWidget {
  const CheckInStepOneScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final flow = AppData.instance;
    final job = flow.job;

    return CheckInScaffold(
      title: 'Check in',
      actionLabel: 'Check In & Auto - Record Start Time',
      onAction: () {
        Navigator.of(
          context,
        ).push(MaterialPageRoute(builder: (_) => const CheckInStepTwoScreen()));
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(14.r),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14.r),
              gradient: const LinearGradient(
                colors: [Color(0xFF5B7DF3), Color(0xFF2942AA)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Work Start Time - Auto Captured on Check In',
                  style: TextStyle(
                    fontSize: 11.sp,
                    color: Colors.white.withValues(alpha: 0.88),
                  ),
                ),
                SizedBox(height: 8.h),
                Text(
                  'Checking in at ${job['checkInTime']}',
                  style: TextStyle(
                    fontSize: 23.sp,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 6.h),
                Text(
                  '${job['dateText']}',
                  style: TextStyle(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 14.h),
                Row(
                  children: [
                    Expanded(
                      child: _HeaderMetric(
                        title: 'Ticket',
                        value: '${job['ticketId']}',
                      ),
                    ),
                    SizedBox(width: 10.w),
                    Expanded(
                      child: _HeaderMetric(
                        title: 'Priority',
                        value: '• ${job['priority']}',
                        valueColor: const Color(0xFFFF4D4F),
                      ),
                    ),
                    SizedBox(width: 10.w),
                    Expanded(
                      child: _HeaderMetric(
                        title: 'Type',
                        value: '${job['type']}',
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          SizedBox(height: 18.h),
          const WorkflowIndicator(currentStep: 2),
          SizedBox(height: 16.h),
          SectionCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Customer Detail',
                  style: TextStyle(
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                SizedBox(height: 12.h),
                const Divider(color: Color(0xFFB7C3DA), height: 1),
                LabelValueRow(label: 'Name', value: '${job['customerName']}'),
                const Divider(color: Color(0xFFB7C3DA), height: 1),
                LabelValueRow(label: 'Product', value: '${job['product']}'),
                const Divider(color: Color(0xFFB7C3DA), height: 1),
                LabelValueRow(label: 'Complaint', value: '${job['complaint']}'),
                const Divider(color: Color(0xFFB7C3DA), height: 1),
                LabelValueRow(
                  label: 'Phone',
                  value: '${job['phone']}',
                  valueColor: const Color(0xFF5177F5),
                ),
                const Divider(color: Color(0xFFB7C3DA), height: 1),
                LabelValueRow(label: 'Address', value: '${job['address']}'),
                const Divider(color: Color(0xFFB7C3DA), height: 1),
                LabelValueRow(
                  label: 'Et . Duration',
                  value: '${job['estimatedDuration']}',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _HeaderMetric extends StatelessWidget {
  const _HeaderMetric({
    required this.title,
    required this.value,
    this.valueColor,
  });

  final String title;
  final String value;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 10.h),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 10.sp,
              color: Colors.white.withValues(alpha: 0.9),
            ),
          ),
          SizedBox(height: 6.h),
          Text(
            value,
            style: TextStyle(
              fontSize: 11.sp,
              fontWeight: FontWeight.w700,
              color: valueColor ?? Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}
