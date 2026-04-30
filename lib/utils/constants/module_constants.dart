import 'package:ecommerce/Dashboard_Module/dashboard_screen.dart' as ecommerce;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/module_model.dart';
import 'package:purchase_erp/dashboard.dart' as purchase;
import 'package:sale_management/Sales_Module/sale_dashboard.dart' as sales;


import 'package:accountings/Dashboard_Module/dashboard_screen.dart' as accounting;
import 'package:hrm/views/main_root.dart' as hrm;
import 'package:warehouse/screens/view/dashboard_screen.dart' as warehouse;
import 'package:warehouse/providers/warehouse_provider.dart';
import 'package:service_ticket/screens/technician_dashboard.dart' as service_erp;
import 'package:manufacturing_erp/core/main_shell.dart' as mfg;

import '../../TOTAL_ERP/master/master_screen.dart';
import '../widgets/dynamic_drawer.dart';
import 'package:erp_smart/CRM-ERP-main/lib/Screens/Home/dashboard_screen.dart'
    as crm;

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
    title: 'Sales',
    imagePath: 'assets/images/sales.png',
    bgColor: Color(0xFFFFF3E0),
    fallbackIcon: Icons.trending_up_rounded,
    screenBuilder: (context) => sales.DashboardPage(
      isEmbedded: true,
      scaffoldKey: moduleScaffoldKey,
    ),
  ),

  ModuleItem(
    title: 'CRM',
    imagePath: 'assets/images/crm_new.png',
    bgColor: Color(0xFFE8F5E9),
    fallbackIcon: Icons.contact_mail_outlined,
    screenBuilder: (context) =>
        crm.DashboardScreen(isEmbedded: true, scaffoldKey: moduleScaffoldKey),
  ),

  ModuleItem(
    title: 'Manufacturing',
    imagePath: 'assets/images/manufacturing.png',
    bgColor: Color(0xFFE3F2FD),
    fallbackIcon: Icons.precision_manufacturing_outlined,
    screenBuilder: (context) => const mfg.MainShell(),
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
