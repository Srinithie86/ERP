import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../Dashboard/notification_screen.dart';
import '../Order Managment/orderdetails_screen.dart';
import '../Order Managment/confirmorders_screen.dart';
import '../Order Managment/dispatchment_screen.dart';
import '../Order Managment/dealersalesinvoice_screen.dart';
import '../Order Managment/ordertracking_screen.dart';
import '../Pricing & Schemes/price_screen.dart';
import '../Pricing & Schemes/discountschems_screen.dart';
import '../Inventory & Returns/purchasereturn_screen.dart';
import '../Inventory & Returns/stockavailability_screen.dart';
import '../Inventory & Returns/salesreturn_screen.dart';
import '../Inventory & Returns/replacementcredit_screen.dart';
import '../Payment & Credit/paymentcollections_screen.dart';
import '../Payment & Credit/creditmanagement_screen.dart';

class ManagementScreen extends StatefulWidget {
  final VoidCallback? onBack;
  const ManagementScreen({super.key, this.onBack});

  @override
  State<ManagementScreen> createState() => _ManagementScreenState();
}

class _ManagementScreenState extends State<ManagementScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          _buildManagementHeader(context),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildCategorizedCards(context),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildManagementHeader(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.fromLTRB(16, 50, 16, 60),
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF1E234E), Color(0xFF26A69A)],
            ),
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(40),
              bottomRight: Radius.circular(40),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    onPressed: widget.onBack ?? () => Navigator.pop(context),
                    icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 22),
                  ),
                  Text(
                    'Management & Services',
                    style: GoogleFonts.outfit(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const NotificationScreen()),
                    ),
                    icon: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.15),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.notifications_none_rounded, color: Colors.white, size: 20),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
            ],
          ),
        ),
        Positioned(
          bottom: -28,
          left: 20,
          right: 20,
          child: Container(
            height: 56,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(28),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Row(
              children: [
                const Icon(Icons.search, color: Colors.grey),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    onChanged: (value) => setState(() => _searchQuery = value.toLowerCase()),
                    decoration: InputDecoration(
                      hintText: 'Search modules...',
                      hintStyle: GoogleFonts.outfit(color: Colors.grey[400]),
                      border: InputBorder.none,
                    ),
                    style: GoogleFonts.outfit(color: Colors.grey[800]),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCategorizedCards(BuildContext context) {
    // Return the data-driven filtered cards
    return Column(children: _getFilteredModules(context));
  }

  List<Widget> _getFilteredModules(BuildContext context) {
    final modules = [
      {'title': 'Order Management', 'subtitle': 'Create and track dealer orders', 'icon': Icons.assignment_rounded, 'subItems': ['Order Details', 'Confirm Orders', 'Dispatchment', 'Dealer Sales Invoice', 'Order Tracking']},
      {'title': 'Pricing & Schemes', 'subtitle': 'Manage price lists and discounts', 'icon': Icons.local_offer_rounded, 'subItems': ['Price', 'Discount Schemes']},
      {'title': 'Inventory & Returns', 'subtitle': 'Stock availability and returns', 'icon': Icons.inventory_2_rounded, 'subItems': ['Purchase return', 'Stock Availability', 'Sales return', 'Replacement/ Credit Note']},
      {'title': 'Payment & Credit', 'subtitle': 'Dealer ledgers and collections', 'icon': Icons.payments_rounded, 'subItems': ['Payment Collections', 'Credit Management', 'Payment Reconciliation', 'Dealer Ledger']},
      {'title': 'Dealer Reports', 'subtitle': 'Performance and sales analytics', 'icon': Icons.analytics_rounded, 'subItems': ['Sales & Collection Report', 'Dealer performance']},
      {'title': 'Dealer Details', 'subtitle': 'Product catalogs and licensing', 'icon': Icons.business_rounded, 'subItems': ['Product Details', 'E com product', 'Wishlist', 'Order Status', 'License Uploads', 'Advertisement', 'Delivery', 'Category List']},
      {'title': 'Access Control', 'subtitle': 'User permissions and security', 'icon': Icons.security_rounded, 'subItems': []},
    ];

    return modules
        .where((m) => (m['title'] as String).toLowerCase().contains(_searchQuery) || (m['subtitle'] as String).toLowerCase().contains(_searchQuery))
        .map((m) => _buildGlassCard(
              context,
              title: m['title'] as String,
              subtitle: m['subtitle'] as String,
              icon: m['icon'] as IconData,
              color: const Color(0xFF26A69A),
              subItems: List<String>.from(m['subItems'] as List),
            ))
        .toList();
  }

  Widget _buildGlassCard(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required List<String> subItems,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: subItems.isEmpty
            ? ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                leading: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.08),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, color: color, size: 24),
                ),
                title: Text(
                  title,
                  style: GoogleFonts.outfit(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Colors.grey[800],
                  ),
                ),
                subtitle: Text(
                  subtitle,
                  style: GoogleFonts.outfit(
                    fontSize: 12,
                    color: Colors.grey[500],
                  ),
                ),
                trailing: const Icon(Icons.play_arrow, size: 16, color: Colors.black),
                onTap: () {},
              )
            : Theme(
                data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
                child: ExpansionTile(
                  tilePadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  leading: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.08),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(icon, color: color, size: 24),
                  ),
                  title: Text(
                    title,
                    style: GoogleFonts.outfit(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Colors.grey[800],
                    ),
                  ),
                  subtitle: Text(
                    subtitle,
                    style: GoogleFonts.outfit(
                      fontSize: 12,
                      color: Colors.grey[500],
                    ),
                  ),
                  trailing: const Icon(Icons.play_arrow, size: 16, color: Colors.black),
                  childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
                  children: [
                    Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      children: subItems.map((item) {
                        return Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: () {
                              if (item == 'Order Details') {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (context) => const OrderDetailsScreen()),
                                );
                              } else if (item == 'Confirm Orders') {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (context) => const ConfirmOrdersScreen()),
                                );
                              } else if (item == 'Dispatchment') {
                                Navigator.push(
                                  context,
                                  CupertinoPageRoute(builder: (context) => const DispatchmentScreen()),
                                );
                              } else if (item == 'Dealer Sales Invoice') {
                                Navigator.push(
                                  context,
                                  CupertinoPageRoute(builder: (context) => const DealerSalesInvoiceScreen()),
                                );
                              } else if (item == 'Order Tracking') {
                                Navigator.push(
                                  context,
                                  CupertinoPageRoute(builder: (context) => const OrderTrackingScreen()),
                                );
                              } else if (item == 'Price') {
                                Navigator.push(
                                  context,
                                  CupertinoPageRoute(builder: (context) => const PriceScreen()),
                                );
                              } else if (item == 'Discount Schemes') {
                                Navigator.push(
                                  context,
                                  CupertinoPageRoute(builder: (context) => const DiscountSchemesScreen()),
                                );
                              } else if (item == 'Purchase return') {
                                Navigator.push(
                                  context,
                                  CupertinoPageRoute(builder: (context) => const PurchaseReturnScreen()),
                                );
                              } else if (item == 'Stock Availability') {
                                Navigator.push(
                                  context,
                                  CupertinoPageRoute(builder: (context) => const StockAvailabilityScreen()),
                                );
                              } else if (item == 'Sales return') {
                                Navigator.push(
                                  context,
                                  CupertinoPageRoute(builder: (context) => const SalesReturnScreen()),
                                );
                              } else if (item == 'Replacement/ Credit Note') {
                                Navigator.push(
                                  context,
                                  CupertinoPageRoute(builder: (context) => const ReplacementCreditScreen()),
                                );
                              } else if (item == 'Payment Collections') {
                                Navigator.push(
                                  context,
                                  CupertinoPageRoute(builder: (context) => const PaymentCollectionsScreen()),
                                );
                              } else if (item == 'Credit Management') {
                                Navigator.push(
                                  context,
                                  CupertinoPageRoute(builder: (context) => const CreditManagementScreen()),
                                );
                              }
                            },
                            borderRadius: BorderRadius.circular(15),
                            child: Container(
                              width: (MediaQuery.of(context).size.width - 92) / 2, // 2 columns
                              padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
                              decoration: BoxDecoration(
                                color: color.withValues(alpha: 0.05),
                                borderRadius: BorderRadius.circular(15),
                                border: Border.all(color: color.withValues(alpha: 0.1)),
                              ),
                              child: Row(
                                children: [
                                  Icon(Icons.play_circle_fill_rounded, size: 14, color: color),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      item,
                                      style: GoogleFonts.outfit(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.grey[800],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}
