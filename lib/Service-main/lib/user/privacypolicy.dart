
import 'package:flutter/material.dart';
import 'package:service_ticket/core/size_utils.dart';

import '../core/app_colors.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  static const _sections = [
    (
      'Data Collected',
      'The app stores technician profile details, ticket updates, task progress, and spare part inventory used in the demo workflow.'
    ),
    (
      'Usage',
      'Data is shown only to support day-to-day technician actions like accepting tickets, updating resolution notes, and checking inventory.'
    ),
    (
      'Storage',
      'This sample app uses local in-memory data. No external server or analytics service is connected in the current build.'
    ),
    (
      'Access',
      'Only authorized service staff should access technician dashboards or customer issue details.'
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(title: const Text('Privacy Policy')),
      body: ListView.separated(
        padding: EdgeInsets.all(20.r),
        itemCount: _sections.length,
        separatorBuilder: (_, __) => SizedBox(height: 12.h),
        itemBuilder: (_, index) {
          final section = _sections[index];
          return Container(
            padding: EdgeInsets.all(16.r),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16.r),
              border: Border.all(color: AppColors.border),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  section.$1,
                  maxLines: 1,

                  style: TextStyle(
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textDark,
                  ),
                ),
                SizedBox(height: 8.h),
                Text(
                  section.$2,
                  maxLines: 5,

                  style: TextStyle(
                    fontSize: 13.sp,
                    color: AppColors.textGrey,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
