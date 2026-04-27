import 'package:flutter/material.dart';

class QcRecord {
  final String id, productName, jobRef, inspector, status;
  final int totalQty, passQty, failQty;
  final DateTime date;
  QcRecord({
    required this.id,
    required this.productName,
    required this.jobRef,
    required this.inspector,
    required this.status,
    required this.totalQty,
    required this.passQty,
    required this.failQty,
    required this.date,
  });
}

class QcSampleData {
  static List<QcRecord> qcRecords = [
    QcRecord(
      id: 'QC-001',
      productName: 'Solar Panel 400W Mono',
      jobRef: 'JC-001',
      inspector: 'Priya QC',
      status: 'completed',
      totalQty: 200,
      passQty: 192,
      failQty: 8,
      date: DateTime.now().subtract(const Duration(hours: 3)),
    ),
    QcRecord(
      id: 'QC-002',
      productName: 'Solar Street Light 60W',
      jobRef: 'JC-003',
      inspector: 'Karthik QC',
      status: 'pending',
      totalQty: 150,
      passQty: 0,
      failQty: 0,
      date: DateTime.now(),
    ),
  ];
}
