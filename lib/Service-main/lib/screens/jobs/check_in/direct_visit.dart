import 'dart:async';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:geolocator/geolocator.dart';
import 'package:service_ticket/core/size_utils.dart';
import '../../../Widgets/app_status_bar_wrapper.dart';
import '../../../core/app_colors.dart';
import '../../../Widgets/workflow_stepper.dart';
import '../../../data/app_data.dart';
import 'direct_visit_camera_screen.dart';

class DirectVisitScreen extends StatefulWidget {
  const DirectVisitScreen({super.key, this.jobData});

  final Map<String, dynamic>? jobData;

  @override
  State<DirectVisitScreen> createState() => _DirectVisitScreenState();
}

class _DirectVisitScreenState extends State<DirectVisitScreen> {
  bool _liveLocationEnabled = false;
  bool _locationBusy = false;
  String _locationStatus = 'Turn on location to fetch the job location.';
  Timer? _visitTimer;
  Duration _visitElapsed = Duration.zero;

  @override
  void initState() {
    super.initState();
    _startVisitTimer();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkLocationServiceOnEntry();
    });
  }

  @override
  void dispose() {
    _visitTimer?.cancel();
    super.dispose();
  }

  void _startVisitTimer() {
    _visitTimer?.cancel();
    _visitElapsed = Duration.zero;
    _visitTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      setState(() {
        _visitElapsed += const Duration(seconds: 1);
      });
    });
  }

  void _stopVisitTimer() {
    _visitTimer?.cancel();
    _visitTimer = null;
  }

  String _formatVisitTime(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = duration.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '${hours.toString().padLeft(2, '0')}:$minutes:$seconds';
  }

  Future<void> _launchMaps() async {
    final job = widget.jobData ?? AppData.instance.job;
    final lat = job['jobLatitude'];
    final lng = job['jobLongitude'];
    final label = _locationLabel(job);

    Uri uri;
    if (lat != null && lng != null) {
      uri = Uri.parse(
        'https://www.google.com/maps/search/?api=1&query=$lat,$lng',
      );
    } else {
      uri = Uri.parse(
        'https://www.google.com/maps/search/?api=1&query=${Uri.encodeComponent(label)}',
      );
    }

    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not open map app.')),
        );
      }
    }
  }

  String _displayTicketNo(String value) {
    return value.replaceFirst(RegExp(r'^#?(TCK|TKT)-'), '#JOB-');
  }

  String _demoAddress(Map<String, dynamic> job) {
    final address = '${job['address'] ?? job['location'] ?? ''}'.trim();
    if (address.isNotEmpty) return address;

    final demoAddresses = <String>[
      'Block D - Finance Dept, Chennai',
      'Block C - HR Dept, Chennai',
      'Floor 2 - Admin Wing, Chennai',
      'Meeting Room A - Corporate Block, Chennai',
    ];
    final ticket = '${job['ticketId'] ?? job['ticketNo'] ?? '0'}';
    final index = ticket.hashCode.abs() % demoAddresses.length;
    return demoAddresses[index];
  }

  String _locationLabel(Map<String, dynamic> job) {
    final label = '${job['locationLabel'] ?? _demoAddress(job)}'.trim();
    return label.isEmpty ? 'Job Location' : label;
  }

  Future<void> _toggleLiveLocation(bool enabled) async {
    if (!enabled) {
      setState(() {
        _liveLocationEnabled = false;
        _locationStatus = 'Turn on location to fetch the job location.';
      });
      return;
    }

    setState(() {
      _locationBusy = true;
      _locationStatus = 'Fetching the location...';
    });

    try {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        setState(() {
          _locationBusy = false;
          _liveLocationEnabled = false;
          _locationStatus = 'Location service is turned off.';
        });
        await _promptTurnOnLocation();
        return;
      }

      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        setState(() {
          _locationBusy = false;
          _liveLocationEnabled = false;
          _locationStatus = 'Location permission is required.';
        });
        return;
      }

      if (!mounted) return;
      final job = widget.jobData ?? AppData.instance.job;
      final resolvedAddress = _demoAddress(job);
      setState(() {
        _liveLocationEnabled = true;
        _locationBusy = false;
        _locationStatus =
            'Location access enabled. Demo location: $resolvedAddress';
      });
    } catch (e) {
      setState(() {
        _locationBusy = false;
        _liveLocationEnabled = false;
        _locationStatus = 'Could not read location.';
      });
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Location check failed: $e')));
      }
    }
  }

  Future<void> _checkLocationServiceOnEntry() async {
    try {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled && mounted) {
        await _promptTurnOnLocation();
      }
    } catch (_) {
      // Ignore platform errors here; the toggle still handles the flow later.
    }
  }

  Future<void> _promptTurnOnLocation() async {
    if (!mounted) return;
    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Turn on location'),
          content: const Text(
            'Location is turned off. Please enable location access to continue the Direct Visit check-in flow.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.of(dialogContext).pop();
                await Geolocator.openLocationSettings();
              },
              child: const Text('Open Settings'),
            ),
          ],
        );
      },
    );
  }

  bool get _canVerify => _liveLocationEnabled;

  @override
  Widget build(BuildContext context) {
    final job = widget.jobData ?? AppData.instance.job;
    final address = _demoAddress(job);
    final ticketNo = _displayTicketNo(
      '${job['ticketId'] ?? job['ticketNo'] ?? ''}',
    );
    final locationLabel = _locationLabel(job);
    return Scaffold(
      backgroundColor: Colors.white,
      body: AppStatusBarWrapper(
        child: SafeArea(
          top: false,
          bottom: false,
          child: SingleChildScrollView(
            padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 18.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    InkWell(
                      onTap: () => Navigator.of(context).maybePop(),
                      borderRadius: BorderRadius.circular(20.r),
                      child: Padding(
                        padding: EdgeInsets.all(4.r),
                        child: Icon(
                          Icons.arrow_back_rounded,
                          size: 24.sp,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                    SizedBox(width: 8.w),
                    Text(
                      'Direct Visit',
                      style: TextStyle(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 16.h),
                InkWell(
                  onTap: _launchMaps,
                  borderRadius: BorderRadius.circular(14.r),
                  child: Container(
                    height: 180.h,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(14.r),
                      border: Border.all(
                        color: const Color(0xFF8EA3F2),
                        width: 1.2,
                      ),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(14.r),
                      child: Stack(
                        children: [
                          Positioned.fill(
                            child: Image.asset(
                              'assets/map.png',
                              package: 'service_ticket',
                              fit: BoxFit.cover,
                            ),
                          ),
                          Positioned(
                            top: 12.h,
                            right: 12.w,
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 10.w,
                                vertical: 6.h,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFF55C56B),
                                borderRadius: BorderRadius.circular(8.r),
                              ),
                              child: Text(
                                locationLabel,
                                style: TextStyle(
                                  fontSize: 11.sp,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 16.h),
                Align(
                  alignment: Alignment.centerRight,
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 16.w,
                      vertical: 12.h,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    child: Text(
                      _formatVisitTime(_visitElapsed),
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 12.h),
                const WorkflowStepper(
                  currentStep: 2,
                  labels: [
                    'Ticket\nRaised',
                    'Direct\nVisit',
                    'Selfie\nVerification',
                    'Check In',
                    'Check Out',
                  ],
                ),
                SizedBox(height: 14.h),
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 14.w,
                    vertical: 12.h,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF3F5F9),
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: Row(
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Enable Live Location',
                            style: TextStyle(
                              fontSize: 15.sp,
                              fontWeight: FontWeight.w700,
                              color: Colors.black87,
                            ),
                          ),
                          SizedBox(height: 4.h),
                          Text(
                            'Share your location while on this job',
                            style: TextStyle(
                              fontSize: 12.sp,
                              color: const Color(0xFF667085),
                            ),
                          ),
                        ],
                      ),
                      const Spacer(),
                      Switch(
                        value: _liveLocationEnabled,
                        onChanged: _locationBusy ? null : _toggleLiveLocation,
                        activeThumbColor: AppColors.primary,
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 8.h),
                Text(
                  _locationBusy ? 'Fetching the location...' : _locationStatus,
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: const Color(0xFF667085),
                  ),
                ),
                SizedBox(height: 14.h),
                Container(
                  padding: EdgeInsets.all(16.r),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF3F5F9),
                    borderRadius: BorderRadius.circular(16.r),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Location Detail',
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w700,
                          color: Colors.black87,
                        ),
                      ),
                      SizedBox(height: 14.h),
                      _DetailRow(
                        label: 'Customer Name',
                        value: '${job['customerName'] ?? job['name'] ?? ''}',
                      ),
                      _DetailRow(
                        label: 'Complaint',
                        value: '${job['complaint'] ?? job['issue'] ?? ''}',
                      ),
                      _DetailRow(label: 'Phone', value: '${job['phone'] ?? ''}', valueColor: const Color(0xFF5177F5)),
                      _DetailRow(label: 'Address', value: address),
                      _DetailRow(label: 'Note', value: '${job['note'] ?? 'N/A'}'),
                      _DetailRow(label: 'Ticket No', value: ticketNo),
                      _DetailRow(
                        label: 'Location Status',
                        value: _liveLocationEnabled ? 'Enabled' : 'Pending',
                      ),
                      _DetailRow(
                        label: 'Latitude',
                        value: '${job['jobLatitude'] ?? 'N/A'}',
                      ),
                      _DetailRow(
                        label: 'Longitude',
                        value: '${job['jobLongitude'] ?? 'N/A'}',
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 28.h),
                SizedBox(
                  width: double.infinity,
                  height: 48.h,
                  child: ElevatedButton(
                    onPressed: _canVerify
                        ? () {
                            _stopVisitTimer();
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => DirectVisitCameraScreen(
                                  jobData: job,
                                  travelDuration: _formatVisitTime(
                                    _visitElapsed,
                                  ),
                                ),
                              ),
                            );
                          }
                        : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _canVerify
                          ? AppColors.primary
                          : const Color(0xFFC9CFDD),
                      disabledBackgroundColor: const Color(0xFFC9CFDD),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(6.r),
                      ),
                      elevation: 0,
                    ),
                    child: Text(
                      'Reached & Verify',
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
        ),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({required this.label, required this.value, this.valueColor});

  final String label;
  final String value;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 10.h),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Color(0xFFD7DCE8))),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 4,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 13.sp,
                color: const Color(0xFF5177F5),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Expanded(
            flex: 5,
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: TextStyle(
                fontSize: 13.sp,
                color: valueColor ?? const Color(0xFF1F2937),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
