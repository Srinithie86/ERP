import 'package:flutter/material.dart';
import '../widgets/app_drawer.dart';
import 'product_model.dart';
import 'payment_screen.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sale_management/core/api_config.dart';
import 'package:erp_localization/erp_localization.dart';

class SalesOrderCatalogScreen extends StatefulWidget {
  final bool isReadOnly;
  final Map<String, dynamic>? selectedCustomer;
  const SalesOrderCatalogScreen({
    super.key,
    this.isReadOnly = false,
    this.selectedCustomer,
  });

  @override
  State<SalesOrderCatalogScreen> createState() =>
      _SalesOrderCatalogScreenState();
}

class _SalesOrderCatalogScreenState extends State<SalesOrderCatalogScreen> {
  final Color primaryColor = const Color(0xFF26A69A);
  String _selectedCategory = 'ALL';
  String _searchQuery = '';

  List<String> _categories = ['ALL'];

  List<SalesOrderProduct> _products = [];
  bool _isFetchingProducts = false;

  @override
  void initState() {
    super.initState();
    _fetchProducts();
  }

  Future<void> _fetchProducts() async {
    setState(() => _isFetchingProducts = true);
    try {
      final prefs = await SharedPreferences.getInstance();
      final cid = prefs.getString('cid') ?? '44555666';
      final lt = prefs.getString('lt') ?? '123';
      final ln = prefs.getString('ln') ?? '123';
      final deviceId = prefs.getString('device_id') ?? '123';

      final response = await http.post(
        Uri.parse(await ApiConfig.getBaseUrl()),
        body: {
          'type': '2083',
          'cid': '44555666',
          'lt': lt,
          'ln': ln,
          'device_id': deviceId,
          'form': 'sm_main_form_10106',
          'select': '*',
        },
      );

      final res = json.decode(response.body);
      if (res['error'] == false && res['data'] != null) {
        final List<dynamic> data = res['data'];
        setState(() {
          _products = data
              .map((item) => SalesOrderProduct(
                    id: item['id'].toString(),
                    name: item['product_name'] ?? 'Unknown',
                    stock:
                        int.tryParse(item['stock_qty']?.toString() ?? '100') ??
                            100,
                    price:
                        double.tryParse(item['price']?.toString() ?? '0') ?? 0,
                    category: item['category']?.toString() ?? 'General',
                  ))
              .toList();
          
          // Extract dynamic categories
          final fetchedCats = _products.map((p) => p.category).where((c) => c.isNotEmpty).toSet().toList();
          fetchedCats.sort();
          _categories = ['ALL', ...fetchedCats];
        });
      }
    } catch (e) {
      debugPrint("Error fetching products: $e");
    } finally {
      if (mounted) setState(() => _isFetchingProducts = false);
    }
  }

  List<SalesOrderProduct> get _filteredProducts {
    List<SalesOrderProduct> result = _products;
    if (_selectedCategory != 'ALL') {
      result = result.where((p) => p.category == _selectedCategory).toList();
    }
    if (_searchQuery.isNotEmpty) {
      result = result.where((p) => p.name.toLowerCase().contains(_searchQuery.toLowerCase())).toList();
    }
    return result;
  }

  int get _totalItems => _products.where((p) => p.isAdded).length;
  int get _totalQty => _products
      .where((p) => p.isAdded)
      .fold(0, (sum, p) => sum + p.selectedQty);
  double get _totalAmount => _products.where((p) => p.isAdded).fold(
      0,
      (sum, p) =>
          sum +
          (p.isPercentageDiscount
              ? (p.price * (1 - p.discountPercentage / 100) * p.selectedQty)
              : ((p.price - p.discountAmount) * p.selectedQty)));

  double get _totalDiscount => _products.where((p) => p.isAdded).fold(
      0,
      (sum, p) =>
          sum +
          (p.isPercentageDiscount
              ? (p.price * (p.discountPercentage / 100) * p.selectedQty)
              : (p.discountAmount * p.selectedQty)));

  void _showDiscountBottomSheet(SalesOrderProduct product) {
    bool localIsPercentage = product.isPercentageDiscount;
    final TextEditingController discountCtrl = TextEditingController(
        text: localIsPercentage
            ? (product.discountPercentage > 0
                ? product.discountPercentage.toString()
                : '')
            : (product.discountAmount > 0
                ? product.discountAmount.toString()
                : ''));

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return StatefulBuilder(builder: (context, setModalState) {
          return Padding(
            padding: EdgeInsets.only(
              top: 24,
              left: 24,
              right: 24,
              bottom: MediaQuery.of(context).viewInsets.bottom + 24,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        product.name.replaceAll('\n', ' '),
                        style: const TextStyle(
                          color: Color(0xFF1A2332),
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Poppins',
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.grey),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  AppLocalization.of('Discount in'),
                  style: TextStyle(
                    color: Color(0xFF546E7A),
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    fontFamily: 'Poppins',
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    GestureDetector(
                      onTap: () {
                        setModalState(() => localIsPercentage = true);
                      },
                      child: Row(
                        children: [
                          Icon(
                            localIsPercentage
                                ? Icons.radio_button_checked
                                : Icons.radio_button_off,
                            color: primaryColor,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '%',
                            style: TextStyle(
                              color: localIsPercentage
                                  ? primaryColor
                                  : Colors.grey,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 24),
                    GestureDetector(
                      onTap: () {
                        setModalState(() => localIsPercentage = false);
                      },
                      child: Row(
                        children: [
                          Icon(
                            !localIsPercentage
                                ? Icons.radio_button_checked
                                : Icons.radio_button_off,
                            color: primaryColor,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '₹',
                            style: TextStyle(
                              color: !localIsPercentage
                                  ? primaryColor
                                  : Colors.grey,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Text(
                  localIsPercentage ? AppLocalization.of('Percentage') : AppLocalization.of('Amount (₹)'),
                  style: const TextStyle(
                    color: Color(0xFF90A4AE),
                    fontSize: 12,
                    fontFamily: 'Poppins',
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: discountCtrl,
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  autofocus: true,
                  style:
                      const TextStyle(color: Color(0xFF1A2332), fontSize: 16),
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: const Color(0xFFF5F7FA),
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 14),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide:
                          BorderSide(color: primaryColor.withOpacity(0.3)),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide:
                          BorderSide(color: primaryColor.withOpacity(0.3)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(color: primaryColor, width: 2),
                    ),
                    suffixIcon: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            AppLocalization.of('Total Amount'),
                            style: TextStyle(
                                color: primaryColor,
                                fontWeight: FontWeight.w600),
                          ),
                          const SizedBox(width: 4),
                          Icon(Icons.arrow_drop_down, color: primaryColor),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 32),
                Container(
                  width: double.infinity,
                  height: 52,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF26A69A), Color(0xFF00796B)],
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                    ),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF26A69A).withOpacity(0.3),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: ElevatedButton(
                    onPressed: () {
                      final double? discount =
                          double.tryParse(discountCtrl.text);
                      setState(() {
                        product.isPercentageDiscount = localIsPercentage;
                        if (localIsPercentage) {
                          product.discountPercentage = discount ?? 0.0;
                          product.discountAmount = 0.0;
                        } else {
                          product.discountAmount = discount ?? 0.0;
                          product.discountPercentage = 0.0;
                        }
                      });
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      AppLocalization.of('Continue'),
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Poppins',
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: primaryColor,
       // elevation: 0,
        // leading: Builder(
        //   builder: (ctx) => IconButton(
        //     icon: const Icon(Icons.menu_rounded, color: Colors.white),
        //     onPressed: () => Scaffold.of(ctx).openDrawer(),
        //   ),
        // ),
        title: Text(
          widget.isReadOnly ? AppLocalization.of('Inventory') : AppLocalization.of('Sales Orders'),
          style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontFamily: 'Poppins'),
        ),
        // actions: [
        //   if (!widget.isReadOnly)
        //     IconButton(
        //       icon: const Icon(Icons.add_circle_outline_rounded,
        //           color: Colors.white),
        //       tooltip: 'New Order',
        //       onPressed: () {},
        //     ),
        //   const SizedBox(width: 4),
        // ],
      ),
     // drawer: const AppDrawer(),
      body: Column(
        children: [
          // White Header Section
          Container(
            color: Colors.white,
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // Search Bar
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: Colors.blueGrey.shade50,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.search, color: Colors.grey.shade500),
                      const SizedBox(width: 8),
                      Expanded(
                        child: TextField(
                          onChanged: (val) => setState(() => _searchQuery = val),
                          decoration: InputDecoration(
                            hintText: widget.isReadOnly
                                ? AppLocalization.of('Search products...')
                                : AppLocalization.of('Search inventory catalog...'),
                            hintStyle: TextStyle(color: Colors.grey.shade500),
                            border: InputBorder.none,
                          ),
                        ),
                      ),
                      // Icon(Icons.qr_code_scanner, color: Colors.blue.shade600),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                // Categories
                SizedBox(
                  height: 36,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: _categories.length,
                    itemBuilder: (context, index) {
                      final category = _categories[index];
                      final isSelected = _selectedCategory == category;
                      return GestureDetector(
                        onTap: () =>
                            setState(() => _selectedCategory = category),
                        child: Container(
                          margin: const EdgeInsets.only(right: 8),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? primaryColor
                                : const Color(0xFFB2DFDB),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            category,
                            style: TextStyle(
                              color: isSelected
                                  ? Colors.white
                                  : const Color(0xFF00695C),
                              fontWeight: FontWeight.w600,
                              fontSize: 12,
                            ),
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
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  AppLocalization.of('Available Products'),
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                ),
                Text(
                  '${AppLocalization.of("Showing")} ${_filteredProducts.length} ${AppLocalization.of("items")}',
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                ),
              ],
            ),
          ),

          // Product List (Restoring original list view for Sales Orders)
          Expanded(
            child: _isFetchingProducts
                ? const Center(child: CircularProgressIndicator())
                : _filteredProducts.isEmpty
                    ? Center(child: Text(AppLocalization.of('No products found')))
                    : widget.isReadOnly
                        ? GridView.builder(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              childAspectRatio: 0.64,
                              crossAxisSpacing: 12,
                              mainAxisSpacing: 12,
                            ),
                            itemCount: _filteredProducts.length,
                            itemBuilder: (context, index) {
                              final product = _filteredProducts[index];
                              return _buildProductCard(product);
                            },
                          )
                        : ListView.builder(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            itemCount: _filteredProducts.length,
                            itemBuilder: (context, index) {
                              final product = _filteredProducts[index];
                              return _buildProductListItem(product);
                            },
                          ),
          ),

          // Persistent Bottom Panel
          if (!widget.isReadOnly && _totalItems > 0)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xFF26A69A),
                    Color(0xFF4DB6AC),
                    Color(0xFF00796B),
                  ],
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, -4),
                  ),
                ],
              ),
              child: SafeArea(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          '${AppLocalization.of("Item")} : $_totalItems | ${AppLocalization.of("Qty")} : $_totalQty',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Poppins',
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${AppLocalization.of("Disc")} : ₹${_totalDiscount.toInt()} | ${AppLocalization.of("Amount")} : ${_totalAmount.toInt()}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Poppins',
                          ),
                        ),
                      ],
                    ),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => SalesOrderPaymentScreen(
                              totalAmount: _totalAmount,
                              selectedProducts:
                                  _products.where((p) => p.isAdded).toList(),
                              selectedCustomer: widget.selectedCustomer,
                            ),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: primaryColor,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            AppLocalization.of('Continue'),
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          SizedBox(width: 4),
                          Icon(Icons.chevron_right, size: 18),
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

  Widget _buildProductCard(SalesOrderProduct product) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Product Image
          Expanded(
            flex: 3,
            child: Stack(
              children: [
                Image.asset(
                  product.imageUrl,
                  //  package: 'sale_management',
                  fit: BoxFit.cover,
                  width: double.infinity,
                ),
                // Stock Badge
                Positioned(
                  top: 8,
                  left: 8,
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.6),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      '${product.stock} ${AppLocalization.of("left")}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 9,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Product Details
          Expanded(
            flex: 2,
            child: Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF4A4A4A),
                      fontFamily: 'Poppins',
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Text(
                        '₹${product.price.toInt()}',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF1B1B1B),
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE8F5E9),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      AppLocalization.of('FREE Delivery'),
                      style: TextStyle(
                        color: Colors.green.shade700,
                        fontSize: 9,
                        fontWeight: FontWeight.w600,
                      ),
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

  Widget _buildProductListItem(SalesOrderProduct product) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F6F8),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product.name,
                      style: const TextStyle(
                        color: Color(0xFF1E242B),
                        fontWeight: FontWeight.w800,
                        fontSize: 15,
                        height: 1.3,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      '${product.stock} ${AppLocalization.of("IN STOCK")}',
                      style: const TextStyle(
                        color: Color(0xFFB14D00),
                        fontWeight: FontWeight.w800,
                        fontSize: 11,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 8),
                    GestureDetector(
                      onTap: () => _showDiscountBottomSheet(product),
                      child: Row(
                        children: [
                          const Icon(Icons.local_offer,
                              size: 14, color: Colors.green),
                          const SizedBox(width: 4),
                          Text(
                            product.isPercentageDiscount
                                ? (product.discountPercentage > 0
                                    ? '${AppLocalization.of("Discount")}: ${product.discountPercentage}%'
                                    : AppLocalization.of('Add Discount'))
                                : (product.discountAmount > 0
                                    ? '${AppLocalization.of("Discount")}: ₹${product.discountAmount}'
                                    : AppLocalization.of('Add Discount')),
                            style: const TextStyle(
                              color: Colors.green,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '₹${(product.isPercentageDiscount ? (product.price * (1 - product.discountPercentage / 100)) : (product.price - product.discountAmount)).toStringAsFixed(2)}',
                    style: const TextStyle(
                      color: Color(0xFF1058B8),
                      fontWeight: FontWeight.w900,
                      fontSize: 16,
                      letterSpacing: -0.5,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Counter
              Container(
                width: 130,
                height: 42,
                decoration: BoxDecoration(
                  color: const Color(0xFFE8EDF2),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    InkWell(
                      onTap: () {
                        if (product.selectedQty > 1) {
                          setState(() => product.selectedQty--);
                        }
                      },
                      child: const SizedBox(
                        width: 40,
                        height: 42,
                        child: Center(
                          child: Text(
                            '–',
                            style: TextStyle(
                              color: Colors.black87,
                              fontWeight: FontWeight.w400,
                              fontSize: 20,
                            ),
                          ),
                        ),
                      ),
                    ),
                    Text(
                      '${product.selectedQty}',
                      style: const TextStyle(
                        color: Colors.black87,
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                    InkWell(
                      onTap: () {
                        if (product.selectedQty < product.stock) {
                          setState(() => product.selectedQty++);
                        }
                      },
                      child: const SizedBox(
                        width: 40,
                        height: 42,
                        child: Center(
                          child: Text(
                            '+',
                            style: TextStyle(
                              color: Colors.black87,
                              fontWeight: FontWeight.w400,
                              fontSize: 20,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    product.isAdded = !product.isAdded;
                  });
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      product.isAdded ? Colors.redAccent : primaryColor,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(6),
                  ),
                  padding: EdgeInsets.zero,
                  minimumSize: const Size(82, 40),
                ),
                child: Text(
                  product.isAdded ? 'Remove' : 'Add',
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}