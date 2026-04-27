import 'package:flutter/material.dart';
import 'package:service_ticket/core/size_utils.dart';

import '../core/app_colors.dart';

class WorkflowStepper extends StatelessWidget {
  const WorkflowStepper({
    super.key,
    required this.currentStep,
    this.title = 'Work Flow',
    this.labels = const [
      'Ticket\nPicked',
      'Check In',
      'Service\nForm',
      'Check\nout',
      'Closed',
    ],
  });

  final int currentStep;
  final String title;
  final List<String> labels;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 15.sp,
            fontWeight: FontWeight.w700,
            color: Colors.black,
          ),
        ),
        SizedBox(height: 12.h),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: List.generate(labels.length, (index) {
            final step = index + 1;
            final isDone = step < currentStep || currentStep >= labels.length;
            final isCurrent = step == currentStep && currentStep < labels.length;
            final isActive = isDone || isCurrent;
            final greenColor = const Color(0xFF56CC5A);

            return Expanded(
              child: Column(
                children: [
                  Row(
                    children: [
                      if (index > 0)
                        Expanded(
                          child: Container(
                            height: 3.h,
                            color: step <= currentStep
                                ? const Color(0xFF56CC5A)
                                : const Color(0xFFD9DEE8),
                          ),
                        ),
                      Container(
                        width: 22.w,
                        height: 22.w,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: isActive ? greenColor : const Color(0xFFD9DEE8),
                        ),
                        alignment: Alignment.center,
                        child: isDone
                            ? Icon(
                                Icons.check_rounded,
                                size: 14.sp,
                                color: Colors.white,
                              )
                            : Text(
                                '$step',
                                style: TextStyle(
                                  fontSize: 10.sp,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                ),
                              ),
                      ),
                      if (index < labels.length - 1)
                        Expanded(
                          child: Container(
                            height: 3.h,
                            color: step < currentStep
                                ? const Color(0xFF56CC5A)
                                : const Color(0xFFD9DEE8),
                          ),
                        ),
                    ],
                  ),
                  SizedBox(height: 6.h),
                  Text(
                    labels[index],
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 9.sp,
                      height: 1.15,
                      fontWeight: isActive ? FontWeight.w500 : FontWeight.normal,
                      color: isActive ? AppColors.primary : const Color(0xFF8892A6),
                    ),
                  ),
                ],
              ),
            );
          }),
        ),
      ],
    );
  }
}
