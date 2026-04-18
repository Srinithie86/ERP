// ════════════════════════════════════════════════════
//  customer_feedback_screen.dart
// ════════════════════════════════════════════════════
import 'package:flutter/material.dart';
import '../Theme_Module/colors_and_models.dart';

class CustomerFeedbackScreen extends StatefulWidget {
  const CustomerFeedbackScreen({super.key});
  @override
  State<CustomerFeedbackScreen> createState() => _CustomerFeedbackScreenState();
}

class _CustomerFeedbackScreenState extends State<CustomerFeedbackScreen> {
  static const _filters = ['All', '5★', '4★', '3★', '1-2★'];
  int _filterIdx = 0;

  static const _feedbacks = [
    _Feedback('Kavitha N',  'Smart Watch Series 5',  5, 'Excellent product! Works perfectly.',          '3 Apr 2026', C.green),
    _Feedback('Priya S',    'Running Sneakers',       5, 'Very comfortable, true to size.',              '2 Apr 2026', C.green),
    _Feedback('Sundar R',   'Yoga Mat Premium',       4, 'Good quality, slight smell initially.',        '3 Apr 2026', C.blue),
    _Feedback('Ravi Kumar', 'Leather Wallet',         4, 'Slim and sturdy, exactly as described.',       '2 Apr 2026', C.blue),
    _Feedback('Manoj K',    'Cotton T-Shirt',         3, 'Okay quality, expected better stitching.',     '4 Apr 2026', C.orange),
    _Feedback('Thanu',      'Wireless Earbuds Pro',   5, 'Amazing sound quality, great battery life!',   '1 Apr 2026', C.green),
    _Feedback('Divya P',    'Denim Jacket',           2, 'Colour faded after first wash. Disappointed.', '4 Apr 2026', C.red),
    _Feedback('Ajith M',    'Resistance Band Set',    1, 'Poor quality, broke within a week.',           '3 Apr 2026', C.red),
  ];

  List<_Feedback> get _filtered {
    switch (_filters[_filterIdx]) {
      case '5★':   return _feedbacks.where((f) => f.rating == 5).toList();
      case '4★':   return _feedbacks.where((f) => f.rating == 4).toList();
      case '3★':   return _feedbacks.where((f) => f.rating == 3).toList();
      case '1-2★': return _feedbacks.where((f) => f.rating <= 2).toList();
      default:     return _feedbacks;
    }
  }

  double get _avgRating =>
      _feedbacks.fold(0.0, (s, f) => s + f.rating) / _feedbacks.length;

  @override
  Widget build(BuildContext context) {
    final list = _filtered;
    return Scaffold(
      backgroundColor: C.bg,
      appBar: const EcomAppBar(showBack: true),
      body: Column(children: [
        // ── Header ──
        Container(
          margin: const EdgeInsets.all(16),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [C.orange, C.orange.withValues(alpha: 0.75)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(18),
          ),
          child: Row(children: [
            Container(
              width: 48, height: 48,
              decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(13)),
              child: const Icon(Icons.star_rounded, color: Colors.white, size: 26),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const Text('Customer Feedback',
                    style: TextStyle(
                        color: Colors.white, fontSize: 16, fontWeight: FontWeight.w800)),
                const SizedBox(height: 2),
                Row(
                  children: List.generate(
                    5,
                        (i) => Icon(
                      i < _avgRating.round()
                          ? Icons.star_rounded
                          : Icons.star_border_rounded,
                      size: 14,
                      color: Colors.white,
                    ),
                  ),
                ),
              ]),
            ),
            Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
              Text(_avgRating.toStringAsFixed(1),
                  style: const TextStyle(
                      color: Colors.white, fontSize: 26, fontWeight: FontWeight.w900)),
              const Text('Avg Rating',
                  style: TextStyle(color: Colors.white70, fontSize: 11)),
            ]),
          ]),
        ),

        // ── Filter chips ──
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: List.generate(_filters.length, (i) {
              final sel = _filterIdx == i;
              return GestureDetector(
                onTap: () => setState(() => _filterIdx = i),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  margin: const EdgeInsets.only(right: 8),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: sel ? C.orange : C.card,
                    borderRadius: BorderRadius.circular(22),
                    boxShadow: sel
                        ? [BoxShadow(
                        color: C.orange.withValues(alpha: 0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 3))]
                        : [],
                  ),
                  child: Text(_filters[i],
                      style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: sel ? Colors.white : C.textMid)),
                ),
              );
            }),
          ),
        ),
        const SizedBox(height: 12),

        // ── Feedback cards ──
        Expanded(
          child: list.isEmpty
              ? const Center(
              child: Text('No feedback found',
                  style: TextStyle(fontSize: 14, color: C.textMid)))
              : ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: list.length,
            itemBuilder: (_, i) => _FeedbackCard(fb: list[i]),
          ),
        ),
      ]),
    );
  }
}

// ── Data Model ──
class _Feedback {
  final String name, product, review, date;
  final int    rating;
  final Color  color;
  const _Feedback(
      this.name, this.product, this.rating, this.review, this.date, this.color);
}

// ── Feedback Card ──
class _FeedbackCard extends StatelessWidget {
  final _Feedback fb;
  const _FeedbackCard({required this.fb});

  @override
  Widget build(BuildContext context) => Container(
    margin: const EdgeInsets.only(bottom: 12),
    decoration: kCard(),
    padding: const EdgeInsets.all(14),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [
        Container(
          width: 42, height: 42,
          decoration: BoxDecoration(
              color: fb.color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12)),
          child: Center(
            child: Text(fb.name[0],
                style: TextStyle(
                    fontSize: 18, fontWeight: FontWeight.w800, color: fb.color)),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(fb.name,
                style: const TextStyle(
                    fontSize: 14, fontWeight: FontWeight.w700, color: C.textDark)),
            Text(fb.product,
                style: const TextStyle(fontSize: 11, color: C.textMid)),
          ]),
        ),
        Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
          Row(
            children: List.generate(
              5,
                  (i) => Icon(
                i < fb.rating ? Icons.star_rounded : Icons.star_border_rounded,
                size: 14,
                color: i < fb.rating ? C.orange : C.textLight,
              ),
            ),
          ),
          const SizedBox(height: 2),
          Text(fb.date,
              style: const TextStyle(fontSize: 10, color: C.textLight)),
        ]),
      ]),
      const SizedBox(height: 10),
      const Divider(height: 1, color: C.border),
      const SizedBox(height: 10),
      Text(fb.review,
          style: const TextStyle(fontSize: 13, color: C.textMid, height: 1.4)),
      const SizedBox(height: 8),
      Row(mainAxisAlignment: MainAxisAlignment.end, children: [
        _ActionBtn(Icons.thumb_up_rounded,     'Helpful', C.primaryLight, C.primary),
        const SizedBox(width: 8),
        _ActionBtn(Icons.reply_rounded,         'Reply',   C.blueLight,    C.blue),
        const SizedBox(width: 8),
        _ActionBtn(Icons.delete_outline_rounded,'Remove',  C.redLight,     C.red),
      ]),
    ]),
  );
}

// ── Action Button ──
class _ActionBtn extends StatelessWidget {
  final IconData icon;
  final String   label;
  final Color    bg, fg;
  const _ActionBtn(this.icon, this.label, this.bg, this.fg);

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
    decoration:
    BoxDecoration(color: bg, borderRadius: BorderRadius.circular(20)),
    child: Row(mainAxisSize: MainAxisSize.min, children: [
      Icon(icon, size: 12, color: fg),
      const SizedBox(width: 4),
      Text(label,
          style: TextStyle(
              fontSize: 11, fontWeight: FontWeight.w600, color: fg)),
    ]),
  );
}