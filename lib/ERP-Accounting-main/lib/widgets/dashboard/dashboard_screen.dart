import 'package:flutter/material.dart';

import '../../screens/note/credit_note_screen.dart';
import '../../screens/trial_balance_screen.dart';
import '../../screens/voucher/contra/contra_voucher.dart';
import '../../screens/note/debit_voucher.dart';
import '../../screens/voucher/journal/journal_voucher.dart';
import '../../screens/voucher/payment/payment_voucher.dart';
import '../../screens/voucher/receipt/receipt_voucher.dart';
import '../../screens/voucher/receipt/receipt_view_list.dart';
import '../../screens/voucher/payment/payment_view_list.dart';
import '../app_colors.dart';

class DashboardDrawer extends StatelessWidget {
  const DashboardDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: Colors.white,
      child: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(20, 56, 20, 24),
            color: AppColors.brand,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.25),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.person_rounded,
                    color: Colors.white,
                    size: 30,
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  'Admin User',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 2),
                const Text(
                  'admin@supplier.com',
                  style: TextStyle(color: Colors.white70, fontSize: 12),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              children: const [
                _DrawerItem(
                  icon: Icons.dashboard_rounded,
                  label: 'Dashboard',
                  active: true,
                ),
                _DropdownDrawerItem(
                  icon: Icons.folder_open_rounded,
                  label: 'Voucher Entry',
                  children: [
                    _DrawerItem(
                      icon: Icons.chevron_right_rounded,
                      label: 'Receipt Voucher',
                      page: ReceiptVoucherScreen(),
                      indentLevel: 1,
                    ),
                    _DrawerItem(
                      icon: Icons.chevron_right_rounded,
                      label: 'Payment Voucher',
                      page: PaymentVoucherScreen(),
                      indentLevel: 1,
                    ),
                    _DrawerItem(
                      icon: Icons.chevron_right_rounded,
                      label: 'Credit Note',
                      page: CreditNoteScreen(),
                      indentLevel: 1,
                    ),
                    _DrawerItem(
                      icon: Icons.chevron_right_rounded,
                      label: 'Debit Note',
                      page: DebitScreen(),
                      indentLevel: 1,
                    ),
                  ],
                ),
                _DrawerItem(
                  icon: Icons.account_balance_rounded,
                  label: 'Trial Balance',
                  page: TrialBalanceScreen(),
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: Color(0xFFF0EEF0)),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 14),
            child: Column(
              children: [
                Text(
                  'Version 1.0.0',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey[400],
                    letterSpacing: 0.3,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Powered by SGS',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[400],
                    letterSpacing: 0.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DropdownDrawerItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final List<Widget> children;
  final int indentLevel;

  const _DropdownDrawerItem({
    required this.icon,
    required this.label,
    required this.children,
    this.indentLevel = 0,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 2),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          tilePadding: EdgeInsets.only(left: 16 + (indentLevel * 32.0), right: 16),
          leading: Icon(icon, color: AppColors.text2, size: 20),
          title: Text(
            label,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: AppColors.text1,
            ),
          ),
          children: children,
        ),
      ),
    );
  }
}

class _DrawerItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool active;
  final Widget? page;
  final int indentLevel;

  const _DrawerItem({
    required this.icon,
    required this.label,
    this.active = false,
    this.page,
    this.indentLevel = 0,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 2),
      decoration: BoxDecoration(
        color: active
            ? AppColors.brand.withValues(alpha: 0.1)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(10),
      ),
      child: ListTile(
        dense: true,
        contentPadding: EdgeInsets.only(left: 16 + (indentLevel * 32.0), right: 16),
        leading: Icon(
          icon,
          color: active ? AppColors.brand : AppColors.text2,
          size: 20,
        ),
        title: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: active ? FontWeight.w700 : FontWeight.w500,
            color: active ? AppColors.brand : AppColors.text1,
          ),
        ),
        onTap: () {
          Navigator.pop(context);
          if (page != null) {
            Navigator.push(context, MaterialPageRoute(builder: (_) => page!));
          }
        },
      ),
    );
  }
}
