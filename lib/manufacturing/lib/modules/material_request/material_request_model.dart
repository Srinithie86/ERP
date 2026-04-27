import 'package:flutter/material.dart';

class MaterialRequest {
  final String id, jobRef, requestedBy, status;
  final String itemName;
  final double qty;
  final String uom;
  final DateTime requestDate;
  final List<MaterialRequestItem> items;

  MaterialRequest({
    required this.id,
    required this.jobRef,
    required this.requestedBy,
    required this.status,
    required this.requestDate,
    required this.items,
    this.itemName = '',
    this.qty = 0,
    this.uom = 'pcs',
  });
}

class MaterialRequestItem {
  final String name, uom;
  final double required, available;
  MaterialRequestItem({
    required this.name,
    required this.uom,
    required this.required,
    required this.available,
  });
}

class MaterialRequestSampleData {
  static List<MaterialRequest> materialRequests = [
    MaterialRequest(
      id: 'MR-001',
      jobRef: 'JC-001',
      requestedBy: 'Rajan Kumar',
      status: 'approved',
      requestDate: DateTime.now().subtract(const Duration(days: 1)),
      itemName: 'Monocrystalline Silicon Cell 6"',
      qty: 36000,
      uom: 'pcs',
      items: [
        MaterialRequestItem(
          name: 'Monocrystalline Silicon Cell 6"',
          uom: 'pcs',
          required: 36000,
          available: 42000,
        ),
        MaterialRequestItem(
          name: 'EVA Encapsulant Film',
          uom: 'm²',
          required: 1960,
          available: 2400,
        ),
        MaterialRequestItem(
          name: 'MC4 Junction Box',
          uom: 'pcs',
          required: 500,
          available: 620,
        ),
      ],
    ),
    MaterialRequest(
      id: 'MR-002',
      jobRef: 'JC-003',
      requestedBy: 'Murugan S',
      status: 'pending',
      requestDate: DateTime.now(),
      itemName: 'LED Street Light Driver 60W',
      qty: 500,
      uom: 'pcs',
      items: [
        MaterialRequestItem(
          name: 'LED Street Light Driver 60W',
          uom: 'pcs',
          required: 500,
          available: 430,
        ),
        MaterialRequestItem(
          name: 'LiFePO4 Battery 60Ah',
          uom: 'pcs',
          required: 500,
          available: 560,
        ),
      ],
    ),
    MaterialRequest(
      id: 'MR-003',
      jobRef: 'JC-004',
      requestedBy: 'Rajan Industries',
      status: 'pending',
      requestDate: DateTime.now(),
      itemName: 'Steel Rod 20mm',
      qty: 1000,
      uom: 'Nos',
      items: [
        MaterialRequestItem(
          name: 'Steel Rod 20mm',
          uom: 'Nos',
          required: 1000,
          available: 450,
        ),
        MaterialRequestItem(
          name: 'Corner Bracket',
          uom: 'Nos',
          required: 400,
          available: 400,
        ),
        MaterialRequestItem(
          name: 'Welding Wire 1kg',
          uom: 'Nos',
          required: 200,
          available: 80,
        ),
      ],
    ),
  ];
}
