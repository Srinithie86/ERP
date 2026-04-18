import 'package:flutter/material.dart';
import 'app_theme.dart';
import 'shared_widgets.dart';
import 'models.dart';

class BomScreen extends StatefulWidget {
  const BomScreen({super.key});
  @override State<BomScreen> createState() => _BomScreenState();
}

class _BomScreenState extends State<BomScreen> {
  String _search = '';
  String _filter = 'All';

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context);
    final sw = mq.size.width;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(children: [
        _buildTopBar(sw),
        Expanded(child: SingleChildScrollView(
          padding: EdgeInsets.all(sw * 0.05),
          child: Column(children: [
            _buildFilters(sw),
            SizedBox(height: sw * 0.04),
            ..._filteredBoms().map((b) => Padding(
              padding: EdgeInsets.only(bottom: sw * 0.03),
              child: _BomCard(bom: b, onTap: () => _showBomDetail(context, b)),
            )),
          ]),
        )),
        _buildAddButton(sw),
      ]),
    );
  }

  Widget _buildTopBar(double sw) => Container(
    color: AppColors.surface,
    padding: EdgeInsets.fromLTRB(sw * 0.05, sw * 0.04, sw * 0.05, sw * 0.03),
    child: Column(children: [
      Row(children: [
        Expanded(child: Text('Bill of Materials', style: TextStyle(
          fontSize: sw * 0.05,
          fontWeight: FontWeight.w800,
          color: AppColors.textPrimary,
        ))),
        Container(
          padding: EdgeInsets.symmetric(horizontal: sw * 0.03, vertical: sw * 0.015),
          decoration: BoxDecoration(
            color: AppColors.primaryLight,
            borderRadius: BorderRadius.circular(sw * 0.02),
          ),
          child: Text('${SampleData.boms.length} BOMs', style: TextStyle(
            fontSize: sw * 0.032,
            color: AppColors.primary,
            fontWeight: FontWeight.w600,
          )),
        ),
      ]),
      SizedBox(height: sw * 0.03),
      TextField(
        onChanged: (v) => setState(() => _search = v),
        style: TextStyle(fontSize: sw * 0.035),
        decoration: InputDecoration(
          hintText: 'Search product name or BOM ID...',
          hintStyle: TextStyle(fontSize: sw * 0.035),
          prefixIcon: Icon(Icons.search, size: sw * 0.045, color: AppColors.textHint),
          filled: true,
          fillColor: AppColors.background,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(sw * 0.025),
            borderSide: const BorderSide(color: AppColors.border),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(sw * 0.025),
            borderSide: const BorderSide(color: AppColors.border),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(sw * 0.025),
            borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
          ),
          contentPadding: EdgeInsets.symmetric(vertical: sw * 0.025),
        ),
      ),
    ]),
  );

  Widget _buildFilters(double sw) => SingleChildScrollView(
    scrollDirection: Axis.horizontal,
    child: Row(children: ['All', 'Active', 'Draft', 'Archived'].map((f) => Padding(
      padding: EdgeInsets.only(right: sw * 0.02),
      child: GestureDetector(
        onTap: () => setState(() => _filter = f),
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: sw * 0.04, vertical: sw * 0.02),
          decoration: BoxDecoration(
            color: _filter == f ? AppColors.primary : AppColors.surface,
            borderRadius: BorderRadius.circular(sw * 0.05),
            border: Border.all(color: _filter == f ? AppColors.primary : AppColors.border),
          ),
          child: Text(f, style: TextStyle(
            fontSize: sw * 0.032,
            fontWeight: FontWeight.w600,
            color: _filter == f ? Colors.white : AppColors.textSecondary,
          )),
        ),
      ),
    )).toList()),
  );

  List<BomItem> _filteredBoms() {
    var list = SampleData.boms;
    if (_search.isNotEmpty) list = list.where((b) => b.productName.toLowerCase().contains(_search.toLowerCase())).toList();
    if (_filter != 'All') list = list.where((b) => b.status == _filter.toLowerCase()).toList();
    return list;
  }

  Widget _buildAddButton(double sw) => Container(
    color: AppColors.surface,
    padding: EdgeInsets.all(sw * 0.04),
    child: SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: () => _showCreateBom(context),
        icon: Icon(Icons.add, size: sw * 0.045),
        label: Text('Create New BOM', style: TextStyle(fontSize: sw * 0.035)),
      ),
    ),
  );

  // ── BOM Detail Bottom Sheet ───────────────────────────────────────────────
  void _showBomDetail(BuildContext context, BomItem bom) {
    final sw = MediaQuery.of(context).size.width;
    final sh = MediaQuery.of(context).size.height;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(sw * 0.05)),
      ),
      builder: (_) => DraggableScrollableSheet(
        initialChildSize: 0.85, maxChildSize: 0.95, minChildSize: 0.5, expand: false,
        builder: (_, ctrl) => SingleChildScrollView(
          controller: ctrl,
          padding: EdgeInsets.all(sw * 0.05),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Center(child: Container(
              width: sw * 0.09, height: sw * 0.01,
              decoration: BoxDecoration(color: AppColors.border, borderRadius: BorderRadius.circular(sw * 0.005)),
            )),
            SizedBox(height: sh * 0.025),
            Row(children: [
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(bom.productName, style: TextStyle(
                  fontSize: sw * 0.045, fontWeight: FontWeight.w800, color: AppColors.textPrimary,
                )),
                SizedBox(height: sw * 0.01),
                Text('${bom.id} · ${bom.version}', style: TextStyle(
                  fontSize: sw * 0.032, color: AppColors.textSecondary,
                )),
              ])),
              StatusBadge(
                label: bom.status == 'active' ? 'Active' : 'Draft',
                status: bom.status == 'active' ? 'completed' : 'pending',
              ),
            ]),
            SizedBox(height: sh * 0.025),
            AppCard(color: AppColors.background, child: Column(children: [
              InfoRow(label: 'Category', value: bom.category),
              InfoRow(label: 'Version', value: bom.version),
              InfoRow(label: 'Materials', value: '${bom.materialCount} items'),
              InfoRow(label: 'Last Updated', value: '${bom.updatedAt.day}/${bom.updatedAt.month}/${bom.updatedAt.year}'),
            ])),
            SizedBox(height: sh * 0.025),
            Text('Components', style: TextStyle(
              fontSize: sw * 0.04, fontWeight: FontWeight.w700, color: AppColors.textPrimary,
            )),
            SizedBox(height: sw * 0.03),
            ...SampleData.bomMaterials.map((m) => Padding(
              padding: EdgeInsets.only(bottom: sw * 0.02),
              child: AppCard(child: Row(children: [
                Container(
                  width: sw * 0.09, height: sw * 0.09,
                  decoration: BoxDecoration(
                    color: AppColors.primaryLight,
                    borderRadius: BorderRadius.circular(sw * 0.02),
                  ),
                  child: Icon(Icons.memory_outlined, color: AppColors.primary, size: sw * 0.045),
                ),
                SizedBox(width: sw * 0.03),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(m.name, style: TextStyle(
                    fontSize: sw * 0.032, fontWeight: FontWeight.w600, color: AppColors.textPrimary,
                  )),
                  Text('Scrap: ${m.scrapPercent}%', style: TextStyle(
                    fontSize: sw * 0.03, color: AppColors.textSecondary,
                  )),
                ])),
                Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                  Text('${m.quantity}', style: TextStyle(
                    fontSize: sw * 0.035, fontWeight: FontWeight.w700, color: AppColors.textPrimary,
                  )),
                  Text(m.uom, style: TextStyle(fontSize: sw * 0.03, color: AppColors.textSecondary)),
                ]),
              ])),
            )),
            SizedBox(height: sh * 0.025),
            Row(children: [
              Expanded(child: OutlinedButton.icon(
                onPressed: () {},
                icon: Icon(Icons.edit_outlined, size: sw * 0.04),
                label: Text('Edit BOM', style: TextStyle(fontSize: sw * 0.032)),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.primary,
                  side: const BorderSide(color: AppColors.primary),
                ),
              )),
              SizedBox(width: sw * 0.03),
              Expanded(child: ElevatedButton.icon(
                onPressed: () {},
                icon: Icon(Icons.play_arrow_outlined, size: sw * 0.04),
                label: Text('Create Plan', style: TextStyle(fontSize: sw * 0.032)),
              )),
            ]),
          ]),
        ),
      ),
    );
  }

  // ── Step 1: Create BOM Basic Info ─────────────────────────────────────────
  void _showCreateBom(BuildContext context) {
    final sw = MediaQuery.of(context).size.width;
    final nameCtrl = TextEditingController();
    final versionCtrl = TextEditingController();
    final yieldCtrl = TextEditingController();
    String selectedCategory = 'PV Module';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(sw * 0.05)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModalState) => Padding(
          padding: EdgeInsets.fromLTRB(
            sw * 0.05, sw * 0.05, sw * 0.05,
            MediaQuery.of(ctx).viewInsets.bottom + sw * 0.05,
          ),
          child: SingleChildScrollView(
            child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
              // Header
              Row(children: [
                Expanded(child: Text('Create New BOM', style: TextStyle(
                  fontSize: sw * 0.045, fontWeight: FontWeight.w800, color: AppColors.textPrimary,
                ))),
                GestureDetector(
                  onTap: () => Navigator.pop(ctx),
                  child: Icon(Icons.close, color: AppColors.textSecondary, size: sw * 0.055),
                ),
              ]),
              SizedBox(height: sw * 0.02),
              // Step indicator
              _StepIndicator(currentStep: 1, sw: sw),
              SizedBox(height: sw * 0.05),

              // Product Name
              _FormLabel(label: 'Product Name', sw: sw),
              SizedBox(height: sw * 0.02),
              TextField(
                controller: nameCtrl,
                style: TextStyle(fontSize: sw * 0.035, color: AppColors.textPrimary),
                decoration: _inputDecoration('e.g. Solar Panel 400W Mono', sw,
                    prefixIcon: Icons.solar_power_outlined),
              ),
              SizedBox(height: sw * 0.035),

              // Category
              _FormLabel(label: 'Category', sw: sw),
              SizedBox(height: sw * 0.02),
              Container(
                padding: EdgeInsets.symmetric(horizontal: sw * 0.04),
                decoration: BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.circular(sw * 0.025),
                  border: Border.all(color: AppColors.border),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: selectedCategory,
                    isExpanded: true,
                    style: TextStyle(fontSize: sw * 0.035, color: AppColors.textPrimary),
                    items: ['PV Module', 'Solar Lighting', 'Solar Pump', 'Off-Grid System', 'Inverter', 'Battery Pack']
                        .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                        .toList(),
                    onChanged: (v) => setModalState(() => selectedCategory = v!),
                  ),
                ),
              ),
              SizedBox(height: sw * 0.035),

              // Version
              _FormLabel(label: 'Version', sw: sw),
              SizedBox(height: sw * 0.02),
              TextField(
                controller: versionCtrl,
                style: TextStyle(fontSize: sw * 0.035, color: AppColors.textPrimary),
                decoration: _inputDecoration('e.g. v1.0', sw, prefixIcon: Icons.tag),
              ),
              SizedBox(height: sw * 0.035),

              // Expected Yield
              _FormLabel(label: 'Expected Yield (%)', sw: sw),
              SizedBox(height: sw * 0.02),
              TextField(
                controller: yieldCtrl,
                keyboardType: TextInputType.number,
                style: TextStyle(fontSize: sw * 0.035, color: AppColors.textPrimary),
                decoration: _inputDecoration('e.g. 95', sw, prefixIcon: Icons.percent),
              ),
              SizedBox(height: sw * 0.05),

              // Next button → opens Add Materials sheet
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pop(ctx);
                    _showAddMaterials(
                      context,
                      productName: nameCtrl.text.isEmpty ? 'New BOM' : nameCtrl.text,
                      category: selectedCategory,
                      version: versionCtrl.text.isEmpty ? 'v1.0' : versionCtrl.text,
                    );
                  },
                  icon: Icon(Icons.arrow_forward, size: sw * 0.045),
                  label: Text('Add Materials', style: TextStyle(fontSize: sw * 0.035)),
                ),
              ),
            ]),
          ),
        ),
      ),
    );
  }

  // ── Step 2: Add Materials ──────────────────────────────────────────────────
  void _showAddMaterials(
      BuildContext context, {
        required String productName,
        required String category,
        required String version,
      }) {
    final sw = MediaQuery.of(context).size.width;

    // Start with one empty row
    final List<_MaterialRow> rows = [_MaterialRow()];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(sw * 0.05)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModalState) {
          final keyboardH = MediaQuery.of(ctx).viewInsets.bottom;
          return SizedBox(
            height: MediaQuery.of(ctx).size.height * 0.92,
            child: Column(children: [
              // ── Fixed header ──
              Padding(
                padding: EdgeInsets.fromLTRB(sw * 0.05, sw * 0.05, sw * 0.05, sw * 0.02),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Row(children: [
                    GestureDetector(
                      onTap: () {
                        Navigator.pop(ctx);
                        _showCreateBom(context);
                      },
                      child: Icon(Icons.arrow_back_ios, size: sw * 0.045, color: AppColors.textSecondary),
                    ),
                    SizedBox(width: sw * 0.02),
                    Expanded(child: Text('Add Materials', style: TextStyle(
                      fontSize: sw * 0.045, fontWeight: FontWeight.w800, color: AppColors.textPrimary,
                    ))),
                    GestureDetector(
                      onTap: () => Navigator.pop(ctx),
                      child: Icon(Icons.close, color: AppColors.textSecondary, size: sw * 0.055),
                    ),
                  ]),
                  SizedBox(height: sw * 0.02),
                  _StepIndicator(currentStep: 2, sw: sw),
                  SizedBox(height: sw * 0.025),
                  // BOM summary pill
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: sw * 0.04, vertical: sw * 0.025),
                    decoration: BoxDecoration(
                      color: AppColors.primaryLight,
                      borderRadius: BorderRadius.circular(sw * 0.025),
                    ),
                    child: Row(children: [
                      Icon(Icons.solar_power_outlined, size: sw * 0.04, color: AppColors.primary),
                      SizedBox(width: sw * 0.025),
                      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Text(productName, style: TextStyle(
                          fontSize: sw * 0.032, fontWeight: FontWeight.w600, color: AppColors.primary,
                        )),
                        Text('$category · $version', style: TextStyle(
                          fontSize: sw * 0.028, color: AppColors.primary,
                        )),
                      ])),
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: sw * 0.025, vertical: sw * 0.01),
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          borderRadius: BorderRadius.circular(sw * 0.015),
                        ),
                        child: Text('${rows.length} items', style: TextStyle(
                          fontSize: sw * 0.028, color: Colors.white, fontWeight: FontWeight.w600,
                        )),
                      ),
                    ]),
                  ),
                  SizedBox(height: sw * 0.03),
                  // Column labels
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: sw * 0.01),
                    child: Row(children: [
                      Expanded(flex: 4, child: Text('Component / Material', style: TextStyle(
                        fontSize: sw * 0.028, fontWeight: FontWeight.w600, color: AppColors.textSecondary,
                      ))),
                      SizedBox(width: sw * 0.02),
                      SizedBox(width: sw * 0.18, child: Text('Qty', style: TextStyle(
                        fontSize: sw * 0.028, fontWeight: FontWeight.w600, color: AppColors.textSecondary,
                      ))),
                      SizedBox(width: sw * 0.02),
                      SizedBox(width: sw * 0.14, child: Text('UOM', style: TextStyle(
                        fontSize: sw * 0.028, fontWeight: FontWeight.w600, color: AppColors.textSecondary,
                      ))),
                      SizedBox(width: sw * 0.02),
                      SizedBox(width: sw * 0.14, child: Text('Scrap%', style: TextStyle(
                        fontSize: sw * 0.028, fontWeight: FontWeight.w600, color: AppColors.textSecondary,
                      ))),
                      SizedBox(width: sw * 0.08),
                    ]),
                  ),
                  SizedBox(height: sw * 0.02),
                  const Divider(color: AppColors.border, height: 1),
                ]),
              ),

              // ── Scrollable material rows ──
              Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsets.fromLTRB(sw * 0.05, sw * 0.02, sw * 0.05, 0),
                  child: Column(children: [
                    ...rows.asMap().entries.map((e) {
                      final idx = e.key;
                      final row = e.value;
                      return Padding(
                        padding: EdgeInsets.only(bottom: sw * 0.025),
                        child: _MaterialRowWidget(
                          row: row,
                          sw: sw,
                          index: idx,
                          canDelete: rows.length > 1,
                          onDelete: () => setModalState(() => rows.removeAt(idx)),
                        ),
                      );
                    }),

                    // Add row button
                    GestureDetector(
                      onTap: () => setModalState(() => rows.add(_MaterialRow())),
                      child: Container(
                        width: double.infinity,
                        padding: EdgeInsets.symmetric(vertical: sw * 0.035),
                        decoration: BoxDecoration(
                          color: AppColors.background,
                          borderRadius: BorderRadius.circular(sw * 0.025),
                          border: Border.all(color: AppColors.primary, width: 1.2),
                        ),
                        child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                          Icon(Icons.add_circle_outline, size: sw * 0.045, color: AppColors.primary),
                          SizedBox(width: sw * 0.02),
                          Text('Add Another Component', style: TextStyle(
                            fontSize: sw * 0.033, fontWeight: FontWeight.w600, color: AppColors.primary,
                          )),
                        ]),
                      ),
                    ),
                    SizedBox(height: keyboardH > 0 ? keyboardH : sw * 0.04),
                  ]),
                ),
              ),

              // ── Fixed bottom: Create BOM button ──
              Container(
                color: AppColors.surface,
                padding: EdgeInsets.fromLTRB(sw * 0.05, sw * 0.03, sw * 0.05, sw * 0.05),
                child: Column(mainAxisSize: MainAxisSize.min, children: [
                  const Divider(color: AppColors.border, height: 1),
                  SizedBox(height: sw * 0.03),
                  Row(children: [
                    Icon(Icons.layers_outlined, size: sw * 0.035, color: AppColors.textSecondary),
                    SizedBox(width: sw * 0.015),
                    Text('${rows.length} component${rows.length == 1 ? '' : 's'} added',
                        style: TextStyle(fontSize: sw * 0.03, color: AppColors.textSecondary)),
                    const Spacer(),
                  ]),
                  SizedBox(height: sw * 0.03),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.pop(ctx);
                        _showBomCreatedSuccess(context, productName, rows.length);
                      },
                      icon: Icon(Icons.check_circle_outline, size: sw * 0.045),
                      label: Text('Create BOM', style: TextStyle(
                        fontSize: sw * 0.038, fontWeight: FontWeight.w700,
                      )),
                      style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.symmetric(vertical: sw * 0.04),
                      ),
                    ),
                  ),
                ]),
              ),
            ]),
          );
        },
      ),
    );
  }

  // ── Success Snackbar ───────────────────────────────────────────────────────
  void _showBomCreatedSuccess(BuildContext context, String productName, int materialCount) {
    final sw = MediaQuery.of(context).size.width;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      backgroundColor: AppColors.success,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(sw * 0.025)),
      content: Row(children: [
        Icon(Icons.check_circle, color: Colors.white, size: sw * 0.045),
        SizedBox(width: sw * 0.025),
        Expanded(child: Text(
          'BOM created for "$productName" with $materialCount component${materialCount == 1 ? '' : 's'}',
          style: TextStyle(fontSize: sw * 0.032, color: Colors.white),
        )),
      ]),
      duration: const Duration(seconds: 3),
    ));
  }

  InputDecoration _inputDecoration(String hint, double sw, {IconData? prefixIcon}) => InputDecoration(
    hintText: hint,
    hintStyle: TextStyle(fontSize: sw * 0.035, color: AppColors.textHint),
    prefixIcon: prefixIcon != null ? Icon(prefixIcon, size: sw * 0.045, color: AppColors.textHint) : null,
    filled: true,
    fillColor: AppColors.background,
    border: OutlineInputBorder(borderRadius: BorderRadius.circular(sw * 0.025),
        borderSide: const BorderSide(color: AppColors.border)),
    enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(sw * 0.025),
        borderSide: const BorderSide(color: AppColors.border)),
    focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(sw * 0.025),
        borderSide: const BorderSide(color: AppColors.primary, width: 1.5)),
    contentPadding: EdgeInsets.symmetric(vertical: sw * 0.025, horizontal: sw * 0.04),
  );
}

// ── Step Indicator ─────────────────────────────────────────────────────────
class _StepIndicator extends StatelessWidget {
  final int currentStep;
  final double sw;
  const _StepIndicator({required this.currentStep, required this.sw});

  @override
  Widget build(BuildContext context) {
    return Row(children: [
      _step(1, 'BOM Info'),
      Expanded(child: Container(height: 1.5,
          color: currentStep >= 2 ? AppColors.primary : AppColors.border)),
      _step(2, 'Materials'),
    ]);
  }

  Widget _step(int step, String label) {
    final active = currentStep >= step;
    return Column(children: [
      Container(
        width: sw * 0.07, height: sw * 0.07,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: active ? AppColors.primary : AppColors.background,
          border: Border.all(color: active ? AppColors.primary : AppColors.border, width: 1.5),
        ),
        child: Center(child: active && currentStep > step
            ? Icon(Icons.check, size: sw * 0.035, color: Colors.white)
            : Text('$step', style: TextStyle(
          fontSize: sw * 0.03,
          fontWeight: FontWeight.w700,
          color: active ? Colors.white : AppColors.textSecondary,
        ))),
      ),
      SizedBox(height: sw * 0.01),
      Text(label, style: TextStyle(
        fontSize: sw * 0.025,
        fontWeight: FontWeight.w500,
        color: active ? AppColors.primary : AppColors.textSecondary,
      )),
    ]);
  }
}

// ── Material Row Data Model ────────────────────────────────────────────────
class _MaterialRow {
  final nameCtrl = TextEditingController();
  final qtyCtrl = TextEditingController();
  String uom = 'pcs';
  final scrapCtrl = TextEditingController();
}

// ── Material Row Widget ────────────────────────────────────────────────────
class _MaterialRowWidget extends StatelessWidget {
  final _MaterialRow row;
  final double sw;
  final int index;
  final bool canDelete;
  final VoidCallback onDelete;

  const _MaterialRowWidget({
    required this.row,
    required this.sw,
    required this.index,
    required this.canDelete,
    required this.onDelete,
  });

  InputDecoration _compact(String hint) => InputDecoration(
    hintText: hint,
    hintStyle: TextStyle(fontSize: sw * 0.028, color: AppColors.textHint),
    filled: true,
    fillColor: AppColors.background,
    border: OutlineInputBorder(borderRadius: BorderRadius.circular(sw * 0.02),
        borderSide: const BorderSide(color: AppColors.border)),
    enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(sw * 0.02),
        borderSide: const BorderSide(color: AppColors.border)),
    focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(sw * 0.02),
        borderSide: const BorderSide(color: AppColors.primary, width: 1.5)),
    contentPadding: EdgeInsets.symmetric(horizontal: sw * 0.025, vertical: sw * 0.02),
    isDense: true,
  );

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(sw * 0.03),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(sw * 0.025),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        // Row number + delete
        Row(children: [
          Container(
            width: sw * 0.06, height: sw * 0.06,
            decoration: BoxDecoration(
              color: AppColors.primaryLight,
              borderRadius: BorderRadius.circular(sw * 0.015),
            ),
            child: Center(child: Text('${index + 1}', style: TextStyle(
              fontSize: sw * 0.028, fontWeight: FontWeight.w700, color: AppColors.primary,
            ))),
          ),
          SizedBox(width: sw * 0.02),
          Text('Component ${index + 1}', style: TextStyle(
            fontSize: sw * 0.03, fontWeight: FontWeight.w600, color: AppColors.textSecondary,
          )),
          const Spacer(),
          if (canDelete)
            GestureDetector(
              onTap: onDelete,
              child: Container(
                padding: EdgeInsets.all(sw * 0.015),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFEBEB),
                  borderRadius: BorderRadius.circular(sw * 0.015),
                ),
                child: const Icon(Icons.delete_outline, size: 20, color: Color(0xFFD32F2F)),
              ),
            ),
        ]),
        SizedBox(height: sw * 0.025),

        // Name field (full width)
        Text('Component Name', style: TextStyle(
          fontSize: sw * 0.028, fontWeight: FontWeight.w500, color: AppColors.textSecondary,
        )),
        SizedBox(height: sw * 0.015),
        TextField(
          controller: row.nameCtrl,
          style: TextStyle(fontSize: sw * 0.032, color: AppColors.textPrimary),
          decoration: _compact('e.g. Monocrystalline Silicon Cell 6"'),
        ),
        SizedBox(height: sw * 0.02),

        // Qty | UOM | Scrap% in one row
        Row(children: [
          // Qty
          Expanded(flex: 3, child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('Quantity', style: TextStyle(
              fontSize: sw * 0.028, fontWeight: FontWeight.w500, color: AppColors.textSecondary,
            )),
            SizedBox(height: sw * 0.015),
            TextField(
              controller: row.qtyCtrl,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              style: TextStyle(fontSize: sw * 0.032, color: AppColors.textPrimary),
              decoration: _compact('0'),
            ),
          ])),
          SizedBox(width: sw * 0.025),

          // UOM
          Expanded(flex: 3, child: StatefulBuilder(
            builder: (ctx, setSelf) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('UOM', style: TextStyle(
                fontSize: sw * 0.028, fontWeight: FontWeight.w500, color: AppColors.textSecondary,
              )),
              SizedBox(height: sw * 0.015),
              Container(
                padding: EdgeInsets.symmetric(horizontal: sw * 0.025),
                decoration: BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.circular(sw * 0.02),
                  border: Border.all(color: AppColors.border),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: row.uom,
                    isExpanded: true,
                    isDense: true,
                    style: TextStyle(fontSize: sw * 0.03, color: AppColors.textPrimary),
                    items: ['pcs', 'kg', 'g', 'm', 'm²', 'ltr', 'set']
                        .map((u) => DropdownMenuItem(value: u, child: Text(u)))
                        .toList(),
                    onChanged: (v) => setSelf(() => row.uom = v!),
                  ),
                ),
              ),
            ]),
          )),
          SizedBox(width: sw * 0.025),

          // Scrap %
          Expanded(flex: 2, child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('Scrap %', style: TextStyle(
              fontSize: sw * 0.028, fontWeight: FontWeight.w500, color: AppColors.textSecondary,
            )),
            SizedBox(height: sw * 0.015),
            TextField(
              controller: row.scrapCtrl,
              keyboardType: TextInputType.number,
              style: TextStyle(fontSize: sw * 0.032, color: AppColors.textPrimary),
              decoration: _compact('0'),
            ),
          ])),
        ]),
      ]),
    );
  }
}

// ── Form Label ────────────────────────────────────────────────────────────
class _FormLabel extends StatelessWidget {
  final String label;
  final double sw;
  const _FormLabel({required this.label, required this.sw});

  @override
  Widget build(BuildContext context) => Text(label, style: TextStyle(
    fontSize: sw * 0.032,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
  ));
}

// ── BOM Card ──────────────────────────────────────────────────────────────
class _BomCard extends StatelessWidget {
  final BomItem bom;
  final VoidCallback onTap;
  const _BomCard({required this.bom, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final sw = MediaQuery.of(context).size.width;

    return AppCard(
      onTap: onTap,
      child: Column(children: [
        Row(children: [
          Container(
            width: sw * 0.105, height: sw * 0.105,
            decoration: BoxDecoration(
              color: AppColors.primaryLight,
              borderRadius: BorderRadius.circular(sw * 0.025),
            ),
            child: Icon(Icons.account_tree_outlined, color: AppColors.primary, size: sw * 0.055),
          ),
          SizedBox(width: sw * 0.03),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(bom.productName, style: TextStyle(
              fontSize: sw * 0.035, fontWeight: FontWeight.w700, color: AppColors.textPrimary,
            )),
            SizedBox(height: sw * 0.008),
            Text('${bom.id} · ${bom.category}', style: TextStyle(
              fontSize: sw * 0.03, color: AppColors.textSecondary,
            )),
          ])),
          StatusBadge(
            label: bom.status == 'active' ? 'Active' : 'Draft',
            status: bom.status == 'active' ? 'completed' : 'pending',
          ),
        ]),
        SizedBox(height: sw * 0.03),
        const Divider(color: AppColors.border, height: 1),
        SizedBox(height: sw * 0.03),
        Row(children: [
          _chip(Icons.layers_outlined, bom.version, sw),
          SizedBox(width: sw * 0.03),
          _chip(Icons.memory_outlined, '${bom.materialCount} components', sw),
          const Spacer(),
          Icon(Icons.chevron_right, color: AppColors.textHint, size: sw * 0.045),
        ]),
      ]),
    );
  }

  Widget _chip(IconData icon, String label, double sw) => Row(children: [
    Icon(icon, size: sw * 0.035, color: AppColors.textSecondary),
    SizedBox(width: sw * 0.01),
    Text(label, style: TextStyle(fontSize: sw * 0.03, color: AppColors.textSecondary)),
  ]);
}