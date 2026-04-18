import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

class DashboardSubScreen extends StatelessWidget {
  const DashboardSubScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const primaryColor = Color(0xFF26A69A);
    
    return Stack(
      children: [
        // Subtle 3D background element for Dashboard
        Positioned(
          top: -40.h,
          right: -60.w,
          child: Opacity(
            opacity: 0.05,
            child: Image.asset(
              'assets/images/animation_object.png',
              width: 180.w,
              fit: BoxFit.contain,
            ),
          ),
        ).animate(onPlay: (controller) => controller.repeat(reverse: true))
         .moveY(begin: 0, end: 15, duration: 4.seconds),

        SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 20.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Search Bar (Professional 3D look)
              Container(
                padding: EdgeInsets.symmetric(horizontal: 18.w),
                height: 56.h,
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(16.r),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.04),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: TextField(
                  decoration: InputDecoration(
                    icon: Icon(Icons.search_rounded, color: primaryColor, size: 24.w),
                    hintText: 'Search business data...',
                    hintStyle: GoogleFonts.outfit(
                      color: Colors.grey.shade400,
                      fontSize: 15.sp,
                    ),
                    border: InputBorder.none,
                  ),
                  style: GoogleFonts.outfit(color: Theme.of(context).textTheme.bodyLarge?.color, fontSize: 15.sp),
                ),
              ).animate().fadeIn(duration: 400.ms).slideX(begin: -0.05),
              
              SizedBox(height: 32.h),
              
              // Section Title
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Key Metrics',
                    style: GoogleFonts.outfit(fontSize: 22.sp, fontWeight: FontWeight.w800),
                  ),
                  Text(
                    'Last 30 days',
                    style: GoogleFonts.outfit(color: Colors.grey.shade500, fontSize: 13.sp, fontWeight: FontWeight.w500),
                  ),
                ],
              ).animate().fadeIn(delay: 200.ms),
              
              SizedBox(height: 20.h),
              
              // Metric Cards Grid
              GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                crossAxisSpacing: 16.w,
                mainAxisSpacing: 16.h,
                childAspectRatio: 1.2,
                children: [
                  _buildMetricCard(
                    'Total Sales',
                    '₹ 56,240',
                    '+12.5%',
                    [const Color(0xFF00796B), const Color(0xFF26A69A)],
                    Icons.trending_up_rounded,
                  ),
                  _buildMetricCard(
                    'Total Orders',
                    '1,235',
                    '+8.3%',
                    [const Color(0xFF1E3A8A), const Color(0xFF3B82F6)],
                    Icons.shopping_bag_rounded,
                  ),
                  _buildMetricCard(
                    'New Customers',
                    '850',
                    '+15.2%',
                    [const Color(0xFF4338CA), const Color(0xFF6366F1)],
                    Icons.people_alt_rounded,
                  ),
                  _buildMetricCard(
                    'Pending Tasks',
                    '320',
                    '-2.4%',
                    [const Color(0xFF913175), const Color(0xFFCD5888)],
                    Icons.task_alt_rounded,
                  ),
                ],
              ).animate().fadeIn(delay: 300.ms).slideY(begin: 0.1),
              
              SizedBox(height: 36.h),
              
              // Sales Overview Chart (3D Elevated Card)
              _buildCardSection(
                context,
                title: 'Sales Performance',
                action: Container(
                  padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                  decoration: BoxDecoration(
                    color: primaryColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                  child: Text(
                    'Monthly',
                    style: GoogleFonts.outfit(
                      color: primaryColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 12.sp,
                    ),
                  ),
                ),
                child: SizedBox(
                   height: 200.h,
                   child: Center(
                     child: CustomPaint(
                       size: Size(double.infinity, 180.h),
                       painter: SimpleLineChartPainter(
                         gridColor: Theme.of(context).dividerColor.withValues(alpha: 0.08),
                         primaryColor: primaryColor,
                       ),
                     ),
                   ),
                ),
              ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.1),
              
              SizedBox(height: 24.h),
              
              // Recent Activity Table
              _buildCardSection(
                context,
                title: 'Recent Activity',
                child: Column(
                  children: [
                    _buildTableHeader(context),
                    _buildTableRow(context, '#1024', 'Alice Smith', 'Completed', const Color(0xFF10B981), '₹250'),
                    _buildTableRow(context, '#1025', 'Michael Lee', 'Pending', const Color(0xFFF59E0B), '₹150'),
                    _buildTableRow(context, '#1026', 'David Kim', 'Cancelled', const Color(0xFFEF4444), '₹340'),
                  ],
                ),
              ).animate().fadeIn(delay: 500.ms).slideY(begin: 0.1),
              
              SizedBox(height: 24.h),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMetricCard(String title, String value, String percentage, List<Color> colors, IconData icon) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: colors,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24.r),
        boxShadow: [
          BoxShadow(
            color: colors.first.withValues(alpha: 0.25),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            right: -10.w,
            bottom: -10.w,
            child: Icon(
              icon,
              size: 48.w,
              color: Colors.white.withValues(alpha: 0.12),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: EdgeInsets.all(8.w),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: Colors.white, size: 18.w),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.outfit(
                      color: Colors.white.withValues(alpha: 0.9),
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          value,
                          style: GoogleFonts.outfit(
                            color: Colors.white,
                            fontSize: 18.sp,
                            fontWeight: FontWeight.w800,
                            letterSpacing: -0.5,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      SizedBox(width: 4.w),
                      Text(
                        percentage,
                        style: GoogleFonts.outfit(
                          color: Colors.white70,
                          fontSize: 10.sp,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCardSection(BuildContext context, {required String title, Widget? action, required Widget child}) {
    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(24.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: Theme.of(context).brightness == Brightness.dark ? 0.3 : 0.04),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
        border: Border.all(
          color: Theme.of(context).dividerColor.withValues(alpha: 0.04),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: GoogleFonts.outfit(fontSize: 18.sp, fontWeight: FontWeight.w800),
              ),
              if (action != null) action,
            ],
          ),
          SizedBox(height: 20.h),
          child,
        ],
      ),
    );
  }

  Widget _buildTableHeader(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: EdgeInsets.symmetric(vertical: 14.h, horizontal: 4.w),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: isDark ? Colors.grey.shade800 : Colors.grey.shade100,
          ),
        ),
      ),
      child: Row(
        children: [
          Expanded(flex: 1, child: Text('ID', style: GoogleFonts.outfit(color: Colors.grey.shade500, fontWeight: FontWeight.bold, fontSize: 11.sp))),
          Expanded(flex: 3, child: Text('Customer', style: GoogleFonts.outfit(color: Colors.grey.shade500, fontWeight: FontWeight.bold, fontSize: 11.sp))),
          Expanded(flex: 2, child: Text('Status', style: GoogleFonts.outfit(color: Colors.grey.shade500, fontWeight: FontWeight.bold, fontSize: 11.sp))),
          Expanded(flex: 2, child: Text('Amount', textAlign: TextAlign.right, style: GoogleFonts.outfit(color: Colors.grey.shade500, fontWeight: FontWeight.bold, fontSize: 11.sp))),
        ],
      ),
    );
  }

  Widget _buildTableRow(BuildContext context, String id, String user, String status, Color statusColor, String amount) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: EdgeInsets.symmetric(vertical: 16.h, horizontal: 4.w),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: isDark ? Colors.grey.shade800 : Colors.grey.shade50,
          ),
        ),
      ),
      child: Row(
        children: [
          Expanded(flex: 1, child: Text(id, style: GoogleFonts.outfit(color: const Color(0xFF26A69A), fontWeight: FontWeight.bold, fontSize: 12.sp))),
          Expanded(flex: 3, child: Text(user, style: GoogleFonts.outfit(color: Theme.of(context).textTheme.bodyLarge?.color, fontSize: 13.sp, fontWeight: FontWeight.w600))),
          Expanded(
            flex: 2, 
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 3.h),
              decoration: BoxDecoration(
                color: statusColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(6.r),
              ),
              child: Text(
                status, 
                style: GoogleFonts.outfit(color: statusColor, fontWeight: FontWeight.bold, fontSize: 10.sp),
                textAlign: TextAlign.center,
              ),
            ),
          ),
          Expanded(flex: 2, child: Text(amount, textAlign: TextAlign.right, style: GoogleFonts.outfit(fontWeight: FontWeight.w800, fontSize: 13.sp))),
        ],
      ),
    );
  }
}

class SimpleLineChartPainter extends CustomPainter {
  final Color gridColor;
  final Color primaryColor;
  SimpleLineChartPainter({required this.gridColor, required this.primaryColor});

  @override
  void paint(Canvas canvas, Size size) {
    final paint1 = Paint()
      ..color = primaryColor
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
      
    final fillPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [primaryColor.withValues(alpha: 0.2), primaryColor.withValues(alpha: 0)],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    final gridPaint = Paint()
      ..color = gridColor
      ..strokeWidth = 1;

    for (int i = 0; i <= 4; i++) {
       double y = size.height - (i * size.height / 4);
       canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }

    final path = Path();
    path.moveTo(0, size.height * 0.8);
    path.cubicTo(
      size.width * 0.2, size.height * 0.8,
      size.width * 0.4, size.height * 0.2,
      size.width * 0.6, size.height * 0.5,
    );
    path.cubicTo(
      size.width * 0.8, size.height * 0.8,
      size.width * 0.9, size.height * 0.1,
      size.width, size.height * 0.3,
    );

    final fillPath = Path.from(path);
    fillPath.lineTo(size.width, size.height);
    fillPath.lineTo(0, size.height);
    fillPath.close();

    canvas.drawPath(fillPath, fillPaint);
    canvas.drawPath(path, paint1);

    // Points
    final dotPaint = Paint()..color = primaryColor..style = PaintingStyle.fill;
    final dotOuterPaint = Paint()..color = Colors.white..style = PaintingStyle.fill;
    
    _drawPoint(canvas, Offset(size.width * 0.6, size.height * 0.5), dotOuterPaint, dotPaint);
    _drawPoint(canvas, Offset(size.width, size.height * 0.3), dotOuterPaint, dotPaint);
  }

  void _drawPoint(Canvas canvas, Offset offset, Paint outer, Paint inner) {
    canvas.drawCircle(offset, 6, outer);
    canvas.drawCircle(offset, 4, inner);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
