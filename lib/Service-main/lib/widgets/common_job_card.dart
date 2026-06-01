import 'package:flutter/material.dart';
import 'package:service_ticket/core/size_utils.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:cached_network_image/cached_network_image.dart';

class CommonJobCard extends StatefulWidget {
  const CommonJobCard({
    super.key,
    required this.ticketNo,
    required this.name,
    required this.issue,
    required this.dateText,
    required this.timeText,
    required this.label,
    this.primaryActionLabel,
    this.product = 'Samsung 1.5T AC',
    this.complaint = 'Runs but not cooling below 28C',
    this.phone = '+91 98765 43210',
    this.address = 'Plot 12, Anna Nagar, Chennai',
    this.showComplaintAudio = false,
    this.complaintTranslation = 'My AC is not cooling so can you check it',
    this.onTap,
    this.onPrimaryTap,
    this.onSecondaryTap,
    this.priority = '',
    this.photoUrl,
    this.audioUrl,
    this.showTranslation = true,
    this.note = 'N/A',
  });

  final String ticketNo;
  final String name;
  final String issue;
  final String dateText;
  final String timeText;
  final String label;
  final String? primaryActionLabel;
  final String product;
  final String complaint;
  final String phone;
  final String address;
  final bool showComplaintAudio;
  final String complaintTranslation;
  final VoidCallback? onTap;
  final VoidCallback? onPrimaryTap;
  final VoidCallback? onSecondaryTap;
  final String priority;
  final String? photoUrl;
  final String? audioUrl;
  final bool showTranslation;
  final String note;

  @override
  State<CommonJobCard> createState() => _CommonJobCardState();
}

class _CommonJobCardState extends State<CommonJobCard>
    with SingleTickerProviderStateMixin {
  bool _expanded = false;
  bool _audioPlaying = false;
  late AudioPlayer _audioPlayer;
  Duration _duration = Duration.zero;
  Duration _position = Duration.zero;

  late AnimationController _blinkController;
  late Animation<double> _blinkAnimation;

  @override
  void initState() {
    _blinkController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _blinkAnimation = Tween<double>(begin: 1.0, end: 0.2).animate(
      CurvedAnimation(parent: _blinkController, curve: Curves.easeInOut),
    );

    super.initState();
    _initAudioPlayer();

    if (widget.label == 'Long Pending') {
      _blinkController.repeat(reverse: true);
    }
  }

  @override
  void didUpdateWidget(CommonJobCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.label == 'Long Pending' && oldWidget.label != 'Long Pending') {
      _blinkController.repeat(reverse: true);
    } else if (widget.label != 'Long Pending' &&
        oldWidget.label == 'Long Pending') {
      _blinkController.stop();
      _blinkController.value = 0;
    }
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

  @override
  void dispose() {
    try {
      _audioPlayer.dispose();
      _blinkController.dispose();
    } catch (_) {}
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final effectiveLabel = widget.label;
    final labelColor = switch (effectiveLabel) {
      'Assigned' => const Color(0xFF8854D0),
      'Today' => const Color(0xFF8854D0),
      'Completed' => const Color(0xFF45C95A),
      'Urgent' => const Color(0xFFF14D67),
      'Received' => const Color(0xFF2196F3),
      'On the Way' => const Color(0xFF6922DC),
      'Long Pending' => const Color(0xFFAA0A0A),
      _ => const Color(0xFFF1A12A),
    };
    final isCompleted = effectiveLabel == 'Completed';
    final showJobImage = widget.photoUrl != null && widget.photoUrl!.isNotEmpty;
    final primaryLabel = isCompleted
        ? 'View Details'
        : (widget.primaryActionLabel ?? 'Check In');

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
            Row(
              children: [
                Expanded(
                  child: Text(
                    widget.ticketNo,
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w700,
                      color: Colors.black87,
                    ),
                  ),
                ),
                SizedBox(width: 8.w),
                FadeTransition(
                  opacity: widget.label == 'Long Pending'
                      ? _blinkAnimation
                      : const AlwaysStoppedAnimation(1.0),
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 14.w,
                      vertical: 6.h,
                    ),
                    decoration: BoxDecoration(
                      color: labelColor,
                      borderRadius: BorderRadius.circular(20.r),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (widget.label == 'Long Pending') ...[
                          Icon(
                            Icons.report_gmailerrorred_rounded,
                            color: Colors.white,
                            size: 14.sp,
                          ),
                          SizedBox(width: 4.w),
                        ],
                        Text(
                          effectiveLabel,
                          style: TextStyle(
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                            height: 1,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),

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
                ),
                SizedBox(width: 4.w),
                Flexible(
                  child: Text(
                    widget.dateText,
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                    style: TextStyle(
                      fontSize: 11.sp,
                      color: const Color(0xFF7A7A7A),
                    ),
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
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                    style: TextStyle(
                      fontSize: 11.sp,
                      color: const Color(0xFF7A7A7A),
                    ),
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
            if (_expanded) ...[
              SizedBox(height: 10.h),
              Row(
                children: [
                  const _Dot(color: Color(0xFFE33A3A)),
                  SizedBox(width: 4.w),
                  Text(
                    widget.priority.isNotEmpty ? widget.priority : 'N/A',
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
              _InfoRow(title: 'Note', value: widget.note),
              SizedBox(height: 10.h),
              const _CardDivider(),
              SizedBox(height: 10.h),
              _InfoRow(title: 'Product', value: widget.product),
              SizedBox(height: 10.h),
              const _CardDivider(),
              SizedBox(height: 10.h),
              _InfoRow(title: 'Complaint', value: widget.complaint),
              if (showJobImage) ...[
                SizedBox(height: 12.h),
                InkWell(
                  onTap: () => _showImagePreview(context, widget.photoUrl!),
                  child: _ComplaintImageCard(imageUrl: widget.photoUrl!),
                ),
              ],
              if (widget.showComplaintAudio) ...[
                SizedBox(height: 12.h),
                _ComplaintAudioCard(
                  isPlaying: _audioPlaying,
                  duration: _duration,
                  position: _position,
                  translation: widget.complaintTranslation,
                  showTranslation: widget.showTranslation,
                  onTogglePlay: () async {
                    if (widget.audioUrl != null &&
                        widget.audioUrl!.isNotEmpty) {
                      try {
                        if (_audioPlaying) {
                          await _audioPlayer.stop();
                          setState(() => _audioPlaying = false);
                        } else {
                          await _audioPlayer.play(UrlSource(widget.audioUrl!));
                          setState(() => _audioPlaying = true);
                        }
                      } catch (e) {
                        debugPrint("AudioPlayer Error: $e");
                        // Fallback to url_launcher if the plugin is missing or fails
                        if (e.toString().contains('MissingPluginException')) {
                          launchUrl(
                            Uri.parse(widget.audioUrl!),
                            mode: LaunchMode.platformDefault,
                          );
                        } else {
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
              SizedBox(height: 16.h),
              if (isCompleted)
                SizedBox(
                  width: double.infinity,
                  height: 42.h,
                  child: ElevatedButton(
                    onPressed: widget.onPrimaryTap,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF3451B2),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(6.r),
                      ),
                      elevation: 0,
                    ),
                    child: Text(
                      primaryLabel,
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                )
              else
                Row(
                  children: [
                    Expanded(
                      child: SizedBox(
                        height: 42.h,
                        child: OutlinedButton(
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Calling ${widget.phone}...'),
                              ),
                            );
                          },
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
                    SizedBox(width: 12.w),
                    Expanded(
                      child: SizedBox(
                        height: 42.h,
                        child: ElevatedButton(
                          onPressed: widget.onPrimaryTap,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF3451B2),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8.r),
                            ),
                            elevation: 0,
                          ),
                          child: Text(
                            primaryLabel,
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

  void _showImagePreview(BuildContext context, String url) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: EdgeInsets.all(10.w),
        child: Stack(
          alignment: Alignment.topRight,
          children: [
            Container(
              width: double.infinity,
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height * 0.8,
              ),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12.r),
                color: Colors.black,
              ),
              clipBehavior: Clip.antiAlias,
              child: url.startsWith('http')
                  ? CachedNetworkImage(
                      imageUrl: url,
                      fit: BoxFit.contain,
                      placeholder: (context, url) => const Center(
                        child: CircularProgressIndicator(color: Colors.white),
                      ),
                      errorWidget: (context, url, error) => Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.broken_image,
                            color: Colors.white,
                            size: 50,
                          ),
                          SizedBox(height: 10.h),
                          const Text(
                            'Failed to load image',
                            style: TextStyle(color: Colors.white),
                          ),
                        ],
                      ),
                    )
                  : url.startsWith('assets/')
                      ? Image.asset(url, package: 'service_ticket', fit: BoxFit.contain)
                      : Image.asset(url, fit: BoxFit.contain),
            ),
            IconButton(
              icon: const Icon(Icons.close, color: Colors.white, size: 30),
              onPressed: () => Navigator.pop(context),
            ),
          ],
        ),
      ),
    );
  }
}

class _ComplaintImageCard extends StatelessWidget {
  const _ComplaintImageCard({required this.imageUrl});

  final String imageUrl;

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
        Container(
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
          child: imageUrl.startsWith('http')
              ? CachedNetworkImage(
                  imageUrl: imageUrl,
                  width: double.infinity,
                  height: double.infinity,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => const Center(
                    child: CircularProgressIndicator(color: Color(0xFF8E52FF)),
                  ),
                  errorWidget: (context, url, error) => Center(
                    child: Icon(
                      Icons.image_not_supported_rounded,
                      color: const Color(0xFF8E52FF),
                      size: 30.sp,
                    ),
                  ),
                )
                : imageUrl.startsWith('assets/')
                    ? Image.asset(
                        imageUrl,
                        package: 'service_ticket',
                        width: double.infinity,
                        height: double.infinity,
                        fit: BoxFit.cover,
                      )
                    : Image.asset(
                        imageUrl,
                        width: double.infinity,
                        height: double.infinity,
                        fit: BoxFit.cover,
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
    required this.translation,
    required this.showTranslation,
    required this.onTogglePlay,
  });

  final bool isPlaying;
  final Duration duration;
  final Duration position;
  final String translation;
  final bool showTranslation;
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
          if (showTranslation && translation.isNotEmpty) ...[
            SizedBox(height: 10.h),
            RichText(
              text: TextSpan(
                style: TextStyle(
                  fontSize: 12.sp,
                  color: const Color(0xFF2C2C2C),
                ),
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
