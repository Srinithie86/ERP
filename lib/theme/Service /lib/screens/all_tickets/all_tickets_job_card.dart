import 'package:flutter/material.dart';
import 'package:service_ticket/core/size_utils.dart';
import 'package:cached_network_image/cached_network_image.dart';

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
    this.complaintTranslation = 'My AC is not cooling so can you check it',
    this.onTap,
    this.onAssignTap,
    this.onViewStatusTap,
    this.onCloseWithReason,
    this.resolutionNote,
    this.priorityName,
    this.photo,
    this.audio,
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
  final String complaintTranslation;
  final VoidCallback? onTap;
  final VoidCallback? onAssignTap;
  final VoidCallback? onViewStatusTap;
  final void Function(String)? onCloseWithReason;
  final String? resolutionNote;
  final String? priorityName;
  final String? photo;
  final String? audio;

  @override
  State<AllTicketsJobCard> createState() => _AllTicketsJobCardState();
}

class _AllTicketsJobCardState extends State<AllTicketsJobCard> {
  bool _expanded = false;
  bool _audioPlaying = false;
  bool _hasCalledCustomer = false;
  bool _showCloseComplaint = false;
  bool _isComplaintClosedLocally = false;
  String _localClosingReason = '';
  final TextEditingController _reasonController = TextEditingController();

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
      onTap: widget.onTap,
      borderRadius: BorderRadius.circular(14.r),
      child: Container(
        margin: EdgeInsets.only(bottom: 12.h),
        padding: EdgeInsets.fromLTRB(12.w, 12.h, 12.w, 10.h),
        decoration: BoxDecoration(
          color: const Color(0xFFF5F5F5),
          borderRadius: BorderRadius.circular(14.r),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Row: Ticket No + Status Badge
            Row(
              children: [
                Text(
                  widget.ticketNo,
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w700,
                    color: Colors.black87,
                  ),
                ),
                const Spacer(),
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
                  width: 13.sp,
                  height: 13.sp,
                ),
                SizedBox(width: 4.w),
                Text(
                  widget.dateText,
                  style: TextStyle(
                    fontSize: 11.sp,
                    color: const Color(0xFF7A7A7A),
                  ),
                ),
                SizedBox(width: 12.w),
                Icon(
                  Icons.access_time_rounded,
                  size: 13.sp,
                  color: const Color(0xFF7A7A7A),
                ),
                SizedBox(width: 4.w),
                Text(
                  widget.timeText,
                  style: TextStyle(
                    fontSize: 11.sp,
                    color: const Color(0xFF7A7A7A),
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
            if (_expanded) ...[
              SizedBox(height: 10.h),
              Row(
                children: [
                  const _Dot(color: Color(0xFFE33A3A)),
                  SizedBox(width: 4.w),
                  Text(
                    widget.priorityName ?? 'Low Priority',
                    style: TextStyle(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFFE33A3A),
                    ),
                  ),
                  SizedBox(width: 12.w),
                  _Dot(color: labelColor),
                  SizedBox(width: 4.w),
                  Text(
                    effectiveLabel,
                    style: TextStyle(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w600,
                      color: labelColor,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 12.h),
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
                  translation: widget.complaintTranslation,
                  onTogglePlay: () =>
                      setState(() => _audioPlaying = !_audioPlaying),
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
                          width: double.infinity,
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

              SizedBox(height: 16.h),

              // ============ BUTTONS PER CATEGORY ============

              // OPENED: "Call" + "Assign"
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
          ],
        ),
      ),
    );
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
                  placeholder: (context, url) => const Center(
                    child: CircularProgressIndicator(),
                  ),
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
      crossAxisAlignment: CrossAxisAlignment.start,
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
            width: double.infinity,
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
                    placeholder: (context, url) => const Center(
                      child: CircularProgressIndicator(),
                    ),
                    errorWidget: (context, url, error) => const Center(
                      child: Icon(Icons.broken_image, color: Colors.grey),
                    ),
                  )
                : Image.asset(
                    'assets/demo.png',
                    width: double.infinity,
                    height: double.infinity,
                    fit: BoxFit.cover,
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
    required this.translation,
    required this.onTogglePlay,
  });

  final bool isPlaying;
  final String translation;
  final VoidCallback onTogglePlay;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(10.w, 10.h, 10.w, 10.h),
      decoration: BoxDecoration(
        color: const Color(0xFFE7DBFF),
        borderRadius: BorderRadius.circular(10.r),
        border: Border.all(color: const Color(0xFF8E52FF)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
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
                child: Row(
                  children: List.generate(
                    18,
                    (index) => Expanded(
                      child: Container(
                        margin: EdgeInsets.symmetric(horizontal: 1.w),
                        height:
                            (index.isEven ? 10 : 22).h + ((index % 5) * 4).h,
                        decoration: BoxDecoration(
                          color: const Color(0xFF65518D),
                          borderRadius: BorderRadius.circular(20.r),
                        ),
                      ),
                    ),
                  ),
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
          SizedBox(height: 10.h),
          RichText(
            text: TextSpan(
              style: TextStyle(fontSize: 12.sp, color: const Color(0xFF2C2C2C)),
              children: [
                const TextSpan(
                  text: 'Translate : ',
                  style: TextStyle(fontWeight: FontWeight.w700),
                ),
                TextSpan(text: translation),
              ],
            ),
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
    return Container(
      width: double.infinity,
      height: 1,
      color: const Color(0xFF9AA8C7),
    );
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
          width: 90.w,
          child: Text(
            title,
            style: TextStyle(
              fontSize: 13.sp,
              color: const Color(0xFF445B87),
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              fontSize: 13.sp,
              color: Colors.black87,
              fontWeight: FontWeight.w500,
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
