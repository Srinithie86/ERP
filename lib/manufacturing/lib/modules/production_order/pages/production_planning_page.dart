import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter/material.dart';
import 'package:manufacturing_erp/modules/production_order/production_order_api_service.dart';
import '../production_order_model.dart';
import '../widgets/production_order_widgets.dart';
import '../widgets/bom_picker_widgets.dart';

class ProductionPlanningPage extends StatefulWidget {
  final ProductionOrder order;
  final int prodIdx;
  final int availableQty;
  final void Function(ProductSplit) onCreated;

  static int _planCounter = 52;

  const ProductionPlanningPage({
    super.key,
    required this.order,
    required this.prodIdx,
    required this.availableQty,
    required this.onCreated,
  });

  @override
  State<ProductionPlanningPage> createState() => _ProductionPlanningPageState();
}

class _ProductionPlanningPageState extends State<ProductionPlanningPage> {
  String? _selectedBom;
  BomData? _bomData;
  int _qty = 0;
  String _priority = '';
  String _productionType = '';
  DateTime? _deadline;
  bool _isAutoFilled = false;

  final _qtyCtrl = TextEditingController();
  final _operatorCtrl = TextEditingController();
  final _assignToCtrl = TextEditingController();
  final _descCtrl = TextEditingController();

  late final String _planId;
  late final String _today;

  List<DropdownItem> _productionTypeList = [];
  List<DropdownItem> _priorityList = [];
  bool _isLoadingDropdowns = true;

  final List<String> _priorityOptions = ['High', 'Medium', 'Low'];
  final List<String> _prodTypeOptions = [
    'Assembly',
    'Fabrication',
    'Machining',
    'Packaging',
    'Testing'
  ];

  @override
  void initState() {
    super.initState();
    ProductionPlanningPage._planCounter++;
    _planId =
        'PP-2026-${ProductionPlanningPage._planCounter.toString().padLeft(4, '0')}';
    final n = DateTime.now();
    _today =
        '${n.day.toString().padLeft(2, '0')}-${n.month.toString().padLeft(2, '0')}-${n.year}';

    _fetchDropdowns();

    // Auto-fill from order
    if (widget.order.dueDate != null) {
      _deadline = widget.order.dueDate;
    }

    final product = widget.order.products[widget.prodIdx];

    // Lock quantity statically exactly like the readonly UI
    _qty = product.qty;
    _qtyCtrl.text = _qty.toString();

    if (product.bomId.isNotEmpty && product.bomId != '0') {
      _bomData = BomData(
        bomId: product.bomId,
        bomLabel: 'BOM-${product.bomId.padLeft(3, '0')}',
        items: [],
      );
      _selectedBom = _bomData!.bomLabel;
      _isAutoFilled = true;
      _fetchRealBomData(product.bomId);
    } else {
      final autoMap = autoMapBom(widget.prodIdx, widget.order.products);
      if (autoMap != null) {
        _bomData = autoMap;
        _selectedBom = autoMap.bomLabel;
        _isAutoFilled = true;
      }
    }
  }

  Future<void> _fetchRealBomData(String bomId) async {
    try {
      final realBom = await ProductionOrderApiService.fetchBomDetails(bomId);
      
      if (realBom != null && mounted) {
        setState(() {
          _bomData = realBom;
          _selectedBom = realBom.bomLabel;
        });
      } else {
        // Fallback if 9008 fails
        final boms = await ProductionOrderApiService.fetchBoms();
        final match = boms.firstWhere(
            (b) => (b['id'] ?? b['bom_id']).toString() == bomId,
            orElse: () => {});
        String label = 'BOM-${bomId.padLeft(3, '0')}';
        if (match.isNotEmpty) {
          label +=
              ' · ${match['bom_label'] ?? match['prd_name'] ?? 'Production'}';
        }

        if (mounted) {
          setState(() {
            _bomData = BomData(bomId: bomId, bomLabel: label, items: []);
            _selectedBom = _bomData!.bomLabel;
          });
        }
      }
    } catch (e) {
      debugPrint('Error fetching BOM details for auto-fill: $e');
    }
  }

  @override
  void dispose() {
    _qtyCtrl.dispose();
    _operatorCtrl.dispose();
    _assignToCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  bool get _canSave =>
      !_isSaving &&
      _selectedBom != null &&
      _qty > 0 &&
      _deadline != null &&
      _priority.isNotEmpty &&
      _productionType.isNotEmpty;

  Future<void> _fetchDropdowns() async {
    try {
      final results = await Future.wait([
        ProductionOrderApiService.fetchDropdown('155'), // Production Type
        ProductionOrderApiService.fetchDropdown('199'), // Priority
      ]);

      if (mounted) {
        setState(() {
          _productionTypeList = results[0];
          _priorityList = results[1];
          _isLoadingDropdowns = false;
        });
      }
    } catch (e) {
      debugPrint('Error fetching dropdowns: $e');
      if (mounted) setState(() => _isLoadingDropdowns = false);
    }
  }

  Future<void> _openBomPicker() async {
    if (_isAutoFilled) return;
    final selected = await showBomPicker(context);
    if (selected != null) {
      setState(() {
        _bomData = selected;
        _selectedBom = selected.bomLabel;
      });
    }
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: now,
      lastDate: DateTime(now.year + 2),
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx)
            .copyWith(colorScheme: const ColorScheme.light(primary: joTeal)),
        child: child!,
      ),
    );
    if (picked != null) setState(() => _deadline = picked);
  }

  String _fmtDate(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')}-${d.month.toString().padLeft(2, '0')}-${d.year}';

  void _reset() {
    setState(() {
      _qty = 0;
      _priority = '';
      _productionType = '';
      _deadline = null;
    });
    _qtyCtrl.clear();
    _operatorCtrl.clear();
    _assignToCtrl.clear();
    _descCtrl.clear();
  }

  String? _operatorId;

  bool _isSaving = false;

  void _savePlan() async {
    if (_bomData == null || _deadline == null) return;
    
    setState(() => _isSaving = true);
    
    final order = widget.order;
    final product = order.products[widget.prodIdx];

    String priorityVal = _priority;
    if (_priorityList.isNotEmpty) {
      final match = _priorityList.where((e) => e.label == _priority).toList();
      if (match.isNotEmpty) priorityVal = match.first.value;
    }

    String typeVal = _productionType;
    if (_productionTypeList.isNotEmpty) {
      final match = _productionTypeList.where((e) => e.label == _productionType).toList();
      if (match.isNotEmpty) typeVal = match.first.value;
    }

    final response = await ProductionOrderApiService.saveProductionPlan(
      jobId: order.id,
      bomId: _bomData!.bomId,
      bomCode: _bomData!.bomLabel.split('·').first.trim(),
      productCode: product.code,
      productName: product.name,
      planQuantity: _qty,
      cusName: order.customerId.isNotEmpty ? order.customerId : order.customer,
      operator: _operatorId ?? _operatorCtrl.text,
      priority: priorityVal,
      productionType: typeVal,
      planDescription: _descCtrl.text,
      startDate: _fmtDate(_deadline!),
      items: _bomData!.items,
    );

    if (mounted) setState(() => _isSaving = false);

    if (response != null && response['error'] == false) {
      widget.onCreated(ProductSplit(
        label: _selectedBom!,
        qty: _qty,
        priority: _priority,
        deadline: _deadline,
      ));
      if (mounted) Navigator.pop(context);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(response?['msg'] ?? 'Failed to save production plan. Check required fields.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final order = widget.order;
    final product = order.products[widget.prodIdx];

    return Scaffold(
      backgroundColor: const Color(0xFFF2F4F7),
      appBar: buildTealAppBar(
        title: 'Production Planning',
        subtitle: order.id,
        showBack: true,
        context: context,
      ),
      body: Column(
        children: [
          Container(
            color: Colors.white,
            child: Row(
              children: [
                _Tab(label: 'Production Planning · $_planId', active: true),
              ],
            ),
          ),
          Expanded(
            child: ListView(
              padding: EdgeInsets.fromLTRB(12, 12, 12, 30),
              children: [
                _Banner2(
                  text:
                      'Production Order: ${order.id} — ${order.customer} | ${product.name}',
                ),
                SizedBox(height: 12.h),
                JORoundedCard(
                  child: Column(
                    children: [
                      JOFormRow(children: [
                        JOReadOnlyField(label: 'ORDER NO', value: order.id),
                      ]),
                      SizedBox(height: 10.h),
                      JOFormRow(children: [
                        JOReadOnlyField(
                            label: 'PRODUCT CODE',
                            value: product.code.isNotEmpty
                                ? product.code
                                : 'PRD-${(widget.prodIdx + 1).toString().padLeft(4, '0')}'),
                        JOReadOnlyField(
                            label: 'PRODUCT NAME', value: product.name),
                      ]),
                      SizedBox(height: 10.h),
                      JOEditableField(
                        label: 'BOM ID',
                        child: _isAutoFilled
                            ? _AutoFilledBomField(bom: _bomData!)
                            : _BomPickerField(
                                selected: _bomData,
                                onTap: _openBomPicker,
                              ),
                      ),
                      SizedBox(height: 10.h),
                      JOFormRow(children: [
                        JOReadOnlyField(
                            label: 'CUSTOMER NAME', value: order.customer),
                        JOReadOnlyField(
                            label: 'QUANTITY', value: product.qty.toString()),
                      ]),
                      SizedBox(height: 10.h),
                      JOFormRow(children: [
                        JOEditableField(
                          label: 'OPERATOR',
                          child: JOAutocompleteField<StaffMember>(
                            controller: _operatorCtrl,
                            hint: 'Operator name...',
                            displayStringForOption: (s) => s.name,
                            filterOption: (s, q) => s.name
                                .toLowerCase()
                                .contains(q.toLowerCase()),
                            fetchSuggestions: ProductionOrderApiService
                                .fetchStaffSuggestions,
                            onSelected: (staff) {
                              setState(() {
                                _operatorCtrl.text = staff.name;
                                _operatorId = staff.id.toString();
                              });
                            },
                          ),
                        ),
                        JOEditableField(
                          label: 'DATE *',
                          child: GestureDetector(
                            onTap: _pickDate,
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 12.w, vertical: 12.h),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF4F6F8),
                                borderRadius: BorderRadius.circular(7.r),
                                border: Border.all(color: Colors.grey.shade300),
                              ),
                              child: Row(children: [
                                Icon(Icons.calendar_today_outlined,
                                    size: 15.sp,
                                    color: _deadline != null
                                        ? joTeal
                                        : Colors.grey),
                                SizedBox(width: 8.w),
                                Expanded(
                                  child: Text(
                                    _deadline == null
                                        ? 'Due date'
                                        : _fmtDate(_deadline!),
                                    style: TextStyle(
                                        fontSize: 13.sp,
                                        color: _deadline == null
                                            ? Colors.grey
                                            : Colors.black87),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ]),
                            ),
                          ),
                        ),
                      ]),
                      SizedBox(height: 10.h),
                      JOFormRow(children: [
                        JOEditableField(
                          label: 'PRIORITY *',
                          child: _isLoadingDropdowns
                              ? _DropdownLoading()
                              : JODropdown(
                                  hint: '-- Select --',
                                  value: _priority.isEmpty ? null : _priority,
                                  items: _priorityList.isEmpty
                                      ? _priorityOptions
                                      : _priorityList
                                          .map((e) => e.label)
                                          .toList(),
                                  itemColor: priorityColor,
                                  onChanged: (v) =>
                                      setState(() => _priority = v ?? ''),
                                ),
                        ),
                        JOEditableField(
                          label: 'PRODUCTION TYPE *',
                          child: _isLoadingDropdowns
                              ? _DropdownLoading()
                              : JODropdown(
                                  hint: '-- Select --',
                                  value: _productionType.isEmpty
                                      ? null
                                      : _productionType,
                                  items: _productionTypeList.isEmpty
                                      ? _prodTypeOptions
                                      : _productionTypeList
                                          .map((e) => e.label)
                                          .toList(),
                                  onChanged: (v) =>
                                      setState(() => _productionType = v ?? ''),
                                ),
                        ),
                      ]),
                      SizedBox(height: 10.h),
                      JOFormRow(
                        children: [

                          JOEditableField(
                            label: 'JOB DESCRIPTION',
                            child: JOTextField(
                                controller: _descCtrl,
                                hint: 'Job description...'),
                          ),
                        ],
                      )
                    ],
                  ),
                ),
                SizedBox(height: 14.h),
                JORoundedCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(children: [
                        Container(
                          width: 4.w,
                          height: 16.h,
                          decoration: BoxDecoration(
                              color: joTeal,
                              borderRadius: BorderRadius.circular(2.r)),
                        ),
                        SizedBox(width: 8.w),
                        Text('Item Details',
                            style: TextStyle(
                                fontSize: 14.sp,
                                fontWeight: FontWeight.w700,
                                color: Colors.black87)),
                        const Spacer(),
                        if (_bomData != null)
                          JOPill(
                              text:
                                  'BOM ID: ${_bomData!.bomId}  ·  ${_bomData!.items.length} rows'),
                      ]),
                      SizedBox(height: 10.h),
                      _ItemTable(bomData: _bomData, splitQty: _qty),
                    ],
                  ),
                ),
                SizedBox(height: 16.h),
                Row(children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _reset,
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.grey.shade700,
                        side: BorderSide(color: Colors.grey.shade400),
                        padding: EdgeInsets.symmetric(vertical: 13.h),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8.r)),
                      ),
                      child: Text('Reset',
                          style: TextStyle(
                              fontSize: 14.sp, fontWeight: FontWeight.w600)),
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    flex: 2,
                    child: ElevatedButton.icon(
                      onPressed: _canSave ? _savePlan : null,
                      icon: _isSaving ? const SizedBox() : Icon(Icons.save_outlined, size: 17.sp),
                      label: _isSaving
                          ? SizedBox(
                              width: 16.sp,
                              height: 16.sp,
                              child: CircularProgressIndicator(
                                  color: Colors.white, strokeWidth: 2.w),
                            )
                          : Text('Save Plan',
                              style: TextStyle(
                                  fontSize: 14.sp, fontWeight: FontWeight.w600)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            _canSave || _isSaving ? joTeal : Colors.grey.shade300,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        padding: EdgeInsets.symmetric(vertical: 13.h),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8.r)),
                      ),
                    ),
                  ),
                ]),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Tab extends StatelessWidget {
  final String label;
  final bool active;
  const _Tab({required this.label, required this.active});

  @override
  Widget build(BuildContext context) => Container(
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
        decoration: BoxDecoration(
          border: Border(
              bottom: BorderSide(
                  color: active ? joTeal : Colors.transparent, width: 2.w)),
        ),
        child: Text(label,
            style: TextStyle(
                fontSize: 11.sp,
                fontWeight: active ? FontWeight.w700 : FontWeight.w400,
                color: active ? joTeal : Colors.grey.shade500)),
      );
}

class _Banner2 extends StatelessWidget {
  final String text;
  const _Banner2({required this.text});

  @override
  Widget build(BuildContext context) => Container(
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
        decoration: BoxDecoration(
          color: const Color(0xFFE8F5E9),
          borderRadius: BorderRadius.circular(8.r),
          border: Border.all(color: Colors.green.shade300),
        ),
        child: Row(children: [
          Icon(Icons.check_circle_outline, color: Colors.green, size: 16.sp),
          SizedBox(width: 8.w),
          Expanded(
            child: Text(text,
                style: TextStyle(
                    fontSize: 12.sp,
                    color: Colors.green,
                    fontWeight: FontWeight.w600),
                overflow: TextOverflow.ellipsis),
          ),
        ]),
      );
}

class _AutoFilledBomField extends StatelessWidget {
  final BomData bom;
  const _AutoFilledBomField({required this.bom});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
      decoration: BoxDecoration(
        color: const Color(0xFFF4F6F8),
        borderRadius: BorderRadius.circular(7.r),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Row(
        children: [
          SizedBox(width: 8.w),
          Expanded(
            child: Text(
              bom.bomLabel,
              style: TextStyle(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

class _BomPickerField extends StatelessWidget {
  final BomData? selected;
  final VoidCallback onTap;
  const _BomPickerField({required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
        decoration: BoxDecoration(
          color: selected != null
              ? const Color(0xFFF0FBF9)
              : const Color(0xFFF4F6F8),
          borderRadius: BorderRadius.circular(7.r),
          border: Border.all(
            color: selected != null
                ? joTeal.withOpacity(0.4)
                : Colors.grey.shade300,
            width: selected != null ? 1.3 : 1,
          ),
        ),
        child: Row(
          children: [
            Icon(
              selected != null
                  ? Icons.check_circle_outline
                  : Icons.list_alt_outlined,
              size: 16.sp,
              color: selected != null ? joTeal : Colors.grey,
            ),
            SizedBox(width: 8.w),
            Expanded(
              child: Text(
                selected != null ? selected!.bomLabel : '-- Select BOM --',
                style: TextStyle(
                  fontSize: 13.sp,
                  color: selected != null ? Colors.black87 : Colors.grey,
                  fontWeight:
                      selected != null ? FontWeight.w600 : FontWeight.normal,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Icon(
              Icons.keyboard_arrow_down,
              size: 18.sp,
              color: selected != null ? joTeal : Colors.grey,
            ),
          ],
        ),
      ),
    );
  }
}

class _PPQtyField extends StatelessWidget {
  final TextEditingController controller;
  final int maxQty;
  final void Function(int) onChanged;
  const _PPQtyField(
      {required this.controller,
      required this.maxQty,
      required this.onChanged});

  @override
  Widget build(BuildContext context) => TextField(
        controller: controller,
        keyboardType: TextInputType.number,
        style: TextStyle(fontSize: 13.sp),
        decoration: InputDecoration(
          hintText: '0',
          hintStyle: TextStyle(fontSize: 13.sp, color: Colors.grey),
          filled: true,
          fillColor: const Color(0xFFF4F6F8),
          contentPadding:
              EdgeInsets.symmetric(horizontal: 11.w, vertical: 11.h),
          isDense: true,
          border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(7.r),
              borderSide: BorderSide(color: Colors.grey.shade300)),
          enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(7.r),
              borderSide: BorderSide(color: Colors.grey.shade300)),
          focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(7.r),
              borderSide: BorderSide(color: joTeal, width: 1.5.w)),
        ),
        onChanged: (v) {
          int parsed = int.tryParse(v) ?? 0;
          if (parsed > maxQty) {
            parsed = maxQty;
            controller.value = TextEditingValue(
                text: '$parsed',
                selection: TextSelection.collapsed(offset: '$parsed'.length));
          }
          onChanged(parsed);
        },
      );
}

class _ItemTable extends StatelessWidget {
  final BomData? bomData;
  final int splitQty;
  const _ItemTable({required this.bomData, required this.splitQty});

  @override
  Widget build(BuildContext context) {
    if (bomData == null) {
      return Container(
        padding: EdgeInsets.symmetric(vertical: 28.h),
        alignment: Alignment.center,
        child: Text(
          'Select a BOM to view item details',
          style: TextStyle(fontSize: 13.sp, color: Colors.grey.shade400),
        ),
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final totalWidth = constraints.maxWidth - 24.w; // Extra margin to avoid pixel overflow
        final idxW = totalWidth * 0.04;
        final codeW = totalWidth * 0.28;
        final nameW = totalWidth * 0.48;
        final qtyW = totalWidth * 0.20;

        Widget headerCell(String text, double width, {bool center = false}) =>
            SizedBox(
              width: width,
              child: Text(
                text,
                textAlign: center ? TextAlign.center : TextAlign.left,
                style: TextStyle(
                  fontSize: 11.sp,
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            );

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: EdgeInsets.symmetric(vertical: 9.h, horizontal: 10.w),
              decoration: BoxDecoration(
                color: joTeal,
                borderRadius: BorderRadius.circular(6.r),
              ),
              child: Row(
                children: [
                  headerCell('', idxW),
                  headerCell('ITEM CODE', codeW),
                  headerCell('ITEM NAME', nameW),
                  headerCell('REQ QTY', qtyW, center: true),
                ],
              ),
            ),
            SizedBox(height: 4.h),
            ...bomData!.items.asMap().entries.map((e) {
              final i = e.key;
              final item = e.value;
              final mult = splitQty > 0 ? splitQty : 1;
              final totalQty = item.qtyPerUnit * mult;

              return Container(
                margin: EdgeInsets.only(top: 4.h),
                padding: EdgeInsets.symmetric(vertical: 9.h, horizontal: 9.w),
                decoration: BoxDecoration(
                  color: i.isEven ? const Color(0xFFF5F5F5) : Colors.white,
                  borderRadius: BorderRadius.circular(5.r),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: Row(
                  children: [
                    SizedBox(
                      width: idxW,
                      child: Container(
                        width: 6.w,
                        height: 6.h,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade400,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                    SizedBox(
                      width: codeW,
                      child: Text(
                        item.itemCode,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: Colors.black87,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    SizedBox(
                      width: nameW,
                      child: Text(
                        item.itemName,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                    SizedBox(
                      width: qtyW,
                      child: _ColorCell(
                        value: '$totalQty',
                        fg: joTealDark,
                        bg: joTealLight,
                      ),
                    ),
                  ],
                ),
              );
            }),
            SizedBox(height: 6.h),
            Align(
              alignment: Alignment.centerRight,
              child: Text(
                'Total Rows: ${bomData!.items.length}',
                style: TextStyle(
                  fontSize: 11.sp,
                  color: Colors.grey.shade500,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _ColorCell extends StatelessWidget {
  final String value;
  final Color fg, bg;
  const _ColorCell({required this.value, required this.fg, required this.bg});

  @override
  Widget build(BuildContext context) => Container(
        margin: EdgeInsets.symmetric(horizontal: 4.w),
        padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
        decoration:
            BoxDecoration(color: bg, borderRadius: BorderRadius.circular(4.r)),
        alignment: Alignment.center,
        child: Text(value,
            textAlign: TextAlign.center,
            style: TextStyle(
                fontSize: 12.sp, color: fg, fontWeight: FontWeight.w700)),
      );
}

class _DropdownLoading extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 40.h,
      padding: EdgeInsets.symmetric(horizontal: 12.w),
      decoration: BoxDecoration(
        color: const Color(0xFFF4F6F8),
        borderRadius: BorderRadius.circular(7.r),
        border: Border.all(color: Colors.grey.shade300),
      ),
      alignment: Alignment.centerLeft,
      child: SizedBox(
        width: 15.w,
        height: 15.h,
        child: CircularProgressIndicator(strokeWidth: 2, color: joTeal),
      ),
    );
  }
}
