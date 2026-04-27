import 'package:flutter/material.dart';
import '../job_order_model.dart';
import '../widgets/job_order_widgets.dart';
import '../widgets/bom_picker_widgets.dart';

class ProductionPlanningPage extends StatefulWidget {
  final JobOrder order;
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
  State<ProductionPlanningPage> createState() =>
      _ProductionPlanningPageState();
}

class _ProductionPlanningPageState
    extends State<ProductionPlanningPage> {
  String? _selectedBom;
  BomData? _bomData;
  int _qty = 0;
  String _priority = '';
  String _productionType = '';
  DateTime? _deadline;
  bool _isAutoFilled = false;

  final _qtyCtrl = TextEditingController();
  final _operatorCtrl = TextEditingController();
  final _descCtrl = TextEditingController();

  late final String _planId;
  late final String _today;

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

    final autoMap = autoMapBom(widget.prodIdx, widget.order.products);
    if (autoMap != null) {
      _bomData = autoMap;
      _selectedBom = autoMap.bomLabel;
      _isAutoFilled = true;
    }
  }

  @override
  void dispose() {
    _qtyCtrl.dispose();
    _operatorCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  bool get _canSave =>
      _selectedBom != null &&
      _qty > 0 &&
      _qty <= widget.availableQty &&
      _deadline != null &&
      _priority.isNotEmpty &&
      _productionType.isNotEmpty;

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
        data: Theme.of(ctx).copyWith(
            colorScheme: const ColorScheme.light(primary: joTeal)),
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
    _descCtrl.clear();
  }

  void _savePlan() {
    widget.onCreated(ProductSplit(
      label: _selectedBom!,
      qty: _qty,
      priority: _priority,
      deadline: _deadline,
    ));
    Navigator.pop(context);
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
              padding: const EdgeInsets.fromLTRB(12, 12, 12, 30),
              children: [
                _Banner2(
                  text:
                      'Job Order: ${order.id} — ${order.customer} | ${product.name}',
                ),
                const SizedBox(height: 12),
                JORoundedCard(
                  child: Column(
                    children: [
                      JOFormRow(children: [
                        JOReadOnlyField(label: 'PLAN ID', value: _planId),
                        JOReadOnlyField(label: 'ORDER NO', value: order.id),
                      ]),
                      const SizedBox(height: 10),
                      JOFormRow(children: [
                        JOReadOnlyField(
                            label: 'PRODUCT CODE',
                            value: product.productId.isNotEmpty
                                ? product.productId
                                : 'PRD-${(widget.prodIdx + 1).toString().padLeft(4, '0')}'),
                        JOReadOnlyField(
                            label: 'PRODUCT NAME', value: product.name),
                      ]),
                      const SizedBox(height: 10),
                      JOEditableField(
                        label: 'BOM ID',
                        child: _isAutoFilled
                            ? _AutoFilledBomField(bom: _bomData!)
                            : _BomPickerField(
                                selected: _bomData,
                                onTap: _openBomPicker,
                              ),
                      ),
                      const SizedBox(height: 10),
                      JOFormRow(children: [
                        JOReadOnlyField(
                            label: 'CUSTOMER NAME', value: order.customer),
                        JOEditableField(
                          label: 'QUANTITY *',
                          child: _PPQtyField(
                            controller: _qtyCtrl,
                            maxQty: widget.availableQty,
                            onChanged: (v) => setState(() => _qty = v),
                          ),
                        ),
                      ]),
                      const SizedBox(height: 10),
                      JOFormRow(children: [
                        JOEditableField(
                          label: 'OPERATOR',
                          child: JOTextField(
                              controller: _operatorCtrl,
                              hint: 'Operator name...'),
                        ),
                        JOEditableField(
                          label: 'DATE *',
                          child: GestureDetector(
                            onTap: _pickDate,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 12),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF4F6F8),
                                borderRadius: BorderRadius.circular(7),
                                border: Border.all(
                                    color: Colors.grey.shade300),
                              ),
                              child: Row(children: [
                                Icon(Icons.calendar_today_outlined,
                                    size: 15,
                                    color: _deadline != null
                                        ? joTeal
                                        : Colors.grey),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    _deadline == null
                                        ? 'Delivery date'
                                        : _fmtDate(_deadline!),
                                    style: TextStyle(
                                        fontSize: 13,
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
                      const SizedBox(height: 10),
                      JOFormRow(children: [
                        JOEditableField(
                          label: 'PRIORITY *',
                          child: JODropdown(
                            hint: '-- Select --',
                            value: _priority.isEmpty ? null : _priority,
                            items: _priorityOptions,
                            itemColor: priorityColor,
                            onChanged: (v) =>
                                setState(() => _priority = v ?? ''),
                          ),
                        ),
                        JOEditableField(
                          label: 'PRODUCTION TYPE *',
                          child: JODropdown(
                            hint: '-- Select --',
                            value: _productionType.isEmpty
                                ? null
                                : _productionType,
                            items: _prodTypeOptions,
                            onChanged: (v) =>
                                setState(() => _productionType = v ?? ''),
                          ),
                        ),
                      ]),
                      const SizedBox(height: 10),
                      JOEditableField(
                        label: 'JOB DESCRIPTION',
                        child: JOTextField(
                            controller: _descCtrl,
                            hint: 'Job description...'),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),
                JORoundedCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(children: [
                        Container(
                          width: 4,
                          height: 16,
                          decoration: BoxDecoration(
                              color: joTeal,
                              borderRadius: BorderRadius.circular(2)),
                        ),
                        const SizedBox(width: 8),
                        const Text('Item Details',
                            style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: Colors.black87)),
                        const Spacer(),
                        if (_bomData != null)
                          JOPill(
                              text:
                                  'BOM ID: ${_bomData!.bomId}  ·  ${_bomData!.items.length} rows'),
                      ]),
                      const SizedBox(height: 10),
                      _ItemTable(bomData: _bomData, splitQty: _qty),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Row(children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _reset,
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.grey.shade700,
                        side: BorderSide(color: Colors.grey.shade400),
                        padding: const EdgeInsets.symmetric(vertical: 13),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8)),
                      ),
                      child: const Text('Reset',
                          style: TextStyle(
                              fontSize: 14, fontWeight: FontWeight.w600)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 2,
                    child: ElevatedButton.icon(
                      onPressed: _canSave ? _savePlan : null,
                      icon: const Icon(Icons.save_outlined, size: 17),
                      label: const Text('Save Plan',
                          style: TextStyle(
                              fontSize: 14, fontWeight: FontWeight.w600)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            _canSave ? joTeal : Colors.grey.shade300,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(vertical: 13),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8)),
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
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          border: Border(
              bottom: BorderSide(
                  color: active ? joTeal : Colors.transparent, width: 2)),
        ),
        child: Text(label,
            style: TextStyle(
                fontSize: 11,
                fontWeight: active ? FontWeight.w700 : FontWeight.w400,
                color: active ? joTeal : Colors.grey.shade500)),
      );
}

class _Banner2 extends StatelessWidget {
  final String text;
  const _Banner2({required this.text});

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: const Color(0xFFE8F5E9),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.green.shade300),
        ),
        child: Row(children: [
          const Icon(Icons.check_circle_outline,
              color: Colors.green, size: 16),
          const SizedBox(width: 8),
          Expanded(
            child: Text(text,
                style: const TextStyle(
                    fontSize: 12,
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
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFF4F6F8),
        borderRadius: BorderRadius.circular(7),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Row(
        children: [
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              bom.bomLabel,
              style: const TextStyle(
                  fontSize: 12,
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
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
          color: selected != null
              ? const Color(0xFFF0FBF9)
              : const Color(0xFFF4F6F8),
          borderRadius: BorderRadius.circular(7),
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
              size: 16,
              color: selected != null ? joTeal : Colors.grey,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                selected != null ? selected!.bomLabel : '-- Select BOM --',
                style: TextStyle(
                  fontSize: 13,
                  color: selected != null ? Colors.black87 : Colors.grey,
                  fontWeight: selected != null
                      ? FontWeight.w600
                      : FontWeight.normal,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Icon(
              Icons.keyboard_arrow_down,
              size: 18,
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
        style: const TextStyle(fontSize: 13),
        decoration: InputDecoration(
          hintText: '0',
          hintStyle: const TextStyle(fontSize: 13, color: Colors.grey),
          filled: true,
          fillColor: const Color(0xFFF4F6F8),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 11, vertical: 11),
          isDense: true,
          border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(7),
              borderSide: BorderSide(color: Colors.grey.shade300)),
          enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(7),
              borderSide: BorderSide(color: Colors.grey.shade300)),
          focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(7),
              borderSide: const BorderSide(color: joTeal, width: 1.5)),
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
        padding: const EdgeInsets.symmetric(vertical: 28),
        alignment: Alignment.center,
        child: Text(
          'Select a BOM to view item details',
          style: TextStyle(fontSize: 13, color: Colors.grey.shade400),
        ),
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final totalWidth = constraints.maxWidth - 20;
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
                style: const TextStyle(
                  fontSize: 11,
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            );

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(vertical: 9, horizontal: 10),
              decoration: BoxDecoration(
                color: joTeal,
                borderRadius: BorderRadius.circular(6),
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
            const SizedBox(height: 4),
            ...bomData!.items.asMap().entries.map((e) {
              final i = e.key;
              final item = e.value;
              final mult = splitQty > 0 ? splitQty : 1;
              final totalQty = item.qtyPerUnit * mult;

              return Container(
                margin: const EdgeInsets.only(top: 4),
                padding: const EdgeInsets.symmetric(vertical: 9, horizontal: 9),
                decoration: BoxDecoration(
                  color: i.isEven ? const Color(0xFFF5F5F5) : Colors.white,
                  borderRadius: BorderRadius.circular(5),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: Row(
                  children: [
                    SizedBox(
                      width: idxW,
                      child: Container(
                        width: 6,
                        height: 6,
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
                        style: const TextStyle(
                          fontSize: 12,
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
                        style: const TextStyle(
                          fontSize: 12,
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
            const SizedBox(height: 6),
            Align(
              alignment: Alignment.centerRight,
              child: Text(
                'Total Rows: ${bomData!.items.length}',
                style: TextStyle(
                  fontSize: 11,
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
        margin: const EdgeInsets.symmetric(horizontal: 4),
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
        decoration:
            BoxDecoration(color: bg, borderRadius: BorderRadius.circular(4)),
        alignment: Alignment.center,
        child: Text(value,
            textAlign: TextAlign.center,
            style: TextStyle(
                fontSize: 12, color: fg, fontWeight: FontWeight.w700)),
      );
}
