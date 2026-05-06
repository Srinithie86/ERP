import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../widgets/app_drawer.dart';
import '../sales_order_module/product_model.dart';
import 'package:sale_management/core/api_config.dart';

class SalesOrderInventoryCatalogScreen extends StatefulWidget {
  final String title;
  const SalesOrderInventoryCatalogScreen(
      {super.key, this.title = 'Inventory Catalog'});

  @override
  State<SalesOrderInventoryCatalogScreen> createState() =>
      _SalesOrderInventoryCatalogScreenState();
}

class _SalesOrderInventoryCatalogScreenState
    extends State<SalesOrderInventoryCatalogScreen> {
  final Color primaryColor = const Color(0xFF26A69A);
  String _selectedCategory = 'ALL';
  bool _isLoading = true;
  String? _error;
  final TextEditingController _searchController = TextEditingController();

  List<String> _categories = ['ALL'];
  List<SalesOrderProduct> _allProducts = [];

  @override
  void initState() {
    super.initState();
    _fetchProducts();
  }

  Future<void> _fetchProducts() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final prefs = await SharedPreferences.getInstance();
      
      // Using user provided values as defaults
      final cid = prefs.getString('cid') ?? '44555666';
      final ln = prefs.getString('ln') ?? '145';
      final lt = prefs.getString('lt') ?? '145';
      final deviceId = prefs.getString('device_id') ?? '12345';
      final token = prefs.getString('token') ?? '';

      final Map<String, String> body = {
        'type': '8009',
        'cid': cid,
        'ln': ln,
        'lt': lt,
        'device_id': deviceId,
        'token': token,
      };

      final response = await http.post(
        Uri.parse(await ApiConfig.getBaseUrl()),
        body: body,
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['error'] == false) {
          final List<dynamic> productList = data['data'] ?? [];
          setState(() {
            _allProducts = productList
                .map((json) => SalesOrderProduct.fromJson(json))
                .toList();
            
            // Extract unique categories
            final Set<String> uniqueCats = {'ALL'};
            for (var p in _allProducts) {
              if (p.categoryName != null && p.categoryName!.isNotEmpty) {
                uniqueCats.add(p.categoryName!);
              }
            }
            _categories = uniqueCats.toList()..sort((a, b) => a == 'ALL' ? -1 : (b == 'ALL' ? 1 : a.compareTo(b)));
            
            _isLoading = false;
          });
        } else {
          setState(() {
            _error = data['error_msg'] ?? 'Failed to load products';
            _isLoading = false;
          });
        }
      } else {
        setState(() {
          _error = 'Server Error: ${response.statusCode}';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _error = 'Connection failed. Please check your internet.';
        _isLoading = false;
      });
      debugPrint("Error fetching products: $e");
    }
  }

  List<SalesOrderProduct> get _filteredProducts {
    final query = _searchController.text.toLowerCase();
    return _allProducts.where((p) {
      final matchesCategory =
          _selectedCategory == 'ALL' || p.categoryName == _selectedCategory;
      final matchesSearch = p.name.toLowerCase().contains(query) ||
          (p.categoryName?.toLowerCase().contains(query) ?? false);
      return matchesCategory && matchesSearch;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: primaryColor,
        elevation: 0,
        leading: Builder(
          builder: (ctx) => IconButton(
            icon: Icon(Icons.menu_rounded, color: Colors.white, size: 24.sp),
            onPressed: () => Scaffold.of(ctx).openDrawer(),
          ),
        ),
        title: Text(
          widget.title,
          style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 18.sp,
              fontFamily: 'Poppins'),
        ),
      ),
      drawer: const AppDrawer(),
      body: Column(
        children: [
          // Elegant Header Section
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.02),
                  blurRadius: 10.r,
                  offset: Offset(0, 4.h),
                ),
              ],
            ),
            padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 20.h),
            child: Column(
              children: [
                // Premium Search Bar
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 18.w),
                  height: 52.h,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(16.r),
                    border:
                        Border.all(color: const Color(0xFFE2E8F0), width: 1.w),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.search_rounded, color: primaryColor, size: 22.sp),
                      SizedBox(width: 12.w),
                      Expanded(
                        child: TextField(
                          controller: _searchController,
                          onChanged: (value) => setState(() {}),
                          style: TextStyle(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w500,
                            fontFamily: 'Poppins',
                          ),
                          decoration: InputDecoration(
                            hintText: 'Search products...',
                            hintStyle: TextStyle(
                                color: Colors.grey.shade500, fontSize: 14.sp),
                            border: InputBorder.none,
                            isDense: true,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 20.h),
                // Premium Category Pills
                SizedBox(
                  height: 38.h,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    physics: const BouncingScrollPhysics(),
                    itemCount: _categories.length,
                    itemBuilder: (context, index) {
                      final category = _categories[index];
                      final isSelected = _selectedCategory == category;
                      return GestureDetector(
                        onTap: () =>
                            setState(() => _selectedCategory = category),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 250),
                          margin: EdgeInsets.only(right: 10.w),
                          padding: EdgeInsets.symmetric(horizontal: 18.w),
                          decoration: BoxDecoration(
                            color: isSelected ? primaryColor : Colors.white,
                            borderRadius: BorderRadius.circular(30.r),
                            border: Border.all(
                              color: isSelected
                                  ? primaryColor
                                  : const Color(0xFFE2E8F0),
                              width: 1.2.w,
                            ),
                            boxShadow: isSelected
                                ? [
                                    BoxShadow(
                                      color: primaryColor.withOpacity(0.3),
                                      blurRadius: 8.r,
                                      offset: Offset(0, 4.h),
                                    ),
                                  ]
                                : [],
                          ),
                          alignment: Alignment.center,
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              if (isSelected) ...[
                                Container(
                                  width: 5.w,
                                  height: 5.w,
                                  decoration: const BoxDecoration(
                                    color: Colors.white,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                SizedBox(width: 8.w),
                              ],
                              Text(
                                category,
                                style: TextStyle(
                                  color: isSelected
                                      ? Colors.white
                                      : const Color(0xFF64748B),
                                  fontWeight: isSelected
                                      ? FontWeight.w700
                                      : FontWeight.w600,
                                  fontSize: 11.sp,
                                  letterSpacing: 0.5,
                                  fontFamily: 'Poppins',
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),

          // List Info
          if (!_isLoading && _error == null)
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Available Products',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14.sp),
                  ),
                  Text(
                    'Showing ${_filteredProducts.length} items',
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 13.sp),
                  ),
                ],
              ),
            ),

          // Main Content Area
          Expanded(
            child: _isLoading
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircularProgressIndicator(
                          color: primaryColor,
                          strokeWidth: 3.w,
                        ),
                        SizedBox(height: 16.h),
                        Text(
                          'Updating catalog...',
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontFamily: 'Poppins',
                            fontSize: 14.sp,
                          ),
                        ),
                      ],
                    ),
                  )
                : _error != null
                    ? Center(
                        child: Padding(
                          padding: EdgeInsets.all(32.0.w),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.error_outline_rounded,
                                  size: 48.sp, color: Colors.red.shade300),
                              SizedBox(height: 16.h),
                              Text(
                                _error!,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: const Color(0xFF1E293B),
                                  fontFamily: 'Poppins',
                                  fontSize: 14.sp,
                                ),
                              ),
                              SizedBox(height: 24.h),
                              ElevatedButton.icon(
                                onPressed: _fetchProducts,
                                icon: Icon(Icons.refresh_rounded, size: 20.sp),
                                label: Text('Retry', style: TextStyle(fontSize: 14.sp)),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: primaryColor,
                                  foregroundColor: Colors.white,
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 24.w, vertical: 12.h),
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12.r)),
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                    : _filteredProducts.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.inventory_2_outlined,
                                    size: 48.sp, color: Colors.grey.shade300),
                                SizedBox(height: 16.h),
                                Text(
                                  'No products found',
                                  style: TextStyle(
                                    color: Colors.grey.shade500,
                                    fontFamily: 'Poppins',
                                    fontSize: 14.sp,
                                  ),
                                ),
                              ],
                            ),
                          )
                        : GridView.builder(
                            padding: EdgeInsets.symmetric(horizontal: 16.w),
                            gridDelegate:
                                SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              childAspectRatio: 0.55,
                              crossAxisSpacing: 12.w,
                              mainAxisSpacing: 12.h,
                            ),
                            itemCount: _filteredProducts.length,
                            itemBuilder: (context, index) {
                              final product = _filteredProducts[index];
                              return _buildProductCard(product);
                            },
                          ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductCard(SalesOrderProduct product) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24.r),
        border: Border.all(color: const Color(0xFFF0F2F5), width: 1.5.w),
        // Adding a subtle 3D inner reflection
        gradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Colors.white, Color(0xFFFEFEFE)],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 30.r,
            offset: Offset(0, 15.h),
            spreadRadius: -5.r,
          ),
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 12.r,
            offset: Offset(0, 5.h),
            spreadRadius: -2.r,
          ),
          BoxShadow(
            color: primaryColor.withOpacity(0.03),
            blurRadius: 20.r,
            offset: Offset(0, 10.h),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Product Image Container with Gradient Background
          Expanded(
            flex: 11,
            child: Stack(
              children: [
                Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [Color(0xFFF8FAFC), Color(0xFFF1F5F9)],
                    ),
                  ),
                  child: _buildProductImage(product),
                ),
                // Premium Dynamic Stock Badge
                Positioned(
                  top: 14.h,
                  left: 14.w,
                  child: Container(
                    padding:
                        EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.9),
                      borderRadius: BorderRadius.circular(12.r),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 10.r,
                          offset: Offset(0, 4.h),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 8.w,
                          height: 8.h,
                          decoration: BoxDecoration(
                            color: product.stock > 10
                                ? const Color(0xFF00C853)
                                : const Color(0xFFFFAB00),
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: (product.stock > 10
                                        ? const Color(0xFF00C853)
                                        : const Color(0xFFFFAB00))
                                    .withOpacity(0.4),
                                blurRadius: 4.r,
                                spreadRadius: 1.r,
                              ),
                            ],
                          ),
                        ),
                        SizedBox(width: 8.w),
                        Text(
                          'Stock: ${product.stock}',
                          style: TextStyle(
                            color: const Color(0xFF475569),
                            fontSize: 10.sp,
                            fontWeight: FontWeight.w800,
                            fontFamily: 'Poppins',
                            letterSpacing: 0.2,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Product Details
          Expanded(
            flex: 10,
            child: Container(
              padding: EdgeInsets.fromLTRB(12.w, 10.h, 12.w, 12.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 15.sp,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF1E293B),
                      fontFamily: 'Poppins',
                      height: 1.3,
                      letterSpacing: -0.2,
                    ),
                  ),
                  const Spacer(),
                  // Price Section with varied colors
                  Container(
                    padding:
                        EdgeInsets.symmetric(horizontal: 8.w, vertical: 8.h),
                    decoration: BoxDecoration(
                      color: primaryColor.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(16.r),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'PRICE',
                              style: TextStyle(
                                fontSize: 9.sp,
                                color: primaryColor.withOpacity(0.7),
                                fontWeight: FontWeight.w800,
                                letterSpacing: 1.2,
                              ),
                            ),
                            SizedBox(height: 2.h),
                            Text(
                              '₹${product.price.toStringAsFixed(0)}',
                              style: TextStyle(
                                fontSize: 18.sp,
                                fontWeight: FontWeight.w900,
                                color: primaryColor,
                                fontFamily: 'Poppins',
                                letterSpacing: -0.5,
                              ),
                            ),
                          ],
                        ),
                        Icon(
                          Icons.trending_up_rounded,
                          color: primaryColor.withOpacity(0.4),
                          size: 20.sp,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductImage(SalesOrderProduct product) {
    if (product.imageUrl.isEmpty) {
      return _buildPlaceholder();
    }

    return Image.network(
      product.imageUrl,
      fit: BoxFit.cover,
      width: double.infinity,
      height: double.infinity,
      errorBuilder: (context, error, stackTrace) => _buildPlaceholder(),
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) return child;
        return Center(
          child: CircularProgressIndicator(
            value: loadingProgress.expectedTotalBytes != null
                ? loadingProgress.cumulativeBytesLoaded /
                    loadingProgress.expectedTotalBytes!
                : null,
            strokeWidth: 2.w,
            color: primaryColor.withOpacity(0.5),
          ),
        );
      },
    );
  }

  Widget _buildPlaceholder() {
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            primaryColor.withOpacity(0.05),
            primaryColor.withOpacity(0.15),
          ],
        ),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.inventory_2_outlined,
              color: primaryColor.withOpacity(0.3),
              size: 40.sp,
            ),
            SizedBox(height: 8.h),
            Text(
              'No Image',
              style: TextStyle(
                color: primaryColor.withOpacity(0.4),
                fontSize: 10.sp,
                fontWeight: FontWeight.w600,
                fontFamily: 'Poppins',
              ),
            ),
          ],
        ),
      ),
    );
  }
}