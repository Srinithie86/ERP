import 'package:flutter/material.dart';
import 'package:service_ticket/core/size_utils.dart';
import '../../core/app_colors.dart';

class AllDispatchCard extends StatelessWidget {
  const AllDispatchCard({
    super.key,
    required this.shipment,
  });

  final Map<String, dynamic> shipment;

  String _getMethodIcon(String method) {
    final m = method.toLowerCase();
    if (m.contains('bus')) return 'assets/bus_icon.png';
    if (m.contains('vechile')) return 'assets/vechile_icon.png';
    if (m.contains('travel')) return 'assets/travel_icon.png';
    if (m.contains('courier')) return 'assets/quantity_icon.png';
    return 'assets/dispatch.png';
  }

  @override
  Widget build(BuildContext context) {
    final bool isReceived = shipment['status'] == 'Received';
    final methodIcon = _getMethodIcon(shipment['method']);

    return Container(
      margin: EdgeInsets.only(bottom: 16.h),
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F5F9).withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                shipment['id'],
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w700,
                  color: Colors.black,
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 4.h),
                decoration: BoxDecoration(
                  color: isReceived ? const Color(0xFF45C95A) : const Color(0xFFC7833D),
                  borderRadius: BorderRadius.circular(20.r),
                ),
                child: Text(
                  shipment['status'],
                  style: TextStyle(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),

          // Date & Time Row
          Row(
            children: [
              _buildIconText(
                asset: 'assets/calendar_icon.png',
                text: shipment['date'],
              ),
              SizedBox(width: 24.w),
              _buildIconText(
                icon: Icons.access_time_filled_rounded,
                text: shipment['time'],
                iconColor: Colors.red.shade400,
              ),
            ],
          ),
          SizedBox(height: 12.h),

          // Divider
          Divider(color: Colors.grey.withValues(alpha: 0.2), thickness: 1.2),
          SizedBox(height: 12.h),

          // Footer Info Row
          Row(
            children: [
              _buildSmallIconText(
                icon: Icons.group_rounded,
                text: shipment['assignedTo'],
                iconColor: const Color(0xFF3B82F6),
              ),
              SizedBox(width: 8.w),
              _buildSmallIconText(
                asset: 'assets/call_icon.png',
                text: shipment['phone'],
              ),
              SizedBox(width: 8.w),
              _buildSmallIconText(
                asset: methodIcon,
                text: shipment['method'],
              ),
            ],
          ),
          SizedBox(height: 18.h),

          // Buttons
          Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 38.h,
                  child: OutlinedButton(
                    onPressed: () {},
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: AppColors.primary, width: 1.5),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                      foregroundColor: AppColors.primary,
                    ),
                    child: Text(
                      'Call',
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(width: 16.w),
              Expanded(
                child: SizedBox(
                  height: 38.h,
                  child: ElevatedButton(
                    onPressed: () {
                      showModalBottomSheet(
                        context: context,
                        isScrollControlled: true,
                        backgroundColor: Colors.transparent,
                        builder: (context) => _ShipmentDetailSheet(shipment: shipment),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                      elevation: 0,
                    ),
                    child: Text(
                      'View',
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
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

  Widget _buildIconText({String? asset, IconData? icon, required String text, Color? iconColor}) {
    return Row(
      children: [
        if (asset != null)
          Image.asset(asset, width: 18.w, height: 18.w)
        else
          Icon(icon, size: 18.sp, color: iconColor),
        SizedBox(width: 8.w),
        Text(
          text,
          style: TextStyle(
            fontSize: 13.5.sp,
            fontWeight: FontWeight.w500,
            color: const Color(0xFF475569),
          ),
        ),
      ],
    );
  }

  Widget _buildSmallIconText({String? asset, IconData? icon, required String text, Color? iconColor}) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (asset != null)
          Image.asset(asset, width: 14.w, height: 14.w)
        else
          Icon(icon, size: 14.sp, color: iconColor),
        SizedBox(width: 4.w),
        Flexible(
          child: Text(
            text,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 11.sp,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF64748B),
            ),
          ),
        ),
      ],
    );
  }
}

class _ShipmentDetailSheet extends StatefulWidget {
  const _ShipmentDetailSheet({required this.shipment});
  final Map<String, dynamic> shipment;

  @override
  State<_ShipmentDetailSheet> createState() => _ShipmentDetailSheetState();
}

class _ShipmentDetailSheetState extends State<_ShipmentDetailSheet> {
  String _selectedRole = 'Customer';

  @override
  Widget build(BuildContext context) {
    final shipment = widget.shipment;
    final bool isReceived = shipment['status'] == 'Received';
    final method = shipment['method'];

    String methodIcon = 'assets/dispatch.png';
    final m = method.toLowerCase();
    if (m.contains('bus')) {
      methodIcon = 'assets/bus_icon.png';
    } else if (m.contains('vechile')) {
      methodIcon = 'assets/vechile_icon.png';
    } else if (m.contains('travel')) {
      methodIcon = 'assets/travel_icon.png';
    } else if (m.contains('courier')) {
      methodIcon = 'assets/quantity_icon.png';
    }

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
      ),
      padding: EdgeInsets.fromLTRB(24.w, 12.h, 24.w, 24.h),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 48.w,
              height: 4.h,
              decoration: BoxDecoration(
                color: const Color(0xFFE2E8F0),
                borderRadius: BorderRadius.circular(2.r),
              ),
            ),
          ),
          SizedBox(height: 20.h),

          // Status Header Icon
          Center(
            child: Container(
              width: 64.w,
              height: 64.w,
              padding: EdgeInsets.all(12.r),
              decoration: BoxDecoration(
                color: isReceived ? const Color(0xFFD1FAE5) : const Color(0xFFFEF3C7),
                shape: BoxShape.circle,
              ),
              child: Image.asset(
                isReceived ? 'assets/received.png' : 'assets/pending_icon.png',
                fit: BoxFit.contain,
              ),
            ),
          ),
          SizedBox(height: 12.h),

          // Method Name
          Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(methodIcon, width: 20.w, height: 20.h),
                SizedBox(width: 8.w),
                Text(
                  method,
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF2E4CB9),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 24.h),

          // Dates Section
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Date of Transport',
                      style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.w700, color: Colors.black87),
                    ),
                    SizedBox(height: 6.h),
                    Row(
                      children: [
                        Text(shipment['date'], style: TextStyle(fontSize: 13.sp, color: const Color(0xFF64748B))),
                        SizedBox(width: 6.w),
                        Image.asset('assets/calendar_icon.png', width: 18.w),
                      ],
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Delivery Date',
                      style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.w700, color: Colors.black87),
                    ),
                    SizedBox(height: 6.h),
                    Row(
                      children: [
                        Text('13 /04 /2026', style: TextStyle(fontSize: 13.sp, color: const Color(0xFF64748B))),
                        SizedBox(width: 6.w),
                        Image.asset('assets/calendar_icon.png', width: 18.w),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 24.h),

          // Details List
          _buildDetailItem(
            asset: 'assets/people_icon.png',
            label: 'Contact Person',
            value: shipment['assignedTo'],
          ),
          SizedBox(height: 16.h),
          _buildDetailItem(
            asset: 'assets/location_icon.png',
            label: 'Address',
            value: 'Irugur, Ondipudur',
          ),
          SizedBox(height: 16.h),
          _buildDetailItem(
            asset: 'assets/caller_icon.png',
            label: 'Phone Number',
            value: shipment['phone'],
          ),
          SizedBox(height: 24.h),

          // Attachments
          Text(
            'Attachments',
            style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w800, color: Colors.black),
          ),
          SizedBox(height: 12.h),
          ClipRRect(
            borderRadius: BorderRadius.circular(12.r),
            child: Image.asset(
              'assets/parcel.png',
              width: double.infinity,
              height: 160.h,
              fit: BoxFit.cover,
            ),
          ),
          SizedBox(height: 24.h),

          // Final Actions
          if (!isReceived) ...[
            Text(
              'Call',
              style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.bold, color: Colors.black87),
            ),
            SizedBox(height: 10.h),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              decoration: BoxDecoration(
                color: const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _selectedRole,
                  isExpanded: true,
                  items: ['Customer', 'Contact Person'].map((val) {
                    return DropdownMenuItem<String>(
                      value: val,
                      child: Text(val, style: TextStyle(fontSize: 14.sp, color: const Color(0xFF64748B))),
                    );
                  }).toList(),
                  onChanged: (val) {
                    if (val != null) setState(() => _selectedRole = val);
                  },
                ),
              ),
            ),
            SizedBox(height: 20.h),
            _buildButton(
              label: 'Call',
              color: const Color(0xFF2E4CB9),
              onPressed: () => Navigator.pop(context),
            ),
          ] else
            _buildButton(
              label: 'Received',
              color: const Color(0xFF4ADE80),
              onPressed: () => Navigator.pop(context),
            ),
          SizedBox(height: 10.h),
        ],
      ),
    );
  }

  Widget _buildDetailItem({required String asset, required String label, required String value}) {
    return Row(
      children: [
        Image.asset(asset, width: 22.w, height: 22.h),
        SizedBox(width: 12.w),
        Text(
          label,
          style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w800, color: Colors.black),
        ),
        const Spacer(),
        Text(
          value,
          style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w500, color: const Color(0xFF2E4CB9)),
        ),
      ],
    );
  }

  Widget _buildButton({required String label, required Color color, required VoidCallback onPressed}) {
    return SizedBox(
      width: double.infinity,
      height: 48.h,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.r)),
          elevation: 0,
        ),
        child: Text(
          label,
          style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w700, color: Colors.white),
        ),
      ),
    );
  }
}
