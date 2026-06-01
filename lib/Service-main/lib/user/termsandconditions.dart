
import 'package:flutter/material.dart';
import 'package:service_ticket/core/size_utils.dart';

import '../core/app_colors.dart';

class TermsAndConditionsScreen extends StatelessWidget {
  const TermsAndConditionsScreen({super.key});

  static const _items = [
    'Tickets must be updated with a status change as work progresses.',
    'Any completed job should include a resolution note and, where possible, proof of work.',
    'Spare parts usage should be recorded before end of shift.',
    'Sensitive user or company information must not be stored outside approved systems.',
    'Repeated ticket reassignment should be escalated to the service supervisor.',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(title: const Text('Terms & Conditions')),
      body: ListView.separated(
        padding: EdgeInsets.all(20.r),
        itemCount: _items.length,
        separatorBuilder: (_, __) => SizedBox(height: 12.h),
        itemBuilder: (_, index) => Container(
          padding: EdgeInsets.all(16.r),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16.r),
            border: Border.all(color: AppColors.border),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 28.w,
                height: 28.w,
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(14.r),
                ),
                child: Center(
                  child: Text(
                    '${index + 1}',
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: AppColors.primary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Text(
                  _items[index],
                  maxLines: 4,

                  style: TextStyle(
                    fontSize: 14.sp,
                    color: AppColors.textDark,
                    height: 1.5,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
