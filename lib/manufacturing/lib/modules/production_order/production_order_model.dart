import 'package:flutter/material.dart';

class ProductSplit {
  String label;
  int qty;
  String priority;
  DateTime? deadline;

  ProductSplit({
    this.label = '',
    this.qty = 0,
    this.priority = 'High',
    this.deadline,
  });
}

class ProductPlan {
  List<ProductSplit> splits;
  bool done;
  ProductPlan() : splits = [], done = false;
  int get planned => splits.fold(0, (a, s) => a + s.qty);

  DateTime? get earliestDeadline {
    final dates = splits
        .where((s) => s.deadline != null)
        .map((s) => s.deadline!)
        .toList();
    if (dates.isEmpty) return null;
    dates.sort();
    return dates.first;
  }
}

class OrderProduct {
  final String name;
  final String code;
  final int qty;
  final String productId;
  final String bomId;
  final int stockQty;

  OrderProduct({
    required this.name,
    required this.code,
    required this.qty,
    this.productId = '',
    this.bomId = '',
    this.stockQty = 0,
  });

  factory OrderProduct.fromJson(Map<String, dynamic> json) {
    return OrderProduct(
      name: json['product_name']?.toString() ?? 'Unknown Product',
      code: json['product_code']?.toString() ?? '',
      qty: json['quantity'] is int ? json['quantity'] : int.tryParse(json['quantity'].toString()) ?? 0,
      productId: json['product_id']?.toString() ?? '',
      bomId: json['bom_id']?.toString() ?? '',
      stockQty: json['stock_qty'] is int ? json['stock_qty'] : int.tryParse(json['stock_qty']?.toString() ?? '0') ?? 0,
    );
  }
}

class ProductionOrder {
  final int dbId;
  final String id;
  final String customer;
  final String customerId;
  final DateTime? dueDate;
  final String productionType;
  final String priority;
  final String statusLabel;
  final List<OrderProduct> products;
  final List<ProductPlan> planning;

  ProductionOrder({
    required this.dbId,
    required this.id,
    this.customer = '',
    this.customerId = '',
    this.dueDate,
    this.productionType = '',
    this.priority = '',
    this.statusLabel = 'Pending',
    required this.products,
  }) : planning = List.generate(products.length, (_) => ProductPlan());

  factory ProductionOrder.fromJson(Map<String, dynamic> json) {
    final List<dynamic> subData = json['sub_data'] ?? [];
    return ProductionOrder(
      dbId: json['id'] is int ? json['id'] : int.tryParse(json['id'].toString()) ?? 0,
      id: json['order_id']?.toString() ?? '',
      customer: json['cus_name']?.toString() ?? '',
      customerId: (json['cus_id'] ?? json['customer_id'] ?? '').toString(),
      dueDate: json['due_date'] != null ? DateTime.tryParse(json['due_date'].toString()) : null,
      priority: json['prity']?.toString() ?? '',
      productionType: json['product_type']?.toString() ?? '',
      statusLabel: json['status_label']?.toString() ?? 'Pending',
      products: subData.map((e) => OrderProduct.fromJson(e)).toList(),
    );
  }

  int get totalQty => products.fold(0, (a, p) => a + p.qty);
  int get plannedCount => planning.where((p) => p.done).length;
}
class BomItem {
  final String itemCode;
  final String itemName;
  final int qtyPerUnit;
  final int stock;

  const BomItem({
    required this.itemCode,
    required this.itemName,
    required this.qtyPerUnit,
    required this.stock,
  });
}

class BomData {
  final String bomId;
  final String bomLabel;
  final List<BomItem> items;

  const BomData({
    required this.bomId,
    required this.bomLabel,
    required this.items,
  });
}

const List<BomData> kBomRegistry = [
  BomData(
    bomId: '1',
    bomLabel: 'BOM-001 · Steel Frame Assembly',
    items: [
      BomItem(
          itemCode: 'SFA-0001',
          itemName: 'Steel Rod 20mm',
          qtyPerUnit: 10,
          stock: 45),
      BomItem(
          itemCode: 'SFA-0002',
          itemName: 'Corner Bracket',
          qtyPerUnit: 4,
          stock: 20),
      BomItem(
          itemCode: 'SFA-0003',
          itemName: 'Welding Wire 1kg',
          qtyPerUnit: 2,
          stock: 8),
    ],
  ),
  BomData(
    bomId: '2',
    bomLabel: 'BOM-002 · Bolt Set Pack',
    items: [
      BomItem(
          itemCode: 'BSP-0001',
          itemName: 'M8 Bolt x50',
          qtyPerUnit: 50,
          stock: 300),
      BomItem(
          itemCode: 'BSP-0002',
          itemName: 'M8 Nut x50',
          qtyPerUnit: 50,
          stock: 280),
      BomItem(
          itemCode: 'BSP-0003',
          itemName: 'M8 Washer x50',
          qtyPerUnit: 50,
          stock: 500),
    ],
  ),
  BomData(
    bomId: '3',
    bomLabel: 'BOM-003 · Control Panel Unit',
    items: [
      BomItem(
          itemCode: 'CPU-0001',
          itemName: 'MCB 32A',
          qtyPerUnit: 2,
          stock: 15),
      BomItem(
          itemCode: 'CPU-0002',
          itemName: 'RCCB 63A',
          qtyPerUnit: 1,
          stock: 4),
      BomItem(
          itemCode: 'CPU-0003',
          itemName: 'DIN Rail 35mm',
          qtyPerUnit: 3,
          stock: 20),
    ],
  ),
  BomData(
    bomId: '4',
    bomLabel: 'BOM-004 · Wire Harness Kit',
    items: [
      BomItem(
          itemCode: 'WHK-0001',
          itemName: 'DING DONG BELL (GALAXY)',
          qtyPerUnit: 12,
          stock: 0),
      BomItem(
          itemCode: 'WHK-0002',
          itemName: '8M-S METAL BOX',
          qtyPerUnit: 12,
          stock: 178),
    ],
  ),
];

BomData? bomForLabel(String label) {
  try {
    return kBomRegistry.firstWhere((b) => b.bomLabel == label);
  } catch (_) {
    return null;
  }
}

BomData? autoMapBom(int prodIdx, List<OrderProduct> products) {
  final pid = products[prodIdx].productId.toUpperCase();
  if (pid == 'PRD-0001') return kBomRegistry[0];
  if (pid == 'PRD-0002') return kBomRegistry[1];
  if (pid == 'PRD-0003') return kBomRegistry[2];
  if (pid == 'PRD-0004') return kBomRegistry[3];
  if (prodIdx == 0) return kBomRegistry[0];
  return null;
}

Color priorityColor(String p) {
  switch (p) {
    case 'High':
      return Colors.red.shade500;
    case 'Medium':
      return const Color(0xFFF57F17); // _amber equivalent
    default:
      return Colors.green.shade600;
  }
}

class DropdownItem {
  final int id;
  final String value;
  final String label;

  DropdownItem({
    required this.id,
    required this.value,
    required this.label,
  });

  factory DropdownItem.fromJson(Map<String, dynamic> json) {
    return DropdownItem(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id'].toString()) ?? 0,
      value: json['value'].toString(),
      label: json['label'].toString(),
    );
  }
}

class StaffMember {
  final int id;
  final String name;

  StaffMember({required this.id, required this.name});

  factory StaffMember.fromJson(Map<String, dynamic> json) {
    return StaffMember(
      id: json['id'] is int
          ? json['id']
          : int.tryParse(json['id'].toString()) ?? 0,
      name: json['name'].toString(),
    );
  }
}
