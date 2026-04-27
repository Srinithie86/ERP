import 'package:flutter/material.dart';
import 'package:crm/core/theme/app_theme.dart';

class LeadUploadScreen extends StatelessWidget {
  const LeadUploadScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildHeader(context),
            const SizedBox(height: 32),
            _buildUploadArea(context),
            const SizedBox(height: 24),
            _buildInstructionsBox(),
            const SizedBox(height: 48),
            _buildFooter(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.blue.shade100,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.bar_chart, color: Colors.blue, size: 28),
            ),
            const SizedBox(width: 16),
            Text(
              'Lead Upload Center',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textColor,
                  ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          'Import and manage your leads efficiently',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.grey.shade600,
              ),
        ),
      ],
    );
  }

  Widget _buildUploadArea(BuildContext context) {
    return Card(
      elevation: 0,
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 48, horizontal: 24),
          decoration: BoxDecoration(
            color: Colors.indigo.shade50.withValues(alpha: 0.3),
            borderRadius: BorderRadius.circular(12),
            // Using a solid border as a fallback for dashed border without external packages
            border: Border.all(
              color: Colors.indigo.shade200,
              width: 1.5,
              style: BorderStyle.solid,
            ),
          ),
          child: Column(
            children: [
              const Icon(
                Icons.folder,
                size: 64,
                color: Colors.amber,
              ),
              const SizedBox(height: 24),
              Text(
                'Drag & Drop Your File Here',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textColor,
                    ),
              ),
              const SizedBox(height: 8),
              Text(
                'or click to browse',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.indigo.shade300,
                    ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  // File picker logic would go here
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('File picker would open here')),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryTeal, // Themed to match the app
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text('Choose File'),
              ),
              const SizedBox(height: 24),
              Text(
                'Supported formats: CSV, XLS, XLSX',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.grey.shade500,
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInstructionsBox() {
    return Card(
      elevation: 0,
      color: Colors.blueGrey.shade50.withValues(alpha: 0.5),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.assignment_outlined, color: Colors.blueGrey.shade700, size: 20),
                const SizedBox(width: 12),
                Text(
                  'Upload Instructions',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.blueGrey.shade800,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            _buildInstructionItem('Ensure your file contains columns: Lead Name, Mobile, Email, Source, Assigned To, Status'),
            _buildInstructionItem('Mobile numbers should be in valid format (10 digits)'),
            _buildInstructionItem('Email addresses must be valid'),
            _buildInstructionItem('Maximum file size: 5MB'),
            _buildInstructionItem('Duplicate leads will be automatically flagged'),
          ],
        ),
      ),
    );
  }

  Widget _buildInstructionItem(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.check, color: Colors.green, size: 18),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                color: Colors.blueGrey.shade700,
                fontSize: 13,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFooter() {
    return Center(
      child: Text(
        '2026 © Smart Global Solutions',
        style: TextStyle(
          color: Colors.grey.shade500,
          fontSize: 12,
        ),
      ),
    );
  }
}
