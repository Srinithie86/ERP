import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CallConfirmationPopup extends StatelessWidget {
  final Map<String, dynamic> lead;
  final VoidCallback onConfirm;
  final VoidCallback onCancel;

  const CallConfirmationPopup({
    super.key,
    required this.lead,
    required this.onConfirm,
    required this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    final name = (lead['le_name'] ?? lead['cus_name'])?.toString() ?? 'Unknown';
    final phone = (lead['mobile_1'] ?? lead['mobile_2'] ?? '').toString();
    final status = (lead['lead_status'] ?? lead['status'] ?? 'New Lead').toString();

    return Container(
      padding: EdgeInsets.fromLTRB(24.w, 12.h, 24.w, 40.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(32.r)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle
          Container(
            width: 60.w,
            height: 4.h,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(2.r),
            ),
          ),
          SizedBox(height: 24.h),
          Text(
            'Confirm Call',
            style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 16.h),
          const Divider(thickness: 1, color: Color(0xFFEEEEEE)),
          SizedBox(height: 24.h),
          // Profile Row
          Row(
            children: [
              Container(
                width: 64.w,
                height: 64.w,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.grey.shade400, width: 2.w),
                ),
                child: Icon(Icons.person_outline, size: 36.r, color: Colors.grey),
              ),
              SizedBox(width: 20.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: TextStyle(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      phone,
                      style: TextStyle(fontSize: 16.sp, color: Colors.grey.shade600),
                    ),
                    SizedBox(height: 8.h),
                    Row(
                      children: [
                        Text('Status: ',
                            style: TextStyle(
                                color: Colors.grey.shade600, fontSize: 13.sp)),
                        SizedBox(width: 4.w),
                        Container(
                          padding: EdgeInsets.symmetric(
                              horizontal: 12.w, vertical: 4.h),
                          decoration: BoxDecoration(
                            color: const Color(0xFF4A80C9),
                            borderRadius: BorderRadius.circular(6.r),
                          ),
                          child: Text(
                            status,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 12.sp,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 24.h),
          const Divider(thickness: 1, color: Color(0xFFEEEEEE)),
          SizedBox(height: 24.h),
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'Do you want to call this lead?',
              style: TextStyle(fontSize: 16.sp, color: Colors.grey.shade600),
            ),
          ),
          SizedBox(height: 40.h),
          // Buttons
          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: onCancel,
                  child: Container(
                    height: 52.h,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade300),
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    child: Center(
                      child: Text(
                        'Cancel',
                        style: TextStyle(
                            fontSize: 16.sp, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(width: 16.w),
              Expanded(
                child: GestureDetector(
                  onTap: onConfirm,
                  child: Container(
                    height: 52.h,
                    decoration: BoxDecoration(
                      color: const Color(0xFF4CAF50),
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    child: Center(
                      child: Text(
                        'Call Now',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
