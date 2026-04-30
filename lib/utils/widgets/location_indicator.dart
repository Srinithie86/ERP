import 'dart:async';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../device_service.dart';

class LocationIndicator extends StatefulWidget {
  final bool isDark;
  const LocationIndicator({super.key, this.isDark = false});

  @override
  State<LocationIndicator> createState() => _LocationIndicatorState();
}

class _LocationIndicatorState extends State<LocationIndicator> {
  bool _isServiceEnabled = true;
  StreamSubscription<ServiceStatus>? _serviceStatusSubscription;

  @override
  void initState() {
    super.initState();
    _checkStatus();
    _serviceStatusSubscription = Geolocator.getServiceStatusStream().listen((status) {
      if (mounted) {
        setState(() {
          _isServiceEnabled = status == ServiceStatus.enabled;
        });
      }
    });
  }

  Future<void> _checkStatus() async {
    bool enabled = await Geolocator.isLocationServiceEnabled();
    if (mounted) {
      setState(() {
        _isServiceEnabled = enabled;
      });
    }
  }

  @override
  void dispose() {
    _serviceStatusSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => DeviceService.forceFetchLocation(context),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
        decoration: BoxDecoration(
          color: _isServiceEnabled 
              ? const Color(0xFF26A69A).withValues(alpha: 0.1) 
              : Colors.red.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(20.r),
          border: Border.all(
            color: _isServiceEnabled 
                ? const Color(0xFF26A69A).withValues(alpha: 0.2) 
                : Colors.red.withValues(alpha: 0.2),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              _isServiceEnabled ? Icons.location_on : Icons.location_off,
              size: 14.sp,
              color: _isServiceEnabled ? const Color(0xFF26A69A) : Colors.red,
            ),
            SizedBox(width: 4.w),
            Text(
              _isServiceEnabled ? 'GPS ON' : 'GPS OFF',
              style: TextStyle(
                fontSize: 10.sp,
                fontWeight: FontWeight.bold,
                color: _isServiceEnabled ? const Color(0xFF26A69A) : Colors.red,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
