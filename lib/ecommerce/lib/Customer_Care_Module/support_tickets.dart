import 'package:flutter/material.dart';
import '../Theme_Module/colors_and_models.dart';

// ═══════════════════════════════════════════
//  1. SUPPORT TICKETS SCREEN
// ═══════════════════════════════════════════
class SupportTicketsScreen extends StatefulWidget {
  const SupportTicketsScreen({super.key});
  @override
  State<SupportTicketsScreen> createState() => _SupportTicketsScreenState();
}

class _SupportTicketsScreenState extends State<SupportTicketsScreen> {
  String _search = '';
  String _filter = 'All';

  final List<Map<String, dynamic>> _tickets = [
    {
      'id': 'TKT-001',
      'customer': 'Ravi Kumar',
      'subject': 'Order not delivered',
      'status': 'Open',
      'priority': 'High',
      'date': '12-06-2025',
      'avatar': 'RK',
    },
    {
      'id': 'TKT-002',
      'customer': 'Priya Sharma',
      'subject': 'Wrong item received',
      'status': 'In Progress',
      'priority': 'Medium',
      'date': '11-06-2025',
      'avatar': 'PS',
    },
    {
      'id': 'TKT-003',
      'customer': 'Arun Selvan',
      'subject': 'Refund not processed',
      'status': 'Open',
      'priority': 'High',
      'date': '10-06-2025',
      'avatar': 'AS',
    },
    {
      'id': 'TKT-004',
      'customer': 'Meena Devi',
      'subject': 'Payment failed twice',
      'status': 'Resolved',
      'priority': 'Low',
      'date': '09-06-2025',
      'avatar': 'MD',
    },
    {
      'id': 'TKT-005',
      'customer': 'Karthik Raja',
      'subject': 'App crashing on login',
      'status': 'In Progress',
      'priority': 'Medium',
      'date': '08-06-2025',
      'avatar': 'KR',
    },
    {
      'id': 'TKT-006',
      'customer': 'Sindhu Nair',
      'subject': 'Coupon code not working',
      'status': 'Resolved',
      'priority': 'Low',
      'date': '07-06-2025',
      'avatar': 'SN',
    },
  ];

  Color _statusColor(String s) {
    switch (s) {
      case 'Open':        return C.red;
      case 'In Progress': return C.orange;
      case 'Resolved':    return C.green;
      default:            return C.textMid;
    }
  }

  Color _priorityColor(String p) {
    switch (p) {
      case 'High':   return C.red;
      case 'Medium': return C.orange;
      case 'Low':    return C.green;
      default:       return C.textMid;
    }
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _tickets.where((t) {
      final matchSearch = _search.isEmpty ||
          t['customer'].toLowerCase().contains(_search.toLowerCase()) ||
          t['subject'].toLowerCase().contains(_search.toLowerCase()) ||
          t['id'].toLowerCase().contains(_search.toLowerCase());
      final matchFilter = _filter == 'All' || t['status'] == _filter;
      return matchSearch && matchFilter;
    }).toList();

    return Scaffold(
      backgroundColor: C.bg,
      appBar: const EcomAppBar(showBack: true),
      body: Column(children: [
        // ── Header Stats ──
        Container(
          color: Colors.white,
          padding: const EdgeInsets.all(16),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const SecTitle('Support Tickets'),
            const SizedBox(height: 14),
            Row(children: [
              _StatCard('14',  'Open',        C.redLight,     C.red),
              const SizedBox(width: 10),
              _StatCard('9',   'In Progress', C.orangeLight,  C.orange),
              const SizedBox(width: 10),
              _StatCard('231', 'Resolved',    C.greenLight,   C.green),
              const SizedBox(width: 10),
              _StatCard('254', 'Total',       C.primaryLight, C.primary),
            ]),
            const SizedBox(height: 14),
            // ── Search ──
            Container(
              decoration: kCard(r: 10),
              child: TextField(
                onChanged: (v) => setState(() => _search = v),
                decoration: const InputDecoration(
                  hintText: 'Search tickets…',
                  hintStyle: TextStyle(color: C.textLight, fontSize: 13),
                  prefixIcon: Icon(Icons.search_rounded, color: C.textLight, size: 18),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
            const SizedBox(height: 10),
            // ── Filter Chips ──
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: ['All', 'Open', 'In Progress', 'Resolved'].map((f) {
                  final selected = _filter == f;
                  return GestureDetector(
                    onTap: () => setState(() => _filter = f),
                    child: Container(
                      margin: const EdgeInsets.only(right: 8),
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                      decoration: BoxDecoration(
                        color: selected ? C.primary : C.bg,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: selected ? C.primary : Colors.grey.shade300,
                        ),
                      ),
                      child: Text(f,
                          style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: selected ? Colors.white : C.textMid)),
                    ),
                  );
                }).toList(),
              ),
            ),
          ]),
        ),
        const Divider(height: 1),
        // ── Ticket List ──
        Expanded(
          child: filtered.isEmpty
              ? const Center(
              child: Text('No tickets found',
                  style: TextStyle(fontSize: 14, color: C.textMid)))
              : ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: filtered.length,
            itemBuilder: (_, i) {
              final t = filtered[i];
              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                decoration: kCard(),
                padding: const EdgeInsets.all(14),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(children: [
                        // Avatar
                        Container(
                          width: 40, height: 40,
                          decoration: BoxDecoration(
                              color: C.primaryLight,
                              borderRadius: BorderRadius.circular(12)),
                          child: Center(
                            child: Text(t['avatar'],
                                style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w800,
                                    color: C.primary)),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(t['customer'],
                                    style: const TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w700,
                                        color: C.textDark)),
                                Text(t['id'],
                                    style: const TextStyle(
                                        fontSize: 11, color: C.textMid)),
                              ]),
                        ),
                        // Status Badge
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: _statusColor(t['status']).withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(t['status'],
                              style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                  color: _statusColor(t['status']))),
                        ),
                      ]),
                      const SizedBox(height: 10),
                      const Divider(height: 1),
                      const SizedBox(height: 10),
                      Text(t['subject'],
                          style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: C.textDark)),
                      const SizedBox(height: 8),
                      Row(children: [
                        // Priority
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: _priorityColor(t['priority'])
                                .withValues(alpha: 0.10),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Row(mainAxisSize: MainAxisSize.min, children: [
                            Icon(Icons.flag_rounded,
                                size: 11,
                                color: _priorityColor(t['priority'])),
                            const SizedBox(width: 3),
                            Text(t['priority'],
                                style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w700,
                                    color: _priorityColor(t['priority']))),
                          ]),
                        ),
                        const SizedBox(width: 10),
                        Icon(Icons.calendar_today_rounded,
                            size: 11, color: C.textLight),
                        const SizedBox(width: 4),
                        Text(t['date'],
                            style: const TextStyle(
                                fontSize: 11, color: C.textMid)),
                        const Spacer(),
                        // Action Buttons
                        _ActionBtn(
                            Icons.visibility_rounded, C.blue, C.blueLight,
                                () {}),
                        const SizedBox(width: 6),
                        _ActionBtn(
                            Icons.reply_rounded, C.teal, C.primaryLight,
                                () {}),
                        const SizedBox(width: 6),
                        _ActionBtn(
                            Icons.close_rounded, C.red, C.redLight,
                                () {}),
                      ]),
                    ]),
              );
            },
          ),
        ),
      ]),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String v, l;
  final Color bg, fg;
  const _StatCard(this.v, this.l, this.bg, this.fg);

  @override
  Widget build(BuildContext context) => Expanded(
    child: Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
          color: bg, borderRadius: BorderRadius.circular(14)),
      child: Column(children: [
        Text(v,
            style: TextStyle(
                fontSize: 18, fontWeight: FontWeight.w900, color: fg)),
        const SizedBox(height: 2),
        Text(l,
            style: const TextStyle(fontSize: 10, color: C.textMid)),
      ]),
    ),
  );
}

class _ActionBtn extends StatelessWidget {
  final IconData icon;
  final Color fg, bg;
  final VoidCallback onTap;
  const _ActionBtn(this.icon, this.fg, this.bg, this.onTap);

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Container(
      width: 30, height: 30,
      decoration: BoxDecoration(
          color: bg, borderRadius: BorderRadius.circular(8)),
      child: Icon(icon, color: fg, size: 15),
    ),
  );
}