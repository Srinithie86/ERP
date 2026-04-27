import 'package:flutter/material.dart';

class ProductionPlan {
  final String id, productName, bomRef, status, priority;
  final int plannedQty, completedQty;
  final DateTime deadline;
  ProductionPlan({
    required this.id,
    required this.productName,
    required this.bomRef,
    required this.status,
    required this.priority,
    required this.plannedQty,
    required this.completedQty,
    required this.deadline,
  });
}

class ProductionSampleData {
  static List<ProductionPlan> plans = [
    ProductionPlan(
      id: 'PP-001',
      productName: 'Solar Panel 400W Mono',
      bomRef: 'BOM-001',
      status: 'inprogress',
      priority: 'High',
      plannedQty: 1000,
      completedQty: 450,
      deadline: DateTime.now().add(const Duration(days: 3)),
    ),
    ProductionPlan(
      id: 'PP-002',
      productName: 'Solar Street Light 60W',
      bomRef: 'BOM-002',
      status: 'pending',
      priority: 'Medium',
      plannedQty: 500,
      completedQty: 0,
      deadline: DateTime.now().add(const Duration(days: 7)),
    ),
    ProductionPlan(
      id: 'PP-003',
      productName: 'Solar Water Pump 1HP',
      bomRef: 'BOM-003',
      status: 'completed',
      priority: 'Low',
      plannedQty: 750,
      completedQty: 750,
      deadline: DateTime.now().subtract(const Duration(days: 1)),
    ),
  ];
}
