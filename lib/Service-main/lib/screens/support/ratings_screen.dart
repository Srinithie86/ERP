import 'package:flutter/material.dart';
import 'package:service_ticket/Widgets/app_status_bar_wrapper.dart';
import 'package:service_ticket/core/size_utils.dart';

class RatingsScreen extends StatefulWidget {
  const RatingsScreen({super.key});

  @override
  State<RatingsScreen> createState() => _RatingsScreenState();
}

class _RatingsScreenState extends State<RatingsScreen> {
  int _userRating = 4;
  final TextEditingController _feedbackController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: AppStatusBarWrapper(
        child: SafeArea(
          top: false,
          bottom: false,
          child: Column(
            children: [
              // Header
              Padding(
                padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 18.h),
                child: Row(
                  children: [
                    InkWell(
                      onTap: () => Navigator.pop(context),
                      child: Icon(Icons.arrow_back_rounded, color: const Color(0xFF2644A6), size: 28.sp),
                    ),
                    SizedBox(width: 12.w),
                    Text(
                      'Ratings & Reviews',
                      style: TextStyle(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF2644A6),
                      ),
                    ),
                  ],
                ),
              ),

              Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsets.symmetric(horizontal: 16.w),
                  child: Column(
                    children: [
                      // Overall Rating card
                      Container(
                        width: double.infinity,
                        padding: EdgeInsets.symmetric(vertical: 24.h),
                        decoration: BoxDecoration(
                          color: const Color(0xFF2644A6),
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                        child: Column(
                          children: [
                            Text(
                              '4.6',
                              style: TextStyle(
                                fontSize: 44.sp,
                                fontWeight: FontWeight.w800,
                                color: Colors.white,
                              ),
                            ),
                            SizedBox(height: 8.h),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: List.generate(
                                5,
                                (index) => Icon(
                                  index < 4 ? Icons.star_rounded : (index < 5 && index == 4 ? Icons.star_half_rounded : Icons.star_outline_rounded),
                                  size: 32.sp,
                                  color: index < 5 ? const Color(0xFFFFD700) : Colors.white70,
                                ),
                              ),
                            ),
                            SizedBox(height: 12.h),
                            Text(
                              'Based on 48 Reviews',
                              style: TextStyle(
                                fontSize: 13.sp,
                                color: Colors.white,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),

                      SizedBox(height: 24.h),

                      // User Input card
                      Container(
                        width: double.infinity,
                        padding: EdgeInsets.all(16.r),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12.r),
                          border: Border.all(color: Colors.grey.shade300),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Your Rating For #TK-2024-0029',
                              style: TextStyle(
                                fontSize: 13.sp,
                                fontWeight: FontWeight.w700,
                                color: Colors.black,
                              ),
                            ),
                            SizedBox(height: 12.h),
                            Row(
                              children: List.generate(
                                5,
                                (index) => InkWell(
                                  onTap: () => setState(() => _userRating = index + 1),
                                  child: Icon(
                                    Icons.star_rounded,
                                    size: 26.sp,
                                    color: index < _userRating 
                                        ? const Color(0xFFFFD700) 
                                        : Colors.grey.shade300,
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(height: 20.h),
                            Container(
                              height: 100.h,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10.r),
                                border: Border.all(color: Colors.grey.shade300),
                              ),
                              child: TextField(
                                controller: _feedbackController,
                                maxLines: 5,
                                decoration: InputDecoration(
                                  contentPadding: EdgeInsets.all(12.r),
                                  border: InputBorder.none,
                                  hintText: 'Type your feedback here...',
                                  hintStyle: TextStyle(fontSize: 12.sp, color: Colors.grey),
                                ),
                              ),
                            ),
                            SizedBox(height: 20.h),
                            SizedBox(
                              width: double.infinity,
                              height: 48.h,
                              child: ElevatedButton(
                                onPressed: () {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text('Review submitted successfully!')),
                                  );
                                  Navigator.pop(context);
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF2644A6),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10.r),
                                  ),
                                  elevation: 0,
                                ),
                                child: Text(
                                  'Submit Review',
                                  style: TextStyle(
                                    fontSize: 14.sp,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
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
