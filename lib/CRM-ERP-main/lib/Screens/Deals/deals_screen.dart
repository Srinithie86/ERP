import 'package:flutter/material.dart';
import 'deal_lost.dart';
import 'deal_won.dart';

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
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.all(20.0),
                      child: Text("No active deals found"),
                    ),
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
}
