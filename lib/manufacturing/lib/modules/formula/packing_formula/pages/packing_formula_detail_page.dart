import 'package:flutter/material.dart';
import '../../../../core/app_theme.dart';
import '../../../../core/shared_widgets.dart';
import '../packing_formula_model.dart';
import '../packing_formula_api_service.dart';
import '../widgets/packing_formula_widgets.dart';
import '../widgets/packing_formula_bottom_sheets.dart';

class PackingFormulaDetailPage extends StatefulWidget {
  final PackingFormulaItem packingFormula;
  final Function(PackingFormulaItem) onPackingFormulaUpdated;

  const PackingFormulaDetailPage({
    super.key,
    required this.packingFormula,
    required this.onPackingFormulaUpdated,
  });

  @override
  State<PackingFormulaDetailPage> createState() => _PackingFormulaDetailPageState();
}

class _PackingFormulaDetailPageState extends State<PackingFormulaDetailPage> {
  List<PackingFormulaMaterial> _materials = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchComponents();
  }

  Future<void> _fetchComponents() async {
    setState(() => _isLoading = true);
    final list = await PackingFormulaApiService.fetchPackingFormulaComponents(widget.packingFormula.id);
    if (mounted) {
      setState(() {
        _materials = list;
        _isLoading = false;
      });
    }
  }

  void _openEditComponents() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => EditComponentsBottomSheet(
        materials: _materials,
        onSaved: (updatedMaterials) {
          setState(() {
            _materials = updatedMaterials;
          });
          final updatedPackingFormula = PackingFormulaItem(
            id: widget.packingFormula.id,
            productName: widget.packingFormula.productName,
            category: widget.packingFormula.category,
            version: widget.packingFormula.version,
            status: widget.packingFormula.status,
            materialCount: updatedMaterials.length,
            updatedAt: DateTime.now(),
          );
          widget.onPackingFormulaUpdated(updatedPackingFormula);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final sw = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: buildPackingFormulaAppBar(
        title: widget.packingFormula.productName,
        subtitle: '${widget.packingFormula.id} · ${widget.packingFormula.version}',
        context: context,
        actions: [
          // IconButton(
          //   icon: const Icon(Icons.edit_outlined, color: Colors.white),
          //   onPressed: _openEditComponents,
          // ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(sw * 0.03),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: sw * 0.03),
            Text(
              'Components',
              style: TextStyle(
                fontSize: sw * 0.04,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            SizedBox(height: sw * 0.04),
            if (_isLoading)
              const Center(child: CircularProgressIndicator(color: packingFormulaTeal))
            else if (_materials.isEmpty)
              const Center(child: Text('No components found'))
            else
              ..._materials.map(
                (m) => Padding(
                  padding: EdgeInsets.only(bottom: sw * 0.02),
                  child: AppCard(
                    child: Row(
                      children: [
                        Container(
                          width: sw * 0.09,
                          height: sw * 0.09,
                          decoration: BoxDecoration(
                            color: packingFormulaTealLight,
                            borderRadius: BorderRadius.circular(sw * 0.02),
                          ),
                          child: Icon(Icons.memory_outlined,
                              color: packingFormulaTeal, size: sw * 0.050),
                        ),
                        SizedBox(width: sw * 0.03),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                m.name,
                                style: TextStyle(
                                  fontSize: sw * 0.034,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              SizedBox(height: sw * 0.008),
                              Text(
                                m.uom,
                                style: TextStyle(
                                  fontSize: sw * 0.030,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              'Qty',
                              style: TextStyle(
                                fontSize: sw * 0.030,
                                color: Colors.green,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            SizedBox(height: sw * 0.004),
                            Text(
                              '${m.quantity}',
                              style: TextStyle(
                                fontSize: sw * 0.030,
                                fontWeight: FontWeight.w700,
                                color: Colors.black,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
