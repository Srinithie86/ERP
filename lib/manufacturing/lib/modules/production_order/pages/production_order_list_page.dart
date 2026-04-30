import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter/material.dart';
import 'package:manufacturing_erp/modules/production_order/production_order_api_service.dart';
import '../production_order_model.dart';
import '../widgets/production_order_widgets.dart';
import 'production_order_product_list_page.dart';
import 'production_order_create_page.dart';

class ProductionOrderListPage extends StatefulWidget {
  const ProductionOrderListPage({super.key});

  @override
  State<ProductionOrderListPage> createState() => _ProductionOrderListPageState();
}

 class _ProductionOrderListPageState extends State<ProductionOrderListPage> {
  final List<ProductionOrder> _orders = [];
  bool _isLoading = true;
  bool _isLoadMore = false;
  bool _hasMore = true;
  int _currentPage = 1;
  int _totalOrders = 0;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    _loadOrders();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.offset >=
            _scrollController.position.maxScrollExtent - 400 &&
        !_isLoadMore &&
        _hasMore &&
        !_isLoading) {
      _loadMore();
    }
  }

  Future<void> _loadOrders() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
      _currentPage = 1;
      _hasMore = true;
      _orders.clear();
    });

    final result = await ProductionOrderApiService.fetchProductionOrders(
        page: _currentPage, limit: 10);

    if (!mounted) return;
    setState(() {
      _orders.addAll(result.orders);
      _totalOrders = result.total;
      _isLoading = false;
      if (result.orders.length < 10) _hasMore = false;
    });
  }

  Future<void> _loadMore() async {
    if (!mounted || _isLoadMore || !_hasMore) return;
    setState(() => _isLoadMore = true);
    
    final nextPage = _currentPage + 1;
    final result = await ProductionOrderApiService.fetchProductionOrders(
        page: nextPage, limit: 10);

    if (!mounted) return;
    setState(() {
      _isLoadMore = false;
      _totalOrders = result.total;
      if (result.orders.isEmpty) {
        _hasMore = false;
      } else {
        // Filter out duplicates just in case
        final newOrders = result.orders.where((newOrd) => 
          !_orders.any((existing) => existing.id == newOrd.id)
        ).toList();
        
        if (newOrders.isEmpty && result.orders.isNotEmpty) {
          // If we got orders but all are duplicates, stop loading more to avoid infinite loop
          _hasMore = false;
        } else {
          _orders.addAll(newOrders);
          _currentPage = nextPage;
          if (result.orders.length < 10) _hasMore = false;
        }
      }
    });
  }

  String _initials(String name) {
    if (name.isEmpty) return '??';
    return name
        .trim()
        .split(' ')
        .take(2)
        .map((w) => w.isNotEmpty ? w[0].toUpperCase() : '')
        .join();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: RefreshIndicator(
        onRefresh: _loadOrders,
        color: joTeal,
        child: _isLoading
            ? const Center(child: CircularProgressIndicator(color: joTeal))
            : Column(
                children: [
                  _OrderSummaryBar(orders: _orders, totalCount: _totalOrders),
                  Expanded(
                    child: _orders.isEmpty
                        ? _buildEmptyState()
                        : ListView.builder(
                            controller: _scrollController,
                            padding: EdgeInsets.fromLTRB(12, 8, 12, 80),
                            itemCount: _orders.length + (_hasMore ? 1 : 0),
                            itemBuilder: (ctx, idx) {
                              if (idx == _orders.length) {
                                return Center(
                                  child: Padding(
                                    padding: EdgeInsets.all(12.0.w),
                                    child: const CircularProgressIndicator(
                                        color: joTeal, strokeWidth: 2),
                                  ),
                                );
                              }
                              final order = _orders[idx];
                              return _CustomerNameCard(
                                order: order,
                                initials: _initials(order.customer),
                                onTap: () async {
                                  await Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) =>
                                          ProductionOrderProductListPage(
                                        order: order,
                                        initials: _initials(order.customer),
                                        onRefresh: _loadOrders,
                                      ),
                                    ),
                                  );
                                  if (mounted) _loadOrders();
                                },
                              );
                            },
                          ),
                  ),
                ],
              ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: joTeal,
        foregroundColor: Colors.white,
        icon: Icon(Icons.add),
        label: const Text('New Order',
            style: TextStyle(fontWeight: FontWeight.w600)),
        onPressed: () async {
          final newOrder = await Navigator.push<ProductionOrder>(
            context,
            MaterialPageRoute(
                builder: (_) => const ProductionOrderCreatePage()),
          );
          if (newOrder != null && mounted) _loadOrders();
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.inventory_2_outlined,
              size: 64.sp, color: Colors.grey.shade400),
          SizedBox(height: 16.h),
          Text('No production orders found',
              style: TextStyle(color: Colors.grey.shade600, fontSize: 16.sp)),
          TextButton(
              onPressed: _loadOrders,
              child: const Text('Retry', style: TextStyle(color: joTeal))),
        ],
      ),
    );
  }
}

class _OrderSummaryBar extends StatelessWidget {
  final List<ProductionOrder> orders;
  final int totalCount;
  const _OrderSummaryBar({required this.orders, required this.totalCount});

  @override
  Widget build(BuildContext context) {
    final active =
        orders.where((o) => o.statusLabel.toLowerCase() == 'active').length;
    final pending = orders
        .where((o) =>
            o.statusLabel.toLowerCase() == 'pending' ||
            o.statusLabel.toLowerCase() == 'unknown')
        .length;

    return Container(
      margin: EdgeInsets.fromLTRB(12, 12, 12, 4),
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _StatItem(label: 'Total', value: '$totalCount', color: joTeal),
          _DividerLine(),
          _StatItem(
              label: 'Active', value: '$active', color: Colors.green.shade600),
          _DividerLine(),
          _StatItem(
              label: 'Pending',
              value: '$pending',
              color: Colors.orange.shade600),
        ],
      ),
    );
  }
}

class _DividerLine extends StatelessWidget {
  @override
  Widget build(BuildContext context) =>
      Container(height: 28.h, width: 1.w, color: Colors.grey.shade200);
}

class _StatItem extends StatelessWidget {
  final String label, value;
  final Color color;
  const _StatItem(
      {required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) => Column(
        children: [
          Text(value,
              style: TextStyle(
                  fontSize: 18.sp, fontWeight: FontWeight.w800, color: color)),
          Text(label,
              style: TextStyle(fontSize: 11.sp, color: Colors.grey.shade500)),
        ],
      );
}

class _CustomerNameCard extends StatelessWidget {
  final ProductionOrder order;
  final String initials;
  final VoidCallback onTap;

  const _CustomerNameCard({
    required this.order,
    required this.initials,
    required this.onTap,
  });

  String _fmt(DateTime? d) {
    if (d == null) return 'N/A';
    return '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.only(bottom: 10.h),
        padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 14.h),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14.r),
          border: Border.all(color: Colors.grey.shade200),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 42.w,
              height: 42.h,
              decoration: BoxDecoration(
                  color: joTealLight, shape: BoxShape.circle),
              alignment: Alignment.center,
              child: Text(
                initials,
                style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w700,
                    color: joTealDark),
              ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                   Text(
                    order.id,
                    style: TextStyle(
                      fontSize: 15.sp,
                      fontWeight: FontWeight.w800,
                      color: Colors.black87,
                    ),
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    order.customer,
                    style: TextStyle(
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w500,
                      color: Colors.grey.shade600,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 5.h),
                  Row(
                    children: [
                      Icon(Icons.calendar_today_outlined,
                          size: 12.sp, color: joTeal),
                      SizedBox(width: 4.w),
                      Expanded(
                        child: Text(
                          'Due Date: ${_fmt(order.dueDate)}',
                          style: TextStyle(
                              fontSize: 11.sp,
                              color: joTealDark,
                              fontWeight: FontWeight.w600),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  if (order.plannedCount > 0) ...[
                    SizedBox(height: 6.h),
                    ClipRRect(
                       borderRadius: BorderRadius.circular(4.r),
                      child: LinearProgressIndicator(
                        value: order.plannedCount / order.products.length,
                        backgroundColor: Colors.grey.shade200,
                        valueColor: const AlwaysStoppedAnimation(joTeal),
                        minHeight: 4,
                      ),
                    ),
                    SizedBox(height: 3.h),
                    Text(
                      '${order.plannedCount}/${order.products.length} planned',
                      style: TextStyle(fontSize: 10.sp, color: joTeal),
                    ),
                  ],
                ],
              ),
            ),
            SizedBox(width: 8.w),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                JOStatusBadge(status: order.statusLabel),
                SizedBox(height: 6.h),
                Icon(Icons.chevron_right, color: Colors.grey, size: 18.sp),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
