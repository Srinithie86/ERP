// ════════════════════════════════════════════════════
//  banner_approval_screen.dart
// ════════════════════════════════════════════════════
import 'package:flutter/material.dart';
import '../Theme_Module/colors_and_models.dart';

// ═══════════════════════════════════════════
//  MODEL
// ═══════════════════════════════════════════
class BannerApproval {
  final int    id;
  final String bannerName;
  final String bannerImage;
  final String position;
  final int    displayOrder;
  final String mainText;
  final String subText;
  final String buttonText;
  final String buttonLink;
  final String startDate;
  final String endDate;
  final String updatedDate;
  final String submittedBy;
  final String submittedDate;
  String       status;
  String       rejectionReason;

  BannerApproval({
    required this.id,
    required this.bannerName,
    required this.bannerImage,
    required this.position,
    required this.displayOrder,
    required this.mainText,
    required this.subText,
    required this.buttonText,
    required this.buttonLink,
    required this.startDate,
    required this.endDate,
    required this.updatedDate,
    required this.submittedBy,
    required this.submittedDate,
    this.status          = 'Pending',
    this.rejectionReason = '',
  });
}

// ═══════════════════════════════════════════
//  SCREEN
// ═══════════════════════════════════════════
class BannerApprovalScreen extends StatefulWidget {
  const BannerApprovalScreen({super.key});
  @override
  State<BannerApprovalScreen> createState() => _BannerApprovalScreenState();
}

class _BannerApprovalScreenState extends State<BannerApprovalScreen> {
  String _filter = 'All';
  String _search = '';

  final List<BannerApproval> _banners = [
    BannerApproval(
      id: 80101, bannerName: 'Summer Sale Banner',
      bannerImage: 'assets/banner/summer_sale.jpg',
      position: 'Top', displayOrder: 1,
      mainText: 'Big Summer Sale', subText: 'Up to 50% off on all items',
      buttonText: 'Shop Now', buttonLink: 'https://shop.example.com/summer',
      startDate: '01-06-2025', endDate: '30-06-2025', updatedDate: '10-06-2025',
      submittedBy: 'Ravi Kumar', submittedDate: '10-06-2025', status: 'Pending',
    ),
    BannerApproval(
      id: 80102, bannerName: 'Flash Deal Banner',
      bannerImage: 'assets/banner/flash_sale.jpg',
      position: 'Middle', displayOrder: 2,
      mainText: 'Flash Deals Today', subText: 'Limited time offers, grab fast!',
      buttonText: 'View Deals', buttonLink: 'https://shop.example.com/flash',
      startDate: '09-06-2025', endDate: '09-06-2025', updatedDate: '09-06-2025',
      submittedBy: 'Priya Sharma', submittedDate: '09-06-2025', status: 'Pending',
    ),
    BannerApproval(
      id: 80103, bannerName: 'New Arrivals',
      bannerImage: 'assets/banner/new_arrivals.jpg',
      position: 'Bottom', displayOrder: 3,
      mainText: 'New Arrivals Are Here', subText: 'Check out the latest collection',
      buttonText: 'Explore', buttonLink: 'https://shop.example.com/new',
      startDate: '01-06-2025', endDate: '15-06-2025', updatedDate: '08-06-2025',
      submittedBy: 'Arun Selvan', submittedDate: '08-06-2025', status: 'Approved',
    ),
    BannerApproval(
      id: 80104, bannerName: 'Weekend Offer',
      bannerImage: 'assets/banner/weekend_offer.jpg',
      position: 'Top', displayOrder: 4,
      mainText: 'Weekend Special', subText: 'Exclusive deals every weekend',
      buttonText: 'Get Offer', buttonLink: 'https://shop.example.com/weekend',
      startDate: '07-06-2025', endDate: '08-06-2025', updatedDate: '07-06-2025',
      submittedBy: 'Meena Devi', submittedDate: '07-06-2025',
      status: 'Rejected', rejectionReason: 'Image resolution too low',
    ),
    BannerApproval(
      id: 80105, bannerName: 'Festival Special',
      bannerImage: 'assets/banner/festival_offer.png',
      position: 'Middle', displayOrder: 5,
      mainText: 'Festival Bonanza', subText: 'Celebrate with amazing discounts',
      buttonText: 'Shop Festival', buttonLink: 'https://shop.example.com/festival',
      startDate: '06-06-2025', endDate: '20-06-2025', updatedDate: '06-06-2025',
      submittedBy: 'Karthik Raja', submittedDate: '06-06-2025', status: 'Pending',
    ),
  ];

  // ── Color helpers ──
  Color _statusColor(String s) {
    switch (s) {
      case 'Approved': return C.green;
      case 'Rejected': return C.red;
      default:         return C.orange;
    }
  }

  Color _statusBg(String s) {
    switch (s) {
      case 'Approved': return C.greenLight;
      case 'Rejected': return C.redLight;
      default:         return C.orangeLight;
    }
  }

  IconData _statusIcon(String s) {
    switch (s) {
      case 'Approved': return Icons.check_circle_rounded;
      case 'Rejected': return Icons.cancel_rounded;
      default:         return Icons.pending_rounded;
    }
  }

  int get _pending  => _banners.where((b) => b.status == 'Pending').length;
  int get _approved => _banners.where((b) => b.status == 'Approved').length;
  int get _rejected => _banners.where((b) => b.status == 'Rejected').length;

  void _approve(BannerApproval b) {
    setState(() => b.status = 'Approved');
    _showSnack('✓  "${b.bannerName}" Approved', C.green);
  }

  void _rejectDialog(BannerApproval b) {
    final ctrl = TextEditingController();
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: const Text('Reject Banner',
            style: TextStyle(fontWeight: FontWeight.w800, color: C.textDark)),
        content: Column(mainAxisSize: MainAxisSize.min, children: [
          Text('Rejecting: "${b.bannerName}"',
              style: const TextStyle(fontSize: 13, color: C.textMid)),
          const SizedBox(height: 14),
          TextField(
            controller: ctrl,
            maxLines: 3,
            decoration: InputDecoration(
              hintText: 'Enter rejection reason…',
              hintStyle: const TextStyle(color: C.textLight, fontSize: 13),
              filled: true, fillColor: C.bg,
              contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(color: Colors.grey.shade200)),
              enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(color: Colors.grey.shade200)),
              focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: C.red, width: 1.5)),
            ),
          ),
        ]),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(color: C.textMid)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() {
                b.status          = 'Rejected';
                b.rejectionReason = ctrl.text.trim().isEmpty
                    ? 'No reason provided' : ctrl.text.trim();
              });
              _showSnack('✗  "${b.bannerName}" Rejected', C.red);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: C.red, foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text('Reject', style: TextStyle(fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }

  void _resetPending(BannerApproval b) {
    setState(() { b.status = 'Pending'; b.rejectionReason = ''; });
    _showSnack('↺  "${b.bannerName}" reset to Pending', C.orange);
  }

  void _showSnack(String msg, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg, style: const TextStyle(fontWeight: FontWeight.w600)),
      backgroundColor: color,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      duration: const Duration(seconds: 2),
    ));
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _banners.where((b) {
      final matchFilter = _filter == 'All' || b.status == _filter;
      final matchSearch = _search.isEmpty ||
          b.bannerName.toLowerCase().contains(_search.toLowerCase()) ||
          b.submittedBy.toLowerCase().contains(_search.toLowerCase());
      return matchFilter && matchSearch;
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
            const SecTitle('Banner Approval'),
            const SizedBox(height: 14),

            // Stats row
            Row(children: [
              Expanded(child: _StatMini('${_banners.length}', 'Total',   C.primaryLight, C.primary)),
              const SizedBox(width: 10),
              Expanded(child: _StatMini('$_pending',  'Pending',  C.orangeLight,  C.orange)),
              const SizedBox(width: 10),
              Expanded(child: _StatMini('$_approved', 'Approved', C.greenLight,   C.green)),
              const SizedBox(width: 10),
              Expanded(child: _StatMini('$_rejected', 'Rejected', C.redLight,     C.red)),
            ]),
            const SizedBox(height: 14),

            // Search
            Container(
              decoration: kCard(r: 10),
              child: TextField(
                onChanged: (v) => setState(() => _search = v),
                decoration: const InputDecoration(
                  hintText: 'Search banner or submitter…',
                  hintStyle: TextStyle(color: C.textLight, fontSize: 13),
                  prefixIcon: Icon(Icons.search_rounded, color: C.textLight, size: 18),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
            const SizedBox(height: 12),

            // Filter chips
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: ['All', 'Pending', 'Approved', 'Rejected'].map((f) {
                  final sel = _filter == f;
                  return GestureDetector(
                    onTap: () => setState(() => _filter = f),
                    child: Container(
                      margin: const EdgeInsets.only(right: 8),
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                      decoration: BoxDecoration(
                        color: sel ? C.primary : C.bg,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: sel ? C.primary : Colors.grey.shade300),
                      ),
                      child: Text(f,
                          style: TextStyle(
                              fontSize: 12, fontWeight: FontWeight.w600,
                              color: sel ? Colors.white : C.textMid)),
                    ),
                  );
                }).toList(),
              ),
            ),
          ]),
        ),

        const Divider(height: 1),

        // ── Banner List ──
        Expanded(
          child: filtered.isEmpty
              ? Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
            Container(
              width: 72, height: 72,
              decoration: BoxDecoration(color: C.bg, borderRadius: BorderRadius.circular(24)),
              child: const Icon(Icons.image_not_supported_rounded, size: 36, color: C.textLight),
            ),
            const SizedBox(height: 14),
            const Text('No banners found',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: C.textDark)),
          ]))
              : ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: filtered.length,
            itemBuilder: (_, i) => _BannerCard(
              banner:      filtered[i],
              onApprove:   () => _approve(filtered[i]),
              onReject:    () => _rejectDialog(filtered[i]),
              onReset:     () => _resetPending(filtered[i]),
              statusColor: _statusColor(filtered[i].status),
              statusBg:    _statusBg(filtered[i].status),
              statusIcon:  _statusIcon(filtered[i].status),
              onViewDetail: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => BannerDetailScreen(
                      banner: filtered[i],
                      onApprove:   () { _approve(filtered[i]);    setState(() {}); },
                      onReject:    () { _rejectDialog(filtered[i]); },
                      onReset:     () { _resetPending(filtered[i]); setState(() {}); },
                      statusColor: _statusColor(filtered[i].status),
                      statusBg:    _statusBg(filtered[i].status),
                      statusIcon:  _statusIcon(filtered[i].status),
                    ),
                  ),
                );
                setState(() {});
              },
            ),
          ),
        ),
      ]),
    );
  }
}

// ═══════════════════════════════════════════
//  BANNER CARD
// ═══════════════════════════════════════════
class _BannerCard extends StatelessWidget {
  final BannerApproval banner;
  final VoidCallback   onApprove, onReject, onReset, onViewDetail;
  final Color          statusColor, statusBg;
  final IconData       statusIcon;

  const _BannerCard({
    required this.banner,
    required this.onApprove,
    required this.onReject,
    required this.onReset,
    required this.onViewDetail,
    required this.statusColor,
    required this.statusBg,
    required this.statusIcon,
  });

  @override
  Widget build(BuildContext context) => Container(
    margin: const EdgeInsets.only(bottom: 14),
    decoration: kCard(),
    padding: const EdgeInsets.all(14),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

      // ── Top row ──
      Row(children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Image.asset(
            banner.bannerImage,
            width: 52, height: 52, fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => Container(
              width: 52, height: 52,
              decoration: BoxDecoration(
                  color: C.primaryLight, borderRadius: BorderRadius.circular(12)),
              child: const Icon(Icons.image_rounded, color: C.primary, size: 26),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(banner.bannerName,
                style: const TextStyle(
                    fontSize: 14, fontWeight: FontWeight.w700, color: C.textDark)),
            const SizedBox(height: 3),
            Text('#${banner.id}  •  ${banner.position}  •  Order: ${banner.displayOrder}',
                style: const TextStyle(fontSize: 11, color: C.textMid)),
          ]),
        ),
        const SizedBox(width: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(color: statusBg, borderRadius: BorderRadius.circular(20)),
          child: Row(mainAxisSize: MainAxisSize.min, children: [
            Icon(statusIcon, size: 12, color: statusColor),
            const SizedBox(width: 4),
            Text(banner.status,
                style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: statusColor)),
          ]),
        ),
      ]),

      const SizedBox(height: 12),
      const Divider(height: 1),
      const SizedBox(height: 10),

      // ── Info chips ──
      Row(children: [
        Expanded(child: _InfoChip(Icons.person_rounded,         banner.submittedBy)),
        Expanded(child: _InfoChip(Icons.calendar_today_rounded, banner.submittedDate)),
        Expanded(child: _InfoChip(Icons.image_outlined,         banner.bannerImage.split('/').last)),
      ]),

      // ── Rejection reason ──
      if (banner.status == 'Rejected' && banner.rejectionReason.isNotEmpty) ...[
        const SizedBox(height: 10),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(color: C.redLight, borderRadius: BorderRadius.circular(10)),
          child: Row(children: [
            const Icon(Icons.info_outline_rounded, size: 14, color: C.red),
            const SizedBox(width: 6),
            Expanded(
              child: Text('Reason: ${banner.rejectionReason}',
                  style: const TextStyle(fontSize: 12, color: C.red, fontWeight: FontWeight.w500)),
            ),
          ]),
        ),
      ],

      const SizedBox(height: 12),

      // ── Buttons row ──
      Row(children: [
        // View Detail button always visible
        GestureDetector(
          onTap: onViewDetail,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
            decoration: BoxDecoration(
              color: C.primaryLight,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(mainAxisSize: MainAxisSize.min, children: [
              Icon(Icons.visibility_rounded, size: 14, color: C.primary),
              const SizedBox(width: 5),
              Text('View Detail',
                  style: TextStyle(
                      fontSize: 12, fontWeight: FontWeight.w700, color: C.primary)),
            ]),
          ),
        ),
        const SizedBox(width: 8),

        // Status action buttons
        if (banner.status == 'Pending') ...[
          Expanded(
            child: GestureDetector(
              onTap: onApprove,
              child: Row(mainAxisAlignment: MainAxisAlignment.center, children: const [
                Icon(Icons.check_circle_rounded, size: 14, color: C.green),
                SizedBox(width: 4),
                Flexible(child: Text('Approve', overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: C.green))),
              ]),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: GestureDetector(
              onTap: onReject,
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 9),
                decoration: BoxDecoration(color: C.redLight, borderRadius: BorderRadius.circular(10)),
                child: Row(mainAxisAlignment: MainAxisAlignment.center, children: const [
                  Icon(Icons.cancel_rounded, size: 14, color: C.red),
                  SizedBox(width: 4),
                  Flexible(child: Text('Reject', overflow: TextOverflow.ellipsis,
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: C.red))),
                ]),
              ),
            ),
          ),
        ] else if (banner.status == 'Approved') ...[
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 9),
              decoration: BoxDecoration(color: C.greenLight, borderRadius: BorderRadius.circular(10)),
              child: Row(mainAxisAlignment: MainAxisAlignment.center, children: const [
                Icon(Icons.check_circle_rounded, size: 14, color: C.green),
                SizedBox(width: 4),
                Flexible(child: Text('Approved', overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: C.green))),
              ]),
            ),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: onReset,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
              decoration: BoxDecoration(
                  color: C.bg, borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.grey.shade300)),
              child: const Row(children: [
                Icon(Icons.refresh_rounded, size: 14, color: C.textMid),
                SizedBox(width: 4),
                Text('Reset', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: C.textMid)),
              ]),
            ),
          ),
        ] else if (banner.status == 'Rejected') ...[
          Expanded(
            child: GestureDetector(
              onTap: onApprove,
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 9),
                decoration: BoxDecoration(color: C.greenLight, borderRadius: BorderRadius.circular(10)),
                child: Row(mainAxisAlignment: MainAxisAlignment.center, children: const [
                  Icon(Icons.check_circle_rounded, size: 14, color: C.green),
                  SizedBox(width: 5),
                  Text('Approve', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: C.green)),
                ]),
              ),
            ),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: onReset,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
              decoration: BoxDecoration(
                  color: C.bg, borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.grey.shade300)),
              child: const Row(children: [
                Icon(Icons.refresh_rounded, size: 14, color: C.textMid),
                SizedBox(width: 4),
                Text('Reset', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: C.textMid)),
              ]),
            ),
          ),
        ],
      ]),
    ]),
  );
}

// ═══════════════════════════════════════════
//  BANNER DETAIL SCREEN
// ═══════════════════════════════════════════
class BannerDetailScreen extends StatefulWidget {
  final BannerApproval banner;
  final VoidCallback   onApprove, onReject, onReset;
  final Color          statusColor, statusBg;
  final IconData       statusIcon;

  const BannerDetailScreen({
    super.key,
    required this.banner,
    required this.onApprove,
    required this.onReject,
    required this.onReset,
    required this.statusColor,
    required this.statusBg,
    required this.statusIcon,
  });

  @override
  State<BannerDetailScreen> createState() => _BannerDetailScreenState();
}

class _BannerDetailScreenState extends State<BannerDetailScreen> {
  BannerApproval get b => widget.banner;

  Color _statusColor(String s) {
    switch (s) {
      case 'Approved': return C.green;
      case 'Rejected': return C.red;
      default:         return C.orange;
    }
  }

  Color _statusBg(String s) {
    switch (s) {
      case 'Approved': return C.greenLight;
      case 'Rejected': return C.redLight;
      default:         return C.orangeLight;
    }
  }

  IconData _statusIcon(String s) {
    switch (s) {
      case 'Approved': return Icons.check_circle_rounded;
      case 'Rejected': return Icons.cancel_rounded;
      default:         return Icons.pending_rounded;
    }
  }

  void _approve() {
    setState(() => b.status = 'Approved');
    widget.onApprove();
    _showSnack('✓  "${b.bannerName}" Approved', C.green);
  }

  void _reject() {
    final ctrl = TextEditingController(text: b.rejectionReason);
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: const Text('Reject Banner',
            style: TextStyle(fontWeight: FontWeight.w800, color: C.textDark)),
        content: Column(mainAxisSize: MainAxisSize.min, children: [
          Text('Rejecting: "${b.bannerName}"',
              style: const TextStyle(fontSize: 13, color: C.textMid)),
          const SizedBox(height: 14),
          TextField(
            controller: ctrl, maxLines: 3,
            decoration: InputDecoration(
              hintText: 'Enter rejection reason…',
              hintStyle: const TextStyle(color: C.textLight, fontSize: 13),
              filled: true, fillColor: C.bg,
              contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(color: Colors.grey.shade200)),
              enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(color: Colors.grey.shade200)),
              focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: C.red, width: 1.5)),
            ),
          ),
        ]),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(color: C.textMid)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() {
                b.status          = 'Rejected';
                b.rejectionReason = ctrl.text.trim().isEmpty
                    ? 'No reason provided' : ctrl.text.trim();
              });
              widget.onReject();
              _showSnack('✗  "${b.bannerName}" Rejected', C.red);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: C.red, foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text('Reject', style: TextStyle(fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }

  void _reset() {
    setState(() { b.status = 'Pending'; b.rejectionReason = ''; });
    widget.onReset();
    _showSnack('↺  "${b.bannerName}" reset to Pending', C.orange);
  }

  void _showSnack(String msg, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg, style: const TextStyle(fontWeight: FontWeight.w600)),
      backgroundColor: color,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      duration: const Duration(seconds: 2),
    ));
  }

  @override
  Widget build(BuildContext context) {
    final sc = _statusColor(b.status);
    final sb = _statusBg(b.status);
    final si = _statusIcon(b.status);

    return Scaffold(
      backgroundColor: C.bg,
      body: CustomScrollView(
        slivers: [

          // ── SliverAppBar with banner image ──
          SliverAppBar(
            expandedHeight: 220,
            pinned: true,
            backgroundColor: C.primary,
            leading: GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                margin: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(10)),
                child: const Icon(Icons.arrow_back_ios_new_rounded,
                    color: Colors.white, size: 18),
              ),
            ),
            flexibleSpace: FlexibleSpaceBar(
              collapseMode: CollapseMode.pin,
              background: Stack(
                fit: StackFit.expand,
                children: [
                  Image.asset(
                    b.bannerImage, fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      color: C.primaryLight,
                      child: const Center(
                        child: Icon(Icons.image_rounded, color: C.primary, size: 64),
                      ),
                    ),
                  ),
                  // Gradient overlay
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withValues(alpha: 0.65),
                        ],
                      ),
                    ),
                  ),
                  // Title overlay
                  Positioned(
                    left: 16, right: 16, bottom: 16,
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text(b.bannerName,
                          style: const TextStyle(
                              fontSize: 18, fontWeight: FontWeight.w800, color: Colors.white)),
                      const SizedBox(height: 6),
                      Row(children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(20)),
                          child: Text('#${b.id}  •  ${b.position}',
                              style: const TextStyle(
                                  fontSize: 11, fontWeight: FontWeight.w600, color: Colors.white)),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                              color: sb, borderRadius: BorderRadius.circular(20)),
                          child: Row(mainAxisSize: MainAxisSize.min, children: [
                            Icon(si, size: 11, color: sc),
                            const SizedBox(width: 4),
                            Text(b.status,
                                style: TextStyle(
                                    fontSize: 10, fontWeight: FontWeight.w700, color: sc)),
                          ]),
                        ),
                      ]),
                    ]),
                  ),
                ],
              ),
            ),
          ),

          // ── Body ──
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

                // ══ BANNER INFO SECTION ══
                _SectionHeader('Banner Information', Icons.info_rounded),
                const SizedBox(height: 10),

                // Row 1: Banner Name + Position
                Row(children: [
                  Expanded(child: _DetailTile(
                      icon: Icons.image_rounded, label: 'Banner Name', value: b.bannerName)),
                  const SizedBox(width: 10),
                  Expanded(child: _DetailTile(
                      icon: Icons.place_rounded, label: 'Position', value: b.position)),
                ]),
                const SizedBox(height: 10),

                // Row 2: Display Order + Status
                Row(children: [
                  Expanded(child: _DetailTile(
                      icon: Icons.format_list_numbered_rounded,
                      label: 'Display Order', value: '${b.displayOrder}')),
                  const SizedBox(width: 10),
                  Expanded(child: _DetailTileStatus(
                      label: 'Status', value: b.status, color: sc, bg: sb, icon: si)),
                ]),
                const SizedBox(height: 10),

                // Banner Image path
                _DetailTileFull(
                    icon: Icons.photo_library_rounded,
                    label: 'Banner Image', value: b.bannerImage),
                const SizedBox(height: 20),

                // ══ CONTENT SECTION ══
                _SectionHeader('Content Details', Icons.text_fields_rounded),
                const SizedBox(height: 10),

                _DetailTileFull(
                    icon: Icons.title_rounded, label: 'Main Text', value: b.mainText),
                const SizedBox(height: 10),
                _DetailTileFull(
                    icon: Icons.subtitles_rounded, label: 'Sub Text', value: b.subText),
                const SizedBox(height: 10),

                Row(children: [
                  Expanded(child: _DetailTile(
                      icon: Icons.smart_button_rounded, label: 'Button Text', value: b.buttonText)),
                  const SizedBox(width: 10),
                  Expanded(child: _DetailTile(
                      icon: Icons.link_rounded, label: 'Button Link', value: b.buttonLink)),
                ]),
                const SizedBox(height: 20),

                // ══ DATE SECTION ══
                _SectionHeader('Schedule & Activity', Icons.schedule_rounded),
                const SizedBox(height: 10),

                Row(children: [
                  Expanded(child: _DetailTile(
                      icon: Icons.play_circle_rounded, label: 'Start Date', value: b.startDate)),
                  const SizedBox(width: 10),
                  Expanded(child: _DetailTile(
                      icon: Icons.stop_circle_rounded, label: 'End Date', value: b.endDate)),
                ]),
                const SizedBox(height: 10),

                Row(children: [
                  Expanded(child: _DetailTile(
                      icon: Icons.update_rounded, label: 'Updated Date', value: b.updatedDate)),
                  const SizedBox(width: 10),
                  Expanded(child: _DetailTile(
                      icon: Icons.calendar_today_rounded,
                      label: 'Submitted Date', value: b.submittedDate)),
                ]),
                const SizedBox(height: 10),

                _DetailTileFull(
                    icon: Icons.person_rounded, label: 'Submitted By', value: b.submittedBy),
                const SizedBox(height: 20),

                // ══ REJECTION REASON (if any) ══
                if (b.status == 'Rejected' && b.rejectionReason.isNotEmpty) ...[
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                        color: C.redLight, borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: C.red.withValues(alpha: 0.3))),
                    child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      const Icon(Icons.info_outline_rounded, size: 16, color: C.red),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          const Text('Rejection Reason',
                              style: TextStyle(
                                  fontSize: 11, fontWeight: FontWeight.w700, color: C.red)),
                          const SizedBox(height: 4),
                          Text(b.rejectionReason,
                              style: const TextStyle(
                                  fontSize: 13, color: C.red, fontWeight: FontWeight.w500)),
                        ]),
                      ),
                    ]),
                  ),
                  const SizedBox(height: 20),
                ],

                // ══ ACTION BUTTONS ══
                const Text('Banner Action',
                    style: TextStyle(
                        fontSize: 11, fontWeight: FontWeight.w700,
                        color: C.textMid, letterSpacing: 0.4)),
                const SizedBox(height: 10),

                Row(children: [
                  if (b.status != 'Approved')
                    Expanded(
                      child: GestureDetector(
                        onTap: _approve,
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 180),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          decoration: BoxDecoration(
                            color: b.status == 'Approved' ? C.green : C.greenLight,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: b.status == 'Approved' ? C.green : C.green.withValues(alpha: 0.4),
                            ),
                          ),
                          child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                            Icon(Icons.check_circle_outline_rounded, size: 18,
                                color: b.status == 'Approved' ? Colors.white : C.green),
                            const SizedBox(width: 6),
                            Text('Approve',
                                style: TextStyle(
                                    fontSize: 14, fontWeight: FontWeight.w700,
                                    color: b.status == 'Approved' ? Colors.white : C.green)),
                          ]),
                        ),
                      ),
                    ),
                  if (b.status != 'Approved') const SizedBox(width: 12),
                  if (b.status != 'Rejected')
                    Expanded(
                      child: GestureDetector(
                        onTap: _reject,
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 180),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          decoration: BoxDecoration(
                            color: b.status == 'Rejected' ? C.red : C.redLight,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: b.status == 'Rejected' ? C.red : C.red.withValues(alpha: 0.4),
                            ),
                          ),
                          child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                            Icon(Icons.cancel_outlined, size: 18,
                                color: b.status == 'Rejected' ? Colors.white : C.red),
                            const SizedBox(width: 6),
                            Text('Reject',
                                style: TextStyle(
                                    fontSize: 14, fontWeight: FontWeight.w700,
                                    color: b.status == 'Rejected' ? Colors.white : C.red)),
                          ]),
                        ),
                      ),
                    ),
                  if (b.status != 'Pending') ...[
                    const SizedBox(width: 12),
                    GestureDetector(
                      onTap: _reset,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                        decoration: BoxDecoration(
                          color: C.bg, borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: Colors.grey.shade300),
                        ),
                        child: const Row(children: [
                          Icon(Icons.refresh_rounded, size: 16, color: C.textMid),
                          SizedBox(width: 6),
                          Text('Reset',
                              style: TextStyle(
                                  fontSize: 13, fontWeight: FontWeight.w700, color: C.textMid)),
                        ]),
                      ),
                    ),
                  ],
                ]),
                const SizedBox(height: 30),
              ]),
            ),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════
//  DETAIL SCREEN HELPER WIDGETS
// ═══════════════════════════════════════════

class _SectionHeader extends StatelessWidget {
  final String title;
  final IconData icon;
  const _SectionHeader(this.title, this.icon);

  @override
  Widget build(BuildContext context) => Row(children: [
    Container(
      width: 30, height: 30,
      decoration: BoxDecoration(color: C.primaryLight, borderRadius: BorderRadius.circular(8)),
      child: Icon(icon, size: 15, color: C.primary),
    ),
    const SizedBox(width: 8),
    Text(title,
        style: const TextStyle(
            fontSize: 13, fontWeight: FontWeight.w800, color: C.textDark)),
  ]);
}

class _DetailTile extends StatelessWidget {
  final IconData icon;
  final String   label, value;
  const _DetailTile({required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(
        color: Colors.white, borderRadius: BorderRadius.circular(13),
        border: Border.all(color: C.border)),
    child: Row(children: [
      Container(
        width: 30, height: 30,
        decoration: BoxDecoration(color: C.primaryLight, borderRadius: BorderRadius.circular(8)),
        child: Icon(icon, size: 14, color: C.primary),
      ),
      const SizedBox(width: 8),
      Expanded(
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(label, style: const TextStyle(fontSize: 10, color: C.textLight)),
          const SizedBox(height: 2),
          Text(value,
              maxLines: 1, overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                  fontSize: 12, fontWeight: FontWeight.w700, color: C.textDark)),
        ]),
      ),
    ]),
  );
}

class _DetailTileFull extends StatelessWidget {
  final IconData icon;
  final String   label, value;
  const _DetailTileFull({required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity,
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(
        color: Colors.white, borderRadius: BorderRadius.circular(13),
        border: Border.all(color: C.border)),
    child: Row(children: [
      Container(
        width: 30, height: 30,
        decoration: BoxDecoration(color: C.primaryLight, borderRadius: BorderRadius.circular(8)),
        child: Icon(icon, size: 14, color: C.primary),
      ),
      const SizedBox(width: 10),
      Expanded(
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(label, style: const TextStyle(fontSize: 10, color: C.textLight)),
          const SizedBox(height: 3),
          Text(value,
              style: const TextStyle(
                  fontSize: 13, fontWeight: FontWeight.w600, color: C.textDark)),
        ]),
      ),
    ]),
  );
}

class _DetailTileStatus extends StatelessWidget {
  final String   label, value;
  final Color    color, bg;
  final IconData icon;
  const _DetailTileStatus({
    required this.label, required this.value,
    required this.color, required this.bg, required this.icon,
  });

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(
        color: Colors.white, borderRadius: BorderRadius.circular(13),
        border: Border.all(color: C.border)),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(label, style: const TextStyle(fontSize: 10, color: C.textLight)),
      const SizedBox(height: 6),
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(20)),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 5),
          Text(value,
              style: TextStyle(
                  fontSize: 11, fontWeight: FontWeight.w700, color: color)),
        ]),
      ),
    ]),
  );
}

// ── Small info chip ──
class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String   label;
  const _InfoChip(this.icon, this.label);

  @override
  Widget build(BuildContext context) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      Icon(icon, size: 12, color: C.textLight),
      const SizedBox(width: 4),
      Flexible(
        child: Text(label,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 11, color: C.textMid)),
      ),
    ],
  );
}

// ── Stat mini card ──
class _StatMini extends StatelessWidget {
  final String v, l;
  final Color  bg, fg;
  const _StatMini(this.v, this.l, this.bg, this.fg);

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(12)),
    child: Column(children: [
      Text(v, style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: fg)),
      const SizedBox(height: 2),
      Text(l, style: const TextStyle(fontSize: 10, color: C.textMid)),
    ]),
  );
}