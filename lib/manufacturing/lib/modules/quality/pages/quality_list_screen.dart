import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter/material.dart';
import '../models/quality_model.dart';
import '../widgets/quality_widgets.dart';
import 'quality_detail_screen.dart';

class QualityListScreen extends StatefulWidget {
  const QualityListScreen({super.key});

  @override
  State<QualityListScreen> createState() => _QualityListScreenState();
}

class _QualityListScreenState extends State<QualityListScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  final List<QualityItem> todayProducts = [
    QualityItem(
      productName: 'Solar panel 400w mono',
      productId: 'P001246',
      batchId: 'B006987',
      productCode: 'PC06987',
      date: '21 April 2026',
      quantityBadge: '04',
    ),
    QualityItem(
      productName: 'Solar street light 60W',
      productId: 'P001246',
      batchId: 'B006987',
      productCode: 'PC06987',
      date: '21 April 2026',
      quantityBadge: '04',
    ),
    QualityItem(
      productName: 'Solar street light 60W',
      productId: 'P001246',
      batchId: 'B006987',
      productCode: 'PC06987',
      date: '21 April 2026',
      quantityBadge: '04',
    ),
  ];

  final List<QualityItem> yesterdayProducts = [
    QualityItem(
      productName: 'Solar panel 400w mono',
      productId: 'P001246',
      batchId: 'B006987',
      productCode: 'PC06987',
      date: '21 April 2026',
      quantityBadge: '04',
    ),
    QualityItem(
      productName: 'Solar street light 60W',
      productId: 'P001246',
      batchId: 'B006987',
      productCode: 'PC06987',
      date: '21 April 2026',
      quantityBadge: '04',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            TabBar(
              controller: _tabController,
              labelColor: Colors.black,
              unselectedLabelColor: Colors.grey,
              indicatorColor: const Color(0xFF26A69A),
              indicatorWeight: 3,
              indicatorSize: TabBarIndicatorSize.label,
              labelStyle: TextStyle(fontWeight: FontWeight.bold),
              tabs: const [
                Tab(text: 'All'),
                Tab(text: 'Failed'),
                Tab(text: 'Passed'),
                Tab(text: 'Checked'),
              ],
            ),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildProductList(),
                  Center(child: Text('Failed Products')),
                  Center(child: Text('Passed Products')),
                  Center(child: Text('Checked Products')),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProductList() {
    return ListView(
      padding: EdgeInsets.symmetric(vertical: 16.h),
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
          child: Text(
            'Product received today',
            style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w500),
          ),
        ),
        ...todayProducts.map((item) => QualityProductCard(
          item: item,
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => QualityDetailScreen(item: item),
            ),
          ),
        )),
        SizedBox(height: 16.h),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
          child: Text(
            'Product received Yesterday',
            style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w500),
          ),
        ),
        ...yesterdayProducts.map((item) => QualityProductCard(
          item: item,
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => QualityDetailScreen(item: item),
            ),
          ),
        )),
      ],
    );
  }
}
