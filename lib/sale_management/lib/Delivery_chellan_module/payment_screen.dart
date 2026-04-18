import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../widgets/app_theme.dart';
import 'product_model.dart';
import 'selected_products_screen.dart';
import 'invoice_view_screen.dart';

class DeliveryChallanPaymentScreen extends StatefulWidget {
  final double totalAmount;
  final List<DeliveryChallanProduct> selectedProducts;
  final String taxType;
  final String priceType;

  const DeliveryChallanPaymentScreen({
    super.key,
    required this.totalAmount,
    required this.selectedProducts,
    this.taxType = 'IGST',
    this.priceType = 'Exclude tax',
    this.selectedCustomer,
  });

  final Map<String, dynamic>? selectedCustomer;
  @override
  State<DeliveryChallanPaymentScreen> createState() =>
      _DeliveryChallanPaymentScreenState();
}

class _DeliveryChallanPaymentScreenState
    extends State<DeliveryChallanPaymentScreen> {
  String _invoiceType = 'Retail';
  String? _taxType;
  String? _priceType;
  String _paymentMode = 'Cash';
  bool _tcsEnabled = false;
  bool _tdsEnabled = false;
  bool _markFullyPaid = false;
  DateTime _selectedDate = DateTime.now();
  bool   _advancedOpen  = false;
  Map<String, dynamic>? _selectedCustomer;
  final TextEditingController _customerSearchController = TextEditingController();
  List<dynamic> _allCustomers = [];
  List<dynamic> _filteredCustomers = [];
  bool _isFetchingCustomers = false;

  late TextEditingController _dcNoController;
  late TextEditingController _customerNameController;
  late TextEditingController _phoneController;

  late TextEditingController _referenceController;
  late TextEditingController _soNoController;
  late TextEditingController _vehicleNoController;
  late TextEditingController _transporterNameController;
  late TextEditingController _lrNoController;
  late TextEditingController _dispatchFromController;
  late TextEditingController _customerPoNoController;
  late TextEditingController _deliveryLocationController;

  DateTime _dispatchDate = DateTime.now();
  final DateTime _expectedDeliveryDate = DateTime.now();
  DateTime _orderDate = DateTime.now();
  final String _deliveryType = 'Road';
  bool _isSubmitting = false;

  Future<void> _submitDeliveryChallan() async {
    if (_isSubmitting) return;

    setState(() => _isSubmitting = true);

    try {
      final prefs = await SharedPreferences.getInstance();
      final cid = prefs.getString('cid') ?? '44555666';
      final uid = prefs.getString('uid') ?? '1';
      final lt = prefs.getString('lt') ?? '123';
      final ln = prefs.getString('ln') ?? '123';
      final deviceId = prefs.getString('device_id') ?? 'abc123';

      final Map<String, dynamic> metadata = {
        'dc_code': _dcNoController.text,
        'dc_date': _selectedDate.toString().split(' ')[0],
        'reference_type': 'Sales Order',
        'reference_no': _soNoController.text,
        'customer_po_no': _customerPoNoController.text,
        'order_date': _orderDate.toString().split(' ')[0],
        'delivery_type': _deliveryType,
        'delivery_location': _deliveryLocationController.text,
        'vehicle_no': _vehicleNoController.text,
        'transporter_name': _transporterNameController.text,
        'lr_no': _lrNoController.text,
        'dispatch_from': _dispatchFromController.text,
        'dispatch_date': _dispatchDate.toString().split(' ')[0],
        'expected_delivery_date':
            _expectedDeliveryDate.toString().split(' ')[0],
      };

      final s = summary;

      final List<Map<String, dynamic>> productsJson =
          widget.selectedProducts.map((p) {
        double taxableVal = (p.price * p.selectedQty) -
            (p.isPercentageDiscount
                ? (p.price * p.selectedQty * p.discountPercentage / 100)
                : (p.discountAmount * p.selectedQty));
        double taxVal = taxableVal * (p.taxRate ?? 0.18);
        double totalAmt = taxableVal + taxVal;

        return {
          "product_code": p.productCode ?? p.id,
          "product_name": p.name,
          "quantity": p.selectedQty,
          "uom": p.uom ?? "NOS",
          "batch_no": "",
          "hsn_code": p.hsnCode ?? "",
          "remarks": "",
          "uprice": p.price,
          "dis":
              p.isPercentageDiscount ? p.discountPercentage : p.discountAmount,
          "tax_val": p.taxRate ?? 18,
          "t_amt": totalAmt,
          "tax_tol": taxVal,
          "t_gst": taxVal,
          "g_tol": totalAmt,
          "cgst": taxVal / 2,
          "sgst": taxVal / 2,
          "igst": 0,
          "mtax": 0,
          "mtax_type": 0,
          "total_qty": p.selectedQty.toString(),
          "prepared_by": "Admin",
          "approved_by": "Manager"
        };
      }).toList();

      final Map<String, String> body = {
        'type': '8003',
        'cid': cid,
        'uid': uid,
        'lt': lt,
        'ln': ln,
        'device_id': deviceId,
        'dc_code': metadata['dc_code'] ?? '',
        'dc_date': metadata['dc_date'] ?? '',
        'reference_type': metadata['reference_type'] ?? 'Sales Order',
        'reference_no': metadata['reference_no'] ?? '',
        'customer_code': _selectedCustomer?['id']?.toString() ?? '',
        'customer_name': _selectedCustomer?['Ledger_Name'] ?? '',
        'customer_po_no': metadata['customer_po_no'] ?? '',
        'order_date': metadata['order_date'] ?? '',
        'delivery_type': metadata['delivery_type'] ?? 'Road',
        'delivery_location': metadata['delivery_location'] ?? '',
        'contact_person': _selectedCustomer?['Ledger_Name'] ?? '',
        'contact_phone': _selectedCustomer?['phone']?.toString() ?? '',
        'vehicle_no': metadata['vehicle_no'] ?? '',
        'transporter_name': metadata['transporter_name'] ?? '',
        'lr_no': metadata['lr_no'] ?? '',
        'dispatch_from': metadata['dispatch_from'] ?? 'Warehouse A',
        'dispatch_date': metadata['dispatch_date'] ?? '',
        'expected_delivery_date': metadata['expected_delivery_date'] ?? '',
        'prepared_by': "Admin",
        'approved_by': "Manager",
        'address': _selectedCustomer?['address'] ?? '',
        'status': 'active',
        'products': json.encode(productsJson),
      };

      final response = await http.post(
        Uri.parse('https://erpsmart.in/total/api/m_api/'),
        body: body,
      );

      final res = json.decode(response.body);
      debugPrint("Save Response: $res");

      if (res['error'] == false) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text(
                    res['error_msg'] ?? 'Delivery challan saved successfully')),
          );

          debugPrint("Navigating to ViewScreen with Customer: $_selectedCustomer");
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => DeliveryChallanViewScreen(
                selectedProducts: widget.selectedProducts,
                summary: s,
                selectedCustomer: _selectedCustomer,
                challanMetadata: body,
              ),
            ),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text(
                    res['error_msg'] ?? 'Failed to save delivery challan')),
          );
        }
      }
    } catch (e) {
      debugPrint("Error submitting delivery challan: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('An error occurred during submission')),
        );
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  Future<void> _fetchCustomers() async {
    if (!mounted) return;
    setState(() => _isFetchingCustomers = true);
    try {
      final prefs = await SharedPreferences.getInstance();
      final cid = prefs.getString('cid') ?? '44555666';
      final lt = prefs.getString('lt') ?? '123';
      final ln = prefs.getString('ln') ?? '123';
      final deviceId = prefs.getString('device_id') ?? '123';

      final response = await http.post(
        Uri.parse('https://erpsmart.in/total/api/m_api/'),
        body: {
          'type': '2083',
          'cid': cid,
          'lt': lt,
          'ln': ln,
          'device_id': deviceId,
          'form': 'sm_main_form_10002',
          'select': '*',
          'where': 'category=8',
        },
      );
      final data = json.decode(response.body);
      if (data['error'] == false) {
        if (!mounted) return;
        setState(() {
          _allCustomers = data['data'];
          _filteredCustomers = _allCustomers;
        });
      }
    } catch (e) {
      debugPrint("Error fetching customers: $e");
    } finally {
      if (!mounted) return;
      setState(() => _isFetchingCustomers = false);
    }
  }

  void _filterCustomers(String query) {
    setState(() {
      _filteredCustomers = _allCustomers
          .where((c) =>
              c['Ledger_Name']
                  .toString()
                  .toLowerCase()
                  .contains(query.toLowerCase()) ||
              c['id'].toString().contains(query))
          .toList();
    });
  }

  // ID Mappings
  final Map<String, String> _invoiceTypeIds = {};
  final Map<String, String> _priceTypeIds = {};
  final Map<String, String> _taxTypeIds = {};

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.primary,
              onPrimary: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _taxType = widget.taxType.trim().replaceAll(RegExp(r'\s+'), ' ');
    _priceType = widget.priceType.trim().replaceAll(RegExp(r'\s+'), ' ');

    _dcNoController = TextEditingController();
    _customerNameController = TextEditingController(
        text: widget.selectedCustomer?['Ledger_Name'] ?? '');
    _customerSearchController.text = widget.selectedCustomer?['Ledger_Name'] ?? '';
    _selectedCustomer = widget.selectedCustomer;
    _phoneController = TextEditingController(
        text: widget.selectedCustomer?['phone']?.toString() ?? '');

    _referenceController = TextEditingController();
    _soNoController = TextEditingController();
    _vehicleNoController = TextEditingController();
    _transporterNameController = TextEditingController();
    _lrNoController = TextEditingController();
    _dispatchFromController = TextEditingController(text: 'Warehouse A');
    _customerPoNoController = TextEditingController();
    _deliveryLocationController = TextEditingController();

    _fetchDCNumber();
    _fetchCustomers();
    _fetchAllDropdowns();
  }

  @override
  void dispose() {
    _dcNoController.dispose();
    _customerNameController.dispose();
    _customerSearchController.dispose();
    _phoneController.dispose();

    _referenceController.dispose();
    _soNoController.dispose();
    _vehicleNoController.dispose();
    _transporterNameController.dispose();
    _lrNoController.dispose();
    _dispatchFromController.dispose();
    _customerPoNoController.dispose();
    _deliveryLocationController.dispose();
    super.dispose();
  }

  Future<void> _fetchDCNumber() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cid = prefs.getString('cid') ?? '44555666';
      final lt = prefs.getString('lt') ?? '123';
      final ln = prefs.getString('ln') ?? '123';
      final deviceId = prefs.getString('device_id') ?? '123';

      final response = await http.post(
        Uri.parse('https://erpsmart.in/total/api/m_api/'),
        body: {
          'type': '8006',
          'cid': cid,
          'ln': ln,
          'lt': lt,
          'device_id': deviceId,
        },
      );

      final res = json.decode(response.body);
      bool isSuccess = (res['status'] == true) || (res['error'] == false);
      final generatedNumber = res['dc_no'];

      if (isSuccess && generatedNumber != null) {
        if (mounted) {
          setState(() {
            _dcNoController.text = generatedNumber.toString();
          });
        }
      }
    } catch (e) {
      debugPrint("Error fetching DC number: $e");
    }
  }

  void _fetchAllDropdowns() {
    _fetchDropdownData('17', _invoiceTypes, _invoiceTypeIds);
    _fetchDropdownData('16', _priceTypes, _priceTypeIds);
    _fetchDropdownData('26', _taxTypes, _taxTypeIds);
  }

  Future<void> _fetchDropdownData(String listId, List<String> targetList,
      Map<String, String> idMapping) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cid = prefs.getString('cid') ?? '44555666';
      final lt = prefs.getString('lt') ?? '123';
      final ln = prefs.getString('ln') ?? '123';
      final deviceId = prefs.getString('device_id') ?? '123';

      final response = await http.post(
        Uri.parse('https://erpsmart.in/total/api/m_api/'),
        body: {
          'type': '2084',
          'cid': cid,
          'lt': lt,
          'ln': ln,
          'device_id': deviceId,
          'list_id': listId,
        },
      );

      final res = json.decode(response.body);
      debugPrint("Dropdown List ID $listId response: $res");
      if (res['error'] == false && res['dropdown'] != null) {
        final List<dynamic> dropdownData = res['dropdown'];
        final Set<String> uniqueItems = {};
        final Map<String, String> newMapping = {};

        for (var item in dropdownData) {
          if (item['label'] != null) {
            String label =
                item['label'].toString().trim().replaceAll(RegExp(r'\s+'), ' ');
            String value =
                item['value']?.toString() ?? item['id']?.toString() ?? label;
            uniqueItems.add(label);
            newMapping[label] = value;
          }
        }

        if (uniqueItems.isNotEmpty) {
          if (mounted) {
            setState(() {
              targetList.clear();
              targetList.addAll(uniqueItems);
              idMapping.clear();
              idMapping.addAll(newMapping);

              // Ensure current values are still valid or reset them
              if (targetList == _taxTypes &&
                  _taxType != null &&
                  !targetList.contains(_taxType)) {
                _taxType = targetList.first;
              }
              if (targetList == _priceTypes &&
                  _priceType != null &&
                  !targetList.contains(_priceType)) {
                _priceType = targetList.first;
              }
              if (targetList == _invoiceTypes &&
                  !targetList.contains(_invoiceType)) {
                _invoiceType = targetList.first;
              }
            });
          }
        }
      }
    } catch (e) {
      debugPrint("Error fetching dropdown (listId $listId): $e");
    }
  }

  // Default: collapsed (eye-off, no avatar, just name)
  bool _customerExpanded = false;

  DeliveryChallanSummary get summary {
    double subtotal = 0;
    double totalDiscount = 0;

    for (var p in widget.selectedProducts) {
      subtotal += p.price * p.selectedQty;
      totalDiscount += p.isPercentageDiscount
          ? (p.price * (p.discountPercentage / 100) * p.selectedQty)
          : (p.discountAmount * p.selectedQty);
    }

    double taxableAmount = subtotal - totalDiscount;
    double igst = 0;
    double cgst = 0;
    double sgst = 0;
    double taxRate = 0.18;

    if (_taxType != 'None') {
      if (_priceType == 'Include tax') {
        double basePrice = taxableAmount / (1 + taxRate);
        double totalTax = taxableAmount - basePrice;
        if (_taxType == 'IGST') {
          igst = totalTax;
        } else {
          cgst = totalTax / 2;
          sgst = totalTax / 2;
        }
        taxableAmount = basePrice;
      } else {
        double totalTax = taxableAmount * taxRate;
        if (_taxType == 'IGST') {
          igst = totalTax;
        } else {
          cgst = totalTax / 2;
          sgst = totalTax / 2;
        }
      }
    }

    double shipping = 0.0;
    double tcs = 0.0;
    double tds = 0.0;

    double rawTotal = taxableAmount + igst + cgst + sgst + shipping + tcs - tds;
    double finalPayable = rawTotal.roundToDouble();
    double roundOff = finalPayable - rawTotal;

    return DeliveryChallanSummary(
      subtotal: subtotal,
      discount: totalDiscount,
      taxableAmount: taxableAmount,
      igst: igst,
      cgst: cgst,
      sgst: sgst,
      tcs: tcs,
      tds: tds,
      shippingCharges: shipping,
      finalPayable: finalPayable,
      taxType: _taxType ?? widget.taxType,
      priceType: _priceType ?? widget.priceType,
      roundOff: roundOff,
    );
  }

  final List<String> _invoiceTypes = [
    'Retail',
    'Wholesale B-B',
    'Bill of Supply',
    'Branch Supply',
    'CS Retail'
  ];
  final List<String> _taxTypes = ['IGST', 'CGST + SGST', 'None'];
  final List<String> _priceTypes = ['Exclude tax', 'Include tax'];
  final List<String> _paymentModes = ['Cash', 'UPI', 'NEFT', 'Cheque'];

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context);
    final sw = mq.size.width;
    final sh = mq.size.height;
    final hp = sw / 390;
    final vp = sh / 844;
    final sp = (sw / 390).clamp(0.8, 1.2);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        elevation: 0,
        leading: IconButton(
          icon:
              Icon(Icons.arrow_back, color: AppColors.textWhite, size: 22 * sp),
          onPressed: () => Navigator.maybePop(context),
        ),
        title: Text('Delivery Challan',
            style: TextStyle(
              color: AppColors.textWhite,
              fontSize: 18 * sp,
              fontWeight: FontWeight.w700,
              fontFamily: 'Poppins',
            )),
        systemOverlayStyle: const SystemUiOverlayStyle(
          statusBarColor: AppColors.primary,
          statusBarIconBrightness: Brightness.light,
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding:
                  EdgeInsets.symmetric(horizontal: 16 * hp, vertical: 14 * vp),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── 1. GENERAL INFORMATION ──────────────────────────────────
                  _SectionCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _SectionHeader(
                          icon: Icons.description_outlined,
                          iconColor: AppColors.blue,
                          label: 'General Information',
                          sp: sp,
                        ),
                        SizedBox(height: 14 * vp),

                        // ROW 1: DC No & Customer Name
                        Row(
                          children: [
                            Expanded(
                              child: 
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _FieldLabel('Dispatch Date', sp: sp),
                            SizedBox(height: 6 * vp),
                            GestureDetector(
                              onTap: () async {
                                final picked = await showDatePicker(
                                  context: context,
                                  initialDate: _dispatchDate,
                                  firstDate: DateTime(2000),
                                  lastDate: DateTime(2101),
                                );
                                if (picked != null)
                                  setState(() => _dispatchDate = picked);
                              },
                              child: _OutlinedField(
                                value:
                                    "${_dispatchDate.month}/${_dispatchDate.day}/${_dispatchDate.year}",
                                sp: sp,
                                hp: hp,
                                vp: vp,
                                trailing: Icon(Icons.calendar_today,
                                    size: 16 * sp, color: AppColors.blue),
                              ),
                            ),
                          ],
                        ),
                            ),
                            SizedBox(width: 10 * hp),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _FieldLabel('Type', sp: sp),
                                  SizedBox(height: 6 * vp),
                                  _OutlinedDropdown(
                                    value: _invoiceType,
                                    items: _invoiceTypes,
                                    sp: sp,
                                    hp: hp,
                                    vp: vp,
                                    onChanged: (v) =>
                                        setState(() => _invoiceType = v!),
                                  ),
                                ],
                              ),
                            )
                          ],
                        ),
                        SizedBox(height: 12 * vp),

                        // ROW 3: Date & Order Date
                        Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _FieldLabel('Date', sp: sp),
                                  SizedBox(height: 6 * vp),
                                  GestureDetector(
                                    onTap: () => _selectDate(context),
                                    child: _OutlinedField(
                                      value:
                                          "${_selectedDate.month}/${_selectedDate.day}/${_selectedDate.year}",
                                      sp: sp,
                                      hp: hp,
                                      vp: vp,
                                      trailing: Icon(Icons.calendar_today,
                                          size: 16 * sp, color: AppColors.blue),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(width: 10 * hp),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _FieldLabel('Order Date', sp: sp),
                                  SizedBox(height: 6 * vp),
                                  GestureDetector(
                                    onTap: () async {
                                      final picked = await showDatePicker(
                                        context: context,
                                        initialDate: _orderDate,
                                        firstDate: DateTime(2000),
                                        lastDate: DateTime(2101),
                                      );
                                      if (picked != null)
                                        setState(() => _orderDate = picked);
                                    },
                                    child: _OutlinedField(
                                      value:
                                          "${_orderDate.month}/${_orderDate.day}/${_orderDate.year}",
                                      sp: sp,
                                      hp: hp,
                                      vp: vp,
                                      trailing: Icon(Icons.calendar_today,
                                          size: 16 * sp, color: AppColors.blue),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 12 * vp),

                        // ROW 4: Tax Type & Price Type
                        Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _FieldLabel('Tax Type', sp: sp),
                                  SizedBox(height: 6 * vp),
                                  _OutlinedDropdown(
                                    value: _taxType ?? widget.taxType,
                                    items: _taxTypes,
                                    sp: sp,
                                    hp: hp,
                                    vp: vp,
                                    onChanged: (v) =>
                                        setState(() => _taxType = v!),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(width: 10 * hp),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _FieldLabel('Price Type', sp: sp),
                                  SizedBox(height: 6 * vp),
                                  _OutlinedDropdown(
                                    value: _priceType ?? widget.priceType,
                                    items: _priceTypes,
                                    sp: sp,
                                    hp: hp,
                                    vp: vp,
                                    onChanged: (v) =>
                                        setState(() => _priceType = v!),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 12 * vp),

                        
                      ],
                    ),
                  ),

                  SizedBox(height: 16 * vp),

                // ── 2. CUSTOMER DETAILS ─────────────────────────────────────
                  Row(
                    children: [
                      Icon(Icons.person, color: AppColors.textDark, size: 20 * sp),
                      SizedBox(width: 6 * hp),
                      Text('Customer Details',
                          style: TextStyle(
                            color: AppColors.textDark,
                            fontSize: 16 * sp,
                            fontWeight: FontWeight.w700,
                            fontFamily: 'Poppins',
                          )),
                      const Spacer(),
                      
                    ],
                  ),
                  SizedBox(height: 10 * vp),

                  // Search bar
                  if (_selectedCustomer == null)
                    Column(
                      children: [
                        Container(
                          height: 46 * vp,
                          decoration: BoxDecoration(
                            color: AppColors.bgCard,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: AppColors.divider),
                          ),
                          padding: EdgeInsets.symmetric(horizontal: 12 * hp),
                          child: Row(
                            children: [
                              Icon(Icons.search, color: AppColors.textMuted, size: 18 * sp),
                              SizedBox(width: 8 * hp),
                              Expanded(
                                child: TextField(
                                  controller: _customerSearchController,
                                  onChanged: _filterCustomers,
                                  style: TextStyle(
                                    fontSize: 13 * sp,
                                    color: AppColors.textDark,
                                    fontFamily: 'Poppins',
                                  ),
                                  decoration: InputDecoration(
                                    hintText: 'Select customer name or ID...',
                                    hintStyle: TextStyle(
                                      color: AppColors.textMuted,
                                      fontSize: 13 * sp,
                                      fontFamily: 'Poppins',
                                    ),
                                    border: InputBorder.none,
                                    isDense: true,
                                    contentPadding: EdgeInsets.zero,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (_customerSearchController.text.isNotEmpty && _selectedCustomer == null)
                          Container(
                            margin: const EdgeInsets.only(top: 4),
                            constraints: const BoxConstraints(maxHeight: 200),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(10),
                              boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4)],
                            ),
                            child: ListView.builder(
                              shrinkWrap: true,
                              padding: EdgeInsets.zero,
                              itemCount: _filteredCustomers.length,
                              itemBuilder: (context, index) {
                                final c = _filteredCustomers[index];
                                return ListTile(
                                  title: Text(c['Ledger_Name'] ?? '', style: TextStyle(fontSize: 14 * sp)),
                                  subtitle: Text('ID: ${c['id']}', style: TextStyle(fontSize: 12 * sp)),
                                  onTap: () {
                                    setState(() {
                                      _selectedCustomer = c;
                                      _customerSearchController.text = c['Ledger_Name'] ?? '';
                                    });
                                  },
                                );
                              },
                            ),
                          ),
                      ],
                    ),
                  SizedBox(height: 10 * vp),

                  // ── CUSTOMER CARD ────────────────────────────────────────────
                  // Collapsed  → Name + eye_off  (NO avatar)
                  // Expanded   → Name + eye_on + details below
                  Container(
                    decoration: BoxDecoration(
                      color: AppColors.bgCard,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: AppColors.divider),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.04),
                          blurRadius: 4,
                          offset: const Offset(0, 1),
                        ),
                      ],
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: Stack(
                      children: [
                        Positioned(
                          left: 0,
                          top: 0,
                          bottom: 0,
                          child: Container(
                            width: 3.5 * hp,
                            color: AppColors.blue,
                          ),
                        ),
                        Column(
                          children: [
                            ListTile(
                              contentPadding: EdgeInsets.symmetric(
                                horizontal: 12 * hp,
                                vertical: 2 * vp,
                              ),
                              leading: CircleAvatar(
                                backgroundColor: AppColors.blue.withOpacity(0.12),
                                radius: 18 * sp,
                                child: Icon(
                                  Icons.person,
                                  color: AppColors.blue,
                                  size: 20 * sp,
                                ),
                              ),
                              title: Text(
                                _selectedCustomer != null
                                    ? "${_selectedCustomer!['label'] ?? _selectedCustomer!['Ledger_Name']} - ${_selectedCustomer!['id']}"
                                    : 'Select Customer',
                                style: TextStyle(
                                  color: AppColors.textDark,
                                  fontSize: 14 * sp,
                                  fontWeight: FontWeight.w600,
                                  fontFamily: 'Poppins',
                                ),
                              ),
                                trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  if (_selectedCustomer != null)
                                    IconButton(
                                      icon: const Icon(Icons.close, size: 20, color: Colors.red),
                                      onPressed: () {
                                        setState(() {
                                          _selectedCustomer = null;
                                          _customerSearchController.clear();
                                        });
                                      },
                                    ),
                                  GestureDetector(
                                    onTap: () => setState(() => _customerExpanded = !_customerExpanded),
                                    child: Icon(
                                      _customerExpanded
                                          ? Icons.visibility_outlined
                                          : Icons.visibility_off_outlined,
                                      color: _customerExpanded ? const Color(0xFF0045BC) : AppColors.textMuted,
                                      size: 22 * sp,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                           
                           
                            AnimatedCrossFade(
                              duration: const Duration(milliseconds: 300),
                              crossFadeState: _customerExpanded
                                  ? CrossFadeState.showSecond
                                  : CrossFadeState.showFirst,
                              firstChild: const SizedBox.shrink(),
                              secondChild: Padding(
                                padding: EdgeInsets.fromLTRB(14 * hp, 0, 14 * hp, 14 * vp),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Divider(color: AppColors.divider, height: 1),
                                    SizedBox(height: 14 * vp),
                                    Row(
                                      children: [
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              _FieldLabel('Contact Person', sp: sp),
                                              SizedBox(height: 5 * vp),
                                              _OutlinedField(
                                                value: _selectedCustomer?['Ledger_Name'] ?? '',
                                                sp: sp, hp: hp, vp: vp
                                              ),
                                            ],
                                          ),
                                        ),
                                        SizedBox(width: 10 * hp),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              _FieldLabel('GST Number', sp: sp),
                                              SizedBox(height: 5 * vp),
                                              _OutlinedField(
                                                value: _selectedCustomer?['gst'] ?? '',
                                                sp: sp, hp: hp, vp: vp
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                    SizedBox(height: 12 * vp),
                                    _FieldLabel('Phone Number', sp: sp),
                                    SizedBox(height: 5 * vp),
                                    _OutlinedField(
                                      value: _selectedCustomer?['phone']?.toString() ?? _selectedCustomer?['Mobile']?.toString() ?? '',
                                      sp: sp, hp: hp, vp: vp
                                    ),
                                    SizedBox(height: 12 * vp),
                                    _FieldLabel('Billing Address', sp: sp),
                                    SizedBox(height: 5 * vp),
                                    Container(
                                      width: double.infinity,
                                      padding: EdgeInsets.symmetric(
                                          horizontal: 12 * hp, vertical: 10 * vp),
                                      decoration: BoxDecoration(
                                        color: AppColors.bgCardAlt,
                                        borderRadius: BorderRadius.circular(10),
                                        border: Border.all(color: AppColors.divider),
                                      ),
                                      child: Text(
                                        _selectedCustomer?['address'] ?? 'No address provided',
                                        style: TextStyle(
                                          color: AppColors.textDark,
                                          fontSize: 13 * sp,
                                          fontWeight: FontWeight.w500,
                                          fontFamily: 'Poppins',
                                          height: 1.5,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: 16 * vp),


                  // ── 3. PRODUCT ITEMS ────────────────────────────────────────
                  Row(
                    children: [
                      Icon(Icons.inventory_2_outlined,
                          color: AppColors.blue, size: 20 * sp),
                      SizedBox(width: 6 * hp),
                      Text('Product Items',
                          style: TextStyle(
                            color: AppColors.textDark,
                            fontSize: 16 * sp,
                            fontWeight: FontWeight.w700,
                            fontFamily: 'Poppins',
                          )),
                      SizedBox(width: 8 * hp),
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Icon(Icons.add_circle_outline,
                            color: AppColors.blue, size: 22 * sp),
                      ),
                      const Spacer(),
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  DeliveryChallanSelectedProductsScreen(
                                selectedProducts: widget.selectedProducts,
                                totalAmount: widget.totalAmount,
                                summary: summary,
                              ),
                            ),
                          );
                        },
                        child:
                            Text('view ${widget.selectedProducts.length} Items',
                                style: TextStyle(
                                  color: AppColors.blue,
                                  fontSize: 13 * sp,
                                  fontWeight: FontWeight.w600,
                                  fontFamily: 'Poppins',
                                )),
                      ),
                    ],
                  ),
                  SizedBox(height: 10 * vp),

                  // ── PRODUCT ITEMS (SINGLE CARD WITH DIVIDERS) ────────────────
                  Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF5F6F8),
                      borderRadius: BorderRadius.circular(12),
                      border:
                          Border.all(color: AppColors.divider.withOpacity(0.5)),
                    ),
                    child: Column(
                      children:
                          widget.selectedProducts.asMap().entries.map((entry) {
                        final index = entry.key;
                        final product = entry.value;

                        return Column(
                          children: [
                            Padding(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 14 * hp, vertical: 8 * vp),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(product.name,
                                                style: TextStyle(
                                                  color: AppColors.textDark,
                                                  fontSize: 14 * sp,
                                                  fontWeight: FontWeight.w600,
                                                  fontFamily: 'Poppins',
                                                )),
                                            Text(
                                                '₹${((product.price * product.selectedQty) - (product.isPercentageDiscount ? (product.price * product.selectedQty * product.discountPercentage / 100) : product.discountAmount)).toInt()}',
                                                style: TextStyle(
                                                  color: AppColors.green,
                                                  fontSize: 14 * sp,
                                                  fontWeight: FontWeight.w700,
                                                  fontFamily: 'Poppins',
                                                )),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            if (index < widget.selectedProducts.length - 1)
                              Divider(
                                color: AppColors.divider,
                                height: 1,
                                thickness: 1.5,
                                indent: 14 * hp,
                                endIndent: 14 * hp,
                              ),
                          ],
                        );
                      }).toList(),
                    ),
                  ),

                  SizedBox(height: 16 * vp),

                
                  // Text('Tax & Compliance',
                  //     style: TextStyle(
                  //       color: AppColors.textDark,
                  //       fontSize: 16 * sp,
                  //       fontWeight: FontWeight.w700,
                  //       fontFamily: 'Poppins',
                  //     )),
                  // SizedBox(height: 10 * vp),
                  // _TaxToggleCard(
                  //   iconBg: AppColors.blue.withOpacity(0.12),
                  //   icon: Icons.credit_card_outlined,
                  //   iconColor: AppColors.blue,
                  //   label: 'TCS',
                  //   rateLabel: 'Collected Rate',
                  //   rate: '0.1%',
                  //   enabled: _tcsEnabled,
                  //   sp: sp,
                  //   hp: hp,
                  //   vp: vp,
                  //   onChanged: (v) => setState(() => _tcsEnabled = v),
                  // ),
                  // SizedBox(height: 10 * vp),
                  // _TaxToggleCard(
                  //   iconBg: AppColors.red.withOpacity(0.12),
                  //   icon: Icons.receipt_long_outlined,
                  //   iconColor: AppColors.red,
                  //   label: 'TDS',
                  //   rateLabel: 'Deductible Rate',
                  //   rate: '1.0%',
                  //   enabled: _tdsEnabled,
                  //   sp: sp,
                  //   hp: hp,
                  //   vp: vp,
                  //   onChanged: (v) => setState(() => _tdsEnabled = v),
                  // ),
                  // SizedBox(height: 14 * vp),

                  // ── 5. ADVANCED OPTIONS ─────────────────────────────────────
                  GestureDetector(
                    onTap: () => setState(() => _advancedOpen = !_advancedOpen),
                    child: Container(
                      padding: EdgeInsets.symmetric(
                          horizontal: 14 * hp, vertical: 13 * vp),
                      decoration: BoxDecoration(
                        color: AppColors.bgCardAlt,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.divider),
                      ),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Icon(Icons.tune_rounded,
                                  color: AppColors.textMuted, size: 18 * sp),
                              SizedBox(width: 8 * hp),
                              Text('ADVANCED OPTIONS',
                                  style: TextStyle(
                                    color: AppColors.textMuted,
                                    fontSize: 12 * sp,
                                    fontWeight: FontWeight.w600,
                                    letterSpacing: 0.6,
                                    fontFamily: 'Poppins',
                                  )),
                              const Spacer(),
                              Icon(
                                _advancedOpen
                                    ? Icons.keyboard_arrow_up_rounded
                                    : Icons.keyboard_arrow_down_rounded,
                                color: AppColors.textMuted,
                                size: 20 * sp,
                              ),
                            ],
                          ),
                          if (_advancedOpen) ...[
                            SizedBox(height: 12 * vp),
                            const Divider(height: 1),
                            ListTile(
                              dense: true,
                              contentPadding: EdgeInsets.zero,
                              leading: Icon(Icons.local_shipping_outlined,
                                  color: AppColors.textMuted, size: 18 * sp),
                              title: Text('Select Dispatch Address',
                                  style: TextStyle(
                                      fontSize: 13 * sp,
                                      color: AppColors.textMuted,
                                      fontFamily: 'Poppins')),
                              onTap: () =>
                                  _showAddressPopup(context, sp, hp, vp),
                            ),
                            ListTile(
                              dense: true,
                              contentPadding: EdgeInsets.zero,
                              leading: Icon(Icons.document_scanner_outlined,
                                  color: AppColors.textMuted, size: 18 * sp),
                              title: Text('Add Reference',
                                  style: TextStyle(
                                      fontSize: 13 * sp,
                                      color: AppColors.textMuted,
                                      fontFamily: 'Poppins')),
                              onTap: () =>
                                  _showReferencePopup(context, sp, hp, vp),
                            ),
                            ListTile(
                              dense: true,
                              contentPadding: EdgeInsets.zero,
                              leading: Icon(Icons.percent,
                                  color: AppColors.textMuted, size: 18 * sp),
                              title: Text('Add Extra Discount',
                                  style: TextStyle(
                                      fontSize: 13 * sp,
                                      color: AppColors.textMuted,
                                      fontFamily: 'Poppins')),
                              onTap: () =>
                                  _showDiscountPopup(context, sp, hp, vp),
                            ),
                            ListTile(
                              dense: true,
                              contentPadding: EdgeInsets.zero,
                              leading: Icon(Icons.payments_outlined,
                                  color: AppColors.textMuted, size: 18 * sp),
                              title: Text('Delivery /Shipping Charges',
                                  style: TextStyle(
                                      fontSize: 13 * sp,
                                      color: AppColors.textMuted,
                                      fontFamily: 'Poppins')),
                              onTap: () =>
                                  _showShippingPopup(context, sp, hp, vp),
                            ),
                            ListTile(
                              dense: true,
                              contentPadding: EdgeInsets.zero,
                              leading: Icon(Icons.inventory_2_outlined,
                                  color: AppColors.textMuted, size: 18 * sp),
                              title: Text('Packing Charges',
                                  style: TextStyle(
                                      fontSize: 13 * sp,
                                      color: AppColors.textMuted,
                                      fontFamily: 'Poppins')),
                              onTap: () =>
                                  _showPackingPopup(context, sp, hp, vp),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 16 * vp),

                  // ── 6. PAYMENT ──────────────────────────────────────────────
                  Text('Payment',
                      style: TextStyle(
                        color: AppColors.textDark,
                        fontSize: 16 * sp,
                        fontWeight: FontWeight.w700,
                        fontFamily: 'Poppins',
                      )),
                  SizedBox(height: 10 * vp),
                  _SectionCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _FieldLabel('Amount Received', sp: sp),
                                  SizedBox(height: 6 * vp),
                                  _OutlinedField(
                                      value: '₹0.0', sp: sp, hp: hp, vp: vp),
                                ],
                              ),
                            ),
                            SizedBox(width: 10 * hp),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _FieldLabel('Payment Mode', sp: sp),
                                  SizedBox(height: 6 * vp),
                                  _OutlinedDropdown(
                                    value: _paymentMode,
                                    items: _paymentModes,
                                    sp: sp,
                                    hp: hp,
                                    vp: vp,
                                    onChanged: (v) =>
                                        setState(() => _paymentMode = v!),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 12 * vp),
                        _FieldLabel('Notes', sp: sp),
                        SizedBox(height: 6 * vp),
                        Container(
                          width: double.infinity,
                          padding: EdgeInsets.symmetric(
                              horizontal: 12 * hp, vertical: 12 * vp),
                          decoration: BoxDecoration(
                            color: AppColors.bgCardAlt,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: AppColors.divider),
                          ),
                          child: Text('Add Notes',
                              style: TextStyle(
                                color: AppColors.textMuted,
                                fontSize: 13 * sp,
                                fontFamily: 'Poppins',
                              )),
                        ),
                        SizedBox(height: 14 * vp),
                        Row(
                          children: [
                            Container(
                              width: 26 * hp,
                              height: 26 * hp,
                              decoration: const BoxDecoration(
                                color: AppColors.green,
                                shape: BoxShape.circle,
                              ),
                              child: Icon(Icons.check,
                                  color: Colors.white, size: 15 * sp),
                            ),
                            SizedBox(width: 10 * hp),
                            Text('Mark as fully paid',
                                style: TextStyle(
                                  color: AppColors.textDark,
                                  fontSize: 14 * sp,
                                  fontWeight: FontWeight.w500,
                                  fontFamily: 'Poppins',
                                )),
                            const Spacer(),
                            Switch.adaptive(
                              value: _markFullyPaid,
                              activeColor: AppColors.primary,
                              onChanged: (v) =>
                                  setState(() => _markFullyPaid = v),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 20 * vp),
                ],
              ),
            ),
          ),
          _BottomBar(
            sp: sp,
            hp: hp,
            vp: vp,
            summary: summary,
            selectedProducts: widget.selectedProducts,
            selectedCustomer: widget.selectedCustomer,
            onTap: _submitDeliveryChallan,
            isLoading: _isSubmitting,
          ),
        ],
      ),
    );
  }

  void _showDiscountPopup(
      BuildContext context, double sp, double hp, double vp) {
    String discountType = '%'; // Local state for the popup

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setPopupState) {
            return Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              padding:
                  EdgeInsets.symmetric(horizontal: 20 * hp, vertical: 20 * vp),
              child: Padding(
                padding: EdgeInsets.only(
                    bottom: MediaQuery.of(context).viewInsets.bottom),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 40 * hp,
                        height: 4 * vp,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade300,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    SizedBox(height: 12 * vp),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Add Extra Discount',
                            style: TextStyle(
                              fontSize: 16 * sp,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'Poppins',
                            )),
                        IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ],
                    ),
                    const Divider(),
                    SizedBox(height: 16 * vp),
                    Text('Select Discount Type',
                        style: TextStyle(
                          color: AppColors.textDark,
                          fontSize: 13 * sp,
                          fontWeight: FontWeight.w600,
                          fontFamily: 'Poppins',
                        )),
                    SizedBox(height: 12 * vp),
                    Row(
                      children: [
                        _discountTypeOption('%', discountType, sp, (val) {
                          setPopupState(() => discountType = val);
                        }),
                        SizedBox(width: 16 * hp),
                        _discountTypeOption('₹', discountType, sp, (val) {
                          setPopupState(() => discountType = val);
                        }),
                      ],
                    ),
                    SizedBox(height: 20 * vp),
                    _popupLabelField('Discount Value',
                        discountType == '%' ? '0' : '₹ 0', sp, hp, vp),
                    SizedBox(height: 32 * vp),
                    SizedBox(
                      width: double.infinity,
                      height: 50 * vp,
                      child: ElevatedButton(
                        onPressed: () => Navigator.pop(context),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8)),
                        ),
                        child: Text('Save',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 15 * sp,
                              fontFamily: 'Poppins',
                            )),
                      ),
                    ),
                    SizedBox(height: 10 * vp),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _discountTypeOption(
      String label, String current, double sp, Function(String) onTap) {
    bool isSelected = current == label;
    return GestureDetector(
      onTap: () => onTap(label),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 20 * sp,
            height: 20 * sp,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: isSelected ? AppColors.primary : AppColors.textMuted,
                width: 2,
              ),
            ),
            child: isSelected
                ? Center(
                    child: Container(
                      width: 10 * sp,
                      height: 10 * sp,
                      decoration: const BoxDecoration(
                        color: AppColors.primary,
                        shape: BoxShape.circle,
                      ),
                    ),
                  )
                : null,
          ),
          const SizedBox(width: 8),
          Text(label,
              style: TextStyle(
                color: AppColors.textDark,
                fontSize: 14 * sp,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                fontFamily: 'Poppins',
              )),
        ],
      ),
    );
  }

  void _showShippingPopup(
      BuildContext context, double sp, double hp, double vp) {
    _showGenericPopup(
        context,
        'Delivery / Shipping Charges',
        [
          _popupLabelField('Delivery Charge Value', '₹', sp, hp, vp,
              showArrow: true),
          SizedBox(height: 16 * vp),
          _popupLabelField('Tax %', '0', sp, hp, vp, showArrow: true),
          SizedBox(height: 16 * vp),
          _popupLabelField('Charges in ₹', '0.0', sp, hp, vp, showArrow: true),
          SizedBox(height: 16 * vp),
          _popupLabelField('', 'Without Tax', sp, hp, vp, showArrow: true),
        ],
        sp,
        hp,
        vp);
  }

  void _showPackingPopup(
      BuildContext context, double sp, double hp, double vp) {
    _showGenericPopup(
        context,
        'Packing Charges',
        [
          _popupLabelField('Delivery Charge Value', '%', sp, hp, vp,
              showArrow: true),
          SizedBox(height: 16 * vp),
          _popupLabelField('Tax %', '0', sp, hp, vp, showArrow: true),
          SizedBox(height: 16 * vp),
          _popupLabelField('Charges in %', '0.0', sp, hp, vp, showArrow: true),
          SizedBox(height: 16 * vp),
          _popupLabelField('', 'Without Tax', sp, hp, vp, showArrow: true),
        ],
        sp,
        hp,
        vp);
  }

  void _showGenericPopup(BuildContext context, String title,
      List<Widget> children, double sp, double hp, double vp) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
          padding: EdgeInsets.symmetric(horizontal: 20 * hp, vertical: 20 * vp),
          child: Padding(
            padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                    child: Container(
                        width: 40 * hp,
                        height: 4 * vp,
                        decoration: BoxDecoration(
                            color: Colors.grey.shade300,
                            borderRadius: BorderRadius.circular(2)))),
                SizedBox(height: 12 * vp),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(title,
                        style: TextStyle(
                            fontSize: 16 * sp,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Poppins')),
                    IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.pop(context)),
                  ],
                ),
                const Divider(),
                SizedBox(height: 16 * vp),
                ...children,
                SizedBox(height: 32 * vp),
                SizedBox(
                  width: double.infinity,
                  height: 50 * vp,
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8))),
                    child: Text('Save',
                        style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 15 * sp,
                            fontFamily: 'Poppins')),
                  ),
                ),
                SizedBox(height: 10 * vp),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _popupLabelField(
      String label, String value, double sp, double hp, double vp,
      {bool showArrow = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label.isNotEmpty) ...[
          Text(label,
              style: TextStyle(
                  color: Colors.black87,
                  fontSize: 13 * sp,
                  fontWeight: FontWeight.w500,
                  fontFamily: 'Poppins')),
          SizedBox(height: 8 * vp),
        ],
        Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(horizontal: 16 * hp, vertical: 12 * vp),
          decoration: BoxDecoration(
              color: const Color(0xFFF2F4F6),
              borderRadius: BorderRadius.circular(10)),
          child: Row(
            children: [
              Text(value,
                  style: TextStyle(
                      color: Colors.black87,
                      fontSize: 14 * sp,
                      fontWeight: FontWeight.w500,
                      fontFamily: 'Poppins')),
              if (showArrow) ...[
                const Spacer(),
                Icon(Icons.arrow_drop_down,
                    color: Colors.black87, size: 20 * sp),
              ],
            ],
          ),
        ),
      ],
    );
  }

  void _showReferencePopup(
      BuildContext context, double sp, double hp, double vp) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          padding: EdgeInsets.symmetric(horizontal: 20 * hp, vertical: 20 * vp),
          child: Padding(
            padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40 * hp,
                    height: 4 * vp,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                SizedBox(height: 12 * vp),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Add Reference',
                        style: TextStyle(
                            fontSize: 16 * sp,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Poppins')),
                    IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.pop(context)),
                  ],
                ),
                const Divider(),
                SizedBox(height: 16 * vp),
                _popupField('Reference', sp, hp, vp),
                SizedBox(height: 24 * vp),
                SizedBox(
                  width: double.infinity,
                  height: 50 * vp,
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8)),
                    ),
                    child: Text('Submit',
                        style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 15 * sp,
                            fontFamily: 'Poppins')),
                  ),
                ),
                SizedBox(height: 10 * vp),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showAddressPopup(
      BuildContext context, double sp, double hp, double vp) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          padding: EdgeInsets.symmetric(horizontal: 20 * hp, vertical: 20 * vp),
          child: Padding(
            padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40 * hp,
                    height: 4 * vp,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                SizedBox(height: 12 * vp),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Enter Address',
                        style: TextStyle(
                            fontSize: 16 * sp,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Poppins')),
                    IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.pop(context)),
                  ],
                ),
                const Divider(),
                SizedBox(height: 16 * vp),
                _popupField('Title', sp, hp, vp),
                SizedBox(height: 8 * vp),
                Text('Autofill Company Name',
                    style: TextStyle(
                        color: const Color(0xFF005BBF),
                        fontSize: 11 * sp,
                        fontWeight: FontWeight.w600,
                        fontFamily: 'Poppins')),
                SizedBox(height: 16 * vp),
                Row(
                  children: [
                    Expanded(
                        child: _popupField('Address line 1 *', sp, hp, vp)),
                    SizedBox(width: 12 * hp),
                    Expanded(
                        child: _popupField('Address line 2 *', sp, hp, vp)),
                  ],
                ),
                SizedBox(height: 16 * vp),
                Row(
                  children: [
                    Expanded(child: _popupField('City', sp, hp, vp)),
                    SizedBox(width: 12 * hp),
                    Expanded(child: _popupField('State *', sp, hp, vp)),
                  ],
                ),
                SizedBox(height: 16 * vp),
                _popupField('Pincode *', sp, hp, vp),
                SizedBox(height: 24 * vp),
                SizedBox(
                  width: double.infinity,
                  height: 50 * vp,
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8)),
                    ),
                    child: Text('Save & Update',
                        style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 15 * sp,
                            fontFamily: 'Poppins')),
                  ),
                ),
                SizedBox(height: 10 * vp),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _popupField(String hint, double sp, double hp, double vp) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 16 * hp, vertical: 12 * vp),
      decoration: BoxDecoration(
        color: const Color(0xFFF2F4F6),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        hint,
        style: TextStyle(
            color: Colors.grey.shade600,
            fontSize: 13 * sp,
            fontWeight: FontWeight.w500,
            fontFamily: 'Poppins'),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
//  REUSABLE WIDGETS
// ═══════════════════════════════════════════════════════════════════════════════

class _SectionCard extends StatelessWidget {
  const _SectionCard({required this.child});
  final Widget child;
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.divider),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: child,
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.sp,
  });
  final IconData icon;
  final Color iconColor;
  final String label;
  final double sp;
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: iconColor, size: 20 * sp),
        const SizedBox(width: 8),
        Text(label,
            style: TextStyle(
              color: AppColors.textDark,
              fontSize: 16 * sp,
              fontWeight: FontWeight.w700,
              fontFamily: 'Poppins',
            )),
      ],
    );
  }
}

class _FieldLabel extends StatelessWidget {
  const _FieldLabel(this.text, {required this.sp});
  final String text;
  final double sp;
  @override
  Widget build(BuildContext context) {
    return Text(text,
        style: TextStyle(
          color: AppColors.textMuted,
          fontSize: 12 * sp,
          fontWeight: FontWeight.w400,
          fontFamily: 'Poppins',
        ));
  }
}

class _OutlinedDropdown extends StatelessWidget {
  const _OutlinedDropdown({
    required this.value,
    required this.items,
    required this.sp,
    required this.hp,
    required this.vp,
    required this.onChanged,
  });
  final String value;
  final List<String> items;
  final double sp, hp, vp;
  final ValueChanged<String?> onChanged;

  @override
  Widget build(BuildContext context) {
    final normalizedValue = value.trim().replaceAll(RegExp(r'\s+'), ' ');
    final normalizedItems =
        items.map((e) => e.trim().replaceAll(RegExp(r'\s+'), ' ')).toList();

    return Container(
      height: 48 * vp,
      padding: EdgeInsets.symmetric(horizontal: 12 * hp),
      decoration: BoxDecoration(
        color: AppColors.bgCardAlt,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.divider),
      ),
      child: DropdownButton<String>(
        value: normalizedItems.contains(normalizedValue)
            ? normalizedValue
            : (normalizedItems.isNotEmpty ? normalizedItems.first : null),
        isExpanded: true,
        underline: const SizedBox(),
        icon: Icon(Icons.keyboard_arrow_down_rounded,
            color: AppColors.textMuted, size: 20 * sp),
        style: TextStyle(
          color: AppColors.textDark,
          fontSize: 14 * sp,
          fontWeight: FontWeight.w500,
          fontFamily: 'Poppins',
        ),
        items: normalizedItems
            .map((e) => DropdownMenuItem(
                  value: e,
                  child: Text(e,
                      style: TextStyle(
                        fontSize: 14 * sp,
                        fontFamily: 'Poppins',
                        color: AppColors.textDark,
                      )),
                ))
            .toList(),
        onChanged: onChanged,
      ),
    );
  }
}

class _OutlinedField extends StatelessWidget {
  const _OutlinedField({
    this.value,
    this.hint,
    this.trailing,
    this.controller,
    this.maxLines = 1,
    this.height,
    required this.sp,
    required this.hp,
    required this.vp,
  });
  final String? value;
  final String? hint;
  final Widget? trailing;
  final TextEditingController? controller;
  final int maxLines;
  final double? height;
  final double sp, hp, vp;
  @override
  Widget build(BuildContext context) {
    return Container(
      height: height ?? (maxLines > 1 ? null : 48 * vp),
      alignment: maxLines > 1 ? Alignment.topLeft : Alignment.centerLeft,
      padding: EdgeInsets.symmetric(
          horizontal: 12 * hp, vertical: maxLines > 1 ? 12 * vp : 0),
      decoration: BoxDecoration(
        color: AppColors.bgCardAlt,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.divider),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment:
            maxLines > 1 ? CrossAxisAlignment.start : CrossAxisAlignment.center,
        children: [
          Expanded(
            child: value != null
                ? Text(value!,
                    maxLines: maxLines,
                    style: TextStyle(
                      color: AppColors.textDark,
                      fontSize: 13 * sp,
                      fontWeight: FontWeight.w500,
                      fontFamily: 'Poppins',
                    ))
                : TextField(
                    controller: controller,
                    maxLines: maxLines,
                    decoration: InputDecoration(
                      hintText: hint,
                      hintStyle: TextStyle(
                        color: AppColors.textLight.withOpacity(0.5),
                        fontSize: 13 * sp,
                        fontFamily: 'Poppins',
                      ),
                      border: InputBorder.none,
                      isDense: true,
                      contentPadding: EdgeInsets.zero,
                    ),
                    style: TextStyle(
                      color: AppColors.textDark,
                      fontSize: 13 * sp,
                      fontWeight: FontWeight.w500,
                      fontFamily: 'Poppins',
                    ),
                  ),
          ),
          if (trailing != null) trailing!,
        ],
      ),
    );
  }
}

class _TaxToggleCard extends StatelessWidget {
  const _TaxToggleCard({
    required this.iconBg,
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.rateLabel,
    required this.rate,
    required this.enabled,
    required this.sp,
    required this.hp,
    required this.vp,
    required this.onChanged,
  });
  final Color iconBg, iconColor;
  final IconData icon;
  final String label, rateLabel, rate;
  final bool enabled;
  final double sp, hp, vp;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 14 * hp, vertical: 14 * vp),
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.divider),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 36 * hp,
                height: 36 * hp,
                decoration: BoxDecoration(
                    color: iconBg, borderRadius: BorderRadius.circular(8)),
                child: Icon(icon, color: iconColor, size: 18 * sp),
              ),
              SizedBox(width: 10 * hp),
              Text(label,
                  style: TextStyle(
                    color: AppColors.textDark,
                    fontSize: 15 * sp,
                    fontWeight: FontWeight.w700,
                    fontFamily: 'Poppins',
                  )),
              const Spacer(),
              Switch.adaptive(
                value: enabled,
                activeColor: AppColors.primary,
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                onChanged: onChanged,
              ),
            ],
          ),
          Padding(
            padding: EdgeInsets.symmetric(vertical: 10 * vp),
            child: const Divider(color: AppColors.divider, height: 1),
          ),
          Row(
            children: [
              Text(rateLabel,
                  style: TextStyle(
                    color: AppColors.textLight,
                    fontSize: 13 * sp,
                    fontFamily: 'Poppins',
                  )),
              const Spacer(),
              Container(
                padding:
                    EdgeInsets.symmetric(horizontal: 12 * hp, vertical: 5 * vp),
                decoration: BoxDecoration(
                  color: AppColors.bgCardAlt,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.divider),
                ),
                child: Text(rate,
                    style: TextStyle(
                      color: AppColors.textDark,
                      fontSize: 13 * sp,
                      fontWeight: FontWeight.w600,
                      fontFamily: 'Poppins',
                    )),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _BottomBar extends StatelessWidget {
  const _BottomBar({
    required this.sp,
    required this.hp,
    required this.vp,
    required this.summary,
    required this.selectedProducts,
    this.selectedCustomer,
    required this.onTap,
    this.isLoading = false,
  });
  final double sp, hp, vp;
  final DeliveryChallanSummary summary;
  final List<DeliveryChallanProduct> selectedProducts;
  final Map<String, dynamic>? selectedCustomer;
  final VoidCallback onTap;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(
        20 * hp,
        14 * vp,
        20 * hp,
        14 * vp + MediaQuery.of(context).padding.bottom,
      ),
      color: AppColors.primary,
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Taxable : ₹${summary.taxableAmount.toInt()}',
                    style: TextStyle(
                      color: AppColors.textWhite,
                      fontSize: 12 * sp,
                      fontWeight: FontWeight.w500,
                      fontFamily: 'Poppins',
                    )),
                SizedBox(height: 4 * vp),
                Text('Total : ₹${summary.finalPayable.toInt()}',
                    style: TextStyle(
                      color: AppColors.textWhite,
                      fontSize: 14 * sp,
                      fontWeight: FontWeight.w700,
                      fontFamily: 'Poppins',
                    )),
              ],
            ),
          ),
          GestureDetector(
            onTap: onTap,
            child: Container(
              padding:
                  EdgeInsets.symmetric(horizontal: 22 * hp, vertical: 12 * vp),
              decoration: BoxDecoration(
                color: AppColors.bgCard,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppColors.textWhite.withOpacity(0.3)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (isLoading)
                    SizedBox(
                      width: 14 * sp,
                      height: 14 * sp,
                      child: CircularProgressIndicator(
                        color: AppColors.primary,
                        strokeWidth: 2,
                      ),
                    )
                  else ...[
                    Text('Create',
                        style: TextStyle(
                          color: AppColors.primary,
                          fontSize: 14 * sp,
                          fontWeight: FontWeight.w700,
                          fontFamily: 'Poppins',
                        )),
                    SizedBox(width: 6 * hp),
                    Icon(Icons.arrow_forward_ios_rounded,
                        color: AppColors.primary, size: 14 * sp),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
