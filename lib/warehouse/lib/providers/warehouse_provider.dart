import 'package:flutter/material.dart';
import '../models/warehouse_models.dart';

class WarehouseProvider extends ChangeNotifier {
  // ── Stock ──────────────────────────────────────────────────────────────────
  final List<StockItem> _stock = [
    StockItem(id: 'SI001', itemName: 'Steel Rod 12mm', category: 'Raw Material', quantity: 450, unit: 'Kg', location: 'WH-A / R1 / B2 / S1', barcode: 'BC-RM-001', minStock: 100, batchNo: 'BT-2024-001'),
    StockItem(id: 'SI002', itemName: 'PVC Pipe 2"', category: 'Raw Material', quantity: 80, unit: 'Pcs', location: 'WH-A / R2 / B1 / S3', barcode: 'BC-RM-002', minStock: 100, batchNo: 'BT-2024-002'),
    StockItem(id: 'SI003', itemName: 'Cement Bag 50kg', category: 'Raw Material', quantity: 25, unit: 'Bags', location: 'WH-B / R1 / B1 / S1', barcode: 'BC-RM-003', minStock: 50, batchNo: 'BT-2024-003'),
    StockItem(id: 'SI004', itemName: 'Finished Door Frame', category: 'Finished Goods', quantity: 120, unit: 'Pcs', location: 'WH-C / R1 / B1 / S1', barcode: 'BC-FG-001', minStock: 20, batchNo: 'BT-FG-001'),
    StockItem(id: 'SI005', itemName: 'Welded Panel A4', category: 'Finished Goods', quantity: 60, unit: 'Pcs', location: 'WH-C / R2 / B1 / S2', barcode: 'BC-FG-002', minStock: 30, batchNo: 'BT-FG-002'),
    StockItem(id: 'SI006', itemName: 'Copper Wire 1.5mm', category: 'Raw Material', quantity: 320, unit: 'Mtrs', location: 'WH-A / R3 / B2 / S1', barcode: 'BC-RM-006', minStock: 200, batchNo: 'BT-2024-006'),
  ];

  // ── GRN Entries ────────────────────────────────────────────────────────────
  final List<GrnEntry> _grnList = [];

  // ── Putaway Entries ────────────────────────────────────────────────────────
  final List<PutawayEntry> _putawayList = [];

  // ── Indent Requests ────────────────────────────────────────────────────────
  final List<IndentRequest> _requests = [
    IndentRequest(
      id: 'REQ-001',
      requestedBy: 'Production Dept',
      requestedAt: DateTime.now().subtract(const Duration(hours: 3)),
      items: [
        RequestItem(itemName: 'Steel Rod 12mm', quantity: 50, unit: 'Kg'),
        RequestItem(itemName: 'PVC Pipe 2"', quantity: 20, unit: 'Pcs'),
      ],
      status: RequestStatus.pending,
    ),
    IndentRequest(
      id: 'REQ-002',
      requestedBy: 'Assembly Line-2',
      requestedAt: DateTime.now().subtract(const Duration(hours: 6)),
      items: [RequestItem(itemName: 'Copper Wire 1.5mm', quantity: 100, unit: 'Mtrs')],
      status: RequestStatus.approved,
    ),
    IndentRequest(
      id: 'REQ-003',
      requestedBy: 'Maintenance',
      requestedAt: DateTime.now().subtract(const Duration(days: 1)),
      items: [RequestItem(itemName: 'Cement Bag 50kg', quantity: 5, unit: 'Bags')],
      status: RequestStatus.rejected,
      remarks: 'Budget exceeded',
    ),
  ];

  // ── Picking Entries ────────────────────────────────────────────────────────
  final List<PickingEntry> _pickingList = [];

  // ── Material Issues ────────────────────────────────────────────────────────
  final List<MaterialIssue> _issues = [];

  // ── Finished Goods ─────────────────────────────────────────────────────────
  final List<FinishedGoodsEntry> _fgList = [];

  // ── Transfers ─────────────────────────────────────────────────────────────
  final List<StockTransfer> _transfers = [];

  // ── Adjustments ────────────────────────────────────────────────────────────
  final List<StockAdjustment> _adjustments = [];

  // ── Barcodes generated ─────────────────────────────────────────────────────
  String? _lastGeneratedBarcode;
  String? _lastGeneratedItemName;

  // ─── Getters ───────────────────────────────────────────────────────────────
  List<StockItem> get stock => List.unmodifiable(_stock);
  List<GrnEntry> get grnList => List.unmodifiable(_grnList);
  List<IndentRequest> get requests => List.unmodifiable(_requests);
  List<IndentRequest> get pendingRequests =>
      _requests.where((r) => r.status == RequestStatus.pending).toList();
  List<PickingEntry> get pickingList => List.unmodifiable(_pickingList);
  List<MaterialIssue> get issues => List.unmodifiable(_issues);
  List<FinishedGoodsEntry> get fgList => List.unmodifiable(_fgList);
  List<StockTransfer> get transfers => List.unmodifiable(_transfers);
  List<StockAdjustment> get adjustments => List.unmodifiable(_adjustments);
  String? get lastGeneratedBarcode => _lastGeneratedBarcode;
  String? get lastGeneratedItemName => _lastGeneratedItemName;

  // ─── Dashboard summaries ───────────────────────────────────────────────────
  double get totalRawMaterialStock => _stock
      .where((s) => s.category == 'Raw Material')
      .fold(0, (sum, s) => sum + s.quantity);

  double get totalFGStock => _stock
      .where((s) => s.category == 'Finished Goods')
      .fold(0, (sum, s) => sum + s.quantity);

  int get pendingRequestCount => pendingRequests.length;
  int get lowStockCount => _stock.where((s) => s.isLowStock).length;
  List<StockItem> get lowStockItems => _stock.where((s) => s.isLowStock).toList();

  // ── Locations / masters ────────────────────────────────────────────────────
  final List<String> warehouses = ['WH-A (Raw Material)', 'WH-B (Storage)', 'WH-C (Finished Goods)'];
  final List<String> racks = ['R1', 'R2', 'R3', 'R4'];
  final List<String> bins = ['B1', 'B2', 'B3'];
  final List<String> shelves = ['S1', 'S2', 'S3', 'S4'];
  final List<String> suppliers = ['Supplier-A (SCRAP Co.)', 'Supplier-B (MetalWorks)', 'Supplier-C (PipeCraft)', 'Internal Production'];
  final List<String> units = ['Kg', 'Pcs', 'Mtrs', 'Bags', 'Ltrs', 'Nos'];

  // ─── Actions ──────────────────────────────────────────────────────────────

  /// Save GRN entry
  GrnEntry saveGrn({
    required String itemName,
    required double quantity,
    required String unit,
    required String supplierRef,
  }) {
    final barcode = 'GRN-${DateTime.now().millisecondsSinceEpoch}';
    final entry = GrnEntry(
      id: 'GRN-${_grnList.length + 1}'.padLeft(6, '0'),
      itemName: itemName,
      quantity: quantity,
      unit: unit,
      supplierRef: supplierRef,
      barcode: barcode,
      createdAt: DateTime.now(),
    );
    _grnList.add(entry);
    _lastGeneratedBarcode = barcode;
    _lastGeneratedItemName = itemName;
    notifyListeners();
    return entry;
  }

  /// Confirm putaway
  void confirmPutaway({
    required String grnId,
    required String warehouse,
    required String rack,
    required String bin,
    required String shelf,
    required String itemName,
    required double quantity,
    required String unit,
  }) {
    final location = '$warehouse / $rack / $bin / $shelf';
    _putawayList.add(PutawayEntry(
      grnId: grnId,
      warehouse: warehouse,
      rack: rack,
      bin: bin,
      shelf: shelf,
      confirmedAt: DateTime.now(),
    ));
    // Update or add stock
    final existing = _stock.where((s) => s.itemName == itemName).firstOrNull;
    if (existing != null) {
      existing.quantity += quantity;
    } else {
      _stock.add(StockItem(
        id: 'SI${_stock.length + 1}'.padLeft(6, '0'),
        itemName: itemName,
        category: 'Raw Material',
        quantity: quantity,
        unit: unit,
        location: location,
        barcode: 'BC-${DateTime.now().millisecondsSinceEpoch}',
        minStock: 10,
        batchNo: 'BT-${DateTime.now().year}-${_stock.length + 1}',
      ));
    }
    notifyListeners();
  }

  /// Add indent request
  IndentRequest addRequest({
    required String requestedBy,
    required List<RequestItem> items,
  }) {
    final req = IndentRequest(
      id: 'REQ-${(_requests.length + 1).toString().padLeft(3, '0')}',
      requestedBy: requestedBy,
      requestedAt: DateTime.now(),
      items: items,
    );
    _requests.add(req);
    notifyListeners();
    return req;
  }

  /// Approve or reject request
  void updateRequestStatus(String requestId, RequestStatus status, {String? remarks}) {
    final req = _requests.where((r) => r.id == requestId).firstOrNull;
    if (req != null) {
      req.status = status;
      req.remarks = remarks;
      notifyListeners();
    }
  }

  /// Save picking entry
  PickingEntry savePicking({
    required String requestId,
    required String itemBarcode,
    required String locationBarcode,
    required double pickedQty,
  }) {
    final entry = PickingEntry(
      requestId: requestId,
      itemBarcode: itemBarcode,
      locationBarcode: locationBarcode,
      pickedQty: pickedQty,
      pickedAt: DateTime.now(),
    );
    _pickingList.add(entry);
    notifyListeners();
    return entry;
  }

  /// Confirm material issue
  MaterialIssue confirmIssue({
    required String requestId,
    required String itemName,
    required double issuedQty,
    required String issuedTo,
  }) {
    final issue = MaterialIssue(
      id: 'ISS-${(_issues.length + 1).toString().padLeft(3, '0')}',
      requestId: requestId,
      itemName: itemName,
      issuedQty: issuedQty,
      issuedTo: issuedTo,
      issuedAt: DateTime.now(),
    );
    _issues.add(issue);
    // Deduct stock
    final stockItem = _stock.where((s) => s.itemName == itemName).firstOrNull;
    if (stockItem != null) {
      stockItem.quantity = (stockItem.quantity - issuedQty).clamp(0, double.infinity);
    }
    // Update request status
    updateRequestStatus(requestId, RequestStatus.issued);
    notifyListeners();
    return issue;
  }

  /// Save finished goods entry
  FinishedGoodsEntry saveFG({
    required String productionRef,
    required String fgItemName,
    required double quantity,
    required String unit,
  }) {
    final barcode = 'FG-${DateTime.now().millisecondsSinceEpoch}';
    final entry = FinishedGoodsEntry(
      id: 'FG-${(_fgList.length + 1).toString().padLeft(3, '0')}',
      productionRef: productionRef,
      fgItemName: fgItemName,
      quantity: quantity,
      unit: unit,
      barcode: barcode,
      createdAt: DateTime.now(),
    );
    _fgList.add(entry);
    _lastGeneratedBarcode = barcode;
    _lastGeneratedItemName = fgItemName;
    notifyListeners();
    return entry;
  }

  /// Confirm stock transfer
  StockTransfer confirmTransfer({
    required String itemName,
    required String fromLocation,
    required String toLocation,
    required double quantity,
  }) {
    final transfer = StockTransfer(
      id: 'TRF-${(_transfers.length + 1).toString().padLeft(3, '0')}',
      itemName: itemName,
      fromLocation: fromLocation,
      toLocation: toLocation,
      quantity: quantity,
      transferredAt: DateTime.now(),
    );
    _transfers.add(transfer);
    // Update stock location
    final item = _stock.where((s) => s.itemName == itemName).firstOrNull;
    if (item != null) {
      // In real app, create new record for new location
      // For now just update location
    }
    notifyListeners();
    return transfer;
  }

  /// Submit stock adjustment
  StockAdjustment submitAdjustment({
    required String itemName,
    required double adjustedQty,
    required String reason,
  }) {
    final adj = StockAdjustment(
      id: 'ADJ-${(_adjustments.length + 1).toString().padLeft(3, '0')}',
      itemName: itemName,
      adjustedQty: adjustedQty,
      reason: reason,
      adjustedAt: DateTime.now(),
    );
    _adjustments.add(adj);
    final item = _stock.where((s) => s.itemName == itemName).firstOrNull;
    if (item != null) {
      item.quantity = (item.quantity + adjustedQty).clamp(0, double.infinity);
    }
    notifyListeners();
    return adj;
  }

  /// Movement history for reports
  List<MovementRecord> get movementHistory {
    final list = <MovementRecord>[];
    for (final g in _grnList) {
      list.add(MovementRecord(
        id: g.id,
        type: 'GRN',
        itemName: g.itemName,
        quantity: g.quantity,
        fromLocation: g.supplierRef,
        toLocation: 'Receiving',
        timestamp: g.createdAt,
        typeColor: Colors.green,
        typeIcon: Icons.login,
      ));
    }
    for (final i in _issues) {
      list.add(MovementRecord(
        id: i.id,
        type: 'Issue',
        itemName: i.itemName,
        quantity: i.issuedQty,
        fromLocation: 'Warehouse',
        toLocation: i.issuedTo,
        timestamp: i.issuedAt,
        typeColor: Colors.orange,
        typeIcon: Icons.logout,
      ));
    }
    for (final t in _transfers) {
      list.add(MovementRecord(
        id: t.id,
        type: 'Transfer',
        itemName: t.itemName,
        quantity: t.quantity,
        fromLocation: t.fromLocation,
        toLocation: t.toLocation,
        timestamp: t.transferredAt,
        typeColor: Colors.blue,
        typeIcon: Icons.swap_horiz,
      ));
    }
    for (final a in _adjustments) {
      list.add(MovementRecord(
        id: a.id,
        type: 'Adjustment',
        itemName: a.itemName,
        quantity: a.adjustedQty,
        fromLocation: '-',
        toLocation: a.reason,
        timestamp: a.adjustedAt,
        typeColor: Colors.purple,
        typeIcon: Icons.tune,
      ));
    }
    list.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    return list;
  }
}
