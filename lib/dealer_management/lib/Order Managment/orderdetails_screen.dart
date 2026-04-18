import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class OrderDetailsScreen extends StatefulWidget {
  const OrderDetailsScreen({super.key});

  @override
  State<OrderDetailsScreen> createState() => _OrderDetailsScreenState();
}

enum OrderDetailsView { viewList, addNew, filterList }

class _OrderDetailsScreenState extends State<OrderDetailsScreen> {
  late List<Map<String, String>> _orders;
  OrderDetailsView _currentView = OrderDetailsView.viewList;

  @override
  void initState() {
    super.initState();
    _orders = [
      {
        'ID': '1',
        'Customer ID': 'GBD99763JS',
        'Order ID': 'ORD-8822',
        'Product ID': 'PRD-900',
        'Order Status': 'Upcoming',
        'Order Date': '24/09/2024',
        'Tracking Number': 'TRK-99021',
        'Payment Method': 'Register',
        'Shipping Address': 'Infinity Event Center',
        'Price': '\$65',
        'Quantity': '1',
        'color': '0xFF7A8CFF' // Blue-ish
      },
      {
        'ID': '2',
        'Customer ID': 'GBD997275JP',
        'Order ID': 'ORD-9911',
        'Product ID': 'PRD-821',
        'Order Status': 'Past',
        'Order Date': '29/08/2024',
        'Tracking Number': 'TRK-88122',
        'Payment Method': 'View Detail',
        'Shipping Address': 'Inspire Impact Organizers',
        'Price': '\$75',
        'Quantity': '2',
        'color': '0xFFF1F54B' // Yellow
      },
      {
        'ID': '3',
        'Customer ID': 'GBD99711MK',
        'Order ID': 'ORD-1022',
        'Product ID': 'PRD-772',
        'Order Status': 'Past',
        'Order Date': '10/08/2024',
        'Tracking Number': 'TRK-77122',
        'Payment Method': 'View Detail',
        'Shipping Address': 'Trendsetters Collective',
        'Price': '\$95',
        'Quantity': '1',
        'color': '0xFFFF9CEE' // Pink
      },
      {
        'ID': '4',
        'Customer ID': 'GBD99812MK',
        'Order ID': 'ORD-2022',
        'Product ID': 'PRD-442',
        'Order Status': 'Past',
        'Order Date': '10/04/2024',
        'Tracking Number': 'TRK-55122',
        'Payment Method': 'View Detail',
        'Shipping Address': 'Art Art Organizer',
        'Price': '\$85',
        'Quantity': '3',
        'color': '0xFF96F2D1' // Green
      },
    ];
  }

  // Form Controllers
  final Map<String, TextEditingController> _controllers = {
    'Customer ID': TextEditingController(),
    'Order ID': TextEditingController(),
    'Product ID': TextEditingController(),
    'Order Status': TextEditingController(),
    'Order Date': TextEditingController(text: '08-04-2026'),
    'Payment Status': TextEditingController(),
    'Payment Method': TextEditingController(),
    'Shipping Address': TextEditingController(),
    'Billing Address': TextEditingController(),
    'Shipping Method': TextEditingController(),
    'Tracking Number': TextEditingController(),
    'Coupon Code': TextEditingController(),
    'PID Count': TextEditingController(),
    'Discount amount': TextEditingController(),
    'Shipping Cost': TextEditingController(),
    'Tax Amount': TextEditingController(),
    'Price': TextEditingController(),
    'Quantity': TextEditingController(),
    'Cancellation Date': TextEditingController(text: '08-04-2026'),
    'Cancellation Reason': TextEditingController(),
    'Cancelled By': TextEditingController(),
    'Refund Status': TextEditingController(),
    'Date': TextEditingController(text: '08-04-2026'),
    'Total Price': TextEditingController(),
    'Account Number': TextEditingController(),
    'Bank Name': TextEditingController(),
    'Holder Name': TextEditingController(),
    'IFSC': TextEditingController(),
  };

  void _saveOrder() {
    setState(() {
      Map<String, String> newOrder = {};
      List<String> activeFields = [
        'Customer ID', 'Order ID', 'Product ID', 'Order Status', 'Order Date', 
        'Tracking Number', 'Payment Method', 'Shipping Address', 'Price', 'Quantity'
      ];
      
      for (var field in activeFields) {
        newOrder[field] = _controllers[field]!.text;
      }
      
      newOrder['ID'] = (_orders.length + 1).toString();
      newOrder['color'] = '0xFF7A8CFF'; // Default color for new items
      _orders.insert(0, newOrder);
      _currentView = OrderDetailsView.viewList;
      
      // Clear controllers
      for (var field in activeFields) {
        if (!field.contains('Date')) _controllers[field]!.clear();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: const Color(0xFF26A69A),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Order Details',
          style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
        ),
        centerTitle: true,
      ),
      floatingActionButton: _currentView == OrderDetailsView.viewList 
        ? FloatingActionButton.extended(
            onPressed: () => setState(() => _currentView = OrderDetailsView.addNew),
            backgroundColor: const Color(0xFF26A69A),
            icon: const Icon(Icons.add_shopping_cart_rounded, color: Colors.white),
            label: Text('Add New Product', style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.bold)),
          )
        : null,
      body: SafeArea(
        child: Column(
          children: [
            _buildActionHeader(),
            Expanded(
              child: _buildMainContent(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMainContent() {
    switch (_currentView) {
      case OrderDetailsView.addNew:
        return _buildAddOrderForm();
      case OrderDetailsView.filterList:
        return _buildFilterForm();
      case OrderDetailsView.viewList:
        return _buildOrderList();
    }
  }

  Widget _buildActionHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 2)),
        ],
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            _buildHeaderButton('Orders Active', Colors.grey[100]!, Colors.grey[700]!),
            const SizedBox(width: 8),
            _buildHeaderButton(
              'View List', 
              _currentView == OrderDetailsView.viewList ? const Color(0xFF26A69A).withValues(alpha: 0.1) : Colors.white, 
              _currentView == OrderDetailsView.viewList ? const Color(0xFF26A69A) : Colors.grey, 
              icon: Icons.grid_view_rounded,
              onTap: () => setState(() => _currentView = OrderDetailsView.viewList),
            ),
            const SizedBox(width: 8),
            _buildHeaderButton(
              'Filter', 
              _currentView == OrderDetailsView.filterList ? const Color(0xFF26A69A).withValues(alpha: 0.1) : Colors.white, 
              _currentView == OrderDetailsView.filterList ? const Color(0xFF26A69A) : Colors.grey, 
              icon: Icons.tune_rounded, // Professional filter icon
              onTap: () => setState(() => _currentView = OrderDetailsView.filterList),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderButton(String label, Color bg, Color text, {IconData? icon, VoidCallback? onTap}) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: bg,
          border: Border.all(color: Colors.grey[300]!),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(label, style: GoogleFonts.outfit(fontSize: 12, color: text, fontWeight: FontWeight.w600)),
            if (icon != null) ...[
              const SizedBox(width: 4),
              Icon(icon, size: 14, color: text),
            ]
          ],
        ),
      ),
    );
  }

  Widget _buildOrderList() {
    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: _orders.length,
      itemBuilder: (context, index) {
        final order = _orders[index];
        return _buildEventStyleCard(order);
      },
    );
  }

  Widget _buildEventStyleCard(Map<String, String> order) {
    Color cardColor = Color(int.parse(order['color'] ?? '0xFF7A8CFF'));
    
    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: cardColor.withValues(alpha: 0.2),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Colorful Header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            decoration: BoxDecoration(
              color: cardColor,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(24),
                topRight: Radius.circular(24),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  order['Customer ID'] ?? 'N/A',
                  style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 16),
                ),
                Text(
                  order['Order Date'] ?? 'N/A',
                  style: GoogleFonts.outfit(color: Colors.white, fontSize: 14),
                ),
              ],
            ),
          ),
          // Body List
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Order ID: ${order['Order ID']}',
                  style: GoogleFonts.outfit(color: Colors.grey[400], fontSize: 13),
                ),
                const SizedBox(height: 4),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        'Product ID: ${order['Product ID']}',
                        style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold, color: const Color(0xFF1E234E)),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: cardColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        order['Order Status'] ?? 'Status',
                        style: GoogleFonts.outfit(color: cardColor, fontWeight: FontWeight.bold, fontSize: 12),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                _buildCardInfoRow(Icons.local_shipping_outlined, 'Tracking:', order['Tracking Number'] ?? '-'),
                _buildCardInfoRow(Icons.payments_outlined, 'Method:', order['Payment Method'] ?? '-'),
                _buildCardInfoRow(Icons.location_on_outlined, 'Address:', order['Shipping Address'] ?? '-'),
                _buildCardInfoRow(Icons.shopping_bag_outlined, 'Qty:', order['Quantity'] ?? '1'),
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 12),
                  child: Divider(height: 1),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      order['Price'] ?? '\$0',
                      style: GoogleFonts.outfit(fontSize: 24, fontWeight: FontWeight.bold, color: const Color(0xFF1E234E)),
                    ),
                    Row(
                      children: [
                        _buildCardActionBtn('Edit', Colors.black, () {}),
                        const SizedBox(width: 8),
                        _buildCardActionBtn('View Detail', Colors.black, () {}),
                      ],
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

  Widget _buildCardInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          Icon(icon, size: 16, color: Colors.grey[400]),
          const SizedBox(width: 8),
          Text('$label ', style: GoogleFonts.outfit(color: Colors.grey[400], fontSize: 12)),
          Expanded(
            child: Text(value, style: GoogleFonts.outfit(color: const Color(0xFF1E234E), fontWeight: FontWeight.w600, fontSize: 12)),
          ),
        ],
      ),
    );
  }

  Widget _buildCardActionBtn(String label, Color color, VoidCallback onTap) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF1E234E),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(label, style: GoogleFonts.outfit(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
    );
  }

  Widget _buildFilterForm() {
    return Container(
      padding: const EdgeInsets.all(24),
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(child: _buildFilterField('Order Date')),
              const SizedBox(width: 20),
              Expanded(child: _buildFilterField('Date')),
            ],
          ),
          const SizedBox(height: 16),
          _buildFilterField('Cancellation Date'),
          const SizedBox(height: 24),
          Align(
            alignment: Alignment.centerRight,
            child: ElevatedButton(
              onPressed: () => setState(() => _currentView = OrderDetailsView.viewList),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue[700],
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
              ),
              child: Text('Filter List', style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterField(String label) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: GoogleFonts.outfit(fontSize: 12, color: Colors.grey[700])),
        const SizedBox(height: 8),
        SizedBox(
          height: 40,
          child: TextField(
            controller: _controllers[label],
            decoration: InputDecoration(
              contentPadding: const EdgeInsets.symmetric(horizontal: 12),
              border: OutlineInputBorder(borderSide: BorderSide(color: Colors.grey[200]!)),
              enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.grey[200]!)),
              hintText: '08-04-2026',
              hintStyle: GoogleFonts.outfit(fontSize: 12, color: Colors.grey[400]),
            ),
            style: GoogleFonts.outfit(fontSize: 12),
          ),
        ),
      ],
    );
  }

  Widget _buildAddOrderForm() {
    List<String> activeFields = [
      'Customer ID', 'Order ID', 'Product ID', 'Order Status', 'Order Date', 
      'Tracking Number', 'Payment Method', 'Shipping Address', 'Price', 'Quantity'
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
                  Text(
                    'Add New Product',
                    style: GoogleFonts.outfit(fontSize: 24, fontWeight: FontWeight.bold, color: const Color(0xFF1E234E)),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Please enter your details',
                    style: GoogleFonts.outfit(fontSize: 14, color: Colors.grey[500]),
                  ),
                  const SizedBox(height: 32),
                  ...activeFields.map((field) => _buildMedlioTextField(field)),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
          Container(
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
                    onPressed: () => setState(() => _currentView = OrderDetailsView.viewList),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      side: BorderSide(color: Colors.grey[300]!),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: Text('Cancel', style: GoogleFonts.outfit(color: Colors.grey[600], fontWeight: FontWeight.w600)),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _saveOrder,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF26A69A),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: Text('Save Order', style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMedlioTextField(String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          RichText(
            text: TextSpan(
              children: [
                TextSpan(
                  text: label,
                  style: GoogleFonts.outfit(fontSize: 13, color: const Color(0xFF1E234E), fontWeight: FontWeight.w600),
                ),
                TextSpan(
                  text: ' *',
                  style: GoogleFonts.outfit(fontSize: 13, color: Colors.redAccent, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _controllers[label],
            decoration: InputDecoration(
              hintText: 'Enter $label',
              hintStyle: GoogleFonts.outfit(fontSize: 14, color: Colors.grey[400]),
              filled: true,
              fillColor: const Color(0xFFF8FAFC),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey[200]!),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey[200]!),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Color(0xFF26A69A), width: 1.5),
              ),
            ),
            style: GoogleFonts.outfit(fontSize: 14, color: const Color(0xFF1E234E)),
          ),
        ],
      ),
    );
  }
}
