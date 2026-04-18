import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cached_network_image/cached_network_image.dart';

enum DiscountView { viewList, viewDetails }

class DiscountSchemesScreen extends StatefulWidget {
  const DiscountSchemesScreen({super.key});

  @override
  State<DiscountSchemesScreen> createState() => _DiscountSchemesScreenState();
}

class _DiscountSchemesScreenState extends State<DiscountSchemesScreen> {
  DiscountView _currentView = DiscountView.viewList;
  Map<String, dynamic>? _selectedCoupon;
  final Color primaryColor = const Color(0xFF26A69A);
  final Color darkBlue = const Color(0xFF1E234E);

  final List<Map<String, dynamic>> _coupons = [
    {
      'id': 'CUP-001',
      'discount': '32%',
      'title': '32% DISCOUNT',
      'sub': 'At selected outlets.\nTerms and conditions apply',
      'colors': [const Color(0xFFCE93D8), const Color(0xFF90CAF9)],
      'barcode': '1234567890',
      'image': 'https://images.pexels.com/photos/1972115/pexels-photo-1972115.jpeg',
    },
    {
      'id': 'CUP-002',
      'discount': '12%',
      'title': '12% DISCOUNT',
      'sub': 'At Ceylon and Spa.\nTerms and conditions apply',
      'colors': [const Color(0xFFFFCC80), const Color(0xFFEF9A9A)],
      'barcode': '9876543210',
      'image': 'https://images.pexels.com/photos/985635/pexels-photo-985635.jpeg',
    },
    {
      'id': 'CUP-003',
      'discount': '25%',
      'title': '25% DISCOUNT',
      'sub': 'At selected outlets.\nTerms and conditions apply',
      'colors': [const Color(0xFF90CAF9), const Color(0xFFA5D6A7)],
      'barcode': '1122334455',
      'image': 'https://images.pexels.com/photos/23570884/pexels-photo-23570884.jpeg',
    },
    {
      'id': 'CUP-004',
      'discount': '7%',
      'title': '7% DISCOUNT',
      'sub': 'At selected outlets.\nTerms and conditions apply',
      'colors': [const Color(0xFFA5D6A7), const Color(0xFFE6EE9C)],
      'barcode': '5566778899',
      'image': 'https://images.pexels.com/photos/1043474/pexels-photo-1043474.jpeg',
    },
  ];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    for (var coupon in _coupons) {
      precacheImage(CachedNetworkImageProvider(coupon['image']), context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: _currentView == DiscountView.viewList ? _buildListView() : _buildDetailView(),
    );
  }

  Widget _buildListView() {
    return SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Text(
              'Redeem your coupons',
              style: GoogleFonts.outfit(fontSize: 22, fontWeight: FontWeight.bold, color: darkBlue),
            ),
          ),
          const SizedBox(height: 24),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              itemCount: _coupons.length,
              itemBuilder: (context, index) {
                final coupon = _coupons[index];
                return _buildCouponCard(coupon);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.arrow_back, color: Colors.black),
          ),
          CircleAvatar(
            radius: 20,
            backgroundImage: NetworkImage('https://i.pravatar.cc/150?u=arun'),
          ),
        ],
      ),
    );
  }

  Widget _buildCouponCard(Map<String, dynamic> coupon) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      height: 140,
      child: Stack(
        children: [
          // Background Gradient Card
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: coupon['colors']),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [BoxShadow(color: (coupon['colors'] as List)[0].withValues(alpha: 0.3), blurRadius: 10, offset: const Offset(0, 5))],
            ),
          ),
          // Coupon Design Elements (The curved cutouts)
          Positioned(
            left: -15,
            top: 55,
            child: Container(width: 30, height: 30, decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle)),
          ),
          Positioned(
            right: -15,
            top: 55,
            child: Container(width: 30, height: 30, decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle)),
          ),
          // Content
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                RotatedBox(
                  quarterTurns: 3,
                  child: Text('DISCOUNT', style: GoogleFonts.outfit(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 2)),
                ),
                VerticalDivider(color: Colors.white.withValues(alpha: 0.3), indent: 20, endIndent: 20, width: 32),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(coupon['discount'], style: GoogleFonts.outfit(fontSize: 36, fontWeight: FontWeight.bold, color: Colors.white)),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(coupon['sub'], style: GoogleFonts.outfit(fontSize: 10, color: Colors.white.withValues(alpha: 0.9))),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          _buildFakeBarcode(Colors.white),
                          const Spacer(),
                          TextButton(
                            onPressed: () => setState(() {
                              _selectedCoupon = coupon;
                              _currentView = DiscountView.viewDetails;
                            }),
                            child: Text('VIEW', style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
                          ),
                          TextButton(
                            onPressed: () {},
                            child: Text('REDEEM', style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFakeBarcode(Color color) {
    return Column(
      children: [
        Row(
          children: List.generate(15, (i) => Container(
            width: i % 3 == 0 ? 3 : 1,
            height: 25,
            margin: const EdgeInsets.symmetric(horizontal: 1),
            color: color,
          )),
        ),
        Text('1234567890', style: GoogleFonts.outfit(fontSize: 8, color: color)),
      ],
    );
  }

  Widget _buildDetailView() {
    if (_selectedCoupon == null) { return const SizedBox(); }
    final c = _selectedCoupon!;
    return Stack(
      children: [
        // Background Soft Gradient
        Container(
          width: double.infinity,
          height: double.infinity,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [c['colors'][0].withValues(alpha: 0.1), Colors.white],
            ),
          ),
        ),
        SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(24),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () => setState(() => _currentView = DiscountView.viewList),
                      icon: const Icon(Icons.arrow_back),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Center(
                  child: Container(
                    width: MediaQuery.of(context).size.width * 0.85,
                    height: MediaQuery.of(context).size.height * 0.7,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(40),
                      boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 30)],
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: Column(
                      children: [
                        // Coupon Image Section
                        Expanded(
                          flex: 4,
                          child: Stack(
                            children: [
                              Positioned.fill(
                                child: CachedNetworkImage(
                                  imageUrl: c['image'],
                                  fit: BoxFit.cover,
                                  placeholder: (context, url) => Container(color: Colors.grey[100]),
                                ),
                              ),
                              Positioned(
                                top: 40,
                                left: 30,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(c['discount'], style: GoogleFonts.outfit(fontSize: 60, fontWeight: FontWeight.bold, color: primaryColor)),
                                    Text('D I S C O U N T', style: GoogleFonts.outfit(fontSize: 24, letterSpacing: 8, color: darkBlue.withValues(alpha: 0.6))),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        // Dashed Divider
                        Row(
                          children: List.generate(20, (i) => Expanded(
                            child: Container(height: 1, color: i % 2 == 0 ? Colors.transparent : Colors.grey[300]),
                          )),
                        ),
                        // Detailed Section
                        Expanded(
                          flex: 3,
                          child: Padding(
                            padding: const EdgeInsets.all(30),
                            child: Column(
                              children: [
                                Text(
                                  'Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.',
                                  textAlign: TextAlign.center,
                                  style: GoogleFonts.outfit(fontSize: 12, color: Colors.grey[500], height: 1.6),
                                ),
                                const Spacer(),
                                // Large Barcode
                                Column(
                                  children: [
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: List.generate(40, (i) => Container(
                                        width: (i % 5 == 0 || i % 7 == 0) ? 3 : 1,
                                        height: 60,
                                        margin: const EdgeInsets.symmetric(horizontal: 1.5),
                                        color: Colors.black,
                                      )),
                                    ),
                                    const SizedBox(height: 8),
                                    Text('1 2 3 4 5 6 7 8 9 0', style: GoogleFonts.outfit(fontSize: 14, letterSpacing: 4)),
                                  ],
                                ),
                                const Spacer(),
                                // Redeem Button
                                Container(
                                  width: double.infinity,
                                  height: 60,
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(colors: [const Color(0xFFFF8A65), const Color(0xFFFFB74D)]),
                                    borderRadius: BorderRadius.circular(20),
                                    boxShadow: [BoxShadow(color: const Color(0xFFFF8A65).withValues(alpha: 0.4), blurRadius: 15, offset: const Offset(0, 5))],
                                  ),
                                  child: Center(
                                    child: Text('REDEEM NOW', style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ],
    );
  }
}
