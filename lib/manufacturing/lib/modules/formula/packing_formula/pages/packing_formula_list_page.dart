import 'package:flutter/material.dart';
import '../../../../core/app_theme.dart';
import '../packing_formula_model.dart';
import '../packing_formula_api_service.dart';
import '../widgets/packing_formula_widgets.dart';
import '../widgets/packing_formula_bottom_sheets.dart';
import 'packing_formula_detail_page.dart';

class PackingFormulaListPage extends StatefulWidget {
  const PackingFormulaListPage({super.key});

  @override
  State<PackingFormulaListPage> createState() => _PackingFormulaListPageState();
}

class _PackingFormulaListPageState extends State<PackingFormulaListPage> {
  String _search = '';
  String _filter = 'All';
  List<PackingFormulaItem> _packingFormulas = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchPackingFormulas();
  }

  Future<void> _fetchPackingFormulas() async {
    setState(() => _isLoading = true);
    final list = await PackingFormulaApiService.fetchPackingFormulas();
    if (mounted) {
      setState(() {
        _packingFormulas = list;
        _isLoading = false;
      });
    }
  }

  void _openCreatePackingFormula() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => CreatePackingFormulaBottomSheet(
        onCreatePackingFormula: (productName, category, version) {
          Navigator.pop(context);
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            backgroundColor: Colors.transparent,
            builder: (_) => AddMaterialsBottomSheet(
              productName: productName,
              category: category,
              version: version,
              onPackingFormulaCreated: (newPackingFormula) {
                setState(() {
                  _packingFormulas.add(newPackingFormula);
                });
              },
            ),
          );
        },
      ),
    );
  }

  void _updatePackingFormula(PackingFormulaItem updatedPackingFormula) {
    setState(() {
      final index = _packingFormulas.indexWhere((b) => b.id == updatedPackingFormula.id);
      if (index != -1) {
        _packingFormulas[index] = updatedPackingFormula;
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
                ? const Center(child: CircularProgressIndicator(color: packingFormulaTeal))
                : RefreshIndicator(
                    onRefresh: _fetchPackingFormulas,
                    color: packingFormulaTeal,
                    child: SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: EdgeInsets.all(sw * 0.05),
                      child: Column(
                        children: [
                          _buildFilters(sw),
                          SizedBox(height: sw * 0.04),
                          if (_filteredPackingFormulas().isEmpty)
                            Padding(
                              padding: EdgeInsets.only(top: sw * 0.2),
                              child: Text('No Packing Formulas found',
                                  style: TextStyle(
                                      color: AppColors.textSecondary)),
                            ),
                          ..._filteredPackingFormulas().map(
                            (b) => Padding(
                              padding: EdgeInsets.only(bottom: sw * 0.03),
                              child: PackingFormulaSummaryCard(
                                packingFormula: b,
                                onTap: () => Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => PackingFormulaDetailPage(
                                      packingFormula: b,
                                      onPackingFormulaUpdated: _updatePackingFormula,
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
        color: packingFormulaTeal,
        padding: EdgeInsets.fromLTRB(sw * 0.04, 0, sw * 0.04, sw * 0.03),
        child: Column(
          children: [
            SizedBox(height: sw * 0.03),
            TextField(
              onChanged: (v) => setState(() => _search = v),
              style:
                  TextStyle(fontSize: sw * 0.035, color: AppColors.textPrimary),
              decoration: InputDecoration(
                hintText: 'Search product name or Packing Formula ID...',
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
                        color: _filter == f ? packingFormulaTeal : AppColors.surface,
                        borderRadius: BorderRadius.circular(sw * 0.05),
                        border: Border.all(
                          color: _filter == f ? packingFormulaTeal : AppColors.border,
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

  List<PackingFormulaItem> _filteredPackingFormulas() {
    var list = _packingFormulas;
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
            onPressed: _openCreatePackingFormula,
            style: ElevatedButton.styleFrom(
              backgroundColor: packingFormulaTeal,
              foregroundColor: Colors.white,
            ),
            icon: Icon(Icons.add, size: sw * 0.045),
            label:
                Text('Create New Packing Formula', style: TextStyle(fontSize: sw * 0.035)),
          ),
        ),
      );
}
