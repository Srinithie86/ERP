import 'package:flutter/material.dart';
import 'package:service_ticket/core/size_utils.dart';
import '../../Widgets/app_status_bar_wrapper.dart';
import '../../data/app_data.dart';
import 'all_dispatch_card.dart';

class AllDispatchScreen extends StatelessWidget {
  const AllDispatchScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final appData = AppData.instance;
    final shipments = appData.shipments;
    final totalCount = appData.totalShipmentCount;
    final receivedCount = appData.receivedShipmentCount;

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
                padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 8.h),
                child: Row(
                  children: [
                    InkWell(
                      onTap: () => Navigator.pop(context),
                      borderRadius: BorderRadius.circular(20.r),
                      child: Padding(
                        padding: EdgeInsets.all(4.r),
                        child: Icon(
                          Icons.arrow_back,
                          size: 22.sp,
                          color: const Color(0xFF2E4CB9),
                        ),
                      ),
                    ),
                    SizedBox(width: 8.w),
                    Text(
                      'All Shipments',
                      style: TextStyle(
                        fontSize: 20.sp,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF2E4CB9),
                      ),
                    ),
                  ],
                ),
              ),

              Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 20.h),
                  child: Column(
                    children: [
                      // Summary
                      Row(
                        children: [
                          Expanded(
                            child: _SummaryBox(
                              count: '$totalCount',
                              label: 'TOTAL',
                              colors: const [
                                Color(0xFF1B8A35),
                                Color(0xFF0F6122),
                              ],
                            ),
                          ),
                          SizedBox(width: 14.w),
                          Expanded(
                            child: _SummaryBox(
                              count: '$receivedCount',
                              label: 'RECEIVED',
                              colors: const [
                                Color(0xFFE55767),
                                Color(0xFFB9424F),
                              ],
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 24.h),

                      // Shipment List
                      ...shipments.map(
                        (shipment) => AllDispatchCard(shipment: shipment),
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

class _SummaryBox extends StatelessWidget {
  const _SummaryBox({
    required this.count,
    required this.label,
    required this.colors,
  });

  final String count;
  final String label;
  final List<Color> colors;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 90.h,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: colors,
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        borderRadius: BorderRadius.circular(10.r),
        boxShadow: [
          BoxShadow(
            color: colors.last.withValues(alpha: 0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            count,
            style: TextStyle(
              fontSize: 26.sp,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
          SizedBox(height: 2.h),
          Text(
            label,
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}
