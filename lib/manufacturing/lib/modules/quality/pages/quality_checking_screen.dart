import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter/material.dart';
import 'dart:ui';
import '../models/quality_model.dart';
import '../widgets/quality_widgets.dart';

class QualityCheckingScreen extends StatefulWidget {
  const QualityCheckingScreen({super.key});

  @override
  State<QualityCheckingScreen> createState() => _QualityCheckingScreenState();
}

class _QualityCheckingScreenState extends State<QualityCheckingScreen> {
  final List<QualityParameter> parameters = [
    QualityParameter(name: 'Power Output'),
    QualityParameter(name: 'Open Circuit Voltage'),
    QualityParameter(name: 'Short Circuit Current'),
    QualityParameter(name: 'Surface Condition'),
    QualityParameter(name: 'Frame Alignment'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color(0xFF26A69A),
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: Colors.white, size: 20.sp),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Checking',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: false,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(16.0.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Quality Parameters',
                style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 16.h),
              
              // Table Header
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
                decoration: BoxDecoration(
                  color: Color(0xFFF5F6FA),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(8.r),
                    topRight: Radius.circular(8.r),
                  ),
                ),
                child: Row(
                  children: [
                    SizedBox(width: 30.w, child: Text('S.no', style: TextStyle(fontWeight: FontWeight.w600))),
                    Expanded(child: Text('parameter', style: TextStyle(fontWeight: FontWeight.w600))),
                    SizedBox(width: 45.w, child: Text('Pass', textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.w600))),
                    SizedBox(width: 45.w, child: Text('Fail', textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.w600))),
                  ],
                ),
              ),
              
              // Parameters List
              ...parameters.asMap().entries.map((e) => QualityCheckRow(
                index: e.key,
                parameter: e.value,
                onChanged: (val) {
                  setState(() {
                    e.value.isPass = val;
                  });
                },
              )),
              
              SizedBox(height: 24.h),
              
              // Defects Section
              Container(
                padding: EdgeInsets.all(16.w),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16.r),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.03),
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
                        Container(
                          padding: EdgeInsets.all(6.w),
                          decoration: BoxDecoration(
                            color: Color(0xFFFFEBEE),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(Icons.warning_amber_rounded, color: Colors.red, size: 20.sp),
                        ),
                        SizedBox(width: 12.w),
                        Text(
                          'Defects',
                          style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold),
                        ),
                        Text('*', style: TextStyle(color: Colors.red, fontSize: 16.sp)),
                      ],
                    ),
                    SizedBox(height: 16.h),
                    Text('Description', style: TextStyle(color: Colors.grey, fontSize: 14.sp)),
                    SizedBox(height: 8.h),
                    Container(
                      height: 100.h,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                    ),
                    SizedBox(height: 24.h),
                    Text('Attachments', style: TextStyle(color: Colors.grey, fontSize: 14.sp)),
                    SizedBox(height: 12.h),
                    DashedBorderContainer(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.camera_alt_outlined, color: Colors.black54, size: 32.sp),
                          SizedBox(height: 8.h),
                          Text(
                            'JPG / PNG only\nMax: 5MB per image',
                            textAlign: TextAlign.center,
                            style: TextStyle(color: Colors.grey, fontSize: 11.sp),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 20.h),
            ],
          ),
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Container(
          padding: EdgeInsets.all(20.w),
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 4,
                offset: Offset(0, -1),
              ),
            ],
          ),
          child: SizedBox(
            width: double.infinity,
            height: 55.h,
            child: ElevatedButton(
              onPressed: () {
                // Submit logic
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Quality Check Submitted Successfully')),
                );
                Navigator.of(context).popUntil((route) => route.isFirst);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF4DB6AC),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30.r),
                ),
                elevation: 0,
              ),
              child: Text(
                'Submit',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class DashedBorderContainer extends StatelessWidget {
  final Widget child;
  const DashedBorderContainer({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 140.h,
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: CustomPaint(
        painter: DashPainter(),
        child: Center(child: child),
      ),
    );
  }
}

class DashPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.grey[300]!
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    const dashWidth = 8.0;
    const dashSpace = 4.0;
    
    final RRect rrect = RRect.fromLTRBR(0, 0, size.width, size.height, Radius.circular(12.r));
    final Path path = Path()..addRRect(rrect);

    for (final PathMetric metric in path.computeMetrics()) {
      double distance = 0;
      while (distance < metric.length) {
        canvas.drawPath(
          metric.extractPath(distance, distance + dashWidth),
          paint,
        );
        distance += dashWidth + dashSpace;
      }
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
