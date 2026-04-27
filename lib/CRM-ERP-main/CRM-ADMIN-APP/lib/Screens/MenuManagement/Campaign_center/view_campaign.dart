import 'package:flutter/material.dart';
import 'campaign_requests_store.dart';
import 'campaign_request.dart';

class ViewCampaignScreen extends StatelessWidget {
  const ViewCampaignScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const CampaignRequestScreen(initialTab: CampaignTab.viewRequests);
  }
}

class ViewCampaignContent extends StatefulWidget {
  final VoidCallback onSwitchToNewRequest;

  const ViewCampaignContent({
    super.key,
    required this.onSwitchToNewRequest,
  });

  @override
  State<ViewCampaignContent> createState() => _ViewCampaignContentState();
}

class _ViewCampaignContentState extends State<ViewCampaignContent> {
  final TextEditingController _searchController = TextEditingController();
  String _campaignType = 'All Types';
  String _approvalStatus = 'All Status';
  String _department = 'All Departments';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final requests = CampaignRequestsStore.requests;
    final filtered = requests.where((request) {
      final search = _searchController.text.trim().toLowerCase();
      final matchesSearch = search.isEmpty ||
          (request['campaignName'] ?? '').toLowerCase().contains(search) ||
          (request['requestId'] ?? '').toLowerCase().contains(search);
      final matchesType =
          _campaignType == 'All Types' || request['type'] == _campaignType;
      final matchesStatus = _approvalStatus == 'All Status' ||
          request['approvalStatus'] == _approvalStatus;
      final matchesDept = _department == 'All Departments' ||
          request['department'] == _department;
      return matchesSearch && matchesType && matchesStatus && matchesDept;
    }).toList();

    final approvedCount =
        requests.where((item) => item['approvalStatus'] == 'Approved').length;
    final pendingCount =
        requests.where((item) => item['approvalStatus'] == 'Pending').length;
    final rejectedCount =
        requests.where((item) => item['approvalStatus'] == 'Rejected').length;

    return SingleChildScrollView(
      key: const ValueKey('view-requests'),
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(0, 16, 0, 24),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: TextField(
              controller: _searchController,
              onChanged: (_) => setState(() {}),
              decoration: InputDecoration(
                hintText: 'Search by name, ID...',
                prefixIcon: const Icon(Icons.search_rounded),
                suffixIcon: IconButton(
                  onPressed: _openFilterSheet,
                  icon: const Icon(Icons.filter_alt_outlined),
                ),
                filled: true,
                fillColor: Colors.white,
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
                enabledBorder: _border(),
                focusedBorder: _border(const Color(0xFF6B7CF6), 1.4),
                border: _border(),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Expanded(
                  child: _statsCard(
                    'TOTAL CAMPAIGNS',
                    '${requests.length}',
                    const Color(0xFF6B7CF6),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _statsCard(
                    'PENDING APPROVAL',
                    '$pendingCount',
                    const Color(0xFFFF9B38),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Expanded(
                  child: _statsCard(
                    'APPROVED',
                    '$approvedCount',
                    const Color(0xFF45C782),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _statsCard(
                    'REJECTED',
                    '$rejectedCount',
                    const Color(0xFFF45050),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: _requestsCard(filtered),
          ),
        ],
      ),
    );
  }

  Widget _statsCard(String title, String value, Color accentColor) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 14,
            offset: const Offset(0, 8),
          ),
        ],
        border: Border(left: BorderSide(color: accentColor, width: 4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Color(0xFF60749A),
              fontSize: 13,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w900,
              color: Color(0xFF1D3557),
            ),
          ),
        ],
      ),
    );
  }

  Widget _requestsCard(List<Map<String, String>> requests) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 14,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Campaign Requests',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w900,
              color: Color(0xFF1D3557),
            ),
          ),
          const SizedBox(height: 16),
          if (requests.isEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFE),
                borderRadius: BorderRadius.circular(18),
              ),
              child: const Text(
                'No campaign requests found for the selected filters.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF5A6B86),
                ),
              ),
            )
          else
            ...requests.map(_requestRow),
        ],
      ),
    );
  }

  Widget _requestRow(Map<String, String> request) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF9FBFF),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE3EAF6)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            request['requestId'] ?? '',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w900,
              color: Color(0xFF1D3557),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            request['campaignName'] ?? '',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: Color(0xFF23395B),
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(child: _infoBlock('TYPE', request['type'] ?? '')),
              Expanded(
                child: _infoBlock('REQUESTED BY', request['requestedBy'] ?? ''),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _infoBlock('DEPARTMENT', request['department'] ?? ''),
              ),
              Expanded(
                child: _infoBlock('START DATE', request['startDate'] ?? ''),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              _tag(
                request['priority'] ?? '',
                (request['priority'] ?? '') == 'Urgent'
                    ? const Color(0xFFFDE2E2)
                    : const Color(0xFFE8EDF4),
                (request['priority'] ?? '') == 'Urgent'
                    ? const Color(0xFFE65454)
                    : const Color(0xFF596D89),
              ),
              const SizedBox(width: 10),
              _tag(
                request['approvalStatus'] ?? '',
                (request['approvalStatus'] ?? '') == 'Approved'
                    ? const Color(0xFFDDF7E8)
                    : const Color(0xFFFFE9C7),
                (request['approvalStatus'] ?? '') == 'Approved'
                    ? const Color(0xFF21965D)
                    : const Color(0xFFDB8B00),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: () => _showCampaignDetails(request),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF6B7CF6),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    minimumSize: const Size.fromHeight(46),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text('View'),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: ElevatedButton(
                  onPressed: () => _deleteRequest(request['requestId'] ?? ''),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFF34D4D),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    minimumSize: const Size.fromHeight(46),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text('Delete'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _infoBlock(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(right: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w800,
              color: Color(0xFF6D81A4),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Color(0xFF23395B),
            ),
          ),
        ],
      ),
    );
  }

  Widget _tag(String text, Color bg, Color fg) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        text.toUpperCase(),
        style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: fg),
      ),
    );
  }

  OutlineInputBorder _border([Color color = const Color(0xFFD8E1EF), double width = 1]) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(16),
      borderSide: BorderSide(color: color, width: width),
    );
  }

  void _deleteRequest(String requestId) {
    setState(() {
      CampaignRequestsStore.delete(requestId);
    });
    _showMessage('Request deleted');
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  void _showCampaignDetails(Map<String, String> request) {
    showDialog<void>(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxHeight: 640),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(18, 20, 18, 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Expanded(
                      child: Text(
                        'Campaign Details',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w900,
                          color: Color(0xFF1D3557),
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close_rounded),
                    ),
                  ],
                ),
                Container(height: 1, color: const Color(0xFFE0E7F2)),
                const SizedBox(height: 12),
                Expanded(
                  child: ListView(
                    children: [
                      _detailRow('Request ID:', request['requestId'] ?? ''),
                      _detailRow('Request Date:', request['requestDate'] ?? ''),
                      _detailRow('Requested By:', request['requestedBy'] ?? ''),
                      _detailRow('Department:', request['department'] ?? ''),
                      _detailRow(
                        'Campaign Name:',
                        request['campaignName'] ?? '',
                        emphasize: true,
                      ),
                      _detailRow('Campaign Type:', request['type'] ?? ''),
                      _detailRow(
                        'Target Audience:',
                        request['targetAudience'] ?? '',
                      ),
                      _detailRow(
                        'Target Location:',
                        request['targetLocation'] ?? '',
                      ),
                      _detailRow('Purpose:', request['purpose'] ?? ''),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _detailRow(String label, String value, {bool emphasize = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Color(0xFFF0F3F8))),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 130,
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w800,
                color: Color(0xFF334E73),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 15,
                fontWeight: emphasize ? FontWeight.w900 : FontWeight.w500,
                color: const Color(0xFF1F3555),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _openFilterSheet() {
    String tempType = _campaignType;
    String tempStatus = _approvalStatus;
    String tempDepartment = _department;

    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Container(
          padding: const EdgeInsets.fromLTRB(20, 18, 20, 26),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 46,
                  height: 5,
                  decoration: BoxDecoration(
                    color: const Color(0xFFD8E1EF),
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
              ),
              const SizedBox(height: 18),
              const Text(
                'Filter Requests',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900),
              ),
              const SizedBox(height: 16),
              _sheetDropdown(
                label: 'Campaign Type',
                value: tempType,
                items: const ['All Types', 'Social Media', 'Email', 'SMS Campaign'],
                onChanged: (value) {
                  if (value != null) setModalState(() => tempType = value);
                },
              ),
              const SizedBox(height: 14),
              _sheetDropdown(
                label: 'Approval Status',
                value: tempStatus,
                items: const ['All Status', 'Approved', 'Pending', 'Rejected'],
                onChanged: (value) {
                  if (value != null) setModalState(() => tempStatus = value);
                },
              ),
              const SizedBox(height: 14),
              _sheetDropdown(
                label: 'Department',
                value: tempDepartment,
                items: const ['All Departments', 'Marketing', 'Sales', 'Operations'],
                onChanged: (value) {
                  if (value != null) setModalState(() => tempDepartment = value);
                },
              ),
              const SizedBox(height: 18),
              Row(
                children: [
                  Expanded(
                    child: _sheetButton('Apply', const Color(0xFF6B7CF6), () {
                      setState(() {
                        _campaignType = tempType;
                        _approvalStatus = tempStatus;
                        _department = tempDepartment;
                      });
                      Navigator.pop(context);
                    }),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _sheetButton('Clear', const Color(0xFF7D8DA6), () {
                      setState(() {
                        _campaignType = 'All Types';
                        _approvalStatus = 'All Status';
                        _department = 'All Departments';
                      });
                      Navigator.pop(context);
                    }),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _sheetDropdown({
    required String label,
    required String value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.w700)),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          initialValue: value,
          onChanged: onChanged,
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.white,
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: Color(0xFFD8E1EF)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: Color(0xFF6B7CF6), width: 1.4),
            ),
          ),
          items: items
              .map((item) => DropdownMenuItem(value: item, child: Text(item)))
              .toList(),
        ),
      ],
    );
  }

  Widget _sheetButton(String label, Color color, VoidCallback onPressed) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        minimumSize: const Size.fromHeight(50),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
      child: Text(label),
    );
  }
}
