import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ConfirmOrdersScreen extends StatefulWidget {
  const ConfirmOrdersScreen({super.key});

  @override
  State<ConfirmOrdersScreen> createState() => _ConfirmOrdersScreenState();
}

class _ConfirmOrdersScreenState extends State<ConfirmOrdersScreen> {
  String selectedTab = 'Active';

  final List<Map<String, dynamic>> dummyOrders = [
    {
      'orderId': 'ORD-5501',
      'date': '08-04-2026',
      'item': 'Engine Oil GT',
      'qty': '12',
      'price': r'$1,240',
      'status': 'Confirmed',
      'tab': 'Active',
      'color': const Color(0xFFFF8A65), 
      'icon': Icons.shopping_bag_rounded,
    },
    {
      'orderId': 'ORD-5502',
      'date': '07-04-2026',
      'item': 'Brake Pads Pro',
      'qty': '08',
      'price': r'$2,840',
      'status': 'Pending',
      'tab': 'Pending',
      'color': const Color(0xFF7E57C2), 
      'icon': Icons.pending_actions_rounded,
    },
    {
      'orderId': 'ORD-5503',
      'date': '06-04-2026',
      'item': 'Air Filter X',
      'qty': '05',
      'price': r'$583',
      'status': 'Shipped',
      'tab': 'History',
      'color': const Color(0xFFFF7043), 
      'icon': Icons.local_shipping_rounded,
    },
    {
      'orderId': 'ORD-5504',
      'date': '05-04-2026',
      'item': 'Spark Plugs 4x',
      'qty': '24',
      'price': r'$16,741',
      'status': 'Delivered',
      'tab': 'History',
      'color': const Color(0xFF26C6DA), 
      'icon': Icons.check_circle_rounded,
    },
    {
      'orderId': 'ORD-5505',
      'date': '04-04-2026',
      'item': 'Chain Lube Elite',
      'qty': '03',
      'price': r'$5,300',
      'status': 'Confirmed',
      'tab': 'Active',
      'color': const Color(0xFF5C6BC0), 
      'icon': Icons.assignment_turned_in_rounded,
    },
    {
      'orderId': 'ORD-5506',
      'date': '03-04-2026',
      'item': 'Battery 12V High',
      'qty': '15',
      'price': r'$12,500',
      'status': 'Pending',
      'tab': 'Pending',
      'color': const Color(0xFF9CCC65), 
      'icon': Icons.hourglass_empty_rounded,
    },
    {
      'orderId': 'ORD-5507',
      'date': '02-04-2026',
      'item': 'Headlight LED',
      'qty': '02',
      'price': r'$3,200',
      'status': 'Confirmed',
      'tab': 'Active',
      'color': const Color(0xFFEF5350), 
      'icon': Icons.lightbulb_rounded,
    },
    {
      'orderId': 'ORD-5508',
      'date': '01-04-2026',
      'item': 'Tire Set Sport',
      'qty': '04',
      'price': r'$8,500',
      'status': 'Confirmed',
      'tab': 'Active',
      'color': const Color(0xFF26A69A), 
      'icon': Icons.tire_repair_rounded,
    },
    {
      'orderId': 'ORD-5509',
      'date': '31-03-2026',
      'item': 'Mirror Kit',
      'qty': '10',
      'price': r'$1,150',
      'status': 'Confirmed',
      'tab': 'Active',
      'color': const Color(0xFFAB47BC), 
      'icon': Icons.visibility_rounded,
    },
    {
      'orderId': 'ORD-5510',
      'date': '30-03-2026',
      'item': 'Seat Cover Pro',
      'qty': '01',
      'price': r'$450',
      'status': 'Confirmed',
      'tab': 'Active',
      'color': const Color(0xFFFFCA28), 
      'icon': Icons.chair_rounded,
    },
  ];

  @override
  Widget build(BuildContext context) {
    final filteredOrders = dummyOrders.where((o) => o['tab'] == selectedTab).toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF1F5F9),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Color(0xFF1E234E), size: 18),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'ORDER LIST',
          style: GoogleFonts.outfit(
            color: const Color(0xFF1E234E), 
            fontWeight: FontWeight.bold, 
            fontSize: 16,
            letterSpacing: 1.1
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Elegant Tabs Row
          Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(15),
              ),
              child: Row(
                children: [
                  _buildTabItem('Active'),
                  _buildTabItem('Pending'),
                  _buildTabItem('History'),
                ],
              ),
            ),
          ),
          
          Expanded(
            child: filteredOrders.isEmpty 
              ? Center(child: Text("No orders found", style: GoogleFonts.outfit(color: Colors.grey)))
              : GridView.builder(
                  padding: const EdgeInsets.all(16),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 14,
                    mainAxisSpacing: 14,
                    childAspectRatio: 1.1, // More compact card aspect ratio
                  ),
                  itemCount: filteredOrders.length,
                  itemBuilder: (context, index) {
                    return _buildOrderCard(filteredOrders[index]);
                  },
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabItem(String label) {
    final bool isActive = selectedTab == label;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => selectedTab = label),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isActive ? const Color(0xFF1E234E) : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Center(
            child: Text(
              label,
              style: GoogleFonts.outfit(
                color: isActive ? Colors.white : Colors.blueGrey[400],
                fontSize: 13,
                fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildOrderCard(Map<String, dynamic> order) {
    return InkWell(
      onTap: () => _showOrderPopup(order),
      borderRadius: BorderRadius.circular(20),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Stack(
            children: [
              // Top accent bar
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                height: 4,
                child: Container(color: order['color']),
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          order['orderId'],
                          style: GoogleFonts.outfit(
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                            color: Colors.blueGrey[800],
                          ),
                        ),
                        Icon(order['icon'], size: 14, color: order['color']),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      order['item'] ?? "General Item",
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.outfit(
                        fontWeight: FontWeight.w500,
                        fontSize: 13,
                        color: const Color(0xFF1E234E),
                      ),
                    ),
                    const Spacer(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Price',
                              style: GoogleFonts.outfit(fontSize: 10, color: Colors.blueGrey[300]),
                            ),
                            Text(
                              order['price'],
                              style: GoogleFonts.outfit(
                                fontWeight: FontWeight.w800,
                                fontSize: 16,
                                color: const Color(0xFF1E234E),
                              ),
                            ),
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: (order['color'] as Color).withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            'x${order['qty']}',
                            style: GoogleFonts.outfit(
                              fontWeight: FontWeight.bold,
                              fontSize: 10,
                              color: order['color'],
                            ),
                          ),
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
    );
  }

  void _showOrderPopup(Map<String, dynamic> order) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        backgroundColor: Colors.white,
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: (order['color'] as Color).withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(order['icon'], color: order['color'], size: 28),
              ),
              const SizedBox(height: 16),
              Text(
                'Confirm Order',
                style: GoogleFonts.outfit(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF1E234E),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Review details for ${order['orderId']}',
                style: GoogleFonts.outfit(color: Colors.blueGrey[400], fontSize: 13),
              ),
              const SizedBox(height: 24),
              _buildDetailRow('Item', order['item'] ?? "N/A"),
              _buildDetailRow('Quantity', order['qty']),
              _buildDetailRow('Total Amount', order['price']),
              _buildDetailRow('Date', order['date']),
              const SizedBox(height: 32),
              AnimatedConfirmButton(onConfirmed: () {
                // Potential delay before closing
                Future.delayed(const Duration(milliseconds: 1500), () {
                  if (Navigator.canPop(context)) Navigator.pop(context);
                });
              }),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: GoogleFonts.outfit(color: Colors.blueGrey[400], fontSize: 13)),
          Text(value, style: GoogleFonts.outfit(fontWeight: FontWeight.bold, color: const Color(0xFF1E234E))),
        ],
      ),
    );
  }
}

class AnimatedConfirmButton extends StatefulWidget {
  final VoidCallback onConfirmed;
  const AnimatedConfirmButton({super.key, required this.onConfirmed});

  @override
  State<AnimatedConfirmButton> createState() => _AnimatedConfirmButtonState();
}

class _AnimatedConfirmButtonState extends State<AnimatedConfirmButton> {
  bool isConfirmed = false;
  bool isAnimating = false;

  void _handlePress() {
    if (isAnimating || isConfirmed) { return; }

    setState(() {
      isAnimating = true;
    });

    // Simulate confirmation
    Future.delayed(const Duration(milliseconds: 600), () {
      setState(() {
        isConfirmed = true;
        isAnimating = false;
      });
      widget.onConfirmed();
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _handlePress,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOutBack,
        height: 54,
        width: double.infinity,
        decoration: BoxDecoration(
          color: isConfirmed ? const Color(0xFF4CAF50) : const Color(0xFF1E234E),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: (isConfirmed ? const Color(0xFF4CAF50) : const Color(0xFF1E234E)).withValues(alpha: 0.3),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Center(
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            child: isAnimating
              ? const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                )
              : isConfirmed
                  ? const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.check_circle_rounded, color: Colors.white, size: 22),
                        SizedBox(width: 8),
                        Text(
                          'CONFIRMED',
                          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, letterSpacing: 1),
                        ),
                      ],
                    )
                  : Text(
                      'CONFIRM ORDER',
                      style: GoogleFonts.outfit(
                        color: Colors.white, 
                        fontWeight: FontWeight.bold, 
                        fontSize: 14,
                        letterSpacing: 1.2
                      ),
                    ),
          ),
        ),
      ),
    );
  }
}

