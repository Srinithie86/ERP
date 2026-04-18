import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:sale_management/Sales_Module/approve_screen.dart';
import 'package:sale_management/Delivery_chellan_module/all_voice_screen.dart';
import '../Proforma_Invoice_Module/all_voice_screen.dart';
import '../sales_invoice_module/all_voice_screen.dart';
import '../Direct_invoice_module/direct_generate_info.dart';
import '../Direct_invoice_module/all_voice_screen.dart';
import '../sales_order_module/all_voice_screen.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: Colors.white,
      width: 310,
      elevation: 4,
      child: Column(
        children: [
          _DrawerHeader(onClose: () => Navigator.pop(context)),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(vertical: 10),
              physics: const BouncingScrollPhysics(),
              children: [
                  const SizedBox(height: 10),
                  const _DrawerTile(
                    icon: Icons.grid_view_rounded,
                    label: 'Dashboard Overview',
                    isActive: true,
                  ),
                  _DrawerTile(
                    icon: Icons.assignment_rounded,
                    label: 'Sales Order',
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const AllSalesOrderPage(),
                        ),
                      );
                    },
                  ),
                  _DrawerTile(
                    icon: Icons.description_rounded,
                    label: 'Proforma Invoice',
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const ProformaAllInvoicePage(
                            title: 'Proforma Invoice',
                          ),
                        ),
                      );
                    },
                  ),
                  _DrawerTile(
                    icon: Icons.local_shipping_rounded,
                    label: 'Delivery Challan',
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const DeliveryChallanAllScreen(),
                        ),
                      );
                    },
                  ),
                  _DrawerTile(
                    icon: Icons.receipt_long_rounded,
                    label: 'Sales Invoice',
                   // badge: '5+',
                    badgeColor: const Color(0xFF26A69A),
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const SalesInvoiceAllScreen(),
                        ),
                      );
                    },
                  ),
                  
                  _DrawerTile(
                    icon: Icons.bolt_rounded,
                    label: 'Direct Invoice',
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              const AllInvoicePage(),
                        ),
                      );
                    },
                  ),
                   _DrawerTile(
                    icon: Icons.approval_rounded,
                    label: 'Approval ',
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const ApproveScreen(),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          
        ],
      ),
    );
  }
}

class _DrawerHeader extends StatelessWidget {
  final VoidCallback onClose;
  const _DrawerHeader({required this.onClose});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: const Color(0xFF26A69A),
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 10,
        bottom: 20,
        left: 20,
        right: 10,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            'Sales Management',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w700,
              fontSize: 22,
              fontFamily: 'Poppins',
            ),
          ),
          IconButton(
            icon: const Icon(Icons.close, color: Colors.white, size: 28),
            onPressed: onClose,
          ),
        ],
      ),
    );
  }
}

class _DrawerSectionLabel extends StatelessWidget {
  final String label;
  const _DrawerSectionLabel(this.label);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(28, 12, 28, 16),
      child: Text(
        label,
        style: TextStyle(
          color: Colors.grey.shade400,
          fontSize: 10,
          fontWeight: FontWeight.w800,
          letterSpacing: 1.8,
          fontFamily: 'Poppins',
        ),
      ),
    );
  }
}

class _DrawerTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isActive;
  final String? badge;
  final Color badgeColor;
  final VoidCallback? onTap;

  const _DrawerTile({
    required this.icon,
    required this.label,
    this.isActive = false,
    this.badge,
    this.badgeColor = const Color(0xFF26A69A),
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    const primaryTeal = Color(0xFF26A69A);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      child: InkWell(
        onTap: onTap ?? () => Navigator.pop(context),
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              Icon(
                icon,
                color: primaryTeal,
                size: 24,
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Text(
                  label,
                  style: const TextStyle(
                    color: Color(0xFF1E293B),
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    fontFamily: 'Poppins',
                  ),
                ),
              ),
              if (badge != null)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: badgeColor,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    badge!,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.w900,
                      fontFamily: 'Poppins',
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
