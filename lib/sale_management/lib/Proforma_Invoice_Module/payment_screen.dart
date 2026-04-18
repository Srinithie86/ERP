import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../widgets/app_theme.dart';
import 'product_model.dart';
import 'selected_products_screen.dart';
import 'invoice_view_screen.dart';

class ProformaInvoicePaymentScreen extends StatefulWidget {
  final double totalAmount;
  final List<ProformaInvoiceProduct> selectedProducts;
  final String title;
  final String taxType;
  final String priceType;
  final Map<String, dynamic>? selectedCustomer;

  const ProformaInvoicePaymentScreen({
    super.key,
    required this.totalAmount,
    required this.selectedProducts,
    this.title = 'Invoice',
    this.taxType = 'IGST',
    this.priceType = 'Exclude tax',
    this.selectedCustomer,
  });
  @override
  State<ProformaInvoicePaymentScreen> createState() =>
      _ProformaInvoicePaymentScreenState();
}

class _ProformaInvoicePaymentScreenState
    extends State<ProformaInvoicePaymentScreen> {
  String _invoiceType = 'Retail';
  String? _taxType;
  String? _priceType;
  String _paymentMode = 'Cash';
  bool _tcsEnabled = false;
  bool _tdsEnabled = false;
  bool _markFullyPaid = false;
  DateTime _selectedDate = DateTime.now();
  bool _advancedOpen = false;
  bool _isSubmitting = false;

  // ID Mappings
  final Map<String, String> _invoiceTypeIds = {};
  final Map<String, String> _priceTypeIds = {};
  final Map<String, String> _taxTypeIds = {};

  List<dynamic> _customers = [];
  List<dynamic> _filteredCustomers = [];
  Map<String, dynamic>? _selectedCustomer;
  bool _isFetchingCustomers = false;
  final TextEditingController _customerSearchController =
      TextEditingController();
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();
  late TextEditingController invoiceNoController;

  @override
  void initState() {
    super.initState();
    _taxType = widget.taxType;
    _priceType = widget.priceType;
    _selectedCustomer = widget.selectedCustomer;
    if (_selectedCustomer != null) {
      _customerSearchController.text = _selectedCustomer!['Ledger_Name'] ?? '';
    }
    invoiceNoController = TextEditingController();
    _fetchInvoiceNumber();
    _fetchCustomers();
    _fetchAllDropdowns();
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
            String label = item['label'].toString().trim();
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
            });
          }
        }
      }
    } catch (e) {
      debugPrint("Error fetching dropdown (listId $listId): $e");
    }
  }

  Future<void> _fetchInvoiceNumber() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cid = prefs.getString('cid') ?? '44555666';
      final lt = prefs.getString('lt') ?? '123';
      final ln = prefs.getString('ln') ?? '123';
      final deviceId = prefs.getString('device_id') ?? '123';

      final response = await http.post(
        Uri.parse('https://erpsmart.in/total/api/m_api/'),
        body: {
          'type': '8002',
          'cid': cid,
          'ln': ln,
          'lt': lt,
          'device_id': deviceId,
        },
      );

      final res = json.decode(response.body);
      debugPrint("Proforma Invoice Number response (API 8002): $res");

      bool isSuccess = (res['error'] == false) || (res['status'] == true);
      final generatedNumber = res['quotation_number'] ??
          res['order_no'] ??
          res['invoice_no'] ??
          res['proforma_no'];

      if (isSuccess && generatedNumber != null) {
        if (mounted) {
          setState(() {
            invoiceNoController.text = generatedNumber.toString();
          });
        }
      }
    } catch (e) {
      debugPrint("Error fetching proforma invoice number (8002): $e");
    }
  }

  Future<void> _fetchCustomers() async {
    if (!mounted) return;
    setState(() => _isFetchingCustomers = true);
    final prefs = await SharedPreferences.getInstance();
    final cid = prefs.getString('cid') ?? '44555666';
    final lt = prefs.getString('lt') ?? '123';
    final ln = prefs.getString('ln') ?? '123';
    final deviceId = prefs.getString('device_id') ?? '123';

    const url = 'https://erpsmart.in/total/api/m_api/';
    final body = {
      'type': '2083',
      'cid': cid,
      'lt': lt,
      'ln': ln,
      'device_id': deviceId,
      'form': 'sm_main_form_10002',
      'select': '*',
      'where': 'category=8',
    };

    debugPrint("\n================ FETCH CUSTOMERS REQUEST ================");
    debugPrint("URL: $url");
    debugPrint("BODY: $body");
    debugPrint("========================================================\n");

    try {
      final response = await http.post(Uri.parse(url), body: body);
      final jsonResponse = json.decode(response.body);

      debugPrint(
          "\n================ FETCH CUSTOMERS RESPONSE ================");
      debugPrint("STATUS: ${response.statusCode}");
      debugPrint("DATA: ${response.body}");
      debugPrint("=========================================================\n");

      if (jsonResponse['error'] == false) {
        if (mounted) {
          setState(() {
            _customers = jsonResponse['data'] ?? [];
            _filteredCustomers = _customers;
          });
        }
      }
    } catch (e) {
      debugPrint("❌ ProformaInvoicePaymentScreen => FETCH CUSTOMERS ERROR: $e");
    } finally {
      if (mounted) setState(() => _isFetchingCustomers = false);
    }
  }

  void _filterCustomers(String query) {
    setState(() {
      _filteredCustomers = _customers
          .where((c) =>
              c['Ledger_Name']
                  .toString()
                  .toLowerCase()
                  .contains(query.toLowerCase()) ||
              c['id'].toString().contains(query))
          .toList();
    });
  }

  Future<void> _submitInvoice() async {
    if (_selectedCustomer == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please select a customer first")),
      );
      return;
    }
    setState(() => _isSubmitting = true);

    final prefs = await SharedPreferences.getInstance();
    final cid = prefs.getString('cid') ?? '44555666';
    final lt = prefs.getString('lt') ?? '123';
    final ln = prefs.getString('ln') ?? '123';
    final deviceId = prefs.getString('device_id') ?? '123';
    final uid = prefs.getString('uid') ?? '1';
    final roleId = prefs.getString('role_id') ?? '2';
    final token = prefs.getString('token') ?? 'rgherjyt34';

    final s = summary;

    // Map products to API format with per-product tax calculation
    final List<Map<String, dynamic>> productsJson =
        widget.selectedProducts.map((p) {
      double pTaxable = (p.price * p.selectedQty);
      double pDiscount = p.isPercentageDiscount
          ? (p.price * (p.discountPercentage / 100) * p.selectedQty)
          : (p.discountAmount * p.selectedQty);
      double pTaxableAfterDiscount = pTaxable - pDiscount;

      double pIgst = 0, pCgst = 0, pSgst = 0;
      double taxRate = p.taxRate / 100;

      if (activeTaxType != 'None') {
        if (activePriceType == 'Include tax') {
          double base = pTaxableAfterDiscount / (1 + taxRate);
          double totalTax = pTaxableAfterDiscount - base;
          if (activeTaxType == 'IGST') {
            pIgst = totalTax;
          } else {
            pCgst = totalTax / 2;
            pSgst = totalTax / 2;
          }
          pTaxableAfterDiscount = base;
        } else {
          double totalTax = pTaxableAfterDiscount * taxRate;
          if (activeTaxType == 'IGST') {
            pIgst = totalTax;
          } else {
            pCgst = totalTax / 2;
            pSgst = totalTax / 2;
          }
        }
      }

      return {
        "product_name": p.name,
        "product_id": p.id,
        "hsn_code": p.hsnCode,
        "quantity": p.selectedQty,
        "uom": p.uom,
        "unit_price": p.price,
        "taxable_value": pTaxableAfterDiscount,
        "discount": pDiscount,
        "mtax_type":
            activePriceType == 'Include tax' ? 'inclusive' : 'exclusive',
        "mtax": p.taxRate,
        "tax_per": "${p.taxRate}%",
        "cgst": pCgst,
        "sgst": pSgst,
        "igst": pIgst,
        "invoice_type": _invoiceTypeIds[_invoiceType] ?? '1',
      };
    }).toList();

    final Map<String, dynamic> body = {
      'type': '8000',
      'cid': cid,
      'lt': lt,
      'ln': ln,
      'device_id': deviceId,
      'uid': uid,
      'bid': '3',
      'cus_id': _selectedCustomer?['id']?.toString() ?? '',
      'invoice_no': invoiceNoController.text,
      'invoice_date':
          "${_selectedDate.year}-${_selectedDate.month.toString().padLeft(2, '0')}-${_selectedDate.day.toString().padLeft(2, '0')}",
      'customer_name': _selectedCustomer?['Ledger_Name'] ?? '',
      'customer_gstin': _selectedCustomer?['gst'] ?? '',
      'address': _selectedCustomer?['address'] ?? '',
      'price_type': _priceTypeIds[activePriceType] ?? '1',
      'tax_type': _taxTypeIds[activeTaxType] ?? '1',
      'grand_total': s.finalPayable.toString(),
      'taxable_total': s.taxableAmount.toString(),
      'total_gst': (s.igst + s.cgst + s.sgst).toString(),
      'tds_type': _tdsEnabled ? '2' : '1',
      'cgst': s.cgst.toString(),
      'sgst': s.sgst.toString(),
      'igst': s.igst.toString(),
      'round_off': s.roundOff.toString(),
      'tds': '0',
      'tcs': '0',
      'products': json.encode(productsJson),
      'invoice_type': _invoiceTypeIds[_invoiceType] ?? '1',
      'role_id': roleId,
      'token': token,
    };

    // Optimized Log Output - Only first 2 products
    final Map<String, dynamic> debugBody = Map.from(body);
    if (productsJson.length > 2) {
      debugBody['products'] =
          "${productsJson.take(2).toList()} ... and ${productsJson.length - 2} more items";
    }

    debugPrint("\n================ SUBMIT INVOICE REQUEST ================");
    debugPrint("URL: https://erpsmart.in/total/api/m_api/");
    debugPrint("BODY: $debugBody");
    debugPrint("========================================================\n");

    try {
      final response = await http.post(
        Uri.parse('https://erpsmart.in/total/api/m_api/'),
        body: body,
      );

      final jsonResponse = json.decode(response.body);

      debugPrint("\n================ SUBMIT INVOICE RESPONSE ================");
      debugPrint("STATUS: ${response.statusCode}");
      debugPrint("DATA: ${response.body}");
      debugPrint("=========================================================\n");

      if (jsonResponse['error'] == false) {
        final pdfUrl = jsonResponse['pdf_url']?.toString();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                  jsonResponse['error_msg'] ?? "Invoice saved successfully"),
              backgroundColor: AppColors.green,
            ),
          );
          // Navigate to view screen or back
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => ProformaInvoiceViewScreen(
                selectedProducts: widget.selectedProducts,
                summary: s,
                selectedCustomer: _selectedCustomer,
                title: widget.title,
                invoiceMetadata: body,
                pdfUrl: pdfUrl,
              ),
            ),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content:
                  Text(jsonResponse['error_msg'] ?? "Error saving invoice"),
              backgroundColor: AppColors.red,
            ),
          );
        }
      }
    } catch (e) {
      debugPrint("❌ ProformaInvoicePaymentScreen => SUBMIT ERROR: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text("Failed to submit invoice. Please try again.")),
        );
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

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

  bool _customerExpanded = false;

  @override
  void dispose() {
    _customerSearchController.dispose();
    _amountController.dispose();
    _notesController.dispose();
    invoiceNoController.dispose();
    super.dispose();
  }

  // Fallbacks with validation — guards against stale hot-reload state
  // where old label values (e.g. 'Exclude') no longer exist in the items list.
  String get activeTaxType {
    final v = _taxType ?? widget.taxType;
    return _taxTypes.contains(v) ? v : _taxTypes.first;
  }

  String get activePriceType {
    final v = _priceType ?? widget.priceType;
    return _priceTypes.contains(v) ? v : _priceTypes.first;
  }

  ProformaInvoiceSummary get summary {
    double subtotal = 0;
    double totalDiscount = 0;

    for (var p in widget.selectedProducts) {
      subtotal += p.price * p.selectedQty;
      totalDiscount += p.isPercentageDiscount
          ? (p.price * (p.discountPercentage / 100) * p.selectedQty)
          : (p.discountAmount * p.selectedQty);
    }

    double taxableAmount = subtotal - totalDiscount;
    double igst = 0, cgst = 0, sgst = 0;
    const double taxRate = 0.18;

    if (activeTaxType != 'None') {
      if (activePriceType == 'Include tax') {
        double base = taxableAmount / (1 + taxRate);
        double totalTax = taxableAmount - base;
        if (activeTaxType == 'IGST') {
          igst = totalTax;
        } else {
          cgst = totalTax / 2;
          sgst = totalTax / 2;
        }
        taxableAmount = base;
      } else {
        double totalTax = taxableAmount * taxRate;
        if (activeTaxType == 'IGST') {
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

    return ProformaInvoiceSummary(
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
      taxType: activeTaxType,
      priceType: activePriceType,
      roundOff: roundOff,
    );
  }

  final List<String> _priceTypes = ['Exclude tax', 'Include tax'];
  final List<String> _invoiceTypes = [
    'Retail',
    'Wholesale B-B',
    'Bill of Supply',
    'Branch Supply',
    'CS Retail'
  ];
  final List<String> _taxTypes = ['IGST', 'CGST + SGST', 'None'];
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
        title: Text(widget.title,
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
                          iconColor: const Color(0xFF0045BC),
                          label: 'General Information',
                          sp: sp,
                        ),
                        SizedBox(height: 14 * vp),
                        Row(
                          children: [
                            Expanded(
                              child: Column(
                                children: [
                                  _FieldLabel('Invoice Type', sp: sp),
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
                            ),
                            SizedBox(width: 12 * hp),
                            Expanded(
                              child: Column(
                                children: [
                                  _FieldLabel('Invoice Date', sp: sp),
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
                          ],
                        ),

                        SizedBox(height: 12 * vp),
                        Row(
                          children: [
                            Expanded(
                              child: Column(
                                children: [
                                  _FieldLabel('Price Type', sp: sp),
                                  SizedBox(height: 6 * vp),
                                  _OutlinedDropdown(
                                    value: activePriceType,
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
                            SizedBox(width: 12 * hp),
                            Expanded(
                              child: Column(
                                children: [
                                  _FieldLabel('Tax Type', sp: sp),
                                  SizedBox(height: 6 * vp),
                                  _OutlinedDropdown(
                                    value: activeTaxType,
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
                          ],
                        ),
                        SizedBox(height: 12 * vp),
                        // Row(
                        //   children: [
                        //     Expanded(
                        //       child: Column(
                        //         crossAxisAlignment: CrossAxisAlignment.start,
                        //         children: [
                        //           _FieldLabel('Invoice Date', sp: sp),
                        //           SizedBox(height: 6 * vp),
                        //           GestureDetector(
                        //             onTap: () => _selectDate(context),
                        //             child: _OutlinedField(
                        //               value:
                        //                   "${_selectedDate.month}/${_selectedDate.day}/${_selectedDate.year}",
                        //               sp: sp,
                        //               hp: hp,
                        //               vp: vp,
                        //               trailing: Icon(Icons.calendar_today,
                        //                   size: 16 * sp, color: AppColors.blue),
                        //             ),
                        //           ),
                        //         ],
                        //       ),
                        //     ),
                        //     SizedBox(width: 10 * hp),
                        //     Expanded(
                        //       child: Column(
                        //         crossAxisAlignment: CrossAxisAlignment.start,
                        //         children: [
                        //           _FieldLabel('Invoice No.', sp: sp),
                        //           SizedBox(height: 6 * vp),
                        //           _OutlinedField(
                        //             hint: 'INV-2023-0042',
                        //             sp: sp,
                        //             hp: hp,
                        //             vp: vp,
                        //             controller: invoiceNoController,
                        //           ),
                        //         ],
                        //       ),
                        //     ),
                        //   ],
                        // ),
                      ],
                    ),
                  ),

                  SizedBox(height: 16 * vp),

                  // ── 2. CUSTOMER DETAILS ─────────────────────────────────────
                  Row(
                    children: [
                      Icon(Icons.person,
                          color: AppColors.textDark, size: 20 * sp),
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
                          Icon(Icons.search,
                              color: AppColors.textMuted, size: 18 * sp),
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
                          if (_isFetchingCustomers)
                            SizedBox(
                              width: 16 * sp,
                              height: 16 * sp,
                              child: const CircularProgressIndicator(
                                  strokeWidth: 2),
                            ),
                        ],
                      ),
                    ),
                  if (_customerSearchController.text.isNotEmpty &&
                      _selectedCustomer == null)
                    Container(
                      margin: const EdgeInsets.only(top: 4),
                      constraints: BoxConstraints(maxHeight: 200 * vp),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: [
                          BoxShadow(color: Colors.black12, blurRadius: 4)
                        ],
                      ),
                      child: ListView.builder(
                        shrinkWrap: true,
                        itemCount: _filteredCustomers.length,
                        itemBuilder: (context, index) {
                          final c = _filteredCustomers[index];
                          return ListTile(
                            title: Text(c['Ledger_Name'] ?? '',
                                style: TextStyle(
                                    fontSize: 14 * sp, fontFamily: 'Poppins')),
                            subtitle: Text('ID: ${c['id']}',
                                style: TextStyle(
                                    fontSize: 12 * sp, color: Colors.grey)),
                            onTap: () {
                              setState(() {
                                _selectedCustomer = c;
                                _customerSearchController.text =
                                    c['Ledger_Name'];
                                // Removed auto-expand: _customerExpanded = true;
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
                            color: const Color(0xFF0045BC),
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
                                backgroundColor:
                                    const Color(0xFF0045BC).withOpacity(0.12),
                                radius: 18 * sp,
                                child: Icon(
                                  Icons.person,
                                  color: const Color(0xFF0045BC),
                                  size: 20 * sp,
                                ),
                              ),
                              title: Text(
                                _selectedCustomer != null
                                    ? '${_selectedCustomer!['Ledger_Name']} - ${_selectedCustomer!['id']}'
                                    : 'Select a Customer',
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
                                      icon: const Icon(Icons.close,
                                          size: 20, color: Colors.red),
                                      onPressed: () {
                                        setState(() {
                                          _selectedCustomer = null;
                                          _customerSearchController.clear();
                                        });
                                      },
                                    ),
                                  GestureDetector(
                                    onTap: () => setState(() =>
                                        _customerExpanded = !_customerExpanded),
                                    child: Icon(
                                      _customerExpanded
                                          ? Icons.visibility_outlined
                                          : Icons.visibility_off_outlined,
                                      color: _customerExpanded
                                          ? const Color(0xFF0045BC)
                                          : AppColors.textMuted,
                                      size: 22 * sp,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            AnimatedCrossFade(
                              duration: const Duration(milliseconds: 300),
                              crossFadeState: (_customerExpanded &&
                                      _selectedCustomer != null)
                                  ? CrossFadeState.showSecond
                                  : CrossFadeState.showFirst,
                              firstChild: const SizedBox.shrink(),
                              secondChild: Padding(
                                padding: EdgeInsets.fromLTRB(
                                    14 * hp, 0, 14 * hp, 14 * vp),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Divider(
                                        color: AppColors.divider, height: 1),
                                    SizedBox(height: 14 * vp),
                                    Row(
                                      children: [
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              _FieldLabel('Phone Number',
                                                  sp: sp),
                                              SizedBox(height: 5 * vp),
                                              _OutlinedField(
                                                  value: _selectedCustomer?[
                                                              'phone']
                                                          ?.toString() ??
                                                      'N/A',
                                                  sp: sp,
                                                  hp: hp,
                                                  vp: vp),
                                            ],
                                          ),
                                        ),
                                        SizedBox(width: 10 * hp),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              _FieldLabel('GST Number', sp: sp),
                                              SizedBox(height: 5 * vp),
                                              _OutlinedField(
                                                  value: _selectedCustomer?[
                                                          'gst'] ??
                                                      'N/A',
                                                  sp: sp,
                                                  hp: hp,
                                                  vp: vp),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                    SizedBox(height: 12 * vp),
                                    _FieldLabel('Billing Address', sp: sp),
                                    SizedBox(height: 5 * vp),
                                    Container(
                                      width: double.infinity,
                                      padding: EdgeInsets.symmetric(
                                          horizontal: 12 * hp,
                                          vertical: 10 * vp),
                                      decoration: BoxDecoration(
                                        color: AppColors.bgCardAlt,
                                        borderRadius: BorderRadius.circular(10),
                                        border: Border.all(
                                            color: AppColors.divider),
                                      ),
                                      child: Text(
                                        _selectedCustomer?['address'] ??
                                            'No address provided',
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
                          color: const Color(0xFF0045BC), size: 20 * sp),
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
                                  ProformaSelectedProductsScreen(
                                selectedProducts: widget.selectedProducts,
                                totalAmount: widget.totalAmount,
                                title: widget.title,
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
                                                '₹${(product.price * product.selectedQty).toInt()}',
                                                style: TextStyle(
                                                  color: AppColors.green,
                                                  fontSize: 14 * sp,
                                                  fontWeight: FontWeight.w700,
                                                  fontFamily: 'Poppins',
                                                )),
                                          ],
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                            'x ${product.selectedQty.toStringAsFixed(2)} OTH',
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
                  //   iconBg: AppColors.blue.withOpacity(0.1),
                  //   icon: Icons.account_balance_wallet_outlined,
                  //   iconColor: AppColors.blue,
                  //   label: 'TCS', rateLabel: 'Collected Rate', rate: '0.1%',
                  //   enabled: _tcsEnabled,
                  //   sp: sp, hp: hp, vp: vp,
                  //   onChanged: (v) => setState(() {
                  //     _tcsEnabled = v;
                  //     if (v) _tdsEnabled = false;
                  //   }),
                  // ),
                  // SizedBox(height: 12 * vp),
                  // _TaxToggleCard(
                  //   iconBg: AppColors.red.withOpacity(0.1),
                  //   icon: Icons.receipt_long_outlined,
                  //   iconColor: AppColors.red,
                  //   label: 'TDS', rateLabel: 'Deductible Rate', rate: '1.0%',
                  //   enabled: _tdsEnabled,
                  //   sp: sp, hp: hp, vp: vp,
                  //   onChanged: (v) => setState(() {
                  //     _tdsEnabled = v;
                  //     if (v) _tcsEnabled = false;
                  //   }),
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
                                  TextField(
                                    controller: _amountController,
                                    keyboardType: TextInputType.number,
                                    style: TextStyle(
                                      fontSize: 14 * sp,
                                      fontWeight: FontWeight.w500,
                                      fontFamily: 'Poppins',
                                    ),
                                    decoration: InputDecoration(
                                      hintText: '₹0.0',
                                      contentPadding: EdgeInsets.symmetric(
                                          horizontal: 12 * hp,
                                          vertical: 10 * vp),
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(10),
                                        borderSide: const BorderSide(
                                            color: AppColors.divider),
                                      ),
                                      enabledBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(10),
                                        borderSide: const BorderSide(
                                            color: AppColors.divider),
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
                        TextField(
                          controller: _notesController,
                          maxLines: 2,
                          style: TextStyle(
                            fontSize: 13 * sp,
                            fontFamily: 'Poppins',
                          ),
                          decoration: InputDecoration(
                            hintText: 'Add Notes',
                            hintStyle: TextStyle(color: AppColors.textMuted),
                            contentPadding: EdgeInsets.symmetric(
                                horizontal: 12 * hp, vertical: 12 * vp),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide:
                                  const BorderSide(color: AppColors.divider),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide:
                                  const BorderSide(color: AppColors.divider),
                            ),
                            fillColor: AppColors.bgCardAlt,
                            filled: true,
                          ),
                        ),
                        SizedBox(height: 14 * vp),
                        Row(
                          children: [
                            Container(
                              width: 26 * hp,
                              height: 26 * hp,
                              decoration: BoxDecoration(
                                color: _markFullyPaid
                                    ? AppColors.green
                                    : Colors.grey.shade300,
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
                              activeColor: const Color(0xFF0045BC),
                              onChanged: (v) {
                                setState(() {
                                  _markFullyPaid = v;
                                  if (_markFullyPaid) {
                                    _amountController.text =
                                        summary.finalPayable.toStringAsFixed(2);
                                  }
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
            summary: summary,
            selectedProducts: widget.selectedProducts,
            title: widget.title,
            markFullyPaid: _markFullyPaid,
            isSubmitting: _isSubmitting,
            onCreate: _submitInvoice,
          ),
        ],
      ),
    );
  }

  void _showDiscountPopup(
      BuildContext context, double sp, double hp, double vp) {
    _showGenericPopup(
        context,
        'Add Extra Discount',
        [
          _popupLabelField('Discount Value', '0', sp, hp, vp, showArrow: true),
        ],
        sp,
        hp,
        vp);
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
                        backgroundColor: const Color(0xFF26A69A),
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
                      backgroundColor: const Color(0xFF26A69A),
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
                      backgroundColor: const Color(0xFF26A69A),
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
    return Container(
      height: 48 * vp,
      padding: EdgeInsets.symmetric(horizontal: 12 * hp),
      decoration: BoxDecoration(
        color: AppColors.bgCardAlt,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.divider),
      ),
      child: DropdownButton<String>(
        value: value,
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
        items: items
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
    required this.sp,
    required this.hp,
    required this.vp,
  });
  final String? value;
  final String? hint;
  final Widget? trailing;
  final TextEditingController? controller;
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
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: value != null
                ? Text(value!,
                    style: TextStyle(
                      color: AppColors.textDark,
                      fontSize: 13 * sp,
                      fontWeight: FontWeight.w500,
                      fontFamily: 'Poppins',
                    ))
                : TextField(
                    controller: controller,
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
      padding: EdgeInsets.symmetric(horizontal: 18 * hp, vertical: 20 * vp),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 44 * hp,
                height: 44 * hp,
                decoration: BoxDecoration(
                  color: iconBg,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: iconColor, size: 22 * sp),
              ),
              SizedBox(width: 14 * hp),
              Text(label,
                  style: TextStyle(
                    color: const Color(0xFF1A1C1E),
                    fontSize: 18 * sp,
                    fontWeight: FontWeight.w800,
                    fontFamily: 'Poppins',
                  )),
              const Spacer(),
              Switch.adaptive(
                value: enabled,
                activeColor: Colors.white,
                activeTrackColor: const Color(0xFF0045BC),
                inactiveTrackColor: const Color(0xFFE2E8F0),
                onChanged: onChanged,
              ),
            ],
          ),
          SizedBox(height: 24 * vp),
          Row(
            children: [
              Text(rateLabel,
                  style: TextStyle(
                    color: const Color(0xFF74777F),
                    fontSize: 14 * sp,
                    fontWeight: FontWeight.w600,
                    fontFamily: 'Poppins',
                  )),
              const Spacer(),
              Container(
                padding:
                    EdgeInsets.symmetric(horizontal: 16 * hp, vertical: 8 * vp),
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(rate,
                    style: TextStyle(
                      color: const Color(0xFF1A1C1E),
                      fontSize: 14 * sp,
                      fontWeight: FontWeight.w800,
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
  final double sp, hp, vp;
  final ProformaInvoiceSummary summary;
  final List<ProformaInvoiceProduct> selectedProducts;
  final String title;
  final bool markFullyPaid;
  final bool isSubmitting;
  final VoidCallback onCreate;

  const _BottomBar({
    required this.sp,
    required this.hp,
    required this.vp,
    required this.summary,
    required this.selectedProducts,
    required this.title,
    required this.markFullyPaid,
    required this.isSubmitting,
    required this.onCreate,
  });

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
            onTap: isSubmitting ? null : onCreate,
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
                  isSubmitting
                      ? SizedBox(
                          width: 14 * sp,
                          height: 14 * sp,
                          child: const CircularProgressIndicator(
                              strokeWidth: 2, color: Color(0xFF0045BC)),
                        )
                      : Text('Create',
                          style: TextStyle(
                            color: const Color(0xFF0045BC),
                            fontSize: 14 * sp,
                            fontWeight: FontWeight.w700,
                            fontFamily: 'Poppins',
                          )),
                  if (!isSubmitting) ...[
                    SizedBox(width: 6 * hp),
                    Icon(Icons.arrow_forward_ios_rounded,
                        color: const Color(0xFF0045BC), size: 14 * sp),
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
