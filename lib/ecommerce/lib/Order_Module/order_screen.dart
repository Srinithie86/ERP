import 'package:flutter/material.dart';
import '../Theme_Module/colors_and_models.dart';
import '../Dashboard_Module/drawer_screen.dart';

// ═══════════════════════════════════════════
//  ORDER STATUS
// ═══════════════════════════════════════════
enum OrderStatus { pending, processing, delivered, cancelled }

extension OrderStatusX on OrderStatus {
  String get label {
    switch (this) {
      case OrderStatus.pending:    return 'Pending';
      case OrderStatus.processing: return 'Processing';
      case OrderStatus.delivered:  return 'Delivered';
      case OrderStatus.cancelled:  return 'Cancelled';
    }
  }

  Color get color {
    switch (this) {
      case OrderStatus.pending:    return C.orange;
      case OrderStatus.processing: return C.blue;
      case OrderStatus.delivered:  return C.green;
      case OrderStatus.cancelled:  return C.red;
    }
  }

  Color get bgColor {
    switch (this) {
      case OrderStatus.pending:    return C.orangeLight;
      case OrderStatus.processing: return C.blueLight;
      case OrderStatus.delivered:  return C.greenLight;
      case OrderStatus.cancelled:  return C.redLight;
    }
  }
}

// ═══════════════════════════════════════════
//  ORDER PRODUCT MODEL
// ═══════════════════════════════════════════
class OrderProduct {
  final String name;
  final String category;
  final String variant;
  final int    qty;
  final int    price;

  OrderProduct({
    required this.name,
    required this.category,
    required this.variant,
    required this.qty,
    required this.price,
  });
}

// ═══════════════════════════════════════════
//  ORDER ITEM MODEL
// ═══════════════════════════════════════════
class OrderItem {
  final String      id;
  final String      customerName;
  final String      date;
  final OrderStatus orderStatus;
  final List<OrderProduct> products;

  OrderItem({
    required this.id,
    required this.customerName,
    required this.date,
    required this.orderStatus,
    required this.products,
  });

  int get totalAmount => products.fold(0, (s, p) => s + p.price * p.qty);
  int get totalItems   => products.fold(0, (s, p) => s + p.qty);
}

// ═══════════════════════════════════════════
//  CATEGORY → COLOR MAP
// ═══════════════════════════════════════════
const Map<String, List<Color>> kCatColors = {
  'Clothing':    [Color(0xFFFEF3C7), C.orange],
  'Electronics': [C.blueLight,       C.blue],
  'Accessories': [C.purpleLight,     C.purple],
  'Footwear':    [C.primaryLight,    C.primary],
  'Sports':      [C.greenLight,      C.green],
};

List<Color> catColors(String cat) =>
    kCatColors[cat] ?? [C.primaryLight, C.primary];

// ═══════════════════════════════════════════
//  SAMPLE DATA
// ═══════════════════════════════════════════
List<OrderItem> buildSampleOrders() => [
  OrderItem(
    id: '#ORD-2401', customerName: 'Thanu',
    date: '1 Apr 2026', orderStatus: OrderStatus.processing,
    products: [
      OrderProduct(name: 'Premium Cotton T-Shirt', category: 'Clothing',    variant: 'Size: M',       qty: 2, price: 500),
      OrderProduct(name: 'Wireless Earbuds Pro',   category: 'Electronics', variant: 'Color: Black',  qty: 2, price: 750),
    ],
  ),
  OrderItem(
    id: '#ORD-2402', customerName: 'Ravi Kumar',
    date: '2 Apr 2026', orderStatus: OrderStatus.pending,
    products: [
      OrderProduct(name: 'Leather Wallet Classic', category: 'Accessories', variant: 'Color: Brown', qty: 1, price: 600),
      OrderProduct(name: 'Running Sneakers',        category: 'Footwear',   variant: 'Size: 10',     qty: 1, price: 2200),
    ],
  ),
  OrderItem(
    id: '#ORD-2403', customerName: 'Priya S',
    date: '2 Apr 2026', orderStatus: OrderStatus.pending,
    products: [
      OrderProduct(name: 'Running Sneakers',     category: 'Footwear',    variant: 'Size: 9',       qty: 1, price: 2200),
      OrderProduct(name: 'Smart Watch Series 5', category: 'Electronics', variant: 'Color: Silver', qty: 1, price: 3800),
      OrderProduct(name: 'Yoga Mat Premium',     category: 'Sports',      variant: 'Color: Blue',   qty: 1, price: 850),
    ],
  ),
  OrderItem(
    id: '#ORD-2404', customerName: 'Ajith M',
    date: '3 Apr 2026', orderStatus: OrderStatus.cancelled,
    products: [
      OrderProduct(name: 'Premium Cotton T-Shirt', category: 'Clothing',    variant: 'Size: L',      qty: 1, price: 500),
      OrderProduct(name: 'Leather Wallet Classic', category: 'Accessories', variant: 'Color: Black', qty: 1, price: 600),
    ],
  ),
  OrderItem(
    id: '#ORD-2405', customerName: 'Sundar R',
    date: '3 Apr 2026', orderStatus: OrderStatus.delivered,
    products: [
      OrderProduct(name: 'Leather Wallet Classic', category: 'Accessories', variant: 'Color: Brown', qty: 1, price: 600),
      OrderProduct(name: 'Yoga Mat Premium',        category: 'Sports',     variant: 'Color: Green', qty: 1, price: 850),
    ],
  ),
  OrderItem(
    id: '#ORD-2406', customerName: 'Kavitha N',
    date: '3 Apr 2026', orderStatus: OrderStatus.processing,
    products: [
      OrderProduct(name: 'Smart Watch Series 5', category: 'Electronics', variant: 'Color: Gold',  qty: 1, price: 3800),
      OrderProduct(name: 'Wireless Earbuds Pro', category: 'Electronics', variant: 'Color: White', qty: 1, price: 1500),
      OrderProduct(name: 'Yoga Mat Premium',     category: 'Sports',      variant: 'Color: Pink',  qty: 2, price: 850),
    ],
  ),
  OrderItem(
    id: '#ORD-2407', customerName: 'Manoj K',
    date: '4 Apr 2026', orderStatus: OrderStatus.processing,
    products: [
      OrderProduct(name: 'Running Sneakers',       category: 'Footwear', variant: 'Size: 8',  qty: 1, price: 2200),
      OrderProduct(name: 'Premium Cotton T-Shirt', category: 'Clothing', variant: 'Size: XL', qty: 2, price: 500),
    ],
  ),
  OrderItem(
    id: '#ORD-2408', customerName: 'Divya P',
    date: '4 Apr 2026', orderStatus: OrderStatus.delivered,
    products: [
      OrderProduct(name: 'Leather Wallet Classic', category: 'Accessories', variant: 'Color: Red', qty: 1, price: 600),
    ],
  ),
];

// ═══════════════════════════════════════════
//  ORDERS SCREEN
// ═══════════════════════════════════════════
class OrdersScreen extends StatefulWidget {
  final String? initialFilter;
  const OrdersScreen({super.key, this.initialFilter});
  @override State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {
  static const _filters = ['All', 'Pending', 'Processing', 'Delivered', 'Cancelled'];

  int    _filterIdx = 0;
  String _search    = '';
  final  List<OrderItem> _orders = buildSampleOrders();

  @override
  void initState() {
    super.initState();
    final init = widget.initialFilter ?? 'All';
    _filterIdx = _filters.indexOf(init).clamp(0, _filters.length - 1);
  }

  String get _active => _filters[_filterIdx];

  List<OrderItem> get _filtered => _orders.where((o) {
    final matchFilter = _active == 'All' || o.orderStatus.label == _active;
    final q           = _search.toLowerCase();
    final matchSearch = q.isEmpty ||
        o.id.toLowerCase().contains(q) ||
        o.customerName.toLowerCase().contains(q);
    return matchFilter && matchSearch;
  }).toList();

  int _countFor(String f) => f == 'All'
      ? _orders.length
      : _orders.where((o) => o.orderStatus.label == f).length;

  Color _chipColor(String f) {
    switch (f) {
      case 'Pending':    return C.orange;
      case 'Processing': return C.blue;
      case 'Delivered':  return C.green;
      case 'Cancelled':  return C.red;
      default:           return C.primary;
    }
  }

  @override
  Widget build(BuildContext context) {
    final list = _filtered;
    return Scaffold(
      backgroundColor: C.bg,
      drawer: const EcomDrawer(),
      appBar: const EcomAppBar(),
      body: Column(children: [

        // ── Filter chips ──
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: List.generate(_filters.length, (i) {
              final sel   = _filterIdx == i;
              final name  = _filters[i];
              final cnt   = _countFor(name);
              final color = _chipColor(name);
              return GestureDetector(
                onTap: () => setState(() => _filterIdx = i),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  margin: const EdgeInsets.only(right: 8),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: sel ? (name == 'All' ? C.primary : color) : C.card,
                    borderRadius: BorderRadius.circular(22),
                    boxShadow: sel
                        ? [BoxShadow(
                        color: (name == 'All' ? C.primary : color).withValues(alpha: 0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 3))]
                        : [],
                  ),
                  child: Row(children: [
                    Text(name,
                        style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: sel ? Colors.white : C.textMid)),
                    const SizedBox(width: 5),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                      decoration: BoxDecoration(
                        color: sel ? Colors.white.withValues(alpha: 0.25) : C.bg,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text('$cnt',
                          style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w800,
                              color: sel ? Colors.white : C.textMid)),
                    ),
                  ]),
                ),
              );
            }),
          ),
        ),

        // ── Search ──
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Container(
            decoration: kCard(),
            child: TextField(
              onChanged: (v) => setState(() => _search = v),
              decoration: const InputDecoration(
                hintText: 'Search orders or customers…',
                hintStyle: TextStyle(color: C.textLight, fontSize: 14),
                prefixIcon: Icon(Icons.search_rounded, color: C.textLight),
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(vertical: 14),
              ),
            ),
          ),
        ),
        const SizedBox(height: 10),

        // ── Active filter label ──
        if (_active != 'All')
          Padding(
            padding: const EdgeInsets.only(left: 16, right: 16, bottom: 6),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                decoration: BoxDecoration(
                  color: _chipColor(_active).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: _chipColor(_active).withValues(alpha: 0.3)),
                ),
                child: Row(mainAxisSize: MainAxisSize.min, children: [
                  Container(
                    width: 7, height: 7,
                    decoration: BoxDecoration(
                        color: _chipColor(_active), shape: BoxShape.circle),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    '$_active orders  ·  ${list.length} found',
                    style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: _chipColor(_active)),
                  ),
                ]),
              ),
            ),
          ),

        // ── Order list ──
        Expanded(
          child: list.isEmpty
              ? _EmptyState(filter: _active)
              : ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            itemCount: list.length,
            itemBuilder: (_, i) => _OrderCard(order: list[i]),
          ),
        ),
      ]),
    );
  }
}

// ═══════════════════════════════════════════
//  ORDER CARD  (expandable, read-only)
// ═══════════════════════════════════════════
class _OrderCard extends StatefulWidget {
  final OrderItem order;
  const _OrderCard({required this.order});
  @override State<_OrderCard> createState() => _OrderCardState();
}

class _OrderCardState extends State<_OrderCard>
    with SingleTickerProviderStateMixin {
  bool _expanded = false;
  late AnimationController _anim;
  late Animation<double>   _rotate;

  @override
  void initState() {
    super.initState();
    _anim   = AnimationController(vsync: this, duration: const Duration(milliseconds: 250));
    _rotate = Tween<double>(begin: 0, end: 0.5).animate(
        CurvedAnimation(parent: _anim, curve: Curves.easeInOut));
  }

  @override
  void dispose() { _anim.dispose(); super.dispose(); }

  void _toggle() {
    setState(() => _expanded = !_expanded);
    _expanded ? _anim.forward() : _anim.reverse();
  }

  OrderItem   get o  => widget.order;
  OrderStatus get os => o.orderStatus;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: C.card,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: _expanded ? C.primary.withValues(alpha: 0.4) : C.border,
          width: _expanded ? 1.5 : 1,
        ),
        boxShadow: [BoxShadow(
          color: Colors.black.withValues(alpha: _expanded ? 0.08 : 0.04),
          blurRadius: _expanded ? 16 : 8,
          offset: const Offset(0, 3),
        )],
      ),
      child: Column(children: [

        // ── Header ──
        GestureDetector(
          onTap: _toggle,
          behavior: HitTestBehavior.opaque,
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(children: [
              Row(children: [
                Container(
                  width: 46, height: 46,
                  decoration: BoxDecoration(
                      color: C.blueLight,
                      borderRadius: BorderRadius.circular(13)),
                  child: const Icon(Icons.receipt_long_rounded, color: C.blue, size: 22),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(o.id,
                        style: const TextStyle(
                            fontSize: 14, fontWeight: FontWeight.w800, color: C.textDark)),
                    Text(o.customerName,
                        style: const TextStyle(fontSize: 12, color: C.textMid)),
                  ]),
                ),
                Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                  Text('₹${o.totalAmount}',
                      style: const TextStyle(
                          fontSize: 15, fontWeight: FontWeight.w800, color: C.textDark)),
                  const SizedBox(height: 4),
                  _StatusBadge(os.label, os.color, os.bgColor),
                ]),
                const SizedBox(width: 8),
                RotationTransition(
                  turns: _rotate,
                  child: const Icon(
                      Icons.keyboard_arrow_down_rounded, color: C.textLight, size: 22),
                ),
              ]),
              const SizedBox(height: 10),
              const Divider(height: 1, color: C.border),
              const SizedBox(height: 10),
              Row(children: [
                const Icon(Icons.calendar_today_rounded, size: 11, color: C.textLight),
                const SizedBox(width: 4),
                Text(o.date, style: const TextStyle(fontSize: 11, color: C.textLight)),
                const SizedBox(width: 14),
                const Icon(Icons.layers_rounded, size: 11, color: C.textLight),
                const SizedBox(width: 4),
                Text('${o.totalItems} items',
                    style: const TextStyle(fontSize: 11, color: C.textLight)),
              ]),
            ]),
          ),
        ),

        // ── Expanded: product list only ──
        if (_expanded) ...[
          Container(
              margin: const EdgeInsets.symmetric(horizontal: 14),
              height: 1,
              color: C.border),
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                const Icon(Icons.inventory_2_rounded, size: 13, color: C.primary),
                const SizedBox(width: 6),
                Text('Products (${o.products.length})',
                    style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: C.primary,
                        letterSpacing: 0.3)),
              ]),
              const SizedBox(height: 10),
              ...o.products.map((p) => _ProductTile(product: p)),
            ]),
          ),
        ],
      ]),
    );
  }
}

// ═══════════════════════════════════════════
//  PRODUCT TILE  (read-only)
// ═══════════════════════════════════════════
class _ProductTile extends StatelessWidget {
  final OrderProduct product;
  const _ProductTile({required this.product});

  @override
  Widget build(BuildContext context) {
    final cc = catColors(product.category);
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(11),
      decoration: BoxDecoration(
        color: C.bg,
        borderRadius: BorderRadius.circular(13),
        border: Border.all(color: C.border),
      ),
      child: Row(children: [
        Container(
          width: 40, height: 40,
          decoration: BoxDecoration(
              color: cc[0], borderRadius: BorderRadius.circular(10)),
          child: Icon(Icons.inventory_2_rounded, color: cc[1], size: 20),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(product.name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                    fontSize: 12.5, fontWeight: FontWeight.w700, color: C.textDark)),
            const SizedBox(height: 2),
            Row(children: [
              _CatPill(product.category, cc[0], cc[1]),
              const SizedBox(width: 6),
              Text(product.variant,
                  style: const TextStyle(fontSize: 10, color: C.textLight)),
            ]),
          ]),
        ),
        Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
          Text('₹${product.price * product.qty}',
              style: const TextStyle(
                  fontSize: 13, fontWeight: FontWeight.w800, color: C.textDark)),
          Text('${product.qty} × ₹${product.price}',
              style: const TextStyle(fontSize: 10, color: C.textLight)),
        ]),
      ]),
    );
  }
}

// ═══════════════════════════════════════════
//  HELPERS
// ═══════════════════════════════════════════
class _StatusBadge extends StatelessWidget {
  final String label;
  final Color  color, bgColor;
  const _StatusBadge(this.label, this.color, this.bgColor);

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
    decoration: BoxDecoration(
        color: bgColor, borderRadius: BorderRadius.circular(20)),
    child: Row(mainAxisSize: MainAxisSize.min, children: [
      Container(
          width: 5, height: 5,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
      const SizedBox(width: 4),
      Text(label,
          style: TextStyle(
              fontSize: 10, fontWeight: FontWeight.w700, color: color)),
    ]),
  );
}

class _CatPill extends StatelessWidget {
  final String label;
  final Color  bg, fg;
  const _CatPill(this.label, this.bg, this.fg);

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
    decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(20)),
    child: Text(label,
        style: TextStyle(fontSize: 9.5, fontWeight: FontWeight.w600, color: fg)),
  );
}

// ═══════════════════════════════════════════
//  EMPTY STATE
// ═══════════════════════════════════════════
class _EmptyState extends StatelessWidget {
  final String filter;
  const _EmptyState({required this.filter});

  @override
  Widget build(BuildContext context) => Center(
    child: Column(mainAxisSize: MainAxisSize.min, children: [
      Container(
        width: 72, height: 72,
        decoration: BoxDecoration(
            color: C.bg, borderRadius: BorderRadius.circular(24)),
        child: const Icon(Icons.inbox_rounded, size: 36, color: C.textLight),
      ),
      const SizedBox(height: 16),
      Text('No $filter orders',
          style: const TextStyle(
              fontSize: 16, fontWeight: FontWeight.w700, color: C.textDark)),
      const SizedBox(height: 6),
      Text('No orders with "$filter" status.',
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 13, color: C.textMid, height: 1.5)),
    ]),
  );
}