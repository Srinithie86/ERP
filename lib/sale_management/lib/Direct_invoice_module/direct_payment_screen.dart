import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../widgets/app_theme.dart';
import 'product_model.dart';
import 'selected_products_screen.dart';
import 'invoice_view_screen.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class DirectInvoicePaymentScreen extends StatefulWidget {
  final double totalAmount;
  final List<DirectInvoiceProduct> selectedProducts;
  final String taxType;
  final String priceType;

  final Map<String, dynamic>? selectedCustomer;
  final String? invoiceNo;
  final DateTime? selectedDate;

  const DirectInvoicePaymentScreen({
    super.key,
    required this.totalAmount,
    required this.selectedProducts,
    this.taxType = 'IGST',
    this.priceType = 'Exclude Tax',
    this.selectedCustomer,
    this.invoiceNo,
    this.selectedDate,
  });
  @override
  State<DirectInvoicePaymentScreen> createState() => _DirectInvoicePaymentScreenState();
}

class _DirectInvoicePaymentScreenState extends State<DirectInvoicePaymentScreen> {
  String? _taxType;
  String? _priceType;
  String _paymentMode   = 'Cash';
  bool   _tcsEnabled    = false;
  bool   _tdsEnabled    = false;
  bool   _markFullyPaid = false;
  DateTime _selectedDate = DateTime.now();
  bool   _advancedOpen  = false;
  String _invoiceType   = 'Retail';
  final List<String> _priceTypes   = ['Exclude Tax', 'Include Tax'];
  final List<String> _invoiceTypes = ['Retail', 'Wholesale B-B', 'Bill of Supply', 'Branch Supply', 'CS Retail'];
  final List<String> _taxTypes     = ['IGST', 'CGST + SGST', 'None'];
  Map<String, dynamic>? _selectedCustomer;
  final TextEditingController _customerSearchController = TextEditingController();
  bool _isCreating = false;

  Future<void> _createInvoice() async {
    if (_selectedCustomer == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a customer first'), backgroundColor: Colors.red),
      );
      return;
    }

    if (mounted) setState(() => _isCreating = true);

    try {
      final prefs = await SharedPreferences.getInstance();
      final cid = prefs.getString('cid') ?? '44555666';
      final lt = prefs.getString('lt') ?? '1';
      final ln = prefs.getString('ln') ?? '1';
      final deviceId = prefs.getString('device_id') ?? '11';
      final roleId = prefs.getString('role_id') ?? '2';
      final token = prefs.getString('token') ?? 'tdtyu34';

      final s = summary;

      Map<String, String> body = {
        'type': '8011',
        'cid': cid,
        'invoice_no': widget.invoiceNo ?? '',
        'date': "${_selectedDate.year}-${_selectedDate.month.toString().padLeft(2, '0')}-${_selectedDate.day.toString().padLeft(2, '0')}",
        'cus_id': _selectedCustomer?['id']?.toString() ?? '',
        'cat': '1',
        'customer_name': (_selectedCustomer?['Ledger_Name'] ?? '').toString(),
        'customer_gstin': (_selectedCustomer?['gst'] ?? _selectedCustomer?['GSTIN'] ?? _selectedCustomer?['gstin'] ?? '').toString(),
        'address': (_selectedCustomer?['address'] ?? _selectedCustomer?['Address'] ?? _selectedCustomer?['b_add1'] ?? '').toString(),
        'mobile': (_selectedCustomer?['phone'] ?? _selectedCustomer?['Mobile'] ?? '').toString(),
        'trans_type': '1',
        'trans_name': '',
        'b_name': (_selectedCustomer?['Ledger_Name'] ?? '').toString(),
        'b_gst': (_selectedCustomer?['gst'] ?? _selectedCustomer?['GSTIN'] ?? _selectedCustomer?['gstin'] ?? '').toString(),
        'b_add1': (_selectedCustomer?['address'] ?? _selectedCustomer?['Address'] ?? _selectedCustomer?['b_add1'] ??  '').toString(),
        'b_loc': (_selectedCustomer?['city'] ?? _selectedCustomer?['location'] ?? '').toString(),
        'b_pin': (_selectedCustomer?['pin'] ?? _selectedCustomer?['pincode'] ?? '').toString(),
        'b_scode': (_selectedCustomer?['state_code'] ?? '').toString(),
        'taxable_total': widget.totalAmount.toStringAsFixed(2),
        'cgst': s.cgst.toStringAsFixed(2),
        'sgst': s.sgst.toStringAsFixed(2),
        'igst': s.igst.toStringAsFixed(2),
        'taxtotal': (s.igst + s.cgst + s.sgst).toStringAsFixed(2),
        'g_total': s.finalPayable.toStringAsFixed(2),
        'ln': ln,
        'lt': lt,
        'device_id': deviceId,
        's_type': '1',
        'mtax': '1',
        'price_type': activePriceType == 'Include tax' ? '1' : '0',
        'discount': s.discount.toStringAsFixed(2),
        'tds_type': '20',
        'tcs_type': '40',
        'total_tds': '0.00',
        'total_tcs': '0.00',
        'role_id': roleId,
        'token': token,
      };

      for (int i = 0; i < widget.selectedProducts.length; i++) {
        final p = widget.selectedProducts[i];
        body['pro_name[$i]'] = p.name;
        body['product_id[$i]'] = p.id;
        body['hsn[$i]'] = p.hsn;
        body['qty[$i]'] = p.selectedQty.toString();
        body['uom[$i]'] = p.uom;
        body['rate[$i]'] = p.price.toStringAsFixed(2);
        body['taxable[$i]'] = (p.price * p.selectedQty).toStringAsFixed(2);
        body['tax[$i]'] = "18"; // Hardcoded in summary logic too
        body['total[$i]'] = ((p.price * p.selectedQty) * 1.18).toStringAsFixed(2); // Simplified for now
        body['cat[$i]'] = '10';
        body['itm_code[$i]'] = 'ITM00$i';
        body['qc_sts[$i]'] = '1';
        body['remarks[$i]'] = 'OK';
      }

      debugPrint("Creating Direct Invoice with body: $body");

      final response = await http.post(
        Uri.parse('https://erpsmart.in/total/api/m_api/'),
        body: body,
      );

      final res = json.decode(response.body);
      debugPrint("Direct Invoice Insert Response: $res");

      if (res['error'] == false) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Invoice Created Successfully'), backgroundColor: Colors.green),
        );
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => DirectInvoiceViewScreen(
              selectedProducts: widget.selectedProducts,
              summary: s,
              title: 'Invoice',
              selectedCustomer: _selectedCustomer,
              invoiceMetadata: body,
              pdfUrl: res['pdf_url']?.toString(),
            ),
          ),
        );
      } else {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(res['message'] ?? 'Error creating invoice'), backgroundColor: Colors.red),
        );
      }
    } catch (e) {
      debugPrint("Error in _createInvoice: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Network error: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isCreating = false);
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
  @override
  void initState() {
    super.initState();
    _taxType = widget.taxType;
    _priceType = widget.priceType;
    _selectedCustomer = widget.selectedCustomer;
    _selectedDate = widget.selectedDate ?? DateTime.now();
  }

  @override
  void dispose() {
    _customerSearchController.dispose();
    super.dispose();
  }

  // Fallbacks explicitly added for Hot Reloading
  String get activeTaxType => _taxType ?? widget.taxType;
  String get activePriceType => _priceType ?? widget.priceType;

  bool _customerExpanded = false;


  DirectInvoiceSummary get summary {
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
        if (activeTaxType == 'IGST') { igst = totalTax; } else { cgst = totalTax / 2; sgst = totalTax / 2; }
        taxableAmount = base;
      } else {
        double totalTax = taxableAmount * taxRate;
        if (activeTaxType == 'IGST') { igst = totalTax; } else { cgst = totalTax / 2; sgst = totalTax / 2; }
      }
    }

    double shipping = 0.0;
    double tcs = 0.0;
    double tds = 0.0;
    double totalTax = igst + cgst + sgst;
    double rawTotal = taxableAmount + totalTax + shipping + tcs - tds;
    double roundedTotal = rawTotal.roundToDouble();
    double roundOff = roundedTotal - rawTotal;
    
    return DirectInvoiceSummary(
      subtotal: subtotal, 
      discount: totalDiscount, 
      taxableAmount: taxableAmount,
      igst: igst, cgst: cgst, sgst: sgst, tcs: tcs, tds: tds,
      shippingCharges: shipping,
      finalPayable: roundedTotal,
      taxType: activeTaxType, 
      priceType: activePriceType,
      roundOff: roundOff,
    );
  }

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
                               Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _FieldLabel('Invoice Date', sp: sp),
                                  SizedBox(height: 6 * vp),
                                  GestureDetector(
                                    onTap: () => _selectDate(context),
                                    child: _OutlinedField(
                                      value: "${_selectedDate.month}/${_selectedDate.day}/${_selectedDate.year}", 
                                      sp: sp, hp: hp, vp: vp,
                                      trailing: Icon(Icons.calendar_today, size: 16 * sp, color: AppColors.blue),
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
                                   _FieldLabel('Invoice Type', sp: sp),
                        SizedBox(height: 6 * vp),
                        _OutlinedDropdown(
                          value: _invoiceType,
                          items: _invoiceTypes,
                          sp: sp, hp: hp, vp: vp,
                          onChanged: (v) => setState(() => _invoiceType = v!),
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
                                     _FieldLabel('Price Type', sp: sp),
                        SizedBox(height: 6 * vp),
                        _OutlinedDropdown(
                          value: _priceType ?? widget.priceType,
                          items: _priceTypes,
                          sp: sp, hp: hp, vp: vp,
                          onChanged: (v) => setState(() => _priceType = v!),
                        ),
                                ],
                              ),
                            ),
                            SizedBox(width: 10 * hp),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _FieldLabel('Tax Type', sp: sp),
                        SizedBox(height: 6 * vp),
                        _OutlinedDropdown(
                          value: _taxType ?? widget.taxType,
                          items: _taxTypes,
                          sp: sp, hp: hp, vp: vp,
                          onChanged: (v) => setState(() => _taxType = v!),
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
                                    ? '${_selectedCustomer!['Ledger_Name']} - ${_selectedCustomer!['id']}'
                                    : 'No Customer Selected',
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
                                    _FieldLabel('Contact Person', sp: sp),
                                    SizedBox(height: 5 * vp),
                                    _OutlinedField(
                                        value: "${_selectedCustomer?['Contact_Person'] ?? 'N/A'}",
                                        sp: sp,
                                        hp: hp,
                                        vp: vp),
                                    SizedBox(height: 12 * vp),
                                    _FieldLabel('Phone Number', sp: sp),
                                    SizedBox(height: 5 * vp),
                                    _OutlinedField(
                                        value: "${_selectedCustomer?['Phone'] ?? 'N/A'}",
                                        sp: sp,
                                        hp: hp,
                                        vp: vp),
                                    SizedBox(height: 12 * vp),
                                    _FieldLabel('Email', sp: sp),
                                    SizedBox(height: 5 * vp),
                                    _OutlinedField(
                                        value: "${_selectedCustomer?['Email'] ?? 'N/A'}",
                                        sp: sp,
                                        hp: hp,
                                        vp: vp),
                                    SizedBox(height: 12 * vp),
                                    Row(
                                      children: [
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              _FieldLabel('Type', sp: sp),
                                              SizedBox(height: 5 * vp),
                                              _OutlinedField(
                                                  value: "${_selectedCustomer?['category'] ?? 'N/A'}",
                                                  sp: sp,
                                                  hp: hp,
                                                  vp: vp),
                                            ],
                                          ),
                                        ),
                                        SizedBox(width: 10 * hp),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              _FieldLabel('Remarks', sp: sp),
                                              SizedBox(height: 5 * vp),
                                              _OutlinedField(
                                                  value: "${_selectedCustomer?['Remarks'] ?? 'N/A'}",
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
                                          horizontal: 12 * hp, vertical: 10 * vp),
                                      decoration: BoxDecoration(
                                        color: AppColors.bgCardAlt,
                                        borderRadius: BorderRadius.circular(10),
                                        border: Border.all(color: AppColors.divider),
                                      ),
                                      child: Text(
                                        "${_selectedCustomer?['Address'] ?? 'N/A'}",
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
                              builder: (context) => DirectInvoiceSelectedProductsScreen(
                                selectedProducts: widget.selectedProducts,
                                totalAmount: widget.totalAmount,
                                summary: summary,
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
                                            Text('₹${((product.price * product.selectedQty) - (product.isPercentageDiscount ? (product.price * product.selectedQty * product.discountPercentage / 100) : product.discountAmount)).toInt()}',
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

              
                  // Text('Tax & Compliance'
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
                                  _OutlinedField(value: '₹0.0', sp: sp, hp: hp, vp: vp),
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
                              onChanged: (v) => setState(() => _markFullyPaid = v),
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
            onTap: _createInvoice,
            isCreating: _isCreating,
          ),
        ],
      ),
    );
  }
  void _showDiscountPopup(BuildContext context, double sp, double hp, double vp) {
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
              padding: EdgeInsets.symmetric(horizontal: 20 * hp, vertical: 20 * vp),
              child: Padding(
                padding: EdgeInsets.fromLTRB(
                    0, 0, 0, MediaQuery.of(context).viewInsets.bottom),
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
                    _popupLabelField('Discount Value', discountType == '%' ? '0' : '₹ 0', sp, hp, vp),
                    SizedBox(height: 32 * vp),
                    SizedBox(
                      width: double.infinity,
                      height: 50 * vp,
                      child: ElevatedButton(
                        onPressed: () => Navigator.pop(context),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
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

  Widget _discountTypeOption(String label, String current, double sp, Function(String) onTap) {
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
            padding: EdgeInsets.fromLTRB(
                0, 0, 0, MediaQuery.of(context).viewInsets.bottom),
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
                    style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
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
            padding: EdgeInsets.fromLTRB(
                0, 0, 0, MediaQuery.of(context).viewInsets.bottom),
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
                      backgroundColor: AppColors.primary,
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
            padding: EdgeInsets.fromLTRB(
                0, 0, 0, MediaQuery.of(context).viewInsets.bottom),
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
                      backgroundColor: AppColors.primary,
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
    required this.sp,
    required this.hp,
    required this.vp,
  });
  final String? value;
  final String? hint;
  final Widget? trailing;
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
    required this.summary,
    required this.selectedProducts,
    required this.onTap,
    required this.isCreating,
  });
  final double sp, hp, vp;
  final DirectInvoiceSummary summary;
  final List<DirectInvoiceProduct> selectedProducts;
  final VoidCallback onTap;
  final bool isCreating;

  @override
  Widget build(BuildContext context) {
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
            onTap: isCreating ? null : onTap,
            child: Container(
              padding: EdgeInsets.symmetric(
                  horizontal: 22 * hp, vertical: 12 * vp),
              decoration: BoxDecoration(
                color: isCreating ? Colors.grey : AppColors.bgCard,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppColors.textWhite.withOpacity(0.3)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (isCreating)
                    SizedBox(
                      width: 14 * sp,
                      height: 14 * sp,
                      child: const CircularProgressIndicator(strokeWidth: 2, color: AppColors.primary),
                    )
                  else
                    Text('Create',
                        style: TextStyle(
                          color: AppColors.primary,
                          fontSize: 14 * sp,
                          fontWeight: FontWeight.w700,
                          fontFamily: 'Poppins',
                        )),
                  if (!isCreating) ...[
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