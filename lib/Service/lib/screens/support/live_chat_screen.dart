import 'package:flutter/material.dart';
import 'package:service_ticket/core/size_utils.dart';
import '../../../Widgets/app_status_bar_wrapper.dart';
import '../../../core/app_colors.dart';

class LiveChatScreen extends StatefulWidget {
  const LiveChatScreen({super.key});

  @override
  State<LiveChatScreen> createState() => _LiveChatScreenState();
}

class _LiveChatScreenState extends State<LiveChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  final List<Map<String, dynamic>> _messages = [
    {
      'text': 'Hello! I\'m here to help. How\ncan I assist you today?',
      'isSender': false,
    },
    {
      'text': 'I need help with\nDispatch',
      'isSender': true,
    },
    {
      'text': 'Sure! I can help you with\ndispatch. Please provide your\norder ID or dispatch number.',
      'isSender': false,
    },
  ];

  void _sendMessage() {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;

    setState(() {
      _messages.add({
        'text': text,
        'isSender': true,
      });
      _messageController.clear();
    });

    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: AppStatusBarWrapper(
        child: SafeArea(
          top: false,
          bottom: false,
          child: Column(
            children: [
              // Custom Header
              Container(
                width: double.infinity,
                color: Colors.white,
                padding: EdgeInsets.fromLTRB(14.w, 10.h, 14.w, 14.h),
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
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                    SizedBox(width: 8.w),
                    Text(
                      'Live Chat',
                      style: TextStyle(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
              ),
              
              // Chat List
              Expanded(
                child: ListView.builder(
                  controller: _scrollController,
                  padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
                  itemCount: _messages.length,
                  itemBuilder: (context, index) {
                    final msg = _messages[index];
                    return _ChatBubble(
                      text: msg['text'] as String,
                      isSender: msg['isSender'] as bool,
                    );
                  },
                ),
              ),

              // Bottom Input Bar
              SafeArea(
                child: Padding(
                  padding: EdgeInsets.fromLTRB(16.w, 10.h, 16.w, 18.h),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.all(color: AppColors.primary, width: 1.2),
                      borderRadius: BorderRadius.circular(6.r),
                    ),
                    padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 8.h),
                    child: Row(
                      children: [
                        Icon(
                          Icons.add_circle_outline,
                          color: AppColors.primary,
                          size: 26.sp,
                        ),
                        SizedBox(width: 10.w),
                        Expanded(
                          child: Container(
                            height: 40.h,
                            padding: EdgeInsets.symmetric(horizontal: 12.w),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF3F5F9),
                              borderRadius: BorderRadius.circular(6.r),
                            ),
                            child: TextField(
                              controller: _messageController,
                              style: TextStyle(fontSize: 13.sp, color: Colors.black87),
                              decoration: InputDecoration(
                                hintText: 'Type message...',
                                hintStyle: TextStyle(
                                  fontSize: 13.sp,
                                  color: AppColors.primary.withValues(alpha: 0.7),
                                ),
                                border: InputBorder.none,
                                contentPadding: EdgeInsets.only(bottom: 11.h), // align center
                              ),
                            ),
                          ),
                        ),
                        SizedBox(width: 10.w),
                        SizedBox(
                          height: 40.h,
                          child: ElevatedButton.icon(
                            onPressed: _sendMessage,
                            icon: Icon(Icons.send_rounded, size: 16.sp, color: Colors.white),
                            label: Text(
                              'Send',
                              style: TextStyle(
                                fontSize: 13.sp,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              elevation: 0,
                              padding: EdgeInsets.symmetric(horizontal: 12.w),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(6.r),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
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

class _ChatBubble extends StatelessWidget {
  const _ChatBubble({
    required this.text,
    required this.isSender,
  });

  final String text;
  final bool isSender;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: 24.h),
      child: Align(
        alignment: isSender ? Alignment.centerRight : Alignment.centerLeft,
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width * 0.75,
          ),
          child: CustomPaint(
            painter: _ChatBubblePainter(isSender: isSender),
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
              child: Text(
                text,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14.sp,
                  height: 1.4,
                  fontWeight: FontWeight.w500,
                  color: isSender ? Colors.white : const Color(0xFF445B87),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ChatBubblePainter extends CustomPainter {
  final bool isSender;

  _ChatBubblePainter({required this.isSender});

  @override
  void paint(Canvas canvas, Size size) {
    final double radius = 4.0;
    final double tailWidth = 10.0;
    final double tailHeight = 12.0;

    final paint = Paint()
      ..style = isSender ? PaintingStyle.fill : PaintingStyle.fill
      ..color = isSender ? const Color(0xFF2F4CB4) : Colors.white;

    final borderPaint = Paint()
      ..style = PaintingStyle.stroke
      ..color = const Color(0xFF90A4E2)
      ..strokeWidth = 1.0;

    final path = Path();
    
    // The main rectangle coordinates
    final left = 0.0;
    final top = 0.0;
    final right = size.width;
    final bottom = size.height;

    if (isSender) {
      // Background path
      path.moveTo(left + radius, top);
      path.lineTo(right - radius, top);
      path.arcToPoint(Offset(right, top + radius), radius: Radius.circular(radius));
      path.lineTo(right, bottom);
      // Sender Tail at bottom right
      path.lineTo(right - tailWidth, bottom);
      path.lineTo(right - tailWidth, bottom + tailHeight);
      path.lineTo(right - tailWidth - 8, bottom); // slant back up
      
      path.lineTo(left + radius, bottom);
      path.arcToPoint(Offset(left, bottom - radius), radius: Radius.circular(radius));
      path.lineTo(left, top + radius);
      path.arcToPoint(Offset(left + radius, top), radius: Radius.circular(radius));
      
      canvas.drawPath(path, paint);
    } else {
      // Receiver: white background with blue border
      path.moveTo(left + radius, top);
      path.lineTo(right - radius, top);
      path.arcToPoint(Offset(right, top + radius), radius: Radius.circular(radius));
      path.lineTo(right, bottom - radius);
      path.arcToPoint(Offset(right - radius, bottom), radius: Radius.circular(radius));
      
      // Tail at bottom left
      path.lineTo(left + tailWidth + 8, bottom);
      path.lineTo(left + tailWidth, bottom + tailHeight);
      path.lineTo(left + tailWidth, bottom);
      
      path.lineTo(left, bottom);
      path.lineTo(left, top + radius);
      path.arcToPoint(Offset(left + radius, top), radius: Radius.circular(radius));

      canvas.drawPath(path, paint);
      canvas.drawPath(path, borderPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
