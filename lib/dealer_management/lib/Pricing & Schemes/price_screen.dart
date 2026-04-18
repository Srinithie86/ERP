import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

enum PriceView { viewList, viewDetails }

class PriceScreen extends StatefulWidget {
  const PriceScreen({super.key});

  @override
  State<PriceScreen> createState() => _PriceScreenState();
}

class _PriceScreenState extends State<PriceScreen> {
  PriceView _currentView = PriceView.viewList;
  Map<String, dynamic>? _selectedProduct;
  final Color primaryColor = const Color(0xFF26A69A);
  final Color darkBlue = const Color(0xFF1E234E);

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Pre-cache all network images for instant browsing
    for (var product in _products) {
      precacheImage(NetworkImage(product['image']), context);
    }
  }

  final List<Map<String, dynamic>> _products = [
    {
      'id': 'DS-001',
      'name': 'Elegant Evening Gown',
      'category': 'Party Wear',
      'price': 2450.00,
      'rating': 4.8,
      'image': 'https://images.pexels.com/photos/23570884/pexels-photo-23570884.jpeg',
      'description': 'A stunning elegant evening gown perfect for formal occasions. Made with premium silk and features delicate embroidery.',
      'colors': [Colors.black, const Color(0xFF000080), Colors.red],
    },
    {
      'id': 'DS-002',
      'name': 'Casual Summer Dress',
      'category': 'Casual',
      'price': 1250.00,
      'rating': 4.5,
      'image': 'https://images.pexels.com/photos/985635/pexels-photo-985635.jpeg?auto=compress&cs=tinysrgb&w=600',
      'description': 'Lightweight and breathable casual summer dress. Ideal for beach outings and sunny afternoons.',
      'colors': [Colors.white, Colors.yellow, Colors.blue],
    },
    {
      'id': 'DS-003',
      'name': 'Vintage Floral Dress',
      'category': 'Vintage',
      'price': 1850.00,
      'rating': 4.7,
      'image': 'https://images.pexels.com/photos/1040945/pexels-photo-1040945.jpeg?auto=compress&cs=tinysrgb&w=600',
      'description': 'Classic vintage style floral dress. Features a timeless print and a flattering silhouette.',
      'colors': [Colors.pink, Colors.green, Colors.purple],
    },
    {
      'id': 'DS-004',
      'name': 'Chic Cocktail Dress',
      'category': 'Party Wear',
      'price': 2100.00,
      'rating': 4.9,
      'image': 'https://images.pexels.com/photos/8365661/pexels-photo-8365661.jpeg',
      'description': 'A chic and modern cocktail dress for the perfect night out. Designed with high-quality sustainable materials.',
      'colors': [Colors.black, const Color(0xFFC0C0C0), const Color(0xFFFFD700)],
    },
  ];

  String _selectedCategory = 'All';
  final List<String> _categories = ['All', 'Party Wear', 'Casual', 'Vintage', 'Modern'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: _currentView == PriceView.viewList ? _buildListView() : _buildDetailView(),
    );
  }

  Widget _buildListView() {
    return SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(),
          _buildCategoryFilters(),
          Expanded(
            child: _buildProductGrid(),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: Icon(Icons.arrow_back_ios_new_rounded, color: darkBlue, size: 22),
          ),
          Text(
            'Accessories', // Title matching the image reference
            style: GoogleFonts.outfit(fontSize: 20, fontWeight: FontWeight.bold, color: darkBlue),
          ),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: darkBlue,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Badge(
              label: Text('02'),
              child: Icon(Icons.shopping_cart_outlined, color: Colors.white, size: 20),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryFilters() {
    return SizedBox(
      height: 45,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 24),
        itemCount: _categories.length,
        itemBuilder: (context, index) {
          final cat = _categories[index];
          final isSelected = _selectedCategory == cat;
          return Padding(
            padding: const EdgeInsets.only(right: 12),
            child: FilterChip(
              label: Text(cat),
              selected: isSelected,
              onSelected: (val) => setState(() => _selectedCategory = cat),
              backgroundColor: Colors.grey[100],
              selectedColor: darkBlue.withValues(alpha: 0.1),
              checkmarkColor: darkBlue,
              labelStyle: GoogleFonts.outfit(
                color: isSelected ? darkBlue : Colors.grey[600],
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20), side: const BorderSide(color: Colors.transparent)),
            ),
          );
        },
      ),
    );
  }

  Widget _buildProductGrid() {
    final filteredProducts = _selectedCategory == 'All' 
        ? _products 
        : _products.where((p) => p['category'] == _selectedCategory).toList();

    return GridView.builder(
      padding: const EdgeInsets.all(24),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.7,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: filteredProducts.length,
      itemBuilder: (context, index) {
        final product = filteredProducts[index];
        return _buildProductCard(product);
      },
    );
  }

  Widget _buildProductCard(Map<String, dynamic> product) {
    return GestureDetector(
      onTap: () => setState(() {
        _selectedProduct = product;
        _currentView = PriceView.viewDetails;
      }),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 15, offset: const Offset(0, 5))],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Stack(
                children: [
                  Image.network(
                    product['image'],
                    fit: BoxFit.cover,
                    width: double.infinity,
                    height: double.infinity,
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) { return child; }
                      return _buildImagePlaceholder();
                    },
                    errorBuilder: (context, error, stackTrace) => _buildImageError(),
                  ),
                  Positioned(
                    top: 12,
                    right: 12,
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                      child: Icon(Icons.favorite_border, size: 16, color: Colors.grey[400]),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(product['name'], style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 13), maxLines: 1, overflow: TextOverflow.ellipsis),
                  Text(product['category'], style: GoogleFonts.outfit(color: Colors.grey[400], fontSize: 10)),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('\$${product['price']}', style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 14)),
                      const Icon(Icons.add_circle, color: Color(0xFF1E234E), size: 24),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailView() {
    if (_selectedProduct == null) { return const SizedBox(); }
    final p = _selectedProduct!;
    return Column(
      children: [
        Expanded(
          flex: 6,
          child: Stack(
            children: [
              Image.network(
                p['image'],
                width: double.infinity,
                fit: BoxFit.cover,
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) { return child; }
                  return _buildImagePlaceholder();
                },
                errorBuilder: (context, error, stackTrace) => _buildImageError(),
              ),
              Positioned(
                top: 60,
                left: 24,
                child: GestureDetector(
                  onTap: () => setState(() => _currentView = PriceView.viewList),
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                    child: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
                  ),
                ),
              ),
              Positioned(
                top: 60,
                right: 24,
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                  child: const Icon(Icons.favorite_border, size: 18),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          flex: 5,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(32),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(topLeft: Radius.circular(40), topRight: Radius.circular(40)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(color: primaryColor.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12)),
                      child: Text('Best Seller', style: GoogleFonts.outfit(color: primaryColor, fontSize: 12, fontWeight: FontWeight.bold)),
                    ),
                    Row(
                      children: [
                        const Icon(Icons.star, color: Colors.amber, size: 20),
                        const SizedBox(width: 4),
                        Text(p['rating'].toString(), style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 16)),
                        Text(' ( Ratings )', style: GoogleFonts.outfit(color: Colors.grey[400], fontSize: 12)),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Text(p['name'], style: GoogleFonts.outfit(fontSize: 24, fontWeight: FontWeight.bold, color: darkBlue)),
                const SizedBox(height: 12),
                Text(
                  p['description'],
                  style: GoogleFonts.outfit(color: Colors.grey[500], fontSize: 14, height: 1.5),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
                const Spacer(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Price', style: GoogleFonts.outfit(color: Colors.grey[400], fontSize: 12)),
                        Text('\$${p['price']}', style: GoogleFonts.outfit(fontSize: 24, fontWeight: FontWeight.bold, color: darkBlue)),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(color: darkBlue, borderRadius: BorderRadius.circular(20)),
                      child: const Icon(Icons.shopping_bag_outlined, color: Colors.white),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
  Widget _buildImagePlaceholder() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(24),
      ),
      child: Center(
        child: SizedBox(
          width: 20,
          height: 20,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            valueColor: AlwaysStoppedAnimation<Color>(darkBlue.withValues(alpha: 0.2)),
          ),
        ),
      ),
    );
  }

  Widget _buildImageError() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(24),
      ),
      child: Icon(Icons.inventory_2_outlined, color: Colors.grey[300], size: 32),
    );
  }
}
