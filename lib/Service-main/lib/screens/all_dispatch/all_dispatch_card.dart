import 'package:flutter/material.dart';
import 'package:service_ticket/core/size_utils.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/app_colors.dart';
import '../../models/dispatch_model.dart';

class AllDispatchCard extends StatelessWidget {
  const AllDispatchCard({super.key, required this.t1, this.t2});

  final T1 t1;
  final T2? t2;

  String _getMethodIcon(String method) {
    final m = method.toLowerCase();
    if (m.contains('bus')) return 'assets/bus_icon.png';
    if (m.contains('vechile')) return 'assets/vechile_icon.png';
    if (m.contains('travel')) return 'assets/travel_icon.png';
    if (m.contains('courier')) return 'assets/quantity_icon.png';
    return 'assets/dispatch.png';
  }

  String _getTranModeText(String mode) {
    final m = mode.toUpperCase();
    if (m == "1" || m.contains("BUS")) {
      return "By Bus";
    } else if (m == "2" || m.contains("COURIER")) {
      return "By Courier";
    } else {
      return "By Vehicle";
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isReceived = t2 != null;
    final statusText = t2 != null ? 'Received' : t1.status;

    final String displayId = t2 != null
        ? "Parcel No --${t2!.id.toString().padLeft(3, '0')}"
        : "Parcel No --${t1.id.toString().padLeft(3, '0')}";

    final String methodText = t2 != null
        ? _getTranModeText(t2!.tranMode)
        : "Not Dispatched";

    final methodIcon = _getMethodIcon(methodText);

    String displayDate = t1.dtime;
    String displayTime = "";
    if (t1.dtime.contains(' ')) {
      final parts = t1.dtime.split(' ');
      final dateParts = parts[0].split('-');
      if (dateParts.length == 3) {
        displayDate = "${dateParts[2]}/${dateParts[1]}/${dateParts[0]}";
      }
      if (parts[1].contains(':')) {
        final timeParts = parts[1].split(':');
        if (timeParts.length >= 2) {
          displayTime = "${timeParts[0]}:${timeParts[1]}";
        }
      }
    }

    return Container(
      margin: EdgeInsets.only(bottom: 16.h),
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F5F9).withOpacity(0.5),
        borderRadius: BorderRadius.circular(12.r),
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
          // Header Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                displayId,
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w700,
                  color: Colors.black,
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 4.h),
                decoration: BoxDecoration(
                  color: isReceived
                      ? const Color(0xFF45C95A)
                      : const Color(0xFFC7833D),
                  borderRadius: BorderRadius.circular(20.r),
                ),
                child: Text(
                  statusText,
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
                text: displayDate,
              ),
              if (displayTime.isNotEmpty) ...[
                SizedBox(width: 24.w),
                _buildIconText(
                  icon: Icons.access_time_filled_rounded,
                  text: displayTime,
                  iconColor: Colors.red.shade400,
                ),
              ],
            ],
          ),
          SizedBox(height: 12.h),

          // Divider
          Divider(color: Colors.grey.withOpacity(0.2), thickness: 1.2),
          SizedBox(height: 12.h),

          // Footer Info Row
          Row(
            children: [
              Expanded(
                flex: 3,
                child: _buildSmallIconText(
                  icon: Icons.group_rounded,
                  text: t1.bName,
                  iconColor: const Color(0xFF3B82F6),
                ),
              ),
              if (t2 != null) ...[
                SizedBox(width: 8.w),
                Expanded(
                  flex: 2,
                  child: _buildSmallIconText(
                    asset: 'assets/call_icon.png',
                    text: t2!.mobileNo,
                  ),
                ),
              ],
              SizedBox(width: 8.w),
              Expanded(
                flex: 2,
                child: _buildSmallIconText(asset: methodIcon, text: methodText),
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
                    onPressed: t2 != null
                        ? () async {
                            final Uri launchUri = Uri(
                              scheme: 'tel',
                              path: t2!.mobileNo,
                            );
                            if (await canLaunchUrl(launchUri)) {
                              await launchUrl(launchUri);
                            }
                          }
                        : null,
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(
                        color: t2 != null ? AppColors.primary : Colors.grey,
                        width: 1.5,
                      ),
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
                        color: t2 != null ? AppColors.primary : Colors.grey,
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
                        builder: (context) =>
                            _ShipmentDetailSheet(t1: t1, t2: t2),
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

  Widget _buildIconText({
    String? asset,
    IconData? icon,
    required String text,
    Color? iconColor,
  }) {
    return Row(
      children: [
        if (asset != null)
          Image.asset(asset, package: 'service_ticket', width: 18.w, height: 18.w)
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

  Widget _buildSmallIconText({
    String? asset,
    IconData? icon,
    required String text,
    Color? iconColor,
  }) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (asset != null)
          Image.asset(asset, package: 'service_ticket', width: 14.w, height: 14.w)
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
  const _ShipmentDetailSheet({required this.t1, this.t2});
  final T1 t1;
  final T2? t2;

  @override
  State<_ShipmentDetailSheet> createState() => _ShipmentDetailSheetState();
}

class _ShipmentDetailSheetState extends State<_ShipmentDetailSheet> {
  String _selectedRole = 'Customer';

  String _getTranModeText(String mode) {
    final m = mode.toUpperCase();
    if (m == "1" || m.contains("BUS")) {
      return "By Bus";
    } else if (m == "2" || m.contains("COURIER")) {
      return "By Courier";
    } else {
      return "By Vehicle";
    }
  }

  void _showFullScreenImage(BuildContext context, String url) {
    showDialog(
      context: context,
      builder: (_) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: EdgeInsets.zero,
        child: Stack(
          alignment: Alignment.center,
          children: [
            GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                width: double.infinity,
                height: double.infinity,
                color: Colors.black54,
              ),
            ),
            Container(
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.9,
                maxHeight: MediaQuery.of(context).size.height * 0.8,
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12.r),
                child: Image.network(
                  url,
                  fit: BoxFit.contain,
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return const Center(child: CircularProgressIndicator());
                  },
                ),
              ),
            ),
            Positioned(
              top: 40.h,
              right: 20.w,
              child: IconButton(
                icon: Icon(
                  Icons.close_rounded,
                  color: Colors.white,
                  size: 30.sp,
                ),
                onPressed: () => Navigator.pop(context),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final t1 = widget.t1;
    final t2 = widget.t2;

    final bool isReceived = t2 != null;
    final methodText = isReceived
        ? _getTranModeText(t2.tranMode)
        : "Not Dispatched";

    String methodIcon = 'assets/dispatch.png';
    final m = methodText.toLowerCase();
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
      child: SingleChildScrollView(
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
                  color: isReceived
                      ? const Color(0xFFD1FAE5)
                      : const Color(0xFFFEF3C7),
                  shape: BoxShape.circle,
                ),
                child: Image.asset(
                  isReceived
                      ? 'assets/received.png'
                      : 'assets/pending_icon.png',
                  package: 'service_ticket',
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
                  Image.asset(methodIcon, package: 'service_ticket', width: 20.w, height: 20.h),
                  SizedBox(width: 8.w),
                  Flexible(
                    child: Text(
                      methodText,
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF2E4CB9),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
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
                        style: TextStyle(
                          fontSize: 13.sp,
                          fontWeight: FontWeight.w700,
                          color: Colors.black87,
                        ),
                      ),
                      SizedBox(height: 6.h),
                      Row(
                        children: [
                          Text(
                            t2?.dateOfTran ?? "N/A",
                            style: TextStyle(
                              fontSize: 13.sp,
                              color: const Color(0xFF64748B),
                            ),
                          ),
                          SizedBox(width: 6.w),
                          Image.asset('assets/calendar_icon.png', package: 'service_ticket', width: 18.w),
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
                        style: TextStyle(
                          fontSize: 13.sp,
                          fontWeight: FontWeight.w700,
                          color: Colors.black87,
                        ),
                      ),
                      SizedBox(height: 6.h),
                      Row(
                        children: [
                          Text(
                            t2?.expDelivery ?? "N/A",
                            style: TextStyle(
                              fontSize: 13.sp,
                              color: const Color(0xFF64748B),
                            ),
                          ),
                          SizedBox(width: 6.w),
                          Image.asset('assets/calendar_icon.png', package: 'service_ticket', width: 18.w),
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
              value: t2?.cusName ?? "N/A",
            ),
            SizedBox(height: 16.h),
            _buildDetailItem(
              asset: 'assets/location_icon.png',
              label: 'Address',
              value: t1.bAdd1,
            ),
            SizedBox(height: 16.h),
            _buildDetailItem(
              asset: 'assets/caller_icon.png',
              label: 'Phone Number',
              value: t2?.mobileNo ?? "N/A",
            ),
            SizedBox(height: 24.h),

            // Attachments
            if (t2 != null && t2.image.isNotEmpty) ...[
              Text(
                'Attachments',
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w800,
                  color: Colors.black,
                ),
              ),
              SizedBox(height: 12.h),
              GestureDetector(
                onTap: () => _showFullScreenImage(context, t2.image),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12.r),
                  child: Image.network(
                    t2.image,
                    width: double.infinity,
                    height: 160.h,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      height: 160.h,
                      color: Colors.grey.shade200,
                      child: const Icon(Icons.broken_image, color: Colors.grey),
                    ),
                  ),
                ),
              ),
              SizedBox(height: 24.h),
            ],

            // Final Actions
            if (t2 != null) ...[
              Text(
                'Call',
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
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
                        child: Text(
                          val,
                          style: TextStyle(
                            fontSize: 14.sp,
                            color: const Color(0xFF64748B),
                          ),
                        ),
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
                onPressed: () async {
                  final phone = _selectedRole == 'Customer'
                      ? t2.mobileNo
                      : t2.contactPersonMobile;
                  final Uri launchUri = Uri(scheme: 'tel', path: phone);
                  if (await canLaunchUrl(launchUri)) {
                    await launchUrl(launchUri);
                  }
                },
              ),
            ] else
              _buildButton(
                label: 'Pending Dispatch',
                color: const Color(0xFFC7833D),
                onPressed: () => Navigator.pop(context),
              ),
            SizedBox(height: 10.h),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailItem({
    required String asset,
    required String label,
    required String value,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(top: 2.h),
          child: Image.asset(asset, package: 'service_ticket', width: 22.w, height: 22.h),
        ),
        SizedBox(width: 12.w),
        Text(
          label,
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.w800,
            color: Colors.black,
          ),
        ),
        SizedBox(width: 12.w),
        Expanded(
          child: Text(
            value,
            textAlign: TextAlign.right,
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.w500,
              color: const Color(0xFF2E4CB9),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildButton({
    required String label,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return SizedBox(
      width: double.infinity,
      height: 48.h,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.r),
          ),
          elevation: 0,
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}
