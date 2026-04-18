// ════════════════════════════════════════════════════
//  drawer_screen.dart
//  EcomDrawer + all sub-screens + BannerScreen
// ════════════════════════════════════════════════════
import 'package:flutter/material.dart';
import '../Theme_Module/colors_and_models.dart';
import '../Order_Module/order_screen.dart';
import '../Reports_Module/reports_screen.dart';
import 'dashboard_screen.dart';
// import '../Customer_Module/customer_orders_screen.dart';
import '../Customer_Module/customer_feedback_screen.dart';
import '../Customer_Module/customer_wishlist_screen.dart';
import '../Banner_Module/banner_approval_screen.dart';
import '../Customer_Care_Module/support_feedback_screen.dart';
import '../Customer_Care_Module/support_tickets.dart';
import '../Customer_Care_Module/chat_communication.dart';


// ═══════════════════════════════════════════
//  DRAWER
// ═══════════════════════════════════════════
class EcomDrawer extends StatelessWidget {
  const EcomDrawer({super.key});

  void _go(BuildContext ctx, Widget s) {
    Navigator.pop(ctx);
    Navigator.push(ctx, MaterialPageRoute(builder: (_) => s));
  }

  @override
  Widget build(BuildContext context) => Drawer(
    backgroundColor: Colors.white,
    child: Column(children: [
      Container(
        width: double.infinity,
        color: C.primary,
        padding: EdgeInsets.fromLTRB(
            20, MediaQuery.of(context).padding.top + 20, 20, 24),
        child: Row(children: [
          Container(
            width: 54, height: 54,
            decoration: BoxDecoration(
                color: C.primaryLight,
                borderRadius: BorderRadius.circular(16)),
            child: const Icon(Icons.storefront_rounded,
                color: C.primary, size: 28),
          ),
          const SizedBox(width: 14),
          const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('E-Com Admin',
                    style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: C.title)),
                Text('admin@ecommerce.com',
                    style: TextStyle(fontSize: 12, color: C.textMid)),
              ]),
        ]),
      ),
      Expanded(
        child: ListView(
          padding: const EdgeInsets.symmetric(vertical: 8),
          children: [
            _dSec('MAIN'),
            _dTile(context, Icons.dashboard_rounded,      'Dashboard',           const DashboardScreen()),
            _dTile(context, Icons.image_rounded,           'Banner Images',       const BannerApprovalScreen()),
            _dTile(context, Icons.category_rounded,        'Category',            const CategoryScreen()),
            _dSec('COMMERCE'),
            _dTile(context, Icons.receipt_long_rounded,    'Orders',              const OrdersScreen()),
            _dTile(context, Icons.people_rounded,          'Customers',           const CustomerScreen()),
            _dTile(context, Icons.manage_accounts_rounded, 'Users',               const UsersScreen()),
            _dSec('LOGISTICS'),
            _dTile(context, Icons.local_shipping_rounded,  'Shipping & Delivery', const ShippingScreen()),
            _dSec('MARKETING'),
            _dTile(context, Icons.campaign_rounded,        'Marketing & Offers',  const MarketingScreen()),
            _dSec('SUPPORT'),
            _dTile(context, Icons.support_agent_rounded,   'Customer Care',       const CustomerCareScreen()),
          ],
        ),
      ),
      const Divider(height: 1),
      SizedBox(height: MediaQuery.of(context).padding.bottom),
    ]),
  );

  Widget _dSec(String t) => Padding(
    padding: const EdgeInsets.fromLTRB(16, 14, 16, 4),
    child: Text(t,
        style: const TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w700,
            color: C.textLight,
            letterSpacing: 1.3)),
  );

  Widget _dTile(BuildContext ctx, IconData icon, String label, Widget screen) =>
      ListTile(
        dense: true,
        leading: Container(
          width: 34, height: 34,
          decoration: BoxDecoration(
              color: C.primaryLight,
              borderRadius: BorderRadius.circular(9)),
          child: Icon(icon, color: C.primary, size: 18),
        ),
        title: Text(label,
            style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: C.textDark)),
        trailing: const Icon(Icons.chevron_right_rounded,
            color: C.textLight, size: 18),
        onTap: () => _go(ctx, screen),
      );
}

// ═══════════════════════════════════════════
//  CUSTOMER SCREEN  (3 tiles → 3 screens)
// ═══════════════════════════════════════════
class CustomerScreen extends StatelessWidget {
  const CustomerScreen({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: C.bg,
    appBar: const EcomAppBar(showBack: true),
    body: ListView(padding: const EdgeInsets.all(16), children: [
      const SecTitle('Customer Management'),
      const SizedBox(height: 14),

      // ── Stats row ──
      Row(children: [
        _StatCard('1,248', 'Total',  C.primaryLight, C.primary),
        const SizedBox(width: 10),
        _StatCard('943',   'Active', C.blueLight,    C.blue),
        const SizedBox(width: 10),
        _StatCard('57',    'New',    C.greenLight,   C.green),
      ]),
      const SizedBox(height: 20),

      // ── 3 Navigation Tiles ──
      _NavTile(
        icon: Icons.shopping_bag_rounded,
        title: 'Customer Orders',
        sub: 'View all orders by customers',
        ic: C.teal,
        bg: C.primaryLight,
        onTap: () => Navigator.push(context,
            MaterialPageRoute(builder: (_) => const OrdersScreen())),
      ),
      _NavTile(
        icon: Icons.star_rounded,
        title: 'Customer Feedback',
        sub: 'Ratings, reviews & comments',
        ic: C.orange,
        bg: C.orangeLight,
        onTap: () => Navigator.push(context,
            MaterialPageRoute(builder: (_) => const CustomerFeedbackScreen())),
      ),
      _NavTile(
        icon: Icons.favorite_rounded,
        title: 'Wishlist',
        sub: 'Products saved by customers',
        ic: C.red,
        bg: C.redLight,
        onTap: () => Navigator.push(context,
            MaterialPageRoute(builder: (_) => const WishlistScreen())),
      ),
    ]),
  );
}

// ═══════════════════════════════════════════
//  CUSTOMER CARE SCREEN  (3 tiles → 3 screens)
// ═══════════════════════════════════════════
class CustomerCareScreen extends StatelessWidget {
  const CustomerCareScreen({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: C.bg,
    appBar: const EcomAppBar(showBack: true),
    body: ListView(padding: const EdgeInsets.all(16), children: [
      const SecTitle('Customer Care'),
      const SizedBox(height: 14),

      // ── Stats row ──
      Row(children: [
        _StatCard('14',  'Open',     C.redLight,     C.red),
        const SizedBox(width: 10),
        _StatCard('231', 'Resolved', C.primaryLight, C.primary),
        const SizedBox(width: 10),
        _StatCard('8',   'Pending',  C.orangeLight,  C.orange),
      ]),
      const SizedBox(height: 20),

      // ── 3 Navigation Tiles ──
      _NavTile(
        icon: Icons.support_agent_rounded,
        title: 'Support Tickets',
        sub: 'Manage & resolve customer tickets',
        ic: C.teal,
        bg: C.primaryLight,
        onTap: () => Navigator.push(context,
            MaterialPageRoute(builder: (_) => const SupportTicketsScreen())),
      ),
      _NavTile(
        icon: Icons.chat_rounded,
        title: 'Chat / Communication',
        sub: 'Live chat & customer messages',
        ic: C.blue,
        bg: C.blueLight,
        onTap: () => Navigator.push(context,
            MaterialPageRoute(builder: (_) => const ChatCommunicationScreen())),
      ),
      _NavTile(
        icon: Icons.feedback_rounded,
        title: 'Support Feedback',
        sub: 'Reviews on support quality',
        ic: C.orange,
        bg: C.orangeLight,
        onTap: () => Navigator.push(context,
            MaterialPageRoute(builder: (_) => const SupportFeedbackScreen())),
      ),
    ]),
  );
}

// ═══════════════════════════════════════════
//  REUSABLE NAV TILE
// ═══════════════════════════════════════════
class _NavTile extends StatelessWidget {
  final IconData     icon;
  final String       title, sub;
  final Color        ic, bg;
  final VoidCallback onTap;
  const _NavTile({
    required this.icon, required this.title, required this.sub,
    required this.ic, required this.bg, required this.onTap,
  });

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: kCard(),
      padding: const EdgeInsets.all(16),
      child: Row(children: [
        Container(
          width: 50, height: 50,
          decoration: BoxDecoration(
              color: bg, borderRadius: BorderRadius.circular(14)),
          child: Icon(icon, color: ic, size: 24),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(title,
                style: const TextStyle(
                    fontSize: 14, fontWeight: FontWeight.w700, color: C.textDark)),
            const SizedBox(height: 2),
            Text(sub,
                style: const TextStyle(fontSize: 12, color: C.textLight)),
          ]),
        ),
        Icon(Icons.arrow_forward_ios_rounded, size: 15, color: ic),
      ]),
    ),
  );
}

// ═══════════════════════════════════════════
//  FORM FIELD HELPERS
// ═══════════════════════════════════════════
class _FormRow extends StatelessWidget {
  final List<Widget> children;
  const _FormRow({required this.children});

  @override
  Widget build(BuildContext context) => Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: children
        .expand((w) => [Expanded(child: w), const SizedBox(width: 14)])
        .toList()
      ..removeLast(),
  );
}

class _LabelField extends StatelessWidget {
  final String label;
  final TextEditingController ctrl;
  final bool required;
  final String? hint;
  final TextInputType keyboardType;
  const _LabelField(this.label, this.ctrl,
      {this.hint, this.required = false, this.keyboardType = TextInputType.text});

  @override
  Widget build(BuildContext context) =>
      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(label,
            style: const TextStyle(
                fontSize: 12, fontWeight: FontWeight.w600, color: C.textDark)),
        const SizedBox(height: 6),
        TextFormField(
          controller: ctrl,
          keyboardType: keyboardType,
          validator: required
              ? (v) => (v == null || v.trim().isEmpty) ? 'Required' : null
              : null,
          decoration: InputDecoration(
            hintText: hint ?? label,
            hintStyle: const TextStyle(color: C.textLight, fontSize: 13),
            filled: true, fillColor: Colors.white,
            contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: Colors.grey.shade200)),
            enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: Colors.grey.shade200)),
            focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: C.primary, width: 1.5)),
            errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: C.red)),
          ),
        ),
      ]);
}

class _StatusDropdown extends StatelessWidget {
  final String value;
  final ValueChanged<String?> onChanged;
  const _StatusDropdown({required this.value, required this.onChanged});
  static const _options = ['Active', 'Inactive', 'Scheduled', 'Expired'];

  @override
  Widget build(BuildContext context) =>
      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('Status',
            style: TextStyle(
                fontSize: 12, fontWeight: FontWeight.w600, color: C.textDark)),
        const SizedBox(height: 6),
        Container(
          decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.grey.shade200)),
          padding: const EdgeInsets.symmetric(horizontal: 14),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: value, isExpanded: true,
              style: const TextStyle(fontSize: 13, color: C.textDark),
              items: _options
                  .map((o) => DropdownMenuItem(value: o, child: Text(o)))
                  .toList(),
              onChanged: onChanged,
            ),
          ),
        ),
      ]);
}

class _DateField extends StatelessWidget {
  final String label;
  final DateTime date;
  final VoidCallback? onTap;
  final bool readOnly;
  const _DateField(this.label, this.date, this.onTap, {this.readOnly = false});

  String get _fmt =>
      '${date.day.toString().padLeft(2, '0')}-'
          '${date.month.toString().padLeft(2, '0')}-'
          '${date.year}';

  @override
  Widget build(BuildContext context) =>
      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(label,
            style: const TextStyle(
                fontSize: 12, fontWeight: FontWeight.w600, color: C.textDark)),
        const SizedBox(height: 6),
        GestureDetector(
          onTap: readOnly ? null : onTap,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
            decoration: BoxDecoration(
              color: readOnly ? C.bg : Colors.white,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Row(children: [
              Icon(Icons.calendar_today_rounded,
                  size: 14, color: readOnly ? C.textLight : C.primary),
              const SizedBox(width: 8),
              Text(_fmt,
                  style: TextStyle(
                      fontSize: 13,
                      color: readOnly ? C.textMid : C.textDark,
                      fontWeight: FontWeight.w500)),
            ]),
          ),
        ),
      ]);
}

// ═══════════════════════════════════════════
//  OTHER SUB-SCREENS
// ═══════════════════════════════════════════
class ShippingScreen extends StatelessWidget {
  const ShippingScreen({super.key});
  @override
  Widget build(BuildContext context) => _Sub('Shipping & Delivery', [
    (Icons.local_shipping_rounded,    'Shipping Method',    C.teal,   C.primaryLight),
    (Icons.track_changes_rounded,     'Delivery Tracking',  C.blue,   C.blueLight),
    (Icons.assignment_return_rounded, 'Returns Management', C.red,    C.redLight),
    (Icons.delivery_dining_rounded,   'Courier Management', C.orange, C.orangeLight),
  ], null);
}

class MarketingScreen extends StatelessWidget {
  const MarketingScreen({super.key});
  @override
  Widget build(BuildContext context) => _Sub('Marketing & Offers', [
    (Icons.local_offer_rounded, 'Promotions',          C.orange, C.orangeLight),
    (Icons.discount_rounded,    'Discounts & Coupons', C.red,    C.redLight),
    (Icons.campaign_rounded,    'Campaigns',           C.purple, C.purpleLight),
    (Icons.image_rounded,       'Banners & Ads',       C.blue,   C.blueLight),
  ], null);
}

class CategoryScreen extends StatelessWidget {
  const CategoryScreen({super.key});
  @override
  Widget build(BuildContext ctx) => _SimpleList(
      'Category', Icons.category_rounded,
      const ['Clothing & Apparel', 'Electronics', 'Accessories',
        'Footwear', 'Sports', 'Home & Living']);
}

class UsersScreen extends StatelessWidget {
  const UsersScreen({super.key});
  @override
  Widget build(BuildContext ctx) => _SimpleList(
      'Users', Icons.manage_accounts_rounded,
      const ['Admin – Full Access', 'Sales Manager', 'Support Executive',
        'Logistics Officer', 'Content Manager']);
}

class _Sub extends StatelessWidget {
  final String title;
  final List<(IconData, String, Color, Color)> secs;
  final Widget? header;
  const _Sub(this.title, this.secs, this.header);

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: C.bg,
    appBar: const EcomAppBar(showBack: true),
    body: ListView(padding: const EdgeInsets.all(16), children: [
      SecTitle(title),
      const SizedBox(height: 14),
      if (header != null) ...[header!, const SizedBox(height: 20)],
      ...secs.map((s) => Container(
        margin: const EdgeInsets.only(bottom: 10),
        decoration: kCard(),
        padding: const EdgeInsets.all(16),
        child: Row(children: [
          Container(
            width: 48, height: 48,
            decoration: BoxDecoration(
                color: s.$4, borderRadius: BorderRadius.circular(14)),
            child: Icon(s.$1, color: s.$3, size: 23),
          ),
          const SizedBox(width: 14),
          Expanded(child: Text(s.$2,
              style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: C.textDark))),
          Icon(Icons.arrow_forward_ios_rounded, size: 15, color: s.$3),
        ]),
      )),
    ]),
  );
}

class _SimpleList extends StatelessWidget {
  final String title;
  final IconData icon;
  final List<String> items;
  const _SimpleList(this.title, this.icon, this.items);

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: C.bg,
    appBar: const EcomAppBar(showBack: true),
    body: ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: items.length,
      itemBuilder: (_, i) => Container(
        margin: const EdgeInsets.only(bottom: 10),
        decoration: kCard(),
        padding: const EdgeInsets.all(15),
        child: Row(children: [
          Container(
            width: 42, height: 42,
            decoration: BoxDecoration(
                color: C.primaryLight,
                borderRadius: BorderRadius.circular(12)),
            child: Icon(icon, color: C.primary, size: 20),
          ),
          const SizedBox(width: 14),
          Expanded(child: Text(items[i],
              style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: C.textDark))),
          const Icon(Icons.chevron_right_rounded, color: C.textLight),
        ]),
      ),
    ),
    floatingActionButton: FloatingActionButton(
      onPressed: () {},
      backgroundColor: C.primary,
      child: const Icon(Icons.add_rounded, color: Colors.white),
    ),
  );
}

// ═══════════════════════════════════════════
//  STAT CARD
// ═══════════════════════════════════════════
class _StatCard extends StatelessWidget {
  final String v, l;
  final Color bg, fg;
  const _StatCard(this.v, this.l, this.bg, this.fg);

  @override
  Widget build(BuildContext context) => Expanded(
    child: Container(
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
          color: bg, borderRadius: BorderRadius.circular(14)),
      child: Column(children: [
        Text(v,
            style: TextStyle(
                fontSize: 20, fontWeight: FontWeight.w900, color: fg)),
        const SizedBox(height: 2),
        Text(l,
            style: const TextStyle(fontSize: 11, color: C.textMid)),
      ]),
    ),
  );
}