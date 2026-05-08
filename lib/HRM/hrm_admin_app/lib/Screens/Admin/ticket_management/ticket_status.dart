import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../Models/ticket_api.dart';

class TicketStatusScreen extends StatefulWidget {
  const TicketStatusScreen({super.key});

  @override
  State<TicketStatusScreen> createState() => _TicketStatusScreenState();
}

class _TicketStatusScreenState extends State<TicketStatusScreen> {
  late Future<TicketResponse> _ticketsFuture;

  @override
  void initState() {
    super.initState();
    _ticketsFuture = TicketApi.fetchTickets();
  }

  void _refreshTickets() {
    setState(() {
      _ticketsFuture = TicketApi.fetchTickets();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F7FA),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: const Color(0xFF26A69A),
        title: Text(
          "Ticket Status",
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
            fontSize: 18,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: _refreshTickets,
          ),
        ],
      ),
      body: FutureBuilder<TicketResponse>(
        future: _ticketsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: Color(0xFF26A69A)));
          } else if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, color: Colors.red, size: 48),
                  const SizedBox(height: 16),
                  Text("Error: ${snapshot.error}", textAlign: TextAlign.center),
                  ElevatedButton(
                    onPressed: _refreshTickets,
                    child: const Text("Retry"),
                  ),
                ],
              ),
            );
          } else if (!snapshot.hasData || snapshot.data!.data.isEmpty) {
            return const Center(child: Text("No tickets found."));
          }

          final tickets = snapshot.data!.data;

          return RefreshIndicator(
            onRefresh: () async => _refreshTickets(),
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: tickets.length,
              itemBuilder: (context, index) {
                final ticket = tickets[index];
                return _buildTicketCard(ticket);
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildTicketCard(TicketData ticket) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(12),
            decoration: const BoxDecoration(
              color: Color(0xFFF8FAFC),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(Icons.confirmation_num_outlined, size: 18, color: Color(0xFF26A69A)),
                    const SizedBox(width: 8),
                    Text(
                      "ID: ${ticket.id}",
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                        color: const Color(0xFF1B2C61),
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.orange.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    ticket.complaintType,
                    style: GoogleFonts.poppins(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: Colors.orange,
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      radius: 20,
                      backgroundColor: const Color(0xFF26A69A).withOpacity(0.1),
                      child: Text(
                        ticket.employeeName.isNotEmpty ? ticket.employeeName[0] : "E",
                        style: const TextStyle(color: Color(0xFF26A69A), fontWeight: FontWeight.bold),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            ticket.employeeName,
                            style: GoogleFonts.poppins(
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                              color: const Color(0xFF1B2C61),
                            ),
                          ),
                          Text(
                            "Dept: ${ticket.department} • ID: ${ticket.employeeId}",
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                const Divider(height: 1),
                const SizedBox(height: 16),
                Text(
                  "Description",
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[500],
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  ticket.description,
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    color: const Color(0xFF334155),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.calendar_today_outlined, size: 14, color: Colors.grey),
                        const SizedBox(width: 4),
                        Text(
                          ticket.complaintDate,
                          style: GoogleFonts.poppins(fontSize: 11, color: Colors.grey[600]),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        const Icon(Icons.access_time, size: 14, color: Colors.grey),
                        const SizedBox(width: 4),
                        Text(
                          ticket.dtime.split(' ').last,
                          style: GoogleFonts.poppins(fontSize: 11, color: Colors.grey[600]),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
