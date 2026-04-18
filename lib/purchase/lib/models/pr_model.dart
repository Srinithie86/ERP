class PrResponse {
  final bool error;
  final int type;
  final String message;
  final List<PrData> data;

  PrResponse({
    required this.error,
    required this.type,
    required this.message,
    required this.data,
  });

  factory PrResponse.fromJson(Map<String, dynamic> json) {
    bool hasError = true;
    if (json['error'] == false || json['error'] == 'false') {
      hasError = false;
    }
    return PrResponse(
      error: hasError,
      type: int.tryParse(json['type']?.toString() ?? '') ?? 0,
      message: json['message']?.toString() ?? '',
      data: (json['data'] as List<dynamic>?)
              ?.map((e) => PrData.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }
}

class PrData {
  final PrMaster master;
  final List<PrItem> items;
  final String? pdfLink;

  PrData({
    required this.master,
    required this.items,
    this.pdfLink,
  });

  factory PrData.fromJson(Map<String, dynamic> json) {
    // If 'master' exists, use it. Otherwise, use the root of the JSON itself.
    final masterMap = json.containsKey('master') 
        ? (json['master'] as Map<String, dynamic>) 
        : json;
    
    return PrData(
      master: PrMaster.fromJson(masterMap),
      pdfLink: json['pdf_link']?.toString(),
      items: (json['items'] as List<dynamic>?)
              ?.map((e) => PrItem.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }
}

class PrMaster {
  final int id;
  final String no;
  final String reqDate;
  final String department;
  final String? requestedBy;
  final String quantityRequired;
  final String? priority;
  final String? status;
  final String dtime;
  final String? remarks;
  final String? approverName;
  final String? approvedByName;
  final String? approvedDate;

  PrMaster({
    required this.id,
    required this.no,
    required this.reqDate,
    required this.department,
    this.requestedBy,
    required this.quantityRequired,
    this.priority,
    this.status,
    required this.dtime,
    this.remarks,
    this.approverName,
    this.approvedByName,
    this.approvedDate,
  });

  factory PrMaster.fromJson(Map<String, dynamic> json) {
    return PrMaster(
      id: int.tryParse(json['id']?.toString() ?? '') ?? 0,
      no: (json['no'] ?? json['requ_no'] ?? json['pr_no'] ?? '').toString(),
      reqDate: (json['req_date'] ?? json['date'] ?? json['rfq_date'] ?? '').toString(),
      department: (json['department'] ?? json['dept_name'] ?? '').toString(),
      requestedBy: (json['requested_by'] ?? json['req_by'] ?? json['user_name'] ?? '').toString(),
      quantityRequired: (json['quantity_required'] ?? json['qty'] ?? json['total_qty'] ?? '0').toString(),
      priority: (json['priority'] ?? json['pr_priority'] ?? 'Normal').toString(),
      status: json['status']?.toString(),
      dtime: (json['dtime'] ?? json['created_at'] ?? '').toString(),
      remarks: (json['remarks'] ?? json['reason'] ?? '').toString(),
      approverName: (json['approver'] ?? json['approver_name'] ?? json['manager_name'] ?? '').toString(),
      approvedByName: (json['approved_by'] ?? json['approved_by_name'] ?? '').toString(),
      approvedDate: (json['approved_date'] ?? json['approval_date'] ?? '').toString(),
    );
  }
}

class PrItem {
  final int id;
  final String no;
  final int mid;
  final String? itemCode;
  final String? itemDescription;
  final String? uom;
  final String date;
  final String? quantityRequired;
  final String? productName;
  final String? qty;

  PrItem({
    required this.id,
    required this.no,
    required this.mid,
    this.itemCode,
    this.itemDescription,
    this.uom,
    required this.date,
    this.quantityRequired,
    this.productName,
    this.qty,
  });

  factory PrItem.fromJson(Map<String, dynamic> json) {
    return PrItem(
      id: int.tryParse(json['id']?.toString() ?? '') ?? 0,
      no: (json['no'] ?? json['requ_no'] ?? '').toString(),
      mid: int.tryParse((json['mid'] ?? json['id'] ?? '').toString()) ?? 0,
      itemCode: json['item_code']?.toString(),
      itemDescription: (json['item_description'] ?? json['remarks'] ?? '').toString(),
      uom: (json['uom'] ?? 'nos').toString(),
      date: (json['date'] ?? json['rfq_date'] ?? json['dtime'] ?? '').toString(),
      quantityRequired: (json['quantity_required'] ?? json['qty'] ?? '0').toString(),
      productName: (json['product_name'] ?? json['item_code'] ?? '').toString(),
      qty: (json['qty'] ?? json['quantity_required'] ?? '0').toString(),
    );
  }
}
