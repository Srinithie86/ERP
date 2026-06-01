import 'dart:convert';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:service_ticket/core/app_colors.dart';
import 'package:service_ticket/core/size_utils.dart';
import 'package:service_ticket/services/api_service.dart';
import 'package:service_ticket/services/storage_service.dart';
import 'package:service_ticket/services/device_service.dart';

class AddSparesScreen extends StatefulWidget {
  const AddSparesScreen({super.key});

  @override
  State<AddSparesScreen> createState() => _AddSparesScreenState();
}

class _AddSparesScreenState extends State<AddSparesScreen> {
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  List<Map<String, dynamic>> _allProducts = [];
  List<Map<String, dynamic>> _filteredProducts = [];
  final List<Map<String, dynamic>> _selectedProducts = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _fetchProducts();
  }

  Future<void> _fetchProducts() async {
    setState(() => _isLoading = true);
    try {
      final cid = await StorageService.getCid() ?? "";
      final uid = await StorageService.getUid() ?? "";
      final roleId = await StorageService.getRoleId() ?? "";
      final token = await StorageService.getToken() ?? "";
      final engineerId = await StorageService.getEngineerId() ?? "";
      final deviceId = await DeviceService.getDeviceId();

      final response = await http.post(
        Uri.parse(await ApiService.getBaseUrl()),
        body: {
          "type": "2083",
          "cid": cid,
          "uid": uid,
          "role_id": roleId,
          "token": token,
          "engineer_id": engineerId,
          "device_id": deviceId,
          "lt": "123",
          "ln": "123",
          "form": "sm_main_form_10106",
          "select": "*",
        },
      );

      debugPrint("ADD PRODUCTS (2083) RESP: ${response.body}");

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['error'] == false && data['data'] != null) {
          final List products = data['data'];
          setState(() {
            _allProducts = products.map((p) {
              final rawMap = Map<String, dynamic>.from(p as Map);
              rawMap['product_name'] = rawMap['product_name']?.toString() ?? '';
              rawMap['product_code'] = rawMap['product_code']?.toString() ?? '';
              rawMap['id'] = rawMap['id']?.toString() ?? '';
              rawMap['name'] = rawMap['product_name'];
              rawMap['code'] = rawMap['product_code'];
              rawMap['stock'] = '${rawMap['stock_qty'] ?? 0} In Stock';
              rawMap['qty'] = 1;

              return rawMap;
            }).toList();
            _filteredProducts = List.from(_allProducts);
          });
        }
      }
    } catch (e) {
      debugPrint("Error fetching products: $e");
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _filterProducts(String query) {
    setState(() {
      _filteredProducts = _allProducts.where((p) {
        final matchesQuery =
            (p['product_name'] as String).toLowerCase().contains(
              query.toLowerCase(),
            ) ||
            (p['product_code'] as String).toLowerCase().contains(
              query.toLowerCase(),
            );
        return matchesQuery;
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    const tealColor = Color(0xFF26A69A);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: tealColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Spares',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20.sp,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: tealColor))
          : Column(
              children: [
                // Header Search Section
                Container(
                  color: Colors.white,
                  padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 12.h),
                  child: Column(
                    children: [
                      // Search Input
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 14.w),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE8EAF6),
                          borderRadius: BorderRadius.circular(10.r),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.search,
                              color: Colors.grey[600],
                              size: 22.sp,
                            ),
                            SizedBox(width: 10.w),
                            Expanded(
                              child: TextField(
                                controller: _searchController,
                                onChanged: _filterProducts,
                                decoration: InputDecoration(
                                  hintText: 'Search inventory catalog...',
                                  hintStyle: TextStyle(
                                    fontSize: 14.sp,
                                    color: Colors.grey[600],
                                  ),
                                  border: InputBorder.none,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                // List Header
                Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: 16.w,
                    vertical: 12.h,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Available Products',
                        style: TextStyle(
                          fontSize: 15.sp,
                          fontWeight: FontWeight.w800,
                          color: Colors.black87,
                        ),
                      ),
                      Text(
                        'Showing ${_filteredProducts.length} items',
                        style: TextStyle(
                          fontSize: 13.sp,
                          color: Colors.grey[600],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),

                // Product List
                Expanded(
                  child: RefreshIndicator(
                    onRefresh: _fetchProducts,
                    color: tealColor,
                    child: Scrollbar(
                      controller: _scrollController,
                      thumbVisibility: true,
                      trackVisibility: true,
                      thickness: 5.w,
                      radius: Radius.circular(10.r),
                      child: ListView.separated(
                        controller: _scrollController,
                        keyboardDismissBehavior:
                            ScrollViewKeyboardDismissBehavior.onDrag,
                        padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 12.h),
                        itemCount: _filteredProducts.length,
                        separatorBuilder: (_, __) => SizedBox(height: 12.h),
                        itemBuilder: (context, index) {
                          final product = _filteredProducts[index];
                          return _buildProductCard(product, tealColor);
                        },
                      ),
                    ),
                  ),
                ),

                // Bottom Summary Panel
                if (_selectedProducts.isNotEmpty)
                  Container(
                    margin: EdgeInsets.fromLTRB(16.w, 0, 16.w, 16.h),
                    padding: EdgeInsets.symmetric(
                      horizontal: 20.w,
                      vertical: 14.h,
                    ),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [tealColor, Color(0xFF00897B)],
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                      ),
                      borderRadius: BorderRadius.circular(16.r),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 10,
                          offset: const Offset(0, -2),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Item : ${_selectedProducts.length} | Qty : ${_selectedProducts.fold(0, (sum, p) => sum + (p['qty'] as int))}',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 15.sp,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                        ElevatedButton(
                          onPressed: () {
                            Navigator.pop(context, _selectedProducts);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: tealColor,
                            padding: EdgeInsets.symmetric(
                              horizontal: 20.w,
                              vertical: 10.h,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10.r),
                            ),
                            elevation: 0,
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                'Continue',
                                style: TextStyle(
                                  fontSize: 16.sp,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              SizedBox(width: 8.w),
                              Icon(Icons.chevron_right, size: 20.sp),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
    );
  }

  Widget _buildProductCard(Map<String, dynamic> product, Color tealColor) {
    return Container(
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product['product_name'] as String,
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w700,
                        color: Colors.black87,
                      ),
                    ),
                    SizedBox(height: 2.h),
                    Text(
                      product['product_code'] as String,
                      style: TextStyle(
                        fontSize: 15.sp,
                        fontWeight: FontWeight.w600,
                        color: Colors.black54,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      product['stock'] as String,
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF2E7D32),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 16.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Quantity Selector
              Container(
                width: 120.w,
                height: 44.h,
                decoration: BoxDecoration(
                  color: const Color(0xFFE8EAF6),
                  borderRadius: BorderRadius.circular(6.r),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    InkWell(
                      onTap: () {
                        setState(() {
                          if ((product['qty'] as int) > 1) {
                            product['qty'] = (product['qty'] as int) - 1;
                          }
                        });
                      },
                      child: Icon(
                        Icons.remove,
                        color: Colors.black54,
                        size: 20.sp,
                      ),
                    ),
                    SizedBox(
                      width: 45.w,
                      child: TextField(
                        textAlign: TextAlign.center,
                        keyboardType: TextInputType.number,
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w700,
                          color: Colors.black87,
                        ),
                        decoration: const InputDecoration(
                          border: InputBorder.none,
                          isDense: true,
                          contentPadding: EdgeInsets.zero,
                        ),
                        key: ValueKey('${product['id']}_${product['qty']}'),
                        controller: TextEditingController(
                          text: '${product['qty']}',
                        ),
                        onChanged: (val) {
                          final n = int.tryParse(val);
                          if (n != null && n > 0) {
                            product['qty'] = n;
                            final idx = _selectedProducts.indexWhere(
                              (p) =>
                                  p['product_code'] == product['product_code'],
                            );
                            if (idx != -1) {
                              setState(() => _selectedProducts[idx]['qty'] = n);
                            }
                          }
                        },
                      ),
                    ),
                    InkWell(
                      onTap: () {
                        setState(() {
                          product['qty'] = (product['qty'] as int) + 1;
                        });
                      },
                      child: Icon(
                        Icons.add,
                        color: Colors.black54,
                        size: 20.sp,
                      ),
                    ),
                  ],
                ),
              ),
              // Add / Remove Button
              Builder(
                builder: (context) {
                  // ── FIX: use product_code (unique per product) as key
                  final isSelected = _selectedProducts.any(
                    (p) => p['product_code'] == product['product_code'],
                  );
                  return SizedBox(
                    width: 100.w,
                    height: 38.h,
                    child: ElevatedButton(
                      onPressed: () {
                        setState(() {
                          if (isSelected) {
                            _selectedProducts.removeWhere(
                              (p) =>
                                  p['product_code'] == product['product_code'],
                            );
                          } else {
                            _selectedProducts.add(product);
                          }
                        });
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isSelected
                            ? const Color(0xFFFF5252)
                            : tealColor,
                        padding: EdgeInsets.zero,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                        elevation: 0,
                      ),
                      child: Text(
                        isSelected ? 'Remove' : 'Add',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }
}
