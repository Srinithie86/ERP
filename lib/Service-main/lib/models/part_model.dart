class PartModel {
  const PartModel({
    required this.id,
    required this.name,
    required this.category,
    required this.stock,
    required this.minStock,
    required this.unit,
    required this.price,
  });

  final String id;
  final String name;
  final String category;
  final int stock;
  final int minStock;
  final String unit;
  final double price;
}


