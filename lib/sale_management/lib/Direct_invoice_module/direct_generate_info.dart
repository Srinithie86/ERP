import 'package:flutter/material.dart';
import 'all_products_screen.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sale_management/core/api_config.dart';

class DirectInvoiceGenerateInfoScreen extends StatefulWidget {
  const DirectInvoiceGenerateInfoScreen({super.key});

  @override
  State<DirectInvoiceGenerateInfoScreen> createState() =>
      _DirectInvoiceGenerateInfoScreenState();
}

class _DirectInvoiceGenerateInfoScreenState
    extends State<DirectInvoiceGenerateInfoScreen> {
  String _selectedInvoiceType = 'Retail';
  String _selectedTaxType = 'IGST';
  String _selectedPriceType = 'Exclude tax';
  DateTime _selectedDate = DateTime.now();

  final TextEditingController _invoiceNoController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchCustomers();
    _fetchInvoiceNumber();
    _fetchAllDropdowns();
  }

  @override
  void dispose() {
    _customerSearchController.dispose();
    _invoiceNoController.dispose();
    super.dispose();
  }

  Future<void> _fetchInvoiceNumber() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cid = prefs.getString('cid') ?? '44555666';
      final lt = prefs.getString('lt') ?? '123';
      final ln = prefs.getString('ln') ?? '123';
      final deviceId = prefs.getString('device_id') ?? '123';

      final response = await http.post(
        Uri.parse(await ApiConfig.getBaseUrl()),
        body: {
          'type': '8007',
          'cid': cid,
          'ln': ln,
          'lt': lt,
          'device_id': deviceId,
        },
      );

      final res = json.decode(response.body);
      if (res['status'] == true && res['invoice_no'] != null) {
        if (!mounted) return;
        setState(() {
          _invoiceNoController.text = res['invoice_no'].toString();
        });
      }
    } catch (e) {
      debugPrint("Error fetching invoice number: $e");
    }
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

  // ✅ Advanced Options toggle
  bool _advancedOptionsExpanded = false;
  // ✅ Eye toggle for customer details
  bool _isCustomerDetailsVisible = false;

  // ✅ Customer selection state
  List<dynamic> _allCustomers = [];
  List<dynamic> _filteredCustomers = [];
  Map<String, dynamic>? _selectedCustomer;
  final TextEditingController _customerSearchController =
      TextEditingController();
  bool _isFetchingCustomers = false;

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
              padding: EdgeInsets.fromLTRB(
                0,
                0,
                0,
                bottomPadding + screenHeight * 0.02,
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
      padding: EdgeInsets.fromLTRB(
        screenWidth * 0.03,
        topPadding + screenWidth * 0.02,
        screenWidth * 0.04,
        screenWidth * 0.035,
      ),
      child: Row(
        children: [
          IconButton(
            icon: Icon(Icons.arrow_back, color: Colors.white, size: iconSize),
            onPressed: () => Navigator.pop(context),
          ),
          SizedBox(width: screenWidth * 0.03),
          Text(
            'Direct Invoice',
            style: TextStyle(
              color: Colors.white,
              fontSize: headerFontSize * 1.1,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.3,
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
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildLabel('Invoice Date', labelFontSize),
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
                          _buildLabel('Invoice Type', labelFontSize),
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
       Row(
                  children: [
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
                    SizedBox(width: screenWidth * 0.03),
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
                  ],
                ),
             
             
                SizedBox(height: sectionSpacing),
                
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
          if (_selectedCustomer == null)
            Container(
              height: screenWidth * 0.12,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(screenWidth * 0.025),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: TextField(
                controller: _customerSearchController,
                onChanged: _filterCustomers,
                decoration: InputDecoration(
                  hintText: 'Select customer name or ID...',
                  hintStyle: TextStyle(
                    color: Colors.grey.shade400,
                    fontSize: valueFontSize * 0.9,
                  ),
                  prefixIcon: Icon(Icons.search,
                      color: Colors.grey.shade400, size: iconSize * 0.9),
                  border: InputBorder.none,
                  contentPadding:
                      EdgeInsets.symmetric(vertical: screenWidth * 0.025),
                ),
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
                boxShadow: const [
                  BoxShadow(color: Colors.black12, blurRadius: 4)
                ],
              ),
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: _filteredCustomers.length,
                itemBuilder: (context, index) {
                  final customer = _filteredCustomers[index];
                  return ListTile(
                    title: Text(customer['Ledger_Name'] ?? ''),
                    subtitle: Text("ID: ${customer['id']}"),
                    onTap: () {
                      setState(() {
                        _selectedCustomer = customer;
                        _customerSearchController.text =
                            customer['Ledger_Name'] ?? '';
                        _isCustomerDetailsVisible = false; // Keep it hidden until toggled
                      });
                    },
                  );
                },
              ),
            ),
          SizedBox(height: sectionSpacing * 0.8),
          if (_selectedCustomer != null)
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

         
                  AnimatedCrossFade(
                    duration: const Duration(milliseconds: 300),
                    crossFadeState: _isCustomerDetailsVisible
                        ? CrossFadeState.showSecond
                        : CrossFadeState.showFirst,
                    firstChild: const SizedBox.shrink(),
                    secondChild: Padding(
                      padding: EdgeInsets.fromLTRB(
                        cardPadding,
                        0,
                        cardPadding,
                        cardPadding,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildDetailRow(
                              'Phone', _selectedCustomer!['Phone'] ?? 'N/A', labelFontSize, valueFontSize, screenWidth),
                          _buildDetailRow(
                              'Email', _selectedCustomer!['Email'] ?? 'N/A', labelFontSize, valueFontSize, screenWidth),
                          _buildDetailRow('GSTIN', _selectedCustomer!['GSTIN'] ?? 'N/A',
                              labelFontSize, valueFontSize, screenWidth),
                          _buildDetailRow(
                              'Address', _selectedCustomer!['Address'] ?? 'N/A', labelFontSize, valueFontSize, screenWidth),
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

  Widget _buildDetailRow(String label, String value, double labelFontSize, double valueFontSize, double screenWidth) {
    return Padding(
      padding: EdgeInsets.only(top: screenWidth * 0.02),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildLabel(label, labelFontSize),
          SizedBox(height: screenWidth * 0.01),
          _buildReadOnlyField(text: value, screenWidth: screenWidth, valueFontSize: valueFontSize),
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
              const SnackBar(content: Text('Please select a customer first')),
            );
            return;
          }
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => DirectInvoiceCatalogScreen(
                taxType: _selectedTaxType,
                priceType: _selectedPriceType,
                selectedCustomer: _selectedCustomer,
                invoiceNo: _invoiceNoController.text,
                selectedDate: _selectedDate,
              ),
            ),
          );
        },
      ),
    );
  }

 
  // ─── Advanced Options Section ──────────────────────────────────────────────

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
          ListTile(
            onTap: () =>
                setState(() => _advancedOptionsExpanded = !_advancedOptionsExpanded),
            contentPadding: EdgeInsets.symmetric(horizontal: cardPadding),
            title: Text(
              'Advanced Options',
              style: TextStyle(
                fontSize: valueFontSize,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF1A1A2E),
              ),
            ),
            trailing: Icon(
              _advancedOptionsExpanded
                  ? Icons.keyboard_arrow_up
                  : Icons.keyboard_arrow_down,
              color: const Color(0xFF0045BC),
            ),
          ),
          if (_advancedOptionsExpanded)
            Padding(
              padding: EdgeInsets.fromLTRB(
                cardPadding,
                0,
                cardPadding,
                cardPadding,
              ),
              child: Column(
                children: _advancedOptions
                    .map((option) => ListTile(
                          contentPadding: EdgeInsets.zero,
                          leading: Icon(option['icon'],
                              color: const Color(0xFF0045BC),
                              size: iconSize * 0.9),
                          title: Text(
                            option['label'],
                            style: TextStyle(
                              fontSize: valueFontSize * 0.9,
                              color: const Color(0xFF1A1A2E),
                            ),
                          ),
                          trailing: Icon(Icons.add_circle_outline,
                              color: Colors.grey.shade400, size: iconSize * 0.8),
                          onTap: () {},
                        ))
                    .toList(),
              ),
            ),
        ],
      ),
    );
  }

  // ─── Helpers ──────────────────────────────────────────────────────────────

  Widget _buildLabel(String text, double fontSize) {
    return Text(
      text,
      style: TextStyle(
        fontSize: fontSize,
        fontWeight: FontWeight.w600,
        color: const Color(0xFF1A1A2E).withOpacity(0.7),
        fontFamily: 'Poppins',
      ),
    );
  }

  Widget _buildTextField({
    TextEditingController? controller,
    required String hintText,
    required double screenWidth,
    required double valueFontSize,
  }) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        horizontal: screenWidth * 0.035,
        vertical: screenWidth * 0.005,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFFF2F4F6),
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
            color: Colors.grey.shade400,
            fontSize: valueFontSize,
          ),
          border: InputBorder.none,
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

  Widget _buildDropdown({
    required String value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
    required double screenWidth,
    required double valueFontSize,
  }) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.035),
      decoration: BoxDecoration(
        color: const Color(0xFFF2F4F6),
        borderRadius: BorderRadius.circular(screenWidth * 0.02),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: items.contains(value) ? value : null,
          items: items
              .map((item) => DropdownMenuItem(
                    value: item,
                    child: Text(
                      item,
                      style: TextStyle(
                        fontSize: valueFontSize,
                        color: const Color(0xFF1A1A2E),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ))
              .toList(),
          onChanged: onChanged,
          icon: const Icon(Icons.keyboard_arrow_down, color: Color(0xFF0045BC)),
          isExpanded: true,
        ),
      ),
    );
  }
}