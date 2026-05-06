import 'dart:collection';
import 'dart:typed_data';
import '../services/storage_service.dart';

class DispatchmentRecord {
  const DispatchmentRecord({
    required this.dispatchId,
    required this.parcelNo,
    required this.transferMode,
    required this.transportDate,
    required this.expectedDelivery,
    required this.dispatchTime,
    required this.contactName,
    required this.phone,
    required this.address,
    required this.notes,
    required this.status,
    this.attachmentPath,
  });

  final String dispatchId;
  final String parcelNo;
  final String transferMode;
  final String transportDate;
  final String expectedDelivery;
  final String dispatchTime;
  final String contactName;
  final String phone;
  final String address;
  final String notes;
  final String status;
  final String? attachmentPath;
}

class AppData {
  AppData._();

  static final AppData instance = AppData._();

  final Map<String, dynamic> _profile = {
    'name': '',
    'role': 'Technician',
    'email': '',
    'phone': '',
    'zone': '',
    'employeeId': '',
    'shift': '',
    'address': '',
    'city': '',
    'state': '',
    'pincode': '',
    'country': '',
    'avatarBytes': null,
    'totalResolved': 248,
    'partsUsed': 42,
    'score': {
      'todayCompletionRate': 0.67,
      'averageRating': 4.8,
      'responseHours': 2.1,
      'efficiencyScore': 92,
    },
  };

  final List<Map<String, dynamic>> _tickets = [];

  final List<Map<String, dynamic>> _tasks = [
    {
      'id': 'TASK-201',
      'title': 'Visit workstation in Block A',
      'location': 'Floor 2 Support Bay',
      'time': '09:30',
      'scheduledAt': DateTime(2026, 4, 9, 9, 30),
      'ticketId': 'TCK-1042',
      'ticketTitle': 'Workstation not booting',
      'status': 'Completed',
      'isDone': true,
    },
    {
      'id': 'TASK-202',
      'title': 'Replace printer toner cartridge',
      'location': 'Admin Desk',
      'time': '11:00',
      'scheduledAt': DateTime(2026, 4, 8, 11, 0),
      'ticketId': 'TCK-1041',
      'ticketTitle': 'Printer toner replacement',
      'status': 'Completed',
      'isDone': true,
    },
    {
      'id': 'TASK-203',
      'title': 'Inspect Wi-Fi signal coverage',
      'location': 'Meeting Room 4',
      'time': '13:30',
      'scheduledAt': DateTime(2026, 4, 9, 13, 30),
      'ticketId': 'TCK-1039',
      'ticketTitle': 'Wi-Fi dead zone complaint',
      'status': 'Pending',
      'isDone': false,
    },
  ];

  final List<Map<String, dynamic>> _parts = [
    {
      'id': 'SP-201',
      'name': '8GB DDR4 RAM Module',
      'category': 'Memory',
      'stock': 6,
      'minStock': 2,
      'unit': 'pcs',
      'price': 1850.0,
    },
    {
      'id': 'SP-202',
      'name': '512GB SATA SSD',
      'category': 'Storage',
      'stock': 3,
      'minStock': 2,
      'unit': 'pcs',
      'price': 3299.0,
    },
    {
      'id': 'SP-203',
      'name': '65W Laptop Adapter',
      'category': 'Power',
      'stock': 1,
      'minStock': 2,
      'unit': 'pcs',
      'price': 1499.0,
    },
    {
      'id': 'SP-204',
      'name': 'Black Toner Cartridge',
      'category': 'Consumable',
      'stock': 0,
      'minStock': 1,
      'unit': 'pcs',
      'price': 2199.0,
    },
    {
      'id': 'SP-205',
      'name': 'Cat6 Patch Cable 2m',
      'category': 'Cable',
      'stock': 14,
      'minStock': 5,
      'unit': 'pcs',
      'price': 180.0,
    },
    {
      'id': 'SP-206',
      'name': 'USB Keyboard',
      'category': 'Peripheral',
      'stock': 8,
      'minStock': 3,
      'unit': 'pcs',
      'price': 650.0,
    },
    {
      'id': 'SP-207',
      'name': 'PoE Injector',
      'category': 'Network',
      'stock': 2,
      'minStock': 1,
      'unit': 'pcs',
      'price': 1450.0,
    },
  ];

  final List<Map<String, dynamic>> _standbyMachines = [
    {'breakerNo': 'BRK-001', 'serial': '9876', 'status': 'available'},
    {'breakerNo': 'BRK-002', 'serial': '9877', 'status': 'available'},
    {'breakerNo': 'BRK-003', 'serial': '9878', 'status': 'available'},
    {'breakerNo': 'BRK-004', 'serial': '9879', 'status': 'available'},
    {'breakerNo': 'BRK-005', 'serial': '9880', 'status': 'available'},
    {'breakerNo': 'BRK-006', 'serial': '9881', 'status': 'available'},
    {'breakerNo': 'BRK-007', 'serial': '9882', 'status': 'available'},
    {'breakerNo': 'BRK-008', 'serial': '9883', 'status': 'available'},
    {'breakerNo': 'BRK-009', 'serial': '9884', 'status': 'available'},
    {
      'breakerNo': 'BRK-010',
      'serial': '9885',
      'status': 'in_use',
      'ticketNo': 'TCK-1035',
      'customerName': 'Kiran Patel',
      'jobNo': 'TCK-1035',
      'givenDate': DateTime(2026, 4, 4),
      'returnDate': DateTime(2026, 4, 10),
      'charges': '500',
    },
  ];

  final List<Map<String, dynamic>> _shipments = [
    {
      'id': 'Parcel - 001',
      'status': 'Pending',
      'date': '11/04/2026',
      'time': '10:00',
      'assignedTo': 'Tamilarasi',
      'phone': '+91 9876543210',
      'method': 'By Bus',
    },
    {
      'id': 'Parcel - 002',
      'status': 'Received',
      'date': '11/04/2026',
      'time': '10:00',
      'assignedTo': 'Tamilarasi',
      'phone': '+91 9876543210',
      'method': 'By Bus',
    },
    {
      'id': 'Parcel - 003',
      'status': 'Pending',
      'date': '12/04/2026',
      'time': '11:00',
      'assignedTo': 'Rajesh',
      'phone': '+91 9876543210',
      'method': 'Courier',
    },
    {
      'id': 'Parcel - 004',
      'status': 'Received',
      'date': '13/04/2026',
      'time': '14:30',
      'assignedTo': 'Sowmiya',
      'phone': '+91 9876543210',
      'method': 'Vechile',
    },
    {
      'id': 'Parcel - 005',
      'status': 'Pending',
      'date': '14/04/2026',
      'time': '09:00',
      'assignedTo': 'Arjun',
      'phone': '+91 9876543210',
      'method': 'Travels',
    },
  ];

  final List<DispatchmentRecord> _dispatchHistory = [];
  final String dispatchCode = '482751';

  final Map<String, dynamic> _job = {
    'ticketId': '#JOB-1043',
    'customerName': 'Sowmiya',
    'issue': 'AC unit not cooling - Repair',
    'dateText': 'Mon, 6 April 2026',
    'checkInTime': '10:16 am',
    'autoCapturedAt': '10:16 AM',
    'startTime': '10:00 AM',
    'endTime': '12:00 PM',
    'duration': '2 Hours',
    'priority': 'High Priority',
    'type': 'Repair',
    'product': 'Samsung 1.5T AC',
    'complaint': 'Runs but not cooling below 28C',
    'phone': '+91 98765 43210',
    'email': 'sowmi@gmail.com',
    'address': 'Plot 12, Anna Nagar, Chennai',
    'estimatedDuration': '2 -3 Hours',
    'serviceCharge': '2',
    'nextVisitDate': '',
    'spareLines': [],
  };

  DateTime? _workStartedAt;
  DateTime? _workEndedAt;
  Duration _workDuration = Duration.zero;
  bool _workTimerRunning = false;
  String workDescription = '';
  String beforeImageName = '';
  String beforeImagePath = '';
  Uint8List? beforeImageBytes;
  String afterImageName = '';
  String afterImagePath = '';
  Uint8List? afterImageBytes;
  String oldSpareImageName = '';
  String oldSpareImagePath = '';
  Uint8List? oldSpareImageBytes = null;
  String signatureName = '';
  String signaturePath = '';
  Uint8List? signatureBytes;
  String sparesUsedLabel = '';
  String serviceChargeInput = '1';
  String workStatus = 'Completed';
  DateTime? nextVisitDate;
  String otpChannel = '';
  bool standBy = true;
  final List<String> otpDigits = ['1', '4', '2', '7', '9', '6'];

  UnmodifiableMapView<String, dynamic> get profile =>
      UnmodifiableMapView(_profile);

  List<Map<String, dynamic>> get tickets => List.unmodifiable(
    _tickets.map((ticket) => Map<String, dynamic>.from(ticket)),
  );

  List<Map<String, dynamic>> get tasks =>
      List.unmodifiable(_tasks.map((task) => Map<String, dynamic>.from(task)));

  List<Map<String, dynamic>> get parts =>
      List.unmodifiable(_parts.map((part) => Map<String, dynamic>.from(part)));

  List<Map<String, dynamic>> get availableMachines => _standbyMachines
      .where((m) => m['status'] == 'available')
      .map((m) => Map<String, dynamic>.from(m))
      .toList();

  List<Map<String, dynamic>> get inUseMachines => _standbyMachines
      .where((m) => m['status'] == 'in_use')
      .map((m) => Map<String, dynamic>.from(m))
      .toList();

  int get totalMachineCount => _standbyMachines.length;
  int get availableMachineCount =>
      _standbyMachines.where((m) => m['status'] == 'available').length;
  int get inUseMachineCount =>
      _standbyMachines.where((m) => m['status'] == 'in_use').length;
  List<String> get availableBreakerNumbers => _standbyMachines
      .where((m) => m['status'] == 'available')
      .map<String>((m) => m['breakerNo'] as String)
      .toList();
  List<String> get pendingAndAssignedJobNumbers => _tickets
      .where(
        (t) =>
            t['status'] == 'Pending' ||
            t['status'] == 'Accepted' ||
            t['status'] == 'In Progress',
      )
      .map<String>((t) => t['id'] as String)
      .toList();
  int get pendingCount =>
      _tickets.where((t) => t['status'] == 'Pending').length;

  List<Map<String, dynamic>> get shipments =>
      List.unmodifiable(_shipments.map((s) => Map<String, dynamic>.from(s)));
  int get totalShipmentCount => _shipments.length;
  int get receivedShipmentCount =>
      _shipments.where((s) => s['status'] == 'Received').length;

  List<DispatchmentRecord> get dispatchHistory =>
      List.unmodifiable(_dispatchHistory);
  DispatchmentRecord? get latestDispatch =>
      _dispatchHistory.isEmpty ? null : _dispatchHistory.last;

  Map<String, dynamic> get job => Map<String, dynamic>.from(_job);
  DateTime? get workStartedAt => _workStartedAt;
  DateTime? get workEndedAt => _workEndedAt;
  Duration get workDuration => _workDuration;
  bool get workTimerRunning => _workTimerRunning;
  String get workStartTimeText =>
      _workStartedAt == null ? '' : _formatTimeOfDay(_workStartedAt!);
  String get workEndTimeText =>
      _workEndedAt == null ? '' : _formatTimeOfDay(_workEndedAt!);
  String get workDurationText => _formatDuration(_workDuration);

  void updateTicket(
    String id, {
    String? status,
    String? resolutionNote,
    String? proofImagePath,
    String? priority,
    String? assignedTo,
  }) {
    final index = _tickets.indexWhere((ticket) => ticket['id'] == id);
    if (index == -1) return;
    final current = Map<String, dynamic>.from(_tickets[index]);
    if (status != null) current['status'] = status;
    if (resolutionNote != null || current['resolutionNote'] != null) {
      current['resolutionNote'] = resolutionNote;
    }
    if (proofImagePath != null || current['proofImagePath'] != null) {
      current['proofImagePath'] = proofImagePath;
    }
    if (priority != null) current['priority'] = priority;
    if (assignedTo != null) {
      current['assignedTo'] = assignedTo;
      current['user'] = assignedTo;
    }
    _tickets[index] = current;
  }

  void setTickets(List<Map<String, dynamic>> tickets) {
    _tickets.clear();
    _tickets.addAll(tickets);
  }

  Future<void> syncProfile() async {
    final name = await StorageService.getName();
    final email = await StorageService.getEmail();
    final phone = await StorageService.getPhone();
    final address = await StorageService.getAddress();
    final city = await StorageService.getCity();
    final state = await StorageService.getState();
    final pincode = await StorageService.getPincode();
    final country = await StorageService.getCountry();

    if (name != null && name.isNotEmpty) {
      _profile['name'] = name;
    }
    if (email != null && email.isNotEmpty) {
      _profile['email'] = email;
    }
    if (phone != null && phone.isNotEmpty) {
      _profile['phone'] = phone;
    }
    if (address != null && address.isNotEmpty) {
      _profile['address'] = address;
    }
    if (city != null && city.isNotEmpty) {
      _profile['city'] = city;
    }
    if (state != null && state.isNotEmpty) {
      _profile['state'] = state;
    }
    if (pincode != null && pincode.isNotEmpty) {
      _profile['pincode'] = pincode;
    }
    if (country != null && country.isNotEmpty) {
      _profile['country'] = country;
    }
  }

  void assignMachine({
    required String breakerNo,
    required String ticketNo,
    required String customerName,
    required String jobNo,
    required DateTime givenDate,
    required DateTime returnDate,
    String? charges,
  }) {
    final index = _standbyMachines.indexWhere(
      (m) => m['breakerNo'] == breakerNo,
    );
    if (index == -1) return;
    _standbyMachines[index] = {
      ..._standbyMachines[index],
      'status': 'in_use',
      'ticketNo': ticketNo,
      'customerName': customerName,
      'jobNo': jobNo,
      'givenDate': givenDate,
      'returnDate': returnDate,
      'charges': charges ?? '',
    };
  }

  void updateProfile(Map<String, dynamic> updatedProfile) {
    _profile.addAll(updatedProfile);
  }

  void updateAvatar(Uint8List? avatarBytes) {
    _profile['avatarBytes'] = avatarBytes;
  }

  String nextDispatchId() {
    final serial = 1001 + _dispatchHistory.length;
    return '#DSP-$serial';
  }

  void confirmDispatch(DispatchmentRecord record) {
    _dispatchHistory.add(record);
  }

  void addShipment({
    required String id,
    required String status,
    required String date,
    required String time,
    required String assignedTo,
    required String phone,
    required String method,
  }) {
    _shipments.insert(0, {
      'id': id,
      'status': status,
      'date': date,
      'time': time,
      'assignedTo': assignedTo,
      'phone': phone,
      'method': method,
    });
  }

  void updateJob(Map<String, dynamic> values) {
    _job.addAll(values);
  }

  void setSpareLines(List<Map<String, String>> lines) {
    _job['spareLines'] = lines;
  }

  void startWorkTimer({DateTime? startedAt}) {
    if (_workStartedAt != null && _workTimerRunning) return;
    _workStartedAt = startedAt ?? DateTime.now();
    _workEndedAt = null;
    _workDuration = Duration.zero;
    _workTimerRunning = true;
    _job['startTime'] = _formatTimeOfDay(_workStartedAt!);
    _job['endTime'] = '';
    _job['duration'] = '00:00:00';
    _job['checkInTime'] = _formatTimeOfDay(_workStartedAt!);
  }

  void stopWorkTimer({DateTime? endedAt}) {
    if (_workStartedAt == null) return;
    _workEndedAt = endedAt ?? DateTime.now();
    _workDuration = _workEndedAt!.difference(_workStartedAt!);
    _workTimerRunning = false;
    _job['startTime'] = _formatTimeOfDay(_workStartedAt!);
    _job['endTime'] = _formatTimeOfDay(_workEndedAt!);
    _job['duration'] = _formatDuration(_workDuration);
  }

  void resetWorkTimer() {
    _workStartedAt = null;
    _workEndedAt = null;
    _workDuration = Duration.zero;
    _workTimerRunning = false;
    _job['startTime'] = '';
    _job['endTime'] = '';
    _job['duration'] = '';
  }

  void resetCheckInFlow() {
    resetWorkTimer();
    workDescription = '';
    beforeImageName = '';
    beforeImagePath = '';
    beforeImageBytes = null;
    afterImageName = '';
    afterImagePath = '';
    afterImageBytes = null;
    sparesUsedLabel = '';
    serviceChargeInput = '1';
    workStatus = 'Completed';
    nextVisitDate = null;
    oldSpareImageName = '';
    oldSpareImagePath = '';
    oldSpareImageBytes = null;
    signatureName = '';
    signaturePath = '';
    signatureBytes = null;
    otpChannel = '';
    standBy = true;
    _job['nextVisitDate'] = '';
    _job['spareLines'] = [];
  }

  String _formatTimeOfDay(DateTime time) {
    final hour = time.hour % 12 == 0 ? 12 : time.hour % 12;
    final minute = time.minute.toString().padLeft(2, '0');
    final period = time.hour >= 12 ? 'PM' : 'AM';
    return '$hour:$minute $period';
  }

  String _formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    final seconds = duration.inSeconds.remainder(60);
    return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }
}
