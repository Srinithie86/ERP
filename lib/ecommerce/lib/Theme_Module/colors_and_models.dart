// ════════════════════════════════════════════════════
//  colors_and_models.dart
//  Shared across all screens — import this everywhere
// ════════════════════════════════════════════════════
import 'package:flutter/material.dart';

// ═══════════════════════════════════════════
//  COLORS
// ═══════════════════════════════════════════
class C {
  static const bg           = Colors.white;
  static const card         = Color(0xFFEAF6F4);
  static const title        = Color(0xFF2A2FA8);
  static const primary      = Color(0xFF26A69A);
  static const primaryLight = Color(0xFFE0F5EF);
  static const textDark     = Color(0xFF1A1E2E);
  static const textMid      = Color(0xFF6B7280);
  static const textLight    = Color(0xFFADB5BD);
  static const orange       = Color(0xFFF59E0B);
  static const blue         = Color(0xFF3B82F6);
  static const purple       = Color(0xFF8B5CF6);
  static const teal         = Color(0xFF14B8A6);
  static const red          = Color(0xFFEF4444);
  static const indigo       = Color(0xFF6366F1);
  static const pink         = Color(0xFFEC4899);
  static const green        = Color(0xFF22C55E);
  static const orangeLight  = Color(0xFFFEF3C7);
  static const yellowLight  = Color(0xFFFFFBEB);
  static const purpleLight  = Color(0xFFF5F3FF);
  static const pinkLight    = Color(0xFFFCE7F3);
  static const blueLight    = Color(0xFFEFF6FF);
  static const greenLight   = Color(0xFFF0FDF4);
  static const redLight     = Color(0xFFFFECEC);
  static const border       = Color(0xFFE5E7EB);
}

// ═══════════════════════════════════════════
//  SHARED CARD DECORATION
// ═══════════════════════════════════════════
BoxDecoration kCard({Color? color, double r = 18}) => BoxDecoration(
  color: color ?? C.card,
  borderRadius: BorderRadius.circular(r),
  boxShadow: [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.05),
      blurRadius: 12,
      offset: const Offset(0, 3),
    )
  ],
);

// ═══════════════════════════════════════════
//  BANNER IMAGE MODEL
// ═══════════════════════════════════════════
class BannerImage {
  final int id;
  String bannerName;
  String bannerImage;
  String bannerPosition;
  int    displayOrder;
  String status;
  String mainText;
  String subText;
  String buttonText;
  String buttonLink;
  DateTime startDate;
  DateTime endDate;
  DateTime updatedDate;

  BannerImage({
    required this.id,
    this.bannerName    = '',
    this.bannerImage   = '',
    this.bannerPosition = '',
    this.displayOrder  = 1,
    this.status        = 'Active',
    this.mainText      = '',
    this.subText       = '',
    this.buttonText    = '',
    this.buttonLink    = '',
    required this.startDate,
    required this.endDate,
    required this.updatedDate,
  });
}

// ═══════════════════════════════════════════
//  ORDER MODEL  (simple, for dashboard rows)
// ═══════════════════════════════════════════
class Order {
  final String id, name, status, date;
  final int    amount, items;
  const Order({
    required this.id,
    required this.name,
    required this.status,
    required this.amount,
    required this.items,
    required this.date,
  });
}

const List<Order> kAllOrders = [
  Order(id: '#ORD-2401', name: 'Thanu',      status: 'Delivered',  amount: 4200,  items: 2, date: '1 Apr 2026'),
  Order(id: '#ORD-2402', name: 'Ravi Kumar', status: 'Processing', amount: 2850,  items: 1, date: '2 Apr 2026'),
  Order(id: '#ORD-2403', name: 'Priya S',    status: 'Pending',    amount: 6400,  items: 3, date: '2 Apr 2026'),
  Order(id: '#ORD-2404', name: 'Ajith M',    status: 'Cancelled',  amount: 1500,  items: 1, date: '3 Apr 2026'),
  Order(id: '#ORD-2405', name: 'Sundar R',   status: 'Delivered',  amount: 3350,  items: 2, date: '3 Apr 2026'),
  Order(id: '#ORD-2406', name: 'Kavitha N',  status: 'Pending',    amount: 7200,  items: 4, date: '3 Apr 2026'),
  Order(id: '#ORD-2407', name: 'Manoj K',    status: 'Processing', amount: 5100,  items: 2, date: '4 Apr 2026'),
  Order(id: '#ORD-2408', name: 'Divya P',    status: 'Delivered',  amount: 1800,  items: 1, date: '4 Apr 2026'),
  Order(id: '#ORD-2409', name: 'Senthil A',  status: 'Pending',    amount: 9500,  items: 5, date: '4 Apr 2026'),
  Order(id: '#ORD-2410', name: 'Nirmala B',  status: 'Cancelled',  amount: 2200,  items: 1, date: '4 Apr 2026'),
  Order(id: '#ORD-2411', name: 'Karthik V',  status: 'Delivered',  amount: 4750,  items: 3, date: '5 Apr 2026'),
  Order(id: '#ORD-2412', name: 'Anitha L',   status: 'Processing', amount: 3300,  items: 2, date: '5 Apr 2026'),
  Order(id: '#ORD-2413', name: 'Balu S',     status: 'Pending',    amount: 8100,  items: 4, date: '5 Apr 2026'),
  Order(id: '#ORD-2414', name: 'Ramya K',    status: 'Delivered',  amount: 2650,  items: 1, date: '5 Apr 2026'),
];

Color statusColor(String s) {
  switch (s) {
    case 'Delivered':  return C.green;
    case 'Processing': return C.orange;
    case 'Pending':    return C.blue;
    case 'Cancelled':  return C.red;
    default:           return C.textMid;
  }
}

// ═══════════════════════════════════════════
//  APP BAR  (shared across all screens)
// ═══════════════════════════════════════════
class EcomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final bool showBack;
  const EcomAppBar({super.key, this.showBack = false});

  @override Size get preferredSize => const Size.fromHeight(68);

  @override
  Widget build(BuildContext context) => Container(
    color: C.primary,
    padding: EdgeInsets.fromLTRB(
        16, MediaQuery.of(context).padding.top + 8, 16, 10),
    child: Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
      GestureDetector(
        onTap: showBack
            ? () => Navigator.pop(context)
            : () => Scaffold.of(context).openDrawer(),
        child: Icon(
          showBack ? Icons.arrow_back_ios_new_rounded : Icons.menu,
          size: 22,
          color: Colors.white,
        ),
      ),
      const SizedBox(width: 10),
      const Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Ecommerce',
                style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                    color: Colors.white)),
            Text('Workplace Dashboard',
                style: TextStyle(fontSize: 11, color: Colors.white70)),
          ],
        ),
      ),
      Stack(children: [
        Container(
          width: 38, height: 38,
          decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.15),
              shape: BoxShape.circle),
          child: const Icon(Icons.notifications_outlined,
              size: 20, color: Colors.white),
        ),
        Positioned(
          right: 8, top: 8,
          child: Container(
            width: 7, height: 7,
            decoration:
            const BoxDecoration(color: C.red, shape: BoxShape.circle),
          ),
        ),
      ]),
    ]),
  );
}

// ═══════════════════════════════════════════
//  SHARED SMALL WIDGETS
// ═══════════════════════════════════════════
class SecTitle extends StatelessWidget {
  final String t;
  const SecTitle(this.t, {super.key});
  @override
  Widget build(BuildContext context) => Text(t,
      style: const TextStyle(
          fontSize: 18, fontWeight: FontWeight.w900, color: C.textDark));
}