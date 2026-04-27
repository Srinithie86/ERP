import 'package:flutter/material.dart';
import 'package:service_ticket/core/size_utils.dart';

import '../../Widgets/app_status_bar_wrapper.dart';
import '../../core/app_colors.dart';
import '../../data/app_data.dart';

import '../technician_dashboard.dart';

class DispatchmentHistoryScreen extends StatelessWidget {
  const DispatchmentHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final record = AppData.instance.latestDispatch;

    return Scaffold(
      backgroundColor: Colors.white,
      body: AppStatusBarWrapper(
        child: SafeArea(
          top: false,
          bottom: false,
          child: SingleChildScrollView(
            padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 20.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    InkWell(
                      onTap: () {
                        Navigator.of(context).pushAndRemoveUntil(
                          MaterialPageRoute(
                            builder: (_) => const TechnicianDashboard(),
                          ),
                          (route) => false,
                        );
                      },
                      borderRadius: BorderRadius.circular(20.r),
                      child: Padding(
                        padding: EdgeInsets.all(4.r),
                        child: Icon(
                          Icons.arrow_back_ios_new_rounded,
                          size: 18.sp,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                    SizedBox(width: 8.w),
                    Text(
                      'Dispatch History',
                      style: TextStyle(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textDark,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 20.h),
                if (record == null)
                  Center(
                    child: Padding(
                      padding: EdgeInsets.only(top: 80.h),
                      child: Text(
                        'No dispatch history available yet.',
                        style: TextStyle(
                          fontSize: 13.sp,
                          color: const Color(0xFF667085),
                        ),
                      ),
                    ),
                  )
                else
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(14.r),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12.r),
                      border: Border.all(color: const Color(0xFFD6DDEA)),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              record.dispatchId,
                              style: TextStyle(
                                fontSize: 15.sp,
                                fontWeight: FontWeight.w700,
                                color: AppColors.primary,
                              ),
                            ),
                            const Spacer(),
                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 10.w,
                                vertical: 5.h,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFFE8F7EA),
                                borderRadius: BorderRadius.circular(20.r),
                              ),
                              child: Text(
                                record.status,
                                style: TextStyle(
                                  fontSize: 10.5.sp,
                                  fontWeight: FontWeight.w700,
                                  color: const Color(0xFF209647),
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 12.h),
                        _HistoryRow(label: 'Parcel No', value: record.parcelNo),
                        _HistoryRow(
                          label: 'Transfer Mode',
                          value: record.transferMode,
                        ),
                        _HistoryRow(
                          label: 'Transport Date',
                          value: record.transportDate,
                        ),
                        _HistoryRow(
                          label: 'Expected Delivery',
                          value: record.expectedDelivery,
                        ),
                        _HistoryRow(
                          label: 'Dispatch Time',
                          value: record.dispatchTime,
                        ),
                        _HistoryRow(
                          label: 'Contact Person',
                          value: record.contactName,
                        ),
                        _HistoryRow(label: 'Phone', value: record.phone),
                        _HistoryRow(label: 'Address', value: record.address),
                        _HistoryRow(
                          label: 'Notes',
                          value: record.notes,
                          isLast: record.attachmentPath == null,
                        ),
                        if (record.attachmentPath != null)
                          _HistoryRow(
                            label: 'Attachment',
                            value: 'Image uploaded',
                            isLast: true,
                          ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _HistoryRow extends StatelessWidget {
  const _HistoryRow({
    required this.label,
    required this.value,
    this.isLast = false,
  });

  final String label;
  final String value;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 10.h),
      decoration: BoxDecoration(
        border: isLast
            ? null
            : const Border(bottom: BorderSide(color: Color(0xFFE4E8F1))),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 110.w,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 12.sp,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF54637D),
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 12.sp,
                color: const Color(0xFF2D3748),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
