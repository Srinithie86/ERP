import 'package:flutter/material.dart';
import '../job_order_model.dart';
import '../widgets/job_order_widgets.dart';
import '../job_order_api_service.dart';

class JobOrderCreatePage extends StatefulWidget {
  const JobOrderCreatePage({super.key});

  @override
  State<JobOrderCreatePage> createState() => _JobOrderCreatePageState();
}

class _JobOrderCreatePageState extends State<JobOrderCreatePage> {
  final _idCtrl = TextEditingController();
  final _assignedToCtrl = TextEditingController();
  DateTime? _deliveryDate;
  DateTime? _dueDate;
  String _status = 'pending';
  String _productionType = 'Assembly';
  String _priority = 'Medium';
  final List<OrderProduct> _products = [];

  List<DropdownItem> _productionTypeList = [];
  List<DropdownItem> _priorityList = [];
  bool _isLoadingDropdowns = true;

  @override
  void initState() {
    super.initState();
    _fetchDropdowns();
  }

  Future<void> _fetchDropdowns() async {
    try {
      final results = await Future.wait([
        JobOrderApiService.fetchDropdown('155'), // Production Type
        JobOrderApiService.fetchDropdown('199'), // Priority
      ]);

      if (mounted) {
        setState(() {
          _productionTypeList = results[0];
          _priorityList = results[1];

          // Set initial values if lists are not empty
          if (_productionTypeList.isNotEmpty) {
            _productionType = _productionTypeList[0].label;
          }
          if (_priorityList.isNotEmpty) {
            _priority = _priorityList[0].label;
          }
          _isLoadingDropdowns = false;
        });
      }
    } catch (e) {
      debugPrint('Error fetching dropdowns: $e');
      if (mounted) {
        setState(() => _isLoadingDropdowns = false);
      }
    }
  }

  final _prodNameCtrl = TextEditingController();
  final _prodQtyCtrl = TextEditingController();
  final _prodIdCtrl = TextEditingController();
  final _prodBomIdCtrl = TextEditingController();

  bool get _canSave =>
      _idCtrl.text.trim().isNotEmpty &&
      _products.isNotEmpty &&
      _deliveryDate != null;

  void _addProduct() {
    final name = _prodNameCtrl.text.trim();
    final qty = int.tryParse(_prodQtyCtrl.text.trim()) ?? 0;
    final bomId = _prodBomIdCtrl.text.trim();
    if (name.isEmpty || qty <= 0) return;
    final id = _prodIdCtrl.text.trim().isEmpty
        ? 'PRD-${(_products.length + 1).toString().padLeft(4, '0')}'
        : _prodIdCtrl.text.trim();
    setState(() {
      _products
          .add(OrderProduct(name: name, qty: qty, productId: id, bomId: bomId));
      _prodNameCtrl.clear();
      _prodQtyCtrl.clear();
      _prodIdCtrl.clear();
      _prodBomIdCtrl.clear();
    });
  }

  void _removeProduct(int i) => setState(() => _products.removeAt(i));

  Future<void> _pickDueDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: now,
      lastDate: DateTime(now.year + 3),
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx)
            .copyWith(colorScheme: const ColorScheme.light(primary: joTeal)),
        child: child!,
      ),
    );
    if (picked != null) setState(() => _dueDate = picked);
  }

  String _fmtDate(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';

  void _save() {
    if (!_canSave) return;
    Navigator.pop(
      context,
      JobOrder(
        id: _idCtrl.text.trim(),
        deliveryDate: _deliveryDate!,
        dueDate: _dueDate,
        productionType: _productionType,
        priority: _priority,
        assignedTo: _assignedToCtrl.text.trim(),
        status: _status,
        products: List.from(_products),
      ),
    );
  }

  @override
  void dispose() {
    _idCtrl.dispose();
    _assignedToCtrl.dispose();
    _prodNameCtrl.dispose();
    _prodQtyCtrl.dispose();
    _prodIdCtrl.dispose();
    _prodBomIdCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F4F7),
      appBar: buildTealAppBar(
        title: 'New Job Order',
        showBack: true,
        context: context,
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(12, 14, 12, 30),
        children: [
          JORoundedCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const JOSectionHeader(label: 'Order Details'),
                const SizedBox(height: 12),
                // JOFormRow(children: [
                //   JOEditableField(
                //     label: 'ORDER ID *',
                //     child:
                //         JOTextField(controller: _idCtrl, hint: 'e.g. JO-003'),
                //   ),
                // ]),
                const SizedBox(height: 10),
                JOFormRow(children: [
                  JOEditableField(
                    label: 'PRODUCTION TYPE *',
                    child: _isLoadingDropdowns
                        ? _DropdownLoading()
                        : JODropdown(
                            hint: '-- Select --',
                            value: _productionType,
                            items: _productionTypeList.isEmpty
                                ? ['Assembly', 'Fabrication', 'Machining', 'Packaging', 'Testing']
                                : _productionTypeList.map((e) => e.label).toList(),
                            onChanged: (v) =>
                                setState(() => _productionType = v ?? 'Assembly'),
                          ),
                  ),
                  JOEditableField(
                    label: 'PRIORITY *',
                    child: _isLoadingDropdowns
                        ? _DropdownLoading()
                        : JODropdown(
                            hint: '-- Select --',
                            value: _priority,
                            items: _priorityList.isEmpty
                                ? ['High', 'Medium', 'Low']
                                : _priorityList.map((e) => e.label).toList(),
                            onChanged: (v) =>
                                setState(() => _priority = v ?? 'Medium'),
                          ),
                  ),
                ]),
                const SizedBox(height: 10),
                JOFormRow(children: [
                  JOEditableField(
                    label: 'ASSIGN TO',
                    child: JOAutocompleteField(
                      controller: _assignedToCtrl,
                      hint: 'Staff name...',
                      fetchSuggestions: JobOrderApiService.fetchStaffSuggestions,
                      onSelected: (staff) {
                        _assignedToCtrl.text = staff.name;
                      },
                    ),
                  ),
                  JOEditableField(
                    label: 'DUE DATE',
                    child: GestureDetector(
                      onTap: _pickDueDate,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 12),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF4F6F8),
                          borderRadius: BorderRadius.circular(7),
                          border: Border.all(color: Colors.grey.shade300),
                        ),
                        child: Row(children: [
                          Icon(Icons.calendar_today_outlined,
                              size: 15,
                              color: _dueDate != null ? joTeal : Colors.grey),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              _dueDate == null
                                  ? 'Select due date'
                                  : _fmtDate(_dueDate!),
                              style: TextStyle(
                                  fontSize: 13,
                                  color: _dueDate == null
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
              
              
                  
              ],
            ),
          ),
          const SizedBox(height: 14),
          JORoundedCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const JOSectionHeader(label: 'Products'),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: JOTextField(
                          controller: _prodIdCtrl, hint: 'Product Code'),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      flex: 3,
                      child: JOTextField(
                          controller: _prodNameCtrl, hint: 'Product Name'),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: JOTextField(
                          controller: _prodBomIdCtrl, hint: 'BOM ID'),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: JOTextField(
                        controller: _prodQtyCtrl,
                        hint: 'Qty',
                        keyboardType: TextInputType.number,
                      ),
                    ),
                    const SizedBox(width: 8),
                    SizedBox(
                      height: 40,
                      child: ElevatedButton(
                        onPressed: _addProduct,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: joTeal,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(7)),
                        ),
                        child: const Icon(Icons.add, size: 20),
                      ),
                    ),
                  ],
                ),
                if (_products.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  ..._products.asMap().entries.map((e) => Container(
                        margin: const EdgeInsets.only(bottom: 6),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 10),
                        decoration: BoxDecoration(
                          color: joTealLight.withOpacity(0.5),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: joTeal.withOpacity(0.2)),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 22,
                              height: 22,
                              decoration: const BoxDecoration(
                                  color: joTeal, shape: BoxShape.circle),
                              alignment: Alignment.center,
                              child: Text(
                                '${e.key + 1}',
                                style: const TextStyle(
                                    fontSize: 11,
                                    color: Colors.white,
                                    fontWeight: FontWeight.w700),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    e.value.name,
                                    style: const TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w700,
                                      color: Colors.black87,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    'ID: ${e.value.productId}',
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.grey.shade500,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: joTeal.withOpacity(0.12),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                  'BOM: ${e.value.bomId.isEmpty ? 'N/A' : e.value.bomId} | Qty: ${e.value.qty}',
                                  style: const TextStyle(
                                      fontSize: 11,
                                      color: joTealDark,
                                      fontWeight: FontWeight.w700)),
                            ),
                            const SizedBox(width: 6),
                            GestureDetector(
                              onTap: () => _removeProduct(e.key),
                              child: const Icon(Icons.close,
                                  size: 16, color: Colors.grey),
                            ),
                          ],
                        ),
                      )),
                ],
              ],
            ),
          ),
          const SizedBox(height: 16),
          Row(children: [
            Expanded(
              child: OutlinedButton(
                onPressed: () => Navigator.pop(context),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.grey.shade700,
                  side: BorderSide(color: Colors.grey.shade400),
                  padding: const EdgeInsets.symmetric(vertical: 13),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8)),
                ),
                child: const Text('Cancel',
                    style:
                        TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              flex: 2,
              child: ElevatedButton.icon(
                onPressed: _canSave ? _save : null,
                icon: const Icon(Icons.save_outlined, size: 17),
                label: const Text('Create Order',
                    style:
                        TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _canSave ? joTeal : Colors.grey.shade300,
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
    );
  }
}

class _DropdownLoading extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 40,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFF4F6F8),
        borderRadius: BorderRadius.circular(7),
        border: Border.all(color: Colors.grey.shade300),
      ),
      alignment: Alignment.centerLeft,
      child: const SizedBox(
        width: 15,
        height: 15,
        child: CircularProgressIndicator(strokeWidth: 2, color: joTeal),
      ),
    );
  }
}
