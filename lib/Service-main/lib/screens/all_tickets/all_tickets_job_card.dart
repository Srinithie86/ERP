import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart' as dio_pkg;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:service_ticket/core/app_colors.dart';
import 'package:service_ticket/core/size_utils.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'add_spares_screen.dart';
import 'package:audioplayers/audioplayers.dart';
import '../../services/api_service.dart';
import '../../services/device_service.dart';
import 'package:url_launcher/url_launcher.dart';

class AllTicketsJobCard extends StatefulWidget {
  const AllTicketsJobCard({
    super.key,
    required this.ticketNo,
    required this.name,
    required this.issue,
    required this.dateText,
    required this.timeText,
    required this.label,
    required this.filterCategory,
    this.product = 'Samsung 1.5T AC',
    this.complaint = 'Runs but not cooling below 28C',
    this.phone = '+91 98765 43210',
    this.address = 'Plot 12, Anna Nagar, Chennai',
    this.showComplaintAudio = false,
    this.onTap,
    this.onAssignTap,
    this.onViewStatusTap,
    this.onCloseWithReason,
    this.resolutionNote,
    this.priorityName,
    this.photo,
    this.audio,
    this.note = 'N/A',
    this.cusId = '',
  });

  final String ticketNo;
  final String name;
  final String issue;
  final String dateText;
  final String timeText;
  final String label;

  /// 'RECEIVED', 'ASSIGNED', or 'COMPLETED'
  final String filterCategory;
  final String product;
  final String complaint;
  final String phone;
  final String address;
  final bool showComplaintAudio;
  final VoidCallback? onTap;
  final VoidCallback? onAssignTap;
  final VoidCallback? onViewStatusTap;
  final void Function(String)? onCloseWithReason;
  final String? resolutionNote;
  final String? priorityName;
  final String? photo;
  final String? audio;
  final String note;
  final String cusId;

  @override
  State<AllTicketsJobCard> createState() => _AllTicketsJobCardState();
}

class _AllTicketsJobCardState extends State<AllTicketsJobCard> {
  bool _expanded = false;
  bool _audioPlaying = false;
  late AudioPlayer _audioPlayer;
  Duration _duration = Duration.zero;
  Duration _position = Duration.zero;
  bool _hasCalledCustomer = false;
  bool _showCloseComplaint = false;
  bool _isComplaintClosedLocally = false;
  final TextEditingController _serviceChargeController =
      TextEditingController();
  bool _sparesNeed = false;
  bool _isStoringCharge = false;
  String _localClosingReason = '';
  final List<Map<String, dynamic>> _selectedSpares = [];
  bool _isRequestingSpares = false;
  final TextEditingController _reasonController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _initAudioPlayer();
  }

  void _initAudioPlayer() {
    try {
      _audioPlayer = AudioPlayer();
      _audioPlayer.onPlayerComplete.listen((event) {
        if (mounted) {
          setState(() {
            _audioPlaying = false;
            _position = Duration.zero;
          });
        }
      });
      _audioPlayer.onDurationChanged.listen((d) {
        if (mounted) setState(() => _duration = d);
      });
      _audioPlayer.onPositionChanged.listen((p) {
        if (mounted) setState(() => _position = p);
      });
    } catch (e) {
      debugPrint("AudioPlayer initialization failed: $e");
    }
  }

  Future<void> _storeServiceCharge() async {
    final amount = _serviceChargeController.text.trim();
    if (amount.isEmpty) return;

    setState(() => _isStoringCharge = true);

    try {
      final prefs = await SharedPreferences.getInstance();
      final cid = (prefs.getString('cid') ?? '').trim();
      final token = (prefs.getString('token') ?? '').trim();
      final uid = (prefs.getString('uid') ?? '').trim();
      final roleId = (prefs.getString('role_id') ?? '').trim();
      final deviceId = (prefs.getString('device_id') ?? '').trim();
      final lat = (prefs.getString('lat') ?? '').trim();
      final lng = (prefs.getString('lng') ?? '').trim();

      // Extract numeric ID from ticketNo
      final numericId =
          RegExp(r'\d+').firstMatch(widget.ticketNo)?.group(0) ?? '';

      if (cid.isEmpty || uid.isEmpty || token.isEmpty || numericId.isEmpty) {
        throw Exception('Missing required authentication or ticket data');
      }

      final dio = dio_pkg.Dio();
      final response = await dio.post(
        await ApiService.getBaseUrl(),
        data: dio_pkg.FormData.fromMap({
          'type': '5039',
          'cid': cid,
          'uid': uid,
          'ticket_id': numericId,
          'charge': amount,
          'role_id': roleId,
          'token': token,
          'device_id': deviceId.isEmpty
              ? await DeviceService.getDeviceId()
              : deviceId,
          'lt': lat.isEmpty ? '22' : lat,
          'ln': lng.isEmpty ? '22' : lng,
        }),
      );

      final resData = response.data;
      if (resData is Map && resData['error'] == false) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Service Charge updated successfully!'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } else {
        throw Exception(
          resData['message'] ?? resData['error_msg'] ?? 'Server error',
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Update failed: $e'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isStoringCharge = false);
    }
  }

  bool get _isComplaintClosed =>
      _isComplaintClosedLocally ||
      (widget.filterCategory == 'COMPLETED' &&
          (widget.resolutionNote?.isNotEmpty ?? false));
  String get _effectiveClosingReason => _isComplaintClosedLocally
      ? _localClosingReason
      : (widget.resolutionNote ?? '');

  @override
  void dispose() {
    _reasonController.dispose();
    _serviceChargeController.dispose();
    try {
      _audioPlayer.dispose();
    } catch (_) {}
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isOpened = widget.filterCategory == 'OPENED';
    final isAssigned = widget.filterCategory == 'ASSIGNED';
    final isCompleted = widget.filterCategory == 'COMPLETED';

    // Determine the effective label and color
    final effectiveLabel = _isComplaintClosed ? 'Closed Order' : widget.label;
    final labelColor = switch (effectiveLabel) {
      'Assigned' => const Color(0xFF8854D0),
      'Completed' => const Color(0xFF45C95A),
      'Closed Order' => const Color(0xFF45C95A),
      'Urgent' => const Color(0xFFF14D67),
      'Opened' => const Color(0xFF2196F3),
      _ => const Color(0xFFF1A12A), // Pending / Default
    };

    return InkWell(
      onTap: () async {
        if (widget.cusId.isNotEmpty) {
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('cus_id', widget.cusId);
          debugPrint("Stored cus_id: ${widget.cusId}");
        }
        if (widget.onTap != null) widget.onTap!();
      },
      borderRadius: BorderRadius.circular(14.r),
      child: Container(
        margin: EdgeInsets.only(bottom: 12.h),
        padding: EdgeInsets.fromLTRB(12.w, 12.h, 12.w, 10.h),
        decoration: BoxDecoration(
          color: const Color(0xFFF5F5F5),
          borderRadius: BorderRadius.circular(14.r),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Row: Ticket No + Status Badge
            Row(
              children: [
                Expanded(
                  child: Text(
                    widget.ticketNo,
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w700,
                      color: Colors.black87,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                SizedBox(width: 8.w),
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 14.w,
                    vertical: 6.h,
                  ),
                  decoration: BoxDecoration(
                    color: labelColor,
                    borderRadius: BorderRadius.circular(20.r),
                  ),
                  child: Text(
                    effectiveLabel.toUpperCase(),
                    style: TextStyle(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                      height: 1,
                    ),
                  ),
                ),
              ],
            ),

            // Show "Closed Order" reason for closed tickets (read-only)
            if (_isComplaintClosed && _effectiveClosingReason.isNotEmpty) ...[
              SizedBox(height: 8.h),
              Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 8.h),
                decoration: BoxDecoration(
                  color: isCompleted
                      ? const Color(0xFF45C95A)
                      : const Color(0xFFE8F5E9),
                  borderRadius: BorderRadius.circular(6.r),
                  border: isCompleted
                      ? null
                      : Border.all(color: const Color(0xFF45C95A), width: 0.5),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.check_circle_rounded,
                          size: 13.sp,
                          color: isCompleted
                              ? Colors.white
                              : const Color(0xFF45C95A),
                        ),
                        SizedBox(width: 6.w),
                        Text(
                          'Closed Order',
                          style: TextStyle(
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w700,
                            color: isCompleted
                                ? Colors.white
                                : const Color(0xFF2E7D32),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 6.h),
                    if (isCompleted)
                      Text(
                        _effectiveClosingReason,
                        style: TextStyle(
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w500,
                          color: Colors.white,
                          height: 1.4,
                        ),
                      )
                    else
                      Container(
                        width: double.infinity,
                        padding: EdgeInsets.symmetric(
                          horizontal: 10.w,
                          vertical: 8.h,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF1F8F2),
                          borderRadius: BorderRadius.circular(4.r),
                          border: Border.all(
                            color: const Color(0xFFC8E6C9),
                            width: 0.5,
                          ),
                        ),
                        child: Text(
                          _effectiveClosingReason,
                          style: TextStyle(
                            fontSize: 11.sp,
                            color: const Color(0xFF2E7D32),
                            height: 1.4,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ],

            SizedBox(height: 8.h),
            Text(
              widget.name,
              style: TextStyle(
                fontSize: 21.sp,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF445B87),
                height: 1,
              ),
            ),
            SizedBox(height: 6.h),
            Text(
              widget.issue,
              style: TextStyle(
                fontSize: 13.sp,
                color: Colors.black87,
                height: 1,
              ),
            ),
            SizedBox(height: 11.h),
            Row(
              children: [
                Image.asset(
                  'assets/calendar_icon.png',
                  package: 'service_ticket',
                  width: 13.sp,
                  height: 13.sp,
                  errorBuilder: (context, error, stackTrace) => Icon(
                    Icons.calendar_today_rounded,
                    size: 13.sp,
                    color: const Color(0xFF7A7A7A),
                  ),
                ),
                SizedBox(width: 4.w),
                Flexible(
                  child: Text(
                    widget.dateText,
                    style: TextStyle(
                      fontSize: 11.sp,
                      color: const Color(0xFF7A7A7A),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                SizedBox(width: 12.w),
                Icon(
                  Icons.access_time_rounded,
                  size: 13.sp,
                  color: const Color(0xFF7A7A7A),
                ),
                SizedBox(width: 4.w),
                Flexible(
                  child: Text(
                    widget.timeText,
                    style: TextStyle(
                      fontSize: 11.sp,
                      color: const Color(0xFF7A7A7A),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const Spacer(),
                InkWell(
                  onTap: () => setState(() => _expanded = !_expanded),
                  child: Icon(
                    _expanded
                        ? Icons.keyboard_arrow_up_rounded
                        : Icons.keyboard_arrow_down_rounded,
                    size: 24.sp,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),

            // Expanded Details Section
            if (_expanded)
              Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 10.h),
                  Row(
                    children: [
                      const _Dot(color: Color(0xFFE33A3A)),
                      SizedBox(width: 4.w),
                      Flexible(
                        child: Text(
                          widget.priorityName ?? 'Low Priority',
                          style: TextStyle(
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFFE33A3A),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      SizedBox(width: 12.w),
                      _Dot(color: labelColor),
                      SizedBox(width: 4.w),
                      Flexible(
                        child: Text(
                          effectiveLabel,
                          style: TextStyle(
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w600,
                            color: labelColor,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 12.h),
                  const _CardDivider(),
                  SizedBox(height: 10.h),
                  _InfoRow(title: 'Note', value: widget.note),
                  SizedBox(height: 10.h),
                  const _CardDivider(),
                  SizedBox(height: 10.h),
                  _InfoRow(title: 'Product', value: widget.product),
                  SizedBox(height: 10.h),
                  const _CardDivider(),
                  SizedBox(height: 10.h),
                  _InfoRow(title: 'Complaint', value: widget.complaint),
                  if (isAssigned || isOpened) ...[
                    SizedBox(height: 12.h),
                    _ComplaintImageCard(imageUrl: widget.photo),
                  ],
                  if (widget.audio != null && widget.audio!.isNotEmpty) ...[
                    SizedBox(height: 12.h),
                    _ComplaintAudioCard(
                      isPlaying: _audioPlaying,
                      duration: _duration,
                      position: _position,
                      onTogglePlay: () async {
                        try {
                          if (_audioPlaying) {
                            await _audioPlayer.stop();
                            setState(() => _audioPlaying = false);
                          } else {
                            await _audioPlayer.play(UrlSource(widget.audio!));
                            setState(() => _audioPlaying = true);
                          }
                        } catch (e) {
                          debugPrint("AudioPlayer Error: $e");
                          // Fallback to url_launcher if the plugin is missing or fails
                          if (e.toString().contains('MissingPluginException')) {
                            launchUrl(
                              Uri.parse(widget.audio!),
                              mode: LaunchMode.platformDefault,
                            );
                          } else {
                            if (mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    'Could not play audio internally: $e',
                                  ),
                                ),
                              );
                            }
                          }
                        }
                      },
                    ),
                  ],
                  SizedBox(height: 10.h),
                  const _CardDivider(),
                  SizedBox(height: 10.h),
                  _InfoRow(title: 'Phone', value: widget.phone),
                  SizedBox(height: 10.h),
                  const _CardDivider(),
                  SizedBox(height: 10.h),
                  _InfoRow(title: 'Address', value: widget.address),
                  SizedBox(height: 12.h),
                  const _CardDivider(),
                  SizedBox(height: 10.h),

                  // Spares Need Toggle (Styled as per Image)
                  Row(
                    children: [
                      Container(
                        padding: EdgeInsets.all(8.r),
                        decoration: const BoxDecoration(
                          color: Color(0xFFDEE5F5), // Light blue background
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.build_rounded,
                          color: const Color(0xFF2C439E), // Dark blue icon
                          size: 16.sp,
                        ),
                      ),
                      SizedBox(width: 12.w),
                      Text(
                        'Spares Need',
                        style: TextStyle(
                          fontSize: 15.sp,
                          color: const Color(0xFF1F2937),
                          fontWeight: FontWeight.w700, // Bold as per image
                        ),
                      ),
                      const Spacer(),
                      Transform.scale(
                        scale: 0.8,
                        child: Switch(
                          value: _sparesNeed,
                          activeColor: const Color(0xFF0052CC), // Blue switch
                          onChanged: (val) => setState(() => _sparesNeed = val),
                        ),
                      ),
                    ],
                  ),

                  if (_sparesNeed) ...[
                    SizedBox(height: 12.h),
                    InkWell(
                      onTap: () async {
                        final result =
                            await Navigator.push<List<Map<String, dynamic>>>(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const AddSparesScreen(),
                              ),
                            );
                        if (result != null && mounted) {
                          setState(() {
                            _selectedSpares.clear();
                            _selectedSpares.addAll(result);
                          });
                        }
                      },
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 16.w,
                          vertical: 14.h,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(
                            0xFFF0F4F8,
                          ), // Very light background
                          borderRadius: BorderRadius.circular(14.r),
                          border: Border.all(color: const Color(0xFFE5E7EB)),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.inventory_2, // Box icon
                              color: const Color(0xFF0052CC),
                              size: 24.sp,
                            ),
                            SizedBox(width: 12.w),
                            Text(
                              'Add Spares',
                              style: TextStyle(
                                fontSize: 15.sp,
                                fontWeight: FontWeight.w700,
                                color: const Color(0xFF1F2937),
                              ),
                            ),
                            const Spacer(),
                            Icon(
                              Icons.arrow_forward_ios_rounded,
                              color: const Color(0xFF94A3B8),
                              size: 16.sp,
                            ),
                          ],
                        ),
                      ),
                    ),
                    if (_selectedSpares.isNotEmpty) ...[
                      SizedBox(height: 16.h),
                      _buildSparesList(),
                    ],
                  ],

                  // Service Charge Section
                  SizedBox(height: 16.h),
                  const _CardDivider(),
                  SizedBox(height: 12.h),
                  Text(
                    'Service Charge',
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF1F2937),
                    ),
                  ),
                  SizedBox(height: 8.h),
                  Row(
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      Flexible(
                        child: TextField(
                          controller: _serviceChargeController,
                          keyboardType: TextInputType.number,
                          style: TextStyle(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF1F2937),
                          ),
                          decoration: InputDecoration(
                            hintText: 'Enter amount',
                            hintStyle: TextStyle(
                              fontSize: 13.sp,
                              color: const Color(0xFF94A3B8),
                            ),
                            filled: true,
                            fillColor: Colors.white,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12.r),
                              borderSide: const BorderSide(
                                color: Colors.black,
                                width: 1.2,
                              ),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12.r),
                              borderSide: const BorderSide(
                                color: Colors.black,
                                width: 1.2,
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12.r),
                              borderSide: const BorderSide(
                                color: Color(0xFF0052CC),
                                width: 1.5,
                              ),
                            ),
                            prefixIcon: Icon(
                              Icons.payments_outlined,
                              size: 20.sp,
                              color: const Color(0xFF64748B),
                            ),
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: 16.w,
                              vertical: 14.h,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: 10.w),
                      ElevatedButton(
                        onPressed: _isStoringCharge
                            ? null
                            : _storeServiceCharge,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF0052CC),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                          padding: EdgeInsets.symmetric(
                            horizontal: 20.w,
                            vertical: 14.h,
                          ),
                          elevation: 0,
                        ),
                        child: _isStoringCharge
                            ? SizedBox(
                                height: 16.sp,
                                width: 16.sp,
                                child: const CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                            : Text(
                                'Send',
                                style: TextStyle(
                                  fontSize: 14.sp,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                      ),
                    ],
                  ),

                  if ((isCompleted || isOpened) &&
                      _hasCalledCustomer &&
                      !_isComplaintClosed) ...[
                    SizedBox(height: 12.h),
                    InkWell(
                      onTap: () => setState(
                        () => _showCloseComplaint = !_showCloseComplaint,
                      ),
                      borderRadius: BorderRadius.circular(10.r),
                      child: Container(
                        width: double.infinity,
                        padding: EdgeInsets.symmetric(
                          horizontal: 10.w,
                          vertical: 9.h,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE8F5E9),
                          borderRadius: BorderRadius.circular(10.r),
                        ),
                        child: Row(
                          children: [
                            Text(
                              'Close Order',
                              style: TextStyle(
                                fontSize: 14.sp,
                                fontWeight: FontWeight.w500,
                                color: const Color(0xFF2E7D32),
                              ),
                            ),
                            const Spacer(),
                            Icon(
                              _showCloseComplaint
                                  ? Icons.keyboard_arrow_up_rounded
                                  : Icons.keyboard_arrow_down_rounded,
                              size: 22.sp,
                              color: Colors.black87,
                            ),
                          ],
                        ),
                      ),
                    ),
                    if (_showCloseComplaint) ...[
                      SizedBox(height: 8.h),
                      Container(
                        width: double.infinity,
                        padding: EdgeInsets.fromLTRB(10.w, 10.h, 10.w, 12.h),
                        decoration: BoxDecoration(
                          color: const Color(0xFFD9E7EF),
                          borderRadius: BorderRadius.circular(10.r),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            TextField(
                              controller: _reasonController,
                              style: TextStyle(fontSize: 12.sp),
                              decoration: InputDecoration(
                                hintText: 'Enter reason to close...',
                                filled: true,
                                fillColor: Colors.white,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(4.r),
                                  borderSide: BorderSide.none,
                                ),
                                contentPadding: EdgeInsets.symmetric(
                                  horizontal: 10.w,
                                  vertical: 8.h,
                                ),
                              ),
                              maxLines: 3,
                            ),
                            SizedBox(height: 10.h),
                            SizedBox(
                              height: 34.h,
                              child: ElevatedButton(
                                onPressed: () {
                                  final reason = _reasonController.text.trim();
                                  if (widget.onCloseWithReason != null) {
                                    widget.onCloseWithReason!(reason);
                                  }
                                  setState(() {
                                    _localClosingReason = reason;
                                    _isComplaintClosedLocally = true;
                                    _showCloseComplaint = false;
                                  });
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF3451B2),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(4.r),
                                  ),
                                  elevation: 0,
                                ),
                                child: Text(
                                  'Close Order',
                                  style: TextStyle(
                                    fontSize: 13.sp,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ],
              ),

            SizedBox(height: 16.h),

            if (isOpened && !_isComplaintClosed)
              Row(
                children: [
                  Expanded(
                    child: SizedBox(
                      height: 42.h,
                      child: OutlinedButton.icon(
                        onPressed: () {
                          setState(() => _hasCalledCustomer = true);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Calling ${widget.phone}...'),
                            ),
                          );
                        },
                        icon: Icon(Icons.call, size: 16.sp),
                        label: Text(
                          'Call',
                          style: TextStyle(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(
                            color: Color(0xFF3451B2),
                            width: 1.5,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8.r),
                          ),
                          foregroundColor: const Color(0xFF3451B2),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: SizedBox(
                      height: 42.h,
                      child: ElevatedButton(
                        onPressed: widget.onAssignTap,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF3451B2),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8.r),
                          ),
                          elevation: 0,
                        ),
                        child: Text(
                          'Assign',
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

            // ASSIGNED: "Call" + "View Status"
            if (isAssigned)
              Row(
                children: [
                  Expanded(
                    child: SizedBox(
                      height: 42.h,
                      child: OutlinedButton.icon(
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Calling ${widget.phone}...'),
                            ),
                          );
                        },
                        icon: Icon(Icons.call, size: 16.sp),
                        label: Text(
                          'Call',
                          style: TextStyle(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(
                            color: Color(0xFF3451B2),
                            width: 1.5,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8.r),
                          ),
                          foregroundColor: const Color(0xFF3451B2),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: SizedBox(
                      height: 42.h,
                      child: ElevatedButton(
                        onPressed: widget.onViewStatusTap,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF3451B2),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8.r),
                          ),
                          elevation: 0,
                        ),
                        child: Text(
                          'View Status',
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
      ),
    );
  }

  Widget _buildSparesList() {
    return Container(
      padding: EdgeInsets.all(12.r),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Icon(
                Icons.shopping_bag_outlined,
                size: 18.sp,
                color: const Color(0xFF334155),
              ),
              SizedBox(width: 8.w),
              Text(
                'Product Items',
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF334155),
                ),
              ),
              const Spacer(),
              Text(
                'view ${_selectedSpares.length} Items',
                style: TextStyle(
                  fontSize: 12.sp,
                  color: const Color(0xFF2563EB),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _selectedSpares.length,
            separatorBuilder: (_, __) =>
                Divider(height: 20.h, color: const Color(0xFFE2E8F0)),
            itemBuilder: (context, index) {
              final item = _selectedSpares[index];
              // ── FIX: use correct display keys from AddSparesScreen ──
              final displayName = (item['product_name'] ?? item['name'] ?? '')
                  .toString();
              final displayQty = item['qty']?.toString() ?? '1';
              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          displayName,
                          style: TextStyle(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF1E293B),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 10.w,
                      vertical: 4.h,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.circular(6.r),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                    ),
                    child: Text(
                      'Qty: $displayQty',
                      style: TextStyle(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF475569),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
          SizedBox(height: 16.h),
          SizedBox(
            height: 44.h,
            child: ElevatedButton(
              onPressed: _isRequestingSpares ? null : _handleRequestSpares,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0052CC),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.r),
                ),
                elevation: 0,
              ),
              child: _isRequestingSpares
                  ? SizedBox(
                      height: 18.sp,
                      width: 18.sp,
                      child: const CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                  : Text(
                      'Request',
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _handleRequestSpares() async {
    if (_selectedSpares.isEmpty) return;

    setState(() => _isRequestingSpares = true);

    try {
      // Extract the pure numeric ticket id from e.g. "#JOB-8" → "8"
      final numericTicketId =
          RegExp(r'\d+').firstMatch(widget.ticketNo)?.group(0) ?? '';

      if (numericTicketId.isEmpty) {
        throw Exception(
          'Could not determine ticket ID from "${widget.ticketNo}"',
        );
      }

      debugPrint(
        '▶ RequestSpares – ticket: $numericTicketId  cusId: ${widget.cusId}',
      );
      debugPrint('▶ Raw selected spares: $_selectedSpares');

      // Build the items list exactly as the API expects:
      //   product_id   → from the "id" field returned by the products API
      //   product_name → from "product_name" (set in AddSparesScreen mapping)
      //   quantity     → from "qty" (the counter chosen by the user)
      // All values must be STRINGS.
      final List<Map<String, String>> requestItems = _selectedSpares.map((
        item,
      ) {
        final productId = (item['id'] ?? item['product_id'] ?? '')
            .toString()
            .trim();
        final productName = (item['product_name'] ?? item['name'] ?? '')
            .toString()
            .trim();
        final quantity = (item['qty'] ?? item['quantity'] ?? 1)
            .toString()
            .trim();

        return {
          "product_id": productId,
          "product_name": productName,
          "quantity": quantity,
        };
      }).toList();

      debugPrint('▶ Mapped requestItems: $requestItems');

      final response = await ApiService.requestSpares(
        ticketId: numericTicketId,
        cusId: widget.cusId,
        customerName: widget.name,
        address: widget.address,
        items: requestItems,
      );

      debugPrint('▶ requestSpares response: $response');

      if (response != null && response['error'] == false) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                response['message']?.toString() ??
                    'Spares requested successfully!',
              ),
              backgroundColor: Colors.green,
            ),
          );
          setState(() => _selectedSpares.clear());
        }
      } else {
        throw Exception(
          response?['message'] ??
              response?['error_msg'] ??
              'Failed to request spares',
        );
      }
    } catch (e) {
      debugPrint('▶ requestSpares error: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isRequestingSpares = false);
    }
  }
}

class _ComplaintImageCard extends StatelessWidget {
  const _ComplaintImageCard({this.imageUrl});
  final String? imageUrl;

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
                child: CachedNetworkImage(
                  imageUrl: url,
                  fit: BoxFit.contain,
                  placeholder: (context, url) =>
                      const Center(child: CircularProgressIndicator()),
                  errorWidget: (context, url, error) => const Center(
                    child: Icon(Icons.broken_image, color: Colors.grey),
                  ),
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Image',
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.w500,
            color: const Color(0xFF5D46AA),
          ),
        ),
        SizedBox(height: 8.h),
        GestureDetector(
          onTap: () {
            if (imageUrl != null && imageUrl!.isNotEmpty) {
              _showFullScreenImage(context, imageUrl!);
            }
          },
          child: Container(
            height: 104.h,
            clipBehavior: Clip.antiAlias,
            foregroundDecoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10.r),
              border: Border.all(color: const Color(0xFF8E52FF)),
            ),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10.r),
            ),
            child: imageUrl != null && imageUrl!.isNotEmpty
                ? CachedNetworkImage(
                    imageUrl: imageUrl!,
                    width: double.infinity,
                    height: double.infinity,
                    fit: BoxFit.cover,
                    placeholder: (context, url) =>
                        const Center(child: CircularProgressIndicator()),
                    errorWidget: (context, url, error) => const Center(
                      child: Icon(Icons.broken_image, color: Colors.grey),
                    ),
                  )
                : Image.asset(
                    'assets/demo.png',
                    package: 'service_ticket',
                    width: double.infinity,
                    height: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      color: Colors.grey[200],
                      child: Icon(Icons.image, color: Colors.grey[400]),
                    ),
                  ),
          ),
        ),
      ],
    );
  }
}

class _ComplaintAudioCard extends StatelessWidget {
  const _ComplaintAudioCard({
    required this.isPlaying,
    required this.duration,
    required this.position,
    required this.onTogglePlay,
  });

  final bool isPlaying;
  final Duration duration;
  final Duration position;
  final VoidCallback onTogglePlay;

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
    String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
    return "$twoDigitMinutes:$twoDigitSeconds";
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(10.w, 10.h, 10.w, 10.h),
      decoration: BoxDecoration(
        color: const Color(0xFFE7DBFF),
        borderRadius: BorderRadius.circular(10.r),
        border: Border.all(color: const Color(0xFF8E52FF)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Complaint Audio',
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.w500,
              color: const Color(0xFF5D46AA),
            ),
          ),
          SizedBox(height: 10.h),
          Row(
            children: [
              InkWell(
                onTap: onTogglePlay,
                borderRadius: BorderRadius.circular(20.r),
                child: Padding(
                  padding: EdgeInsets.all(4.r),
                  child: Icon(
                    isPlaying ? Icons.stop_rounded : Icons.play_arrow_rounded,
                    size: 28.sp,
                    color: const Color(0xFF322748),
                  ),
                ),
              ),
              SizedBox(width: 10.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: List.generate(18, (index) {
                        final progress = duration.inMilliseconds > 0
                            ? position.inMilliseconds / duration.inMilliseconds
                            : 0.0;
                        final isActive = (index / 18) <= progress;

                        return Expanded(
                          child: Container(
                            margin: EdgeInsets.symmetric(horizontal: 1.w),
                            height:
                                (index.isEven ? 10 : 22).h +
                                ((index % 5) * 4).h,
                            decoration: BoxDecoration(
                              color: isActive
                                  ? const Color(0xFF322748)
                                  : const Color(0xFF65518D).withOpacity(0.3),
                              borderRadius: BorderRadius.circular(20.r),
                            ),
                          ),
                        );
                      }),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      '${_formatDuration(position)} / ${_formatDuration(duration)}',
                      style: TextStyle(
                        fontSize: 10.sp,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF5D46AA),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(width: 10.w),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 7.w, vertical: 5.h),
                decoration: BoxDecoration(
                  color: const Color(0xFFF0E9FF),
                  borderRadius: BorderRadius.circular(6.r),
                  border: Border.all(color: const Color(0xFFA789E8)),
                ),
                child: Text(
                  isPlaying ? 'Stop' : 'Play',
                  style: TextStyle(
                    fontSize: 10.sp,
                    color: const Color(0xFF5D46AA),
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

class _CardDivider extends StatelessWidget {
  const _CardDivider();

  @override
  Widget build(BuildContext context) {
    return Container(height: 1, color: const Color(0xFF9AA8C7));
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.title, required this.value});

  final String title;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 85.w,
          child: Text(
            title,
            style: TextStyle(
              fontSize: 13.sp,
              color: const Color(0xFF445B87),
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        SizedBox(width: 4.w),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              fontSize: 13.sp,
              color: Colors.black87,
              fontWeight: FontWeight.w500,
              height: 1.3,
            ),
          ),
        ),
      ],
    );
  }
}

class _Dot extends StatelessWidget {
  const _Dot({required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 6.w,
      height: 6.w,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
    );
  }
}
