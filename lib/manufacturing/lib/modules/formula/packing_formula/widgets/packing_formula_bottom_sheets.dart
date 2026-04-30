import 'package:flutter/material.dart';
import '../../../../core/app_theme.dart';
import '../packing_formula_model.dart';
import '../packing_formula_api_service.dart';
import 'packing_formula_widgets.dart';
import 'packing_formula_form_widgets.dart';

class EditComponentsBottomSheet extends StatefulWidget {
  final List<PackingFormulaMaterial> materials;
  final Function(List<PackingFormulaMaterial>) onSaved;

  const EditComponentsBottomSheet({
    super.key,
    required this.materials,
    required this.onSaved,
  });

  @override
  State<EditComponentsBottomSheet> createState() =>
      _EditComponentsBottomSheetState();
}

class _EditComponentsBottomSheetState
    extends State<EditComponentsBottomSheet> {
  late List<PackingFormulaEditableRow> _rows;
  List<PackingFormulaProductSuggestion> _suggestions = [];

  @override
  void initState() {
    super.initState();
    _rows = widget.materials
        .map((m) => PackingFormulaEditableRow.fromMaterial(m))
        .toList();
    _loadSuggestions();
  }

  Future<void> _loadSuggestions() async {
    final list = await PackingFormulaApiService.getSuggestions(subType: 1);
    if (mounted) {
      setState(() {
        _suggestions = list;
      });
    }
  }

  @override
  void dispose() {
    for (final r in _rows) {
      r.dispose();
    }
    super.dispose();
  }

  void _saveAll(BuildContext ctx) {
    final updated = _rows.map((r) {
      return PackingFormulaMaterial(
        name: r.nameCtrl.text.isEmpty
            ? 'Unnamed Component'
            : r.nameCtrl.text,
        uom: r.uom,
        quantity: double.tryParse(r.qtyCtrl.text) ?? 0,
      );
    }).toList();

    widget.onSaved(updated);
    Navigator.pop(ctx);

    ScaffoldMessenger.of(ctx).showSnackBar(
      const SnackBar(
        content: Text('Components updated successfully'),
        backgroundColor: Colors.green,
        duration: Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final sw = MediaQuery.of(context).size.width;
    final keyboardH = MediaQuery.of(context).viewInsets.bottom;
    final bottomPadding = MediaQuery.of(context).viewPadding.bottom;

    return PackingFormulaBottomSheet(
      title: 'Edit Components',
      subtitle: '${_rows.length} components',
      child: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(
                sw * 0.05,
                sw * 0.04,
                sw * 0.05,
                keyboardH + sw * 0.04,
              ),
              child: Column(
                children: [
                  ..._rows.asMap().entries.map((e) {
                    final idx = e.key;
                    final row = e.value;
                    return Padding(
                      padding: EdgeInsets.only(bottom: sw * 0.025),
                      child: PackingFormulaEditableRowWidget(
                        row: row,
                        sw: sw,
                        index: idx,
                        canDelete: _rows.length > 1,
                        suggestions: _suggestions,
                        onDelete: () => setState(() {
                          row.dispose();
                          _rows.removeAt(idx);
                        }),
                      ),
                    );
                  }),
                ],
              ),
            ),
          ),
          Container(
            color: AppColors.surface,
            padding: EdgeInsets.fromLTRB(
              sw * 0.05,
              sw * 0.03,
              sw * 0.05,
              sw * 0.04 + bottomPadding,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Divider(color: AppColors.border, height: 1),
                SizedBox(height: sw * 0.03),
                Row(
                  children: [
                    Icon(Icons.layers_outlined,
                        size: sw * 0.035,
                        color: AppColors.textSecondary),
                    SizedBox(width: sw * 0.015),
                    Text(
                      '${_rows.length} component${_rows.length == 1 ? '' : 's'}',
                      style: TextStyle(
                          fontSize: sw * 0.03,
                          color: AppColors.textSecondary),
                    ),
                  ],
                ),
                SizedBox(height: sw * 0.03),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(context),
                        style: OutlinedButton.styleFrom(
                          padding: EdgeInsets.symmetric(
                              vertical: sw * 0.04),
                          side: const BorderSide(color: packingFormulaTeal),
                        ),
                        child: const Text(
                          'Cancel',
                          style: TextStyle(
                              fontSize: 14, color: packingFormulaTeal),
                        ),
                      ),
                    ),
                    SizedBox(width: sw * 0.03),
                    Expanded(
                      flex: 2,
                      child: ElevatedButton.icon(
                        onPressed: () => _saveAll(context),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: packingFormulaTeal,
                          foregroundColor: Colors.white,
                          padding: EdgeInsets.symmetric(
                              vertical: sw * 0.04),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        icon: const Icon(Icons.check_circle_outline,
                            size: 18),
                        label: const Text(
                          'Save Changes',
                          style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w700),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class CreatePackingFormulaBottomSheet extends StatefulWidget {
  final Function(String, String, String) onCreatePackingFormula;

  const CreatePackingFormulaBottomSheet({super.key, required this.onCreatePackingFormula});

  @override
  State<CreatePackingFormulaBottomSheet> createState() => _CreatePackingFormulaBottomSheetState();
}

class _CreatePackingFormulaBottomSheetState extends State<CreatePackingFormulaBottomSheet> {
  final _nameCtrl = TextEditingController();
  final _verCtrl = TextEditingController(text: '');
  final _nameFocus = FocusNode();
  final _verFocus = FocusNode();
  final String _category = 'PV Module';
  List<PackingFormulaProductSuggestion> _allSuggestions = [];

  @override
  void initState() {
    super.initState();
    _loadSuggestions();
  }

  @override
  void dispose() {
    _nameFocus.dispose();
    _verFocus.dispose();
    super.dispose();
  }

  Future<void> _loadSuggestions() async {
    final list = await PackingFormulaApiService.getSuggestions(subType: 2);
    if (mounted) {
      setState(() {
        _allSuggestions = list;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final sw = MediaQuery.of(context).size.width;
    return PackingFormulaBottomSheet(
      title: 'Create New Packing Formula',
      subtitle: 'Basic details',
      heightFactor: 0.6,
      child: Padding(
        padding: EdgeInsets.all(sw * 0.05),
        child: Column(
          children: [
            RawAutocomplete<PackingFormulaProductSuggestion>(
              textEditingController: _nameCtrl,
              focusNode: _nameFocus,
              displayStringForOption: (option) => option.name,
              optionsBuilder: (TextEditingValue textEditingValue) {
                if (textEditingValue.text.isEmpty) {
                  return const Iterable<PackingFormulaProductSuggestion>.empty();
                }
                final query = textEditingValue.text.toLowerCase();
                // Prioritize startsWith, but include contains
                final filtered = _allSuggestions.where((option) {
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
                      width: MediaQuery.of(context).size.width * 0.9,
                      child: ListView.builder(
                        padding: EdgeInsets.zero,
                        shrinkWrap: true,
                        itemCount: options.length,
                        itemBuilder: (BuildContext context, int index) {
                          final option = options.elementAt(index);
                          return ListTile(
                            title: Text(option.name,
                                style: const TextStyle(
                                    fontSize: 14, fontWeight: FontWeight.w600)),
                            subtitle: Text(option.code,
                                style: const TextStyle(fontSize: 12)),
                            onTap: () => onSelected(option),
                          );
                        },
                      ),
                    ),
                  ),
                );
              },
              onSelected: (PackingFormulaProductSuggestion selection) {
                setState(() {
                  _nameCtrl.text = selection.name;
                  _verCtrl.text = selection.code;
                });
              },
              fieldViewBuilder:
                  (context, controller, focusNode, onFieldSubmitted) {
                return TextField(
                  controller: controller,
                  focusNode: focusNode,
                  decoration: const InputDecoration(
                    labelText: 'Product Name',
                    hintText: 'Enter name or code...',
                    suffixIcon: Icon(Icons.search, size: 20),
                  ),
                );
              },
            ),
            SizedBox(height: sw * 0.03),
            RawAutocomplete<PackingFormulaProductSuggestion>(
              textEditingController: _verCtrl,
              focusNode: _verFocus,
              displayStringForOption: (option) => option.code,
              optionsBuilder: (TextEditingValue textEditingValue) {
                if (textEditingValue.text.isEmpty) {
                  return const Iterable<PackingFormulaProductSuggestion>.empty();
                }
                final query = textEditingValue.text.toLowerCase();
                final filtered = _allSuggestions.where((option) {
                  return option.code.toLowerCase().contains(query) ||
                      option.name.toLowerCase().contains(query);
                }).toList();

                filtered.sort((a, b) {
                  final aStarts = a.code.toLowerCase().startsWith(query);
                  final bStarts = b.code.toLowerCase().startsWith(query);
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
                      width: MediaQuery.of(context).size.width * 0.9,
                      child: ListView.builder(
                        padding: EdgeInsets.zero,
                        shrinkWrap: true,
                        itemCount: options.length,
                        itemBuilder: (BuildContext context, int index) {
                          final option = options.elementAt(index);
                          return ListTile(
                            title: Text(option.code,
                                style: const TextStyle(
                                    fontSize: 14, fontWeight: FontWeight.w600)),
                            subtitle: Text(option.name,
                                style: const TextStyle(fontSize: 12)),
                            onTap: () => onSelected(option),
                          );
                        },
                      ),
                    ),
                  ),
                );
              },
              onSelected: (PackingFormulaProductSuggestion selection) {
                setState(() {
                  _nameCtrl.text = selection.name;
                  _verCtrl.text = selection.code;
                });
              },
              fieldViewBuilder:
                  (context, controller, focusNode, onFieldSubmitted) {
                return TextField(
                  controller: controller,
                  focusNode: focusNode,
                  decoration: const InputDecoration(
                    labelText: 'Product Code',
                    hintText: 'Enter code or name...',
                  ),
                );
              },
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => widget.onCreatePackingFormula(
                    _nameCtrl.text, _category, _verCtrl.text),
                style: ElevatedButton.styleFrom(
                  backgroundColor: packingFormulaTeal,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                child: const Text('Next: Add Components',
                    style: TextStyle(fontWeight: FontWeight.w700)),
              ),
            ),
            SizedBox(height: MediaQuery.of(context).viewPadding.bottom + 10),
          ],
        ),
      ),
    );
  }
}

class AddMaterialsBottomSheet extends StatefulWidget {
  final String productName, category, version;
  final Function(PackingFormulaItem) onPackingFormulaCreated;

  const AddMaterialsBottomSheet({
    super.key,
    required this.productName,
    required this.category,
    required this.version,
    required this.onPackingFormulaCreated,
  });

  @override
  State<AddMaterialsBottomSheet> createState() =>
      _AddMaterialsBottomSheetState();
}

class _AddMaterialsBottomSheetState extends State<AddMaterialsBottomSheet> {
  final List<PackingFormulaEditableRow> _rows = [PackingFormulaEditableRow()];
  List<PackingFormulaProductSuggestion> _suggestions = [];

  @override
  void initState() {
    super.initState();
    _loadSuggestions();
  }

  Future<void> _loadSuggestions() async {
    final list = await PackingFormulaApiService.getSuggestions(subType: 1);
    if (mounted) {
      setState(() {
        _suggestions = list;
      });
    }
  }

  void _submit() async {
    // Show a snackbar or loading indicator
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
          content: Text('Saving Packing Formula...'), duration: Duration(seconds: 1)),
    );

    final res = await PackingFormulaApiService.savePackingFormula(
      productName: widget.productName,
      productCode: widget.version, // Using version text as code for now
      category: widget.category,
      version: widget.version,
      uom: 'Nos',
      rows: _rows,
    );

    if (res['error'] == false) {
      final newPackingFormula = PackingFormulaItem(
        id: (res['packing_formula_id'] ?? 'Packing Formula-${100 + PackingFormulaSampleData.packingFormulas.length}')
            .toString(),
        productName: widget.productName,
        category: widget.category,
        version: widget.version,
        status: 'active',
        materialCount: _rows.length,
        updatedAt: DateTime.now(),
      );
      widget.onPackingFormulaCreated(newPackingFormula);
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(res['error_msg'] ?? 'Packing Formula saved successfully'),
              backgroundColor: Colors.green),
        );
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(res['message'] ?? 'Failed to save Packing Formula'),
              backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final sw = MediaQuery.of(context).size.width;
    return PackingFormulaBottomSheet(
      title: 'Add Components',
      subtitle: widget.productName,
      child: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: EdgeInsets.all(sw * 0.05),
              itemCount: _rows.length,
              itemBuilder: (_, i) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: PackingFormulaEditableRowWidget(
                  row: _rows[i],
                  sw: sw,
                  index: i,
                  canDelete: _rows.length > 1,
                  suggestions: _suggestions,
                  onDelete: () => setState(() => _rows.removeAt(i)),
                ),
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.all(sw * 0.05),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () =>
                        setState(() => _rows.add(PackingFormulaEditableRow())),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: const Text('Add Row'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _submit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: packingFormulaTeal,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: const Text('Finish',
                        style: TextStyle(fontWeight: FontWeight.w700)),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: MediaQuery.of(context).viewPadding.bottom),
        ],
      ),
    );
  }
}
