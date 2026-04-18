import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../widgets/app_theme.dart';

class HelpSupportPage extends StatefulWidget {
  const HelpSupportPage({super.key});

  @override
  State<HelpSupportPage> createState() => _HelpSupportPageState();
}

class _HelpSupportPageState extends State<HelpSupportPage> {
  final _searchController = TextEditingController();
  String _searchQuery = '';
  int? _expandedFaq;

  final List<_FaqItem> _faqs = const [
    _FaqItem(
      q: 'How do I create a new Sales Order?',
      a: 'Go to Sales → Sales Orders → tap the "+" button in the bottom right. Fill in customer details, add products, and tap "Save" to create the order.',
    ),
    _FaqItem(
      q: 'How do I generate an invoice from a Sales Order?',
      a: 'Open the confirmed Sales Order, tap the menu (⋮) in the top-right corner, and select "Generate Invoice". The invoice will be created automatically with all order details.',
    ),
    _FaqItem(
      q: 'How do I record a payment received?',
      a: 'Navigate to the Invoice, tap "Record Payment", enter the amount received, payment date and mode. The invoice status will update to "Paid" automatically.',
    ),
    _FaqItem(
      q: 'How do I track delivery status?',
      a: 'Go to Sales → Deliveries. You can filter by status (Pending, In Transit, Delivered). Each delivery card shows real-time status and expected delivery date.',
    ),
    _FaqItem(
      q: 'How do I add a new customer?',
      a: 'Go to Contacts → Customers → tap "+". Enter customer name, GST number, billing address and contact details. The customer will be available immediately in all order forms.',
    ),
    _FaqItem(
      q: 'Can I export reports to Excel or PDF?',
      a: 'Yes! On any report page, tap the export icon (↑) in the top-right. Choose between Excel and PDF format. The file will be saved to your device downloads folder.',
    ),
    _FaqItem(
      q: 'How do I manage product stock levels?',
      a: 'Go to Inventory → Products. Each product shows current stock. Tap a product to view stock history, set reorder points, and manually adjust stock levels.',
    ),
    _FaqItem(
      q: 'How do I approve a Sales Return?',
      a: 'You will receive a notification for pending approvals. Go to Sales → Returns, open the return request, review the items, and tap "Approve" or "Reject" with remarks.',
    ),
  ];

  List<_FaqItem> get _filteredFaqs {
    if (_searchQuery.isEmpty) return _faqs;
    return _faqs
        .where((f) =>
    f.q.toLowerCase().contains(_searchQuery.toLowerCase()) ||
        f.a.toLowerCase().contains(_searchQuery.toLowerCase()))
        .toList();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final mq     = MediaQuery.of(context);
    final sw     = mq.size.width;
    final isWide = sw >= 600;

    final horizPad   = isWide ? sw * 0.06 : 16.0;
    final cardRadius = isWide ? 20.0 : 16.0;
    final headerH    = isWide ? 180.0 : 155.0;
    final sectionFs  = isWide ? 13.0 : 12.0;
    final titleFs    = isWide ? 15.0 : 14.0;
    final bodyFs     = isWide ? 13.0 : 12.0;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: AppTheme.statusBarTeal,
      child: Scaffold(
        backgroundColor: const Color(0xFFF5F7FA),
        body: CustomScrollView(
          slivers: [
            // ── Header ─────────────────────────────────────────────────────
            SliverAppBar(
              expandedHeight: headerH,
              pinned: true,
              backgroundColor: AppColors.primaryDark,
              surfaceTintColor: Colors.transparent,
              systemOverlayStyle: AppTheme.statusBarTeal,
              leading: IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.arrow_back_rounded,
                    color: Colors.white, size: 22),
              ),
              title: const Text(
                'Help & Support',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  fontFamily: 'Poppins',
                ),
              ),
              flexibleSpace: FlexibleSpaceBar(
                background: Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [AppColors.primaryDark, AppColors.primary],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child: SafeArea(
                    child: Padding(
                      padding: EdgeInsets.fromLTRB(
                          horizPad, isWide ? 72 : 60, horizPad, 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'How can we help you?',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: isWide ? 20 : 17,
                              fontWeight: FontWeight.w700,
                              fontFamily: 'Poppins',
                            ),
                          ),
                          SizedBox(height: isWide ? 10 : 8),
                          // Search bar
                          Container(
                            height: isWide ? 46 : 42,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: TextField(
                              controller: _searchController,
                              onChanged: (v) =>
                                  setState(() => _searchQuery = v),
                              style: TextStyle(
                                fontSize: bodyFs,
                                fontFamily: 'Poppins',
                                color: AppColors.textDark,
                              ),
                              decoration: InputDecoration(
                                hintText: 'Search help topics…',
                                hintStyle: TextStyle(
                                  color: AppColors.textMuted,
                                  fontSize: bodyFs,
                                  fontFamily: 'Poppins',
                                ),
                                prefixIcon: const Icon(Icons.search_rounded,
                                    color: AppColors.primary, size: 20),
                                suffixIcon: _searchQuery.isNotEmpty
                                    ? IconButton(
                                  icon: const Icon(Icons.close_rounded,
                                      color: AppColors.textMuted,
                                      size: 18),
                                  onPressed: () {
                                    _searchController.clear();
                                    setState(() => _searchQuery = '');
                                  },
                                )
                                    : null,
                                border: InputBorder.none,
                                contentPadding: const EdgeInsets.symmetric(
                                    vertical: 12),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),

            SliverPadding(
              padding: EdgeInsets.fromLTRB(
                  horizPad, isWide ? 20 : 16, horizPad, 32),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  // ── Quick Actions ────────────────────────────────────────
                  _SectionLabel(label: 'QUICK ACTIONS', fontSize: sectionFs),
                  SizedBox(height: isWide ? 10 : 8),
                  _QuickActions(
                      isWide: isWide, cardRadius: cardRadius),

                  SizedBox(height: isWide ? 24 : 18),

                  // ── Contact Support ──────────────────────────────────────
                  _SectionLabel(
                      label: 'CONTACT SUPPORT', fontSize: sectionFs),
                  SizedBox(height: isWide ? 10 : 8),
                  _ContactCard(
                      isWide: isWide,
                      cardRadius: cardRadius,
                      titleFs: titleFs,
                      bodyFs: bodyFs),

                  SizedBox(height: isWide ? 24 : 18),

                  // ── FAQ ──────────────────────────────────────────────────
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _SectionLabel(
                          label: 'FREQUENTLY ASKED', fontSize: sectionFs),
                      Text(
                        '${_filteredFaqs.length} topics',
                        style: TextStyle(
                          color: AppColors.textMuted,
                          fontSize: sectionFs,
                          fontFamily: 'Poppins',
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: isWide ? 10 : 8),

                  if (_filteredFaqs.isEmpty)
                    _EmptySearch(bodyFs: bodyFs)
                  else
                    ...List.generate(_filteredFaqs.length, (i) {
                      final faq = _filteredFaqs[i];
                      return _FaqTile(
                        faq: faq,
                        index: i,
                        isExpanded: _expandedFaq == i,
                        cardRadius: cardRadius,
                        titleFs: titleFs,
                        bodyFs: bodyFs,
                        onTap: () => setState(() =>
                        _expandedFaq = _expandedFaq == i ? null : i),
                        isLast: i == _filteredFaqs.length - 1,
                      );
                    }),

                  SizedBox(height: isWide ? 20 : 16),

                  // ── App Info ─────────────────────────────────────────────
                  _AppInfoCard(
                      isWide: isWide,
                      cardRadius: cardRadius,
                      bodyFs: bodyFs),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Quick Actions ────────────────────────────────────────────────────────────
class _QuickActions extends StatelessWidget {
  final bool isWide;
  final double cardRadius;
  const _QuickActions({required this.isWide, required this.cardRadius});

  static const _actions = [
    _QuickAction(Icons.chat_bubble_outline_rounded, 'Live Chat',
        AppColors.primary, AppColors.primarySurface),
    _QuickAction(Icons.mail_outline_rounded, 'Email Us',
        Color(0xFF0045BC), Color(0xFFE3F2FD)),
    _QuickAction(Icons.phone_outlined, 'Call Us',
        Color(0xFF66BB6A), Color(0xFFE8F5E9)),
    _QuickAction(Icons.video_call_outlined, 'Video Call',
        Color(0xFFAB47BC), Color(0xFFF3E5F5)),
  ];

  @override
  Widget build(BuildContext context) {
    return Row(
      children: _actions.map((a) {
        return Expanded(
          child: Padding(
            padding: const EdgeInsets.only(right: 8),
            child: Container(
              padding: EdgeInsets.symmetric(
                  vertical: isWide ? 16 : 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(cardRadius),
                border: Border.all(color: AppColors.divider),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.03),
                    blurRadius: 6, offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Container(
                    width: isWide ? 42 : 36,
                    height: isWide ? 42 : 36,
                    decoration: BoxDecoration(
                      color: a.bgColor,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(a.icon, color: a.color,
                        size: isWide ? 20 : 18),
                  ),
                  SizedBox(height: isWide ? 8 : 6),
                  Text(
                    a.label,
                    style: TextStyle(
                      color: AppColors.textDark,
                      fontSize: isWide ? 11 : 10,
                      fontWeight: FontWeight.w600,
                      fontFamily: 'Poppins',
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}

class _QuickAction {
  final IconData icon;
  final String label;
  final Color color;
  final Color bgColor;
  const _QuickAction(this.icon, this.label, this.color, this.bgColor);
}

// ─── Contact Card ─────────────────────────────────────────────────────────────
class _ContactCard extends StatelessWidget {
  final bool isWide;
  final double cardRadius;
  final double titleFs;
  final double bodyFs;
  const _ContactCard(
      {required this.isWide,
        required this.cardRadius,
        required this.titleFs,
        required this.bodyFs});

  @override
  Widget build(BuildContext context) {
    final items = [
      _ContactRow(Icons.support_agent_rounded, 'Support Hours',
          'Mon–Sat, 9 AM – 6 PM IST', AppColors.primary),
      _ContactRow(Icons.mail_outline_rounded, 'Email',
          'support@salemanagement.in', const Color(0xFF0045BC)),
      _ContactRow(Icons.phone_outlined, 'Phone',
          '+91 1800-123-4567 (Toll Free)', const Color(0xFF66BB6A)),
      _ContactRow(Icons.chat_rounded, 'WhatsApp',
          '+91 98765 00000', const Color(0xFF25D366)),
    ];

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(cardRadius),
        border: Border.all(color: AppColors.divider),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8, offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: List.generate(items.length, (i) {
          final item = items[i];
          return Column(
            children: [
              Padding(
                padding: EdgeInsets.symmetric(
                    horizontal: isWide ? 18 : 14,
                    vertical: isWide ? 14 : 12),
                child: Row(
                  children: [
                    Container(
                      width: isWide ? 40 : 34,
                      height: isWide ? 40 : 34,
                      decoration: BoxDecoration(
                        color: item.color.withOpacity(0.10),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(item.icon,
                          color: item.color, size: isWide ? 18 : 16),
                    ),
                    SizedBox(width: isWide ? 14 : 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.label,
                            style: TextStyle(
                              color: AppColors.textMuted,
                              fontSize: bodyFs - 1,
                              fontFamily: 'Poppins',
                            ),
                          ),
                          Text(
                            item.value,
                            style: TextStyle(
                              color: AppColors.textDark,
                              fontSize: bodyFs,
                              fontWeight: FontWeight.w600,
                              fontFamily: 'Poppins',
                            ),
                          ),
                        ],
                      ),
                    ),
                    Icon(Icons.chevron_right_rounded,
                        color: AppColors.textMuted, size: 18),
                  ],
                ),
              ),
              if (i < items.length - 1)
                const Divider(
                    height: 1, color: AppColors.divider,
                    indent: 16, endIndent: 16),
            ],
          );
        }),
      ),
    );
  }
}

class _ContactRow {
  final IconData icon;
  final String label;
  final String value;
  final Color color;
  const _ContactRow(this.icon, this.label, this.value, this.color);
}

// ─── FAQ Tile ─────────────────────────────────────────────────────────────────
class _FaqTile extends StatelessWidget {
  final _FaqItem faq;
  final int index;
  final bool isExpanded;
  final double cardRadius;
  final double titleFs;
  final double bodyFs;
  final VoidCallback onTap;
  final bool isLast;
  const _FaqTile(
      {required this.faq,
        required this.index,
        required this.isExpanded,
        required this.cardRadius,
        required this.titleFs,
        required this.bodyFs,
        required this.onTap,
        required this.isLast});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: isLast ? 0 : 8),
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeInOut,
          decoration: BoxDecoration(
            color: isExpanded
                ? AppColors.primarySurface
                : Colors.white,
            borderRadius: BorderRadius.circular(cardRadius),
            border: Border.all(
              color: isExpanded
                  ? AppColors.primary.withOpacity(0.25)
                  : AppColors.divider,
            ),
            boxShadow: [
              BoxShadow(
                color: isExpanded
                    ? AppColors.primary.withOpacity(0.06)
                    : Colors.black.withOpacity(0.03),
                blurRadius: 8, offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 24, height: 24,
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Center(
                        child: Text(
                          'Q',
                          style: TextStyle(
                            color: AppColors.primary,
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                            fontFamily: 'Poppins',
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        faq.q,
                        style: TextStyle(
                          color: AppColors.textDark,
                          fontSize: titleFs,
                          fontWeight: FontWeight.w600,
                          fontFamily: 'Poppins',
                        ),
                      ),
                    ),
                    AnimatedRotation(
                      turns: isExpanded ? 0.5 : 0,
                      duration: const Duration(milliseconds: 250),
                      child: const Icon(Icons.keyboard_arrow_down_rounded,
                          color: AppColors.primary, size: 20),
                    ),
                  ],
                ),
                if (isExpanded) ...[
                  const SizedBox(height: 10),
                  const Divider(height: 1, color: AppColors.divider),
                  const SizedBox(height: 10),
                  Text(
                    faq.a,
                    style: TextStyle(
                      color: AppColors.textLight,
                      fontSize: bodyFs,
                      fontFamily: 'Poppins',
                      height: 1.6,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _FaqItem {
  final String q;
  final String a;
  const _FaqItem({required this.q, required this.a});
}

// ─── App Info Card ────────────────────────────────────────────────────────────
class _AppInfoCard extends StatelessWidget {
  final bool isWide;
  final double cardRadius;
  final double bodyFs;
  const _AppInfoCard(
      {required this.isWide,
        required this.cardRadius,
        required this.bodyFs});

  @override
  Widget build(BuildContext context) => Container(
    padding: EdgeInsets.all(isWide ? 18 : 14),
    decoration: BoxDecoration(
      color: AppColors.primarySurface,
      borderRadius: BorderRadius.circular(cardRadius),
      border: Border.all(color: AppColors.primary.withOpacity(0.20)),
    ),
    child: Row(
      children: [
        Container(
          width: isWide ? 44 : 38,
          height: isWide ? 44 : 38,
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(Icons.info_outline_rounded,
              color: Colors.white, size: isWide ? 22 : 18),
        ),
        SizedBox(width: isWide ? 14 : 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Sale Management App',
                style: TextStyle(
                  color: AppColors.textDark,
                  fontSize: bodyFs,
                  fontWeight: FontWeight.w700,
                  fontFamily: 'Poppins',
                ),
              ),
              Text(
                'Version 2.4.1 · Build 241',
                style: TextStyle(
                  color: AppColors.textMuted,
                  fontSize: bodyFs - 1,
                  fontFamily: 'Poppins',
                ),
              ),
            ],
          ),
        ),
        Text(
          'Up to date',
          style: TextStyle(
            color: AppColors.primary,
            fontSize: bodyFs - 1,
            fontWeight: FontWeight.w600,
            fontFamily: 'Poppins',
          ),
        ),
      ],
    ),
  );
}

// ─── Section Label ────────────────────────────────────────────────────────────
class _SectionLabel extends StatelessWidget {
  final String label;
  final double fontSize;
  const _SectionLabel({required this.label, required this.fontSize});

  @override
  Widget build(BuildContext context) => Text(
    label,
    style: TextStyle(
      color: AppColors.textMuted,
      fontSize: fontSize,
      fontWeight: FontWeight.w600,
      letterSpacing: 0.6,
      fontFamily: 'Poppins',
    ),
  );
}

// ─── Empty Search ─────────────────────────────────────────────────────────────
class _EmptySearch extends StatelessWidget {
  final double bodyFs;
  const _EmptySearch({required this.bodyFs});

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 32),
    child: Center(
      child: Column(
        children: [
          const Icon(Icons.search_off_rounded,
              color: AppColors.textFaint, size: 48),
          const SizedBox(height: 12),
          Text(
            'No results found',
            style: TextStyle(
              color: AppColors.textLight,
              fontSize: bodyFs + 1,
              fontWeight: FontWeight.w600,
              fontFamily: 'Poppins',
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Try a different search term',
            style: TextStyle(
              color: AppColors.textMuted,
              fontSize: bodyFs,
              fontFamily: 'Poppins',
            ),
          ),
        ],
      ),
    ),
  );
}