import 'package:flutter/material.dart';
import 'deal_lost.dart';
import 'deal_won.dart';
import '../Follows/enquiry_details_screen.dart';

class DealsScreen extends StatefulWidget {
  final VoidCallback? onBack;
  const DealsScreen({super.key, this.onBack});

  @override
  State<DealsScreen> createState() => _DealsScreenState();
}

class _DealsScreenState extends State<DealsScreen> {
  @override
  Widget build(BuildContext context) {
    const Color primaryPurple = Color(0xFF26A69A);
    final Size size = MediaQuery.of(context).size;
    final double screenWidth = size.width;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: primaryPurple,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            if (widget.onBack != null) {
              widget.onBack!();
            } else if (Navigator.canPop(context)) {
              Navigator.pop(context);
            }
          },
        ),
        title: Text(
          'Deals',
          style: TextStyle(
            color: Colors.white,
            fontSize: screenWidth * 0.05,
            fontWeight: FontWeight.w500,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(
              Icons.calendar_month_outlined,
              color: Colors.white,
            ),
            onPressed: () async {
              await showDatePicker(
                context: context,
                initialDate: DateTime.now(),
                firstDate: DateTime(2000),
                lastDate: DateTime(2101),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                // Curved Purple Background
                Container(
                  height: 100,
                  width: double.infinity,
                  decoration: const BoxDecoration(
                    color: primaryPurple,
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(40),
                      bottomRight: Radius.circular(40),
                    ),
                  ),
                ),
                // Summary Cards Row
                Positioned(
                  top: 20,
                  left: 16,
                  right: 16,
                  child: Row(
                    children: [
                      _buildSummaryCard(
                        "Active",
                        "Deals",
                        "10",
                        const Color(0xFFFCF2D5),
                        const Color(0xFF2E79DA),
                        screenWidth,
                        onTap: () {},
                      ),
                      const SizedBox(width: 12),
                      _buildSummaryCard(
                        "Total Deal",
                        "Won",
                        "10",
                        Colors.white,
                        const Color(0xFF109B1E),
                        screenWidth,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const DealWonScreen(),
                            ),
                          );
                        },
                      ),
                      const SizedBox(width: 12),
                      _buildSummaryCard(
                        "Total Deal",
                        "Lost",
                        "10",
                        Colors.white,
                        const Color(0xFFC66A6A),
                        screenWidth,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const DealLostScreen(),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 100),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Text(
                'Active Deals list',
                style: TextStyle(
                  fontSize: screenWidth * 0.045,
                  fontWeight: FontWeight.w500,
                  color: Theme.of(context).textTheme.titleMedium?.color,
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Deals List
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                children: [
                  _buildDealCard(
                    name: 'Arun Kumar',
                    leadNo: 'L002',
                    phone: '7894561231',
                    date: '25/11/2025',
                    wonBy: 'Nandhini',
                    screenWidth: screenWidth,
                  ),
                  _buildDealCard(
                    name: 'Kumar',
                    leadNo: 'L002',
                    phone: '7894561231',
                    date: '21/11/2025',
                    wonBy: 'Kiran',
                    screenWidth: screenWidth,
                  ),
                  _buildDealCard(
                    name: 'Thanu Sri',
                    leadNo: 'L006',
                    phone: '7894561231',
                    date: '10/11/2025',
                    wonBy: 'Sowmiya',
                    screenWidth: screenWidth,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryCard(
    String line1,
    String line2,
    String count,
    Color bgColor,
    Color statusColor,
    double screenWidth, {
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          height: 120,
          decoration: BoxDecoration(
            color:
                Theme.of(context).brightness == Brightness.dark &&
                    bgColor == Colors.white
                ? Theme.of(context).cardColor
                : bgColor,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                line1,
                style: TextStyle(
                  fontSize: screenWidth * 0.035,
                  fontWeight: FontWeight.bold,
                  color:
                      bgColor == Colors.white &&
                          Theme.of(context).brightness == Brightness.dark
                      ? Colors.white
                      : Colors.black,
                ),
              ),
              Text(
                line2,
                style: TextStyle(
                  fontSize: screenWidth * 0.035,
                  fontWeight: FontWeight.bold,
                  color: statusColor,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                count,
                style: TextStyle(
                  fontSize: screenWidth * 0.045,
                  fontWeight: FontWeight.bold,
                  color:
                      bgColor == Colors.white &&
                          Theme.of(context).brightness == Brightness.dark
                      ? Colors.white
                      : Colors.black,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDealCard({
    required String name,
    required String leadNo,
    required String phone,
    required String date,
    required String wonBy,
    required double screenWidth,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Theme.of(context).dividerColor),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Image.asset(
            'assets/icons/call_purple.png',
             color: const Color(0xFF26A69A),
            width: screenWidth * 0.06,
            height: screenWidth * 0.06,
            errorBuilder: (context, error, stackTrace) => Icon(
              Icons.phone_callback_rounded,
              color: const Color(0xFF26A69A),
              size: screenWidth * 0.06,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      name,
                      style: TextStyle(
                        fontSize: screenWidth * 0.045,
                        fontWeight: FontWeight.w500,
                        color: Theme.of(context).textTheme.titleMedium?.color,
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const EnquiryDetailsScreen(),
                          ),
                        );
                      },
                      child: Image.asset(
                        'assets/icons/green_next.png',
                        width: screenWidth * 0.06,
                        height: screenWidth * 0.06,
                        errorBuilder: (context, error, stackTrace) => Container(
                          padding: const EdgeInsets.all(4),
                          decoration: const BoxDecoration(
                            color: Colors.green,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.chevron_right,
                            color: Colors.white,
                            size: screenWidth * 0.04,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  leadNo,
                  style: TextStyle(
                    fontSize: screenWidth * 0.035,
                    color: Theme.of(
                      context,
                    ).textTheme.bodyMedium?.color?.withValues(alpha: 0.7),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  phone,
                  style: TextStyle(
                    fontSize: screenWidth * 0.04,
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).textTheme.bodyLarge?.color,
                  ),
                ),
                const SizedBox(height: 8),
                const Divider(height: 1, color: Color(0xFFEEEEEE)),
                const SizedBox(height: 8),
                Text(
                  date,
                  style: TextStyle(
                    fontSize: screenWidth * 0.035,
                    color: Theme.of(context).textTheme.bodySmall?.color,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Deal Won By  $wonBy',
                  style: TextStyle(
                    fontSize: screenWidth * 0.035,
                    color: Theme.of(context).textTheme.bodySmall?.color,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
