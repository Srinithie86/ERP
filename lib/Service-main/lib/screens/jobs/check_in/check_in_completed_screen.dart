import 'package:flutter/material.dart';
import 'package:service_ticket/core/size_utils.dart';

import '../../../data/app_data.dart';
import 'check_in_feedback_screen.dart';
import 'check_in_widgets.dart';

class CheckInCompletedScreen extends StatelessWidget {
  const CheckInCompletedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final flow = AppData.instance;
    final job = flow.job;
    final rows = (job['spareLines'] as List)
        .map((item) => Map<String, String>.from(item as Map))
        .toList();

    return CheckInScaffold(
      title: 'Check Out',
      showBackButton: false,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const WorkflowIndicator(currentStep: 5),
          SizedBox(height: 32.h),
          Center(
            child: Column(
              children: [
                Container(
                  width: 64.w,
                  height: 64.w,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Color(0xFF56CC5A),
                  ),
                  child: Icon(
                    Icons.check_rounded,
                    size: 42.sp,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 20.h),
                Text(
                  'Check Out Completed!',
                  style: TextStyle(
                    fontSize: 20.sp,
                    fontWeight: FontWeight.w700,
                    color: Colors.black,
                  ),
                ),
                SizedBox(height: 10.h),
                Text(
                  'Happy Code verified',
                  style: TextStyle(
                    fontSize: 13.sp,
                    color: const Color(0xFF667085),
                  ),
                ),
                SizedBox(height: 8.h),
                RichText(
                  text: TextSpan(
                    style: TextStyle(fontSize: 13.sp, color: Colors.black87),
                    children: [
                      const TextSpan(text: 'Ticket '),
                      TextSpan(
                        text: '${job['ticketId']}',
                        style: const TextStyle(fontWeight: FontWeight.w800),
                      ),
                      const TextSpan(text: ' is now '),
                      const TextSpan(
                        text: 'Closed',
                        style: TextStyle(fontWeight: FontWeight.w800, color: Color(0xFF1E8D43)),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 24.h),
          GradientTicketSummary(
            ticketId: '${job['ticketId']}',
            customerName: '${job['customerName']}',
            issue: '${job['issue']}',
            startTime: '${job['startTime']}',
            endTime: '${job['endTime']}',
            duration: '${job['duration']}',
          ),
          SizedBox(height: 16.h),
          _DetailCard(
            title: 'Customer Detail',
            children: [
              _DetailRow(label: 'Date', value: '${job['dateText']}'),
              _DetailRow(label: 'Check In', value: '${job['checkInTime']}'),
              _DetailRow(label: 'Name', value: '${job['customerName']}'),
              _DetailRow(label: 'Product', value: '${job['product']}'),
              _DetailRow(label: 'Complaint', value: '${job['complaint']}'),
              _DetailRow(label: 'Phone', value: '${job['phone']}', valueColor: const Color(0xFF5177F5)),
              _DetailRow(label: 'Email', value: '${job['email']}', valueColor: const Color(0xFF5177F5)),
              _DetailRow(label: 'Address', value: '${job['address']}'),
              _DetailRow(label: 'Duration', value: '${job['estimatedDuration']}'),
              if ('${job['nextVisitDate'] ?? ''}'.isNotEmpty)
                _DetailRow(label: 'Next Visit Date', value: '${job['nextVisitDate']}'),
            ],
          ),
          SizedBox(height: 16.h),
          SummaryTable(
            rows: rows,
            serviceCharge: '${job['serviceCharge']}',
            nextVisitDate: '${job['nextVisitDate'] ?? ''}',
          ),
          SizedBox(height: 16.h),
          _DetailCard(
            title: 'Service Details',
            children: [
              _DetailRow(label: 'Work Description', value: flow.workDescription.isEmpty ? '-' : flow.workDescription),
              _DetailRow(label: 'Before Image', value: flow.beforeImageName.isEmpty ? '-' : flow.beforeImageName),
              _DetailRow(label: 'After Image', value: flow.afterImageName.isEmpty ? '-' : flow.afterImageName),
              _DetailRow(label: 'Old Spare Image', value: flow.oldSpareImageName.isEmpty ? '-' : flow.oldSpareImageName),
              _DetailRow(label: 'Signature', value: flow.signatureName.isEmpty ? '-' : flow.signatureName),
              _DetailRow(label: 'Send Via', value: flow.otpChannel.isEmpty ? '-' : flow.otpChannel == 'Phone' ? 'Phone Number' : 'Email ID'),
            ],
          ),
          SizedBox(height: 20.h),
          Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 48.h,
                  child: OutlinedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const CheckInFeedbackScreen(),
                        ),
                      );
                    },
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Color(0xFF2644A6)),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                    ),
                    child: Text(
                      'Rating & Feedback',
                      style: TextStyle(
                        fontSize: 13.sp,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF2644A6),
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: SizedBox(
                  height: 48.h,
                  child: ElevatedButton(
                    onPressed: () => _finishFlow(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2644A6),
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                    ),
                    child: Text(
                      'Skip',
                      style: TextStyle(
                        fontSize: 13.sp,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 16.h),
        ],
      ),
    );
  }

  void _finishFlow(BuildContext context) {
    AppData.instance.resetCheckInFlow();
    Navigator.of(context).popUntil((route) => route.isFirst);
  }
}

class _DetailCard extends StatelessWidget {
  const _DetailCard({
    required this.title,
    required this.children,
  });

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(14.r),
      decoration: BoxDecoration(
        color: const Color(0xFFF3F5F9),
        borderRadius: BorderRadius.circular(14.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.w700,
              color: Colors.black87,
            ),
          ),
          SizedBox(height: 10.h),
          ...children,
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({
    required this.label,
    required this.value,
    this.valueColor,
  });

  final String label;
  final String value;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 10.h),
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Color(0xFFD7DCE8)),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 4,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 13.sp,
                color: const Color(0xFF5177F5),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            flex: 6,
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: TextStyle(
                fontSize: 13.sp,
                color: valueColor ?? const Color(0xFF1F2937),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
