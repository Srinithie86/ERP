import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter/material.dart';
import '../production_order_model.dart';
import '../widgets/production_order_widgets.dart';
import '../production_order_api_service.dart';

class ProductionOrderCreatePage extends StatefulWidget {
  const ProductionOrderCreatePage({super.key});

  @override
  State<ProductionOrderCreatePage> createState() =>
      _ProductionOrderCreatePageState();
}

class _ProductionOrderCreatePageState extends State<ProductionOrderCreatePage> {
  final _idCtrl = TextEditingController();
  final _customerCtrl = TextEditingController();
  DateTime? _deliveryDate;
  DateTime? _dueDate;
  String _status = 'pending';
  String _productionType = 'Assembly';
  String _priority = 'Medium';
  String? _selectedProdTypeValue;
  String? _selectedPriorityValue;
  String? _selectedCustomerId;
  bool _isSaving = false;
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
        ProductionOrderApiService.fetchDropdown('155'), // Production Type
        ProductionOrderApiService.fetchDropdown('199'), // Priority
      ]);

      if (mounted) {
        setState(() {
          _productionTypeList = results[0];
          _priorityList = results[1];

          // Set initial values if lists are not empty
          if (_productionTypeList.isNotEmpty) {
            _productionType = _productionTypeList[0].label;
            _selectedProdTypeValue = _productionTypeList[0].value;
          }
          if (_priorityList.isNotEmpty) {
            _priority = _priorityList[0].label;
            _selectedPriorityValue = _priorityList[0].value;
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
  final _prodStockCtrl = TextEditingController();
  int _currentStock = 0;

  bool get _canSave => _products.isNotEmpty && _dueDate != null;

  void _addProduct() {
    final name = _prodNameCtrl.text.trim();
    final qty = int.tryParse(_prodQtyCtrl.text.trim()) ?? 0;
    final bomId = _prodBomIdCtrl.text.trim();
    if (name.isEmpty || qty <= 0) return;
    final id = _prodIdCtrl.text.trim().isEmpty
        ? 'PRD-${(_products.length + 1).toString().padLeft(4, '0')}'
        : _prodIdCtrl.text.trim();
    setState(() {
      _products.add(OrderProduct(
          name: name, code: id, qty: qty, productId: id, bomId: bomId, stockQty: _currentStock));
      _prodNameCtrl.clear();
      _prodQtyCtrl.clear();
      _prodIdCtrl.clear();
      _prodBomIdCtrl.clear();
      _prodStockCtrl.clear();
      _currentStock = 0;
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

  void _resetForm() {
    setState(() {
      _idCtrl.clear();
      _customerCtrl.clear();
      _prodNameCtrl.clear();
      _prodQtyCtrl.clear();
      _prodIdCtrl.clear();
      _prodBomIdCtrl.clear();
      _dueDate = null;
      _selectedCustomerId = null;
      _products.clear();

      // Reset dropdown selections
      if (_productionTypeList.isNotEmpty) {
        _productionType = _productionTypeList[0].label;
        _selectedProdTypeValue = _productionTypeList[0].value;
      }
      if (_priorityList.isNotEmpty) {
        _priority = _priorityList[0].label;
        _selectedPriorityValue = _priorityList[0].value;
      }
    });
  }

  Future<void> _save() async {
    if (!_canSave || _isSaving) return;

    if (_selectedProdTypeValue == null ||
        _selectedPriorityValue == null ||
        _selectedCustomerId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select all required fields')),
      );
      return;
    }

    setState(() => _isSaving = true);

    try {
      final response = await ProductionOrderApiService.saveProductionOrder(
        productionType: _selectedProdTypeValue!,
        priority: _selectedPriorityValue!,
        dueDate:
            '${_dueDate!.year}-${_dueDate!.month.toString().padLeft(2, '0')}-${_dueDate!.day.toString().padLeft(2, '0')}',
        customerId: _selectedCustomerId!,
        products: _products,
      );

      if (mounted) {
        setState(() => _isSaving = false);
        if (response['error'] == false) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                backgroundColor: Colors.green.shade800,
                content: Text(response['error_msg'] ??
                    'Production Order created successfully')),
          );
          _resetForm();
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content:
                    Text(response['error_msg'] ?? 'Failed to create order')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isSaving = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  @override
  void dispose() {
    _idCtrl.dispose();
    _customerCtrl.dispose();
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
        title: 'New Production Order',
        showBack: true,
        context: context,
      ),
      body: ListView(
        padding: EdgeInsets.fromLTRB(12, 14, 12, 30),
        children: [
          JORoundedCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const JOSectionHeader(label: 'Order Details'),
                SizedBox(height: 12.h),
                // JOFormRow(children: [
                //   JOEditableField(
                //     label: 'ORDER ID *',
                //     child:
                //         JOTextField(controller: _idCtrl, hint: 'e.g. JO-003'),
                //   ),
                // ]),
                SizedBox(height: 10.h),
                JOFormRow(children: [
                  JOEditableField(
                    label: 'PRODUCTION TYPE *',
                    child: _isLoadingDropdowns
                        ? _DropdownLoading()
                        : JODropdown(
                            hint: '-- Select --',
                            value: _productionType,
                            items: _productionTypeList.isEmpty
                                ? [
                                    'Assembly',
                                    'Fabrication',
                                    'Machining',
                                    'Packaging',
                                    'Testing'
                                  ]
                                : _productionTypeList
                                    .map((e) => e.label)
                                    .toList(),
                            onChanged: (v) {
                              final item = _productionTypeList
                                  .firstWhere((e) => e.label == v);
                              setState(() {
                                _productionType = v ?? 'Assembly';
                                _selectedProdTypeValue = item.value;
                              });
                            },
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
                            onChanged: (v) {
                              final item =
                                  _priorityList.firstWhere((e) => e.label == v);
                              setState(() {
                                _priority = v ?? 'Medium';
                                _selectedPriorityValue = item.value;
                              });
                            },
                          ),
                  ),
                ]),
                SizedBox(height: 10.h),
                JOFormRow(children: [
                  JOEditableField(
                    label: 'Customer name',
                    child: JOAutocompleteField<Map<String, dynamic>>(
                      controller: _customerCtrl,
                      hint: 'Search customer...',
                      displayStringForOption: (c) =>
                          (c['Ledger_Name'] ?? '').toString(),
                      filterOption: (c, q) => (c['Ledger_Name'] ?? '')
                          .toString()
                          .toLowerCase()
                          .contains(q.toLowerCase()),
                      fetchSuggestions:
                          ProductionOrderApiService.fetchCustomers,
                      onSelected: (c) {
                        setState(() {
                          _customerCtrl.text =
                              (c['Ledger_Name'] ?? '').toString();
                          _selectedCustomerId = (c['id'] ?? '').toString();
                        });
                      },
                    ),
                  ),
                  JOEditableField(
                    label: 'DUE DATE',
                    child: GestureDetector(
                      onTap: _pickDueDate,
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
                              color: _dueDate != null ? joTeal : Colors.grey),
                          SizedBox(width: 8.w),
                          Expanded(
                            child: Text(
                              _dueDate == null
                                  ? 'Select due date'
                                  : _fmtDate(_dueDate!),
                              style: TextStyle(
                                  fontSize: 13.sp,
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
                SizedBox(height: 10.h),
              ],
            ),
          ),
          SizedBox(height: 14.h),
          JORoundedCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const JOSectionHeader(label: 'Products'),
                SizedBox(height: 12.h),
                Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: JOAutocompleteField<Map<String, dynamic>>(
                        controller: _prodIdCtrl,
                        hint: 'Product Code',
                        displayStringForOption: (p) =>
                            (p['prd_code'] ?? '').toString(),
                        filterOption: (p, q) => (p['prd_code'] ?? '')
                            .toString()
                            .toLowerCase()
                            .contains(q.toLowerCase()),
                        fetchSuggestions: ProductionOrderApiService.fetchBoms,
                        onSelected: (p) async {
                          final pCode = (p['prd_code'] ?? '').toString();
                          setState(() {
                            _prodIdCtrl.text = pCode;
                            _prodNameCtrl.text =
                                (p['prd_name'] ?? '').toString();
                            _prodBomIdCtrl.text =
                                (p['bom_id'] ?? p['id'] ?? '').toString();
                          });
                          int stock = await ProductionOrderApiService.fetchProductStock(pCode);
                          if (mounted) {
                            setState(() {
                              _currentStock = stock;
                              _prodStockCtrl.text = stock.toString();
                            });
                          }
                        },
                      ),
                    ),
                    SizedBox(width: 8.w),
                    Expanded(
                      flex: 3,
                      child: JOAutocompleteField<Map<String, dynamic>>(
                        controller: _prodNameCtrl,
                        hint: 'Product Name',
                        displayStringForOption: (p) =>
                            (p['prd_name'] ?? '').toString(),
                        filterOption: (p, q) => (p['prd_name'] ?? '')
                            .toString()
                            .toLowerCase()
                            .contains(q.toLowerCase()),
                        fetchSuggestions: ProductionOrderApiService.fetchBoms,
                        onSelected: (p) async {
                          final pCode = (p['prd_code'] ?? '').toString();
                          setState(() {
                            _prodIdCtrl.text = pCode;
                            _prodNameCtrl.text =
                                (p['prd_name'] ?? '').toString();
                            _prodBomIdCtrl.text =
                                (p['bom_id'] ?? p['id'] ?? '').toString();
                          });
                          int stock = await ProductionOrderApiService.fetchProductStock(pCode);
                          if (mounted) {
                            setState(() {
                              _currentStock = stock;
                              _prodStockCtrl.text = stock.toString();
                            });
                          }
                        },
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 8.h),
                Row(
                  children: [
                    Expanded(
                      flex: 3,
                      child: JOAutocompleteField<Map<String, dynamic>>(
                        controller: _prodBomIdCtrl,
                        hint: 'BOM ID',
                        displayStringForOption: (p) =>
                            (p['bom_id'] ?? p['id'] ?? '').toString(),
                        filterOption: (p, q) => (p['bom_id'] ?? p['id'] ?? '')
                            .toString()
                            .toLowerCase()
                            .contains(q.toLowerCase()),
                        fetchSuggestions: ProductionOrderApiService.fetchBoms,
                        onSelected: (p) async {
                          final pCode = (p['prd_code'] ?? '').toString();
                          setState(() {
                            _prodIdCtrl.text = pCode;
                            _prodNameCtrl.text =
                                (p['prd_name'] ?? '').toString();
                            _prodBomIdCtrl.text =
                                (p['bom_id'] ?? p['id'] ?? '').toString();
                          });
                          int stock = await ProductionOrderApiService.fetchProductStock(pCode);
                          if (mounted) {
                            setState(() {
                              _currentStock = stock;
                              _prodStockCtrl.text = stock.toString();
                            });
                          }
                        },
                      ),
                    ),
                    SizedBox(width: 8.w),
                    Expanded(
                      flex: 2,
                      child: JOTextField(
                        controller: _prodStockCtrl,
                        hint: 'Stock',
                        readOnly: true,
                        keyboardType: TextInputType.number,
                        contentPadding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 11.h),
                      ),
                    ),
                    SizedBox(width: 8.w),
                    Expanded(
                      flex: 2,
                      child: JOTextField(
                        controller: _prodQtyCtrl,
                        hint: 'Qty',
                        keyboardType: TextInputType.number,
                        contentPadding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 11.h),
                      ),
                    ),
                    SizedBox(width: 8.w),
                    SizedBox(
                      height: 40.h,
                      child: ElevatedButton(
                        onPressed: _addProduct,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: joTeal,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          padding: EdgeInsets.symmetric(horizontal: 16.w),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(7.r)),
                        ),
                        child: Icon(Icons.add, size: 20.sp),
                      ),
                    ),
                  ],
                ),
                if (_products.isNotEmpty) ...[
                  SizedBox(height: 12.h),
                  ..._products.asMap().entries.map((e) => Container(
                        margin: EdgeInsets.only(bottom: 6.h),
                        padding: EdgeInsets.symmetric(
                            horizontal: 12.w, vertical: 10.h),
                        decoration: BoxDecoration(
                          color: joTealLight.withOpacity(0.5),
                          borderRadius: BorderRadius.circular(8.r),
                          border: Border.all(color: joTeal.withOpacity(0.2)),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 22.w,
                              height: 22.h,
                              decoration: BoxDecoration(
                                  color: joTeal, shape: BoxShape.circle),
                              alignment: Alignment.center,
                              child: Text(
                                '${e.key + 1}',
                                style: TextStyle(
                                    fontSize: 11.sp,
                                    color: Colors.white,
                                    fontWeight: FontWeight.w700),
                              ),
                            ),
                            SizedBox(width: 10.w),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    e.value.name,
                                    style: TextStyle(
                                      fontSize: 13.sp,
                                      fontWeight: FontWeight.w700,
                                      color: Colors.black87,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  SizedBox(height: 2.h),
                                  Text(
                                    'ID: ${e.value.productId}',
                                    style: TextStyle(
                                      fontSize: 10.sp,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.grey.shade500,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 8.w, vertical: 3.h),
                              decoration: BoxDecoration(
                                color: joTeal.withOpacity(0.12),
                                borderRadius: BorderRadius.circular(12.r),
                              ),
                              child: Text(
                                  'BOM: ${e.value.bomId.isEmpty ? 'N/A' : e.value.bomId} | Qty: ${e.value.qty} | Stock: ${e.value.stockQty}',
                                  style: TextStyle(
                                      fontSize: 11.sp,
                                      color: joTealDark,
                                      fontWeight: FontWeight.w700)),
                            ),
                            SizedBox(width: 6.w),
                            GestureDetector(
                              onTap: () => _removeProduct(e.key),
                              child: Icon(Icons.close,
                                  size: 16.sp, color: Colors.grey),
                            ),
                          ],
                        ),
                      )),
                ],
              ],
            ),
          ),
          SizedBox(height: 16.h),
          Row(children: [
            Expanded(
              child: OutlinedButton(
                onPressed: () => Navigator.pop(context),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.grey.shade700,
                  side: BorderSide(color: Colors.grey.shade400),
                  padding: EdgeInsets.symmetric(vertical: 13.h),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.r)),
                ),
                child: Text('Cancel',
                    style:
                        TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w600)),
              ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              flex: 2,
              child: ElevatedButton.icon(
                onPressed: (_canSave && !_isSaving) ? _save : null,
                icon: _isSaving
                    ? SizedBox(
                        width: 17.w,
                        height: 17.h,
                        child: const CircularProgressIndicator(
                            strokeWidth: 2, color: Colors.white))
                    : Icon(Icons.save_outlined, size: 17.sp),
                label: Text(_isSaving ? 'Creating...' : 'Create Order',
                    style: TextStyle(
                        fontSize: 14.sp, fontWeight: FontWeight.w600)),
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      (_canSave && !_isSaving) ? joTeal : Colors.grey.shade300,
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
    );
  }
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
        child: const CircularProgressIndicator(strokeWidth: 2, color: joTeal),
      ),
    );
  }
}


