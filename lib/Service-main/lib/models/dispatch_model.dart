class DispatchResponse {
  final bool error;
  final int total;
  final List<DispatchItem> data;

  DispatchResponse({
    required this.error,
    required this.total,
    required this.data,
  });

  factory DispatchResponse.fromJson(Map<String, dynamic> json) {
    return DispatchResponse(
      error: json['error'] ?? false,
      total: json['total'] is int
          ? json['total']
          : int.tryParse(json['total']?.toString() ?? "0") ?? 0,
      data: (json['data'] as List?)
              ?.map((e) => DispatchItem.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }
}

class DispatchItem {
  final T1 t1;
  final List<T2> t2;

  DispatchItem({required this.t1, required this.t2});

  factory DispatchItem.fromJson(Map<String, dynamic> json) {
    return DispatchItem(
      t1: T1.fromJson(json['t1'] ?? {}),
      t2: (json['t2'] as List?)
              ?.map((e) => T2.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }
}

class T1 {
  final int id;
  final String? qty;
  final String bGst;
  final String bName;
  final String bAdd1;
  final String dtime;
  final String pname;
  final String status;

  T1({
    required this.id,
    this.qty,
    required this.bGst,
    required this.bName,
    required this.bAdd1,
    required this.dtime,
    required this.pname,
    required this.status,
  });

  factory T1.fromJson(Map<String, dynamic> json) {
    return T1(
      id: json['id'] is int
          ? json['id']
          : int.tryParse(json['id']?.toString() ?? "0") ?? 0,
      qty: json['qty']?.toString(),
      bGst: json['b_gst']?.toString() ?? "",
      bName: json['b_name']?.toString() ?? "",
      bAdd1: json['b_add1']?.toString() ?? "",
      dtime: json['dtime']?.toString() ?? "",
      pname: json['pname']?.toString() ?? "",
      status: json['status']?.toString() ?? "",
    );
  }
}

class T2 {
  final int id;
  final int invId;
  final String cusName;
  final String mobileNo;
  final String contactPersonMobile;
  final String tranMode;
  final String dateOfTran;
  final String expDelivery;
  final String image;

  T2({
    required this.id,
    required this.invId,
    required this.cusName,
    required this.mobileNo,
    required this.contactPersonMobile,
    required this.tranMode,
    required this.dateOfTran,
    required this.expDelivery,
    required this.image,
  });

  factory T2.fromJson(Map<String, dynamic> json) {
    return T2(
      id: json['id'] is int
          ? json['id']
          : int.tryParse(json['id']?.toString() ?? "0") ?? 0,
      invId: json['inv_id'] is int
          ? json['inv_id']
          : int.tryParse(json['inv_id']?.toString() ?? "0") ?? 0,
      cusName: json['cus_name']?.toString() ?? "",
      mobileNo: json['mobile_no']?.toString() ?? "",
      contactPersonMobile: json['contact_person_mobile']?.toString() ?? "",
      tranMode: json['tran_mode']?.toString() ?? "",
      dateOfTran: json['date_of_tran']?.toString() ?? "",
      expDelivery: json['exp_delivery']?.toString() ?? "",
      image: json['image']?.toString() ?? "",
    );
  }
}
