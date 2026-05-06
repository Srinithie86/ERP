import 'package:flutter/material.dart';
import 'package:service_ticket/core/size_utils.dart';
import 'check_in_widgets.dart';
import '../../../data/app_data.dart';

class CheckInFeedbackScreen extends StatefulWidget {
  const CheckInFeedbackScreen({super.key});

  @override
  State<CheckInFeedbackScreen> createState() => _CheckInFeedbackScreenState();
}

class _CheckInFeedbackScreenState extends State<CheckInFeedbackScreen> {
  int _rating = 0;
  final TextEditingController _commentController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final job = AppData.instance.job;

    return CheckInScaffold(
      title: 'Ratings & Feedback',
      showBackButton: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 12.h),
          // Profile/Rating Card
          Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(vertical: 24.h),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12.r),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              children: [
                Container(
                  width: 60.w,
                  height: 60.w,
                  decoration: const BoxDecoration(
                    color: Color(0xFFE8EFFF),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.person_outline_rounded, size: 34.sp, color: const Color(0xFF2644A6)),
                ),
                SizedBox(height: 12.h),
                Text(
                  '${job['customerName']}',
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.w700,
                    color: Colors.black,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  'How was today\'s service?',
                  style: TextStyle(
                    fontSize: 13.sp,
                    color: const Color(0xFF445B87),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(height: 20.h),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(5, (index) {
                    final current = index + 1;
                    return InkWell(
                      onTap: () => setState(() => _rating = current),
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 4.w),
                        child: Icon(
                          Icons.star_rounded,
                          size: 36.sp,
                          color: index < _rating ? const Color(0xFFFFD700) : const Color(0xFFE0E6F3),
                        ),
                      ),
                    );
                  }),
                ),
                SizedBox(height: 16.h),
                Text(
                  'Tap a star to rate',
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w700,
                    color: Colors.black,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 32.h),
          
          Text(
            'Customer Feedback',
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.w700,
              color: Colors.black,
            ),
          ),
          SizedBox(height: 12.h),
          Container(
            height: 100.h,
            padding: EdgeInsets.symmetric(horizontal: 14.w),
            decoration: BoxDecoration(
              color: const Color(0xFFF1F4F9),
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: TextField(
              controller: _commentController,
              maxLines: 4,
              decoration: InputDecoration(
                hintText: 'Customer\'s Comments',
                hintStyle: TextStyle(fontSize: 13.sp, color: const Color(0xFF8C96B5)),
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(vertical: 12.h),
              ),
            ),
          ),
          SizedBox(height: 24.h),
          
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Feedback Date',
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w700,
                        color: Colors.black,
                      ),
                    ),
                    SizedBox(height: 10.h),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF1F4F9),
                        borderRadius: BorderRadius.circular(10.r),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              '11/24/2023',
                              style: TextStyle(fontSize: 13.sp, color: const Color(0xFF445B87)),
                            ),
                          ),
                          Image.asset('assets/calendar.png', width: 16.sp, height: 16.sp),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(width: 16.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Agent ID',
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w700,
                        color: Colors.black,
                      ),
                    ),
                    SizedBox(height: 10.h),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF1F4F9),
                        borderRadius: BorderRadius.circular(10.r),
                      ),
                      child: Text(
                        'AOT-2201',
                        style: TextStyle(fontSize: 13.sp, color: const Color(0xFF445B87)),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          
          SizedBox(height: 32.h),
          
          Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 48.h,
                  child: OutlinedButton(
                    onPressed: () => _finishFlow(context),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Color(0xFF2644A6)),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                    ),
                    child: Text(
                      'Skip',
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF2644A6),
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(width: 16.w),
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
                      'Submit',
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 24.h),
        ],
      ),
    );
  }

  void _finishFlow(BuildContext context) {
    // Pop everything back to technicians dashboard which is assumed to be the home/first screen
    Navigator.of(context).popUntil((route) => route.isFirst);
  }
}
