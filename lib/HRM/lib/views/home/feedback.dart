import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hrm/views/home/ticket_raise.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

void main() => runApp(const MaterialApp(home: FeedbackSupportScreen()));

class FeedbackSupportScreen extends StatefulWidget {
  const FeedbackSupportScreen({super.key});

  @override
  State<FeedbackSupportScreen> createState() => _FeedbackSupportScreenState();
}

class _FeedbackSupportScreenState extends State<FeedbackSupportScreen> {
  bool _isLoading = true;
  Map<String, dynamic> _supportData = {};

  @override
  void initState() {
    super.initState();
    _fetchSupportData();
  }

  Future<void> _fetchSupportData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cid = prefs.getString('cid') ?? prefs.getString('cid_str') ?? "99994444";
      final deviceId = prefs.getString('device_id') ?? "123";
      final lat = prefs.getString('lt') ?? prefs.getDouble('lat')?.toString() ?? "0.0";
      final lng = prefs.getString('ln') ?? prefs.getDouble('lng')?.toString() ?? "0.0";

      final response = await http.post(
        Uri.parse("https://erpsmart.in/total/api/m_api/"),
        body: {
          "type": "3041",
          "cid": cid,
          "device_id": deviceId,
          "lt": lat,
          "ln": lng,
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['error'] == false) {
          if (mounted) {
            setState(() {
              _supportData = data['data'] ?? {};
              _isLoading = false;
            });
          }
        } else {
          if (mounted) setState(() => _isLoading = false);
        }
      } else {
        if (mounted) setState(() => _isLoading = false);
      }
    } catch (e) {
      debugPrint("Error fetching feedback data: $e");
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final width = size.width;
    final isTablet = width > 600;

    final double horizontalPadding = isTablet ? 32.0 : 20.0;
    final double topPadding = isTablet ? 32.0 : 24.0;
    final double bodyFontSize = isTablet ? 16.5 : 15.0;
    final double buttonHeight = isTablet ? 64.0 : 56.0;

    // Fallback default values
    String pageTitle = _supportData['page_title'] ?? "Feedback & Support";
    String heading = _supportData['heading'] ?? "Feedback & Support \u2013 HRM Portal";
    
    List<dynamic> descriptionList = _supportData['description'] ?? [
      "We're here to support you in your HR journey.",
      "Got questions about attendance, payroll, leave, or performance? Find quick answers or connect with our HR team."
    ];
    String formattedDescription = descriptionList.join("\n");

    Map<String, dynamic> callSupport = _supportData['call_support'] ?? {
      "section_title": "Call Us Directly",
      "description": "Speak with our customer care team for urgent help.",
      "helpdesk_label": "HR Helpdesk",
      "phone": "+91 98765-43210",
      "available": "9 AM \u2013 6 PM (Mon\u2013Sat)"
    };

    Map<String, dynamic> emailSupport = _supportData['email_support'] ?? {
      "section_title": "Email Support",
      "description": "For detailed queries or document submissions.",
      "email": "support@hrm.com"
    };

    Map<String, dynamic> raiseTicket = _supportData['raise_ticket'] ?? {
      "button_label": "Raise a Ticket",
    };

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: const Color(0xFF26A69A),
        foregroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          pageTitle,
          style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w500),
        ),
        centerTitle: false,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFF26A69A)))
          : SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: topPadding),

                  // Title
                  Text(
                    heading,
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),

                  const SizedBox(height: 8),

                  // Description
                  Text(
                    formattedDescription,
                    style: GoogleFonts.poppins(
                      fontSize: bodyFontSize,
                      color: Colors.black,
                      height: 1.50,
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Call Support Section
                  Text(
                    callSupport['section_title'] ?? "Call Us Directly",
                    style: GoogleFonts.poppins(
                      fontSize: bodyFontSize,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: const Color(0xFF26A69A).withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          Icons.phone_outlined,
                          color: const Color(0xFF26A69A),
                          size: isTablet ? 30 : 26,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              callSupport['description'] ?? "",
                              style: GoogleFonts.poppins(
                                fontSize: bodyFontSize,
                                color: Colors.black87,
                                height: 1.5,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              "${callSupport['helpdesk_label'] ?? 'Helpdesk'}: ${callSupport['phone'] ?? ''}\nAvailable ${callSupport['available'] ?? ''}",
                              style: GoogleFonts.poppins(
                                fontSize: 14,
                                fontWeight: FontWeight.w400,
                                color: Colors.black87,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 32),

                  // Email Support Section
                  Text(
                    emailSupport['section_title'] ?? "Email Support",
                    style: GoogleFonts.poppins(
                      fontSize: bodyFontSize,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: const Color(0xFF26A69A).withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          Icons.email_outlined,
                          color: const Color(0xFF26A69A),
                          size: isTablet ? 30 : 26,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              emailSupport['description'] ?? "",
                              style: GoogleFonts.poppins(
                                fontSize: bodyFontSize,
                                color: Colors.black87,
                                height: 1.5,
                              ),
                            ),
                            Text(
                              emailSupport['email'] ?? "",
                              style: GoogleFonts.poppins(
                                fontSize: bodyFontSize + 1,
                                fontWeight: FontWeight.w600,
                                color: const Color(0xFF26A69A),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: size.height * 0.24),

                  // Raise a Ticket Button
                  Center(
                    child: SizedBox(
                      width: isTablet ? 420 : double.infinity,
                      height: buttonHeight,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const TicketRaise()),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF26A69A),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          elevation: 6,
                        ),
                        child: Text(
                          raiseTicket['button_label'] ?? "Raise a Ticket",
                          style: GoogleFonts.poppins(
                            fontSize: isTablet ? 20 : 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ),

                  SizedBox(height: size.height * 0.05),
                ],
              ),
            ),
    );
  }
}
