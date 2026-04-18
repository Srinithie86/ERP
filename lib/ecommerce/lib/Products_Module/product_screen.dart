// ════════════════════════════════════════════════════
//  product_screen.dart
//  Products Module — List screen + Detail screen
//  Style matches Ecommerce Workplace Dashboard
// ════════════════════════════════════════════════════
import 'package:flutter/material.dart';
import '../Theme_Module/colors_and_models.dart';
import '../Dashboard_Module/drawer_screen.dart';

// ═══════════════════════════════════════════
//  PRODUCT STATUS
// ═══════════════════════════════════════════
enum ProductStatus { pending, approved, rejected }

extension ProductStatusX on ProductStatus {
  String get label {
    switch (this) {
      case ProductStatus.pending:  return 'Pending';
      case ProductStatus.approved: return 'Approved';
      case ProductStatus.rejected: return 'Rejected';
    }
  }

  Color get color {
    switch (this) {
      case ProductStatus.pending:  return C.orange;
      case ProductStatus.approved: return C.green;
      case ProductStatus.rejected: return C.red;
    }
  }

  Color get bgColor {
    switch (this) {
      case ProductStatus.pending:  return C.orangeLight;
      case ProductStatus.approved: return C.greenLight;
      case ProductStatus.rejected: return C.redLight;
    }
  }

  IconData get icon {
    switch (this) {
      case ProductStatus.pending:  return Icons.hourglass_top_rounded;
      case ProductStatus.approved: return Icons.check_circle_rounded;
      case ProductStatus.rejected: return Icons.cancel_rounded;
    }
  }
}

// ═══════════════════════════════════════════
//  PRODUCT MODEL
// ═══════════════════════════════════════════
class ProductItem {
  final String        id;
  final String        name;
  final String        category;
  final String        description;
  final int           price;
  final int           stock;
  final String        sku;
  final String        brand;
  final List<String>  variants;
  final List<String>  tags;
  final List<String>  images;
  ProductStatus       status;

  ProductItem({
    required this.id,
    required this.name,
    required this.category,
    required this.description,
    required this.price,
    required this.stock,
    required this.sku,
    required this.brand,
    required this.variants,
    required this.tags,
    required this.images,
    this.status = ProductStatus.pending,
  });
}

// ═══════════════════════════════════════════
//  CATEGORY → COLOR MAP
// ═══════════════════════════════════════════
const Map<String, List<Color>> kProdCatColors = {
  'Clothing':    [Color(0xFFFEF3C7), C.orange],
  'Electronics': [C.blueLight,       C.blue],
  'Accessories': [C.purpleLight,     C.purple],
  'Footwear':    [C.primaryLight,    C.primary],
  'Sports':      [C.greenLight,      C.green],
};

List<Color> prodCatColors(String cat) =>
    kProdCatColors[cat] ?? [C.primaryLight, C.primary];

// ═══════════════════════════════════════════
//  SAMPLE PRODUCTS
// ═══════════════════════════════════════════
List<ProductItem> buildSampleProducts() => [
  ProductItem(
    id: '#PRD-1001',
    name: 'Premium Cotton T-Shirt',
    category: 'Clothing',
    description:
    'High-quality 100% cotton t-shirt with a soft finish. Breathable fabric ideal for everyday wear. Pre-shrunk to maintain shape after washing.',
    price: 500, stock: 120, sku: 'CLT-TSH-001', brand: 'StyleCo',
    variants: ['Size: S', 'Size: M', 'Size: L', 'Size: XL'],
    tags: ['cotton', 'casual', 'unisex'],
    images: [
      'assets/product/product1_a.jpg',
      'assets/product/product1_b.jpg',
      'assets/product/product1_c.webp',
    ],
    status: ProductStatus.approved,
  ),
  ProductItem(
    id: '#PRD-1002',
    name: 'Wireless Earbuds Pro',
    category: 'Electronics',
    description:
    'True wireless earbuds with active noise cancellation, 24-hour battery life, and IPX5 water resistance. Seamless Bluetooth 5.2 connectivity.',
    price: 1500, stock: 45, sku: 'ELC-EAR-002', brand: 'SoundMax',
    variants: ['Color: Black', 'Color: White', 'Color: Blue'],
    tags: ['wireless', 'noise-cancel', 'bluetooth'],
    images: [
      'assets/product/product2_a.jpg',
      'assets/product/product2_b.jpg',
      'assets/product/product2_c.jpg',
    ],
    status: ProductStatus.pending,
  ),
  ProductItem(
    id: '#PRD-1003',
    name: 'Leather Wallet Classic',
    category: 'Accessories',
    description:
    'Genuine leather bi-fold wallet with RFID blocking technology. Features 6 card slots, 2 bill compartments, and a slim profile design.',
    price: 600, stock: 80, sku: 'ACC-WAL-003', brand: 'LeatherCraft',
    variants: ['Color: Brown', 'Color: Black', 'Color: Red'],
    tags: ['leather', 'rfid', 'slim'],
    images: [
      'assets/product/product3_a.avif',
      'assets/product/product3_b.jpg',
      'assets/product/product3_c.jpg',
    ],
    status: ProductStatus.approved,
  ),
  ProductItem(
    id: '#PRD-1004',
    name: 'Running Sneakers',
    category: 'Footwear',
    description:
    'Lightweight running shoes with responsive foam cushioning and breathable mesh upper. Ideal for road running and gym workouts.',
    price: 2200, stock: 60, sku: 'FTW-SNK-004', brand: 'StridePro',
    variants: ['Size: 7', 'Size: 8', 'Size: 9', 'Size: 10', 'Size: 11'],
    tags: ['running', 'lightweight', 'breathable'],
    images: [
      'assets/product/product4_a.jpg',
      'assets/product/product4_a.webp',
      'assets/product/product4_c.avif',
    ],
    status: ProductStatus.pending,
  ),
  ProductItem(
    id: '#PRD-1005',
    name: 'Smart Watch Series 5',
    category: 'Electronics',
    description:
    'Advanced smartwatch with health monitoring, GPS tracking, and a 1.9-inch AMOLED display. 7-day battery life with fast charging support.',
    price: 3800, stock: 30, sku: 'ELC-WTC-005', brand: 'TechWear',
    variants: ['Color: Black', 'Color: Silver', 'Color: Gold'],
    tags: ['smartwatch', 'gps', 'health'],
    images: [
      'assets/product/product5_a.jpg',
      'assets/product/product5_b.jpg',
      'assets/product/product5_c.png',
    ],
    status: ProductStatus.rejected,
  ),
  ProductItem(
    id: '#PRD-1006',
    name: 'Yoga Mat Premium',
    category: 'Sports',
    description:
    'Extra-thick 6mm yoga mat with non-slip surface and alignment lines. Made from eco-friendly TPE material. Includes carry strap.',
    price: 850, stock: 95, sku: 'SPT-YGA-006', brand: 'FlexFit',
    variants: ['Color: Blue', 'Color: Green', 'Color: Pink'],
    tags: ['yoga', 'eco', 'non-slip'],
    images: [
      'assets/product/product6_a.jpg',
      'assets/product/product6_b.jpg',
      'assets/product/product6_c.webp',
    ],
    status: ProductStatus.approved,
  ),
  ProductItem(
    id: '#PRD-1007',
    name: 'Denim Jacket Classic',
    category: 'Clothing',
    description:
    'Timeless denim jacket crafted from premium stretch denim. Features button closure, chest pockets, and a relaxed fit for all-day comfort.',
    price: 1200, stock: 55, sku: 'CLT-JKT-007', brand: 'StyleCo',
    variants: ['Size: S', 'Size: M', 'Size: L', 'Size: XL'],
    tags: ['denim', 'jacket', 'casual'],
    images: [
      'assets/product/product7_a.jpeg',
      'assets/product/product7_b.webp',
      'assets/product/product7_c.avif',
    ],
    status: ProductStatus.pending,
  ),
  ProductItem(
    id: '#PRD-1008',
    name: 'Resistance Band Set',
    category: 'Sports',
    description:
    'Set of 5 resistance bands with varying tension levels (10–50 lbs). Made from latex-free elastic. Includes carry bag and exercise guide.',
    price: 450, stock: 140, sku: 'SPT-RBD-008', brand: 'FlexFit',
    variants: ['Set of 3', 'Set of 5'],
    tags: ['resistance', 'workout', 'home-gym'],
    images: [
      'assets/product/product8_a.jpg',
      'assets/product/product8_b.jpg',
      'assets/product/product8_c.jpg',
    ],
    status: ProductStatus.approved,
  ),
];

// ═══════════════════════════════════════════
//  PRODUCTS SCREEN  (list)
// ═══════════════════════════════════════════
class ProductsScreen extends StatefulWidget {
  const ProductsScreen({super.key});
  @override State<ProductsScreen> createState() => _ProductsScreenState();
}

class _ProductsScreenState extends State<ProductsScreen> {
  static const _filters = ['All', 'Pending', 'Approved', 'Rejected'];
  int    _filterIdx = 0;
  String _search    = '';
  late List<ProductItem> _products;

  @override
  void initState() {
    super.initState();
    _products = buildSampleProducts();
  }

  String get _active => _filters[_filterIdx];

  List<ProductItem> get _filtered => _products.where((p) {
    final matchFilter = _active == 'All' || p.status.label == _active;
    final q           = _search.toLowerCase();
    final matchSearch = q.isEmpty ||
        p.name.toLowerCase().contains(q) ||
        p.category.toLowerCase().contains(q) ||
        p.id.toLowerCase().contains(q);
    return matchFilter && matchSearch;
  }).toList();

  int _countFor(String f) => f == 'All'
      ? _products.length
      : _products.where((p) => p.status.label == f).length;

  Color _chipColor(String f) {
    switch (f) {
      case 'Pending':  return C.orange;
      case 'Approved': return C.green;
      case 'Rejected': return C.red;
      default:         return C.primary;
    }
  }

  void _onStatusChanged(ProductItem product, ProductStatus status) {
    setState(() => product.status = status);
  }

  @override
  Widget build(BuildContext context) {
    final list = _filtered;
    return Scaffold(
      backgroundColor: C.bg,
      drawer: const EcomDrawer(),
      appBar: const EcomAppBar(),
      body: Column(children: [

        // ── Filter chips ──
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: List.generate(_filters.length, (i) {
              final sel   = _filterIdx == i;
              final name  = _filters[i];
              final cnt   = _countFor(name);
              final color = _chipColor(name);
              return GestureDetector(
                onTap: () => setState(() => _filterIdx = i),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  margin: const EdgeInsets.only(right: 8),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: sel ? (name == 'All' ? C.primary : color) : C.card,
                    borderRadius: BorderRadius.circular(22),
                    boxShadow: sel
                        ? [BoxShadow(
                        color: (name == 'All' ? C.primary : color).withValues(alpha: 0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 3))]
                        : [],
                  ),
                  child: Row(children: [
                    Text(name,
                        style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: sel ? Colors.white : C.textMid)),
                    const SizedBox(width: 5),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                      decoration: BoxDecoration(
                        color: sel ? Colors.white.withValues(alpha: 0.25) : C.bg,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text('$cnt',
                          style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w800,
                              color: sel ? Colors.white : C.textMid)),
                    ),
                  ]),
                ),
              );
            }),
          ),
        ),

        // ── Search ──
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Container(
            decoration: kCard(),
            child: TextField(
              onChanged: (v) => setState(() => _search = v),
              decoration: const InputDecoration(
                hintText: 'Search products…',
                hintStyle: TextStyle(color: C.textLight, fontSize: 14),
                prefixIcon: Icon(Icons.search_rounded, color: C.textLight),
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(vertical: 14),
              ),
            ),
          ),
        ),
        const SizedBox(height: 10),

        // ── Active filter label ──
        if (_active != 'All')
          Padding(
            padding: const EdgeInsets.only(left: 16, right: 16, bottom: 6),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                decoration: BoxDecoration(
                  color: _chipColor(_active).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: _chipColor(_active).withValues(alpha: 0.3)),
                ),
                child: Row(mainAxisSize: MainAxisSize.min, children: [
                  Container(
                    width: 7, height: 7,
                    decoration: BoxDecoration(
                        color: _chipColor(_active), shape: BoxShape.circle),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    '$_active products  ·  ${list.length} found',
                    style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: _chipColor(_active)),
                  ),
                ]),
              ),
            ),
          ),

        // ── Product list ──
        Expanded(
          child: list.isEmpty
              ? _EmptyState(filter: _active)
              : ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            itemCount: list.length,
            itemBuilder: (_, i) => _ProductCard(
              product: list[i],
              onViewDetails: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ProductDetailScreen(
                      product: list[i],
                      onStatusChanged: (s) =>
                          _onStatusChanged(list[i], s),
                    ),
                  ),
                );
                setState(() {});
              },
            ),
          ),
        ),
      ]),
    );
  }
}

// ═══════════════════════════════════════════
//  PRODUCT CARD  (list item)
// ═══════════════════════════════════════════
class _ProductCard extends StatelessWidget {
  final ProductItem  product;
  final VoidCallback onViewDetails;
  const _ProductCard({required this.product, required this.onViewDetails});

  @override
  Widget build(BuildContext context) {
    final cc = prodCatColors(product.category);
    final ps = product.status;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: C.card,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: C.border),
        boxShadow: [BoxShadow(
          color: Colors.black.withValues(alpha: 0.04),
          blurRadius: 8,
          offset: const Offset(0, 3),
        )],
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(children: [

          // ── Top row ──
          Row(children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(13),
              child: Image.asset(
                product.images.first,
                width: 48, height: 48,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  width: 48, height: 48,
                  decoration: BoxDecoration(
                      color: cc[0], borderRadius: BorderRadius.circular(13)),
                  child: Icon(Icons.inventory_2_rounded, color: cc[1], size: 24),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(product.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                        fontSize: 14, fontWeight: FontWeight.w800, color: C.textDark)),
                const SizedBox(height: 3),
                _CatPill(product.category, cc[0], cc[1]),
              ]),
            ),
            const SizedBox(width: 8),
            Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
              Text('₹${product.price}',
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.w800, color: C.textDark)),
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
                decoration: BoxDecoration(
                    color: ps.bgColor, borderRadius: BorderRadius.circular(20)),
                child: Text(ps.label,
                    style: TextStyle(
                        fontSize: 10, fontWeight: FontWeight.w700, color: ps.color)),
              ),
            ]),
          ]),

          const SizedBox(height: 10),
          const Divider(height: 1, color: C.border),
          const SizedBox(height: 10),

          // ── Bottom row ──
          Row(children: [
            const Icon(Icons.tag_rounded, size: 11, color: C.textLight),
            const SizedBox(width: 4),
            Text(product.id,
                style: const TextStyle(fontSize: 11, color: C.textLight)),
            const SizedBox(width: 14),
            const Icon(Icons.layers_rounded, size: 11, color: C.textLight),
            const SizedBox(width: 4),
            Text('${product.stock} in stock',
                style: const TextStyle(fontSize: 11, color: C.textLight)),
            const Spacer(),
            GestureDetector(
              onTap: onViewDetails,
              child: Row(children: [
                Text('View Details',
                    style: TextStyle(
                        fontSize: 12, fontWeight: FontWeight.w700, color: C.primary)),
                const SizedBox(width: 3),
                Icon(Icons.arrow_forward_rounded, size: 13, color: C.primary),
              ]),
            ),
          ]),
        ]),
      ),
    );
  }
}

// ═══════════════════════════════════════════
//  IMAGE SLIDER WIDGET
// ═══════════════════════════════════════════
class _ImageSlider extends StatefulWidget {
  final List<String> images;
  final List<Color>  catColors;
  const _ImageSlider({required this.images, required this.catColors});

  @override
  State<_ImageSlider> createState() => _ImageSliderState();
}

class _ImageSliderState extends State<_ImageSlider> {
  final PageController _ctrl = PageController();
  int _current = 0;

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 280,
      child: Stack(children: [

        // ── PageView ──
        PageView.builder(
          controller: _ctrl,
          itemCount: widget.images.length,
          onPageChanged: (i) => setState(() => _current = i),
          itemBuilder: (_, i) => Image.asset(
            widget.images[i],
            fit: BoxFit.cover,
            width: double.infinity,
            errorBuilder: (_, __, ___) => Container(
              color: widget.catColors[0],
              child: Center(
                child: Icon(Icons.inventory_2_rounded,
                    color: widget.catColors[1], size: 64),
              ),
            ),
          ),
        ),

        // ── Dot indicators ──
        Positioned(
          bottom: 14, left: 0, right: 0,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(widget.images.length, (i) {
              final active = i == _current;
              return AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                margin: const EdgeInsets.symmetric(horizontal: 4),
                width:  active ? 22 : 8,
                height: 8,
                decoration: BoxDecoration(
                  color: active ? Colors.white : Colors.white.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(8),
                ),
              );
            }),
          ),
        ),

        // ── Image counter badge ──
        Positioned(
          top: 12, right: 12,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.45),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              '${_current + 1} / ${widget.images.length}',
              style: const TextStyle(
                  fontSize: 11, fontWeight: FontWeight.w700, color: Colors.white),
            ),
          ),
        ),
      ]),
    );
  }
}

// ═══════════════════════════════════════════
//  PRODUCT DETAIL SCREEN
// ═══════════════════════════════════════════
class ProductDetailScreen extends StatefulWidget {
  final ProductItem                 product;
  final ValueChanged<ProductStatus> onStatusChanged;

  const ProductDetailScreen({
    super.key,
    required this.product,
    required this.onStatusChanged,
  });

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  late ProductStatus _status;

  @override
  void initState() {
    super.initState();
    _status = widget.product.status;
  }

  ProductItem get p => widget.product;

  void _changeStatus(ProductStatus s) {
    setState(() => _status = s);
    widget.onStatusChanged(s);
  }

  // ═══════════════════════════════════════════
  //  REJECT DIALOG
  // ═══════════════════════════════════════════
  void _showRejectDialog() {
    final TextEditingController reasonCtrl = TextEditingController();

    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFFF0F0F5),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        contentPadding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
        actionsPadding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
        title: const Text(
          'Reject Product',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w900,
            color: C.textDark,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Rejecting: "${p.name}"',
              style: const TextStyle(fontSize: 14, color: C.textMid),
            ),
            const SizedBox(height: 16),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
              ),
              child: TextField(
                controller: reasonCtrl,
                maxLines: 4,
                decoration: const InputDecoration(
                  hintText: 'Enter rejection reason…',
                  hintStyle: TextStyle(color: C.textLight, fontSize: 14),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.all(14),
                ),
              ),
            ),
          ],
        ),
        actions: [
          Row(children: [
            Expanded(
              child: TextButton(
                onPressed: () => Navigator.pop(ctx),
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                ),
                child: const Text(
                  'Cancel',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: C.textMid,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(ctx);
                  _changeStatus(ProductStatus.rejected);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: C.red,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  elevation: 0,
                ),
                child: const Text(
                  'Reject',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ]),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════
  //  APPROVE SNACKBAR
  // ═══════════════════════════════════════════
  void _showApproveSnackbar() {
    _changeStatus(ProductStatus.approved);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        backgroundColor: Colors.transparent,
        elevation: 0,
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        duration: const Duration(seconds: 3),
        content: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: C.green,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: C.green.withValues(alpha: 0.35),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(children: [
            Container(
              width: 36, height: 36,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.25),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.check_circle_rounded,
                color: Colors.white,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Product Approved!',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    '"${p.name}" has been approved.',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.white.withValues(alpha: 0.85),
                    ),
                  ),
                ],
              ),
            ),
          ]),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cc = prodCatColors(p.category);

    return Scaffold(
      backgroundColor: C.bg,
      body: CustomScrollView(
        slivers: [

          // ── SliverAppBar with Image Slider ──
          SliverAppBar(
            expandedHeight: 280,
            pinned: true,
            backgroundColor: C.primary,
            leading: GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                margin: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(10)),
                child: const Icon(Icons.arrow_back_ios_new_rounded,
                    color: Colors.white, size: 18),
              ),
            ),
            flexibleSpace: FlexibleSpaceBar(
              collapseMode: CollapseMode.pin,
              background: Stack(
                fit: StackFit.expand,
                children: [

                  // Image Slider
                  _ImageSlider(images: p.images, catColors: cc),

                  // Gradient overlay
                  Positioned(
                    left: 0, right: 0, bottom: 0,
                    child: Container(
                      height: 90,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.bottomCenter,
                          end: Alignment.topCenter,
                          colors: [
                            Colors.black.withValues(alpha: 0.65),
                            Colors.transparent,
                          ],
                        ),
                      ),
                    ),
                  ),

                  // Product name + category
                  Positioned(
                    left: 16, right: 16, bottom: 30,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          p.name,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                              color: Colors.white),
                        ),
                        const SizedBox(height: 6),
                        _CatPillWhite(p.category),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ── Body ──
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  // Price + Status
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: C.border),
                      boxShadow: [BoxShadow(
                          color: Colors.black.withValues(alpha: 0.04),
                          blurRadius: 8, offset: const Offset(0, 3))],
                    ),
                    child: Row(children: [
                      Expanded(
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Price',
                                  style: TextStyle(fontSize: 11, color: C.textLight)),
                              const SizedBox(height: 4),
                              Text('₹${p.price}',
                                  style: const TextStyle(
                                      fontSize: 22,
                                      fontWeight: FontWeight.w900,
                                      color: C.textDark)),
                            ]),
                      ),
                      Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                        const Text('Status',
                            style: TextStyle(fontSize: 11, color: C.textLight)),
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 5),
                          decoration: BoxDecoration(
                              color: _status.bgColor,
                              borderRadius: BorderRadius.circular(20)),
                          child: Row(mainAxisSize: MainAxisSize.min, children: [
                            Icon(_status.icon, size: 12, color: _status.color),
                            const SizedBox(width: 5),
                            Text(_status.label,
                                style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                    color: _status.color)),
                          ]),
                        ),
                      ]),
                    ]),
                  ),
                  const SizedBox(height: 12),

                  // Info grid
                  Row(children: [
                    Expanded(child: _InfoCard(
                        icon: Icons.tag_rounded,
                        label: 'Product ID', value: p.id)),
                    const SizedBox(width: 10),
                    Expanded(child: _InfoCard(
                        icon: Icons.qr_code_rounded,
                        label: 'SKU', value: p.sku)),
                  ]),
                  const SizedBox(height: 10),
                  Row(children: [
                    Expanded(child: _InfoCard(
                        icon: Icons.business_rounded,
                        label: 'Brand', value: p.brand)),
                    const SizedBox(width: 10),
                    Expanded(child: _InfoCard(
                        icon: Icons.warehouse_rounded,
                        label: 'Stock', value: '${p.stock} units')),
                  ]),
                  const SizedBox(height: 12),

                  // Description
                  _SectionCard(
                    title: 'Description',
                    icon: Icons.description_rounded,
                    child: Text(p.description,
                        style: const TextStyle(
                            fontSize: 13, color: C.textMid, height: 1.6)),
                  ),
                  const SizedBox(height: 12),

                  // Variants
                  _SectionCard(
                    title: 'Variants',
                    icon: Icons.tune_rounded,
                    child: Wrap(
                      spacing: 8, runSpacing: 8,
                      children: p.variants.map((v) => Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: C.bg,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: C.border),
                        ),
                        child: Text(v,
                            style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: C.textDark)),
                      )).toList(),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Tags
                  _SectionCard(
                    title: 'Tags',
                    icon: Icons.label_rounded,
                    child: Wrap(
                      spacing: 8, runSpacing: 8,
                      children: p.tags.map((t) => Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: C.primaryLight,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text('#$t',
                            style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: C.primary)),
                      )).toList(),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // ── Product Action ──
                  const Text('Product Action',
                      style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: C.textMid,
                          letterSpacing: 0.4)),
                  const SizedBox(height: 10),
                  Row(children: [

                    // Approve Button
                    Expanded(
                      child: GestureDetector(
                        onTap: _showApproveSnackbar,  // ← Snackbar
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 180),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          decoration: BoxDecoration(
                            color: _status == ProductStatus.approved
                                ? C.green : C.greenLight,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: _status == ProductStatus.approved
                                  ? C.green : C.green.withValues(alpha: 0.3),
                              width: _status == ProductStatus.approved ? 1.5 : 1,
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.check_circle_outline_rounded,
                                  size: 18,
                                  color: _status == ProductStatus.approved
                                      ? Colors.white : C.green),
                              const SizedBox(width: 6),
                              Text('Approve',
                                  style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w700,
                                      color: _status == ProductStatus.approved
                                          ? Colors.white : C.green)),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),

                    // Reject Button
                    Expanded(
                      child: GestureDetector(
                        onTap: _showRejectDialog,  // ← Dialog
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 180),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          decoration: BoxDecoration(
                            color: _status == ProductStatus.rejected
                                ? C.red : C.redLight,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: _status == ProductStatus.rejected
                                  ? C.red : C.red.withValues(alpha: 0.3),
                              width: _status == ProductStatus.rejected ? 1.5 : 1,
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.cancel_outlined,
                                  size: 18,
                                  color: _status == ProductStatus.rejected
                                      ? Colors.white : C.red),
                              const SizedBox(width: 6),
                              Text('Reject',
                                  style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w700,
                                      color: _status == ProductStatus.rejected
                                          ? Colors.white : C.red)),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ]),
                  const SizedBox(height: 30),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════
//  REUSABLE WIDGETS
// ═══════════════════════════════════════════
class _InfoCard extends StatelessWidget {
  final IconData icon;
  final String   label, value;
  const _InfoCard({required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(13),
      border: Border.all(color: C.border),
    ),
    child: Row(children: [
      Container(
        width: 32, height: 32,
        decoration: BoxDecoration(
            color: C.primaryLight, borderRadius: BorderRadius.circular(8)),
        child: Icon(icon, size: 16, color: C.primary),
      ),
      const SizedBox(width: 10),
      Expanded(
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(label,
              style: const TextStyle(fontSize: 10, color: C.textLight)),
          const SizedBox(height: 2),
          Text(value,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                  fontSize: 12, fontWeight: FontWeight.w700, color: C.textDark)),
        ]),
      ),
    ]),
  );
}

class _SectionCard extends StatelessWidget {
  final String   title;
  final IconData icon;
  final Widget   child;
  const _SectionCard({required this.title, required this.icon, required this.child});

  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity,
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: C.border),
      boxShadow: [BoxShadow(
          color: Colors.black.withValues(alpha: 0.04),
          blurRadius: 8, offset: const Offset(0, 3))],
    ),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [
        Icon(icon, size: 14, color: C.primary),
        const SizedBox(width: 6),
        Text(title,
            style: const TextStyle(
                fontSize: 13, fontWeight: FontWeight.w700, color: C.textDark)),
      ]),
      const SizedBox(height: 10),
      child,
    ]),
  );
}

class _CatPill extends StatelessWidget {
  final String label;
  final Color  bg, fg;
  const _CatPill(this.label, this.bg, this.fg);

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
    decoration: BoxDecoration(
        color: bg, borderRadius: BorderRadius.circular(20)),
    child: Text(label,
        style: TextStyle(
            fontSize: 10, fontWeight: FontWeight.w600, color: fg)),
  );
}

class _CatPillWhite extends StatelessWidget {
  final String label;
  const _CatPillWhite(this.label);

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
    decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.25),
        borderRadius: BorderRadius.circular(20)),
    child: Text(label,
        style: const TextStyle(
            fontSize: 11, fontWeight: FontWeight.w600, color: Colors.white)),
  );
}

// ═══════════════════════════════════════════
//  EMPTY STATE
// ═══════════════════════════════════════════
class _EmptyState extends StatelessWidget {
  final String filter;
  const _EmptyState({required this.filter});

  @override
  Widget build(BuildContext context) => Center(
    child: Column(mainAxisSize: MainAxisSize.min, children: [
      Container(
        width: 72, height: 72,
        decoration: BoxDecoration(
            color: C.bg, borderRadius: BorderRadius.circular(24)),
        child: const Icon(Icons.inventory_2_rounded,
            size: 36, color: C.textLight),
      ),
      const SizedBox(height: 16),
      Text('No $filter products',
          style: const TextStyle(
              fontSize: 16, fontWeight: FontWeight.w700, color: C.textDark)),
      const SizedBox(height: 6),
      Text('No products with "$filter" status.',
          textAlign: TextAlign.center,
          style: const TextStyle(
              fontSize: 13, color: C.textMid, height: 1.5)),
    ]),
  );
}