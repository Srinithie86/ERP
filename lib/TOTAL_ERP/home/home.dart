import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:erp_smart/theme/Service /lib/core/size_utils.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:erp_localization/erp_localization.dart';
import '../../utils/device_service.dart';
import '../../utils/constants/module_constants.dart';
import '../../utils/models/module_model.dart';
import '../../utils/widgets/universal_app_bar.dart';
import '../../providers/menu_provider.dart' hide ModuleItem;
import 'package:provider/provider.dart';
//import 'package:erp_smart/CRM-ERP-main/lib/Drawer/drawer_screen.dart' as crm_drawer;
import '../../utils/widgets/dynamic_drawer.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with WidgetsBindingObserver {
  int _selectedIndex = 0;
  ModuleItem? _activeModule; // Store ModuleItem instead of instantiated Widget
  String? _activeModuleTitle;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    // Check location permission on start to ensure user friendliness
    WidgetsBinding.instance.addPostFrameCallback((_) {
      DeviceService.forceFetchLocation(context);
      context.read<MenuProvider>().fetchMenuFromServer();
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      context.read<MenuProvider>().fetchMenuFromServer();
    }
  }

  void _onModuleSelected(ModuleItem module, String moduleTitle) {
    setState(() {
      _activeModule = module;
      _activeModuleTitle = moduleTitle;
    });
  }

  void _clearActiveModule() {
    setState(() {
      _activeModule = null;
      _activeModuleTitle = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    const tealColor = Color(0xFF26A69A);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return PopScope(
      canPop: _activeModule == null,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop && _activeModule != null) {
          _clearActiveModule();
        }
      },
      child: AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle(
          statusBarColor: tealColor,
          statusBarIconBrightness: Brightness.light,
        ),
        child: Scaffold(
          key: _scaffoldKey,
          backgroundColor: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
          resizeToAvoidBottomInset: false,
          drawer: DynamicDrawer(moduleName: _activeModuleTitle?.toUpperCase()),
          appBar: null,
          body: _activeModule != null
              ? _activeModule!.screenBuilder!(context)
              : ModernPremiumDashboard(onModuleSelected: _onModuleSelected),
          bottomNavigationBar: null,
        ),
      ),
    );
  }
}

class ModernPremiumDashboard extends StatelessWidget {
  final Function(ModuleItem, String) onModuleSelected;
  const ModernPremiumDashboard({super.key, required this.onModuleSelected});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final menuProvider = context.watch<MenuProvider>();
    
    final visibleModules = allModules
        .where((m) => menuProvider.isModuleVisible(m.title))
        .fold<List<ModuleItem>>([], (list, item) {
          if (!list.any((e) => e.title.toUpperCase() == item.title.toUpperCase())) {
            list.add(item);
          }
          return list;
        });

    return RefreshIndicator(
      color: const Color(0xFF26A69A),
      onRefresh: () async => await menuProvider.fetchMenuFromServer(),
      child: SafeArea(
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            // Header Section
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.fromLTRB(20.w, 15.h, 20.w, 10.h),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                  GestureDetector(
                    onTap: () => Scaffold.of(context).openDrawer(),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Row(
                            children: [
                              Container(
                                padding: EdgeInsets.all(4.w),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.05),
                                      blurRadius: 10,
                                    )
                                  ]
                                ),
                                child: Image.asset('assets/images/logo.png', width: 38.w, height: 38.w),
                              ),
                              SizedBox(width: 12.w),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Global Erp',
                                      style: GoogleFonts.outfit(
                                        fontSize: 20.sp,
                                        fontWeight: FontWeight.w900,
                                        color: const Color(0xFF1B2C61),
                                        letterSpacing: -0.5,
                                      ),
                                    ),
                                    Text(
                                      'Workplace Dashboard',
                                      style: GoogleFonts.outfit(
                                        fontSize: 12.sp,
                                        fontWeight: FontWeight.w500,
                                        color: Colors.grey[500],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                          decoration: BoxDecoration(
                            color: const Color(0xFFE0F2F1),
                            borderRadius: BorderRadius.circular(20.r),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.location_on, color: const Color(0xFF26A69A), size: 14.sp),
                              SizedBox(width: 4.w),
                              Text(
                                'GPS ON',
                                style: GoogleFonts.outfit(
                                  fontSize: 10.sp,
                                  fontWeight: FontWeight.bold,
                                  color: const Color(0xFF26A69A),
                                  fontStyle: FontStyle.italic,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 30.h),
                  Text(
                    'Select an App to Manage',
                    style: GoogleFonts.outfit(
                      fontSize: 22.sp,
                      fontWeight: FontWeight.w900,
                      color: const Color(0xFF0F172A),
                      letterSpacing: -0.5,
                    ),
                  ),
                ],
              ),
            ),
          ),

          SliverPadding(
            padding: EdgeInsets.fromLTRB(20.w, 20.h, 20.w, 30.h),
            sliver: SliverGrid(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  mainAxisSpacing: 35.h,
                  crossAxisSpacing: 15.w,
                  childAspectRatio: 0.76,
                ),
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final module = visibleModules[index];
                  return _buildAppCard(context, module, isDark);
                },
                childCount: visibleModules.length,
              ),
            ),
          ),
          SliverToBoxAdapter(child: SizedBox(height: 50.h)),
        ],
      ),
    ),
  );
}

  Widget _buildAppCard(BuildContext context, ModuleItem module, bool isDark) {
    return GestureDetector(
      onTap: () => onModuleSelected(module, module.title),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            height: 85.w,
            width: 85.w,
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.08),
                  blurRadius: 20,
                  spreadRadius: 2,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Center(
              child: module.imagePath.isNotEmpty
                  ? Image.asset(module.imagePath, width: 48.w, height: 48.w, fit: BoxFit.contain)
                  : Icon(module.fallbackIcon, color: const Color(0xFF26A69A), size: 35.sp),
            ),
          ),
          SizedBox(height: 14.h),
          Text(
            module.title,
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.outfit(
              fontSize: 11.5.sp,
              fontWeight: FontWeight.w800,
              color: const Color(0xFF1E293B),
            ),
          ),
        ],
      ),
    ).animate().scale(begin: const Offset(0.95, 0.95), duration: 400.ms, curve: Curves.easeOutBack);
  }
}
