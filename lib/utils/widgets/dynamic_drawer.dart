import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:erp_smart/providers/menu_provider.dart';
import 'package:erp_smart/utils/app_navigation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:erp_smart/Models/erp_login_api.dart';
import 'package:hrm/main.dart'; 
import 'package:erp_smart/main.dart' as main;
import 'package:erp_smart/TOTAL_ERP/home/home.dart';
import 'package:erp_smart/TOTAL_ERP/home/dashboard_sub_screen.dart';
import 'profile_details_sheet.dart';
import 'package:erp_smart/TOTAL_ERP/login/sign_in_screen.dart' as erp;

class DynamicDrawer extends StatefulWidget {
  final String? moduleName;
  
  const DynamicDrawer({super.key, this.moduleName});

  @override
  State<DynamicDrawer> createState() => _DynamicDrawerState();
}

class _DynamicDrawerState extends State<DynamicDrawer> {
  bool _isSwitching = false;
  String? currentCompanyName;
  String? userName;
  String? userId;
  String? profilePhoto;

  @override
  void initState() {
    super.initState();
    _loadCurrentCompany();
  }

  Future<void> _loadCurrentCompany() async {
    final prefs = await SharedPreferences.getInstance();
    if (mounted) {
      setState(() {
        currentCompanyName = prefs.getString('company_name') ?? 'Global ERP';
        userName = prefs.getString('name') ?? 'User';
        userId = prefs.getString('employee_code') ?? 'ID: ${prefs.getString('uid') ?? "N/A"}';
        profilePhoto = prefs.getString('profile_photo') ?? '';
      });
    }
  }

  Future<void> _showSwitchAccountDialog(BuildContext context) async {
    setState(() => _isSwitching = true);
    
    try {
      final prefs = await SharedPreferences.getInstance();
      final uid = prefs.getString('uid') ?? prefs.getString('id') ?? '';
      final deviceId = prefs.getString('device_id') ?? '1';
      final lat = prefs.getString('lt') ?? '0.0';
      final lng = prefs.getString('ln') ?? '0.0';

      final token = prefs.getString('token');
      
      final response = await ErpLoginApi.switchCompany(
        uid: uid,
        deviceId: deviceId,
        lat: lat,
        lng: lng,
        token: token,
      );

      if (mounted) setState(() => _isSwitching = false);

      if (response['error'] == false && response['company_map'] != null) {
        final List<dynamic> companies = response['company_map'];
        
        if (!mounted) return;

        showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          backgroundColor: Colors.white,
          shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(30))),
          builder: (context) {
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        backgroundColor: Colors.grey[300],
                        radius: 20,
                        child: IconButton(
                          icon: const Icon(Icons.chevron_left, color: Colors.white, size: 25),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ),
                      const SizedBox(width: 15),
                      Text(
                        "Account",
                        style: GoogleFonts.outfit(fontSize: 22, fontWeight: FontWeight.w700, color: Colors.black),
                      ),
                    ],
                  ),
                  const SizedBox(height: 30),
                  Flexible(
                    child: ListView.builder(
                      shrinkWrap: true,
                      itemCount: companies.length,
                      itemBuilder: (context, index) {
                        final company = companies[index];
                        final comData = company['com_data'];
                        final companyName = comData['name'] ?? 'Unknown Company';
                        
                        return Container(
                          margin: const EdgeInsets.only(bottom: 16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(15),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.08),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: ListTile(
                            contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                            title: Text(
                              companyName.toUpperCase(),
                              style: GoogleFonts.outfit(fontWeight: FontWeight.w600, fontSize: 16),
                            ),
                            onTap: () => _performSwitch(context, company),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            );
          },
        );
      } else {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(response['message'] ?? 'Failed to fetch accounts')),
        );
      }
    } catch (e) {
      if (mounted) setState(() => _isSwitching = false);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  Future<void> _performSwitch(BuildContext context, Map<String, dynamic> accountData) async {
    final comData = accountData['com_data'];
    final userData = accountData['user'];
    
    if (comData == null || userData == null) return;

    final prefs = await SharedPreferences.getInstance();
    
    // 1. Update Company Metadata
    String cid = comData['cid']?.toString() ?? accountData['cid']?.toString() ?? '';
    await prefs.setString('cid', cid);
    await prefs.setString('cid_str', cid); // Some parts of the app use cid_str
    await prefs.setString('company_name', comData['name'] ?? '');
    await prefs.setString('address', comData['address'] ?? '');
    await prefs.setString('phone', comData['phone']?.toString() ?? '');
    await prefs.setString('gstin', comData['gstin']?.toString() ?? '');
    await prefs.setString('email', comData['email']?.toString() ?? '');
    String logoUrl = comData['logo_url'] ?? comData['logo'] ?? '';
    if (logoUrl.isNotEmpty && !logoUrl.startsWith('http')) {
       logoUrl = "https://erpsmart.in/uploads/logo/$logoUrl";
    }
    await prefs.setString('logo', logoUrl);
    await prefs.setString('profile_photo', logoUrl);
    
    // 2. Update User Session Data
    final String newUid = userData['uid']?.toString() ?? '';
    await prefs.setString('uid', newUid);
    await prefs.setString('user_id', newUid);
    await prefs.setString('id', newUid); 
    await prefs.setString('name', userData['name'] ?? '');
    await prefs.setString('mobile', userData['mobile']?.toString() ?? '');
    await prefs.setString('role_id', userData['role']?.toString() ?? '1');
    await prefs.setString('led_id', userData['led_id']?.toString() ?? '');
    await prefs.setString('def_acc', userData['def_acc']?.toString() ?? '');
    await prefs.setString('uid', newUid); // Critical for HRM and other modules
    
    // Custom CID and reference IDs
    if (userData['cid'] != null) await prefs.setString('user_cid', userData['cid'].toString());
    if (userData['led_id'] != null) await prefs.setString('led_id_ref', userData['led_id'].toString());
    if (userData['bid'] != null) await prefs.setString('bid', userData['bid'].toString());
    
    // Update token if provided in user object or top level
    final String? newToken = userData['token']?.toString() ?? accountData['token']?.toString();
    if (newToken != null && newToken.isNotEmpty && newToken != "null") {
      await prefs.setString('token', newToken);
    }

    if (userData['bid'] != null) await prefs.setString('bid', userData['bid'].toString());

    // 3. Mark as Logged In
    await prefs.setBool('is_logged_in', true);

    // Refresh Menu via Provider
    if (!mounted) return;
    final menuProvider = Provider.of<MenuProvider>(context, listen: false);
    await menuProvider.fetchMenuFromServer();

    // Reset UI to Home
    if (!mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => HomeScreen()),
      (route) => false,
    );
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Account Switched to ${comData['name']}")),
    );
  }


  @override
  Widget build(BuildContext context) {
    final menuProvider = context.watch<MenuProvider>();
    final String displayTitle = widget.moduleName != null 
        ? (widget.moduleName!.toUpperCase().contains("PURCHASE") ? "Purchase ERP" : 
           widget.moduleName!.toUpperCase().contains("SALES") ? "Sales ERP" :
           widget.moduleName!.toUpperCase().contains("CRM") ? "CRM ERP" :
           widget.moduleName!.toUpperCase().contains("HRM") ? "HRM ERP" :
           "${widget.moduleName} ERP")
        : (currentCompanyName ?? "Main Menu");

    return Drawer(
      backgroundColor: Colors.white,
      child: Column(
        children: [
          _buildHeader(context, displayTitle, userName ?? "User", userId ?? ""),
          
          Expanded(
            child: (widget.moduleName != null && menuProvider.getSubMenus(widget.moduleName!).isEmpty)
                ? const Center(child: Text("No menus available"))
                : ListView(
                    padding: EdgeInsets.zero,
                    physics: const BouncingScrollPhysics(),
                    children: [
                      if (widget.moduleName == null) ...[
                        _DrawerTile(
                          icon: Icons.dashboard_customize_outlined,
                          title: "Global Analytics",
                          onTap: () {
                            Navigator.pop(context);
                            Navigator.of(context).pushAndRemoveUntil(
                              MaterialPageRoute(builder: (context) => const DashboardSubScreen()),
                              (route) => false,
                            );
                          },
                        ),
                        _buildSectionHeader("Account"),
                        _DrawerTile(
                          icon: Icons.person_outline_rounded,
                          title: "Personal Information",
                          onTap: () => showProfileDetailsSheet(context),
                          trailing: const Icon(Icons.chevron_right, size: 20),
                        ),
                        StatefulBuilder(
                          builder: (context, setInternalState) {
                            return _DrawerTile(
                              icon: Icons.lock_outline_rounded,
                              title: "App Lock Pin",
                              onTap: () {},
                              trailing: FutureBuilder<SharedPreferences>(
                                future: SharedPreferences.getInstance(),
                                builder: (context, snapshot) {
                                  bool isLocked = snapshot.data?.getBool('app_lock_enabled') ?? false;
                                  return Switch(
                                    value: isLocked,
                                    onChanged: (v) async {
                                      final prefs = await SharedPreferences.getInstance();
                                      await prefs.setBool('app_lock_enabled', v);
                                      setInternalState(() {});
                                    },
                                    activeColor: const Color(0xFF26A69A),
                                  );
                                }
                              ),
                            );
                          }
                        ),
                        
                        _buildSectionHeader("Preference"),
                        ValueListenableBuilder<ThemeMode>(
                          valueListenable: main.themeNotifier,
                          builder: (context, mode, child) {
                            return _DrawerTile(
                              icon: Icons.dark_mode_outlined,
                              title: "Dark Mode",
                              onTap: () {},
                              trailing: Switch(
                                value: mode == ThemeMode.dark,
                                onChanged: (v) {
                                  main.themeNotifier.value = v ? ThemeMode.dark : ThemeMode.light;
                                },
                                activeColor: const Color(0xFF26A69A),
                              ),
                            );
                          }
                        ),
                        ValueListenableBuilder<Locale>(
                          valueListenable: main.localeNotifier,
                          builder: (context, locale, child) {
                            return _DrawerTile(
                              icon: Icons.language_outlined,
                              title: "Language",
                              onTap: () => _showLanguageDialog(context),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    locale.languageCode == 'en' ? "English" : 
                                    locale.languageCode == 'ta' ? "Tamil" : "Hindi", 
                                    style: GoogleFonts.outfit(color: Colors.grey, fontSize: 13)
                                  ),
                                  const SizedBox(width: 4),
                                  const Icon(Icons.chevron_right, size: 20, color: Colors.grey),
                                ],
                              ),
                            );
                          }
                        ),

                        _buildSectionHeader("Support"),
                        _DrawerTile(
                          icon: Icons.help_outline_rounded,
                          title: "Help Center",
                          onTap: () {},
                          trailing: const Icon(Icons.chevron_right, size: 20),
                        ),
                        _DrawerTile(
                          icon: Icons.policy_outlined,
                          title: "Terms & Policies",
                          onTap: () {},
                          trailing: const Icon(Icons.chevron_right, size: 20),
                        ),
                        
                        const SizedBox(height: 20),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 24),
                          child: ElevatedButton(
                            onPressed: () async {
                              final prefs = await SharedPreferences.getInstance();
                              await prefs.clear();
                              if (!mounted) return;
                              Navigator.of(context).pushAndRemoveUntil(
                                MaterialPageRoute(builder: (context) => const erp.SignInScreen()),
                                (route) => false,
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red.shade600,
                              foregroundColor: Colors.white,
                              minimumSize: const Size(double.infinity, 50),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              elevation: 2,
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.logout_rounded, size: 20),
                                const SizedBox(width: 10),
                                Text("Logout", style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 16)),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 30),
                        const Divider(),
                        _buildSectionHeader("Modules"),
                      ],
                      ..._buildDynamicDrawerItems(context, menuProvider),
                      const SizedBox(height: 20),
                    ],
                  ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildDynamicDrawerItems(BuildContext context, MenuProvider provider) {
    List<Widget> items = [];

    if (widget.moduleName != null) {
      final subMenus = provider.getSubMenus(widget.moduleName!);
      return subMenus.map((item) => _buildDynamicTile(context, item, provider, widget.moduleName)).toList();
    }

    // Primary root modules to show at the top level of the drawer
    final rootModules = ["PURCHASE", "SALES", "CRM", "HRM", "TOTAL_ERP", "ACCOUNTING"];
    
    final availableModules = provider.menuData.keys.toList();
    for (var module in availableModules) {
      final String upperModule = module.trim().toUpperCase();
      
      // If we are in Global menu, only show the defined root modules at the top level
      if (widget.moduleName == null && !rootModules.contains(upperModule)) continue;
      
      final subMenus = provider.getSubMenus(module);
      if (subMenus.isEmpty) continue;

      items.add(Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          iconColor: const Color(0xFF26A69A),
          collapsedIconColor: const Color(0xFF26A69A),
          leading: Icon(AppNavigation.getIcon(module), color: const Color(0xFF26A69A)),
          title: Text(module, style: GoogleFonts.outfit(fontWeight: FontWeight.w700, fontSize: 16)),
          children: subMenus.map((item) => _buildDynamicTile(context, item, provider, module)).toList(),
        ),
      ));
    }

    return items;
  }

  Widget _buildDynamicTile(BuildContext context, Map<String, dynamic> item, MenuProvider provider, String? parentModule) {
    final name = item['name'] ?? 'Unknown';
    final trimmedName = name.toString().trim();
    
    // Check if this item is itself a folder containing more items
    if (provider.isFolder(trimmedName)) {
      final children = provider.getFolderContents(trimmedName);
      
      // Prevent infinite recursion if a folder points to its parent or itself
      if (children.isNotEmpty && trimmedName.toUpperCase() != parentModule?.toUpperCase()) {
        return Theme(
          data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
          child: ExpansionTile(
            iconColor: const Color(0xFF26A69A),
            collapsedIconColor: const Color(0xFF26A69A),
            leading: Icon(AppNavigation.getIcon(trimmedName), color: const Color(0xFF26A69A), size: 22),
            title: Text(trimmedName, style: GoogleFonts.outfit(fontSize: 15, fontWeight: FontWeight.w600)),
            childrenPadding: const EdgeInsets.only(left: 16),
            children: children.map((child) => _buildDynamicTile(context, child, provider, trimmedName)).toList(),
          ),
        );
      }
    }

    return _DrawerTile(
      title: trimmedName,
      icon: AppNavigation.getIcon(trimmedName),
      onTap: () {
        Navigator.pop(context);
        AppNavigation.handleNavigation(context, trimmedName, moduleContext: widget.moduleName ?? parentModule);
      },
    );
  }

  Widget _buildHeader(BuildContext context, String displayTitle, String name, String email) {
    bool isModuleHeader = widget.moduleName != null;
    
    if (isModuleHeader) {
      return Container(
        width: double.infinity,
        padding: EdgeInsets.only(
          top: MediaQuery.of(context).padding.top + 10,
          left: 20,
          right: 12,
          bottom: 20,
        ),
        decoration: const BoxDecoration(
          color: Color(0xFF26A69A),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                displayTitle,
                style: GoogleFonts.outfit(
                  color: Colors.white,
                  fontSize: 22.sp,
                  fontWeight: FontWeight.w700,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            IconButton(
              icon: const Icon(Icons.close, color: Colors.white, size: 28),
              onPressed: () => Navigator.pop(context),
            ),
          ],
        ),
      );
    }

    return Container(
      width: double.infinity,
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 20,
        left: 20,
        right: 12,
        bottom: 25,
      ),
      decoration: const BoxDecoration(
        color: Color(0xFF00695C), // Deeper teal as in screenshot
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 45,
            backgroundColor: Colors.white,
            child: ClipOval(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: (profilePhoto != null && profilePhoto!.isNotEmpty) 
                    ? Image.network(profilePhoto!, fit: BoxFit.contain) 
                    : Image.asset('assets/images/inventory.png', fit: BoxFit.contain), // Default logo
              ),
            ),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  currentCompanyName?.toUpperCase() ?? "GLOBAL ERP",
                  style: GoogleFonts.outfit(
                    color: Colors.white,
                    fontSize: 18.sp,
                    fontWeight: FontWeight.w800,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  email.contains("@") ? email : "smmpower@gmail.com",
                  style: GoogleFonts.outfit(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w400,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.white.withOpacity(0.3)),
                  ),
                  child: InkWell(
                    onTap: () => _showSwitchAccountDialog(context),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          "Switch Account",
                          style: GoogleFonts.outfit(
                            color: Colors.white,
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(width: 4),
                        const Icon(Icons.keyboard_arrow_down_rounded, color: Colors.white, size: 18),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 10),
      child: Text(
        title,
        style: GoogleFonts.outfit(
          fontSize: 15,
          fontWeight: FontWeight.bold,
          color: Colors.grey[600],
        ),
      ),
    );
  }

  void _showLanguageDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Select Language", style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _languageOption(context, "English", const Locale('en')),
            _languageOption(context, "Tamil", const Locale('ta')),
            _languageOption(context, "Hindi", const Locale('hi')),
          ],
        ),
      ),
    );
  }

  Widget _languageOption(BuildContext context, String title, Locale locale) {
    return ListTile(
      title: Text(title, style: GoogleFonts.outfit()),
      onTap: () {
        main.localeNotifier.value = locale;
        Navigator.pop(context);
      },
    );
  }
}

class _DrawerTile extends StatelessWidget {
  final String title;
  final IconData icon;
  final VoidCallback onTap;
  final Widget? trailing;

  const _DrawerTile({
    required this.title,
    required this.icon,
    required this.onTap,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 0),
      leading: Icon(icon, color: const Color(0xFF26A69A), size: 24),
      title: Text(
        title,
        style: GoogleFonts.outfit(
          fontSize: 16,
          color: Colors.black87,
          fontWeight: FontWeight.w500,
        ),
      ),
      trailing: trailing,
      onTap: onTap,
    );
  }
}
