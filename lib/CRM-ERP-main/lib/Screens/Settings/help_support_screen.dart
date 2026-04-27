import 'package:flutter/material.dart';

class HelpSupportScreen extends StatelessWidget {
  const HelpSupportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF26A69A),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Help & Support',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSection(
              title: 'Support Option',
              children: [
                _buildSupportItem(
                  'Knowledge Base',
                  'Browse FAQs, guides, and tutorials',
                  Icons.description_outlined,
                ),
                const Divider(height: 1),
                _buildSupportItem(
                  'Video Tutorial',
                  'Step-by-step walkthroughs',
                  Icons.play_circle_outline,
                ),
                const Divider(height: 1),
                _buildSupportItem(
                  'Live Chat',
                  'Connect instantly with our team',
                  Icons.chat_bubble_outline,
                ),
                const Divider(height: 1),
                _buildSupportItem(
                  'Mail Support',
                  'support@smartcrm.com',
                  Icons.mail_outline,
                ),
                const Divider(height: 1),
                _buildSupportItem(
                  'Mobile Support',
                  '+91 98765 43210',
                  Icons.phone_outlined,
                ),
              ],
            ),
            const SizedBox(height: 20),
            _buildCardSection(
              title: 'Feedback & Suggestions',
              description:
                  '💡 We value your feedback! Share your ideas to improve your CRM experience.',
              buttonLabel: 'Submit Feedback',
            ),
            const SizedBox(height: 20),
            _buildCardSection(
              title: 'Contact Support',
              description:
                  '🎧 Need immediate assistance? Our support team is ready to help.',
              buttonLabel: 'Contact Support',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required List<Widget> children,
  }) {
    return Builder(
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: Theme.of(context).cardTheme.color ?? Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.withValues(alpha: 0.2)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 16, top: 16, bottom: 4),
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color:
                      Theme.of(context).textTheme.titleMedium?.color ??
                      Colors.black,
                ),
              ),
            ),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildSupportItem(String title, String subtitle, IconData icon) {
    return Builder(
      builder: (context) => ListTile(
        title: Text(
          title,
          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
        ),
        subtitle: Text(
          subtitle,
          style: TextStyle(
            fontSize: 13,
            color:
                Theme.of(context).textTheme.bodySmall?.color ?? Colors.black54,
          ),
        ),
        trailing: const Icon(Icons.chevron_right, color: Colors.black54),
        onTap: () {},
      ),
    );
  }

  Widget _buildCardSection({
    required String title,
    required String description,
    required String buttonLabel,
  }) {
    return Builder(
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Theme.of(context).cardTheme.color ?? Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.withValues(alpha: 0.2)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              description,
              style: TextStyle(
                fontSize: 14,
                color:
                    Theme.of(context).textTheme.bodyLarge?.color ??
                    Colors.black87,
              ),
            ),
            const SizedBox(height: 16),
            Align(
              alignment: Alignment.centerRight,
              child: ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF26A69A),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 12,
                  ),
                ),
                child: Text(
                  buttonLabel,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
