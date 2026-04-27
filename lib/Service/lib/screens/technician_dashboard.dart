import 'package:flutter/material.dart';
import '../Widgets/bottom_nav_bar.dart';
import '../Widgets/technician_drawer.dart';
import '../core/app_colors.dart';
import '../data/app_data.dart';
import 'spares/toolkit_screen.dart';
import 'home_screen.dart';
import 'jobs/jobs_screen.dart';
import 'jobs/Check_in/direct_visit.dart';
import 'all_tickets/all_tickets.dart';
import 'support/help_support_screen.dart';
import 'support/profiletab_screen.dart';
import 'support/ratings_screen.dart';
import 'spares/sparetab_screen.dart';
import 'standby_screen.dart';
import 'all_dispatch/all_dispatch_screen.dart';
import 'dispatchment/dispatchment_entry.dart';

class TechnicianDashboard extends StatefulWidget {
  final Widget? drawer;
  const TechnicianDashboard({super.key, this.drawer});

  @override
  State<TechnicianDashboard> createState() => _TechnicianDashboardState();
}

class _TechnicianDashboardState extends State<TechnicianDashboard> {
  int _navIndex = 0;

  @override
  void initState() {
    super.initState();
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
    final profile = AppData.instance.profile;

    return Scaffold(
      backgroundColor: AppColors.bg,
      drawer: widget.drawer ?? CustomDrawer(
        profile: profile,
        onProfileTap: () {
          Navigator.pop(context);
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const ProfilePage()),
          );
        },
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
        onAllTicketsTap: () {
          Navigator.pop(context);
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AllTicketsScreen()),
          );
        },
        onStandbyTap: () {
          Navigator.pop(context);
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const StandByScreen()),
          );
        },
        onToolkitTap: () {
          Navigator.pop(context);
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const ToolkitScreen()),
          );
        },
        onAllDispatchTap: () {
          Navigator.pop(context);
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AllDispatchScreen()),
          );
        },
        onRatingTap: () {
          Navigator.pop(context);
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const RatingsScreen()),
          );
        },
        onHelpSupportTap: () {
          Navigator.pop(context);
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const HelpSupportScreen()),
          );
        },
      ),
      body: IndexedStack(
        index: _navIndex,
        children: [
          HomeTab(onOpenTasks: goToTasks, onOpenDirectVisit: _openDirectVisit),
          JobsScreen(onBack: () => setState(() => _navIndex = 0)),
          SparePartsTab(onBack: () => setState(() => _navIndex = 0)),
          DispatchmentEntryScreen(onBack: () => setState(() => _navIndex = 0)),
        ],
      ),
      bottomNavigationBar: BottomNavBar(
        currentIndex: _navIndex,
        onTap: _goToTab,
      ),
    );
  }
}
