import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../widgets/app_drawer.dart';
import 'payment_screen.dart';
import 'product_model.dart';

class DeliveryChallanCatalogScreen extends StatefulWidget {
  final String taxType;
  final String priceType;
  final Map<String, dynamic>? selectedCustomer;

  const DeliveryChallanCatalogScreen({
    super.key,
    this.taxType = 'IGST',
    this.priceType = 'Exclude tax',
    this.selectedCustomer,
  });

  @override
  State<DeliveryChallanCatalogScreen> createState() => _DeliveryChallanCatalogScreenState();
}

class _DeliveryChallanCatalogScreenState extends State<DeliveryChallanCatalogScreen> {
  final Color primaryColor = const Color(0xFF26A69A);
  String _selectedCategory = 'ALL';
  String _searchQuery = '';

  List<String> _categories = ['ALL'];

  List<DeliveryChallanProduct> _products = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchProducts();
  }

  Future<void> _fetchProducts() async {
    setState(() => _isLoading = true);
    final prefs = await SharedPreferences.getInstance();
    final cid = prefs.getString('cid') ?? '44555666';
    final lt = prefs.getString('lt') ?? '123';
    final ln = prefs.getString('ln') ?? '123';
    final deviceId = prefs.getString('device_id') ?? '123';

    const url = 'https://erpsmart.in/total/api/m_api/';
    final body = {
      'type': '2083',
      'cid': cid,
      'lt': lt,
      'ln': ln,
      'device_id': deviceId,
      'form': 'sm_main_form_10106',
      'select': '*',
    };

    try {
      final response = await http.post(Uri.parse(url), body: body);
      final jsonResponse = json.decode(response.body);

      if (jsonResponse['error'] == false) {
        final List data = jsonResponse['data'] ?? [];
        setState(() {
          _products = data.map((item) {
            return DeliveryChallanProduct(
              id: item['id']?.toString() ?? '0',
              name: item['product_name'] ?? 'Unknown Product',
              stock: int.tryParse(item['stock_qty']?.toString() ?? '0') ?? 0,
              price: double.tryParse(item['price']?.toString() ?? '0.0') ?? 0.0,
              category: item['category']?.toString() ?? 'General',
              productCode: item['product_code'] ?? '',
              uom: item['uom']?.toString() ?? '',
              hsnCode: item['hsn_sac_code']?.toString() ?? '',
              taxRate: double.tryParse(item['tax_rate']?.toString() ?? '0') ?? 0.0,
            );
          }).toList();

          final cats = _products.map((p) => p.category).where((c) => c.isNotEmpty).toSet().toList();
          cats.sort();
          _categories = ['ALL', ...cats];
        });
      }
    } catch (e) {
      debugPrint("❌ DeliveryChallanCatalogScreen => FETCH ERROR: $e");
    } finally {
      setState(() => _isLoading = false);
    }
  }

  List<DeliveryChallanProduct> get _filteredProducts {
    List<DeliveryChallanProduct> result = _products;
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
  double get _totalAmount => _products
      .where((p) => p.isAdded)
      .fold(0, (sum, p) => sum + (p.isPercentageDiscount
          ? (p.price * (1 - p.discountPercentage / 100) * p.selectedQty)
          : ((p.price - p.discountAmount) * p.selectedQty)));

  double get _totalDiscount => _products
      .where((p) => p.isAdded)
      .fold(0, (sum, p) => sum + (p.isPercentageDiscount
          ? (p.price * (p.discountPercentage / 100) * p.selectedQty)
          : (p.discountAmount * p.selectedQty)));

  void _showDiscountBottomSheet(DeliveryChallanProduct product) {
    bool localIsPercentage = product.isPercentageDiscount;
    final TextEditingController discountCtrl = TextEditingController(
        text: localIsPercentage
            ? (product.discountPercentage > 0 ? product.discountPercentage.toString() : '')
            : (product.discountAmount > 0 ? product.discountAmount.toString() : ''));

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
                const Text(
                  'Discount in',
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
                            localIsPercentage ? Icons.radio_button_checked : Icons.radio_button_off,
                            color: primaryColor,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '%',
                            style: TextStyle(
                              color: localIsPercentage ? primaryColor : Colors.grey,
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
                            !localIsPercentage ? Icons.radio_button_checked : Icons.radio_button_off,
                            color: primaryColor,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '₹',
                            style: TextStyle(
                              color: !localIsPercentage ? primaryColor : Colors.grey,
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
                  localIsPercentage ? 'Percentage' : 'Amount (₹)',
                  style: const TextStyle(
                    color: Color(0xFF90A4AE),
                    fontSize: 12,
                    fontFamily: 'Poppins',
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: discountCtrl,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  autofocus: true,
                  style: const TextStyle(color: Color(0xFF1A2332), fontSize: 16),
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: const Color(0xFFF5F7FA),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(color: primaryColor.withOpacity(0.3)),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(color: primaryColor.withOpacity(0.3)),
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
                            'Total Amount',
                            style: TextStyle(color: primaryColor, fontWeight: FontWeight.w600),
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
                      final double? discount = double.tryParse(discountCtrl.text);
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
                    child: const Text(
                      'Continue',
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
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Delivery Challan',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      drawer: const AppDrawer(),
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
                            hintText: 'Search inventory catalog...',
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
                            color: isSelected ? primaryColor : const Color(0xFFB2DFDB),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            category,
                            style: TextStyle(
                              color: isSelected ? Colors.white : const Color(0xFF00695C),
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
                const Text(
                  'Avaliable Products',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                ),
                Text(
                  'Showing ${_filteredProducts.length} items',
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                ),
              ],
            ),
          ),

          // Product List
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _products.isEmpty
                    ? const Center(child: Text("No products found"))
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _filteredProducts.length,
              itemBuilder: (context, index) {
                final product = _filteredProducts[index];
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
                                  '${product.stock} IN STOCK',
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
                                      const Icon(Icons.local_offer, size: 14, color: Colors.green),
                                      const SizedBox(width: 4),
                                      Text(
                                        product.isPercentageDiscount
                                            ? (product.discountPercentage > 0
                                                ? 'Discount: ${product.discountPercentage}%'
                                                : 'Add Discount')
                                            : (product.discountAmount > 0
                                                ? 'Discount: ₹${product.discountAmount}'
                                                : 'Add Discount'),
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
                              backgroundColor: product.isAdded
                                  ? Colors.redAccent
                                  : primaryColor,
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
              },
            ),
          ),

          // Persistent Bottom Panel
          if (_totalItems > 0)
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
                          'Item : $_totalItems | Qty : $_totalQty',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Poppins',
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Disc : ₹${_totalDiscount.toInt()} | Amount : ${_totalAmount.toInt()}',
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
                            builder: (_) => DeliveryChallanPaymentScreen(
                              totalAmount: _totalAmount,
                              selectedProducts: _products.where((p) => p.isAdded).toList(),
                              taxType: widget.taxType,
                              priceType: widget.priceType,
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
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'Continue',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          SizedBox(width: 4),
                          Icon(Icons.chevron_right, size: 18),
                        ],
                      ),
                    ),                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}