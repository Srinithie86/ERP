import 'package:flutter/material.dart';
import '../../../../core/app_theme.dart';
import '../../../../core/shared_widgets.dart';
import '../bom_model.dart';
import '../bom_api_service.dart';
import '../widgets/bom_widgets.dart';
import '../widgets/bom_bottom_sheets.dart';

class BomDetailPage extends StatefulWidget {
  final BomItem bom;
  final Function(BomItem) onBomUpdated;

  const BomDetailPage({
    super.key,
    required this.bom,
    required this.onBomUpdated,
  });

  @override
  State<BomDetailPage> createState() => _BomDetailPageState();
}

class _BomDetailPageState extends State<BomDetailPage> {
  List<BomMaterial> _materials = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchComponents();
  }

  Future<void> _fetchComponents() async {
    setState(() => _isLoading = true);
    final list = await BomApiService.fetchBomComponents(widget.bom.id);
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
          final updatedBom = BomItem(
            id: widget.bom.id,
            productName: widget.bom.productName,
            category: widget.bom.category,
            version: widget.bom.version,
            status: widget.bom.status,
            materialCount: updatedMaterials.length,
            updatedAt: DateTime.now(),
          );
          widget.onBomUpdated(updatedBom);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final sw = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: buildBomAppBar(
        title: widget.bom.productName,
        subtitle: '${widget.bom.id} · ${widget.bom.version}',
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
              const Center(child: CircularProgressIndicator(color: bomTeal))
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
                            color: bomTealLight,
                            borderRadius: BorderRadius.circular(sw * 0.02),
                          ),
                          child: Icon(Icons.memory_outlined,
                              color: bomTeal, size: sw * 0.050),
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
