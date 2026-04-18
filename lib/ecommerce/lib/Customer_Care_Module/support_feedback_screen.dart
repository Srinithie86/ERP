import 'package:flutter/material.dart';
import '../Theme_Module/colors_and_models.dart';

class SupportFeedbackScreen extends StatefulWidget {
  const SupportFeedbackScreen({super.key});
  @override
  State<SupportFeedbackScreen> createState() => _SupportFeedbackScreenState();
}

class _SupportFeedbackScreenState extends State<SupportFeedbackScreen> {
  String _filter = 'All';

  final List<Map<String, dynamic>> _feedbacks = [
    {
      'name': 'Ravi Kumar',
      'avatar': 'RK',
      'rating': 5,
      'comment': 'Excellent support! Issue resolved within 2 hours. Very satisfied.',
      'agent': 'Deepa',
      'ticket': 'TKT-001',
      'date': '12-06-2025',
      'tag': 'Excellent',
    },
    {
      'name': 'Priya Sharma',
      'avatar': 'PS',
      'rating': 4,
      'comment': 'Good response time. Agent was helpful and polite.',
      'agent': 'Ramesh',
      'ticket': 'TKT-002',
      'date': '11-06-2025',
      'tag': 'Good',
    },
    {
      'name': 'Arun Selvan',
      'avatar': 'AS',
      'rating': 2,
      'comment': 'Refund took too long. Not happy with the process.',
      'agent': 'Siva',
      'ticket': 'TKT-003',
      'date': '10-06-2025',
      'tag': 'Poor',
    },
    {
      'name': 'Meena Devi',
      'avatar': 'MD',
      'rating': 5,
      'comment': 'Super fast resolution. The team was very professional.',
      'agent': 'Deepa',
      'ticket': 'TKT-004',
      'date': '09-06-2025',
      'tag': 'Excellent',
    },
    {
      'name': 'Karthik Raja',
      'avatar': 'KR',
      'rating': 3,
      'comment': 'Average experience. Took multiple follow-ups to resolve.',
      'agent': 'Ramesh',
      'ticket': 'TKT-005',
      'date': '08-06-2025',
      'tag': 'Average',
    },
    {
      'name': 'Sindhu Nair',
      'avatar': 'SN',
      'rating': 4,
      'comment': 'Quick fix for the coupon issue. Happy with support.',
      'agent': 'Siva',
      'ticket': 'TKT-006',
      'date': '07-06-2025',
      'tag': 'Good',
    },
  ];

  Color _tagColor(String tag) {
    switch (tag) {
      case 'Excellent': return C.green;
      case 'Good':      return C.teal;
      case 'Average':   return C.orange;
      case 'Poor':      return C.red;
      default:          return C.textMid;
    }
  }

  Color _tagBg(String tag) {
    switch (tag) {
      case 'Excellent': return C.greenLight;
      case 'Good':      return C.primaryLight;
      case 'Average':   return C.orangeLight;
      case 'Poor':      return C.redLight;
      default:          return C.bg;
    }
  }

  double get _avgRating {
    if (_feedbacks.isEmpty) return 0;
    final total = _feedbacks.fold<int>(0, (s, f) => s + (f['rating'] as int));
    return total / _feedbacks.length;
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _feedbacks.where((f) {
      return _filter == 'All' || f['tag'] == _filter;
    }).toList();

    return Scaffold(
      backgroundColor: C.bg,
      appBar: const EcomAppBar(showBack: true),
      body: Column(children: [
        // ── Header ──
        Container(
          color: Colors.white,
          padding: const EdgeInsets.all(16),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const SecTitle('Support Feedback'),
            const SizedBox(height: 14),
            // Avg Rating Card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [C.primary, Color(0xFF7B63E8)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(children: [
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  const Text('Average Rating',
                      style: TextStyle(
                          fontSize: 12,
                          color: Colors.white70,
                          fontWeight: FontWeight.w500)),
                  const SizedBox(height: 4),
                  Text(_avgRating.toStringAsFixed(1),
                      style: const TextStyle(
                          fontSize: 36,
                          fontWeight: FontWeight.w900,
                          color: Colors.white)),
                  const SizedBox(height: 6),
                  Row(children: List.generate(5, (i) {
                    return Icon(
                      i < _avgRating.round()
                          ? Icons.star_rounded
                          : Icons.star_outline_rounded,
                      size: 18,
                      color: Colors.amber,
                    );
                  })),
                ]),
                const Spacer(),
                Column(children: [
                  _RatingBar('5★', _feedbacks.where((f) => f['rating'] == 5).length, _feedbacks.length),
                  _RatingBar('4★', _feedbacks.where((f) => f['rating'] == 4).length, _feedbacks.length),
                  _RatingBar('3★', _feedbacks.where((f) => f['rating'] == 3).length, _feedbacks.length),
                  _RatingBar('2★', _feedbacks.where((f) => f['rating'] == 2).length, _feedbacks.length),
                  _RatingBar('1★', _feedbacks.where((f) => f['rating'] == 1).length, _feedbacks.length),
                ]),
              ]),
            ),
            const SizedBox(height: 14),
            // Stats
            Row(children: [
              _StatCard('${_feedbacks.length}', 'Total',     C.primaryLight, C.primary),
              const SizedBox(width: 10),
              _StatCard('${_feedbacks.where((f) => f['tag'] == 'Excellent').length}', 'Excellent', C.greenLight, C.green),
              const SizedBox(width: 10),
              _StatCard('${_feedbacks.where((f) => f['tag'] == 'Poor').length}',      'Poor',      C.redLight,   C.red),
            ]),
            const SizedBox(height: 14),
            // Filter Chips
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: ['All', 'Excellent', 'Good', 'Average', 'Poor'].map((f) {
                  final selected = _filter == f;
                  return GestureDetector(
                    onTap: () => setState(() => _filter = f),
                    child: Container(
                      margin: const EdgeInsets.only(right: 8),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 6),
                      decoration: BoxDecoration(
                        color: selected ? C.primary : C.bg,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                            color: selected
                                ? C.primary
                                : Colors.grey.shade300),
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
        // ── Feedback List ──
        Expanded(
          child: filtered.isEmpty
              ? const Center(
              child: Text('No feedback found',
                  style: TextStyle(fontSize: 14, color: C.textMid)))
              : ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: filtered.length,
            itemBuilder: (_, i) {
              final f = filtered[i];
              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                decoration: kCard(),
                padding: const EdgeInsets.all(14),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(children: [
                        Container(
                          width: 42, height: 42,
                          decoration: BoxDecoration(
                              color: _tagBg(f['tag']),
                              borderRadius: BorderRadius.circular(12)),
                          child: Center(
                            child: Text(f['avatar'],
                                style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w800,
                                    color: _tagColor(f['tag']))),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                              crossAxisAlignment:
                              CrossAxisAlignment.start,
                              children: [
                                Text(f['name'],
                                    style: const TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w700,
                                        color: C.textDark)),
                                Text(
                                    '${f['ticket']}  •  Agent: ${f['agent']}',
                                    style: const TextStyle(
                                        fontSize: 11,
                                        color: C.textMid)),
                              ]),
                        ),
                        // Tag badge
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: _tagBg(f['tag']),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(f['tag'],
                              style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                  color: _tagColor(f['tag']))),
                        ),
                      ]),
                      const SizedBox(height: 10),
                      // Stars
                      Row(children: [
                        ...List.generate(5, (s) => Icon(
                          s < (f['rating'] as int)
                              ? Icons.star_rounded
                              : Icons.star_outline_rounded,
                          size: 16,
                          color: Colors.amber,
                        )),
                        const SizedBox(width: 6),
                        Text('${f['rating']}.0',
                            style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: C.textDark)),
                        const Spacer(),
                        Icon(Icons.calendar_today_rounded,
                            size: 11, color: C.textLight),
                        const SizedBox(width: 4),
                        Text(f['date'],
                            style: const TextStyle(
                                fontSize: 11, color: C.textMid)),
                      ]),
                      const SizedBox(height: 8),
                      // Comment
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: C.bg,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(f['comment'],
                            style: const TextStyle(
                                fontSize: 12,
                                color: C.textMid,
                                height: 1.5)),
                      ),
                      const SizedBox(height: 10),
                      // Actions
                      Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            _ActionBtn(Icons.reply_rounded,    C.blue,   C.blueLight,    () {}),
                            const SizedBox(width: 6),
                            _ActionBtn(Icons.flag_rounded,     C.orange, C.orangeLight,  () {}),
                            const SizedBox(width: 6),
                            _ActionBtn(Icons.delete_rounded,   C.red,    C.redLight,     () {}),
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

// Rating bar widget inside the rating card
class _RatingBar extends StatelessWidget {
  final String label;
  final int count;
  final int total;
  const _RatingBar(this.label, this.count, this.total);

  @override
  Widget build(BuildContext context) {
    final pct = total == 0 ? 0.0 : count / total;
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(children: [
        Text(label,
            style: const TextStyle(
                fontSize: 9, color: Colors.white70, fontWeight: FontWeight.w600)),
        const SizedBox(width: 6),
        Container(
          width: 80, height: 6,
          decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(3)),
          child: FractionallySizedBox(
            alignment: Alignment.centerLeft,
            widthFactor: pct,
            child: Container(
              decoration: BoxDecoration(
                  color: Colors.amber,
                  borderRadius: BorderRadius.circular(3)),
            ),
          ),
        ),
        const SizedBox(width: 6),
        Text('$count',
            style: const TextStyle(
                fontSize: 9, color: Colors.white, fontWeight: FontWeight.w700)),
      ]),
    );
  }
}

// ═══════════════════════════════════════════
//  SHARED HELPERS (same style as your code)
// ═══════════════════════════════════════════
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