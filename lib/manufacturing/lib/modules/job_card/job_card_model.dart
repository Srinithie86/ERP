import 'package:flutter/material.dart';

class JobCard {
  final String id, productName, planRef, status, assignedTo, machine;
  final String description;
  final int qty;
  final DateTime startDate, endDate;
  JobCard({
    required this.id,
    required this.productName,
    required this.planRef,
    required this.status,
    required this.assignedTo,
    required this.machine,
    required this.qty,
    required this.startDate,
    required this.endDate,
    this.description = '',
  });
}

class SpareItem {
  final String partNo;
  final String name;
  final int required;
  final int inStock;
  final String uom;

  const SpareItem({
    required this.partNo,
    required this.name,
    required this.required,
    required this.inStock,
    required this.uom,
  });

  bool get isSufficient => inStock >= required;
  int get gap => required - inStock;
}

final Map<String, List<SpareItem>> _jobSpares = {
  'JC-001': [
    SpareItem(partNo: 'SP-101', name: 'Monocrystalline Cell 6"',  required: 144, inStock: 200, uom: 'Nos'),
    SpareItem(partNo: 'SP-102', name: 'EVA Encapsulant Film',      required: 4,   inStock: 2,   uom: 'm²'),
    SpareItem(partNo: 'SP-103', name: 'TPT Back Sheet',            required: 4,   inStock: 0,   uom: 'm²'),
    SpareItem(partNo: 'SP-104', name: 'MC4 Junction Box',          required: 2,   inStock: 5,   uom: 'Nos'),
  ],
  'JC-002': [
    SpareItem(partNo: 'SP-201', name: 'Tempered Solar Glass 3.2mm', required: 2,  inStock: 1,   uom: 'Nos'),
    SpareItem(partNo: 'SP-202', name: 'Anodised Aluminium Frame',   required: 4,  inStock: 8,   uom: 'Nos'),
    SpareItem(partNo: 'SP-203', name: 'Bypass Diode',               required: 6,  inStock: 0,   uom: 'Nos'),
  ],
  'JC-003': [
    SpareItem(partNo: 'SP-301', name: 'LED Street Light Driver 60W', required: 10, inStock: 10, uom: 'Nos'),
    SpareItem(partNo: 'SP-302', name: 'LiFePO4 Battery 60Ah',        required: 10, inStock: 6,  uom: 'Nos'),
    SpareItem(partNo: 'SP-303', name: 'Solar Charge Controller 10A', required: 10, inStock: 0,  uom: 'Nos'),
    SpareItem(partNo: 'SP-304', name: 'Mounting Pole Bracket',       required: 10, inStock: 15, uom: 'Nos'),
  ],
  'JC-004': [
    SpareItem(partNo: 'SP-401', name: 'Steel Rod 20mm',   required: 1000, inStock: 450, uom: 'Nos'),
    SpareItem(partNo: 'SP-402', name: 'Corner Bracket',   required: 400,  inStock: 400, uom: 'Nos'),
    SpareItem(partNo: 'SP-403', name: 'Welding Wire 1kg', required: 200,  inStock: 80,  uom: 'Nos'),
  ],
};

List<SpareItem> sparesFor(String jobId) =>
    _jobSpares[jobId] ?? _jobSpares['JC-001']!;

class JobCardSampleData {
  static List<JobCard> jobCards = [
    JobCard(
      id: 'JC-001',
      productName: 'Solar Panel 400W Mono',
      planRef: 'PP-001',
      status: 'inprogress',
      assignedTo: 'Rajan Kumar',
      machine: 'Laminator L-01',
      qty: 500,
      description: 'Lamination and assembly of 400W monocrystalline solar panels.',
      startDate: DateTime.now().subtract(const Duration(days: 1)),
      endDate: DateTime.now().add(const Duration(days: 2)),
    ),
    JobCard(
      id: 'JC-002',
      productName: 'Solar Panel 400W Mono',
      planRef: 'PP-001',
      status: 'pending',
      assignedTo: 'Suresh M',
      machine: 'Framing Press F-02',
      qty: 500,
      description: 'Framing and encapsulation of solar panel modules.',
      startDate: DateTime.now().add(const Duration(days: 1)),
      endDate: DateTime.now().add(const Duration(days: 3)),
    ),
    JobCard(
      id: 'JC-003',
      productName: 'Solar Street Light 60W',
      planRef: 'PP-002',
      status: 'pending',
      assignedTo: 'Murugan S',
      machine: 'Assembly Station A-01',
      qty: 500,
      description: 'Assembly of 60W solar street light units with battery integration.',
      startDate: DateTime.now().add(const Duration(days: 2)),
      endDate: DateTime.now().add(const Duration(days: 4)),
    ),
    JobCard(
      id: 'JC-004',
      productName: 'Steel Frame',
      planRef: 'JO-001',
      status: 'pending',
      assignedTo: 'Rajan Industries',
      machine: 'Fabrication Station F-01',
      qty: 100,
      description: 'Fabrication and welding of steel mounting frames.',
      startDate: DateTime.now().add(const Duration(days: 1)),
      endDate: DateTime.now().add(const Duration(days: 5)),
    ),
  ];
}
