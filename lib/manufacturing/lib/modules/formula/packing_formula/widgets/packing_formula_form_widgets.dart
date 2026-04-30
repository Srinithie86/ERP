import 'package:flutter/material.dart';
import '../../../../core/app_theme.dart';
import '../packing_formula_model.dart';
import '../packing_formula_api_service.dart';
import 'packing_formula_widgets.dart';

class PackingFormulaEditableRow {
  final TextEditingController nameCtrl;
  final TextEditingController itemCodeCtrl;
  final TextEditingController qtyCtrl;
  final FocusNode nameFocus;
  String uom;

  PackingFormulaEditableRow({
    String name = '',
    String itemCode = '',
    String qty = '',
    this.uom = 'pcs',
  })  : nameCtrl = TextEditingController(text: name),
        itemCodeCtrl = TextEditingController(text: itemCode),
        qtyCtrl = TextEditingController(text: qty),
        nameFocus = FocusNode();

  factory PackingFormulaEditableRow.fromMaterial(PackingFormulaMaterial m) => PackingFormulaEditableRow(
        name: m.name,
        qty: m.quantity.toString(),
        uom: m.uom,
      );

  void dispose() {
    nameCtrl.dispose();
    itemCodeCtrl.dispose();
    qtyCtrl.dispose();
    nameFocus.dispose();
  }
}

class PackingFormulaEditableRowWidget extends StatefulWidget {
  final PackingFormulaEditableRow row;
  final double sw;
  final int index;
  final bool canDelete;
  final VoidCallback onDelete;
  final List<PackingFormulaProductSuggestion> suggestions;

  const PackingFormulaEditableRowWidget({
    super.key,
    required this.row,
    required this.sw,
    required this.index,
    required this.canDelete,
    required this.onDelete,
    this.suggestions = const [],
  });

  @override
  State<PackingFormulaEditableRowWidget> createState() => _PackingFormulaEditableRowWidgetState();
}

class _PackingFormulaEditableRowWidgetState extends State<PackingFormulaEditableRowWidget> {
  InputDecoration _compact(String hint) => InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(
            fontSize: widget.sw * 0.028, color: AppColors.textHint),
        filled: true,
        fillColor: AppColors.background,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(widget.sw * 0.02),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(widget.sw * 0.02),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(widget.sw * 0.02),
          borderSide: const BorderSide(color: packingFormulaTeal, width: 1.5),
        ),
        contentPadding: EdgeInsets.symmetric(
            horizontal: widget.sw * 0.025, vertical: widget.sw * 0.02),
        isDense: true,
      );

  @override
  Widget build(BuildContext context) {
    final sw = widget.sw;
    return Container(
      padding: EdgeInsets.all(sw * 0.03),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(sw * 0.03),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: sw * 0.06,
                height: sw * 0.06,
                decoration: const BoxDecoration(
                  color: packingFormulaTealLight,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    '${widget.index + 1}',
                    style: TextStyle(
                      fontSize: sw * 0.028,
                      fontWeight: FontWeight.w700,
                      color: packingFormulaTeal,
                    ),
                  ),
                ),
              ),
              const Spacer(),
              if (widget.canDelete)
                GestureDetector(
                  onTap: widget.onDelete,
                  child: Icon(Icons.delete_outline,
                      color: AppColors.danger, size: sw * 0.05),
                ),
            ],
          ),
          SizedBox(height: sw * 0.02),
          RawAutocomplete<PackingFormulaProductSuggestion>(
            textEditingController: widget.row.nameCtrl,
            focusNode: widget.row.nameFocus,
            displayStringForOption: (option) => option.name,
            optionsBuilder: (TextEditingValue textEditingValue) {
              if (textEditingValue.text.isEmpty) {
                return const Iterable<PackingFormulaProductSuggestion>.empty();
              }
              final query = textEditingValue.text.toLowerCase();
              final filtered = widget.suggestions.where((option) {
                return option.name.toLowerCase().contains(query) ||
                    option.code.toLowerCase().contains(query);
              }).toList();

              filtered.sort((a, b) {
                final aStarts = a.name.toLowerCase().startsWith(query);
                final bStarts = b.name.toLowerCase().startsWith(query);
                if (aStarts && !bStarts) return -1;
                if (!aStarts && bStarts) return 1;
                return 0;
              });

              return filtered;
            },
            optionsViewBuilder: (context, onSelected, options) {
              return Align(
                alignment: Alignment.topLeft,
                child: Material(
                  elevation: 4.0,
                  borderRadius: BorderRadius.circular(8),
                  child: SizedBox(
                    width: sw * 0.8,
                    child: ListView.builder(
                      padding: EdgeInsets.zero,
                      shrinkWrap: true,
                      itemCount: options.length,
                      itemBuilder: (BuildContext context, int index) {
                        final option = options.elementAt(index);
                        return ListTile(
                          title: Text(option.name,
                              style: const TextStyle(
                                  fontSize: 13, fontWeight: FontWeight.w600)),
                          subtitle: Text(option.code,
                              style: const TextStyle(fontSize: 11)),
                          onTap: () => onSelected(option),
                        );
                      },
                    ),
                  ),
                ),
              );
            },
            fieldViewBuilder:
                (context, controller, focusNode, onFieldSubmitted) {
              return TextField(
                controller: controller,
                focusNode: focusNode,
                style:
                    TextStyle(fontSize: sw * 0.032, fontWeight: FontWeight.w600),
                decoration: _compact('Component Name'),
              );
            },
          ),
          SizedBox(height: sw * 0.02),
          Row(
            children: [
              Expanded(
                flex: 2,
                child: TextField(
                  controller: widget.row.qtyCtrl,
                  keyboardType: TextInputType.number,
                  style: TextStyle(fontSize: sw * 0.032),
                  decoration: _compact('Qty'),
                ),
              ),
              SizedBox(width: sw * 0.02),
              Expanded(
                child: Container(
                  height: sw * 0.09,
                  padding: EdgeInsets.symmetric(horizontal: sw * 0.02),
                  decoration: BoxDecoration(
                    color: AppColors.background,
                    borderRadius: BorderRadius.circular(sw * 0.02),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Center(
                    child: Text(widget.row.uom,
                        style: TextStyle(fontSize: sw * 0.03)),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
