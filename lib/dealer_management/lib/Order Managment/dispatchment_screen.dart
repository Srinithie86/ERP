import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dispatch_notification_detail.dart';

enum DispatchView { viewList, addNew, filterList }

class DispatchmentScreen extends StatefulWidget {
  const DispatchmentScreen({super.key});

  @override
  State<DispatchmentScreen> createState() => _DispatchmentScreenState();
}

class _DispatchmentScreenState extends State<DispatchmentScreen> {
  DispatchView _currentView = DispatchView.viewList;

  late List<Map<String, dynamic>> dispatchRecords;
  
  // Controllers for Add New (8 fields)
  final Map<String, TextEditingController> _addControllers = {
    'Dispatch no': TextEditingController(),
    'Order ID': TextEditingController(),
    'Customer ID': TextEditingController(),
    'Warehouse': TextEditingController(),
    'Dispatch Date': TextEditingController(text: '08-04-2026'),
    'Total Amount': TextEditingController(),
    'Product Name': TextEditingController(),
    'Order Date': TextEditingController(text: '08-04-2026'),
  };

  // Controllers for Filter (2 fields)
  final Map<String, TextEditingController> _filterControllers = {
    'Dispatch Date': TextEditingController(text: '08-04-2026'),
    'Order Date': TextEditingController(text: '08-04-2026'),
  };

  @override
  void initState() {
    super.initState();
    dispatchRecords = [
      {
        'dispatchNo': 'DSP-2026-001',
        'orderId': 'ORD-5501',
        'customerId': 'CUS-101',
        'warehouse': 'Main Hub - Secunderabad',
        'dispatchDate': '08-04-2026',
        'totalQuantity': '150',
        'totalAmount': r'$12,400',
        'status': 'In Transit',
        'createdTime': '10:30 AM',
        'productName': 'Premium Synthetic Engine Oil',
        'productId': 'PROD-778',
        'orderDate': '05-04-2026',
        'color': const Color(0xFF26A69A),
      },
      {
        'dispatchNo': 'DSP-2026-002',
        'orderId': 'ORD-5502',
        'customerId': 'CUS-205',
        'warehouse': 'North Zone Warehouse',
        'dispatchDate': '08-04-2026',
        'totalQuantity': '45',
        'totalAmount': r'$3,250',
        'status': 'Delivered',
        'createdTime': '09:15 AM',
        'productName': 'Heavy Duty Brake Pads',
        'productId': 'PROD-421',
        'orderDate': '04-04-2026',
        'color': const Color(0xFF4CAF50),
      },
      {
        'dispatchNo': 'DSP-2026-003',
        'orderId': 'ORD-5503',
        'customerId': 'CUS-089',
        'warehouse': 'West Side Storage',
        'dispatchDate': '07-04-2026',
        'totalQuantity': '20',
        'totalAmount': r'$850',
        'status': 'Pending',
        'createdTime': '04:45 PM',
        'productName': 'Air Filter Mesh X',
        'productId': 'PROD-102',
        'orderDate': '03-04-2026',
        'color': const Color(0xFFFF9800),
      },
    ];
  }

  @override
  void dispose() {
    for (var controller in _addControllers.values) {
      controller.dispose();
    }
    for (var controller in _filterControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  void _saveNewDispatch() {
    setState(() {
      final newEntry = {
        'dispatchNo': _addControllers['Dispatch no']!.text,
        'orderId': _addControllers['Order ID']!.text,
        'customerId': _addControllers['Customer ID']!.text,
        'warehouse': _addControllers['Warehouse']!.text,
        'dispatchDate': _addControllers['Dispatch Date']!.text,
        'totalQuantity': '0',
        'totalAmount': _addControllers['Total Amount']!.text,
        'status': 'Pending',
        'createdTime': 'Just Now',
        'productName': _addControllers['Product Name']!.text,
        'productId': 'N/A',
        'orderDate': _addControllers['Order Date']!.text,
        'color': const Color(0xFF26A69A),
      };
      
      if (newEntry['dispatchNo'].toString().isNotEmpty && 
          newEntry['productName'].toString().isNotEmpty) {
         dispatchRecords.insert(0, newEntry);
      }
      
      _currentView = DispatchView.viewList;
      
      // Clear non-date controllers
      for (var key in _addControllers.keys) {
        if (!key.contains('Date')) _addControllers[key]!.clear();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    const primaryColor = Color(0xFF26A69A);
    final size = MediaQuery.of(context).size;
    final isSmallScreen = size.width < 380;
    final horizontalPadding = size.width * 0.06;

    return Scaffold(
      backgroundColor: const Color(0xFFF1F5F9),
      body: Column(
        children: [
          // Header
          Container(
            width: double.infinity,
            padding: EdgeInsets.only(
              top: MediaQuery.of(context).padding.top + 20, 
              left: horizontalPadding, 
              right: horizontalPadding, 
              bottom: 40
            ),
            decoration: const BoxDecoration(
              color: primaryColor,
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(40),
                bottomRight: Radius.circular(40),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 20),
                      onPressed: () {
                        if (_currentView == DispatchView.viewList) {
                          Navigator.pop(context);
                        } else {
                          setState(() => _currentView = DispatchView.viewList);
                        }
                      },
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                    Text(
                      _currentView == DispatchView.addNew 
                          ? 'Add New Dispatch' 
                          : (_currentView == DispatchView.filterList ? 'Filter Records' : 'Dispatchment Portal'),
                      style: GoogleFonts.outfit(
                        color: Colors.white,
                        fontSize: isSmallScreen ? 16 : 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const DispatchNotificationDetail()),
                      ),
                      icon: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(Icons.notifications_none_rounded, color: Colors.white, size: 20),
                      ),
                    ),
                  ],
                ),
                if (_currentView == DispatchView.viewList) ...[
                  const SizedBox(height: 32),
                  Text(
                    'Manage Shipments',
                    style: GoogleFonts.outfit(
                      color: Colors.white,
                      fontSize: isSmallScreen ? 24 : 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Track and confirm order dispatches',
                    style: GoogleFonts.outfit(
                      color: Colors.white.withValues(alpha: 0.7),
                      fontSize: isSmallScreen ? 12 : 14,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(
                        child: _buildHeaderAction(
                          icon: Icons.add_circle_outline_rounded,
                          label: 'Add New',
                          onTap: () => setState(() => _currentView = DispatchView.addNew),
                          isSmallScreen: isSmallScreen,
                          primaryColor: primaryColor,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildHeaderAction(
                          icon: Icons.history_rounded,
                          label: 'View Logs',
                          onTap: () {},
                          isSmallScreen: isSmallScreen,
                          primaryColor: primaryColor,
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),

          // Main View Switcher
          Expanded(
            child: _buildMainContent(isSmallScreen, horizontalPadding, primaryColor),
          ),
        ],
      ),
    );
  }

  Widget _buildMainContent(bool isSmallScreen, double horizontalPadding, Color primaryColor) {
    switch (_currentView) {
      case DispatchView.addNew:
        return _buildAddDispatchForm(primaryColor);
      case DispatchView.filterList:
        return _buildFilterForm(primaryColor);
      case DispatchView.viewList:
        return Column(
          children: [
            // Filter Bar
            Padding(
              padding: EdgeInsets.symmetric(horizontal: horizontalPadding, vertical: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Sorted by',
                        style: GoogleFonts.outfit(color: Colors.blueGrey[300], fontSize: 12),
                      ),
                      Row(
                        children: [
                          Text(
                            'Recent Dispatch',
                            style: GoogleFonts.outfit(
                              color: primaryColor,
                              fontWeight: FontWeight.bold,
                              fontSize: isSmallScreen ? 13 : 15,
                            ),
                          ),
                          Icon(Icons.keyboard_arrow_down_rounded, color: primaryColor, size: 20),
                        ],
                      ),
                    ],
                  ),
                  InkWell(
                    onTap: () => setState(() => _currentView = DispatchView.filterList),
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: isSmallScreen ? 12 : 16, 
                        vertical: isSmallScreen ? 8 : 10
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.05),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Text(
                            'Filter',
                            style: GoogleFonts.outfit(
                              color: primaryColor,
                              fontWeight: FontWeight.w600,
                              fontSize: isSmallScreen ? 12 : 14,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Icon(Icons.tune_rounded, color: primaryColor, size: isSmallScreen ? 16 : 18),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView.builder(
                padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
                itemCount: dispatchRecords.length,
                itemBuilder: (context, index) {
                  return _buildDispatchCard(dispatchRecords[index], isSmallScreen);
                },
              ),
            ),
          ],
        );
    }
  }

  Widget _buildAddDispatchForm(Color primaryColor) {
    final List<String> fields = [
      'Dispatch no', 'Order ID', 'Customer ID', 'Warehouse', 
      'Dispatch Date', 'Total Amount', 'Product Name', 'Order Date'
    ];

    return Container(
      color: Colors.white,
      child: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ...fields.map((field) => _buildMedlioField(field, _addControllers[field]!, primaryColor)),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
          _buildFormActions('Save Dispatch', _saveNewDispatch, primaryColor),
        ],
      ),
    );
  }

  Widget _buildFilterForm(Color primaryColor) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildMedlioField('Dispatch Date', _filterControllers['Dispatch Date']!, primaryColor),
          const SizedBox(height: 16),
          _buildMedlioField('Order Date', _filterControllers['Order Date']!, primaryColor),
          const Spacer(),
          _buildFormActions('Apply Filter', () => setState(() => _currentView = DispatchView.viewList), primaryColor),
        ],
      ),
    );
  }

  Widget _buildMedlioField(String label, TextEditingController controller, Color primaryColor) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: GoogleFonts.outfit(fontSize: 13, color: const Color(0xFF1E234E), fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: controller,
            decoration: InputDecoration(
              hintText: 'Enter $label',
              hintStyle: GoogleFonts.outfit(fontSize: 14, color: Colors.blueGrey[200]),
              filled: true,
              fillColor: const Color(0xFFF8FAFC),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.blueGrey[50]!),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.blueGrey[50]!),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: primaryColor, width: 2),
              ),
            ),
            style: GoogleFonts.outfit(fontSize: 14),
          ),
        ],
      ),
    );
  }

  Widget _buildFormActions(String primaryLabel, VoidCallback onPrimary, Color primaryColor) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, -5)),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: () => setState(() => _currentView = DispatchView.viewList),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                side: BorderSide(color: Colors.blueGrey[100]!),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: Text('Cancel', style: GoogleFonts.outfit(color: Colors.blueGrey[400], fontWeight: FontWeight.w600)),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: ElevatedButton(
              onPressed: onPrimary,
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor,
                padding: const EdgeInsets.symmetric(vertical: 16),
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: Text(primaryLabel, style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderAction({
    required IconData icon, 
    required String label, 
    required VoidCallback onTap,
    required bool isSmallScreen,
    required Color primaryColor,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: primaryColor, size: isSmallScreen ? 18 : 20),
            const SizedBox(width: 8),
            Text(
              label,
              style: GoogleFonts.outfit(
                color: primaryColor,
                fontWeight: FontWeight.bold,
                fontSize: isSmallScreen ? 12 : 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDispatchCard(Map<String, dynamic> data, bool isSmallScreen) {
    const primaryColor = Color(0xFF1E234E);
    
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Column(
          children: [
            // Top Section (Product & Tag)
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              data['productName'],
                              style: GoogleFonts.outfit(
                                fontSize: isSmallScreen ? 14 : 16,
                                fontWeight: FontWeight.bold,
                                color: primaryColor,
                              ),
                            ),
                            Text(
                              'Product ID: ${data['productId']}',
                              style: GoogleFonts.outfit(color: Colors.blueGrey[300], fontSize: 10),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: (data['color'] as Color).withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: (data['color'] as Color).withValues(alpha: 0.3)),
                        ),
                        child: Text(
                          data['status'].toUpperCase(),
                          style: GoogleFonts.outfit(
                            color: data['color'],
                            fontSize: 9,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  
                  // Routing Style (Source -> Destination)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildRoutePoint('Warehouse', data['warehouse']),
                      Expanded(
                        child: Column(
                          children: [
                            Row(
                              children: List.generate(isSmallScreen ? 6 : 10, (index) => Expanded(
                                child: Container(
                                  height: 1,
                                  margin: const EdgeInsets.symmetric(horizontal: 2),
                                  color: Colors.blueGrey[100],
                                ),
                              )),
                            ),
                            Icon(Icons.local_shipping_rounded, color: primaryColor, size: 16),
                          ],
                        ),
                      ),
                      _buildRoutePoint('Customer ID', data['customerId'], alignRight: true),
                    ],
                  ),
                  
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildLabelValue('Order Date', data['orderDate']),
                      _buildLabelValue('Dispatch Date', data['dispatchDate'], alignRight: true),
                    ],
                  ),
                ],
              ),
            ),
            
            // Divider
            Container(
              height: 1,
              color: Colors.grey[100],
              margin: const EdgeInsets.symmetric(horizontal: 20),
            ),
            
            // Bottom Info Bar (Details)
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildMiniInfo(Icons.confirmation_number_outlined, 'DP No', data['dispatchNo']),
                      _buildMiniInfo(Icons.list_alt_rounded, 'Order ID', data['orderId']),
                      _buildMiniInfo(Icons.inventory_2_outlined, 'Qty', data['totalQuantity']),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildMiniInfo(Icons.access_time_rounded, 'Created', data['createdTime']),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                            Text(
                            'Total Amount',
                            style: GoogleFonts.outfit(color: Colors.blueGrey[400], fontSize: 10),
                          ),
                          Text(
                            data['totalAmount'],
                            style: GoogleFonts.outfit(
                              color: primaryColor,
                              fontSize: isSmallScreen ? 18 : 20,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
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
    );
  }

  Widget _buildRoutePoint(String label, String value, {bool alignRight = false}) {
    return Expanded(
      child: Column(
        crossAxisAlignment: alignRight ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          Text(label, style: GoogleFonts.outfit(color: Colors.blueGrey[300], fontSize: 9)),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.outfit(
              color: const Color(0xFF1E234E),
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLabelValue(String label, String value, {bool alignRight = false}) {
    return Column(
      crossAxisAlignment: alignRight ? CrossAxisAlignment.end : CrossAxisAlignment.start,
      children: [
        Text(label, style: GoogleFonts.outfit(color: Colors.blueGrey[300], fontSize: 9)),
        Text(value, style: GoogleFonts.outfit(color: const Color(0xFF1E234E), fontWeight: FontWeight.bold, fontSize: 12)),
      ],
    );
  }

  Widget _buildMiniInfo(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 12, color: Colors.blueGrey[400]),
        const SizedBox(width: 4),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: GoogleFonts.outfit(color: Colors.blueGrey[300], fontSize: 8)),
            Text(
              value,
              style: GoogleFonts.outfit(
                color: const Color(0xFF1E234E),
                fontWeight: FontWeight.w600,
                fontSize: 11,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

