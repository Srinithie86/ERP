import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';

class ReportDetailScreen extends StatefulWidget {
  const ReportDetailScreen({super.key});

  @override
  State<ReportDetailScreen> createState() => _ReportDetailScreenState();
}

class _ReportDetailScreenState extends State<ReportDetailScreen> {
  void _showShareOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Theme.of(context).cardColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Share Report via',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).textTheme.titleLarge?.color,
                ),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildShareOption(
                    context,
                    Icons.whatshot,
                    'WhatsApp',
                    Colors.green,
                    onTap: () {
                      Navigator.pop(context);
                      Share.share(
                        'Check out this Lead Report for Project CRM!',
                      );
                    },
                  ),
                  _buildShareOption(
                    context,
                    Icons.mail_outline,
                    'Mail',
                    Colors.blue,
                    onTap: () {
                      Navigator.pop(context);
                      Share.share('Lead Report for Project CRM attached.');
                    },
                  ),
                  _buildShareOption(
                    context,
                    Icons.message_outlined,
                    'SMS',
                    Colors.orange,
                    onTap: () {
                      Navigator.pop(context);
                      Share.share('Lead Report: CRM - Harish');
                    },
                  ),
                  _buildShareOption(
                    context,
                    Icons.copy,
                    'Copy Link',
                    Colors.grey,
                    onTap: () {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Link copied to clipboard!'),
                        ),
                      );
                    },
                  ),
                ],
              ),
              const SizedBox(height: 10),
            ],
          ),
        );
      },
    );
  }

  Widget _buildShareOption(
    BuildContext context,
    IconData icon,
    String label,
    Color color, {
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Column(
        children: [
          CircleAvatar(
            radius: 25,
            backgroundColor: color.withAlpha(25),
            child: Icon(icon, color: color, size: 28),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Theme.of(context).textTheme.bodyMedium?.color,
            ),
          ),
        ],
      ),
    );
  }

  void _showGenerateDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Theme.of(context).cardColor,
          title: Text(
            'Generate Report',
            style: TextStyle(
              color: Theme.of(context).textTheme.titleLarge?.color,
            ),
          ),
          content: Text(
            'Choose your preferred format to download the report.',
            style: TextStyle(
              color: Theme.of(context).textTheme.bodyMedium?.color,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                _simulateDownload('PDF');
              },
              child: const Text(
                'PDF',
                style: TextStyle(
                  color: Color(0xFF26A69A),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                _simulateDownload('DOCS');
              },
              child: const Text(
                'DOCS',
                style: TextStyle(
                  color: Color(0xFF26A69A),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                'Cancel',
                style: TextStyle(
                  color: Theme.of(context).textTheme.bodySmall?.color,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  void _simulateDownload(String format) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return Center(
          child: Card(
            color: Theme.of(context).cardColor,
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const CircularProgressIndicator(color: Color(0xFF26A69A)),
                  const SizedBox(height: 16),
                  Text(
                    'Downloading Report...',
                    style: TextStyle(
                      color: Theme.of(context).textTheme.bodyLarge?.color,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );

    Future.delayed(const Duration(seconds: 2), () {
      Navigator.pop(context); // Dismiss the loading dialog
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Report successfully downloaded as $format'),
          backgroundColor: Colors.green,
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final screenWidth = mediaQuery.size.width;
    final screenHeight = mediaQuery.size.height;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: const Color(0xFF26A69A),
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: Colors.white,
            size: screenWidth * 0.06,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Reports',
          style: TextStyle(
            color: Colors.white,
            fontSize: screenWidth * 0.05,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(
              Icons.more_vert,
              color: Colors.white,
              size: screenWidth * 0.06,
            ),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.all(screenWidth * 0.05),
              child: Text(
                'Lead Reports',
                style: TextStyle(
                  fontSize: screenWidth * 0.045,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF26A69A),
                ),
              ),
            ),
            // Header Card - Full Width
            Container(
              width: screenWidth,
              padding: EdgeInsets.all(screenWidth * 0.04),
              decoration: const BoxDecoration(
                color: Color(0xFF26A69A),
                // Removed borderRadius for full-width effect
              ),
              child: Row(
                children: [
                  Container(
                    width: screenWidth * 0.2,
                    height: screenWidth * 0.2,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                    child: Padding(
                      padding: EdgeInsets.all(screenWidth * 0.04),
                      child: Image.asset('assets/icons/report-orange.png'),
                    ),
                  ),
                  SizedBox(width: screenWidth * 0.03),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              'Company Name : Harish',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w400,
                                fontSize: screenWidth * 0.037,
                              ),
                            ),
                            SizedBox(width: screenWidth * 0.13),
                            IconButton(
                              icon: Image.asset(
                                'assets/icons/edit.png',
                                height: screenWidth * 0.06,
                                width: screenWidth * 0.06,
                              ),
                              onPressed: () {},
                            ),
                          ],
                        ),
                        Text(
                          'Project : CRM',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: screenWidth * 0.037,
                          ),
                        ),
                        SizedBox(height: screenHeight * 0.005),
                        Text(
                          'Report : Leads Report',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: screenWidth * 0.037,
                          ),
                        ),
                        SizedBox(height: screenHeight * 0.005),
                        Text(
                          'Date Range: 12-09-2025 - 25-09-2025',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: screenWidth * 0.037,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: screenHeight * 0.03),
            // Lead Details Card
            Container(
              margin: EdgeInsets.symmetric(horizontal: screenWidth * 0.04),
              padding: EdgeInsets.all(screenWidth * 0.05),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(color: Colors.black.withAlpha(12), blurRadius: 10),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Lead Details',
                    style: TextStyle(
                      fontSize: screenWidth * 0.04,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).textTheme.titleMedium?.color,
                    ),
                  ),
                  SizedBox(height: screenHeight * 0.02),
                  _buildDetailRow('Created', '1/10/2026', screenWidth),
                  _buildDetailRow('Source', 'Google', screenWidth),
                  _buildDetailRow('Medium', 'Whatsapp', screenWidth),
                  _buildDetailRow('Budget Amount', '20,00,000', screenWidth),
                  _buildDetailRow(
                    'Status',
                    'Booked',
                    screenWidth,
                    valueColor: Colors.green,
                  ),
                  _buildDetailRow(
                    'Remarks',
                    'He is okay to deal with us',
                    screenWidth,
                  ),
                  _buildDetailRow('Attended by', 'Rakesh', screenWidth),
                  _buildDetailRow('Details', 'Good', screenWidth),
                ],
              ),
            ),
            SizedBox(height: screenHeight * 0.1),
          ],
        ),
      ),
      bottomNavigationBar: Padding(
        padding: EdgeInsets.all(screenWidth * 0.04),
        child: Row(
          children: [
            Expanded(
              child: SizedBox(
                height: screenHeight * 0.065,
                child: ElevatedButton.icon(
                  onPressed: () => _showShareOptions(context),
                  icon: Icon(
                    Icons.upload_outlined,
                    color: Colors.white,
                    size: screenWidth * 0.05,
                  ),
                  label: Text(
                    'Share Report',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: screenWidth * 0.032,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF26A69A),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(width: screenWidth * 0.04),
            Expanded(
              child: SizedBox(
                height: screenHeight * 0.065,
                child: ElevatedButton.icon(
                  onPressed: () => _showGenerateDialog(context),
                  icon: Icon(
                    Icons.add_box_outlined,
                    color: Colors.white,
                    size: screenWidth * 0.05,
                  ),
                  label: Text(
                    'Generate Report',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: screenWidth * 0.032,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF26A69A),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(
    String label,
    String value,
    double screenWidth, {
    Color? valueColor,
  }) {
    final Color effectiveValueColor =
        valueColor ??
        (Theme.of(context).textTheme.bodyMedium?.color ??
            const Color(0xFF707070));
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: screenWidth * 0.35,
            child: Text(
              label,
              style: TextStyle(
                color: const Color(0xFF26A69A),
                fontSize: screenWidth * 0.038,
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                color: effectiveValueColor,
                fontSize: screenWidth * 0.038,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
