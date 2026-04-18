import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../widgets/app_theme.dart';
import 'product_model.dart';
import 'selected_products_screen.dart';
import 'invoice_view_screen.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';



class SalesOrderPaymentScreen extends StatefulWidget {
  final double totalAmount;
  final List<SalesOrderProduct> selectedProducts;
  final Map<String, dynamic>? selectedCustomer;

  const SalesOrderPaymentScreen({
    super.key,
    required this.totalAmount,
    required this.selectedProducts,
    this.selectedCustomer,
  });
  @override
  State<SalesOrderPaymentScreen> createState() => _SalesOrderPaymentScreenState();
}
class _SalesOrderPaymentScreenState extends State<SalesOrderPaymentScreen> {
  // Controllers
  final TextEditingController _customerSearchController = TextEditingController();
  final TextEditingController _amountController         = TextEditingController();
  final TextEditingController _notesController          = TextEditingController();

  Map<String, dynamic>? _selectedCustomer;
  List<dynamic> _allCustomers      = [];
  List<dynamic> _filteredCustomers = [];
  bool _isFetchingCustomers        = false;
  bool _isSubmitting               = false;

  String _invoiceType   = 'Tax Invoice';
  String _taxType       = 'IGST';
  String _priceType     = 'Exclude tax';
  String _paymentMode   = 'Cash';
  bool   _tcsEnabled    = false;
  bool   _tdsEnabled    = false;
  bool   _markFullyPaid = false;
  bool   _advancedOpen  = false;
  String _orderNo       = '';

  DateTime _deliveryDate = DateTime.now();
  String _invoiceDate = DateTime.now().toString().split(' ').first;
  final TextEditingController _referenceController = TextEditingController();

  // ID Mappings
  final Map<String, String> _invoiceTypeIds = {};
  final Map<String, String> _priceTypeIds = {};
  final Map<String, String> _taxTypeIds = {};

  // Default: collapsed (eye-off, no avatar, just name)
  bool _customerExpanded = false;

  @override
  void initState() {
    super.initState();
    _selectedCustomer = widget.selectedCustomer;
    _fetchCustomers();
    _fetchAllDropdowns();
    _fetchOrderNumber();
  }

  Future<void> _fetchOrderNumber() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cid = prefs.getString('cid') ?? '44555666';
      final lt = prefs.getString('lt') ?? '123';
      final ln = prefs.getString('ln') ?? '123';
      final deviceId = prefs.getString('device_id') ?? '123';

      final response = await http.post(
        Uri.parse('https://erpsmart.in/total/api/m_api/'),
        body: {
          'type': '4019',
          'cid': cid,
          'lt': lt,
          'ln': ln,
          'device_id': deviceId,
        },
      );

      final res = json.decode(response.body);
      bool isSuccess = (res['error'] == false) || (res['status'] == true);
      final generatedNumber = res['order_no'] ?? res['quotation_number'] ?? res['invoice_no'];
      
      if (isSuccess && generatedNumber != null) {
        if (mounted) {
          setState(() {
            _orderNo = generatedNumber.toString();
          });
        }
      }
    } catch (e) {
      debugPrint("Error fetching order number: $e");
    }
  }

  void _fetchAllDropdowns() {
    _fetchDropdownData('17', _invoiceTypes, _invoiceTypeIds);
    _fetchDropdownData('16', _priceTypes, _priceTypeIds);
    _fetchDropdownData('26', _taxTypes, _taxTypeIds);
  }

  Future<void> _fetchDropdownData(String listId, List<String> targetList, Map<String, String> idMapping) async {
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
            String label = item['label'].toString().trim();
            String value = item['value']?.toString() ?? item['id']?.toString() ?? label;
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
            });
          }
        }
      }
    } catch (e) {
      debugPrint("Error fetching dropdown (listId $listId): $e");
    }
  }

  @override
  void dispose() {
    _customerSearchController.dispose();
    _amountController.dispose();
    _notesController.dispose();
    _referenceController.dispose();
    super.dispose();
  }

  Future<void> _selectDeliveryDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _deliveryDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF0045BC),
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
        _deliveryDate = picked;
      });
    }
  }

  Future<void> _fetchCustomers() async {
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
        setState(() {
          _allCustomers = data['data'];
          _filteredCustomers = _allCustomers;
        });
      }
    } catch (e) {
      debugPrint("❌ Error fetching customers: $e");
    } finally {
      setState(() => _isFetchingCustomers = false);
    }
  }

  void _filterCustomers(String q) {
    setState(() {
      _filteredCustomers = _allCustomers
          .where((c) => (c['Ledger_Name'] ?? '')
              .toString()
              .toLowerCase()
              .contains(q.toLowerCase()))
          .toList();
    });
  }

  Future<void> _submitSalesOrder() async {
    setState(() => _isSubmitting = true);

    // Summary calculations (mirroring invoice_view_screen)
    double totalSubtotal = 0;
    double totalDiscount = 0;
    for (var p in widget.selectedProducts) {
      totalSubtotal += p.price * p.selectedQty;
      totalDiscount += p.isPercentageDiscount
          ? (p.price * (p.discountPercentage / 100) * p.selectedQty)
          : (p.discountAmount * p.selectedQty);
    }

    final double taxableAmount = totalSubtotal - totalDiscount;
    final double tax           = taxableAmount * 0.18;
    final double tcs           = 0;
    final double tds           = 0;
    final double rawTotal      = taxableAmount + tax; // Removed tcs and tds
    final double finalPayable  = rawTotal.roundToDouble();
    final double roundOff      = finalPayable - rawTotal;

    final String invoiceDate = DateTime.now().toString().split(' ').first;
    final String orderNo = _orderNo.isNotEmpty 
        ? _orderNo 
        : 'ORD-${DateTime.now().millisecondsSinceEpoch}';
    final String cusId = _selectedCustomer?['id']?.toString() ?? '3';
    final String cusName = _selectedCustomer?['Ledger_Name'] ?? 'Unknown';

    final prefs = await SharedPreferences.getInstance();
    final cid = prefs.getString('cid') ?? '44555666';
    final lt = prefs.getString('lt') ?? '145';
    final ln = prefs.getString('ln') ?? '145';
    final deviceId = prefs.getString('device_id') ?? '12345';
    final uid = prefs.getString('uid') ?? '1';
    final bid = prefs.getString('bid') ?? '1';
    final roleId = prefs.getString('role_id') ?? '1';
    final token = prefs.getString('token') ?? 'ghvki23';

    final List<Map<String, dynamic>> productsJson = widget.selectedProducts.map((p) => {
      "cid": cid,
      "uid": uid,
      "bid": bid,
      "type": "2",
      "date": invoiceDate,
      "order_no": orderNo,
      "cust_name": cusName,
      "cus_id": cusId,
      "product_id": "14", // default or fetch from your model
      "product_name": p.name,
      "hsn": "1234",
      "quantity": p.selectedQty,
      "uom": p.category ?? "5",
      "discount": p.isPercentageDiscount ? p.discountPercentage : p.discountAmount,
      "unit_price": p.price,
      "taxable_value": p.price * p.selectedQty,
      "total_amount": (p.isPercentageDiscount 
          ? (p.price * (1 - p.discountPercentage / 100) * p.selectedQty)
          : ((p.price - p.discountAmount) * p.selectedQty)),
    }).toList();

    final firstProduct = widget.selectedProducts.isNotEmpty ? widget.selectedProducts.first : null;

    final Map<String, dynamic> body = {
      'type': '8001',
      'cid': cid,
      'uid': uid,
      'bid': bid,
      'ln': ln,
      'lt': lt,
      'device_id': deviceId,
      'order_type': '2',
      'cus_id': cusId,
      'invoice_no': orderNo,
      'date': invoiceDate,
      'customer_name': cusName,
      'customer_gstin': _selectedCustomer?['gst']?.toString() ?? '',
      'address': _selectedCustomer?['address']?.toString() ?? '',
      'price_type': _priceTypeIds[_priceType]?.toString() ?? '1',
      'tax_type': _taxTypeIds[_taxType]?.toString() ?? '2',
      'grand_total': finalPayable.toString(),
      'taxable_total': taxableAmount.toString(),
      'total_gst': tax.toString(),
      'cgst': (tax/2).toString(),
      'sgst': (tax/2).toString(),
      'igst': '0',        
      'round_off': roundOff.toString(),
      'tds': '0',
      'tds_type': '25',
      'tcs': '0',
      'tcs_type': '35',
      'delivery_date': "${_deliveryDate.year}-${_deliveryDate.month.toString().padLeft(2, '0')}-${_deliveryDate.day.toString().padLeft(2, '0')}", 
      'reference': _referenceController.text,
      'product_name': firstProduct?.name ?? '',
      'hsn': '1234',
      'quantity': firstProduct?.selectedQty.toString() ?? '0',
      'discount': firstProduct != null ? (firstProduct.isPercentageDiscount ? firstProduct.discountPercentage : firstProduct.discountAmount).toString() : '0',
      'uprice': firstProduct?.price.toString() ?? '0',
      'tax_value': firstProduct != null ? (firstProduct.price * firstProduct.selectedQty).toString() : '0',
      'tax_amount': firstProduct != null ? ((firstProduct.isPercentageDiscount 
          ? (firstProduct.price * (1 - firstProduct.discountPercentage / 100) * firstProduct.selectedQty)
          : ((firstProduct.price - firstProduct.discountAmount) * firstProduct.selectedQty))).toString() : '0',
      'role_id': roleId,
      'token': token,
      'products': json.encode(productsJson),
    };

    // Optimized Log Output - Only first 2 products
    final Map<String, dynamic> debugBody = Map.from(body);
    if (productsJson.length > 2) {
      debugBody['products'] = "${productsJson.take(2).toList()} ... and ${productsJson.length - 2} more items";
    }

    debugPrint("\n================ SUBMIT SALES ORDER REQUEST ================");
    debugPrint("URL: https://erpsmart.in/total/api/m_api/");
    debugPrint("BODY: $debugBody");
    debugPrint("============================================================\n");

    try {
      final response = await http.post(
        Uri.parse('https://erpsmart.in/total/api/m_api/'),
        body: body,
      );
      final res = json.decode(response.body);
      debugPrint("sales order Response: $res");

      if (res['error'] == false) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(res['error_msg'] ?? "Sales Order Saved"), backgroundColor: AppColors.green),
          );
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => SalesOrderInvoiceViewScreen(
                selectedProducts: widget.selectedProducts,
                subtotal: widget.totalAmount,
                selectedCustomer: _selectedCustomer,
                invoiceMetadata: body,
                pdfUrl: res['pdf_url']?.toString(),
              ),
            ),
          );
        }
      } else {
         if (mounted) {
           ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(res['error_msg'] ?? "Save Failed"), backgroundColor: AppColors.red),
          );
         }
      }
    } catch (e) {
      debugPrint("❌ CRITICAL ERROR IN SAVE: $e");
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  final List<String> _invoiceTypes = ['Tax Invoice', 'Proforma Invoice', 'Credit Note'];
  final List<String> _priceTypes   = ['Exclude tax', 'Include tax'];
  final List<String> _taxTypes     = ['IGST', 'CGST + SGST', 'None'];
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
          icon: Icon(Icons.arrow_back, color: AppColors.textWhite, size: 22 * sp),
          onPressed: () => Navigator.maybePop(context),
        ),
        title: Text('Invoice',
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
              padding: EdgeInsets.symmetric(horizontal: 16 * hp, vertical: 14 * vp),
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
                        _FieldLabel('Order Type', sp: sp),
                        SizedBox(height: 6 * vp),
                        _OutlinedDropdown(
                          value: _invoiceType,
                          items: _invoiceTypes,
                          sp: sp, hp: hp, vp: vp,
                          onChanged: (v) => setState(() => _invoiceType = v!),
                        ),
                        SizedBox(height: 12 * vp),
                        Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _FieldLabel('Order Date', sp: sp),
                                  SizedBox(height: 6 * vp),
                                  _OutlinedField(value: _invoiceDate, sp: sp, hp: hp, vp: vp),
                                ],
                              ),
                            ),
                            SizedBox(width: sw * 0.03),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _FieldLabel('Delivery Date', sp: sp),
                                  SizedBox(height: 6 * vp),
                                  GestureDetector(
                                    onTap: () => _selectDeliveryDate(context),
                                    child: Container(
                                      width: double.infinity,
                                      padding: EdgeInsets.symmetric(
                                        horizontal: 14 * hp,
                                        vertical: 13 * vp,
                                      ),
                                      decoration: BoxDecoration(
                                        color: AppColors.bgCardAlt,
                                        borderRadius: BorderRadius.circular(10),
                                        border: Border.all(color: AppColors.divider),
                                      ),
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            "${_deliveryDate.month}/${_deliveryDate.day}/${_deliveryDate.year}",
                                            style: TextStyle(
                                              fontSize: 14 * sp,
                                              color: AppColors.textDark,
                                              fontWeight: FontWeight.w500,
                                              fontFamily: 'Poppins',
                                            ),
                                          ),
                                          Icon(Icons.calendar_today_outlined, size: 16 * sp, color: AppColors.blue),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 12 * vp),
                        Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _FieldLabel('Tax Type', sp: sp),
                                  SizedBox(height: 6 * vp),
                                  _OutlinedDropdown(
                                    value: _taxType,
                                    items: _taxTypes,
                                    sp: sp, hp: hp, vp: vp,
                                    onChanged: (v) => setState(() => _taxType = v!),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(width: sw * 0.03),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _FieldLabel('Price Type', sp: sp),
                                  SizedBox(height: 6 * vp),
                                  _OutlinedDropdown(
                                    value: _priceType,
                                    items: _priceTypes,
                                    sp: sp, hp: hp, vp: vp,
                                    onChanged: (v) => setState(() => _priceType = v!),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 12 * vp),
                        _FieldLabel('Reference', sp: sp),
                        SizedBox(height: 6 * vp),
                        Container(
                          height: 48 * vp,
                          decoration: BoxDecoration(
                            color: AppColors.bgCardAlt,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: AppColors.divider),
                          ),
                          child: TextField(
                            controller: _referenceController,
                            style: TextStyle(fontSize: 14 * sp, color: AppColors.textDark),
                            decoration: InputDecoration(
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.symmetric(horizontal: 12 * hp),
                              hintText: 'Enter Reference',
                              hintStyle: TextStyle(color: AppColors.textMuted, fontSize: 13 * sp, fontFamily: 'Poppins'),
                            ),
                          ),
                        ),
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

                  if (_selectedCustomer == null)
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

                  if (_customerSearchController.text.isNotEmpty && _filteredCustomers.isNotEmpty)
                    Container(
                      constraints: BoxConstraints(maxHeight: 200 * vp),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4)],
                      ),
                      child: ListView.builder(
                        shrinkWrap: true,
                        padding: EdgeInsets.zero,
                        itemCount: _filteredCustomers.length,
                        itemBuilder: (context, index) {
                          final c = _filteredCustomers[index];
                          return ListTile(
                            title: Text(c['Ledger_Name'] ?? '', style: TextStyle(fontSize: 13 * sp)),
                            onTap: () {
                              setState(() {
                                _selectedCustomer = c;
                                _customerSearchController.clear();
                                _filteredCustomers = [];
                              });
                            },
                          );
                        },
                      ),
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
                                _selectedCustomer != null ? (_selectedCustomer!['Ledger_Name'] ?? 'No Name') : 'Select Customer',
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
                                              _OutlinedField(value: _selectedCustomer?['Ledger_Name'] ?? '', sp: sp, hp: hp, vp: vp),
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
                                              _OutlinedField(value: _selectedCustomer?['gst'] ?? '', sp: sp, hp: hp, vp: vp),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                    SizedBox(height: 12 * vp),
                                    _FieldLabel('Phone Number', sp: sp),
                                    SizedBox(height: 5 * vp),
                                    _OutlinedField(value: _selectedCustomer?['Mobile']?.toString() ?? '', sp: sp, hp: hp, vp: vp),
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
                                        _selectedCustomer?['address'] ?? 'No Address Provided',
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
                      Icon(Icons.inventory_2_outlined, color: AppColors.blue, size: 20 * sp),
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
                              builder: (context) => SalesOrderSelectedProductsScreen(
                                selectedProducts: widget.selectedProducts,
                                totalAmount: widget.totalAmount,
                              ),
                            ),
                          );
                        },
                        child: Text('view ${widget.selectedProducts.length} Items',
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
                      border: Border.all(color: AppColors.divider.withOpacity(0.5)),
                    ),
                    child: Column(
                      children: widget.selectedProducts.asMap().entries.map((entry) {
                        final index = entry.key;
                        final product = entry.value;

                        return Column(
                          children: [
                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: 14 * hp, vertical: 8 * vp),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(product.name,
                                                style: TextStyle(
                                                  color: AppColors.textDark,
                                                  fontSize: 14 * sp,
                                                  fontWeight: FontWeight.w600,
                                                  fontFamily: 'Poppins',
                                                )),
                                            Text('₹${(product.price * product.selectedQty).toInt()}',
                                                style: TextStyle(
                                                  color: AppColors.green,
                                                  fontSize: 14 * sp,
                                                  fontWeight: FontWeight.w700,
                                                  fontFamily: 'Poppins',
                                                )),
                                          ],
                                        ),
                                        const SizedBox(height: 4),
                                        Text('x ${product.selectedQty.toStringAsFixed(2)} ${product.category}',
                                            style: TextStyle(
                                              color: AppColors.textMuted,
                                              fontSize: 12 * sp,
                                              fontFamily: 'Poppins',
                                            )),
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
                  //   label: 'TCS', rateLabel: 'Collected Rate', rate: '0.1%',
                  //   enabled: _tcsEnabled,
                  //   sp: sp, hp: hp, vp: vp,
                  //   onChanged: (v) => setState(() => _tcsEnabled = v),
                  // ),
                  // SizedBox(height: 10 * vp),
                  // _TaxToggleCard(
                  //   iconBg: AppColors.red.withOpacity(0.12),
                  //   icon: Icons.receipt_long_outlined,
                  //   iconColor: AppColors.red,
                  //   label: 'TDS', rateLabel: 'Deductible Rate', rate: '1.0%',
                  //   enabled: _tdsEnabled,
                  //   sp: sp, hp: hp, vp: vp,
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
                              Icon(Icons.tune_rounded, color: AppColors.textMuted, size: 18 * sp),
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
                              leading: Icon(Icons.local_shipping_outlined, color: AppColors.textMuted, size: 18 * sp),
                              title: Text('Select Dispatch Address', style: TextStyle(fontSize: 13 * sp, color: AppColors.textMuted, fontFamily: 'Poppins')),
                              onTap: () => _showAddressPopup(context, sp, hp, vp),
                            ),
                            ListTile(
                              dense: true,
                              contentPadding: EdgeInsets.zero,
                              leading: Icon(Icons.document_scanner_outlined, color: AppColors.textMuted, size: 18 * sp),
                              title: Text('Add Reference', style: TextStyle(fontSize: 13 * sp, color: AppColors.textMuted, fontFamily: 'Poppins')),
                              onTap: () => _showReferencePopup(context, sp, hp, vp),
                            ),
                            ListTile(
                              dense: true,
                              contentPadding: EdgeInsets.zero,
                              leading: Icon(Icons.percent, color: AppColors.textMuted, size: 18 * sp),
                              title: Text('Add Extra Discount', style: TextStyle(fontSize: 13 * sp, color: AppColors.textMuted, fontFamily: 'Poppins')),
                              onTap: () => _showDiscountPopup(context, sp, hp, vp),
                            ),
                            ListTile(
                              dense: true,
                              contentPadding: EdgeInsets.zero,
                              leading: Icon(Icons.payments_outlined, color: AppColors.textMuted, size: 18 * sp),
                              title: Text('Delivery /Shipping Charges', style: TextStyle(fontSize: 13 * sp, color: AppColors.textMuted, fontFamily: 'Poppins')),
                              onTap: () => _showShippingPopup(context, sp, hp, vp),
                            ),
                            ListTile(
                              dense: true,
                              contentPadding: EdgeInsets.zero,
                              leading: Icon(Icons.inventory_2_outlined, color: AppColors.textMuted, size: 18 * sp),
                              title: Text('Packing Charges', style: TextStyle(fontSize: 13 * sp, color: AppColors.textMuted, fontFamily: 'Poppins')),
                              onTap: () => _showPackingPopup(context, sp, hp, vp),
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
                                  Container(
                                    height: 48 * vp,
                                    decoration: BoxDecoration(
                                      color: AppColors.bgCardAlt,
                                      borderRadius: BorderRadius.circular(10),
                                      border: Border.all(color: AppColors.divider),
                                    ),
                                    child: TextField(
                                      controller: _amountController,
                                      keyboardType: TextInputType.number,
                                      style: TextStyle(fontSize: 14 * sp, color: AppColors.textDark, fontWeight: FontWeight.w600),
                                      decoration: InputDecoration(
                                        border: InputBorder.none,
                                        contentPadding: EdgeInsets.symmetric(horizontal: 12 * hp),
                                        hintText: '₹0.0',
                                        hintStyle: TextStyle(color: AppColors.textMuted),
                                      ),
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
                                  _FieldLabel('Payment Mode', sp: sp),
                                  SizedBox(height: 6 * vp),
                                  _OutlinedDropdown(
                                    value: _paymentMode,
                                    items: _paymentModes,
                                    sp: sp, hp: hp, vp: vp,
                                    onChanged: (v) => setState(() => _paymentMode = v!),
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
                          decoration: BoxDecoration(
                            color: AppColors.bgCardAlt,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: AppColors.divider),
                          ),
                          child: TextField(
                            controller: _notesController,
                            maxLines: 2,
                            style: TextStyle(fontSize: 13 * sp, color: AppColors.textDark),
                            decoration: InputDecoration(
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.all(12 * hp),
                              hintText: 'Add Notes',
                              hintStyle: TextStyle(color: AppColors.textMuted),
                            ),
                          ),
                        ),
                        SizedBox(height: 14 * vp),
                        Row(
                          children: [
                            Container(
                              width:  26 * hp,
                              height: 26 * hp,
                              decoration: const BoxDecoration(
                                color: AppColors.green,
                                shape: BoxShape.circle,
                              ),
                              child: Icon(Icons.check, color: Colors.white, size: 15 * sp),
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
                                onChanged: (v) {
                                  setState(() {
                                    _markFullyPaid = v;
                                    if(v) _amountController.text = (widget.totalAmount.roundToDouble()).toString();
                                  });
                                },
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
            totalAmount: widget.totalAmount,
            selectedProducts: widget.selectedProducts,
            isSubmitting: _isSubmitting,
            onSubmit: _submitSalesOrder,
          ),
        ],
      ),
    );
  }
  void _showDiscountPopup(BuildContext context, double sp, double hp, double vp) {
    _showGenericPopup(context, 'Add Extra Discount', [
      _popupLabelField('Discount Value', '0', sp, hp, vp, showArrow: true),
    ], sp, hp, vp);
  }

  void _showShippingPopup(BuildContext context, double sp, double hp, double vp) {
    _showGenericPopup(context, 'Delivery / Shipping Charges', [
      _popupLabelField('Delivery Charge Value', '₹', sp, hp, vp, showArrow: true),
      SizedBox(height: 16 * vp),
      _popupLabelField('Tax %', '0', sp, hp, vp, showArrow: true),
      SizedBox(height: 16 * vp),
      _popupLabelField('Charges in ₹', '0.0', sp, hp, vp, showArrow: true),
      SizedBox(height: 16 * vp),
      _popupLabelField('', 'Without Tax', sp, hp, vp, showArrow: true),
    ], sp, hp, vp);
  }

  void _showPackingPopup(BuildContext context, double sp, double hp, double vp) {
    _showGenericPopup(context, 'Packing Charges', [
      _popupLabelField('Delivery Charge Value', '%', sp, hp, vp, showArrow: true),
      SizedBox(height: 16 * vp),
      _popupLabelField('Tax %', '0', sp, hp, vp, showArrow: true),
      SizedBox(height: 16 * vp),
      _popupLabelField('Charges in %', '0.0', sp, hp, vp, showArrow: true),
      SizedBox(height: 16 * vp),
      _popupLabelField('', 'Without Tax', sp, hp, vp, showArrow: true),
    ], sp, hp, vp);
  }

  void _showGenericPopup(BuildContext context, String title, List<Widget> children, double sp, double hp, double vp) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
          padding: EdgeInsets.symmetric(horizontal: 20 * hp, vertical: 20 * vp),
          child: Padding(
            padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(child: Container(width: 40 * hp, height: 4 * vp, decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(2)))),
                SizedBox(height: 12 * vp),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(title, style: TextStyle(fontSize: 16 * sp, fontWeight: FontWeight.bold, fontFamily: 'Poppins')),
                    IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(context)),
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
                    style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF26A69A), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
                    child: Text('Save', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15 * sp, fontFamily: 'Poppins')),
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

  Widget _popupLabelField(String label, String value, double sp, double hp, double vp, {bool showArrow = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label.isNotEmpty) ...[
          Text(label, style: TextStyle(color: Colors.black87, fontSize: 13 * sp, fontWeight: FontWeight.w500, fontFamily: 'Poppins')),
          SizedBox(height: 8 * vp),
        ],
        Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(horizontal: 16 * hp, vertical: 12 * vp),
          decoration: BoxDecoration(color: const Color(0xFFF2F4F6), borderRadius: BorderRadius.circular(10)),
          child: Row(
            children: [
              Text(value, style: TextStyle(color: Colors.black87, fontSize: 14 * sp, fontWeight: FontWeight.w500, fontFamily: 'Poppins')),
              if (showArrow) ...[
                const Spacer(),
                Icon(Icons.arrow_drop_down, color: Colors.black87, size: 20 * sp),
              ],
            ],
          ),
        ),
      ],
    );
  }

  void _showReferencePopup(BuildContext context, double sp, double hp, double vp) {
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
            padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
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
                    Text('Add Reference', style: TextStyle(fontSize: 16 * sp, fontWeight: FontWeight.bold, fontFamily: 'Poppins')),
                    IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(context)),
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
                      backgroundColor: const Color(0xFF26A69A),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    child: Text('Submit', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15 * sp, fontFamily: 'Poppins')),
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

  void _showAddressPopup(BuildContext context, double sp, double hp, double vp) {
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
            padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
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
                    Text('Enter Address', style: TextStyle(fontSize: 16 * sp, fontWeight: FontWeight.bold, fontFamily: 'Poppins')),
                    IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(context)),
                  ],
                ),
                const Divider(),
                SizedBox(height: 16 * vp),
                _popupField('Title', sp, hp, vp),
                SizedBox(height: 8 * vp),
                Text('Autofill Company Name', style: TextStyle(color: const Color(0xFF005BBF), fontSize: 11 * sp, fontWeight: FontWeight.w600, fontFamily: 'Poppins')),
                SizedBox(height: 16 * vp),
                Row(
                  children: [
                    Expanded(child: _popupField('Address line 1 *', sp, hp, vp)),
                    SizedBox(width: 12 * hp),
                    Expanded(child: _popupField('Address line 2 *', sp, hp, vp)),
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
                      backgroundColor: const Color(0xFF26A69A),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    child: Text('Save & Update', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15 * sp, fontFamily: 'Poppins')),
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
        style: TextStyle(color: Colors.grey.shade600, fontSize: 13 * sp, fontWeight: FontWeight.w500, fontFamily: 'Poppins'),
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
  final Color    iconColor;
  final String   label;
  final double   sp;
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
  final String       value;
  final List<String> items;
  final double       sp, hp, vp;
  final ValueChanged<String?> onChanged;

  @override
  Widget build(BuildContext context) {
    final normalizedValue = value.trim().replaceAll(RegExp(r'\s+'), ' ');
    final normalizedItems = items.map((e) => e.trim().replaceAll(RegExp(r'\s+'), ' ')).toList();

    return Container(
      height: 48 * vp,
      padding: EdgeInsets.symmetric(horizontal: 12 * hp),
      decoration: BoxDecoration(
        color: AppColors.bgCardAlt,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.divider),
      ),
      child: DropdownButton<String>(
        value: normalizedItems.contains(normalizedValue) ? normalizedValue : (normalizedItems.isNotEmpty ? normalizedItems.first : null),
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
    required this.value,
    required this.sp,
    required this.hp,
    required this.vp,
  });
  final String value;
  final double sp, hp, vp;
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 48 * vp,
      alignment: Alignment.centerLeft,
      padding: EdgeInsets.symmetric(horizontal: 12 * hp),
      decoration: BoxDecoration(
        color: AppColors.bgCardAlt,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.divider),
      ),
      child: Text(value,
          style: TextStyle(
            color: AppColors.textDark,
            fontSize: 13 * sp,
            fontWeight: FontWeight.w500,
            fontFamily: 'Poppins',
          )),
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
  final Color    iconBg, iconColor;
  final IconData icon;
  final String   label, rateLabel, rate;
  final bool     enabled;
  final double   sp, hp, vp;
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
                width:  36 * hp,
                height: 36 * hp,
                decoration: BoxDecoration(
                    color: iconBg,
                    borderRadius: BorderRadius.circular(8)),
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
                padding: EdgeInsets.symmetric(
                    horizontal: 12 * hp, vertical: 5 * vp),
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
    required this.totalAmount,
    required this.selectedProducts,
    required this.isSubmitting,
    required this.onSubmit,
  });
  final double sp, hp, vp;
  final double totalAmount;
  final List<SalesOrderProduct> selectedProducts;
  final bool isSubmitting;
  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context) {
    double subtotal = 0;
    for (var p in selectedProducts) {
      subtotal += p.price * p.selectedQty;
    }

    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(
        20 * hp, 14 * vp, 20 * hp,
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
                Text('Sub Total : ₹${subtotal.toInt()}',
                    style: TextStyle(
                      color: AppColors.textWhite,
                      fontSize: 13 * sp,
                      fontWeight: FontWeight.w500,
                      fontFamily: 'Poppins',
                    )),
                SizedBox(height: 4 * vp),
                Text('Discounted Amount : ₹${totalAmount.toInt()}',
                    style: TextStyle(
                      color: AppColors.textWhite,
                      fontSize: 13 * sp,
                      fontWeight: FontWeight.w700,
                      fontFamily: 'Poppins',
                    )),
              ],
            ),
          ),
          GestureDetector(
            onTap: isSubmitting ? null : onSubmit,
            child: Container(
              padding: EdgeInsets.symmetric(
                  horizontal: 22 * hp, vertical: 12 * vp),
              decoration: BoxDecoration(
                color: isSubmitting ? Colors.grey : AppColors.bgCard,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppColors.textWhite.withOpacity(0.3)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if(isSubmitting)
                    SizedBox(width: 14*sp, height:14*sp, child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primary))
                  else
                    Text('Create',
                        style: TextStyle(
                          color: AppColors.primary,
                          fontSize: 14 * sp,
                          fontWeight: FontWeight.w700,
                          fontFamily: 'Poppins',
                        )),
                  SizedBox(width: 6 * hp),
                  if(!isSubmitting)
                    Icon(Icons.arrow_forward_ios_rounded,
                        color: AppColors.primary, size: 14 * sp),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
