import 'package:flutter/material.dart';

// Purchase Imports
import 'package:purchase_erp/create_pr.dart';
import 'package:purchase_erp/Supplier%20Quotations/supplier_quotations.dart';
import 'package:purchase_erp/RFQ/request_for_quotation.dart';
import 'package:purchase_erp/GRN/grn_screen.dart';
import 'package:purchase_erp/Supplier%20Quotations/quotation_comparison.dart';
import 'package:purchase_erp/purchase_invoice.dart';
import 'package:purchase_erp/Request%20Approvals/approvals.dart';
import 'package:purchase_erp/purchase_orders/purchase_orders.dart';

// Sales Imports
import 'package:sale_management/sales_order_module/all_voice_screen.dart';
import 'package:sale_management/sales_invoice_module/all_voice_screen.dart';
import 'package:sale_management/Delivery_chellan_module/all_voice_screen.dart';
import 'package:sale_management/Proforma_Invoice_Module/all_voice_screen.dart';
import 'package:sale_management/Direct_invoice_module/direct_generate_info.dart';
import 'package:sale_management/Sales_Module/sale_dashboard.dart' as sales;
import 'package:purchase_erp/dashboard.dart' as purchase;
import 'package:crm/Home/dashboard_screen.dart' as crm;
import 'package:hrm/views/main_root.dart' as hrm;
import 'package:hrm/views/home/settings.dart' as hrm_settings;
import 'package:hrm/views/home_screen/leave_management.dart' as hrm_leave;
import 'package:accountings/Dashboard_Module/dashboard_screen.dart' as accounting;

class AppNavigation {
  static void handleNavigation(BuildContext context, String name, {String? moduleContext}) {
    final String n = name.trim().toUpperCase();
    final String m = (moduleContext ?? "").toUpperCase();
    
    // Check for "Dashboard" specifically within a module context
    if (n == "DASHBOARD") {
      if (m.contains("PURCHASE")) {
        Navigator.push(context, MaterialPageRoute(builder: (context) => purchase.Dashboard(isEmbedded: true)));
        return;
      } else if (m.contains("SALES")) {
        Navigator.push(context, MaterialPageRoute(builder: (context) => const sales.DashboardPage(isEmbedded: true)));
        return;
      } else if (m.contains("CRM")) {
        Navigator.push(context, MaterialPageRoute(builder: (context) => const crm.DashboardScreen(initialIndex: 0, isEmbedded: true)));
        return;
      } else if (m.contains("HRM")) {
        Navigator.push(context, MaterialPageRoute(builder: (context) => const hrm.MainRoot(isEmbedded: true)));
        return;
      } else if (m.contains("ACCOUNTING")) {
        Navigator.push(context, MaterialPageRoute(builder: (context) => const accounting.MainShell()));
        return;
      }
    }

    // Purchase Module
    if (n == "PURCHASE REQUEST" || n == "PURCHASE REQUISITION" || n == "CREATE PR" || n == "PR") {
      Navigator.push(context, MaterialPageRoute(builder: (context) => const CreatePurchaseRequestScreen()));
    } else if (n == "SUPPLIER QUOTATION ENTRY" || n == "SUPPLIER QUOTATIONS") {
      Navigator.push(context, MaterialPageRoute(builder: (context) => const SupplierQuotationsScreen()));
    } else if (n == "REQUEST FOR QUOTATION (RFQ)" || n == "RFQ") {
      Navigator.push(context, MaterialPageRoute(builder: (context) => const RFQScreen()));
    } else if (n == "PURCHASE ORDER (PO)" || n == "PURCHASE ORDERS") {
      Navigator.push(context, MaterialPageRoute(builder: (context) => const PurchaseOrdersScreen()));
    } else if (n == "GRN INSPECTION/QC" || n == "GRN / QC") {
      Navigator.push(context, MaterialPageRoute(builder: (context) => const GRNScreen()));
    } else if (n == "REQUEST FOR APPROVAL" || n == "APPROVALS") {
      Navigator.push(context, MaterialPageRoute(builder: (context) => const RequestApprovals()));
    } else if (n == "COMPARISON" || n == "QUOTATION COMPARISON") {
      Navigator.push(context, MaterialPageRoute(builder: (context) => const QuotationComparisonScreen()));
    } else if (n.contains("PURCHASE INVOICE")) {
      Navigator.push(context, MaterialPageRoute(builder: (context) => const PurchaseInvoiceScreen()));
    } else if (n == "DASHBOARD") {
      // Direct to specialized dashboard if keyword is just 'DASHBOARD'
      // This is usually handled within the module's sub-navigation list.
      // For now, we'll try to guess based on the context if possible, 
      // but usually the caller will handle specific module dashboards.
    }
    
    // Sales Module
    else if (n.contains("SALES ORDER")) {
       Navigator.push(context, MaterialPageRoute(builder: (_) => const AllSalesOrderPage()));
    } else if (n.contains("SALES INVOICE")) {
       Navigator.push(context, MaterialPageRoute(builder: (_) => const SalesInvoiceAllScreen()));
    } else if (n.contains("DELIVERY CHALLAN")) {
       Navigator.push(context, MaterialPageRoute(builder: (_) => const DeliveryChallanAllScreen()));
    } else if (n.contains("PROFORMA INVOICE")) {
       Navigator.push(context, MaterialPageRoute(builder: (_) => const ProformaAllInvoicePage(title: 'Proforma Invoice')));
    } else if (n.contains("DIRECT INVOICE")) {
       Navigator.push(context, MaterialPageRoute(builder: (_) => const DirectInvoiceGenerateInfoScreen()));
    } else if (n.contains("APPROVAL") || n.contains("RETURN")) {
       // Generic implementation for Sales Approval/Return as found in Sales_Module
       Navigator.push(context, MaterialPageRoute(builder: (_) => const sales.ApproveScreen()));
    } 
    else if (n.contains("RECEIPT") || n.contains("VOUCHER")) {
       Navigator.push(context, MaterialPageRoute(builder: (_) => const sales.ReceiptVoucherScreen()));
    }    
    // HRM Module
    else if (n.contains("LEAVE APPROVAL") || n.contains("LEAVE TYPES") || n == "LEAVE") {
       Navigator.push(context, MaterialPageRoute(builder: (_) => const hrm_leave.LeaveManagementScreen()));
    } else if (n.contains("HRM SETTINGS")) {
       Navigator.push(context, MaterialPageRoute(builder: (_) => const hrm_settings.SettingsScreen()));
    } else if (n.contains("PERMISSION")) {
       Navigator.push(context, MaterialPageRoute(builder: (_) => const hrm_leave.LeaveManagementScreen()));
    }
    // Generic
    else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Navigation for $name not implemented yet")),
      );
    }
  }

  static IconData getIcon(String name) {
    final String n = name.toUpperCase();
    
    // Module Icons
    if (n.contains("PURCHASE")) return Icons.shopping_bag_outlined;
    if (n.contains("SALES")) return Icons.trending_up_rounded;
    if (n.contains("HRM")) return Icons.people_outline_rounded;
    if (n.contains("CRM")) return Icons.contact_mail_outlined;
    if (n.contains("ACCOUNTING")) return Icons.account_balance_wallet_outlined;
    if (n.contains("WAREHOUSE")) return Icons.warehouse_outlined;
    
    // Action Icons
    if (n.contains("CREATE PR") || n == "PR" || n.contains("PURCHASE REQUEST")) return Icons.add_shopping_cart_rounded;
    if (n.contains("SUPPLIER QUOTATIONS")) return Icons.history_rounded;
    if (n.contains("RFQ")) return Icons.article_outlined;
    if (n.contains("ORDER")) return Icons.local_offer_outlined;
    if (n.contains("GRN") || n.contains("QC")) return Icons.assignment_turned_in_outlined;
    if (n.contains("INVOICE")) return Icons.receipt_long_outlined;
    if (n.contains("APPROVAL")) return Icons.assignment_ind_outlined;
    if (n.contains("COMPARISON")) return Icons.compare_arrows_rounded;
    if (n.contains("CHALLAN")) return Icons.local_shipping_outlined;
    if (n.contains("LEAVE")) return Icons.event_available_outlined;
    if (n.contains("PERMISSION")) return Icons.history_toggle_off_rounded;
    if (n.contains("SETTINGS")) return Icons.settings_outlined;
    if (n.contains("REPORT")) return Icons.analytics_outlined;
    if (n.contains("DASHBOARD")) return Icons.dashboard_customize_outlined;
    
    return Icons.circle_outlined;
  }

  static List<Color> getGradient(String name) {
    final String n = name.toUpperCase();
    if (n.contains("APPROVAL")) return [const Color(0xfffbc02d), const Color(0xfffdd835)];
    if (n == "PR" || n.contains("PURCHASE")) return [const Color(0xff0288d1), const Color(0xff03a9f4)];
    return [const Color(0xff26A69A), const Color(0xff4DB6AC)];
  }

  static String getModuleImage(String name) {
    final String n = name.trim().toUpperCase();
    if (n.contains('CRM')) return 'assets/images/crm.png';
    if (n.contains('SALES')) return 'assets/images/sales.png';
    if (n.contains('HRM')) return 'assets/images/hrm.png';
    if (n.contains('PURCHASE')) return 'assets/images/inventory.png';
    if (n.contains('ACCOUNTS') || n.contains('FINANCE')) return 'assets/images/financials.png';
    if (n.contains('WAREHOUSE')) return 'assets/images/warehouse.png';
    if (n.contains('MANUFACTURING')) return 'assets/images/manufacturing.png';
    if (n.contains('ECOMMERCE')) return 'assets/images/ecommerce.png';
    if (n.contains('DEALER')) return 'assets/images/dealer_mgmt.png';
    if (n.contains('ATTENDANCE')) return 'assets/images/attendance.png';
    if (n.contains('PAYROLL')) return 'assets/images/payroll.png';
    if (n.contains('PRODUCTION')) return 'assets/images/production.png';
    if (n.contains('SUPPORT')) return 'assets/images/support.png';
    return '';
  }
}
