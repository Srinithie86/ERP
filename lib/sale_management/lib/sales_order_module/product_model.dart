
class SalesOrderProduct {
  final String id;
  final String name;
  final String imageUrl;
  final int stock;
  final double price;
  final String category;
  final String? categoryId;
  final String? categoryName;
  final String? productCode;
  final String? hsn;
  final String? uom;
  int selectedQty;
  bool isAdded;
  double discountPercentage;
  double discountAmount;
  bool isPercentageDiscount;

  SalesOrderProduct({
    required this.id,
    required this.name,
    this.imageUrl = 'https://picsum.photos/200',
    required this.stock,
    required this.price,
    required this.category,
    this.categoryId,
    this.categoryName,
    this.productCode,
    this.hsn,
    this.uom,
    this.selectedQty = 1,
    this.isAdded = false,
    this.discountPercentage = 0.0,
    this.discountAmount = 0.0,
    this.isPercentageDiscount = true,
  });

  factory SalesOrderProduct.fromJson(Map<String, dynamic> json) {
    // Handle price being potentially null or string/num
    double parsedPrice = 0.0;
    if (json['price'] != null) {
      parsedPrice = double.tryParse(json['price'].toString()) ?? 0.0;
    }

    // Handle stock being potentially null or string/num
    int parsedStock = 0;
    if (json['stock_qty'] != null && json['stock_qty'].toString().isNotEmpty) {
      parsedStock = int.tryParse(json['stock_qty'].toString()) ?? 0;
    }

    return SalesOrderProduct(
      id: json['product_id']?.toString() ?? DateTime.now().millisecondsSinceEpoch.toString(),
      name: json['product_name']?.toString() ?? 'Unknown Product',
      imageUrl: (json['product_image'] != null && json['product_image'].toString().isNotEmpty)
          ? json['product_image'].toString()
          : '',
      stock: parsedStock,
      price: parsedPrice,
      category: json['category_name']?.toString() ?? 'ALL',
      categoryId: json['category_id']?.toString(),
      categoryName: json['category_name']?.toString(),
      uom: json['uom']?.toString(),
      hsn: json['hsn']?.toString(),
    );
  }
}
