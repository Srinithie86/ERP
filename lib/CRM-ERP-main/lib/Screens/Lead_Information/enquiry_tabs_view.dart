import 'package:flutter/material.dart';
import 'overview_tab.dart';
import 'timeline_tab.dart';
import 'call_summary_tab.dart';
import 'meeting_tab.dart';
import '../../Services/lead_service.dart';
import '../../Models/follow_up_api.dart';

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
  List<dynamic> _timelineData = [];
  List<dynamic> _callSummaryData = [];
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
    setState(() => _isLoading = true);
    try {
      // Find the best ID to use for fetching
      final String leadId = (
        widget.lead['id'] ?? 
        widget.lead['cus_id'] ?? 
        widget.lead['led_id'] ?? 
        widget.lead['aid'] ?? 
        widget.lead['uid'] ?? 
        ''
      ).toString();
      
      final String leCode = (widget.lead['le_code'] ?? '').toString();

      if (leadId.isNotEmpty && leadId != 'null') {
        // Fetch history and summary from all available sources
        final results = await Future.wait([
          LeadService.fetchFollowUpHistory(leadNo: leadId),
          LeadService.fetchCallSummary(leCode),
          FollowUpApi.fetchFollowUpLeads(uid: leadId),
        ]);
        
        final history = results[0] as List<dynamic>;
        final summary = results[1] as List<dynamic>;
        final historyAll = (results[2] as List<FollowUpModel>).map((m) => m.toMap()).toList();
        
        if (mounted) {
          setState(() {
            // Use Maps and Sets to ensure absolute uniqueness by ID and by Content
            final Map<String, dynamic> uniqueSummaryMap = {};
            final Set<String> uniqueContentSet = {};
            
            // Helper to add items uniquely
            void addItem(dynamic item) {
              final String itemLeadId = (item['aid'] ?? item['bid'] ?? item['did'] ?? item['led_id'] ?? '').toString();
              bool isMatching = itemLeadId == leadId || item['led_id'].toString() == leadId;
              if (leCode.isNotEmpty) {
                isMatching = isMatching || (item['le_code']?.toString().toUpperCase() == leCode.toUpperCase() || 
                                           item['lead_code']?.toString().toUpperCase() == leCode.toUpperCase());
              }
              
              if (isMatching) {
                // 1. Check by ID (if available)
                String idKey = (item['id'] ?? item['history_id'] ?? '').toString();
                bool hasId = idKey.isNotEmpty && idKey != 'null';
                
                // 2. Check by Content (Summary + Date + Time)
                String summary = (item['call_summary'] ?? '').toString().trim();
                String date = (item['call_date'] ?? item['dtime'] ?? '').toString();
                String time = (item['call_time'] ?? '').toString();
                String contentKey = "${summary}_${date}_${time}".toLowerCase();

                // If we already have this ID or this exact content, skip it
                if (hasId && uniqueSummaryMap.containsKey(idKey)) return;
                if (summary.isNotEmpty && uniqueContentSet.contains(contentKey)) return;

                // Add to our tracking collections
                if (hasId) uniqueSummaryMap[idKey] = item;
                if (summary.isNotEmpty) uniqueContentSet.add(contentKey);
                
                // If it wasn't skipped, we want to include it in the final list
                // We use another map to collect the actual items to preserve one instance
                if (!hasId) {
                   // For items without ID, use content as the key for the map
                   uniqueSummaryMap['content_$contentKey'] = item;
                }
              }
            }

            // Process sources in order of reliability/detail
            for (var item in summary) addItem(item);
            for (var item in historyAll) addItem(item);
            for (var item in history) addItem(item);
            
            _callSummaryData = uniqueSummaryMap.values.toList();
            
            // Sort by date/time descending
            _callSummaryData.sort((a, b) {
              String dateA = (a['call_date'] ?? a['dtime'] ?? '').toString();
              String dateB = (b['call_date'] ?? b['dtime'] ?? '').toString();
              return dateB.compareTo(dateA);
            });

            // Ensure timelineData is also unique using the same logic
            final Map<String, dynamic> uniqueTimelineMap = {};
            final Set<String> timelineContentSet = {};
            final listToProcess = (historyAll.isNotEmpty ? historyAll : history);
            
            for (var item in listToProcess) {
               final String itemLeadId = (item['aid'] ?? item['bid'] ?? item['did'] ?? item['led_id'] ?? '').toString();
               if (itemLeadId == leadId || item['led_id'].toString() == leadId || 
                   (leCode.isNotEmpty && (item['le_code']?.toString().toUpperCase() == leCode.toUpperCase() || 
                                         item['lead_code']?.toString().toUpperCase() == leCode.toUpperCase()))) {
                 
                 String idKey = (item['id'] ?? item['history_id'] ?? '').toString();
                 String summary = (item['call_summary'] ?? '').toString().trim();
                 String date = (item['call_date'] ?? item['dtime'] ?? '').toString();
                 String contentKey = "${summary}_$date".toLowerCase();

                 bool hasId = idKey.isNotEmpty && idKey != 'null';
                 if (hasId && uniqueTimelineMap.containsKey(idKey)) continue;
                 if (summary.isNotEmpty && timelineContentSet.contains(contentKey)) continue;

                 if (hasId) uniqueTimelineMap[idKey] = item;
                 else uniqueTimelineMap['content_$contentKey'] = item;
                 
                 if (summary.isNotEmpty) timelineContentSet.add(contentKey);
               }
            }
            _timelineData = uniqueTimelineMap.values.toList();
            _timelineData.sort((a, b) {
              String dateA = (a['call_date'] ?? a['dtime'] ?? '').toString();
              String dateB = (b['call_date'] ?? b['dtime'] ?? '').toString();
              return dateB.compareTo(dateA);
            });
          });
        }
      } else {
        debugPrint(">>> WARNING: No valid leadId found in widget.lead!");
      }
    } catch (e) {
      debugPrint("Error fetching enquiry details: $e");
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
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
