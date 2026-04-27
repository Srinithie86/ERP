class ShipmentModel {
  const ShipmentModel({
    required this.id,
    required this.status,
    required this.date,
    required this.time,
    required this.assignedTo,
    required this.phone,
    required this.method,
  });

  final String id;
  final String status;
  final String date;
  final String time;
  final String assignedTo;
  final String phone;
  final String method;
}


