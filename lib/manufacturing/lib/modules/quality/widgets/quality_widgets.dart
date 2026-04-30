import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter/material.dart';
import '../models/quality_model.dart';

class QualityProductCard extends StatelessWidget {
  final QualityItem item;
  final VoidCallback onTap;

  const QualityProductCard({
    super.key,
    required this.item,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    item.productName,
                    style: TextStyle(
                      color: Color(0xFF26A69A),
                      fontSize: 16.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Text(
                  item.date,
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 12.sp,
                  ),
                ),
              ],
            ),
            SizedBox(height: 4.h),
            Text(
              item.productId,
              style: TextStyle(
                color: Colors.black87,
                fontSize: 14.sp,
                fontWeight: FontWeight.w500,
              ),
            ),
            SizedBox(height: 8.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                RichText(
                  text: TextSpan(
                    style: TextStyle(fontSize: 14.sp),
                    children: [
                      TextSpan(
                        text: item.batchId,
                        style: TextStyle(color: Color(0xFFFF8B8B)),
                      ),
                      const TextSpan(
                        text: '  •  ',
                        style: TextStyle(color: Colors.green),
                      ),
                      TextSpan(
                        text: item.productCode,
                        style: TextStyle(color: Color(0xFF4CAF50)),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFE0B2),
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: Text(
                    item.quantityBadge,
                    style: TextStyle(
                      color: Color(0xFFFB8C00),
                      fontSize: 12.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class QualityInfoRow extends StatelessWidget {
  final String label;
  final String value;
  final bool isBoldValue;
  final bool isTextArea;

  const QualityInfoRow({
    super.key,
    required this.label,
    required this.value,
    this.isBoldValue = true,
    this.isTextArea = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 12.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              color: Colors.grey[500],
              fontSize: 14.sp,
            ),
          ),
          SizedBox(height: 8.h),
          if (isTextArea)
            Container(
              width: double.infinity,
              height: 100.h,
              padding: EdgeInsets.all(12.w),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Text(
                value,
                style: TextStyle(
                  color: Colors.black87,
                  fontSize: 16.sp,
                  fontWeight: isBoldValue ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            )
          else
            Text(
              value,
              style: TextStyle(
                color: Colors.black,
                fontSize: 16.sp,
                fontWeight: isBoldValue ? FontWeight.bold : FontWeight.normal,
              ),
            ),
        ],
      ),
    );
  }
}

class QualityCheckRow extends StatelessWidget {
  final int index;
  final QualityParameter parameter;
  final Function(bool?) onChanged;

  const QualityCheckRow({
    super.key,
    required this.index,
    required this.parameter,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 8.h),
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(color: Colors.blue.withOpacity(0.1)),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 30.w,
            child: Text(
              '${index + 1}',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: Text(
              parameter.name,
              style: TextStyle(fontSize: 14.sp, color: Colors.black87),
            ),
          ),
          _buildCheckbox(
            value: parameter.isPass == true,
            activeColor: Colors.green,
            onChanged: (v) => onChanged(v == true ? true : null),
          ),
          SizedBox(width: 25.w),
          _buildCheckbox(
            value: parameter.isPass == false,
            activeColor: Colors.red,
            onChanged: (v) => onChanged(v == true ? false : null),
          ),
          SizedBox(width: 8.w),
        ],
      ),
    );
  }

  Widget _buildCheckbox({
    required bool value,
    required Color activeColor,
    required Function(bool?) onChanged,
  }) {
    return GestureDetector(
      onTap: () => onChanged(!value),
      child: Container(
        width: 22.w,
        height: 22.h,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(4.r),
          border: Border.all(
            color: value ? activeColor : Colors.grey[400]!,
            width: 1.5.w,
          ),
          color: value ? activeColor.withOpacity(0.1) : Colors.transparent,
        ),
        child: value
            ? Icon(Icons.check, size: 16.sp, color: activeColor)
            : null,
      ),
    );
  }
}
