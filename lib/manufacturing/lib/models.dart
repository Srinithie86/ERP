
class BomItem {
  final String id, productName, category, version, status;
  final int materialCount;
  final DateTime updatedAt;
  BomItem({required this.id, required this.productName, required this.category,
    required this.version, required this.status, required this.materialCount,
    required this.updatedAt});
}

class BomMaterial {
  final String name, uom;
  final double quantity, scrapPercent;
  BomMaterial({required this.name, required this.uom,
    required this.quantity, required this.scrapPercent});
}

class ProductionPlan {
  final String id, productName, bomRef, status, priority;
  final int plannedQty, completedQty;
  final DateTime deadline;
  ProductionPlan({required this.id, required this.productName, required this.bomRef,
    required this.status, required this.priority, required this.plannedQty,
    required this.completedQty, required this.deadline});
}

class JobCard {
  final String id, productName, planRef, status, assignedTo, machine;
  final int qty;
  final DateTime startDate, endDate;
  JobCard({required this.id, required this.productName, required this.planRef,
    required this.status, required this.assignedTo, required this.machine,
    required this.qty, required this.startDate, required this.endDate});
}

class MaterialRequest {
  final String id, jobRef, requestedBy, status;
  final DateTime requestDate;
  final List<MaterialRequestItem> items;
  MaterialRequest({required this.id, required this.jobRef, required this.requestedBy,
    required this.status, required this.requestDate, required this.items});
}

class MaterialRequestItem {
  final String name, uom;
  final double required, available;
  MaterialRequestItem({required this.name, required this.uom,
    required this.required, required this.available});
}

class QcRecord {
  final String id, productName, jobRef, inspector, status;
  final int totalQty, passQty, failQty;
  final DateTime date;
  QcRecord({required this.id, required this.productName, required this.jobRef,
    required this.inspector, required this.status, required this.totalQty,
    required this.passQty, required this.failQty, required this.date});
}

// ─── Job Order Models ─────────────────────────────────────────────────────────

class PlanSplit {
  final String priority;
  final DateTime? deadline;
  const PlanSplit({required this.priority, this.deadline});
}

class ProductPlan {
  final int planned;
  final bool done;
  final List<PlanSplit> splits;
  const ProductPlan({
    required this.planned,
    this.done = false,
    this.splits = const [],
  });
}

class OrderProduct {
  final String name;
  final int qty;
  const OrderProduct({required this.name, required this.qty});
}

class JobOrder {
  final String id;
  final String ref;
  final List<OrderProduct> products;
  final List<ProductPlan> planning;
  const JobOrder({
    required this.id,
    required this.ref,
    required this.products,
    required this.planning,
  });
}

// ---------------------------------------------------------------------------
// Sample Data — Solar Energy Products MRP
// ---------------------------------------------------------------------------
class SampleData {
  // ── Bill of Materials ──────────────────────────────────────────────────────
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

  // ── BOM Materials (BOM-001 — Solar Panel 400W Mono) ───────────────────────
  static List<BomMaterial> bomMaterials = [
    BomMaterial(
      name: 'Monocrystalline Silicon Cell 6"',
      uom: 'pcs',
      quantity: 72,
      scrapPercent: 3,
    ),
    BomMaterial(
      name: 'Tempered Solar Glass 3.2mm',
      uom: 'm²',
      quantity: 1.96,
      scrapPercent: 2,
    ),
    BomMaterial(
      name: 'EVA Encapsulant Film',
      uom: 'm²',
      quantity: 3.92,
      scrapPercent: 1,
    ),
    BomMaterial(
      name: 'TPT Back Sheet',
      uom: 'm²',
      quantity: 1.96,
      scrapPercent: 1,
    ),
    BomMaterial(
      name: 'Anodised Aluminium Frame',
      uom: 'pcs',
      quantity: 1,
      scrapPercent: 0,
    ),
    BomMaterial(
      name: 'MC4 Junction Box',
      uom: 'pcs',
      quantity: 1,
      scrapPercent: 0,
    ),
  ];

  // ── Production / Build Plans ───────────────────────────────────────────────
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

  // ── Job Cards / Work Orders ────────────────────────────────────────────────
  static List<JobCard> jobCards = [
    JobCard(
      id: 'JC-001',
      productName: 'Solar Panel 400W Mono',
      planRef: 'PP-001',
      status: 'inprogress',
      assignedTo: 'Rajan Kumar',
      machine: 'Laminator L-01',
      qty: 500,
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
      startDate: DateTime.now().add(const Duration(days: 2)),
      endDate: DateTime.now().add(const Duration(days: 4)),
    ),
  ];

  // ── Job Orders ─────────────────────────────────────────────────────────────
  static final List<JobOrder> jobOrders = [
    JobOrder(
      id: 'JO-001',
      ref: 'REF-001',
      products: const [
        OrderProduct(name: 'Solar Panel 400W Mono', qty: 1000),
        OrderProduct(name: 'Solar Street Light 60W', qty: 500),
      ],
      planning: [
        ProductPlan(
          planned: 450,
          done: false,
          splits: [
            PlanSplit(
              priority: 'High',
              deadline: DateTime.now().add(const Duration(days: 3)),
            ),
          ],
        ),
        const ProductPlan(planned: 0, done: false),
      ],
    ),
    JobOrder(
      id: 'JO-002',
      ref: 'REF-002',
      products: const [
        OrderProduct(name: 'Solar Water Pump 1HP', qty: 750),
        OrderProduct(name: 'Solar Home System 1kW', qty: 200),
      ],
      planning: [
        ProductPlan(
          planned: 750,
          done: true,
          splits: [
            PlanSplit(
              priority: 'Low',
              deadline: DateTime.now().subtract(const Duration(days: 1)),
            ),
          ],
        ),
        ProductPlan(
          planned: 80,
          done: false,
          splits: [
            PlanSplit(
              priority: 'Medium',
              deadline: DateTime.now().add(const Duration(days: 10)),
            ),
          ],
        ),
      ],
    ),
  ];

  // ── Component / Material Requests ─────────────────────────────────────────
  static List<MaterialRequest> materialRequests = [
    MaterialRequest(
      id: 'MR-001',
      jobRef: 'JC-001',
      requestedBy: 'Rajan Kumar',
      status: 'approved',
      requestDate: DateTime.now().subtract(const Duration(days: 1)),
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
  ];

  // ── QC / Testing Records ──────────────────────────────────────────────────
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
      productName: 'Solar Water Pump 1HP',
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