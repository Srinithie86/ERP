import 'package:flutter/material.dart';
import '../../../../core/app_theme.dart';
import '../bom_model.dart';
import '../bom_api_service.dart';
import '../widgets/bom_widgets.dart';
import '../widgets/bom_bottom_sheets.dart';
import 'bom_detail_page.dart';

class BomListPage extends StatefulWidget {
  const BomListPage({super.key});

  @override
  State<BomListPage> createState() => _BomListPageState();
}

class _BomListPageState extends State<BomListPage> {
  String _search = '';
  String _filter = 'All';
  List<BomItem> _boms = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchBoms();
  }

  Future<void> _fetchBoms() async {
    setState(() => _isLoading = true);
    final list = await BomApiService.fetchBoms();
    if (mounted) {
      setState(() {
        _boms = list;
        _isLoading = false;
      });
    }
  }

  void _openCreateBom() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => CreateBomBottomSheet(
        onCreateBom: (productName, category, version) {
          Navigator.pop(context);
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            backgroundColor: Colors.transparent,
            builder: (_) => AddMaterialsBottomSheet(
              productName: productName,
              category: category,
              version: version,
              onBomCreated: (newBom) {
                setState(() {
                  _boms.add(newBom);
                });
              },
            ),
          );
        },
      ),
    );
  }

  void _updateBom(BomItem updatedBom) {
    setState(() {
      final index = _boms.indexWhere((b) => b.id == updatedBom.id);
      if (index != -1) {
        _boms[index] = updatedBom;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context);
    final sw = mq.size.width;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          _buildTopBar(sw),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator(color: bomTeal))
                : RefreshIndicator(
                    onRefresh: _fetchBoms,
                    color: bomTeal,
                    child: SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: EdgeInsets.all(sw * 0.05),
                      child: Column(
                        children: [
                          _buildFilters(sw),
                          SizedBox(height: sw * 0.04),
                          if (_filteredBoms().isEmpty)
                            Padding(
                              padding: EdgeInsets.only(top: sw * 0.2),
                              child: Text('No BOMs found',
                                  style: TextStyle(
                                      color: AppColors.textSecondary)),
                            ),
                          ..._filteredBoms().map(
                            (b) => Padding(
                              padding: EdgeInsets.only(bottom: sw * 0.03),
                              child: BomSummaryCard(
                                bom: b,
                                onTap: () => Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => BomDetailPage(
                                      bom: b,
                                      onBomUpdated: _updateBom,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
          ),
          _buildAddButton(sw),
        ],
      ),
    );
  }

  Widget _buildTopBar(double sw) => Container(
        color: bomTeal,
        padding: EdgeInsets.fromLTRB(sw * 0.04, 0, sw * 0.04, sw * 0.03),
        child: Column(
          children: [
            SizedBox(height: sw * 0.03),
            TextField(
              onChanged: (v) => setState(() => _search = v),
              style:
                  TextStyle(fontSize: sw * 0.035, color: AppColors.textPrimary),
              decoration: InputDecoration(
                hintText: 'Search product name or BOM ID...',
                hintStyle: TextStyle(fontSize: sw * 0.035),
                prefixIcon: Icon(Icons.search,
                    size: sw * 0.045, color: AppColors.textHint),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(sw * 0.025),
                  borderSide: BorderSide.none,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(sw * 0.025),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(sw * 0.025),
                  borderSide: const BorderSide(color: Colors.white, width: 1.5),
                ),
                contentPadding: EdgeInsets.symmetric(vertical: sw * 0.025),
              ),
            ),
          ],
        ),
      );

  Widget _buildFilters(double sw) => SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: ['All', 'Active', 'Draft', 'Archived']
              .map(
                (f) => Padding(
                  padding: EdgeInsets.only(right: sw * 0.02),
                  child: GestureDetector(
                    onTap: () => setState(() => _filter = f),
                    child: Container(
                      padding: EdgeInsets.symmetric(
                          horizontal: sw * 0.04, vertical: sw * 0.02),
                      decoration: BoxDecoration(
                        color: _filter == f ? bomTeal : AppColors.surface,
                        borderRadius: BorderRadius.circular(sw * 0.05),
                        border: Border.all(
                          color: _filter == f ? bomTeal : AppColors.border,
                        ),
                      ),
                      child: Text(
                        f,
                        style: TextStyle(
                          fontSize: sw * 0.032,
                          fontWeight: FontWeight.w600,
                          color: _filter == f
                              ? Colors.white
                              : AppColors.textSecondary,
                        ),
                      ),
                    ),
                  ),
                ),
              )
              .toList(),
        ),
      );

  List<BomItem> _filteredBoms() {
    var list = _boms;
    if (_search.isNotEmpty) {
      list = list
          .where((b) =>
              b.productName.toLowerCase().contains(_search.toLowerCase()))
          .toList();
    }
    if (_filter != 'All') {
      list = list.where((b) => b.status == _filter.toLowerCase()).toList();
    }
    return list;
  }

  Widget _buildAddButton(double sw) => Container(
        color: AppColors.surface,
        padding: EdgeInsets.fromLTRB(
          sw * 0.04,
          sw * 0.04,
          sw * 0.04,
          sw * 0.04 + MediaQuery.of(context).viewPadding.bottom,
        ),
        child: SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: _openCreateBom,
            style: ElevatedButton.styleFrom(
              backgroundColor: bomTeal,
              foregroundColor: Colors.white,
            ),
            icon: Icon(Icons.add, size: sw * 0.045),
            label:
                Text('Create New BOM', style: TextStyle(fontSize: sw * 0.035)),
          ),
        ),
      );
}
