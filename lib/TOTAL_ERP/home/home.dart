import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
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
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          resizeToAvoidBottomInset: false,
          drawer: DynamicDrawer(moduleName: _activeModuleTitle?.toUpperCase()),
          appBar: _activeModule != null ? null : UniversalAppBar(
            onMenuPressed: () => _scaffoldKey.currentState?.openDrawer(),
            title: _selectedIndex == 0
                ? AppLocalization.of('Global Erp')
                : (_selectedIndex == 1
                    ? AppLocalization.of('Global Erp Dashboard')
                    : AppLocalization.of('Settings')),
            subtitle: _selectedIndex == 0
                ? AppLocalization.of('Workplace Dashboard')
                : (_selectedIndex == 1
                    ? AppLocalization.of('Analytics & Reports')
                    : AppLocalization.of('Manage preferences and configuration')),
            isDark: isDark,
          ),
          body: Column(
            children: [
              Expanded(
                child: _activeModule != null
                    ? _activeModule!.screenBuilder!(context)
                    : AppGridSubScreen(onModuleSelected: _onModuleSelected),
              ),
            ],
          ),
          bottomNavigationBar: null, // Removed as requested
        ),
      ),
    );
  }

}

class AppGridSubScreen extends StatelessWidget {
  final Function(ModuleItem, String) onModuleSelected;
  const AppGridSubScreen({super.key, required this.onModuleSelected});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Column(
      children: [
        SizedBox(height: 10.h),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.w),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text(
              AppLocalization.of('Select an App to Manage'),
              style: GoogleFonts.outfit(
                fontSize: 20.sp,
                fontWeight: FontWeight.w900,
                color: isDark ? Colors.white : Colors.black,
                letterSpacing: -0.2,
              ),
            ),
          ),
        ),
        SizedBox(height: 20.h),
        Expanded(
          child: RefreshIndicator(
            color: const Color(0xFF26A69A),
            onRefresh: () async {
              await context.read<MenuProvider>().fetchMenuFromServer();
            },
            child: GridView.count(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: EdgeInsets.only(left: 20.w, right: 20.w, bottom: 100.h),
              crossAxisCount: 3,
              mainAxisSpacing: 20.h,
              crossAxisSpacing: 20.w,
            childAspectRatio: 0.72,
            children: [
              ...allModules
                  .where((module) => context.watch<MenuProvider>().isModuleVisible(module.title))
                  .map((module) {
                return _buildAppCard(
                  context,
                  module.title,
                  module.imagePath,
                  module.bgColor,
                  module.fallbackIcon,
                  () {
                    if (module.screenBuilder != null) {
                      onModuleSelected(module, module.title);
                    }
                  },
                );
              }),
            ],
          ),
          ),
        ),
      ],
    );
  }

  Widget _buildAppCard(
    BuildContext context,
    String label,
    String imagePath,
    Color bgColor,
    IconData fallbackIcon,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          LayoutBuilder(
            builder: (context, constraints) {
              double size = constraints.maxWidth;
              return Container(
                width: size,
                height: size,
                decoration: BoxDecoration(
                  color: bgColor.withValues(alpha: 0.08),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.04),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                padding: EdgeInsets.all(imagePath.isNotEmpty ? 16.w : 20.w),
                child: ClipOval(
                  child: imagePath.isNotEmpty
                      ? Image.asset(imagePath, fit: BoxFit.contain)
                      : Icon(
                          fallbackIcon,
                          color: Theme.of(context).brightness == Brightness.dark
                              ? Colors.white70
                              : Colors.blueGrey.shade800,
                          size: size * 0.5,
                        ),
                ),
              );
            },
          ),
          SizedBox(height: 8.h),
          Expanded(
            child: Container(
              alignment: Alignment.topCenter,
              child: Text(
                AppLocalization.of(label),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.outfit(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w800,
                  color: Theme.of(context).brightness == Brightness.dark ? Colors.white : const Color(0xFF1E293B),
                  height: 1.1,
                ),
              ),
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 400.ms).scale(begin: const Offset(0.95, 0.95), curve: Curves.easeOutBack, delay: 50.ms);
  }
}
