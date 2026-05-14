import 'package:flutter/material.dart';
import 'overview_tab.dart';
import 'timeline_tab.dart';
import 'call_summary_tab.dart';

class EnquiryTabsView extends StatefulWidget {
  final Map<String, dynamic> lead;
  final String status;
  final int initialIndex;
  const EnquiryTabsView({
    super.key,
    required this.lead,
    required this.status,
    this.initialIndex = 0,
  });

  @override
  State<EnquiryTabsView> createState() => _EnquiryTabsViewState();
}

class _EnquiryTabsViewState extends State<EnquiryTabsView>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final List<dynamic> _timelineData = [];
  final List<dynamic> _callSummaryData = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: 3,
      vsync: this,
      initialIndex: widget.initialIndex > 2 ? 0 : widget.initialIndex,
    );
    _fetch();
  }

  Future<void> _fetch() async {
    // API Binding removed for re-binding
    if (mounted) setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1F1F1),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: const Color(0xFF26A69A),
        title: const Text(
          'Enquiry Details',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w500,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          // Custom Tab Bar Container
          Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: TabBar(
              controller: _tabController,
              indicator: BoxDecoration(
                color: const Color(0xFF1B7BBC),
                borderRadius: BorderRadius.circular(8),
              ),
              labelColor: Colors.white,
              unselectedLabelColor: const Color(0xFF26A69A),
              labelStyle: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 13,
              ),
              unselectedLabelStyle: const TextStyle(
                fontWeight: FontWeight.normal,
                fontSize: 13,
              ),
              tabs: [
                _buildTab('Overview', 0),
                _buildTab('Summary', 1),
                _buildTab('Timeline', 2),
              ],
            ),
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                EnquiryOverviewDetailView(lead: widget.lead),
                EnquirySummaryTab(
                  lead: widget.lead,
                  callSummaryData: _callSummaryData,
                  isLoading: _isLoading,
                  selectedStatus: widget.status,
                ),
                EnquiryTimelineTab(
                  lead: widget.lead,
                  timelineData: _timelineData,
                  isLoading: _isLoading,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTab(String text, int index) {
    bool isSelected = _tabController.index == index;
    return Tab(
      child: Container(
        width: double.infinity,
        height: 50,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: isSelected ? Colors.transparent : Colors.grey.shade300,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          text,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: isSelected ? Colors.white : const Color(0xFF26A69A),
          ),
        ),
      ),
    );
  }
}
