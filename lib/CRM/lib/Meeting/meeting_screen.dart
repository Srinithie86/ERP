import 'package:flutter/material.dart';
import '../Follows/enquiry_details_screen.dart';
import 'add_meeting_screen.dart';

class MeetingVisitScreen extends StatefulWidget {
  final VoidCallback? onBack;
  const MeetingVisitScreen({super.key, this.onBack});

  @override
  State<MeetingVisitScreen> createState() => _MeetingVisitScreenState();
}

class _MeetingVisitScreenState extends State<MeetingVisitScreen> {
  final List<String> _categories = [
    "All",
    "Direct",
    "Phone Call",
    "Video Call",
  ];
  String _selectedCategory = "All";
  String _selectedReportType = "Daily Meeting Report"; // Default sort option

  // Method to get current counts based on report type
  Map<String, String> get _currentCounts {
    switch (_selectedReportType) {
      case "Weekly Meeting Report":
        return {
          "Today": "Week", // specific title key
          "Schedule": "25",
          "Complete": "18",
          "Total": "45",
        };
      case "Monthly Meeting Report":
        return {
          "Today": "Month", // specific title key
          "Schedule": "120",
          "Complete": "85",
          "Total": "210",
        };
      case "Daily Meeting Report":
      default:
        return {
          "Today": "Today", // specific title key
          "Schedule": "10",
          "Complete": "10",
          "Total": "10",
        };
    }
  }

  // Method to get the first card's title
  String get _firstCardTitle {
    switch (_selectedReportType) {
      case "Weekly Meeting Report":
        return "Weekly";
      case "Monthly Meeting Report":
        return "Monthly";
      case "Daily Meeting Report":
      default:
        return "Today";
    }
  }

  // Method to get the first card's count
  String get _firstCardCount {
    switch (_selectedReportType) {
      case "Weekly Meeting Report":
        return "15"; // Example data for weekly
      case "Monthly Meeting Report":
        return "45"; // Example data for monthly
      case "Daily Meeting Report":
      default:
        return "06"; // Default data for today
    }
  }

  @override
  Widget build(BuildContext context) {
    const Color primaryPurple = Color(0xFF26A69A);
    final Size size = MediaQuery.of(context).size;
    final double screenWidth = size.width;
    final counts = _currentCounts;

    return Scaffold(
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
          'Meeting/Visit',
          style: TextStyle(
            color: Colors.white,
            fontSize: screenWidth * 0.05,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Search Bar
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).brightness == Brightness.dark
                      ? const Color(0xFF2C2440)
                      : const Color(0xFFE0FFFC),
                  borderRadius: BorderRadius.circular(30),
                ),
                child: TextField(
                  decoration: InputDecoration(
                    hintText: 'Search',
                    hintStyle: TextStyle(
                      color: Theme.of(context).brightness == Brightness.dark
                          ? Colors.white60
                          : const Color(0xFF9E8EBB),
                      fontSize: screenWidth * 0.04,
                    ),
                    prefixIcon: Icon(
                      Icons.search,
                      color: Theme.of(context).brightness == Brightness.dark
                          ? Colors.white60
                          : const Color(0xFF9E8EBB),
                    ),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
            ),

            // Horizontal Categories
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: _categories.map((category) {
                  bool isSelected = _selectedCategory == category;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: InkWell(
                      onTap: () {
                        setState(() {
                          _selectedCategory = category;
                        });
                      },
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: screenWidth * 0.06,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? primaryPurple
                              : Theme.of(context).cardColor,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: isSelected
                                ? primaryPurple
                                : Theme.of(context).dividerColor,
                            width: 1,
                          ),
                        ),
                        child: Text(
                          category,
                          style: TextStyle(
                            color: isSelected
                                ? Colors.white
                                : const Color(0xFF26A69A),
                            fontWeight: FontWeight.w500,
                            fontSize: screenWidth * 0.035,
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),

            // Sort By Button
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Align(
                alignment: Alignment.centerRight,
                child: OutlinedButton.icon(
                  onPressed: () => _showSortByBottomSheet(context),
                  icon: const Icon(Icons.filter_list, size: 20),
                  label: Text(
                    _selectedReportType.split(' ').first,
                  ), // Show selected sort type
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Theme.of(
                      context,
                    ).textTheme.bodyLarge?.color,
                    side: const BorderSide(color: Color(0xFF26A69A)),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                  ),
                ),
              ),
            ),

            // Summary Grid
            Padding(
              padding: const EdgeInsets.all(16),
              child: GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 1.2,
                children: [
                  _buildSummaryCard(
                    _firstCardTitle,
                    _firstCardCount,
                    const Color(0xFFB5F2B5),
                    const Color(0xFF00C853),
                    screenWidth,
                  ),
                  _buildSummaryCard(
                    "Schedule",
                    counts["Schedule"]!,
                    const Color(0xFFFFCC99),
                    const Color(0xFFFF9800),
                    screenWidth,
                  ),
                  _buildSummaryCard(
                    "Complete",
                    counts["Complete"]!,
                    const Color(0xFFB3E5FC),
                    const Color(0xFF03A9F4),
                    screenWidth,
                  ),
                  _buildSummaryCard(
                    "Total",
                    counts["Total"]!,
                    const Color(0xFFFFF9C4),
                    const Color(0xFFFBC02D),
                    screenWidth,
                  ),
                ],
              ),
            ),

            // History Section
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'History',
                  style: TextStyle(
                    fontSize: screenWidth * 0.045,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).textTheme.titleLarge?.color,
                  ),
                ),
              ),
            ),

            // History List
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                children: [
                  _buildHistoryItem(
                    "Raj",
                    "10 Dec 2025 10:27 am",
                    "Scheduled Direct Visit",
                    const Color(0xFF00C853),
                    screenWidth,
                  ),
                  _buildHistoryItem(
                    "kumar",
                    "10 Dec 2025 10:27 am",
                    "Scheduled Phone Call",
                    const Color(0xFFFF9800),
                    screenWidth,
                  ),
                  _buildHistoryItem(
                    "Raj",
                    "10 Dec 2025 10:27 am",
                    "Scheduled Video Visit",
                    const Color(0xFF03A9F4),
                    screenWidth,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 100),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddMeetingScreen()),
          );
        },
        backgroundColor: const Color(0xFF26A69A),
        shape: const CircleBorder(),
        elevation: 2,
        child: const Icon(Icons.add, color: Colors.white, size: 30),
      ),
    );
  }

  Widget _buildSummaryCard(
    String title,
    String count,
    Color badgeColor,
    Color textColor,
    double screenWidth,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Theme.of(context).dividerColor),
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
            style: TextStyle(
              fontSize: screenWidth * 0.045,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).textTheme.titleMedium?.color,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: badgeColor,
              shape: BoxShape.circle,
            ),
            child: Text(
              count,
              style: TextStyle(
                color: textColor,
                fontWeight: FontWeight.bold,
                fontSize: screenWidth * 0.04,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryItem(
    String name,
    String dateTime,
    String status,
    Color statusColor,
    double screenWidth,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Theme.of(context).dividerColor),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                name,
                style: TextStyle(
                  fontSize: screenWidth * 0.04,
                  fontWeight: FontWeight.w500,
                  color: Theme.of(context).textTheme.bodyLarge?.color,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                dateTime,
                style: TextStyle(
                  fontSize: screenWidth * 0.035,
                  color: Theme.of(context).textTheme.bodySmall?.color,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                status,
                style: TextStyle(
                  fontSize: screenWidth * 0.035,
                  color: statusColor,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
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
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: const BoxDecoration(
                color: Color(0xFF00C853),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.chevron_right,
                color: Colors.white,
                size: 20,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showSortByBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Theme.of(context).cardColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildSortOption(
                context,
                Icons.calendar_month_outlined,
                "Daily Meeting Report",
              ),
              Divider(height: 1, color: Theme.of(context).dividerColor),
              _buildSortOption(
                context,
                Icons.calendar_month_outlined,
                "Weekly Meeting Report",
              ),
              Divider(height: 1, color: Theme.of(context).dividerColor),
              _buildSortOption(
                context,
                Icons.calendar_month_outlined,
                "Monthly Meeting Report",
              ),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSortOption(BuildContext context, IconData icon, String label) {
    bool isSelected = _selectedReportType == label;
    return ListTile(
      leading: Icon(
        icon,
        color: isSelected
            ? const Color(0xFF26A69A)
            : Theme.of(context).textTheme.bodyLarge?.color,
      ),
      title: Text(
        label,
        style: TextStyle(
          fontSize: 16,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
          color: isSelected
              ? const Color(0xFF26A69A)
              : Theme.of(context).textTheme.bodyLarge?.color,
        ),
      ),
      trailing: isSelected
          ? const Icon(Icons.check, color: Color(0xFF26A69A))
          : null,
      onTap: () {
        setState(() {
          _selectedReportType = label;
        });
        Navigator.pop(context);
      },
    );
  }
}
