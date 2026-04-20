import 'package:flutter/material.dart';
import 'package:crm/core/theme/app_theme.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:crm/features/dashboard/screens/dashboard_screen.dart';
import 'package:crm/features/campaign/screens/campaign_request_screen.dart';
import 'package:crm/features/campaign/screens/lead_upload_screen.dart';
import 'package:crm/features/campaign/screens/communication_log_screen.dart';
import 'package:crm/features/campaign/screens/email_sms_campaign_screen.dart';

class MainLayout extends StatefulWidget {
  const MainLayout({super.key});

  @override
  State<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> {
  int _selectedIndex = 0;

  List<Widget> get _screens => [
    const DashboardScreen(), // Integrated Dashboard
    const CampaignRequestScreen(), // Index 1: Campaign Request
    const LeadUploadScreen(), // Index 2: Lead Upload
    const CommunicationLogScreen(), // Index 3: SMS / Email Log
    const EmailSmsCampaignScreen(), // Index 4: Email / SMS Campaign
    const Center(child: Text('Reports')),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.orange[800],
                borderRadius: BorderRadius.circular(4),
              ),
              child: const Text(
                '21472147-DEMO',
                style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
        actions: [
          IconButton(icon: const Icon(Icons.search), onPressed: () {}),
          const CircleAvatar(
            backgroundColor: AppTheme.primaryTeal,
            child: Text('JD', style: TextStyle(color: Colors.white, fontSize: 12)),
          ),
          const SizedBox(width: 16),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: const BoxDecoration(
                color: AppTheme.primaryTeal,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  const Icon(Icons.language, color: Colors.white, size: 30),
                  const SizedBox(height: 8),
                  Text(
                    'Global Erp',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(color: Colors.white),
                  ),
                ],
              ),
            ),
            _drawerItem(0, Icons.dashboard_outlined, 'Dashboard'),
            _drawerExpansionItem(
              'Campaign Center',
              Icons.campaign_outlined,
              [
                'Campaign Request',
                'Lead Upload',
                'Leads List',
                'Email / SMS Campaign',
                'SMS / Email Log',
              ],
            ),
            _drawerExpansionItem(
              'CRM',
              FontAwesomeIcons.handshake,
              [
                'Sign Up',
                'Lead/Enquiry',
                'Assigned TO',
                'Re-Assign',
                'Work Assign',
                'Call Summary',
                'Meeting and Visit',
                'Follow Up',
                'Schedule List',
                'Negotiation',
                'Deal Won',
                'Deal Lost',
                'Customer list',
              ],
            ),
            _drawerItem(4, Icons.description_outlined, 'Reports'),
            _drawerItem(5, Icons.upload_file_outlined, 'Document Upload'),
            _drawerExpansionItem(
              'Ticketing System',
              Icons.confirmation_number_outlined,
              [
                'Ticket List',
                'My Ticket',
                'Ticket Reports',
              ],
            ),
            _drawerItem(7, Icons.feedback_outlined, 'Feedback'),
            _drawerItem(8, Icons.shopping_bag_outlined, 'Product Sale'),
            _drawerItem(9, Icons.support_agent, 'Customer Support'),
            _drawerItem(10, Icons.notifications_active_outlined, 'Reminders / Alerts'),
            _drawerItem(11, Icons.show_chart_outlined, 'Pipeline View'),
            _drawerItem(12, Icons.more_horiz, 'Others-crm'),
          ],
        ),
      ),
      body: _screens[_selectedIndex < _screens.length ? _selectedIndex : 0],
    );
  }

  Widget _drawerItem(int index, dynamic icon, String title) {
    return ListTile(
      leading: icon is IconData 
          ? Icon(icon, color: _selectedIndex == index ? AppTheme.primaryTeal : Colors.grey[700])
          : FaIcon(icon, color: _selectedIndex == index ? AppTheme.primaryTeal : Colors.grey[700], size: 20),
      title: Text(
        title,
        style: TextStyle(
          color: _selectedIndex == index ? AppTheme.primaryTeal : AppTheme.textColor,
          fontWeight: _selectedIndex == index ? FontWeight.bold : FontWeight.normal,
        ),
      ),
      onTap: () {
        setState(() {
          _selectedIndex = index;
        });
        Navigator.pop(context);
      },
    );
  }

  Widget _drawerExpansionItem(String title, dynamic icon, List<String> subItems) {
    return ExpansionTile(
      leading: icon is IconData ? Icon(icon, color: Colors.grey[700]) : FaIcon(icon, color: Colors.grey[700], size: 20),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w500)),
      children: subItems.map((subTitle) {
        return ListTile(
          contentPadding: const EdgeInsets.only(left: 72),
          title: Text(subTitle, style: const TextStyle(fontSize: 14)),
          onTap: () {
             setState(() {
               if (subTitle == 'Campaign Request') {
                 _selectedIndex = 1;
               } else if (subTitle == 'Lead Upload') {
                 _selectedIndex = 2;
               } else if (subTitle == 'SMS / Email Log') {
                 _selectedIndex = 3;
               } else if (subTitle == 'Email / SMS Campaign') {
                 _selectedIndex = 4;
               }
             });
             Navigator.pop(context);
          },
        );
      }).toList(),
    );
  }
}
