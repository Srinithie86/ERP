import 'package:ecommerce/Dashboard_Module/dashboard_screen.dart' as ecommerce;

import 'package:dealermanagment/Dashboard/dashboard_screen.dart'
    as dealers;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:warehouse/providers/warehouse_provider.dart';
import '../models/module_model.dart';
import 'package:purchase_erp/dashboard.dart' as purchase;


import 'package:accountings/Dashboard_Module/dashboard_screen.dart' as accounting;
import 'package:hrm/views/main_root.dart' as hrm;
import 'package:warehouse/screens/view/dashboard_screen.dart' as warehouse;
import 'package:service_ticket/screens/technician_dashboard.dart' as service_erp;

import '../../TOTAL_ERP/master/master_screen.dart';
import '../widgets/dynamic_drawer.dart';

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
    imagePath: 'assets/images/hrm_new.png',
    bgColor: Color(0xFFE3F2FD),
    fallbackIcon: Icons.people_alt,
    screenBuilder: (context) => hrm.MainRoot(isEmbedded: true, scaffoldKey: moduleScaffoldKey),
  ),

  ModuleItem(
    title: 'Purchase',
    imagePath: 'assets/images/purchase_new.png',
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
    title: 'ERP Service',
    imagePath: 'assets/images/service_logo.png',
    bgColor: Color(0xFFE8EAF6),
    fallbackIcon: Icons.home_repair_service,
    screenBuilder: (context) => const service_erp.TechnicianDashboard(
      drawer: DynamicDrawer(moduleName: "ERP SERVICE"),
    ),
  ),

];
