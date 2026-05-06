import 'package:flutter/material.dart';
import 'package:erp_smart/TOTAL_ERP/home/home.dart';
// Purchase Imports
import 'package:purchase_erp/create_pr.dart';
import 'package:purchase_erp/Supplier%20Quotations/supplier_quotations.dart';
import 'package:purchase_erp/RFQ/request_for_quotation.dart';
import 'package:purchase_erp/GRN/grn_screen.dart';
import 'package:purchase_erp/Supplier%20Quotations/quotation_comparison.dart';
import 'package:purchase_erp/purchase_invoice.dart';
import 'package:purchase_erp/Request%20Approvals/approvals.dart';
import 'package:purchase_erp/purchase_orders/purchase_orders.dart';
import 'package:purchase_erp/QC/qc_inspections_screen.dart';
import 'package:purchase_erp/dashboard.dart' as purchase;



import 'package:hrm/views/main_root.dart' as hrm;
import 'package:hrm/views/home/settings.dart' as hrm_settings;
import 'package:hrm/views/home_screen/leave_management.dart' as hrm_leave;
import 'package:hrm/views/home_screen/employee_detail.dart' as hrm_employee;
import 'package:hrm/views/home/expense.dart' as hrm_emp_expense;
import 'package:hrm/views/home/payroll.dart' as hrm_emp_payroll;
import 'package:hrm/views/home_screen/performance.dart' as hrm_emp_performance;
import 'package:hrm/views/home_screen/reports.dart' as hrm_emp_reports;
import 'package:hrm/views/marketing/marketing_selection.dart' as hrm_emp_marketing;
import 'package:hrm/views/home/ticket_raise.dart' as hrm_emp_ticket;
import 'package:hrm/views/attendance_history/attendance.dart' as hrm_emp_attendance;
import 'package:hrm/views/payroll/advance_salary_request.dart' as hrm_emp_advance;
import 'package:hrm/views/home/feedback.dart' as hrm_emp_feedback;
import 'package:accountings/screens/home/home_screen.dart' as accounting;

import 'package:sale_management/Sales_Module/sale_dashboard.dart' as sales;

import 'package:erp_smart/CRM-ERP-main/lib/Screens/Home/dashboard_screen.dart'
    as crm_dashboard;
import 'package:erp_smart/utils/constants/module_constants.dart' show moduleScaffoldKey;
import 'package:erp_smart/utils/widgets/placeholder_screen.dart';

import 'package:service_ticket/screens/technician_dashboard.dart' as service;

import 'package:manufacturing_erp/core/main_shell.dart' as mfg;
import 'package:manufacturing_erp/modules/formula/bom/bom_screen.dart' as mfg_bom;
import 'package:manufacturing_erp/modules/formula/formula_screen.dart' as mfg_formula;
import 'package:manufacturing_erp/modules/job_card/job_card_screen.dart' as mfg_job;
import 'package:manufacturing_erp/modules/material_request/material_request_screen.dart' as mfg_material;
import 'package:manufacturing_erp/modules/production/production_screen.dart' as mfg_production;
import 'package:manufacturing_erp/modules/production_order/production_order_screen.dart' as mfg_po;
import 'package:manufacturing_erp/modules/quality/pages/quality_list_screen.dart' as mfg_quality;

// HRM Admin Imports
import 'package:hrm_admin_app/Screens/Admin/Onboarding/onboarding_management.dart' as hrm_admin_onboarding;
import 'package:hrm_admin_app/Screens/Admin/PerformanceManagement/performance_management.dart' as hrm_admin_performance;
import 'package:hrm_admin_app/Screens/Admin/TrainingDevelopment/training_management.dart' as hrm_admin_training;
import 'package:hrm_admin_app/Screens/Admin/HealthSafety/health_safety_management.dart' as hrm_admin_health;
import 'package:hrm_admin_app/Screens/Admin/RecuritmentScreens/recruitment.dart' as hrm_admin_recruitment;
import 'package:hrm_admin_app/Screens/Admin/LeaveManagement/admin_leave_management.dart' as hrm_admin_leave;
import 'package:hrm_admin_app/Screens/Admin/PermissionManagement/admin_permission_management.dart' as hrm_admin_permission;
import 'package:hrm_admin_app/Screens/Admin/ExpenseManagement/admin_expense_management.dart' as hrm_admin_expense;
import 'package:hrm_admin_app/Screens/Admin/PayrollManagement/admin_payroll_management.dart' as hrm_admin_payroll;
import 'package:hrm_admin_app/Screens/Admin/ComplaintManagement/admin_complaint_management.dart' as hrm_admin_complaint;
import 'package:hrm_admin_app/Screens/Admin/EmployeeManagement/admin_employee_details.dart' as hrm_admin_employee;
import 'package:hrm_admin_app/Screens/Admin/AttendanceManagement/admin_attendance_management.dart' as hrm_admin_attendance;
import 'package:hrm_admin_app/Screens/Admin/AttendanceManagement/office_attendance.dart' as hrm_admin_office_att;
import 'package:hrm_admin_app/Screens/Admin/AttendanceManagement/mobile_attendance.dart' as hrm_admin_mobile_att;
import 'package:hrm_admin_app/Screens/Admin/LeaveManagement/admin_leave_requests.dart' as hrm_admin_leave_req;
import 'package:hrm_admin_app/Screens/Admin/PermissionManagement/admin_permission_report.dart' as hrm_admin_perm_rep;
import 'package:hrm_admin_app/Screens/Admin/ExpenseManagement/admin_expense_requests.dart' as hrm_admin_exp_req;
import 'package:hrm/views/marketing/marketing_screen.dart' as hrm_marketing;
import 'package:hrm_admin_app/Screens/Admin/LeaveManagement/admin_leave_status.dart' as hrm_admin_leave_status;
import 'package:hrm_admin_app/Screens/Admin/AttendanceManagement/marketing_attendance.dart' as hrm_admin_marketing;

class AppNavigation {
  static void handleNavigation(BuildContext context, String name, {String? moduleContext}) {
    final String n = name.trim().toUpperCase();
    final String m = (moduleContext ?? "").toUpperCase();
    final bool isHrmContext = m.contains("HRM");
    
    // Dashboard handling (module-aware)
    if (n == "DASHBOARD" || n.endsWith(" DASHBOARD")) {
      final bool handled = _openModuleDashboard(context, moduleContext: moduleContext);
      if (!handled) {
        // Fallback: send to ERP common home dashboard
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const HomeScreen()),
          (route) => false,
        );
      }
      return;
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
    } else if (n.contains("QC") || n.contains("INSPECTION")) {
      Navigator.push(context, MaterialPageRoute(builder: (context) => const QCInspectionsScreen()));
    } else if (n.contains("GRN") || n.contains("GOODS RECEIPT")) {
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
    

    // HRM Module
    else if (n == "CHECKIN/CHECK OUT" || n == "CHECKIN/CHECKOUT" || n == "CHECK-IN/CHECK-OUT" || n == "OFFICE ATTENDANCE") {
       Navigator.push(context, MaterialPageRoute(builder: (_) => const hrm_admin_office_att.OfficeAttendanceScreen()));
    } else if (n == "MOBILE ATTENDANCE") {
       Navigator.push(context, MaterialPageRoute(builder: (_) => const hrm_admin_mobile_att.MobileAttendanceScreen()));
    } else if (n == "LEAVE REQUEST" || n == "LEAVE REQUESTS") {
       Navigator.push(context, MaterialPageRoute(builder: (_) => const hrm_admin_leave_req.AdminLeaveRequestsScreen()));
    } else if (n == "PERMISSION REQUEST" || n == "PERMISSION REQUESTS") {
       Navigator.push(context, MaterialPageRoute(builder: (_) => const hrm_admin_perm_rep.AdminPermissionReportScreen()));
    } else if (n == "EXPENSE APPROVAL" || n == "EXPENSE APPROVALS" || n.contains("EXPENSE APPROVAL")) {
       Navigator.push(context, MaterialPageRoute(builder: (_) => const hrm_admin_exp_req.AdminExpenseRequestsScreen()));
    } else if (n.contains("LEAVE APPROVAL") || n.contains("ADMIN LEAVE") || n.contains("LEAVE APPROVEL")) {
       Navigator.push(context, MaterialPageRoute(builder: (_) => const hrm_admin_leave.AdminLeaveManagementScreen()));
    } else if (n == "LEAVE STATUS" || n.contains("LEAVE STATUS")) {
       if (m.contains("ADMIN")) {
          Navigator.push(context, MaterialPageRoute(builder: (_) => const hrm_admin_leave_status.AdminLeaveStatusScreen()));
       } else {
          Navigator.push(context, MaterialPageRoute(builder: (_) => const hrm_leave.LeaveManagementScreen()));
       }
    } else if (n.contains("LEAVE TYPES") || n == "LEAVE" || n == "LEAVE MANAGEMENT") {
       Navigator.push(context, MaterialPageRoute(builder: (_) => const hrm_leave.LeaveManagementScreen()));
    } else if (n.contains("HRM SETTINGS") || n == "SETTINGS") {
       Navigator.push(context, MaterialPageRoute(builder: (_) => const hrm_settings.SettingsScreen()));
    } else if (n.contains("PERMISSION") && !m.contains("ADMIN") && !n.contains("MANAGEMENT")) {
       Navigator.push(context, MaterialPageRoute(builder: (_) => const hrm_leave.LeaveManagementScreen()));
    } else if (n == "EMPLOYEE DETAILS" || n.contains("ADMIN EMPLOYEE") || n.contains("STAFF DETAILS") || (n.contains("ADMIN") && n.contains("EMPLOYEE"))) {
       Navigator.push(context, MaterialPageRoute(builder: (_) => const hrm_admin_employee.AdminEmployeeFeatureScreen()));
    } else if (n == "PERSONAL DETAILS UPDATE" || n == "PERSONAL DETAILS" || n == "EMPLOYEE" || n == "EMPLOYEE DETAIL") {
       Navigator.push(context, MaterialPageRoute(builder: (_) => const hrm_employee.EmployeeDetailsScreen()));
    } else if (n == "ATTENDANCE STATUS" || n.contains("ATTENDANCE STATUS")) {
       Navigator.push(context, MaterialPageRoute(builder: (_) => const hrm_emp_attendance.AttendanceScreen()));
    } else if (n.contains("ATTENDANCE MANAGEMENT") || n.contains("ATTENDANCE ADMIN") || (n.contains("ATTENDANCE") && m.contains("ADMIN"))) {
       Navigator.push(context, MaterialPageRoute(builder: (_) => const hrm_admin_attendance.AdminAttendanceManagementScreen()));
    } else if ((n.contains("LEAVE") && m.contains("ADMIN")) || n.contains("ADMIN LEAVE")) {
       Navigator.push(context, MaterialPageRoute(builder: (_) => const hrm_admin_leave.AdminLeaveManagementScreen()));
    } else if (n.contains("RECRUITMENT")) {
       Navigator.push(context, MaterialPageRoute(builder: (_) => const hrm_admin_recruitment.RecruitmentScreen()));
    } else if (n.contains("ONBOARDING")) {
       Navigator.push(context, MaterialPageRoute(builder: (_) => const hrm_admin_onboarding.OnboardingManagementScreen()));
    } else if (n == "EMPLOYEE COMPLAIN RAISE" || n == "EMPLOYEE COMPLAINTS" || n.contains("COMPLAIN RAISE")) {
       Navigator.push(context, MaterialPageRoute(builder: (_) => const hrm_emp_feedback.FeedbackSupportScreen()));
    } else if (n.contains("COMPLAINTS") || n.contains("COMPLAINT MANAGEMENT")) {
       Navigator.push(context, MaterialPageRoute(builder: (_) => const hrm_admin_complaint.AdminComplaintManagementScreen()));
    } else if (n == "ADVANCE" || n == "ADVANCE SALARY") {
       Navigator.push(context, MaterialPageRoute(builder: (_) => const hrm_emp_advance.AdvanceSalaryRequestScreen()));
    } else if (n == "PAYROLL" || n == "PAY ROLL" || n == "PAYROLL AND ADVANCE" || n == "PAYROLL & ADVANCE") {
       Navigator.push(context, MaterialPageRoute(builder: (_) => const hrm_emp_payroll.PayrollScreen()));
    } else if ((n.contains("PAYROLL") || n.contains("PAY ROLL")) && m.contains("ADMIN")) {
       Navigator.push(context, MaterialPageRoute(builder: (_) => const hrm_admin_payroll.AdminPayrollManagementScreen()));
    } else if (n.contains("PAYROLL") || n.contains("PAY ROLL") || n.contains("SALARY")) {
       Navigator.push(context, MaterialPageRoute(builder: (_) => const hrm_emp_payroll.PayrollScreen()));
    } else if (n.contains("PERMISSION MANAGEMENT") || (n.contains("PERMISSION") && m.contains("ADMIN"))) {
       Navigator.push(context, MaterialPageRoute(builder: (_) => const hrm_admin_permission.AdminPermissionManagementScreen()));
    } else if (n == "EXPENSE" || (n.contains("EXPENSE") && m.contains("ADMIN"))) {
       Navigator.push(context, MaterialPageRoute(builder: (_) => const hrm_admin_expense.AdminExpenseManagementScreen()));
    } else if (n.contains("EXPENSE MANAGEMENT") || n.contains("EXPENSE")) {
       Navigator.push(context, MaterialPageRoute(builder: (_) => const hrm_emp_expense.ExpenseManagementScreen()));
    } else if (n == "PERFORMANCE" || (n.contains("PERFORMANCE") && m.contains("ADMIN"))) {
       Navigator.push(context, MaterialPageRoute(builder: (_) => const hrm_admin_performance.PerformanceManagementScreen()));
    } else if (n.contains("MY PERFORMANCE") || n.contains("PERFORMANCE")) {
       Navigator.push(context, MaterialPageRoute(builder: (_) => const hrm_emp_performance.PerformanceScreen()));
    } else if (n.contains("TRAINING")) {
       Navigator.push(context, MaterialPageRoute(builder: (_) => const hrm_admin_training.TrainingManagementScreen()));
    } else if (n.contains("HEALTH") && n.contains("SAFETY")) {
       Navigator.push(context, MaterialPageRoute(builder: (_) => const hrm_admin_health.HealthSafetyManagementScreen()));
    } else if (n == "MARKETING" || n == "MARKETING ATTENDANCE") {
       if (m.contains("ADMIN")) {
          Navigator.push(context, MaterialPageRoute(builder: (_) => const hrm_admin_marketing.MarketingAttendanceScreen()));
       } else {
          Navigator.push(context, MaterialPageRoute(builder: (_) => const hrm_marketing.MarketingScreen()));
       }
    } else if (n.contains("MARKETING SELECTION") || n.contains("MARKETING")) {
       Navigator.push(context, MaterialPageRoute(builder: (_) => const hrm_emp_marketing.MarketingSelectionScreen()));
    } else if (n.contains("REPORTS") || n.contains("INSIGHTS")) {
       Navigator.push(context, MaterialPageRoute(builder: (_) => const hrm_emp_reports.ReportsScreen()));
    } else if (n.contains("TICKET") || n.contains("RAISE A TICKET")) {
       Navigator.push(context, MaterialPageRoute(builder: (_) => const hrm_emp_ticket.TicketRaise()));
    } else if (n == "HRM" || n == "HRM DASHBOARD" || (isHrmContext && n.contains("HOME"))) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => hrm.MainRoot(isEmbedded: true, scaffoldKey: moduleScaffoldKey)),
      );
    } else if (isHrmContext) {
      // Keep HRM menus fully navigable even when backend sends new/renamed labels.
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => hrm.MainRoot(isEmbedded: true, scaffoldKey: moduleScaffoldKey)),
      );
    }


    // Service Module
    else if (n == "SERVICE" || n == "SERVICE TICKETS" || n == "ERP SERVICE") {
       Navigator.push(context, MaterialPageRoute(builder: (_) => const service.TechnicianDashboard()));
    }

    // Manufacturing Module (when user is inside Manufacturing drawer)
    else if (m.contains("MANUFACTURING")) {
      if (n.contains("BILL OF MATERIAL") || n == "BOM" || n.startsWith("BOM ") || n.contains(" BOM")) {
        Navigator.push(context, MaterialPageRoute(builder: (_) => const mfg_bom.BomScreen()));
      } else if (n.contains("FORMULA") || n.contains("BOM FORMULA")) {
        Navigator.push(context, MaterialPageRoute(builder: (_) => const mfg_formula.FormulaScreen()));
      } else if (n.contains("PRODUCTION ORDER")) {
        Navigator.push(context, MaterialPageRoute(builder: (_) => const mfg_po.ProductionOrderScreen()));
      } else if (n.contains("JOB CARD")) {
        Navigator.push(context, MaterialPageRoute(builder: (_) => const mfg_job.JobCardScreen()));
      } else if (n.contains("MATERIAL") || n.contains("INDENT") || n.contains("ISSUE") || n.contains("INTENT")) {
        Navigator.push(context, MaterialPageRoute(builder: (_) => const mfg_material.MaterialRequestScreen()));
      } else if (n == "PRODUCTION" || n.contains("PRODUCTIONS") || n.contains("PRODUCTION PROCESS")) {
        Navigator.push(context, MaterialPageRoute(builder: (_) => const mfg_production.ProductionEntryScreen()));
      } else if (n.contains("QUALITY") || n.contains("QC")) {
        Navigator.push(context, MaterialPageRoute(builder: (_) => const mfg_quality.QualityListScreen()));
      } else {
        Navigator.push(context, MaterialPageRoute(builder: (_) => PlaceholderScreen(title: name)));
      }
    }
    // Generic
    else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Navigation for $name not implemented yet")),
      );
    }
  }

  static bool _openModuleDashboard(BuildContext context, {String? moduleContext}) {
    final String m = (moduleContext ?? "").trim().toUpperCase();
    if (m.isEmpty) return false;

    if (m.contains("PURCHASE")) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => purchase.Dashboard(isEmbedded: true, scaffoldKey: moduleScaffoldKey)),
      );
      return true;
    }

    if (m.contains("SALES")) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => sales.DashboardPage(isEmbedded: true, scaffoldKey: moduleScaffoldKey)),
      );
      return true;
    }

    if (m.contains("CRM")) {
      Navigator.push(
        context,
        MaterialPageRoute(
            builder: (_) => crm_dashboard.DashboardScreen(
                isEmbedded: true, scaffoldKey: moduleScaffoldKey)),
      );
      return true;
    }

    if (m.contains("MANUFACTURING")) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const mfg.MainShell()),
      );
      return true;
    }

    if (m.contains("HRM")) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => hrm.MainRoot(isEmbedded: true, scaffoldKey: moduleScaffoldKey)),
      );
      return true;
    }

    if (m.contains("ACCOUNTING")) {
      Navigator.push(context, MaterialPageRoute(builder: (_) => const accounting.MainShell()));
      return true;
    }

    if (m.contains("ERP SERVICE") || m == "SERVICE") {
      Navigator.push(context, MaterialPageRoute(builder: (_) => const service.TechnicianDashboard()));
      return true;
    }

    return false;
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
    if (n.contains("MANUFACTURING")) return Icons.precision_manufacturing_outlined;
    if (n.contains("SERVICE")) return Icons.home_repair_service_outlined;
    
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
    if (n.contains("LEAD")) return Icons.person_add_alt_1_rounded;
    if (n.contains("ENQUIRY")) return Icons.headset_mic_rounded;
    if (n.contains("DEAL")) return Icons.handshake_rounded;
    if (n.contains("FOLLOW")) return Icons.event_note_rounded;
    if (n.contains("MEETING")) return Icons.groups_rounded;
    if (n.contains("RECRUITMENT")) return Icons.person_search_outlined;
    if (n.contains("ONBOARDING")) return Icons.how_to_reg_outlined;
    if (n.contains("COMPLAINT")) return Icons.gavel_outlined;
    if (n.contains("PAYROLL")) return Icons.payments_outlined;
    if (n.contains("EXPENSE")) return Icons.account_balance_wallet_outlined;
    if (n.contains("PERFORMANCE")) return Icons.speed_outlined;
    if (n.contains("TRAINING")) return Icons.school_outlined;
    if (n.contains("HEALTH") && n.contains("SAFETY")) return Icons.health_and_safety_outlined;
    if (n.contains("EMPLOYEE DETAILS") || n.contains("STAFF DETAILS")) return Icons.badge_outlined;
    if (n.contains("ATTENDANCE MANAGEMENT") || n.contains("ATTENDANCE ADMIN") || (n.contains("ATTENDANCE") && n.contains("ADMIN"))) return Icons.fact_check_rounded;
    
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
    if (n.contains('SERVICE')) return 'assets/images/service_logo.png';
    return '';
  }
}
