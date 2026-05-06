import 'package:flutter/material.dart';
import 'package:service_ticket/core/size_utils.dart';
import '../../Widgets/app_status_bar_wrapper.dart';
import '../../services/api_service.dart';
import '../../core/app_colors.dart';

class EvaluationScreen extends StatefulWidget {
  const EvaluationScreen({super.key});

  @override
  State<EvaluationScreen> createState() => _EvaluationScreenState();
}

class _EvaluationScreenState extends State<EvaluationScreen> {
  List<dynamic> _evaluationList = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchEvaluationData();
  }

  Future<void> _fetchEvaluationData() async {
    try {
      final response = await ApiService.getEvaluationReport();
      if (mounted) {
        if (response != null && response['error'] == false) {
          setState(() {
            _evaluationList = response['summary'] ?? [];
            _isLoading = false;
          });
        } else {
          setState(() => _isLoading = false);
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig.init(context);

    return Scaffold(
      backgroundColor: Colors.white,
      body: AppStatusBarWrapper(
        child: Column(
          children: [
            // Custom App Bar
            Container(
              padding: EdgeInsets.only(
                left: 8.w,
                right: 16.w,
                bottom: 12.h,
                top: 4.h,
              ),
              decoration: const BoxDecoration(color: AppColors.primary),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  IconButton(
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    icon: Icon(
                      Icons.arrow_back,
                      color: Colors.white,
                      size: 24.sp,
                    ),
                    onPressed: () => Navigator.pop(context),
                  ),
                  SizedBox(width: 12.w),
                  Text(
                    'Evaluation',
                    style: TextStyle(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),

            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _evaluationList.isEmpty
                      ? const Center(child: Text("No evaluation data available"))
                      : ListView.builder(
                          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
                          physics: const BouncingScrollPhysics(),
                          itemCount: _evaluationList.length,
                          itemBuilder: (context, index) {
                            final item = _evaluationList[index];
                            final rank = int.tryParse(item['rank']?.toString() ?? '') ?? (index + 1);
                            final name = item['engineer_name']?.toString() ?? 'Unknown';
                            final assigned = int.tryParse(item['total']?.toString() ?? '0') ?? 0;
                            final completed = int.tryParse(item['status_4_total']?.toString() ?? '0') ?? 0;
                            final pending = assigned - completed;
                            final percentage = assigned > 0 ? (completed / assigned * 100).toStringAsFixed(0) : "0";
                            final rating = double.tryParse(item['average_rating']?.toString() ?? '0') ?? 0.0;

                            if (rank == 1) {
                              return Column(
                                children: [
                                  _buildTopPerformerCard(
                                    name: name,
                                    assigned: assigned,
                                    completed: completed,
                                    percentage: percentage,
                                    rating: rating,
                                  ),
                                  SizedBox(height: 20.h),
                                ],
                              );
                            }

                            return Column(
                              children: [
                                _buildRankingCard(
                                  rank: rank,
                                  name: name,
                                  assigned: assigned,
                                  completed: completed,
                                  pending: pending,
                                  rating: rating,
                                  showTrophy: rank <= 3,
                                  trophyColor: rank == 2 ? Colors.grey[400]! : Colors.orange[400]!,
                                  iconType: rank > 3 ? 'progress' : 'trophy',
                                ),
                                SizedBox(height: 12.h),
                              ],
                            );
                          },
                        ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopPerformerCard({
    required String name,
    required int assigned,
    required int completed,
    required String percentage,
    required double rating,
  }) {
    return Container(
      width: double.infinity,
      height: 160.h,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF5E81F4), Color(0xFF3458D1)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // Top Performer Badge (Top-Left)
          Positioned(
            top: 0,
            left: 0,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 6.h),
              decoration: BoxDecoration(
                color: const Color(0xFFFF9800),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(12.r),
                  bottomRight: Radius.circular(12.r),
                ),
              ),
              child: Text(
                'TOP PERFORMER',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 9.sp,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 0.5,
                ),
              ),
            ),
          ),

          Padding(
            padding: EdgeInsets.all(16.r),
            child: Row(
              children: [
                // Rank Badge Section
                Container(
                  width: 54.w,
                  height: 54.w,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.orange[300]!, width: 2.5),
                  ),
                  child: Center(
                    child: Text(
                      '1st',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18.sp,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 20.w),

                // Info & Stats Section
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20.sp,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      SizedBox(height: 4.h),
                      Row(
                        children: [
                          Icon(Icons.star_rounded, color: Colors.amber[300], size: 16.sp),
                          SizedBox(width: 4.w),
                          Text(
                            rating.toStringAsFixed(1),
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 14.h),
                      Row(
                        children: [
                          Expanded(
                            child: _buildTopStat(
                              'Assigned',
                              '$assigned Tasks',
                              Colors.yellow[400]!,
                            ),
                          ),
                          Expanded(
                            child: _buildTopStat(
                              'Completed',
                              '$completed Tasks',
                              Colors.greenAccent[400]!,
                            ),
                          ),
                          Expanded(
                            child: _buildTopStat(
                              'Percentage',
                              '$percentage%',
                              Colors.greenAccent[100]!,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Trophy Animated GIF
                Padding(
                  padding: EdgeInsets.only(left: 10.w),
                  child: Image.asset(
                    'assets/trophy.gif.gif',
                    width: 70.sp,
                    height: 70.sp,
                    fit: BoxFit.contain,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopStat(String label, String value, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withOpacity(0.9),
            fontSize: 10.sp,
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: 4.h),
        Text(
          value,
          style: TextStyle(
            color: color,
            fontSize: 13.sp,
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    );
  }

  Widget _buildRankingCard({
    required int rank,
    required String name,
    required int assigned,
    required int completed,
    required int pending,
    required double rating,
    bool showTrophy = false,
    Color trophyColor = Colors.grey,
    String iconType = 'trophy',
  }) {
    return Container(
      padding: EdgeInsets.all(12.r),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          color: AppColors.primary.withOpacity(0.4),
          width: 1.2,
        ),
      ),
      child: Row(
        children: [
          // Rank Badge
          Container(
            width: 32.w,
            height: 32.w,
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.85),
              shape: BoxShape.circle,
              border: Border.all(color: Colors.amber, width: 1),
            ),
            child: Center(
              child: Text(
                '$rank',
                style: TextStyle(
                  color: Colors.amber,
                  fontSize: 12.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          SizedBox(width: 16.w),

          // Employee Info & Stats
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFF1F2937),
                      ),
                    ),
                    Row(
                      children: [
                        Icon(Icons.star_rounded, color: Colors.amber[700], size: 15.sp),
                        SizedBox(width: 3.w),
                        Text(
                          rating.toStringAsFixed(1),
                          style: TextStyle(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w800,
                            color: const Color(0xFF1F2937),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                SizedBox(height: 10.h),
                Row(
                  children: [
                    Expanded(
                      child: _buildListStat(
                        'Assigned',
                        '$assigned Tasks',
                        Colors.yellow[800]!,
                      ),
                    ),
                    Expanded(
                      child: _buildListStat(
                        'Completed',
                        '$completed Tasks',
                        Colors.green[600]!,
                      ),
                    ),
                    Expanded(
                      child: _buildListStat(
                        'Pending',
                        '$pending Tasks',
                        Colors.red[600]!,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Right Icon Section
          if (showTrophy)
            Icon(Icons.emoji_events, color: trophyColor, size: 45.sp)
          else if (iconType == 'progress')
            _buildProgressIcon(),
        ],
      ),
    );
  }

  Widget _buildListStat(String label, String value, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: const Color(0xFF4B5563),
            fontSize: 10.sp,
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: 4.h),
        Text(
          value,
          style: TextStyle(
            color: color,
            fontSize: 12.sp,
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    );
  }

  Widget _buildProgressIcon() {
    return Stack(
      alignment: Alignment.center,
      children: [
        Icon(Icons.settings, color: Colors.teal[300], size: 32.sp),
        Positioned(
          top: 0,
          right: 0,
          child: Icon(
            Icons.arrow_upward,
            color: Colors.greenAccent[400],
            size: 14.sp,
          ),
        ),
        Positioned(
          bottom: 0,
          right: 0,
          child: Icon(
            Icons.access_time_filled,
            color: Colors.red[400],
            size: 14.sp,
          ),
        ),
      ],
    );
  }
}
