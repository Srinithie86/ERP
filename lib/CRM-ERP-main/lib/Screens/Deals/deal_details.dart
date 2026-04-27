import 'package:flutter/material.dart';

class DealDetailsScreen extends StatelessWidget {
  final String status;
  const DealDetailsScreen({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    const Color primaryPurple = Color(0xFF26A69A);
    const Color profileBlue = Color(0xFFAEC1E8);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: primaryPurple,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'details',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Profile Card Section
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: profileBlue,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    const CircleAvatar(
                      radius: 40,
                      backgroundImage: AssetImage(
                        'assets/images/user_avatar.png',
                      ), // Fallback to placeholder if not exists
                      backgroundColor: Colors.white,
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildProfileInfoLine('Company Name', 'Harish'),
                          _buildProfileInfoLine('Project', 'CRM'),
                          _buildProfileInfoLine('Report', 'Enquiry Report'),
                          _buildProfileInfoLine(
                            'Date Range',
                            '12-09-2025 - 25-09-2025',
                          ),
                        ],
                      ),
                    ),
                    const Align(
                      alignment: Alignment.topRight,
                      child: Icon(
                        Icons.edit_square,
                        color: primaryPurple,
                        size: 24,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Details List Section
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 8.0,
              ),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Theme.of(context).dividerColor),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.02),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildDetailField(context, 'Project Value', '₹20,00,00'),
                    _buildDetailField(context, 'Name', 'Ganesh'),
                    _buildDetailField(context, 'Lead No', 'L001'),
                    _buildDetailField(context, 'Phone No', '7894561231'),
                    _buildDetailField(context, 'WhatsApp No', '7894561231'),
                    _buildDetailField(context, 'Email ID', 'Ganesh@gmail.com'),
                    _buildDetailField(
                      context,
                      'Date Created',
                      '05 December 2025 - 10:45 AM',
                      isLast: true,
                    ),
                  ],
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
              child: Text(
                'Time line',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).textTheme.titleLarge?.color,
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                children: [
                  _buildTimelineItem(
                    context,
                    title: status == 'Won' ? 'Deal Won' : 'Deal Lost',
                    titleColor: status == 'Won'
                        ? const Color(0xFF4FDB09)
                        : const Color(0xFFDC0A0A),
                    dateTime: '2025-12-08 11:30 AM',
                    actor: 'Rajesh Kumar',
                    isFirst: true,
                  ),
                  _buildTimelineItem(
                    context,
                    title: 'Follow-up Meeting made',
                    titleColor:
                        Theme.of(context).textTheme.bodyLarge?.color ??
                        Colors.black,
                    highlightWord: 'Meeting',
                    highlightColor: const Color(0xFFAFE90F),
                    dateTime: '2025-12-08 11:30 AM',
                    actor: 'Rajesh Kumar',
                    comment: 'Customer showed interest',
                  ),
                  _buildTimelineItem(
                    context,
                    title: 'Follow-up call made',
                    titleColor:
                        Theme.of(context).textTheme.bodyLarge?.color ??
                        Colors.black,
                    highlightWord: 'call',
                    highlightColor: const Color(0xFF9B22F2),
                    dateTime: '2025-12-05 10:30 AM',
                    actor: 'Rajesh Kumar',
                    comment: 'Customer showed interest',
                  ),
                  _buildTimelineItem(
                    context,
                    title: 'Email sent',
                    titleColor: const Color(0xFF098377),
                    dateTime: '2025-12-05 09:00 AM',
                    actor: 'System',
                    comment: 'Welcome email with property details',
                  ),
                  _buildTimelineItem(
                    context,
                    title: 'Enquiry created',
                    titleColor: const Color(0xFF2C13EA),
                    dateTime: '2025-12-05 08:45 AM',
                    actor: 'Website',
                    comment: 'Lead captured from website form',
                    isLast: true,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileInfoLine(String label, String value) {
    return Builder(
      builder: (context) => Padding(
        padding: const EdgeInsets.only(bottom: 4),
        child: RichText(
          text: TextSpan(
            style: TextStyle(
              fontSize: 14,
              color: Theme.of(context).textTheme.bodyMedium?.color,
            ),
            children: [
              TextSpan(
                text: '$label : ',
                style: const TextStyle(fontWeight: FontWeight.w400),
              ),
              TextSpan(
                text: value,
                style: const TextStyle(fontWeight: FontWeight.w400),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailField(
    BuildContext context,
    String label,
    String value, {
    bool isLast = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).textTheme.titleSmall?.color,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            color: Theme.of(context).textTheme.bodyMedium?.color,
          ),
        ),
        if (!isLast) ...[const SizedBox(height: 12)],
      ],
    );
  }

  Widget _buildTimelineItem(
    BuildContext context, {
    required String title,
    required Color titleColor,
    String? highlightWord,
    Color? highlightColor,
    required String dateTime,
    required String actor,
    String? comment,
    bool isFirst = false,
    bool isLast = false,
  }) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Dot and Line
          Column(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  shape: BoxShape.circle,
                  border: Border.all(color: const Color(0xFF26A69A), width: 2),
                ),
                child: const Icon(
                  Icons.access_time_filled,
                  color: Color(0xFF26A69A),
                  size: 24,
                ),
              ),
              if (!isLast)
                Expanded(
                  child: Container(
                    width: 2,
                    color: const Color(0xFF26A69A).withValues(alpha: 0.5),
                  ),
                ),
            ],
          ),
          const SizedBox(width: 16),
          // Content
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 32.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (highlightWord != null && highlightColor != null)
                    _buildRichTitle(
                      context,
                      title,
                      highlightWord,
                      highlightColor,
                    )
                  else
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: titleColor,
                      ),
                    ),
                  const SizedBox(height: 4),
                  Text(
                    dateTime,
                    style: TextStyle(
                      fontSize: 14,
                      color: Theme.of(context).textTheme.bodySmall?.color,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    actor,
                    style: TextStyle(
                      fontSize: 14,
                      color: Theme.of(context).textTheme.bodySmall?.color,
                    ),
                  ),
                  if (comment != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      comment,
                      style: TextStyle(
                        fontSize: 14,
                        color: Theme.of(context).textTheme.bodySmall?.color,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRichTitle(
    BuildContext context,
    String title,
    String highlight,
    Color highlightColor,
  ) {
    final parts = title.split(highlight);
    return RichText(
      text: TextSpan(
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: Theme.of(context).textTheme.bodyLarge?.color,
        ),
        children: [
          if (parts[0].isNotEmpty) TextSpan(text: parts[0]),
          TextSpan(
            text: highlight,
            style: TextStyle(color: highlightColor),
          ),
          if (parts.length > 1 && parts[1].isNotEmpty) TextSpan(text: parts[1]),
        ],
      ),
    );
  }
}
