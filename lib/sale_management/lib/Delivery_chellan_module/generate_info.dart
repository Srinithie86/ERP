import 'package:flutter/material.dart';
import 'all_products_screen.dart';
import 'all_voice_screen.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sale_management/core/api_config.dart';

class DeliveryChallanGenerateInfoScreen extends StatefulWidget {
  const DeliveryChallanGenerateInfoScreen({super.key});

  @override
  State<DeliveryChallanGenerateInfoScreen> createState() =>
      _DeliveryChallanGenerateInfoScreenState();
}

class _DeliveryChallanGenerateInfoScreenState
    extends State<DeliveryChallanGenerateInfoScreen> {
  String _selectedInvoiceType = 'Retail';
  String _selectedTaxType = 'IGST';
  String _selectedPriceType = 'Exclude tax';
  DateTime _selectedDate = DateTime.now();

  List<dynamic> _customers = [];
  List<dynamic> _filteredCustomers = [];
  Map<String, dynamic>? _selectedCustomer;
  bool _isFetchingCustomers = false;
  final TextEditingController _customerSearchController =
      TextEditingController();
  final TextEditingController _dcNoController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchCustomers();
    _fetchDCNumber();
    _fetchAllDropdowns();
  }

  @override
  void dispose() {
    _customerSearchController.dispose();
    _dcNoController.dispose();
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
        Uri.parse(await ApiConfig.getBaseUrl()),
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
        if (!mounted) return;
        setState(() {
          _dcNoController.text = generatedNumber.toString();
        });
      }
    } catch (e) {
      debugPrint("Error fetching DC number: $e");
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

    final url = await ApiConfig.getBaseUrl();
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

    try {
      final response = await http.post(Uri.parse(url), body: body);
      final jsonResponse = json.decode(response.body);
      if (jsonResponse['error'] == false) {
        if (!mounted) return;
        setState(() {
          _customers = jsonResponse['data'] ?? [];
          _filteredCustomers = _customers;
        });
      }
    } catch (e) {
      debugPrint(
          "❌ DeliveryChallanGenerateInfoScreen => FETCH CUSTOMERS ERROR: $e");
    } finally {
      if (!mounted) return;
      setState(() => _isFetchingCustomers = false);
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

  void _fetchAllDropdowns() {
    _fetchDropdownData('17', _invoiceTypes, (val) => _selectedInvoiceType = val,
        _selectedInvoiceType);
    _fetchDropdownData('16', _priceTypes, (val) => _selectedPriceType = val,
        _selectedPriceType);
    _fetchDropdownData(
        '26', _taxTypes, (val) => _selectedTaxType = val, _selectedTaxType);
  }

  Future<void> _fetchDropdownData(String listId, List<String> targetList,
      Function(String) onSelectUpdate, String currentSelection) async {
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
          if (!mounted) return;
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

  DateTime _deliveryDate = DateTime.now().add(const Duration(days: 7));
  final String _selectedStatus = 'Pending';

  // ✅ Advanced Options toggle
  bool _advancedOptionsExpanded = false;
  // ✅ Eye toggle for customer details
  bool _isCustomerDetailsVisible = false;

  // ✅ Customer detail data
  // ✅ Automated from API
  String get _contactPerson => _selectedCustomer?['Ledger_Name'] ?? 'N/A';
  String get _gstNumber => _selectedCustomer?['gst'] ?? 'N/A';
  String get _phoneNumber => _selectedCustomer?['phone']?.toString() ?? 'N/A';
  String get _billingAddress =>
      _selectedCustomer?['address'] ?? 'No address provided';

  final List<String> _invoiceTypes = [
    'Retail',
    'Wholesale B-B',
    'Bill of Supply',
    'Branch Supply',
    'CS Retail',
  ];

  final List<String> _taxTypes = [
    'IGST',
    'CGST + SGST',
    'None',
  ];

  final List<String> _priceTypes = [
    'Exclude tax',
    'Include tax',
  ];

  final List<String> _statusTypes = [
    'Pending',
    'Confirmed',
    'Processing',
    'Invoiced',
    'Delivered',
  ];

  // ✅ Advanced Options items with icons
  final List<Map<String, dynamic>> _advancedOptions = [
    {'label': 'Select Dispatch Address', 'icon': Icons.local_shipping_outlined},
    {'label': 'Add Reference', 'icon': Icons.assignment_outlined},
    {'label': 'Add Extra Discount', 'icon': Icons.discount_outlined},
    {'label': 'Delivery / Shipping Charges', 'icon': Icons.wallet_outlined},
    {'label': 'Packing Charges', 'icon': Icons.inventory_2_outlined},
  ];

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
        _selectedDate = picked;
      });
    }
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

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context);
    final screenWidth = mq.size.width;
    final screenHeight = mq.size.height;
    final topPadding = mq.padding.top;
    final bottomPadding = mq.padding.bottom;

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
          IconButton(
            icon: Icon(Icons.arrow_back, color: Colors.white, size: iconSize),
            onPressed: () => Navigator.pop(context),
          ),
          SizedBox(width: screenWidth * 0.03),
          Expanded(
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const DeliveryChallanAllScreen(),
                  ),
                );
              },
              child: Text(
                'Delivery Challan',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: headerFontSize * 1.1,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.3,
                ),
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
                Icon(Icons.description,
                    color: const Color(0xFF0045BC), size: iconSize),
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
                // ── ROW 1: DC No & Customer Name ──────────────────
                Row(
                  children: [
                    Expanded(
                      child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildLabel('Dispatch Date', labelFontSize),
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
                          borderRadius:
                              BorderRadius.circular(screenWidth * 0.02),
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
                            Icon(Icons.calendar_today_outlined,
                                size: iconSize * 0.8,
                                color: const Color(0xFF0045BC)),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                    ),
                    SizedBox(width: screenWidth * 0.03),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildLabel('Type', labelFontSize),
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
                    ),
                  ],
                ),
                SizedBox(height: sectionSpacing),

                // ── ROW 3: Date & Order Date ──────────────────────
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildLabel('Date', labelFontSize),
                          SizedBox(height: screenWidth * 0.015),
                          GestureDetector(
                            onTap: () => _selectDate(context),
                            child: Container(
                              width: double.infinity,
                              padding: EdgeInsets.symmetric(
                                horizontal: screenWidth * 0.035,
                                vertical: screenWidth * 0.032,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF2F4F6),
                                borderRadius:
                                    BorderRadius.circular(screenWidth * 0.02),
                                border: Border.all(color: Colors.grey.shade300),
                              ),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    "${_selectedDate.month}/${_selectedDate.day}/${_selectedDate.year}",
                                    style: TextStyle(
                                      fontSize: valueFontSize,
                                      color: const Color(0xFF1A1A2E),
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  Icon(Icons.calendar_today_outlined,
                                      size: iconSize * 0.8,
                                      color: const Color(0xFF0045BC)),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(width: screenWidth * 0.03),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildLabel('Order Date', labelFontSize),
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
                                borderRadius:
                                    BorderRadius.circular(screenWidth * 0.02),
                                border: Border.all(color: Colors.grey.shade300),
                              ),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    "${_deliveryDate.month}/${_deliveryDate.day}/${_deliveryDate.year}",
                                    style: TextStyle(
                                      fontSize: valueFontSize,
                                      color: const Color(0xFF1A1A2E),
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  Icon(Icons.calendar_today_outlined,
                                      size: iconSize * 0.8,
                                      color: const Color(0xFF0045BC)),
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

                // ── ROW 4: Tax Type & Price Type ──────────────────
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
                            onChanged: (val) =>
                                setState(() => _selectedTaxType = val!),
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
                            onChanged: (val) =>
                                setState(() => _selectedPriceType = val!),
                            screenWidth: screenWidth,
                            valueFontSize: valueFontSize,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                SizedBox(height: sectionSpacing),

                // ── Dispatch Date ────────────────
                
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
                  Icon(Icons.person,
                      color: const Color(0xFF0045BC), size: iconSize),
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

          // Search field
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
                  Icon(Icons.search,
                      color: Colors.grey.shade400, size: iconSize * 0.9),
                  SizedBox(width: screenWidth * 0.025),
                  Expanded(
                    child: TextField(
                      controller: _customerSearchController,
                      onChanged: _filterCustomers,
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
                  if (_isFetchingCustomers)
                    SizedBox(
                      width: 16,
                      height: 16,
                      child: const CircularProgressIndicator(strokeWidth: 2),
                    ),
                ],
              ),
            ),
          if (_customerSearchController.text.isNotEmpty &&
              _selectedCustomer == null)
            Container(
              margin: const EdgeInsets.only(top: 4),
              constraints: const BoxConstraints(maxHeight: 200),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  const BoxShadow(color: Colors.black12, blurRadius: 4)
                ],
              ),
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: _filteredCustomers.length,
                itemBuilder: (context, index) {
                  final c = _filteredCustomers[index];
                  return ListTile(
                    title: Text(c['Ledger_Name'] ?? ''),
                    subtitle: Text('ID: ${c['id']}'),
                    onTap: () {
                      setState(() {
                        _selectedCustomer = c;
                        _customerSearchController.text = c['Ledger_Name'];
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
                              size: 20, color: Colors.red),
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
                                    text: _contactPerson,
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
                                    text: _gstNumber,
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
                          text: _phoneNumber,
                          screenWidth: screenWidth,
                          valueFontSize: valueFontSize,
                        ),

                        SizedBox(height: sectionSpacing * 0.8),

                        // Billing Address
                        _buildLabel('Billing Address', labelFontSize),
                        SizedBox(height: screenWidth * 0.015),
                        _buildReadOnlyField(
                          text: _billingAddress,
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
              builder: (_) => DeliveryChallanCatalogScreen(
                taxType: _selectedTaxType,
                priceType: _selectedPriceType,
                selectedCustomer: _selectedCustomer,
              ),
            ),
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
                () => _advancedOptionsExpanded = !_advancedOptionsExpanded),
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
                  final Map<String, dynamic> option = entry.value;

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
    int? maxLines,
    void Function(String)? onChanged,
  }) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFFF2F4F6),
        borderRadius: BorderRadius.circular(screenWidth * 0.02),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: TextField(
        controller: controller,
        onChanged: onChanged,
        maxLines: maxLines,
        style: TextStyle(
          fontSize: valueFontSize,
          color: const Color(0xFF1A1A2E),
          fontWeight: FontWeight.w500,
        ),
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: TextStyle(
            color: Colors.grey.shade400,
            fontSize: valueFontSize,
          ),
          contentPadding: EdgeInsets.symmetric(
            horizontal: screenWidth * 0.035,
            vertical: screenWidth * 0.025,
          ),
          border: InputBorder.none,
        ),
      ),
    );
  }
}