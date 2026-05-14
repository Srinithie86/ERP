import 'package:flutter/material.dart';
import '../../Services/deals_service.dart';
import '../../Services/preference_service.dart';
import 'package:intl/intl.dart';

class DealsScreen extends StatefulWidget {
  final VoidCallback? onBack;
  const DealsScreen({super.key, this.onBack});

  @override
  State<DealsScreen> createState() => _DealsScreenState();
}

class _DealsScreenState extends State<DealsScreen> {
  bool _isLoading = false;
  int _selectedType = 0; // 0: Active, 1: Won, 2: Lost
  Map<String, dynamic> _summary = {
    'active_deals': 0,
    'total_deal_won': 0,
    'total_deal_lost': 0
  };
  List<dynamic> _activeDeals = [];
  List<dynamic> _wonDeals = [];
  List<dynamic> _lostDeals = [];
  String? _selectedDate;

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData({String? date}) async {
    if (!mounted) return;
    setState(() => _isLoading = true);

    try {
      final response = await DealsService.fetchDeals(date: date);
      if (mounted) {
        if (response['error'] == false && response['data'] != null) {
          final data = response['data'];
          setState(() {
            _summary = data['summary'] ?? _summary;
            _activeDeals = data['active_deals_list'] ?? [];
            _wonDeals = data['won_deals_list'] ?? [];
            _lostDeals = data['lost_deals_list'] ?? [];
          });
        }
      }
    } catch (e) {
      debugPrint("Error fetching deals: $e");
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  List<dynamic> get _displayList {
    if (_selectedType == 0) return _activeDeals;
    if (_selectedType == 1) return _wonDeals;
    return _lostDeals;
  }

  String get _listTitle {
    if (_selectedType == 0) return 'Active Deals list';
    if (_selectedType == 1) return 'Won Deals list';
    return 'Lost Deals list';
  }

  @override
  Widget build(BuildContext context) {
    const Color primaryPurple = Color(0xFF26A69A);
    final Size size = MediaQuery.of(context).size;
    final double screenWidth = size.width;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
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
          'Deals',
          style: TextStyle(
            color: Colors.white,
            fontSize: screenWidth * 0.05,
            fontWeight: FontWeight.w500,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(
              Icons.calendar_month_outlined,
              color: Colors.white,
            ),
            onPressed: () async {
              final DateTime? picked = await showDatePicker(
                context: context,
                initialDate: DateTime.now(),
                firstDate: DateTime(2000),
                lastDate: DateTime(2101),
              );
              if (picked != null) {
                final formattedDate = DateFormat('dd-MM-yyyy').format(picked);
                setState(() => _selectedDate = formattedDate);
                _fetchData(date: formattedDate);
              }
            },
          ),
        ],
      ),
      body: _isLoading && _summary['total_deal_won'] == 0 && _summary['total_deal_lost'] == 0
          ? const Center(child: CircularProgressIndicator(color: primaryPurple))
          : RefreshIndicator(
              onRefresh: () => _fetchData(date: _selectedDate),
              color: primaryPurple,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Stack(
                      clipBehavior: Clip.none,
                      children: [
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
                        Positioned(
                          top: 20,
                          left: 16,
                          right: 16,
                          child: Row(
                            children: [
                              _buildSummaryCard(
                                "Active",
                                "Deals",
                                _summary['active_deals'].toString(),
                                _selectedType == 0 ? const Color(0xFFFCF2D5) : Colors.white,
                                const Color(0xFF2E79DA),
                                screenWidth,
                                isSelected: _selectedType == 0,
                                onTap: () => setState(() => _selectedType = 0),
                              ),
                              const SizedBox(width: 12),
                              _buildSummaryCard(
                                "Total Deal",
                                "Won",
                                _summary['total_deal_won'].toString(),
                                _selectedType == 1 ? const Color(0xFFE8F5E9) : Colors.white,
                                const Color(0xFF109B1E),
                                screenWidth,
                                isSelected: _selectedType == 1,
                                onTap: () => setState(() => _selectedType = 1),
                              ),
                              const SizedBox(width: 12),
                              _buildSummaryCard(
                                "Total Deal",
                                "Lost",
                                _summary['total_deal_lost'].toString(),
                                _selectedType == 2 ? const Color(0xFFFFEBEE) : Colors.white,
                                const Color(0xFFC66A6A),
                                screenWidth,
                                isSelected: _selectedType == 2,
                                onTap: () => setState(() => _selectedType = 2),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 100),
                    if (_selectedDate != null)
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: Row(
                          children: [
                            Text(
                              "Date: $_selectedDate",
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: primaryPurple,
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.close, size: 18),
                              onPressed: () {
                                setState(() => _selectedDate = null);
                                _fetchData();
                              },
                            )
                          ],
                        ),
                      ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Text(
                        _listTitle,
                        style: TextStyle(
                          fontSize: screenWidth * 0.045,
                          fontWeight: FontWeight.w500,
                          color: Theme.of(context).textTheme.titleMedium?.color,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    _displayList.isEmpty
                        ? Center(
                            child: Padding(
                              padding: const EdgeInsets.all(40.0),
                              child: Column(
                                children: [
                                  Icon(Icons.folder_open, size: 64, color: Colors.grey.withOpacity(0.5)),
                                  const SizedBox(height: 16),
                                  Text(
                                    "No deals found",
                                    style: TextStyle(color: Colors.grey.shade600),
                                  ),
                                ],
                              ),
                            ),
                          )
                        : ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            padding: const EdgeInsets.symmetric(horizontal: 16.0),
                            itemCount: _displayList.length,
                            itemBuilder: (context, index) {
                              final deal = _displayList[index];
                              return _buildDealCard(deal);
                            },
                          ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildDealCard(Map<String, dynamic> deal) {
    final isWon = _selectedType == 1;
    final isLost = _selectedType == 2;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                deal['customer_name'] ?? 'Unknown Customer',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: Color(0xFF1A1A1A),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: (isWon ? Colors.green : (isLost ? Colors.red : Colors.blue)).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  deal['enquiry_no'] ?? '',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: isWon ? Colors.green : (isLost ? Colors.red : Colors.blue),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          if (deal['contact_no'] != null && deal['contact_no'].toString().isNotEmpty)
            _buildInfoRow(Icons.phone, deal['contact_no'].toString()),
          if (deal['product_name'] != null && deal['product_name'].toString().isNotEmpty)
            _buildInfoRow(Icons.inventory_2_outlined, "Product: ${deal['product_name']}"),
          if (isWon && deal['won_amount'] != null)
            _buildInfoRow(Icons.payments_outlined, "Won Amount: ₹${deal['won_amount']}", color: Colors.green),
          if (isLost && deal['reason'] != null)
            _buildInfoRow(Icons.report_problem_outlined, "Reason: ${deal['reason']}", color: Colors.red),
          if (isLost && deal['quoted_amount'] != null)
            _buildInfoRow(Icons.request_quote_outlined, "Quoted: ₹${deal['quoted_amount']}"),
          const Divider(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                deal['deal_date'] ?? '',
                style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
              ),
              if (deal['remarks'] != null && deal['remarks'].toString().isNotEmpty)
                Expanded(
                  child: Text(
                    deal['remarks'],
                    textAlign: TextAlign.end,
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 12, fontStyle: FontStyle.italic),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text, {Color? color}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4.0),
      child: Row(
        children: [
          Icon(icon, size: 14, color: color ?? Colors.grey.shade600),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 13,
                color: color ?? Colors.grey.shade800,
                fontWeight: color != null ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard(
    String line1,
    String line2,
    String count,
    Color bgColor,
    Color statusColor,
    double screenWidth, {
    required VoidCallback onTap,
    bool isSelected = false,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          height: 120,
          decoration: BoxDecoration(
            color: Theme.of(context).brightness == Brightness.dark && bgColor == Colors.white
                ? Theme.of(context).cardColor
                : bgColor,
            borderRadius: BorderRadius.circular(12),
            border: isSelected ? Border.all(color: statusColor, width: 2) : null,
            boxShadow: [
              BoxShadow(
                color: isSelected ? statusColor.withOpacity(0.2) : Colors.black.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                line1,
                style: TextStyle(
                  fontSize: screenWidth * 0.035,
                  fontWeight: FontWeight.bold,
                  color: bgColor == Colors.white && Theme.of(context).brightness == Brightness.dark
                      ? Colors.white
                      : Colors.black,
                ),
              ),
              Text(
                line2,
                style: TextStyle(
                  fontSize: screenWidth * 0.035,
                  fontWeight: FontWeight.bold,
                  color: statusColor,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                count,
                style: TextStyle(
                  fontSize: screenWidth * 0.045,
                  fontWeight: FontWeight.bold,
                  color: bgColor == Colors.white && Theme.of(context).brightness == Brightness.dark
                      ? Colors.white
                      : Colors.black,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
