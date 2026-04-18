// ════════════════════════════════════════════════════
//  customer_wishlist_screen.dart
// ════════════════════════════════════════════════════
import 'package:flutter/material.dart';
import '../Theme_Module/colors_and_models.dart';

class WishlistScreen extends StatefulWidget {
  const WishlistScreen({super.key});
  @override
  State<WishlistScreen> createState() => _WishlistScreenState();
}

class _WishlistScreenState extends State<WishlistScreen> {
  static const _filters = [
    'All', 'Clothing', 'Electronics', 'Accessories', 'Footwear', 'Sports'
  ];
  int _filterIdx = 0;

  static const _items = [
    _WishItem('Smart Watch Series 5', 'Electronics', '₹3,800', 24, C.blue,    C.blueLight),
    _WishItem('Running Sneakers',      'Footwear',    '₹2,200', 18, C.primary, C.primaryLight),
    _WishItem('Denim Jacket Classic',  'Clothing',    '₹1,200', 15, C.orange,  C.orangeLight),
    _WishItem('Wireless Earbuds Pro',  'Electronics', '₹1,500', 12, C.blue,    C.blueLight),
    _WishItem('Leather Wallet',        'Accessories', '₹600',   10, C.purple,  C.purpleLight),
    _WishItem('Yoga Mat Premium',      'Sports',      '₹850',    9, C.green,   C.greenLight),
    _WishItem('Cotton T-Shirt',        'Clothing',    '₹500',    7, C.orange,  C.orangeLight),
    _WishItem('Resistance Band Set',   'Sports',      '₹450',    5, C.green,   C.greenLight),
  ];

  List<_WishItem> get _filtered {
    final f = _filters[_filterIdx];
    if (f == 'All') return _items;
    return _items.where((w) => w.category == f).toList();
  }

  @override
  Widget build(BuildContext context) {
    final list  = _filtered;
    final total = _items.fold(0, (s, w) => s + w.saves);

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
              colors: [C.red, C.red.withValues(alpha: 0.75)],
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
              child: const Icon(Icons.favorite_rounded, color: Colors.white, size: 26),
            ),
            const SizedBox(width: 14),
            const Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('Wishlist',
                    style: TextStyle(
                        color: Colors.white, fontSize: 16, fontWeight: FontWeight.w800)),
                SizedBox(height: 2),
                Text('Products saved by customers',
                    style: TextStyle(color: Colors.white70, fontSize: 12)),
              ]),
            ),
            Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
              Text('$total',
                  style: const TextStyle(
                      color: Colors.white, fontSize: 22, fontWeight: FontWeight.w900)),
              const Text('Total Saves',
                  style: TextStyle(color: Colors.white70, fontSize: 11)),
            ]),
          ]),
        ),

        // ── Category filter chips ──
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
                    color: sel ? C.red : C.card,
                    borderRadius: BorderRadius.circular(22),
                    boxShadow: sel
                        ? [BoxShadow(
                        color: C.red.withValues(alpha: 0.3),
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

        // ── Wishlist items ──
        Expanded(
          child: list.isEmpty
              ? const Center(
              child: Text('No items found',
                  style: TextStyle(fontSize: 14, color: C.textMid)))
              : ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: list.length,
            itemBuilder: (_, i) => _WishCard(item: list[i]),
          ),
        ),
      ]),
    );
  }
}

// ── Data Model ──
class _WishItem {
  final String name, category, price;
  final int    saves;
  final Color  ic, bg;
  const _WishItem(this.name, this.category, this.price, this.saves, this.ic, this.bg);
}

// ── Wish Card ──
class _WishCard extends StatelessWidget {
  final _WishItem item;
  const _WishCard({required this.item});

  @override
  Widget build(BuildContext context) => Container(
    margin: const EdgeInsets.only(bottom: 12),
    decoration: kCard(),
    padding: const EdgeInsets.all(14),
    child: Row(children: [
      Container(
        width: 50, height: 50,
        decoration: BoxDecoration(
            color: item.bg, borderRadius: BorderRadius.circular(14)),
        child: Icon(Icons.inventory_2_rounded, color: item.ic, size: 24),
      ),
      const SizedBox(width: 12),
      Expanded(
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(item.name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                  fontSize: 14, fontWeight: FontWeight.w700, color: C.textDark)),
          const SizedBox(height: 4),
          Row(children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                  color: item.bg, borderRadius: BorderRadius.circular(20)),
              child: Text(item.category,
                  style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: item.ic)),
            ),
            const SizedBox(width: 8),
            Text(item.price,
                style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    color: C.textDark)),
          ]),
        ]),
      ),
      const SizedBox(width: 8),
      Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
        Row(children: [
          const Icon(Icons.favorite_rounded, size: 14, color: C.red),
          const SizedBox(width: 4),
          Text('${item.saves}',
              style: const TextStyle(
                  fontSize: 13, fontWeight: FontWeight.w700, color: C.textDark)),
        ]),
        const SizedBox(height: 4),
        const Text('saves', style: TextStyle(fontSize: 10, color: C.textLight)),
      ]),
    ]),
  );
}