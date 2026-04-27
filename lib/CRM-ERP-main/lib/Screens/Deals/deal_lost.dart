import 'package:flutter/material.dart';

class DealLostScreen extends StatelessWidget {
  const DealLostScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const Color primaryPurple = Color(0xFF26A69A);
    const Color coralColor = Color(0xFFFFA095);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: primaryPurple,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Deal lost',
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
                      _buildSummaryCard("Total Deal Lost", "4", coralColor),
                      const SizedBox(width: 16),
                      _buildSummaryCard(
                        "Total Deal Value",
                        "₹70,000",
                        coralColor,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 100), // Space for cards

            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Center(
                child: Padding(
                  padding: EdgeInsets.all(32.0),
                  child: Text("No lost deals found"),
                ),
              ),
            ),

            const SizedBox(height: 16),
            _buildReasonSection(context),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryCard(String title, String value, Color color) {
    return Expanded(
      child: Container(
        height: 140,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
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
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              value,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReasonSection(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Theme.of(context).dividerColor),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.02),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Reason For Losses in pipeline Status',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).textTheme.titleLarge?.color,
              ),
            ),
            const SizedBox(height: 24),
            _buildProgressItem(context, 'Price', 0.6, [
              const Color(0xFF7FFFE0),
              const Color(0xFF0081EA),
            ]),
            _buildProgressItem(context, 'Competitor', 0.45, [
              const Color(0xFFF590FF),
              const Color(0xFF4D39FF),
            ]),
            _buildProgressItem(context, 'Timing Conflicts', 0.75, [
              const Color(0xFFFFBC48),
              const Color(0xFFFF8000),
            ]),
            _buildProgressItem(context, 'Requirement changed', 0.55, [
              const Color(0xFFC5FF77),
              const Color(0xFF00CC89),
            ]),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressItem(
    BuildContext context,
    String label,
    double progress,
    List<Color> gradientColors,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '• $label',
            style: TextStyle(
              fontSize: 16,
              color: Theme.of(context).textTheme.bodyLarge?.color,
            ),
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: SizedBox(
              height: 18,
              child: Stack(
                children: [
                  Container(
                    width: double.infinity,
                    color: Theme.of(context).brightness == Brightness.dark
                        ? Colors.grey[800]
                        : Colors.grey.shade200,
                  ),
                  FractionallySizedBox(
                    widthFactor: progress,
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: gradientColors,
                          begin: Alignment.centerRight,
                          end: Alignment.centerLeft,
                        ),
                      ),
                      child: CustomPaint(
                        painter: StripePainter(),
                        size: Size.infinite,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class StripePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.3)
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;

    const double step = 8.0;
    // Draw diagonal lines across the tube
    for (double i = -size.height; i < size.width; i += step) {
      canvas.drawLine(
        Offset(i, size.height),
        Offset(i + size.height, 0),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
