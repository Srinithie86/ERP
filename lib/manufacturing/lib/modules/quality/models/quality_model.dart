class QualityItem {
  final String productName;
  final String productId;
  final String batchId;
  final String productCode;
  final String date;
  final String quantityBadge;

  QualityItem({
    required this.productName,
    required this.productId,
    required this.batchId,
    required this.productCode,
    required this.date,
    required this.quantityBadge,
  });
}

class QualityParameter {
  final String name;
  bool? isPass; // null = none, true = pass, false = fail

  QualityParameter({required this.name, this.isPass});
}
