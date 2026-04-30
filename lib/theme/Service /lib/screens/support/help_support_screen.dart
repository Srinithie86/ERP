import 'package:flutter/material.dart';
import 'package:service_ticket/Widgets/app_status_bar_wrapper.dart';
import 'package:service_ticket/core/app_colors.dart';
import 'package:service_ticket/core/size_utils.dart';
import 'live_chat_screen.dart';

class HelpSupportScreen extends StatelessWidget {
  const HelpSupportScreen({super.key});

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
              // ─── Header ───
              Padding(
                padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 6.h),
                child: Row(
                  children: [
                    InkWell(
                      onTap: () => Navigator.pop(context),
                      borderRadius: BorderRadius.circular(20.r),
                      child: Padding(
                        padding: EdgeInsets.all(4.r),
                        child: Icon(Icons.arrow_back_ios_new_rounded,
                            color: AppColors.primary, size: 18.sp),
                      ),
                    ),
                    SizedBox(width: 8.w),
                    Text(
                      'Help and support',
                      style: TextStyle(
                        fontSize: 17.sp,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
              ),

              // ─── Scrollable Content ───
              Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsets.symmetric(horizontal: 16.w),
                  child: Column(
                    children: [
                      SizedBox(height: 14.h),

                      // ════════════════════════════════════════
                      //  Quick Service Card
                      // ════════════════════════════════════════
                      Container(
                        width: double.infinity,
                        padding: EdgeInsets.fromLTRB(14.w, 14.h, 14.w, 16.h),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF5F7FA),
                          borderRadius: BorderRadius.circular(14.r),
                          border: Border.all(
                            color: const Color(0xFFE8ECF2),
                            width: 1,
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Quick Service',
                              style: TextStyle(
                                fontSize: 14.sp,
                                fontWeight: FontWeight.w700,
                                color: const Color(0xFF1A1A1A),
                              ),
                            ),
                            SizedBox(height: 14.h),

                            // Row 1: Call Support + Email Support
                            Row(
                              children: [
                                _QuickServiceTile(
                                  label: 'Call Support',
                                  assetPath: 'assets/call_icon.png',
                                  bgColor: const Color(0xFFDDE3FF),
                                  onTap: () {},
                                ),
                                SizedBox(width: 12.w),
                                _QuickServiceTile(
                                  label: 'Email Support',
                                  assetPath: 'assets/email_icon.png',
                                  bgColor: const Color(0xFFFFF4D6),
                                  onTap: () {},
                                ),
                              ],
                            ),

                            SizedBox(height: 12.h),

                            // Row 2: Live Chat + FAQs
                            Row(
                              children: [
                                _QuickServiceTile(
                                  label: 'Live Chat',
                                  assetPath: 'assets/chat_icon.png',
                                  bgColor: const Color(0xFFD4F5E0),
                                  onTap: () {
                                    Navigator.push(context, MaterialPageRoute(builder: (_) => const LiveChatScreen()));
                                  },
                                ),
                                SizedBox(width: 12.w),
                                _QuickServiceTile(
                                  label: 'FAQs',
                                  assetPath: 'assets/faq_icon.png',
                                  bgColor: const Color(0xFFFFDDE5),
                                  onTap: () {},
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),

                      SizedBox(height: 22.h),

                      // ════════════════════════════════════════
                      //  Frequently Asked Question Section
                      // ════════════════════════════════════════
                      Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(14.r),
                          border: Border.all(
                            color: const Color(0xFFE8ECF2),
                            width: 1,
                          ),
                        ),
                        child: Column(
                          children: [
                            // FAQ Header
                            Padding(
                              padding: EdgeInsets.fromLTRB(
                                  16.w, 16.h, 16.w, 12.h),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.help_outline_rounded,
                                      size: 22.sp,
                                      color: const Color(0xFF3A3A3A)),
                                  SizedBox(width: 8.w),
                                  Text(
                                    'Frequently Asked Question',
                                    style: TextStyle(
                                      fontSize: 13.5.sp,
                                      fontWeight: FontWeight.w700,
                                      color: const Color(0xFF1A1A1A),
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            // Divider under header
                            Container(
                              height: 0.8,
                              color: const Color(0xFFE8ECF2),
                            ),

                            // FAQ Items
                            const _FAQItem(
                              question:
                                  'How do I track my machine\'s\nservice schedule?',
                            ),
                            const _FAQItem(
                              question:
                                  'What should I do if the machine\nstops unexpectedly?',
                            ),
                            const _FAQItem(
                              question:
                                  'How can I Download my warranty\ncertificate?',
                            ),
                            const _FAQItem(
                              question:
                                  'Where can I find the user\nmanual for JC-500>',
                            ),
                            const _FAQItem(
                              question:
                                  'How do I request genuine\nspare parts?',
                            ),
                            const _FAQItem(
                              question:
                                  'What is covered under my\ncurrent warrenty plan?',
                              isLast: true,
                            ),
                          ],
                        ),
                      ),

                      SizedBox(height: 32.h),

                      // ════════════════════════════════════════
                      //  Contact Support Button
                      // ════════════════════════════════════════
                      SizedBox(
                        width: double.infinity,
                        height: 50.h,
                        child: ElevatedButton(
                          onPressed: () {},
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12.r),
                            ),
                            elevation: 0,
                          ),
                          child: Text(
                            'Contact Support',
                            style: TextStyle(
                              fontSize: 15.sp,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),

                      SizedBox(height: 28.h),
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

// ─────────────────────────────────────────────────────────
//  Quick Service Tile (uses PNG asset icon)
// ─────────────────────────────────────────────────────────
class _QuickServiceTile extends StatelessWidget {
  const _QuickServiceTile({
    required this.label,
    required this.assetPath,
    required this.bgColor,
    required this.onTap,
  });

  final String label;
  final String assetPath;
  final Color bgColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12.r),
        child: Container(
          height: 110.h,
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(12.r),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                assetPath,
                width: 52.w,
                height: 52.w,
                fit: BoxFit.contain,
              ),
              SizedBox(height: 8.h),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF2A2A2A),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────
//  FAQ Item Row
// ─────────────────────────────────────────────────────────
class _FAQItem extends StatelessWidget {
  const _FAQItem({required this.question, this.isLast = false});

  final String question;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 13.h),
      decoration: BoxDecoration(
        border: isLast
            ? null
            : Border(
                bottom: BorderSide(
                  color: const Color(0xFFE8ECF2),
                  width: 0.8,
                ),
              ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Bullet dot
          Padding(
            padding: EdgeInsets.only(top: 7.h),
            child: Container(
              width: 4.w,
              height: 4.w,
              decoration: const BoxDecoration(
                color: Color(0xFF8D8D8D),
                shape: BoxShape.circle,
              ),
            ),
          ),
          SizedBox(width: 10.w),
          // Question text
          Expanded(
            child: Text(
              question,
              style: TextStyle(
                fontSize: 12.sp,
                fontWeight: FontWeight.w500,
                color: const Color(0xFF667085),
                height: 1.45,
              ),
            ),
          ),
          // Dropdown arrow
          Padding(
            padding: EdgeInsets.only(top: 2.h),
            child: Icon(
              Icons.keyboard_arrow_down_rounded,
              size: 20.sp,
              color: const Color(0xFF8D8D8D),
            ),
          ),
        ],
      ),
    );
  }
}
