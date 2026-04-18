import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/warehouse_provider.dart';
import '../../widgets/common_widgets.dart';
import '../entry/stock_transfer_screen.dart';
import '../entry/stock_adjustment_screen.dart';

class StockViewScreen extends StatefulWidget {
  final String initialFilter;

  const StockViewScreen({
    super.key,
    this.initialFilter = 'All',
  });

  @override
  State<StockViewScreen> createState() => _StockViewScreenState();
}

class _StockViewScreenState extends State<StockViewScreen> {
  late String _filterVal;

  @override
  void initState() {
    super.initState();
    _filterVal = widget.initialFilter;
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<WarehouseProvider>();
    
    var items = provider.stock;
    if (_filterVal == 'Low Stock') {
      items = items.where((i) => i.isLowStock).toList();
    } else if (_filterVal != 'All') {
      items = items.where((i) => i.category == _filterVal).toList();
    }

    String title = 'Stock View';
    if (_filterVal == 'Raw Material') {
      title = 'Total Raw Material';
    } else if (_filterVal == 'Finished Goods') {
      title = 'Total FG Stock';
    } else if (_filterVal == 'Low Stock') {
      title = 'Low Stock Alerts';
    }

    return Scaffold(
      appBar: WmsAppBar(
        title: title,
        screenType: ScreenType.viewOnly,
      ),
      body: Column(
        children: [
          const ViewOnlyBanner(),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: WDropdown(
                    label: 'Filter by Category',
                    value: _filterVal,
                    items: const ['All', 'Raw Material', 'Finished Goods', 'Low Stock'],
                    onChanged: (v) => setState(() => _filterVal = v ?? 'All'),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: items.isEmpty
                ? const EmptyState(title: 'No stock found')
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: items.length,
                    itemBuilder: (context, index) {
                      final item = items[index];
                      return Card(
                        elevation: 0,
                        margin: const EdgeInsets.only(bottom: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                          side: BorderSide(color: item.isLowStock ? Colors.red.shade200 : Colors.grey.shade200, width: 1),
                        ),
                        clipBehavior: Clip.antiAlias,
                        child: Column(
                          children: [
                            Container(
                              padding: const EdgeInsets.only(left: 16, right: 16, top: 16, bottom: 16),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                border: Border(
                                  left: BorderSide(
                                    color: item.category == 'Raw Material' ? Colors.blue.shade400 : Colors.green.shade400, 
                                    width: 4
                                  ),
                                ),
                              ),
                              child: Column(
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Row(
                                        children: [
                                          Icon(
                                            item.category == 'Raw Material' ? Icons.category : Icons.inventory_2, 
                                            size: 16, 
                                            color: item.category == 'Raw Material' ? Colors.blue.shade400 : Colors.green.shade400
                                          ),
                                          const SizedBox(width: 6),
                                          Text(
                                            item.category.toUpperCase(),
                                            style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 0.5, color: Colors.grey.shade600),
                                          ),
                                        ],
                                      ),
                                      if (item.isLowStock)
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                          decoration: BoxDecoration(color: Colors.red.shade50, borderRadius: BorderRadius.circular(8)),
                                          child: Row(
                                            children: [
                                              Icon(Icons.warning_rounded, size: 12, color: Colors.red.shade700),
                                              const SizedBox(width: 4),
                                              Text('LOW STOCK', style: TextStyle(color: Colors.red.shade700, fontSize: 10, fontWeight: FontWeight.bold)),
                                            ],
                                          ),
                                        )
                                      else
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                          decoration: BoxDecoration(color: Colors.green.shade50, borderRadius: BorderRadius.circular(8)),
                                          child: Row(
                                            children: [
                                              Icon(Icons.check_circle_rounded, size: 12, color: Colors.green.shade700),
                                              const SizedBox(width: 4),
                                              Text('IN STOCK', style: TextStyle(color: Colors.green.shade700, fontSize: 10, fontWeight: FontWeight.bold)),
                                            ],
                                          ),
                                        ),
                                    ],
                                  ),
                                  const SizedBox(height: 16),
                                  Row(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      Expanded(
                                        child: Text(
                                          item.itemName,
                                          style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 18, color: Colors.black87),
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                      const SizedBox(width: 16),
                                      Column(
                                        crossAxisAlignment: CrossAxisAlignment.end,
                                        children: [
                                          Text(
                                            '${item.quantity}',
                                            style: TextStyle(
                                              fontSize: 26,
                                              fontWeight: FontWeight.w900,
                                              color: item.isLowStock ? Colors.red.shade700 : Colors.black87,
                                              height: 1.0,
                                            ),
                                          ),
                                          const SizedBox(height: 2),
                                          Text(
                                            item.unit,
                                            style: const TextStyle(fontSize: 12, color: Colors.grey, fontWeight: FontWeight.w600),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ]
                              )
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                              color: item.isLowStock ? Colors.red.shade50.withValues(alpha: 0.5) : Colors.grey.shade50,
                              child: Column(
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Row(
                                        children: [
                                          const Icon(Icons.location_on, size: 14, color: Colors.grey),
                                          const SizedBox(width: 4),
                                          Text(item.location, style: TextStyle(fontSize: 12, color: Colors.grey.shade700, fontWeight: FontWeight.w600)),
                                        ],
                                      ),
                                      Row(
                                        children: [
                                          const Icon(Icons.qr_code_2, size: 14, color: Colors.grey),
                                          const SizedBox(width: 4),
                                          Text(item.barcode, style: TextStyle(fontSize: 12, color: Colors.grey.shade700, fontWeight: FontWeight.w600)),
                                        ],
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 12),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: ClipRRect(
                                          borderRadius: BorderRadius.circular(4),
                                          child: LinearProgressIndicator(
                                            value: (item.quantity / (item.minStock * 3)).clamp(0.0, 1.0),
                                            minHeight: 6,
                                            backgroundColor: Colors.grey.shade300,
                                            valueColor: AlwaysStoppedAnimation<Color>(
                                              item.isLowStock ? Colors.red.shade400 : const Color(0xFF26A69A),
                                            ),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Text(
                                        'Min Stock: ${item.minStock}',
                                        style: TextStyle(fontSize: 10, color: Colors.grey.shade600, fontWeight: FontWeight.bold),
                                      ),
                                    ],
                                  ),
                                ]
                              ),
                            ),
                          ],
                        )
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            heroTag: 'adj',
            backgroundColor: Colors.purple,
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const StockAdjustmentScreen())),
            tooltip: 'Stock Adjustment',
            child: const Icon(Icons.tune),
          ),
          const SizedBox(height: 16),
          FloatingActionButton(
            heroTag: 'tsf',
            backgroundColor: Colors.blue,
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const StockTransferScreen())),
            tooltip: 'Stock Transfer',
            child: const Icon(Icons.swap_horiz),
          ),
        ],
      ),
    );
  }
}
