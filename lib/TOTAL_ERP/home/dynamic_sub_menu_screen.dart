import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:erp_smart/providers/menu_provider.dart';
import 'package:erp_smart/utils/app_navigation.dart';
import 'package:flutter_animate/flutter_animate.dart';

class DynamicSubMenuScreen extends StatefulWidget {
  final String moduleName;
  final List<Map<String, dynamic>> subMenus;

  const DynamicSubMenuScreen({
    super.key,
    required this.moduleName,
    required this.subMenus,
  });

  @override
  State<DynamicSubMenuScreen> createState() => _DynamicSubMenuScreenState();
}

class _DynamicSubMenuScreenState extends State<DynamicSubMenuScreen> {
  String searchQuery = "";
  late List<Map<String, dynamic>> filteredMenus;

  @override
  void initState() {
    super.initState();
    filteredMenus = widget.subMenus;
  }

  void _filterMenus(String query) {
    setState(() {
      searchQuery = query;
      filteredMenus = widget.subMenus
          .where((item) => (item['name'] ?? '')
              .toString()
              .toLowerCase()
              .contains(query.toLowerCase()))
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = const Color(0xFF26A69A);

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF121212) : const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: Text(
          widget.moduleName,
          style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 20),
        ),
        backgroundColor: primaryColor,
        elevation: 0,
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Search Header
          Container(
            padding: EdgeInsets.fromLTRB(20.w, 10.h, 20.w, 20.h),
            decoration: BoxDecoration(
              color: primaryColor,
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(30),
                bottomRight: Radius.circular(30),
              ),
            ),
            child: Container(
              height: 48.h,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(15),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: TextField(
                onChanged: _filterMenus,
                decoration: InputDecoration(
                  hintText: "Search in ${widget.moduleName}...",
                  hintStyle: GoogleFonts.outfit(color: Colors.grey, fontSize: 14.sp),
                  prefixIcon: const Icon(Icons.search, color: Color(0xFF26A69A)),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(vertical: 12.h),
                ),
              ),
            ),
          ),

          Expanded(
            child: filteredMenus.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.search_off_rounded, size: 64, color: Colors.grey.shade400),
                        SizedBox(height: 16.h),
                        Text(
                          "No actions found matching '$searchQuery'",
                          style: GoogleFonts.outfit(color: Colors.grey, fontSize: 16),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: EdgeInsets.all(20.w),
                    itemCount: filteredMenus.length,
                    itemBuilder: (context, index) {
                      final item = filteredMenus[index];
                      final name = item['name'] ?? 'Unknown';
                      
                      return _buildActionCard(context, name, isDark);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionCard(BuildContext context, String name, bool isDark) {
    final icon = AppNavigation.getIcon(name);
    final gradient = AppNavigation.getGradient(name);

    return Container(
      margin: EdgeInsets.only(bottom: 16.h),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => AppNavigation.handleNavigation(context, name, moduleContext: widget.moduleName),
          borderRadius: BorderRadius.circular(20),
          child: Container(
            padding: EdgeInsets.all(16.w),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  width: 50.w,
                  height: 50.w,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: gradient,
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Icon(icon, color: Colors.white, size: 28.w),
                ),
                SizedBox(width: 16.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        style: GoogleFonts.outfit(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.white : Colors.black87,
                        ),
                      ),
                      Text(
                        "Manage ${name.toLowerCase()}",
                        style: GoogleFonts.outfit(
                          fontSize: 12.sp,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 16,
                  color: Colors.grey.shade400,
                ),
              ],
            ),
          ),
        ),
      ),
    ).animate().fadeIn(delay: 50.ms).slideX(begin: 0.1, end: 0);
  }
}
