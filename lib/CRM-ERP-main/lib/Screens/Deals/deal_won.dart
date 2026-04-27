import 'package:flutter/material.dart';

class DealWonScreen extends StatelessWidget {
  const DealWonScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const Color primaryPurple = Color(0xFF26A69A);
    const Color lightPurpleColor = Color(0xFFFDEFFF);
    return Scaffold(
      appBar: AppBar(
        backgroundColor: primaryPurple,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Deal Won',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w500,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.calendar_month, color: Colors.white),
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
                // Curved Purple Header
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
                // Summary Cards
                Positioned(
                  top: 20,
                  left: 16,
                  right: 16,
                  child: Row(
                    children: [
                      _buildSummaryCard(
                        "Total Deal Won",
                        "10",
                        Color(0xFFFCF2D5),
                        Colors.black,
                      ),
                      const SizedBox(width: 16),
                      _buildSummaryCard(
                        "Total Deal Value",
                        "₹10,00,00",
                        lightPurpleColor,
                        Colors.black,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 100), // Space for cards

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: const Center(
                child: Padding(
                  padding: EdgeInsets.all(32.0),
                  child: Text("No won deals found"),
                ),
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryCard(
    String title,
    String value,
    Color color,
    Color textColor,
  ) {
    return Expanded(
      child: Container(
        height: 140,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: textColor,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              value,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: textColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
