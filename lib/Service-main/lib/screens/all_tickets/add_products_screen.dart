import 'dart:convert';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:service_ticket/core/app_colors.dart';
import 'package:service_ticket/core/size_utils.dart';
import 'package:service_ticket/services/api_service.dart';
import 'package:service_ticket/services/storage_service.dart';
import 'package:service_ticket/services/device_service.dart';

class AddProductsScreen extends StatefulWidget {
  const AddProductsScreen({super.key});

  @override
  State<AddProductsScreen> createState() => _AddProductsScreenState();
}

class _AddProductsScreenState extends State<AddProductsScreen> {
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  List<Map<String, dynamic>> _allProducts = [];
  List<Map<String, dynamic>> _filteredProducts = [];
  Map<String, dynamic>? _selectedProduct;
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
        Uri.parse(ApiService.baseUrl),
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
              return Map<String, dynamic>.from(p)..addAll({
                'name': p['product_name'] ?? '',
                'code': p['product_code'] ?? '',
                'stock': '${p['stock_qty'] ?? 0} In Stock',
                'qty': 1,
              });
            }).toList();
            _filteredProducts = _allProducts;
            if (_allProducts.isNotEmpty) {
              _selectedProduct = _allProducts[0];
            }
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
            p['name'].toLowerCase().contains(query.toLowerCase()) ||
            p['code'].toLowerCase().contains(query.toLowerCase());
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
          'Products',
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
                      // Search Input with Barcode
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
                            Icon(
                              Icons.qr_code_scanner_rounded,
                              color: const Color(0xFF303F9F),
                              size: 24.sp,
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
                if (_selectedProduct != null)
                  Container(
                    padding: EdgeInsets.fromLTRB(24.w, 16.h, 24.w, 20.h),
                    decoration: const BoxDecoration(color: tealColor),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Row(
                          children: [
                            Text(
                              'Product Name : ',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16.sp,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            Expanded(
                              child: Text(
                                _selectedProduct!['name'],
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16.sp,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 12.h),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Qty : ${_selectedProduct!['qty']}',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16.sp,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            Text(
                              _selectedProduct!['stock'],
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16.sp,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 16.h),
                        SizedBox(
                          width: double.infinity,
                          height: 48.h,
                          child: ElevatedButton(
                            onPressed: () {
                              Navigator.pop(context, _selectedProduct);
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              foregroundColor: tealColor,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(4.r),
                              ),
                              elevation: 0,
                            ),
                            child: Text(
                              'Request',
                              style: TextStyle(
                                fontSize: 16.sp,
                                fontWeight: FontWeight.w700,
                              ),
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
                      product['name'],
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w700,
                        color: Colors.black87,
                      ),
                    ),
                    SizedBox(height: 2.h),
                    Text(
                      product['code'],
                      style: TextStyle(
                        fontSize: 15.sp,
                        fontWeight: FontWeight.w600,
                        color: Colors.black54,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      product['stock'],
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
                          if (product['qty'] > 1) product['qty']--;
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
                        controller: TextEditingController(
                          text: '${product['qty']}',
                        ),
                        onChanged: (val) {
                          final n = int.tryParse(val);
                          if (n != null && n > 0) {
                            product['qty'] = n;
                            if (_selectedProduct != null &&
                                _selectedProduct!['code'] == product['code']) {
                              setState(() {});
                            }
                          }
                        },
                      ),
                    ),
                    InkWell(
                      onTap: () {
                        setState(() {
                          product['qty']++;
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
              // Add Button
              SizedBox(
                width: 80.w,
                height: 36.h,
                child: ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _selectedProduct = product;
                    });
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: tealColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4.r),
                    ),
                    elevation: 0,
                  ),
                  child: Text(
                    'Add',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
    @override
    void dispose() {
      _searchController.dispose();
      _scrollController.dispose();
      super.dispose();
    }
  }
}
