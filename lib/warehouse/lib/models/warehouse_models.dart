import 'package:flutter/material.dart';

// ─── GRN / Inward Entry ───────────────────────────────────────────────────────
class GrnEntry {
  final String id;
  final String itemName;
  final double quantity;
  final String unit;
  final String supplierRef;
  final String barcode;
  final DateTime createdAt;
  String? putawayLocation;

  GrnEntry({
    required this.id,
    required this.itemName,
    required this.quantity,
    required this.unit,
    required this.supplierRef,
    required this.barcode,
    required this.createdAt,
    this.putawayLocation,
  });
}

// ─── Putaway ──────────────────────────────────────────────────────────────────
class PutawayEntry {
  final String grnId;
  final String warehouse;
  final String rack;
  final String bin;
  final String shelf;
  final DateTime confirmedAt;

  PutawayEntry({
    required this.grnId,
    required this.warehouse,
    required this.rack,
    required this.bin,
    required this.shelf,
    required this.confirmedAt,
  });

  String get location => '$warehouse / $rack / $bin / $shelf';
}

// ─── Stock Item ───────────────────────────────────────────────────────────────
class StockItem {
  final String id;
  final String itemName;
  final String category;
  double quantity;
  final String unit;
  final String location;
  final String barcode;
  final double minStock;
  final String batchNo;

  StockItem({
    required this.id,
    required this.itemName,
    required this.category,
    required this.quantity,
    required this.unit,
    required this.location,
    required this.barcode,
    required this.minStock,
    required this.batchNo,
  });

  bool get isLowStock => quantity <= minStock;
}

// ─── Request / Indent ─────────────────────────────────────────────────────────
enum RequestStatus { pending, approved, rejected, issued }

class IndentRequest {
  final String id;
  final String requestedBy;
  final DateTime requestedAt;
  final List<RequestItem> items;
  RequestStatus status;
  String? remarks;

  IndentRequest({
    required this.id,
    required this.requestedBy,
    required this.requestedAt,
    required this.items,
    this.status = RequestStatus.pending,
    this.remarks,
  });

  double get totalQty => items.fold(0, (s, i) => s + i.quantity);
}

class RequestItem {
  final String itemName;
  final double quantity;
  final String unit;

  RequestItem({
    required this.itemName,
    required this.quantity,
    required this.unit,
  });
}

// ─── Picking ──────────────────────────────────────────────────────────────────
class PickingEntry {
  final String requestId;
  final String itemBarcode;
  final String locationBarcode;
  final double pickedQty;
  final DateTime pickedAt;

  PickingEntry({
    required this.requestId,
    required this.itemBarcode,
    required this.locationBarcode,
    required this.pickedQty,
    required this.pickedAt,
  });
}

// ─── Material Issue ───────────────────────────────────────────────────────────
class MaterialIssue {
  final String id;
  final String requestId;
  final String itemName;
  final double issuedQty;
  final String issuedTo;
  final DateTime issuedAt;

  MaterialIssue({
    required this.id,
    required this.requestId,
    required this.itemName,
    required this.issuedQty,
    required this.issuedTo,
    required this.issuedAt,
  });
}
// ─── Finished Goods ───────────────────────────────────────────────────────────
class FinishedGoodsEntry {
  final String id;
  final String productionRef;
  final String fgItemName;
  final double quantity;
  final String unit;
  final String barcode;
  final DateTime createdAt;
  String? putawayLocation;

  FinishedGoodsEntry({
    required this.id,
    required this.productionRef,
    required this.fgItemName,
    required this.quantity,
    required this.unit,
    required this.barcode,
    required this.createdAt,
    this.putawayLocation,
  });
}

// ─── Stock Transfer ───────────────────────────────────────────────────────────
class StockTransfer {
  final String id;
  final String itemName;
  final String fromLocation;
  final String toLocation;
  final double quantity;
  final DateTime transferredAt;

  StockTransfer({
    required this.id,
    required this.itemName,
    required this.fromLocation,
    required this.toLocation,
    required this.quantity,
    required this.transferredAt,
  });
}

// ─── Stock Adjustment ─────────────────────────────────────────────────────────
class StockAdjustment {
  final String id;
  final String itemName;
  final double adjustedQty;
  final String reason;
  final DateTime adjustedAt;

  StockAdjustment({
    required this.id,
    required this.itemName,
    required this.adjustedQty,
    required this.reason,
    required this.adjustedAt,
  });
}

// ─── Movement Record (for reports) ────────────────────────────────────────────
class MovementRecord {
  final String id;
  final String type; // 'GRN', 'Issue', 'Transfer', 'Adjustment'
  final String itemName;
  final double quantity;
  final String fromLocation;
  final String toLocation;
  final DateTime timestamp;
  final Color typeColor;
  final IconData typeIcon;

  MovementRecord({
    required this.id,
    required this.type,
    required this.itemName,
    required this.quantity,
    required this.fromLocation,
    required this.toLocation,
    required this.timestamp,
    required this.typeColor,
    required this.typeIcon,
  });
}
