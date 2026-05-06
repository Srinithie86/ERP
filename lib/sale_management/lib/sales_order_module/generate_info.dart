import 'package:flutter/material.dart';
import 'all_products_screen.dart';
import 'all_voice_screen.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sale_management/core/api_config.dart';

class SalesOrderGenerateInfoScreen extends StatefulWidget {
  const SalesOrderGenerateInfoScreen({super.key});

  @override
  State<SalesOrderGenerateInfoScreen> createState() => _SalesOrderGenerateInfoScreenState();
}

class _SalesOrderGenerateInfoScreenState extends State<SalesOrderGenerateInfoScreen> {
  String _selectedInvoiceType = 'Tax Invoice';
  String _selectedTaxType = 'IGST';
  String _selectedPriceType = 'Exclude tax';
  final String _invoiceDate = '11/24/2023';
  final String _invoiceNo = 'SPS/26-27/SI0006';

  // Customer selection
  List<dynamic> _allCustomers = [];
  List<dynamic> _filteredCustomers = [];
  Map<String, dynamic>? _selectedCustomer;
  final TextEditingController _customerSearchController = TextEditingController();
  final TextEditingController _orderNoController = TextEditingController();
  bool _isFetchingCustomers = false;

  @override
  void initState() {
    super.initState();
    _fetchCustomers();
    _generateOrderNumber();
    _fetchAllDropdowns();
  }

  void _fetchAllDropdowns() {
    _fetchDropdownData('17', _invoiceTypes, (val) => _selectedInvoiceType = val, _selectedInvoiceType);
    _fetchDropdownData('16', _priceTypes, (val) => _selectedPriceType = val, _selectedPriceType);
    _fetchDropdownData('26', _taxTypes, (val) => _selectedTaxType = val, _selectedTaxType);
  }

  Future<void> _fetchDropdownData(String listId, List<String> targetList, Function(String) onSelectUpdate, String currentSelection) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cid = prefs.getString('cid') ?? '44555666';
      final lt = prefs.getString('lt') ?? '123';
      final ln = prefs.getString('ln') ?? '123';
      final deviceId = prefs.getString('device_id') ?? '123';

      final response = await http.post(
        Uri.parse(await ApiConfig.getBaseUrl()),
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
        for (var item in dropdownData) {
          if (item['label'] != null) {
            uniqueItems.add(item['label'].toString().trim());
          }
        }

        if (uniqueItems.isNotEmpty) {
          setState(() {
            targetList.clear();
            targetList.addAll(uniqueItems);
            if (!targetList.contains(currentSelection)) {
              onSelectUpdate(targetList.first);
            }
          });
        }
      }
    } catch (e) {
      debugPrint("Error fetching dropdown (listId $listId): $e");
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
        Uri.parse(await ApiConfig.getBaseUrl()),
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
      debugPrint("Error fetching customers: $e");
    } finally {
      setState(() => _isFetchingCustomers = false);
    }
  }

  Future<void> _generateOrderNumber() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cid = prefs.getString('cid') ?? '44555666';
      final lt = prefs.getString('lt') ?? '145';
      final ln = prefs.getString('ln') ?? '145';
      final deviceId = prefs.getString('device_id') ?? '12345';

      final response = await http.post(
        Uri.parse(await ApiConfig.getBaseUrl()),
        body: {
          'type': '4019',
          'cid': cid,
          'lt': lt,
          'ln': ln,
          'device_id': deviceId,
        },
      );

      final res = json.decode(response.body);
      debugPrint("Order number response (API 4019): $res");
      
      // API might return 'error': false or 'status': true
      bool isSuccess = (res['error'] == false) || (res['status'] == true);
      
      // Try multiple possible keys for the order number
      final generatedNumber = res['order_no'] ?? res['quotation_number'] ?? res['invoice_no'];
      
      if (isSuccess && generatedNumber != null) {
        setState(() {
          _orderNoController.text = generatedNumber.toString();
        });
      }
    } catch (e) {
      debugPrint("Error generating order number: $e");
    }
  }

  void _filterCustomers(String query) {
    setState(() {
      _filteredCustomers = _allCustomers
          .where((c) =>
              (c['Ledger_Name'] ?? '').toString().toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }

  DateTime _deliveryDate = DateTime.now();
  String _selectedStatus = 'Pending';
  final List<String> _statusTypes = ['Pending', 'Confirmed', 'Cancelled'];

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

  // ✅ Advanced Options toggle
  bool _advancedOptionsExpanded = false;

  // ✅ Eye toggle for customer details
  bool _isCustomerDetailsVisible = false;

  // customer data is now dynamic

  final List<String> _invoiceTypes = [
    'Tax Invoice',
    'Proforma Invoice',
    'Credit Note',
    'Debit Note',
  ];

  final List<String> _taxTypes = ['IGST', 'CGST + SGST', 'None'];

  final List<String> _priceTypes = ['Exclude tax', 'Include tax'];

  // ✅ Advanced Options items with icons
  final List<Map<String, dynamic>> _advancedOptions = [
    {'label': 'Select Dispatch Address', 'icon': Icons.local_shipping_outlined},
    {'label': 'Add Reference', 'icon': Icons.assignment_outlined},
    {'label': 'Add Extra Discount', 'icon': Icons.discount_outlined},
    {'label': 'Delivery / Shipping Charges', 'icon': Icons.wallet_outlined},
    {'label': 'Packing Charges', 'icon': Icons.inventory_2_outlined},
  ];

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context);
    final screenWidth = mq.size.width;
    final screenHeight = mq.size.height;
    final topPadding = mq.padding.top;
    final bottomPadding = mq.padding.bottom;

    final double hp = screenWidth / 390;
    final double vp = screenHeight / 844;
    final double sp = (screenWidth / 390).clamp(0.8, 1.2);

    final double horizontalPadding = screenWidth * 0.04;
    final double sectionSpacing = screenHeight * 0.015;
    final double cardPadding = screenWidth * 0.04;
    final double labelFontSize = screenWidth * 0.032;
    final double valueFontSize = screenWidth * 0.038;
    final double headerFontSize = screenWidth * 0.042;
    final double iconSize = screenWidth * 0.055;

    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F8),
      body: Column(
        children: [
          _buildAppBar(
            topPadding: topPadding,
            screenWidth: screenWidth,
            headerFontSize: headerFontSize,
            iconSize: iconSize,
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.only(
                bottom: bottomPadding + screenHeight * 0.02,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: sectionSpacing),
                  _buildGeneralInfoCard(
                    screenWidth: screenWidth,
                    horizontalPadding: horizontalPadding,
                    cardPadding: cardPadding,
                    labelFontSize: labelFontSize,
                    valueFontSize: valueFontSize,
                    headerFontSize: headerFontSize,
                    iconSize: iconSize,
                    sectionSpacing: sectionSpacing,
                  ),
                  SizedBox(height: sectionSpacing),
                  _buildCustomerDetailsSection(
                    screenWidth: screenWidth,
                    horizontalPadding: horizontalPadding,
                    cardPadding: cardPadding,
                    labelFontSize: labelFontSize,
                    valueFontSize: valueFontSize,
                    headerFontSize: headerFontSize,
                    iconSize: iconSize,
                    sectionSpacing: sectionSpacing,
                    vp: vp,
                    sp: sp,
                  ),
                  SizedBox(height: sectionSpacing),
                  _buildAddProductsSection(
                    screenWidth: screenWidth,
                    horizontalPadding: horizontalPadding,
                    cardPadding: cardPadding,
                    valueFontSize: valueFontSize,
                    iconSize: iconSize,
                  ),
                  SizedBox(height: sectionSpacing),
                  _buildAdvancedOptionsSection(
                    screenWidth: screenWidth,
                    horizontalPadding: horizontalPadding,
                    cardPadding: cardPadding,
                    labelFontSize: labelFontSize,
                    valueFontSize: valueFontSize,
                    iconSize: iconSize,
                  ),
                  SizedBox(height: sectionSpacing),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─── App Bar ──────────────────────────────────────────────────────────────

  Widget _buildAppBar({
    required double topPadding,
    required double screenWidth,
    required double headerFontSize,
    required double iconSize,
  }) {
    return Container(
      color: const Color(0xFF00897B),
      padding: EdgeInsets.only(
        top: topPadding + screenWidth * 0.02,
        bottom: screenWidth * 0.035,
        left: screenWidth * 0.03,
        right: screenWidth * 0.04,
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Icon(Icons.arrow_back, color: Colors.white, size: iconSize),
          ),
          SizedBox(width: screenWidth * 0.03),
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const AllSalesOrderPage(),
                ),
              );
            },
            child: Text(
              'Sales Order',
              style: TextStyle(
                color: Colors.white,
                fontSize: headerFontSize * 1.1,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.3,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─── General Information Card ─────────────────────────────────────────────

  Widget _buildGeneralInfoCard({
    required double screenWidth,
    required double horizontalPadding,
    required double cardPadding,
    required double labelFontSize,
    required double valueFontSize,
    required double headerFontSize,
    required double iconSize,
    required double sectionSpacing,
  }) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: horizontalPadding),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(screenWidth * 0.03),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.all(cardPadding),
            child: Row(
              children: [
                Icon(
                  Icons.description,
                  color: const Color(0xFF0045BC),
                  size: iconSize,
                ),
                SizedBox(width: screenWidth * 0.025),
                Text(
                  'General Information',
                  style: TextStyle(
                    fontSize: headerFontSize,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF1A1A2E),
                  ),
                ),
              ],
            ),
          ),

          Padding(
            padding: EdgeInsets.all(cardPadding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildLabel('Order Type', labelFontSize),
                    SizedBox(height: screenWidth * 0.015),
                    _buildDropdown(
                      value: _selectedInvoiceType,
                      items: _invoiceTypes,
                      onChanged: (val) =>
                          setState(() => _selectedInvoiceType = val!),
                      screenWidth: screenWidth,
                      valueFontSize: valueFontSize,
                    ),
                  ],
                ),
                SizedBox(height: sectionSpacing),
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildLabel('Order Date', labelFontSize),
                          SizedBox(height: screenWidth * 0.015),
                          _buildReadOnlyField(
                            text: _invoiceDate,
                            screenWidth: screenWidth,
                            valueFontSize: valueFontSize,
                          ),
                        ],
                      ),
                    ),
                    SizedBox(width: screenWidth * 0.03),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildLabel('Delivery Date', labelFontSize),
                          SizedBox(height: screenWidth * 0.015),
                          GestureDetector(
                            onTap: () => _selectDeliveryDate(context),
                            child: Container(
                              width: double.infinity,
                              padding: EdgeInsets.symmetric(
                                horizontal: screenWidth * 0.035,
                                vertical: screenWidth * 0.032,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF2F4F6),
                                borderRadius: BorderRadius.circular(screenWidth * 0.02),
                                border: Border.all(color: Colors.grey.shade300),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    "${_deliveryDate.month}/${_deliveryDate.day}/${_deliveryDate.year}",
                                    style: TextStyle(
                                      fontSize: valueFontSize,
                                      color: const Color(0xFF1A1A2E),
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  Icon(Icons.calendar_today_outlined, size: iconSize * 0.8, color: const Color(0xFF0045BC)),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                SizedBox(height: sectionSpacing),
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildLabel('Tax Type', labelFontSize),
                          SizedBox(height: screenWidth * 0.015),
                          _buildDropdown(
                            value: _selectedTaxType,
                            items: _taxTypes,
                            onChanged: (val) => setState(() => _selectedTaxType = val!),
                            screenWidth: screenWidth,
                            valueFontSize: valueFontSize,
                          ),
                        ],
                      ),
                    ),
                    SizedBox(width: screenWidth * 0.03),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildLabel('Price Type', labelFontSize),
                          SizedBox(height: screenWidth * 0.015),
                          _buildDropdown(
                            value: _selectedPriceType,
                            items: _priceTypes,
                            onChanged: (val) => setState(() => _selectedPriceType = val!),
                            screenWidth: screenWidth,
                            valueFontSize: valueFontSize,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                SizedBox(height: sectionSpacing),
                Row(
                  children: [
                    
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildLabel('Reference', labelFontSize),
                          SizedBox(height: screenWidth * 0.015),
                          _buildTextField(
                            hintText: 'Enter Reference',
                            screenWidth: screenWidth,
                            valueFontSize: valueFontSize,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    
    
    );
  }

 
 
  // ─── Customer Details Section ─────────────────────────────────────────────

  Widget _buildCustomerDetailsSection({
    required double screenWidth,
    required double horizontalPadding,
    required double cardPadding,
    required double labelFontSize,
    required double valueFontSize,
    required double headerFontSize,
    required double iconSize,
    required double sectionSpacing,
    required double vp,
    required double sp,
  }) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.person,
                    color: const Color(0xFF0045BC),
                    size: iconSize,
                  ),
                  SizedBox(width: screenWidth * 0.02),
                  Text(
                    'Customer Details',
                    style: TextStyle(
                      fontSize: headerFontSize,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF1A1A2E),
                    ),
                  ),
                ],
              ),
             
            ],
          ),

          SizedBox(height: sectionSpacing * 0.8),

          if (_selectedCustomer == null)
            Container(
              height: screenWidth * 0.12,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(screenWidth * 0.025),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: Row(
                children: [
                  SizedBox(width: screenWidth * 0.03),
                  Icon(
                    Icons.search,
                    color: Colors.grey.shade400,
                    size: iconSize * 0.9,
                  ),
                  SizedBox(width: screenWidth * 0.025),
                  Expanded(
                    child: TextField(
                      controller: _customerSearchController,
                      onChanged: _filterCustomers,
                      style: TextStyle(fontSize: valueFontSize * 0.9),
                      decoration: InputDecoration(
                        hintText: 'Select customer name or ID...',
                        hintStyle: TextStyle(
                          color: Colors.grey.shade400,
                          fontSize: valueFontSize * 0.9,
                        ),
                        border: InputBorder.none,
                        isDense: true,
                      ),
                    ),
                  ),
                ],
              ),
            ),

          if (_customerSearchController.text.isNotEmpty && _filteredCustomers.isNotEmpty)
            Container(
              constraints: BoxConstraints(maxHeight: 200 * vp),
              margin: EdgeInsets.only(top: 4 * vp),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4)],
              ),
              child: ListView.builder(
                shrinkWrap: true,
                padding: EdgeInsets.zero,
                itemCount: _filteredCustomers.length,
                itemBuilder: (context, index) {
                  final c = _filteredCustomers[index];
                  return ListTile(
                    title: Text(c['Ledger_Name'] ?? 'No Name',
                        style: TextStyle(fontSize: 13 * sp, fontFamily: 'Poppins')),
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

          SizedBox(height: sectionSpacing * 0.8),

          // ✅ Customer tile + expandable details
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(screenWidth * 0.025),
              border: Border(
                left: BorderSide(
                  color: const Color(0xFF0045BC),
                  width: screenWidth * 0.012,
                ),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 4,
                  offset: const Offset(0, 1),
                ),
              ],
            ),
            child: Column(
              children: [
                // Customer name row with eye toggle
               ListTile(
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: cardPadding,
                    vertical: screenWidth * 0.01,
                  ),
                  leading: CircleAvatar(
                    backgroundColor: const Color(0xFFEEF0FB),
                    radius: screenWidth * 0.055,
                    child: Icon(
                      Icons.person,
                      color: const Color(0xFF0045BC),
                      size: iconSize,
                    ),
                  ),
                  title: Text(
                    _selectedCustomer != null
                        ? '${_selectedCustomer!['Ledger_Name']} - ${_selectedCustomer!['id']}'
                        : 'Select a Customer',
                    style: TextStyle(
                      fontSize: valueFontSize,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF1A1A2E),
                    ),
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (_selectedCustomer != null)
                        IconButton(
                          icon: const Icon(Icons.close,
                              color: Colors.red, size: 20),
                          onPressed: () {
                            setState(() {
                              _selectedCustomer = null;
                              _customerSearchController.clear();
                            });
                          },
                        ),
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            _isCustomerDetailsVisible =
                                !_isCustomerDetailsVisible;
                          });
                        },
                        child: Icon(
                          _isCustomerDetailsVisible
                              ? Icons.visibility_outlined
                              : Icons.visibility_off_outlined,
                          color: _isCustomerDetailsVisible
                              ? const Color(0xFF0045BC)
                              : Colors.grey.shade400,
                          size: iconSize,
                        ),
                      ),
                    ],
                  ),
                ),

         

                // ✅ Animated expandable customer details
                AnimatedCrossFade(
                  duration: const Duration(milliseconds: 300),
                  crossFadeState: _isCustomerDetailsVisible
                      ? CrossFadeState.showSecond
                      : CrossFadeState.showFirst,
                  firstChild: const SizedBox.shrink(),
                  secondChild: Padding(
                    padding: EdgeInsets.only(
                      left: cardPadding,
                      right: cardPadding,
                      bottom: cardPadding,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(height: sectionSpacing * 0.8),

                        // Contact Person & GST Number
                        Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _buildLabel('Contact Person', labelFontSize),
                                  SizedBox(height: screenWidth * 0.015),
                                  _buildReadOnlyField(
                                    text: _selectedCustomer?['Ledger_Name'] ?? '',
                                    screenWidth: screenWidth,
                                    valueFontSize: valueFontSize,
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(width: screenWidth * 0.03),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _buildLabel('GST Number', labelFontSize),
                                  SizedBox(height: screenWidth * 0.015),
                                  _buildReadOnlyField(
                                    text: _selectedCustomer?['gst']?.toString() ?? '',
                                    screenWidth: screenWidth,
                                    valueFontSize: valueFontSize,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),

                        SizedBox(height: sectionSpacing * 0.8),

                        // Phone Number
                        _buildLabel('Phone Number', labelFontSize),
                        SizedBox(height: screenWidth * 0.015),
                        _buildReadOnlyField(
                          text: _selectedCustomer?['Mobile']?.toString() ?? '',
                          screenWidth: screenWidth,
                          valueFontSize: valueFontSize,
                        ),

                        SizedBox(height: sectionSpacing * 0.8),

                        // Billing Address
                        _buildLabel('Billing Address', labelFontSize),
                        SizedBox(height: screenWidth * 0.015),
                        _buildReadOnlyField(
                          text: _selectedCustomer?['address'] ?? '',
                          screenWidth: screenWidth,
                          valueFontSize: valueFontSize,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ─── Add Products Section ─────────────────────────────────────────────────

  Widget _buildAddProductsSection({
    required double screenWidth,
    required double horizontalPadding,
    required double cardPadding,
    required double valueFontSize,
    required double iconSize,
  }) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: horizontalPadding),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(screenWidth * 0.025),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: EdgeInsets.symmetric(
          horizontal: cardPadding,
          vertical: screenWidth * 0.01,
        ),
        leading: Container(
          width: screenWidth * 0.1,
          height: screenWidth * 0.1,
          decoration: BoxDecoration(
            color: const Color(0xFF0045BC).withOpacity(0.1),
            borderRadius: BorderRadius.circular(screenWidth * 0.02),
          ),
          child: Icon(
            Icons.inventory_2,
            color: const Color(0xFF0045BC),
            size: iconSize,
          ),
        ),
        title: Text(
          'Add Products',
          style: TextStyle(
            fontSize: valueFontSize,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF1A1A2E),
          ),
        ),
        trailing: Icon(
          Icons.chevron_right,
          color: Colors.grey.shade500,
          size: iconSize * 1.2,
        ),
        onTap: () {
          if (_selectedCustomer == null) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Please select a customer first'),
                backgroundColor: Colors.red,
              ),
            );
            return;
          }
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (_) => SalesOrderCatalogScreen(
                      selectedCustomer: _selectedCustomer,
                    )),
          );
        },
      ),
    );
  }

  // ─── Advanced Options Section ─────────────────────────────────────────────

  Widget _buildAdvancedOptionsSection({
    required double screenWidth,
    required double horizontalPadding,
    required double cardPadding,
    required double labelFontSize,
    required double valueFontSize,
    required double iconSize,
  }) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: horizontalPadding),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(screenWidth * 0.025),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        children: [
          // ✅ Advanced Options header row
          ListTile(
            contentPadding: EdgeInsets.symmetric(
              horizontal: cardPadding,
              vertical: screenWidth * 0.005,
            ),
            leading: Icon(
              Icons.tune,
              color: Colors.grey.shade600,
              size: iconSize,
            ),
            title: Text(
              'ADVANCED OPTIONS',
              style: TextStyle(
                fontSize: labelFontSize,
                fontWeight: FontWeight.w700,
                color: Colors.grey.shade600,
                letterSpacing: 0.8,
              ),
            ),
            trailing: Icon(
              _advancedOptionsExpanded
                  ? Icons.keyboard_arrow_up
                  : Icons.keyboard_arrow_down,
              color: Colors.grey.shade500,
              size: iconSize * 1.1,
            ),
            onTap: () => setState(
              () => _advancedOptionsExpanded = !_advancedOptionsExpanded,
            ),
          ),

          // ✅ Animated expandable advanced option items
          AnimatedCrossFade(
            duration: const Duration(milliseconds: 300),
            crossFadeState: _advancedOptionsExpanded
                ? CrossFadeState.showSecond
                : CrossFadeState.showFirst,
            firstChild: const SizedBox.shrink(),
            secondChild: Column(
              children: [
                ..._advancedOptions.asMap().entries.map((entry) {
                  final int index = entry.key;
                  final Map<String, dynamic> option = entry.value;
                  final bool isLast = index == _advancedOptions.length - 1;

                  return Column(
                    children: [
                      ListTile(
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: cardPadding,
                          vertical: screenWidth * 0.001,
                        ),
                        leading: Icon(
                          option['icon'] as IconData,
                          color: Colors.grey.shade600,
                          size: iconSize,
                        ),
                        title: Text(
                          option['label'] as String,
                          style: TextStyle(
                            fontSize: valueFontSize,
                            fontWeight: FontWeight.w500,
                            color: const Color(0xFF1A1A2E),
                          ),
                        ),
                        onTap: () {},
                      ),
                    ],
                  );
                }),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ─── Shared Helpers ───────────────────────────────────────────────────────

  Widget _buildLabel(String text, double fontSize) {
    return Text(
      text,
      style: TextStyle(
        fontSize: fontSize,
        color: Colors.grey.shade600,
        fontWeight: FontWeight.w500,
      ),
    );
  }

  Widget _buildDropdown({
    required String? value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
    required double screenWidth,
    required double valueFontSize,
  }) {
    // Safety check: ensure value is in items, else use first item or null
    String? effectiveValue = value;
    if (items.isNotEmpty) {
      if (effectiveValue == null || !items.contains(effectiveValue)) {
        effectiveValue = items.first;
      }
    } else {
      effectiveValue = null;
    }

    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        horizontal: screenWidth * 0.035,
        vertical: screenWidth * 0.01,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFFF2F4F6),
        borderRadius: BorderRadius.circular(screenWidth * 0.02),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: effectiveValue,
          isExpanded: true,
          dropdownColor: const Color(0xFFF2F4F6),
          icon: Icon(
            Icons.keyboard_arrow_down,
            color: Colors.grey.shade600,
            size: screenWidth * 0.06,
          ),
          style: TextStyle(
            fontSize: valueFontSize,
            color: const Color(0xFF1A1A2E),
            fontWeight: FontWeight.w500,
          ),
          items: items.map((e) {
            return DropdownMenuItem<String>(
              value: e,
              child: Text(e),
            );
          }).toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }

  Widget _buildReadOnlyField({
    required String text,
    required double screenWidth,
    required double valueFontSize,
  }) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        horizontal: screenWidth * 0.035,
        vertical: screenWidth * 0.032,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFFF2F4F6),
        borderRadius: BorderRadius.circular(screenWidth * 0.02),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: valueFontSize,
          color: const Color(0xFF1A1A2E),
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildTextField({
    required String hintText,
    required double screenWidth,
    required double valueFontSize,
    TextEditingController? controller,
  }) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(screenWidth * 0.02),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: TextField(
        controller: controller,
        style: TextStyle(
          fontSize: valueFontSize,
          color: const Color(0xFF1A1A2E),
          fontWeight: FontWeight.w500,
        ),
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: TextStyle(
            fontSize: valueFontSize,
            color: Colors.grey.shade400,
          ),
          contentPadding: EdgeInsets.symmetric(
            horizontal: screenWidth * 0.035,
            vertical: screenWidth * 0.032,
          ),
          border: InputBorder.none,
          isDense: true,
        ),
      ),
    );
  }
}