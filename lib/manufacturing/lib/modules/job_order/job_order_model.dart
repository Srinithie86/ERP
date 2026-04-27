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
  String name;
  int qty;
  String productId;
  String bomId;
  OrderProduct({
    required this.name,
    required this.qty,
    this.productId = '',
    this.bomId = '',
  });
}

class JobOrder {
  final String id;
  final String customer;
  final DateTime deliveryDate;
  final DateTime? dueDate;
  final String productionType;
  final String priority;
  final String assignedTo;
  String status;
  final List<OrderProduct> products;
  final List<ProductPlan> planning;

  JobOrder({
    required this.id,
    this.customer = '',
    required this.deliveryDate,
    this.dueDate,
    this.productionType = 'Assembly',
    this.priority = 'Medium',
    this.assignedTo = '',
    this.status = 'pending',
    required this.products,
  }) : planning = List.generate(products.length, (_) => ProductPlan());

  int get totalQty => products.fold(0, (a, p) => a + p.qty);
  int get plannedCount => planning.where((p) => p.done).length;
}

class JobOrderSampleData {
  static final List<JobOrder> jobOrders = [
    JobOrder(
      id: 'JO-001',
      customer: 'Rajan Industries',
      status: 'active',
      deliveryDate: DateTime(2026, 4, 25),
      productionType: 'Assembly',
      priority: 'High',
      products: [
        OrderProduct(
            name: 'Steel Frame',
            qty: 100,
            productId: 'PRD-0001',
            bomId: 'BOM-001'),
        OrderProduct(
            name: 'Bolt Set',
            qty: 500,
            productId: 'PRD-0002',
            bomId: 'BOM-002'),
      ],
    ),
    JobOrder(
      id: 'JO-002',
      customer: 'Tamil Tech Pvt Ltd',
      status: 'pending',
      deliveryDate: DateTime(2026, 4, 30),
      productionType: 'Fabrication',
      priority: 'Medium',
      products: [
        OrderProduct(
            name: 'Control Panel',
            qty: 40,
            productId: 'PRD-0003',
            bomId: 'BOM-003'),
        OrderProduct(
            name: 'Wire Harness',
            qty: 120,
            productId: 'PRD-0004',
            bomId: 'BOM-004'),
      ],
    ),
  ];
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
