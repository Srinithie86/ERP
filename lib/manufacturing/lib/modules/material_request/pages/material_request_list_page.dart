import 'package:flutter/material.dart';
import '../../../core/app_theme.dart';
import '../material_request_model.dart';
import '../widgets/material_request_widgets.dart';
import '../widgets/material_request_cards.dart';
import 'material_request_detail_page.dart';
import 'material_request_response_page.dart';
import 'material_request_create_page.dart';

class MaterialRequestListPage extends StatefulWidget {
  final bool showBack;
  const MaterialRequestListPage({super.key, this.showBack = false});

  @override
  State<MaterialRequestListPage> createState() => _MaterialRequestListPageState();
}

class _MaterialRequestListPageState extends State<MaterialRequestListPage> {
  int _tab = 0;

  List<MaterialRequest> get _intentRequests =>
      MaterialRequestSampleData.materialRequests.where((r) => r.status == 'pending').toList();

  List<MaterialRequest> get _issued =>
      MaterialRequestSampleData.materialRequests.where((r) => r.status == 'approved').toList();

  @override
  Widget build(BuildContext context) {
    final sw = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: buildMRAppBar(
        title: 'Material Request',
        showBack: widget.showBack,
        context: context,
      ),
      body: Column(
        children: [
          Container(
            color: mrTeal,
            child: Row(
              children: [
                _TabItem(
                  label: 'Intent Request',
                  count: _intentRequests.length,
                  active: _tab == 0,
                  onTap: () => setState(() => _tab = 0),
                ),
                _TabItem(
                  label: 'Intent Issue',
                  count: _issued.length,
                  active: _tab == 1,
                  onTap: () => setState(() => _tab = 1),
                ),
              ],
            ),
          ),
          Expanded(
            child: IndexedStack(
              index: _tab,
              children: [
                ListView.builder(
                  padding: EdgeInsets.all(sw * 0.04),
                  itemCount: _intentRequests.length,
                  itemBuilder: (_, i) => Padding(
                    padding: EdgeInsets.only(bottom: sw * 0.03),
                    child: MRCard(
                      mr: _intentRequests[i],
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => MRDetailPage(mr: _intentRequests[i]),
                        ),
                      ),
                    ),
                  ),
                ),
                ListView.builder(
                  padding: EdgeInsets.all(sw * 0.04),
                  itemCount: _issued.length,
                  itemBuilder: (_, i) => Padding(
                    padding: EdgeInsets.only(bottom: sw * 0.03),
                    child: MRResponseCard(
                      mr: _issued[i],
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => MRResponseDetailPage(mr: _issued[i]),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: mrTeal,
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const MRCreatePage()),
        ),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}

class _TabItem extends StatelessWidget {
  final String label;
  final int count;
  final bool active;
  final VoidCallback onTap;

  const _TabItem({
    required this.label,
    required this.count,
    required this.active,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: active ? Colors.white : Colors.transparent,
                width: 3,
              ),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                label,
                style: TextStyle(
                  color: active ? Colors.white : Colors.white70,
                  fontWeight: active ? FontWeight.w700 : FontWeight.w500,
                  fontSize: 13,
                ),
              ),
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: active ? Colors.white24 : Colors.transparent,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '$count',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
