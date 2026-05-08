import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';

class TicketHistoryScreen extends StatefulWidget {
  const TicketHistoryScreen({super.key});

  @override
  State<TicketHistoryScreen> createState() => _TicketHistoryScreenState();
}

class _TicketHistoryScreenState extends State<TicketHistoryScreen> {
  bool _isLoading = true;
  List<dynamic> _tickets = [];

  @override
  void initState() {
    super.initState();
    _fetchTicketHistory();
  }

  Future<void> _fetchTicketHistory() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cid = prefs.getString('cid') ?? prefs.getString('cid_str') ?? "99994444";
      final deviceId = prefs.getString('device_id') ?? "123456";
      final uid = prefs.getString('uid') ?? prefs.get('uid')?.toString() ?? "185";
      final lat = prefs.getString('lt') ?? prefs.getDouble('lat')?.toString() ?? "3232";
      final lng = prefs.getString('ln') ?? prefs.getDouble('lng')?.toString() ?? "332";

      final response = await http.post(
        Uri.parse("https://erpsmart.in/total/api/m_api/"),
        body: {
          "type": "2058",
          "cid": cid,
          "uid": uid,
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
              _tickets = data['data'] ?? [];
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
      debugPrint("Error fetching ticket history: $e");
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F7FA),
      appBar: AppBar(
        backgroundColor: const Color(0xFF26A69A),
        foregroundColor: Colors.white,
        elevation: 0,
        title: Text(
          "Ticket History",
          style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w500),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFF26A69A)))
          : _tickets.isEmpty
              ? _buildEmptyState()
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _tickets.length,
                  itemBuilder: (context, index) {
                    final ticket = _tickets[index];
                    return _buildTicketCard(ticket);
                  },
                ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.confirmation_num_outlined, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            "No tickets found",
            style: GoogleFonts.poppins(fontSize: 16, color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }

  Widget _buildTicketCard(Map<String, dynamic> ticket) {
    final status = ticket['status']?.toString() ?? "Pending";
    final isResolved = status.toLowerCase() == "resolved" || status.toLowerCase() == "closed";

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    ticket['subject'] ?? "No Subject",
                    style: GoogleFonts.poppins(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF1B2C61),
                    ),
                  ),
                ),
                _buildStatusBadge(status),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              ticket['description'] ?? "",
              style: GoogleFonts.poppins(
                fontSize: 13,
                color: Colors.grey[600],
                height: 1.4,
              ),
            ),
            const SizedBox(height: 16),
            const Divider(height: 1),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Ticket ID: #${ticket['ticket_id']}",
                      style: GoogleFonts.poppins(
                        fontSize: 11,
                        color: Colors.grey[500],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      ticket['complaint_date'] ?? "",
                      style: GoogleFonts.poppins(
                        fontSize: 11,
                        color: Colors.grey[500],
                      ),
                    ),
                  ],
                ),
                if (isResolved && ticket['resolved_date'] != null && ticket['resolved_date'].toString().isNotEmpty)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        "Resolved On",
                        style: GoogleFonts.poppins(
                          fontSize: 10,
                          color: Colors.green[700],
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        ticket['resolved_date'].toString().split(' ')[0],
                        style: GoogleFonts.poppins(
                          fontSize: 11,
                          color: Colors.green[700],
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    Color color;
    Color bgColor;

    switch (status.toLowerCase()) {
      case 'resolved':
      case 'closed':
        color = Colors.green[700]!;
        bgColor = Colors.green[50]!;
        break;
      case 'in progress':
      case 'pending':
        color = Colors.orange[700]!;
        bgColor = Colors.orange[50]!;
        break;
      case 'rejected':
        color = Colors.red[700]!;
        bgColor = Colors.red[50]!;
        break;
      default:
        color = Colors.blue[700]!;
        bgColor = Colors.blue[50]!;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        status,
        style: GoogleFonts.poppins(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }
}
