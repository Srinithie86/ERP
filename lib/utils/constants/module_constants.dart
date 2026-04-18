import 'package:ecommerce/Dashboard_Module/dashboard_screen.dart' as ecommerce;
import 'package:manufacturing_erp/dashboard.dart' as manufacturing;
import 'package:erp_smart/dealer_management/lib/Dashboard/dashboard_screen.dart'
    as dealers;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:warehouse/providers/warehouse_provider.dart';
import '../models/module_model.dart';
import 'package:purchase_erp/dashboard.dart' as purchase;
import 'package:crm/Home/dashboard_screen.dart' as crm;
import 'package:sale_management/Sales_Module/sale_dashboard.dart' as sale_mgmt;
import 'package:accountings/Dashboard_Module/dashboard_screen.dart' as accounting;
import 'package:hrm/views/main_root.dart' as hrm;
import 'package:warehouse/screens/view/dashboard_screen.dart' as warehouse;
import '../../TOTAL_ERP/master/master_screen.dart';

/// Globally accessible key to control modular scaffolds (e.g., opening drawers from host app bar)
final GlobalKey<ScaffoldState> moduleScaffoldKey = GlobalKey<ScaffoldState>();

List<ModuleItem> get allModules => [
  ModuleItem(
    title: 'Master',
    imagePath: 'assets/images/logo.png',
    bgColor: Color(0xFFF3E5F5),
    fallbackIcon: Icons.settings_applications_rounded,
    screenBuilder: (context) => MasterScreen(isEmbedded: true, scaffoldKey: moduleScaffoldKey),
  ),
  ModuleItem(
    title: 'HRM',
    imagePath: 'assets/images/hrm.png',
    bgColor: Color(0xFFE3F2FD),
    fallbackIcon: Icons.people_alt,
    screenBuilder: (context) => hrm.MainRoot(isEmbedded: true, scaffoldKey: moduleScaffoldKey),
  ),
  ModuleItem(
    title: 'CRM',
    imagePath: 'assets/images/crm.png',
    bgColor: Color(0xFFE8F5E9),
    fallbackIcon: Icons.handshake,
    screenBuilder: (context) => crm.DashboardScreen(initialIndex: 0, isEmbedded: true, scaffoldKey: moduleScaffoldKey),
  ),
  ModuleItem(
    title: 'Purchase',
    imagePath: 'assets/images/inventory.png',
    bgColor: Color(0xFFE1F5FE),
    fallbackIcon: Icons.shopping_bag,
    screenBuilder: (context) =>
        purchase.Dashboard(isEmbedded: true, scaffoldKey: moduleScaffoldKey),
  ),
  ModuleItem(
    title: 'Accounting',
    imagePath: 'assets/images/financials.png',
    bgColor: Color(0xFFF3E5F5),
    fallbackIcon: Icons.account_balance_wallet,
    screenBuilder: (context) => const accounting.MainShell(),
  ),
  ModuleItem(
    title: 'Sales',
    imagePath: 'assets/images/sales.png',
    bgColor: Color(0xFFFFEBEE),
    fallbackIcon: Icons.local_offer,
    screenBuilder: (context) => sale_mgmt.DashboardPage(
        isEmbedded: true, scaffoldKey: moduleScaffoldKey),
  ),
  ModuleItem(
    title: 'Ecommerce',
    imagePath: 'assets/images/ecommerce.png',
    bgColor: Color(0xFFE0F2F1),
    fallbackIcon: Icons.shopping_cart,
    screenBuilder: (context) =>
        ecommerce.MainShell(isEmbedded: true, scaffoldKey: moduleScaffoldKey),
  ),
  ModuleItem(
    title: 'Warehouse',
    imagePath: 'assets/images/warehouse.png',
    bgColor: Color(0xFFE0F7FA),
    fallbackIcon: Icons.warehouse,
    screenBuilder: (context) => ChangeNotifierProvider(
      create: (_) => WarehouseProvider(),
      child: warehouse.DashboardScreen(
          isEmbedded: true, scaffoldKey: moduleScaffoldKey),
    ),
  ),
  ModuleItem(
    title: 'Dealer Mgmt',
    imagePath: 'assets/images/dealer_mgmt.png',
    bgColor: Color(0xFFFFF8E1),
    fallbackIcon: Icons.store_mall_directory,
    screenBuilder: (context) => dealers.DashboardScreen(
        isEmbedded: true, scaffoldKey: moduleScaffoldKey),
  ),
  ModuleItem(
    title: 'Manufacturing',
    imagePath: 'assets/images/manufacturing.png',
    bgColor: Color(0xFFE0F7FA),
    fallbackIcon: Icons.precision_manufacturing,
    screenBuilder: (context) => manufacturing.DashboardScreen(
        isEmbedded: true, scaffoldKey: moduleScaffoldKey),
  ),
];
