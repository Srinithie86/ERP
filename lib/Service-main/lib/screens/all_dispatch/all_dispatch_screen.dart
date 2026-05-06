import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:service_ticket/core/size_utils.dart';
import '../../Widgets/app_status_bar_wrapper.dart';
import '../../services/api_service.dart';
import '../../models/dispatch_model.dart';
import 'all_dispatch_card.dart';

class AllDispatchScreen extends StatefulWidget {
  const AllDispatchScreen({super.key});

  @override
  State<AllDispatchScreen> createState() => _AllDispatchScreenState();
}

class _AllDispatchScreenState extends State<AllDispatchScreen> {
  bool _isLoading = true;
  List<DispatchItem> _shipments = [];
  int _totalCount = 0;
  int _receivedCount = 0;
  DateTime? _selectedDate;

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    // Only show full-screen loading if we have no items to show
    if (_shipments.isEmpty) {
      setState(() => _isLoading = true);
    }

    try {
      String? formattedDate;
      if (_selectedDate != null) {
        formattedDate = DateFormat('yyyy-MM-dd').format(_selectedDate!);
      }

      final response = await ApiService.getDispatchData(date: formattedDate);
      if (response != null) {
        final dispatchResponse = DispatchResponse.fromJson(response);
        setState(() {
          _shipments = dispatchResponse.data;
          _totalCount = dispatchResponse.total;
          _receivedCount = _shipments
              .where((item) => item.t2.isNotEmpty)
              .length;
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint("Error fetching dispatch data: $e");
      setState(() => _isLoading = false);
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF2E4CB9),
              onPrimary: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
      _fetchData();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: AppStatusBarWrapper(
        child: SafeArea(
          top: false,
          bottom: false,
          child: Column(
            children: [
              // Header
              Padding(
                padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 8.h),
                child: Row(
                  children: [
                    InkWell(
                      onTap: () => Navigator.pop(context),
                      borderRadius: BorderRadius.circular(20.r),
                      child: Padding(
                        padding: EdgeInsets.all(4.r),
                        child: Icon(
                          Icons.arrow_back,
                          size: 22.sp,
                          color: const Color(0xFF2E4CB9),
                        ),
                      ),
                    ),
                    SizedBox(width: 8.w),
                    Text(
                      'All Shipments',
                      style: TextStyle(
                        fontSize: 20.sp,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF2E4CB9),
                      ),
                    ),
                    const Spacer(),
                    InkWell(
                      onTap: () => _selectDate(context),
                      child: Container(
                        padding: EdgeInsets.all(8.r),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF1F5F9),
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                        child: Icon(
                          Icons.calendar_month_outlined,
                          color: const Color(0xFF2E4CB9),
                          size: 20.sp,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              if (_selectedDate != null)
                Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: 16.w,
                    vertical: 4.h,
                  ),
                  child: Row(
                    children: [
                      Text(
                        "Showing for: ${DateFormat('dd/MM/yyyy').format(_selectedDate!)}",
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: Colors.grey.shade600,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      SizedBox(width: 8.w),
                      InkWell(
                        onTap: () {
                          setState(() => _selectedDate = null);
                          _fetchData();
                        },
                        child: Icon(
                          Icons.close,
                          size: 14.sp,
                          color: Colors.red,
                        ),
                      ),
                    ],
                  ),
                ),

              Expanded(
                child: _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : RefreshIndicator(
                        onRefresh: _fetchData,
                        child: _buildList(),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildList() {
    // Pre-flatten the list for performance
    final flattened = _shipments.expand((item) {
      if (item.t2.isEmpty) {
        return [
          {'t1': item.t1, 't2': null}
        ];
      } else {
        return item.t2.map((parcel) => {'t1': item.t1, 't2': parcel});
      }
    }).toList();

    if (flattened.isEmpty) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 0),
            child: _buildSummary(),
          ),
          SizedBox(height: 100.h),
          Center(
            child: Text(
              "No shipments found",
              style: TextStyle(fontSize: 16.sp, color: Colors.grey),
            ),
          ),
        ],
      );
    }

    return ListView.builder(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 20.h),
      itemCount: flattened.length + 1, // +1 for the summary box
      itemBuilder: (context, index) {
        if (index == 0) {
          return Padding(
            padding: EdgeInsets.only(bottom: 24.h),
            child: _buildSummary(),
          );
        }

        final item = flattened[index - 1];
        return AllDispatchCard(
          t1: item['t1'] as T1,
          t2: item['t2'] as T2?,
        );
      },
    );
  }

  Widget _buildSummary() {
    return Row(
      children: [
        Expanded(
          child: _SummaryBox(
            count: '$_totalCount',
            label: 'TOTAL',
            colors: const [Color(0xFF1B8A35), Color(0xFF0F6122)],
          ),
        ),
        SizedBox(width: 14.w),
        Expanded(
          child: _SummaryBox(
            count: '$_receivedCount',
            label: 'RECEIVED',
            colors: const [Color(0xFFE55767), Color(0xFFB9424F)],
          ),
        ),
      ],
    );
  }
}

class _SummaryBox extends StatelessWidget {
  const _SummaryBox({
    required this.count,
    required this.label,
    required this.colors,
  });

  final String count;
  final String label;
  final List<Color> colors;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 90.h,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: colors,
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        borderRadius: BorderRadius.circular(10.r),
        boxShadow: [
          BoxShadow(
            color: colors.last.withValues(alpha: 0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            count,
            style: TextStyle(
              fontSize: 26.sp,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
          SizedBox(height: 2.h),
          Text(
            label,
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}
