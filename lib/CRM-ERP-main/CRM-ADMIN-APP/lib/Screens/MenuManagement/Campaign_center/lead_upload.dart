import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

class LeadUploadScreen extends StatefulWidget {
  const LeadUploadScreen({super.key});

  @override
  State<LeadUploadScreen> createState() => _LeadUploadScreenState();
}

class _LeadUploadScreenState extends State<LeadUploadScreen> {
  void _pickFile() {
    // Placeholder for file picking logic
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('File picker opened')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F9FC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Color(0xFF1A1A1A), size: 18),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Lead Upload Center',
          style: TextStyle(
            color: Color(0xFF1A1A1A),
            fontSize: 18,
            fontWeight: FontWeight.w900,
            letterSpacing: -0.5,
          ),
        ),
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        child: Column(
          children: [
            // Header Section
            _buildHeader(),
            const SizedBox(height: 24),

            // Upload Area
            _buildUploadCard(),
            const SizedBox(height: 24),

            // Instructions Card
            _buildInstructionsCard(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Image.network(
            'https://cdn-icons-png.flaticon.com/512/2874/2874251.png', // Modern chart/lead icon
            width: 48,
            height: 48,
            errorBuilder: (context, error, stackTrace) => const Icon(Icons.cloud_upload_rounded, size: 48, color: Color(0xFF6B7CF6)),
          ),
        ).animate().scale(duration: 400.ms, curve: Curves.easeOutBack),
        const SizedBox(height: 16),
        const Text(
          'Lead Upload Center',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w900,
            color: Color(0xFF1A1A1A),
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Import and manage your leads efficiently',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey.shade600,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.1);
  }

  Widget _buildUploadCard() {
    return Container(
      width: double.infinity,
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
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            CustomPaint(
              painter: _DashedBorderPainter(color: const Color(0xFFD0D7E5), radius: 20),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 40),
                decoration: BoxDecoration(
                  color: const Color(0xFFF9FBFF),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  children: [
                    Icon(Icons.folder_open_rounded, size: 56, color: Colors.amber.shade400),
                    const SizedBox(height: 16),
                    const Text(
                      'Drag & Drop Your File Here',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF2D3E50),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'or click to browse',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey.shade500,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: _pickFile,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF6B7CF6),
                        foregroundColor: Colors.white,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: const Text(
                        'Choose File',
                        style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'Supported formats: CSV, XLS, XLSX',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade400,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.1);
  }

  Widget _buildInstructionsCard() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFFF0F4FB),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFE0E7F2)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.assignment_outlined, size: 20, color: Color(0xFF4A5568)),
                const SizedBox(width: 10),
                const Text(
                  'Upload Instructions',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF2D3E50),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _instructionRow('Ensure your file contains columns: Lead Name, Mobile, Email, Source, Assigned To, Status'),
            _instructionRow('Mobile numbers should be in valid format (10 digits)'),
            _instructionRow('Email addresses must be valid'),
            _instructionRow('Maximum file size: 5MB'),
            _instructionRow('Duplicate leads will be automatically flagged'),
          ],
        ),
      ),
    ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.1);
  }

  Widget _instructionRow(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.check_rounded, size: 18, color: Color(0xFF45C782)),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 13,
                color: Color(0xFF4A5568),
                fontWeight: FontWeight.w500,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DashedBorderPainter extends CustomPainter {
  final Color color;
  final double radius;

  _DashedBorderPainter({required this.color, required this.radius});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1.6
      ..style = PaintingStyle.stroke;
    final path = Path()
      ..addRRect(RRect.fromRectAndRadius(Offset.zero & size, Radius.circular(radius)));
    for (final metric in path.computeMetrics()) {
      double distance = 0;
      while (distance < metric.length) {
        canvas.drawPath(metric.extractPath(distance, distance + 6), paint);
        distance += 11;
      }
    }
  }

  @override
  bool shouldRepaint(covariant _DashedBorderPainter oldDelegate) => true;
}
