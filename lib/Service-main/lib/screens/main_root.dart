import 'package:flutter/material.dart';
import 'package:service_ticket/services/api_service.dart';
import '../widgets/bottom_nav_bar.dart';
import '../core/app_colors.dart';
import '../data/app_data.dart';
import 'home_screen.dart';
import 'jobs/jobs_screen.dart';
import 'jobs/Check_in/direct_visit.dart';
import 'spares/sparetab_screen.dart';
import 'dispatchment/dispatchment_entry.dart';
import 'package:service_ticket/core/size_utils.dart';
import '../widgets/technician_drawer.dart';
import 'package:erp_smart/utils/widgets/dynamic_drawer.dart';

class MainRoot extends StatefulWidget {
  final bool isEmbedded;
  final GlobalKey<ScaffoldState>? scaffoldKey;
  final Function(BuildContext, String, {String? moduleContext})? onNavigate;
  final VoidCallback? onHomePressed;
  final List<Map<String, dynamic>>? serviceMenus;

  const MainRoot({
    super.key,
    this.isEmbedded = false,
    this.scaffoldKey,
    this.onNavigate,
    this.onHomePressed,
    this.serviceMenus,
  });

  @override
  State<MainRoot> createState() => _MainRootState();
}

class _MainRootState extends State<MainRoot> {
  int _navIndex = 0;

  @override
  void initState() {
    super.initState();
    _syncUserData();
  }

  Future<void> _syncUserData() async {
    try {
      await AppData.instance.syncProfile();
      // Only call this once
      await ApiService.getDispatchData();
    } catch (e) {
      debugPrint("Service Module Sync Error: $e");
    }
  }

  void _goToTab(int index) {
    setState(() => _navIndex = index);
  }

  void goToTasks() => _goToTab(1);

  void _openDirectVisit(Map<String, dynamic> job) {
    AppData.instance.updateJob({
      'ticketId': '${job['ticketNo'] ?? job['ticketId'] ?? ''}',
      'customerName': '${job['customerName'] ?? job['name'] ?? ''}',
      'complaint': '${job['complaint'] ?? job['issue'] ?? ''}',
      'phone': '${job['phone'] ?? ''}',
      'address': '${job['address'] ?? ''}',
      'locationLabel': '${job['locationLabel'] ?? job['address'] ?? ''}',
      'jobLatitude': job['jobLatitude'],
      'jobLongitude': job['jobLongitude'],
      'dateText': '${job['dateText'] ?? ''}',
      'issue': '${job['issue'] ?? ''}',
      'product': '${job['product'] ?? ''}',
    });
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (_) => DirectVisitScreen(jobData: job)));
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig.init(context);

    return PopScope(
      canPop: _navIndex == 0,
      onPopInvoked: (didPop) {
        if (didPop) return;
        setState(() => _navIndex = 0);
      },
      child: Scaffold(
        backgroundColor: AppColors.bg,
        extendBody: false,
        drawer: widget.isEmbedded
            ? const DynamicDrawer(moduleName: 'ERP SERVICE')
            : CustomDrawer(
                profile: {
                  'name': AppData.instance.profile['name'],
                  'phone': AppData.instance.profile['phone'],
                },
                menuItems: widget.serviceMenus,
                onJobsTap: () {
                  Navigator.pop(context);
                  _goToTab(1);
                },
                onSparesTap: () {
                  Navigator.pop(context);
                  _goToTab(2);
                },
                onDispatchTap: () {
                  Navigator.pop(context);
                  _goToTab(3);
                },
                onHomePressed: widget.onHomePressed,
              ),
        body: IndexedStack(
          index: _navIndex,
          children: [
            HomeTab(
              isEmbedded: widget.isEmbedded,
              scaffoldKey: widget.scaffoldKey,
              onOpenTasks: goToTasks,
              onOpenDirectVisit: _openDirectVisit,
            ),
            JobsScreen(onBack: () => setState(() => _navIndex = 0)),
            SparePartsTab(onBack: () => setState(() => _navIndex = 0)),
            DispatchmentEntryScreen(
              onBack: () => setState(() => _navIndex = 0),
            ),
          ],
        ),
        bottomNavigationBar: BottomNavBar(
          currentIndex: _navIndex,
          onTap: _goToTab,
        ),
      ),
    );
  }
}
