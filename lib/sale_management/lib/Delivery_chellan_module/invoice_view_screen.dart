import 'package:flutter/material.dart';
import 'product_model.dart';
import '../widgets/app_theme.dart';
import '../Sales_Module/sale_dashboard.dart';
import '../widgets/pdf_viewer_screen.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sale_management/core/api_config.dart';

class DeliveryChallanViewScreen extends StatefulWidget {
  final List<DeliveryChallanProduct> selectedProducts;
  final DeliveryChallanSummary summary;
  final String title;
  final Map<String, dynamic>? selectedCustomer;
  final Map<String, dynamic>? challanMetadata;
  final String? pdfUrl;

  const DeliveryChallanViewScreen({
    super.key,
    required this.selectedProducts,
    required this.summary,
    this.title = 'Invoice',
    this.selectedCustomer,
    this.challanMetadata,
    this.pdfUrl,
  });

  @override
  State<DeliveryChallanViewScreen> createState() => _DeliveryChallanViewScreenState();
}

class _DeliveryChallanViewScreenState extends State<DeliveryChallanViewScreen> {
  bool _isCustomerExpanded = false;
  int? _expandedItemIndex;
  bool _isConverting = false;

  void _sendEmail() async {
    Map<String, dynamic>? customer = widget.selectedCustomer != null 
        ? Map<String, dynamic>.from(widget.selectedCustomer!) 
        : null;

    debugPrint("--- Email Debug Info (Delivery Challan) ---");
    debugPrint("Initial Customer Data: $customer");
    
    String email = '';
    
    if (customer != null) {
      email = (customer['email'] ?? customer['Email'] ?? customer['Ledger_Email'] ?? '').toString().trim();
      
      // Fallback: If email is missing, try fetching full customer details from API
      if (email.isEmpty || email == '0') {
        final cusId = customer['id'] ?? customer['cus_id'];
        if (cusId != null) {
          debugPrint("Email missing. Fetching full details for Customer ID: $cusId");
          try {
            final prefs = await SharedPreferences.getInstance();
            final response = await http.post(
              Uri.parse(await ApiConfig.getBaseUrl()),
              body: {
                'type': '2083',
                'cid': prefs.getString('cid') ?? '44555666',
                'device_id': prefs.getString('device_id') ?? '123',
                'lt': prefs.getString('lt') ?? '123',
                'ln': prefs.getString('ln') ?? '123',
                'form': 'sm_main_form_10002',
                'select': '*',
                'where': 'id=$cusId',
              },
            );
            final res = json.decode(response.body);
            debugPrint("Full Details Response (Delivery Challan): $res");
            if (res['error'] == false && res['data'] != null && (res['data'] as List).isNotEmpty) {
              final List results = res['data'];
              final match = results.firstWhere(
                (item) => item['id'].toString() == cusId.toString(),
                orElse: () => null,
              );

              if (match != null) {
                email = (match['email'] ?? match['Email'] ?? match['Ledger_Email'] ?? '').toString().trim();
                if (email.isEmpty || email == '0') {
                  match.forEach((key, value) {
                    if (key.toString().toLowerCase().contains('email') && 
                        value != null && 
                        value.toString().trim().isNotEmpty &&
                        value.toString() != '0') {
                      email = value.toString().trim();
                    }
                  });
                }
                debugPrint("Successfully matched Customer ID $cusId from API. Email: '$email'");
              }
            }
          } catch (e) {
            debugPrint("Error fetching customer details: $e");
          }
        }
      }

      if (email.isEmpty || email == '0') {
        customer.forEach((key, value) {
          if (key.toString().toLowerCase().contains('email') && 
              value != null && 
              value.toString().trim().isNotEmpty &&
              value.toString() != '0') {
            email = value.toString().trim();
            debugPrint("Heuristic Match Found! Key: '$key', Value: '$email'");
          }
        });
      }
    }
    
    debugPrint("Final Resolved Email: '$email'");
    debugPrint("------------------------");

    if (email.isEmpty || email == '0') {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Customer email not available')),
      );
      return;
    }

    final Uri emailLaunchUri = Uri(
      scheme: 'mailto',
      path: email,
      query: encodeQueryParameters(<String, String>{
        'subject': 'Delivery Challan from Total ERP',
        'body': 'Please find attached invoice details.'
      }),
    );
    try {
      await launchUrl(emailLaunchUri, mode: LaunchMode.externalApplication);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not launch email app: $e')),
        );
      }
    }
  }

  String? encodeQueryParameters(Map<String, String> params) {
    return params.entries
        .map((MapEntry<String, String> e) =>
            '${Uri.encodeComponent(e.key)}=${Uri.encodeComponent(e.value)}')
        .join('&');
  }

  Future<String?> _fetchNextNumber(String apiType) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cid = prefs.getString('cid') ?? '44555666';
      final lt = prefs.getString('lt') ?? '123';
      final ln = prefs.getString('ln') ?? '123';
      final deviceId = prefs.getString('device_id') ?? '123';

      String fetchType = '8007'; // Default for Sales Invoice
      if (apiType == '8000') fetchType = '8002';
      if (apiType == '8001') fetchType = '4019';
      if (apiType == '8003') fetchType = '8006';

      final response = await http.post(
        Uri.parse(await ApiConfig.getBaseUrl()),
        body: {
          'type': fetchType.toString(),
          'cid': cid.toString(),
          'lt': lt.toString(),
          'ln': ln.toString(),
          'device_id': deviceId.toString(),
        },
      );

      final res = json.decode(response.body);
      bool isSuccess = (res['error'] == false) || (res['status'] == true);
      final generatedNumber = res['order_no'] ?? res['quotation_number'] ?? res['invoice_no'] ?? res['dc_code'];
      
      if (isSuccess && generatedNumber != null) {
        return generatedNumber.toString();
      }
    } catch (e) {
      debugPrint("Error fetching next number: $e");
    }
    return '';
  }

  Future<void> _convertTo(String targetType, String apiType) async {
    setState(() => _isConverting = true);
    try {
      final meta = widget.challanMetadata;
      final prefs = await SharedPreferences.getInstance();

      final cid = meta?['cid'] ?? prefs.getString('cid') ?? '44555666';
      final uid = meta?['uid'] ?? prefs.getString('uid') ?? '11';
      final bid = meta?['bid'] ?? prefs.getString('bid') ?? '1';
      final lt = meta?['lt'] ?? prefs.getString('lt') ?? '1';
      final ln = meta?['ln'] ?? prefs.getString('ln') ?? '1';
      final deviceId = meta?['device_id'] ?? prefs.getString('device_id') ?? '11';
      final token = meta?['token'] ?? prefs.getString('token') ?? 'tdtyu34';
      final roleId = meta?['role_id'] ?? prefs.getString('role_id') ?? '2';

      final String invoiceDate = DateTime.now().toString().split(' ').first;

      final s = widget.summary;
      final c = widget.selectedCustomer;

      // Fetch autogenerated number
      final String nextNo = await _fetchNextNumber(apiType) ?? '';

      final Map<String, String> body = {
        'type': apiType.toString(),
        'cid': cid.toString(),
        'uid': uid.toString(),
        'bid': bid.toString(),
        'lt': lt.toString(),
        'ln': ln.toString(),
        'device_id': deviceId.toString(),
        'token': token.toString(),
        'role_id': roleId.toString(),
        'invoice_no': nextNo.toString(),
        'date': invoiceDate.toString(),
        'cus_id': (c?['id'] ?? '').toString(),
        'customer_name': (c?['Ledger_Name'] ?? '').toString(),
        'customer_gstin': (c?['gst'] ?? c?['gstin'] ?? c?['GSTIN'] ?? '').toString(),
        'address': (c?['address'] ?? c?['Address'] ?? c?['b_add1'] ??  '').toString(),
        'mobile': (c?['phone'] ?? c?['Mobile'] ?? '').toString(),
        'trans_type': '1',
        'trans_name': '',
        'b_name': (c?['Ledger_Name'] ?? '').toString(),
        'b_gst': (c?['gst'] ?? c?['gstin'] ?? c?['GSTIN'] ?? '').toString(),
        'b_add1': (c?['address'] ?? c?['Address'] ?? c?['b_add1'] ?? '').toString(),
        'b_loc': (c?['city'] ?? c?['location'] ?? '').toString(),
        'b_pin': (c?['pin'] ?? c?['pincode'] ?? '').toString(),
        'b_scode': (c?['state_code'] ?? '').toString(),
        'taxable_total': s.taxableAmount.toStringAsFixed(2),
        'cgst': s.cgst.toStringAsFixed(2),
        'sgst': s.sgst.toStringAsFixed(2),
        'igst': s.igst.toStringAsFixed(2),
        'taxtotal': (s.igst + s.cgst + s.sgst).toStringAsFixed(2),
        'total_gst': (s.igst + s.cgst + s.sgst).toStringAsFixed(2),
        'g_total': s.finalPayable.toStringAsFixed(2),
        'grand_total': s.finalPayable.toStringAsFixed(2),
        'discount': '0.00',
        's_type': '1',
        'mtax': s.taxType == 'IGST' ? '1' : '2',
        'price_type': s.priceType == 'Include Tax' ? '2' : '1',
        'tds_type': '20',
        'tcs_type': '40',
        'total_tds': '0.00',
        'total_tcs': '0.00',
        'payment_mode': 'Cash',
      };

      if (apiType == '8005') {
        // Use indexed format for Sales Invoice
        for (int i = 0; i < widget.selectedProducts.length; i++) {
          final p = widget.selectedProducts[i];
          double taxableVal = (p.price * p.selectedQty) - 
              (p.isPercentageDiscount ? (p.price * p.selectedQty * p.discountPercentage / 100) : (p.discountAmount * p.selectedQty));
          double taxPer = 18.0; 
          double totalItem = taxableVal * (1 + taxPer / 100);

          body['pro_name[$i]'] = p.name;
          body['product_id[$i]'] = p.id;
          body['pid[$i]'] = p.id;
          body['hsn[$i]'] = p.hsnCode ?? '';
          body['qty[$i]'] = p.selectedQty.toString();
          body['uom[$i]'] = p.uom ?? 'NOS';
          body['rate[$i]'] = p.price.toStringAsFixed(2);
          body['taxable[$i]'] = taxableVal.toStringAsFixed(2);
          body['tax[$i]'] = taxPer.toStringAsFixed(0);
          body['total[$i]'] = totalItem.toStringAsFixed(2);
          body['cat[$i]'] = p.category ?? '';
          body['itm_code[$i]'] = p.productCode ?? ''; 
          body['qc_sts[$i]'] = '1';
          body['remarks[$i]'] = 'OK';
        }
      } else {
        // Use JSON format for other types (8000, 8001, 8003)
        final List<Map<String, dynamic>> productsJsonList = widget.selectedProducts.map((p) {
          double taxableVal = (p.price * p.selectedQty) - 
              (p.isPercentageDiscount ? (p.price * p.selectedQty * p.discountPercentage / 100) : (p.discountAmount * p.selectedQty));
          double taxPer = 18.0; 
          double totalItem = taxableVal * (1 + taxPer / 100);

          return {
            "product_name": p.name,
            "product_id": p.id,
            "pid": p.id,
            "hsn": p.hsnCode ?? '',
            "hsn_code": p.hsnCode ?? '',
            "quantity": p.selectedQty,
            "qty": p.selectedQty,
            "uom": p.uom ?? 'NOS',
            "unit_price": p.price,
            "rate": p.price,
            "taxable_total": taxableVal,
            "taxable_value": taxableVal,
            "tax": taxPer,
            "total_amount": totalItem,
            "total": totalItem,
            "cgst": s.taxType != 'IGST' ? (totalItem - taxableVal) / 2 : 0,
            "sgst": s.taxType != 'IGST' ? (totalItem - taxableVal) / 2 : 0,
            "igst": s.taxType == 'IGST' ? (totalItem - taxableVal) : 0,
            "itm_code": p.productCode ?? '',
            "cat": p.category ?? '',
          };
        }).toList();
        body['products'] = json.encode(productsJsonList);
      }

      debugPrint("Converting Order with body: $body");

      final response = await http.post(
        Uri.parse(await ApiConfig.getBaseUrl()),
        body: body,
      );

      final res = json.decode(response.body);
      debugPrint("Conversion Response: $res");

      if (res['error'] == false) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Converted to $targetType Successfully'), backgroundColor: const Color(0xFF26A69A)),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(res['error_msg'] ?? 'Conversion Failed'), backgroundColor: Colors.red),
          );
        }
      }
    } catch (e) {
      debugPrint('Error converting: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isConverting = false);
    }
  }
  bool _isFabExpanded = false;


  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context);
    final sp = mq.size.width / 375;
    final hp = mq.size.width / 375;
    final vp = mq.size.height / 812;

    final s = widget.summary;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        _navigateToDashboard();
      },
      child: Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: _navigateToDashboard,
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'CH - 1',
              style: TextStyle(color: Colors.white, fontSize: 16 * sp, fontWeight: FontWeight.bold, fontFamily: 'Poppins'),
            ),
            Row(
              children: [
                Text(
                  'Challan - ',
                  style: TextStyle(color: Colors.white, fontSize: 11 * sp, fontFamily: 'Poppins'),
                ),
                Text(
                  'Pending',
                  style: TextStyle(color: Colors.orange, fontSize: 11 * sp, fontWeight: FontWeight.bold, fontFamily: 'Poppins'),
                ),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(icon: const Icon(Icons.more_vert, color: Colors.white, size: 20), onPressed: () => _showMoreOptions(context)),
        ],
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(16 * hp),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.person, color: Color(0xFF005BBF), size: 20),
                      SizedBox(width: 8 * hp),
                      Text('Customer Details', style: TextStyle(fontSize: 15 * sp, fontWeight: FontWeight.w700, fontFamily: 'Poppins')),
                    ],
                  ),
                  SizedBox(height: 12 * vp),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: const Border(left: BorderSide(color: Color(0xFF005BBF), width: 5)),
                      boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 4, offset: const Offset(0, 2))],
                    ),
                    child: Column(
                      children: [
                        ListTile(
                          leading: CircleAvatar(backgroundColor: const Color(0xFFEEF0FB), radius: 20 * hp, child: const Icon(Icons.person, color: Color(0xFF005BBF), size: 22)),
                          title: Text(
                            widget.selectedCustomer != null 
                                ? '${widget.selectedCustomer!['Ledger_Name']} - ${widget.selectedCustomer!['id']}'
                                : 'Select a Customer',
                            style: TextStyle(fontSize: 14 * sp, fontWeight: FontWeight.w700, fontFamily: 'Poppins'),
                          ),
                          trailing: IconButton(
                            icon: Icon(_isCustomerExpanded ? Icons.visibility_outlined : Icons.visibility_off_outlined, color: _isCustomerExpanded ? const Color(0xFF005BBF) : Colors.grey),
                            onPressed: () => setState(() => _isCustomerExpanded = !_isCustomerExpanded),
                          ),
                        ),
                        if (_isCustomerExpanded)
                          Padding(
                            padding: EdgeInsets.fromLTRB(16 * hp, 0, 16 * hp, 16 * vp),
                            child: Column(
                              children: [
                                const Divider(),
                                SizedBox(height: 12 * vp),
                                Row(
                                  children: [
                                    Expanded(child: _customerField('Contact Person', widget.selectedCustomer?['Ledger_Name'] ?? 'N/A', sp, hp, vp)),
                                    SizedBox(width: 12 * hp),
                                    Expanded(child: _customerField('GST Number', widget.selectedCustomer?['gst'] ?? widget.selectedCustomer?['gst_no'] ?? widget.selectedCustomer?['gst_number'] ?? 'N/A', sp, hp, vp)),
                                  ],
                                ),
                                SizedBox(height: 12 * vp),
                                _customerField('Phone Number', widget.selectedCustomer?['phone']?.toString() ?? 'N/A', sp, hp, vp),
                                SizedBox(height: 12 * vp),
                                _customerField('Billing Address', widget.selectedCustomer?['address'] ?? 'No address provided', sp, hp, vp),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ),
                  SizedBox(height: 24 * vp),
                  Text('Item(${widget.selectedProducts.length})', style: TextStyle(fontSize: 15 * sp, fontWeight: FontWeight.w700, fontFamily: 'Poppins')),
                  SizedBox(height: 12 * vp),
                  Container(
                    decoration: BoxDecoration(color: const Color(0xFFF5F7FA), borderRadius: BorderRadius.circular(12)),
                    child: ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: widget.selectedProducts.length,
                      separatorBuilder: (c, i) => const Divider(height: 1),
                      itemBuilder: (context, index) {
                        final p = widget.selectedProducts[index];
                        final isExpanded = _expandedItemIndex == index;
                        return Column(
                          children: [
                            ListTile(
                              contentPadding: EdgeInsets.symmetric(horizontal: 16 * hp, vertical: 8 * vp),
                              title: Row(
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Expanded(
                                              child: Text(
                                                p.name, 
                                                style: TextStyle(fontSize: 14 * sp, fontWeight: FontWeight.w700, fontFamily: 'Poppins'),
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                            SizedBox(width: 8 * hp),
                                            GestureDetector(
                                              onTap: () => setState(() => _expandedItemIndex = isExpanded ? null : index),
                                              child: Icon(
                                                isExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                                                size: 22 * sp,
                                                color: const Color(0xFF3D5481),
                                              ),
                                            ),
                                            const Spacer(),
                                            Text('₹${(p.price * p.selectedQty - (p.isPercentageDiscount ? (p.price * (p.discountPercentage / 100) * p.selectedQty) : (p.discountAmount * p.selectedQty))).toInt()}', style: TextStyle(color: const Color.fromARGB(255, 113, 191, 132), fontSize: 14 * sp, fontWeight: FontWeight.w700, fontFamily: 'Poppins')),
                                          ],
                                        ),
                                        Text('x ${p.selectedQty.toStringAsFixed(2)} OTH', style: TextStyle(color: const Color(0xFF005BBF).withOpacity(0.6), fontSize: 11 * sp, fontFamily: 'Poppins')),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            AnimatedCrossFade(
                              duration: const Duration(milliseconds: 300),
                              crossFadeState: isExpanded ? CrossFadeState.showSecond : CrossFadeState.showFirst,
                              firstChild: const SizedBox.shrink(),
                              secondChild: Padding(
                                padding: EdgeInsets.fromLTRB(16 * hp, 0, 16 * hp, 16 * vp),
                                child: Column(
                                  children: [
                                    _invoiceItemDetail(Icons.sell_outlined, 'PRICE', '₹${p.price.toInt()}.00', sp, hp),
                                    SizedBox(height: 8 * vp),
                                    _invoiceItemDetail(Icons.inventory_2_outlined, 'QTY', '${p.selectedQty}', sp, hp),
                                    SizedBox(height: 8 * vp),
                                    _invoiceItemDetail(Icons.percent, 'DISC', p.isPercentageDiscount ? '${p.discountPercentage}%' : '₹${p.discountAmount}', sp, hp),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                  SizedBox(height: 24 * vp),
                  Container(
                    padding: EdgeInsets.all(20 * hp),
                    margin: EdgeInsets.only(bottom: 120 * vp),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 15, offset: const Offset(0, 5))]
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Bill Summary', style: TextStyle(fontSize: 16 * sp, fontWeight: FontWeight.w800, fontFamily: 'Poppins')),
                        SizedBox(height: 20 * vp),
                        
                        _summaryRow('Taxable Total', '₹ ${s.taxableAmount.toStringAsFixed(2)}', sp, Colors.black87),
                        SizedBox(height: 12 * vp),
                        if (s.igst > 0) ...[
                          _summaryRow('IGST', '₹ ${s.igst.toStringAsFixed(2)}', sp, Colors.black87),
                          SizedBox(height: 12 * vp),
                        ],
                        if (s.cgst > 0) ...[
                          _summaryRow('CGST', '₹ ${s.cgst.toStringAsFixed(2)}', sp, Colors.black87),
                          SizedBox(height: 12 * vp),
                        ],
                        if (s.sgst > 0) ...[
                          _summaryRow('SGST', '₹ ${s.sgst.toStringAsFixed(2)}', sp, Colors.black87),
                          SizedBox(height: 12 * vp),
                        ],

                        _summaryRow('Round Off', '₹ ${s.roundOff.toStringAsFixed(2)}', sp, Colors.black87),
                        SizedBox(height: 12 * vp),
                        _summaryRow('Total GST', '₹ ${(s.igst + s.cgst + s.sgst).toStringAsFixed(2)}', sp, Colors.black87),
                        
                        SizedBox(height: 20 * vp),
                        const Divider(),
                        SizedBox(height: 16 * vp),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text('Final Payable', style: TextStyle(fontSize: 15 * sp, fontWeight: FontWeight.w800, fontFamily: 'Poppins')),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text('TOTAL AMOUNT DUE', style: TextStyle(fontSize: 9 * sp, color: Colors.grey, fontWeight: FontWeight.w700, fontFamily: 'Poppins')),
                                Text('₹ ${s.finalPayable.toStringAsFixed(2)}', style: TextStyle(color: const Color(0xFF2E7D32), fontSize: 18 * sp, fontWeight: FontWeight.w900, fontFamily: 'Poppins')),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          Positioned(
            bottom: 20 * vp,
            right: 20 * hp,
            child: _buildSpeedDial(sp, hp, vp),
          ),
        ],
      ),
    ),
    );
  }

  void _navigateToDashboard() {
    FocusScope.of(context).unfocus();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const DashboardPage()),
          (route) => false,
        );
      }
    });
  }

  void _launchPDF() {
    if (widget.pdfUrl == null || widget.pdfUrl!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('PDF URL not available')),
      );
      return;
    }
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PDFViewerScreen(
          url: widget.pdfUrl!,
          title: 'Delivery Challan PDF',
        ),
      ),
    );
  }

  Widget _buildSpeedDial(double sp, double hp, double vp) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        if (_isFabExpanded) ...[
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
               _dialItem(icon: Icons.picture_as_pdf_outlined, label: 'PDF View', sp: sp, vp: vp, customLabel: 'PDF\nView', onTap: _launchPDF),
            ],
          ),
          SizedBox(height: 10 * vp),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _dialItem(icon: Icons.share, label: 'Share', sp: sp, vp: vp),
              SizedBox(width: 10 * hp),
              _mainFabToggle(),
            ],
          ),
        ] else
          _mainFabToggle(),
      ],
    );
  }

  Widget _mainFabToggle() {
    return FloatingActionButton(
      heroTag: 'main_fab',
      onPressed: () => setState(() => _isFabExpanded = !_isFabExpanded),
      backgroundColor: AppColors.primary,
      elevation: 4,
      child: Icon(_isFabExpanded ? Icons.close : Icons.add, color: Colors.white, size: _isFabExpanded ? 28 : 30),
    );
  }

  Widget _dialItem({required IconData icon, required String label, required double sp, required double vp, String? customLabel, VoidCallback? onTap, bool isLoading = false}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 56 * sp,
        height: 56 * sp,
        decoration: BoxDecoration(color: AppColors.primary, shape: BoxShape.circle, boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4)]),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (isLoading)
              SizedBox(width: 18 * sp, height: 18 * sp, child: const CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
            else
              Icon(icon, color: Colors.white, size: 18 * sp),
            Text(customLabel ?? label, textAlign: TextAlign.center, style: TextStyle(color: Colors.white, fontSize: 9 * sp, fontWeight: FontWeight.bold, height: 1.1, fontFamily: 'Poppins')),
          ],
        ),
      ),
    );
  }

  void _showAttachmentPopup(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        final mq = MediaQuery.of(context);
        final sp = mq.size.width / 375;
        final hp = mq.size.width / 375;
        final vp = mq.size.height / 812;
        return Container(
          height: 180 * vp,
          decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
          child: Column(
            children: [
              SizedBox(height: 12 * vp),
              Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(2))),
              SizedBox(height: 30 * vp),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _mediaOption(Icons.camera_alt_outlined, 'Camera', sp, hp, vp),
                  _mediaOption(Icons.upload_outlined, 'Upload File', sp, hp, vp),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  void _showConvertPopup(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        final mq = MediaQuery.of(context);
        final sp = mq.size.width / 375;
        final hp = mq.size.width / 375;
        final vp = mq.size.height / 812;
        return Container(
          decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
          padding: EdgeInsets.symmetric(horizontal: 20 * hp, vertical: 12 * vp),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(2))),
              SizedBox(height: 20 * vp),
              _convertRow(Icons.sync_alt, 'Delivery Challan to Sales Invoice', sp, hp, vp, onTap: () => _convertTo('Sales Invoice', '8005')),
              _convertRow(Icons.sync_alt, 'Delivery Challan to Sales Order', sp, hp, vp, onTap: () => _convertTo('Sales Order', '8001')),
              _convertRow(Icons.sync_alt, 'Delivery Challan to proforma Invoice', sp, hp, vp, onTap: () => _convertTo('Proforma Invoice', '8000')),
              SizedBox(height: 20 * vp),
            ],
          ),
        );
      },
    );
  }

  Widget _mediaOption(IconData icon, String label, double sp, double hp, double vp) {
    return Column(
      children: [
        Container(
          width: 70 * sp,
          height: 70 * sp,
          decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: AppColors.primary)),
          child: Icon(icon, color: AppColors.primary, size: 28 * sp),
        ),
        SizedBox(height: 12 * vp),
        Text(label, style: TextStyle(color: AppColors.primary, fontSize: 13 * sp, fontWeight: FontWeight.bold, fontFamily: 'Poppins')),
      ],
    );
  }

  Widget _convertRow(IconData icon, String label, double sp, double hp, double vp, {VoidCallback? onTap}) {
    return GestureDetector(
      onTap: () {
        Navigator.pop(context);
        if (onTap != null) onTap();
      },
      child: Container(
      margin: EdgeInsets.only(bottom: 12 * vp),
      padding: EdgeInsets.symmetric(horizontal: 16 * hp, vertical: 12 * vp),
      decoration: BoxDecoration(color: const Color(0xFFE0F7FA).withOpacity(0.5), borderRadius: BorderRadius.circular(8)),
      child: Row(
        children: [
          Icon(Icons.sync_alt, color: const Color(0xFF00ACC1), size: 20 * sp),
          SizedBox(width: 12 * hp),
          Text(label, style: TextStyle(fontSize: 14 * sp, fontWeight: FontWeight.bold, fontFamily: 'Poppins')),
        ],
      ),
    ),
    );
  }

  void _showMoreOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        final mq = MediaQuery.of(context);
        final sp = mq.size.width / 375;
        final hp = mq.size.width / 375;
        final vp = mq.size.height / 812;
        return Container(
          decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
          padding: EdgeInsets.symmetric(horizontal: 20 * hp, vertical: 20 * vp),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const SizedBox(width: 40),
                  Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(2))),
                  IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(context)),
                ],
              ),
              _sectionHeader('OTHERS', const Color(0xFF005BBF), sp),
              SizedBox(height: 20 * vp),
              Wrap(
                spacing: 20 * hp,
                runSpacing: 20 * vp,
                children: [
                  _OptionItem(icon: Icons.description_outlined, label: 'Reference', iconColor: const Color(0xFF0045BC), sp: sp, vp: vp),
                  _OptionItem(
                    icon: Icons.attach_file,
                    label: 'Attachments',
                    iconColor: const Color(0xFF0045BC),
                    sp: sp,
                    vp: vp,
                    onTap: () {
                      Navigator.pop(context);
                      _showAttachmentPopup(context);
                    },
                  ),
                  _OptionItem(icon: Icons.print_outlined, label: 'Print', iconColor: const Color(0xFF0045BC), sp: sp, vp: vp, onTap: () { Navigator.pop(context); _launchPDF(); }),
                  _OptionItem(icon: Icons.email_outlined, label: 'Send Email', iconColor: const Color(0xFF0045BC), sp: sp, vp: vp, onTap: () { Navigator.pop(context); _sendEmail(); }),
                  _OptionItem(icon: Icons.sms_outlined, label: 'Send SMS', iconColor: const Color(0xFF0045BC), sp: sp, vp: vp),
                ],
              ),
              SizedBox(height: 30 * vp),
              _sectionHeader('CONVERT', const Color(0xFF005BBF), sp),
              SizedBox(height: 20 * vp),
              Wrap(
                spacing: 20 * hp,
                runSpacing: 20 * vp,
                children: [
                  _OptionItem(
                    icon: Icons.replay_rounded,
                    label: 'Convert',
                    iconColor: AppColors.primary,
                    sp: sp,
                    vp: vp,
                    onTap: () {
                      Navigator.pop(context);
                      _showConvertPopup(context);
                    },
                  ),
                  _OptionItem(icon: Icons.local_shipping_outlined, label: 'Delivery Challan', iconColor: const Color(0xFFFFA726), sp: sp, vp: vp),
                  _OptionItem(icon: Icons.qr_code_2, label: 'Generate QR Code', iconColor: const Color(0xFF26C6DA), sp: sp, vp: vp),
                  _OptionItem(icon: Icons.receipt_long, label: 'Convert E-Way Bill', iconColor: const Color(0xFF9CCC65), sp: sp, vp: vp),
                  _OptionItem(icon: Icons.computer, label: 'Convert E-Invoice', iconColor: const Color(0xFF78909C), sp: sp, vp: vp),
                ],
              ),
              SizedBox(height: 30 * vp),
              _sectionHeader('CANCEL', const Color(0xFFE53935), sp),
              SizedBox(height: 20 * vp),
              Row(children: [_OptionItem(icon: Icons.close_rounded, label: 'Cancel Challan', iconColor: const Color(0xFFEF9A9A), sp: sp, vp: vp, isCancel: true)]),
              SizedBox(height: 20 * vp),
            ],
          ),
        );
      },
    );
  }

  Widget _sectionHeader(String label, Color color, double sp) {
    return Row(children: [Text(label, style: TextStyle(color: color, fontSize: 16 * sp, fontWeight: FontWeight.w800, letterSpacing: 0.8, fontFamily: 'Poppins')), const SizedBox(width: 10), const Expanded(child: Divider())]);
  }

  Widget _customerField(String label, String value, double sp, double hp, double vp) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(color: Colors.grey.shade600, fontSize: 12 * sp, fontWeight: FontWeight.w500, fontFamily: 'Poppins')),
        SizedBox(height: 6 * vp),
        Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(horizontal: 12 * hp, vertical: 10 * vp),
          decoration: BoxDecoration(color: const Color(0xFFF2F4F6), borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.grey.shade300)),
          child: Text(value, style: TextStyle(color: const Color(0xFF1A1A2E), fontSize: 13 * sp, fontWeight: FontWeight.w500, fontFamily: 'Poppins')),
        ),
      ],
    );
  }

  Widget _invoiceItemDetail(IconData icon, String label, String value, double sp, double hp) {
    return Row(children: [Icon(icon, color: const Color(0xFF005BBF), size: 18 * sp), SizedBox(width: 8 * hp), Text(label, style: TextStyle(color: const Color(0xFF005BBF), fontSize: 13 * sp, fontWeight: FontWeight.w700, fontFamily: 'Poppins')), const Spacer(), Text(value, style: TextStyle(color: const Color(0xFF1E2432), fontSize: 13 * sp, fontWeight: FontWeight.w600, fontFamily: 'Poppins'))]);
  }

  Widget _summaryRow(String label, String value, double sp, Color valueColor, {bool hasInfo = false}) {
    return Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Row(children: [Text(label, style: TextStyle(color: Colors.black54, fontSize: 13 * sp, fontWeight: FontWeight.w500, fontFamily: 'Poppins')), if (hasInfo) ...[const SizedBox(width: 4), Icon(Icons.info_outline, size: 14 * sp, color: Colors.grey)]]), Text(value, style: TextStyle(color: valueColor, fontSize: 13 * sp, fontWeight: FontWeight.bold, fontFamily: 'Poppins'))]);
  }
}

class _OptionItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color iconColor;
  final double sp, vp;
  final bool isCancel;
  final VoidCallback? onTap;
  const _OptionItem({required this.icon, required this.label, required this.iconColor, required this.sp, required this.vp, this.isCancel = false, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: 80 * sp,
        child: Column(
          children: [
            Container(width: 50 * sp, height: 40 * sp, decoration: BoxDecoration(color: isCancel ? const Color(0xFFEF9A9A).withOpacity(0.3) : const Color(0xFFE0F7FA), borderRadius: BorderRadius.circular(12)), child: Icon(icon, color: isCancel ? Colors.red : iconColor, size: 22 * sp)),
            SizedBox(height: 6 * vp),
            Text(label, textAlign: TextAlign.center, style: TextStyle(fontSize: 10 * sp, fontWeight: FontWeight.w600, color: Colors.black87, fontFamily: 'Poppins')),
          ],
        ),
      ),
    );
  }
}