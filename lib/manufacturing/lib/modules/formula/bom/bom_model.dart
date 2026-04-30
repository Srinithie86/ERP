import 'package:flutter/material.dart';

class BomItem {
  final String id, productName, category, version, status;
  final int materialCount;
  final DateTime updatedAt;

  String get dtime => "${updatedAt.year}-${updatedAt.month.toString().padLeft(2, '0')}-${updatedAt.day.toString().padLeft(2, '0')}";

  String get timeAgo {
    final diff = DateTime.now().difference(updatedAt);
    if (diff.inDays > 0) return '${diff.inDays} days ago';
    if (diff.inHours > 0) return '${diff.inHours} hours ago';
    return 'Just now';
  }
  BomItem({
    required this.id,
    required this.productName,
    required this.category,
    required this.version,
    required this.status,
    required this.materialCount,
    required this.updatedAt,
  });

  factory BomItem.fromJson(Map<String, dynamic> json) {
    return BomItem(
      id: (json['bom_id'] ?? json['id'] ?? '').toString(),
      productName: json['prd_name'] ?? json['product_name'] ?? '',
      category: json['catry'] ?? json['category'] ?? '',
      version: (json['version'] ?? '').toString(),
      status: json['status'] ?? 'active',
      materialCount: 0, // Will be updated when components are loaded
      updatedAt: DateTime.tryParse(json['dtime'] ?? '') ?? DateTime.now(),
    );
  }
}

class BomMaterial {
  final String name, uom;
  final double quantity;

  BomMaterial({
    required this.name,
    required this.uom,
    required this.quantity,
  });

  factory BomMaterial.fromJson(Map<String, dynamic> json) {
    return BomMaterial(
      name: json['components'] ?? json['name'] ?? '',
      uom: json['um'] ?? json['uom'] ?? '',
      quantity: double.tryParse((json['qty'] ?? '0').toString()) ?? 0,
    );
  }
}

class BomSampleData {
  static List<BomItem> boms = [
    BomItem(
      id: 'BOM-001',
      productName: 'Solar Panel 400W Mono',
      category: 'PV Module',
      version: 'v2.1',
      status: 'active',
      materialCount: 6,
      updatedAt: DateTime.now().subtract(const Duration(days: 2)),
    ),
    BomItem(
      id: 'BOM-002',
      productName: 'Solar Street Light 60W',
      category: 'Solar Lighting',
      version: 'v1.3',
      status: 'active',
      materialCount: 4,
      updatedAt: DateTime.now().subtract(const Duration(days: 5)),
    ),
    BomItem(
      id: 'BOM-003',
      productName: 'Solar Water Pump 1HP',
      category: 'Solar Pump',
      version: 'v3.0',
      status: 'draft',
      materialCount: 8,
      updatedAt: DateTime.now().subtract(const Duration(days: 1)),
    ),
    BomItem(
      id: 'BOM-004',
      productName: 'Solar Home System 1kW',
      category: 'Off-Grid System',
      version: 'v1.0',
      status: 'active',
      materialCount: 10,
      updatedAt: DateTime.now().subtract(const Duration(days: 10)),
    ),
  ];

  static List<BomMaterial> bomMaterials = [
    BomMaterial(name: 'Monocrystalline Silicon Cell 6"', uom: 'pcs', quantity: 72),
    BomMaterial(name: 'Tempered Solar Glass 3.2mm', uom: 'm²', quantity: 1.96),
    BomMaterial(name: 'EVA Encapsulant Film', uom: 'm²', quantity: 3.92),
    BomMaterial(name: 'TPT Back Sheet', uom: 'm²', quantity: 1.96),
    BomMaterial(name: 'Anodised Aluminium Frame', uom: 'pcs', quantity: 1),
    BomMaterial(name: 'MC4 Junction Box', uom: 'pcs', quantity: 1),
  ];
}
