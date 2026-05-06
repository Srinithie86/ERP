import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../widgets/app_colors.dart';

// ═══════════════════════════════════════════
//  SHARED DECORATIONS  (uses AppColors — no duplicate class T)
// ═══════════════════════════════════════════
BoxDecoration debitCardDec({double radius = 14}) => BoxDecoration(
  color: AppColors.voucherCard,
  borderRadius: BorderRadius.circular(radius),
  border: Border.all(color: AppColors.voucherBorder, width: 1),
  boxShadow: [
    BoxShadow(
      color: AppColors.voucherCardShadow,
      blurRadius: 12,
      offset: const Offset(0, 3),
    ),
  ],
);

InputDecoration debitFieldDec(String hint) => InputDecoration(
  hintText: hint,
  hintStyle: const TextStyle(color: AppColors.voucherHint, fontSize: 13),
  isDense: true,
  contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
  filled: true,
  fillColor: AppColors.voucherFieldFill,
  border: OutlineInputBorder(
    borderRadius: BorderRadius.circular(10),
    borderSide: const BorderSide(color: AppColors.voucherBorder),
  ),
  enabledBorder: OutlineInputBorder(
    borderRadius: BorderRadius.circular(10),
    borderSide: const BorderSide(color: AppColors.voucherBorder),
  ),
  focusedBorder: OutlineInputBorder(
    borderRadius: BorderRadius.circular(10),
    borderSide: const BorderSide(color: AppColors.voucherPrimary, width: 1.8),
  ),
);

// ═══════════════════════════════════════════
//  DATA MODEL
// ═══════════════════════════════════════════
class DebitRecord {
  final int    id;
  final String supplier;
  final String grn;
  final String quantity;
  final String amount;
  final String remarks;

  DebitRecord({
    required this.id,
    required this.supplier,
    required this.grn,
    required this.quantity,
    required this.amount,
    required this.remarks,
  });
}

// ═══════════════════════════════════════════
//  MAIN SCREEN
// ═══════════════════════════════════════════
class DebitScreen extends StatefulWidget {
  const DebitScreen({super.key});

  @override
  State<DebitScreen> createState() => _DebitScreenState();
}

class _DebitScreenState extends State<DebitScreen> {
  int _currentTab = 1; // Default to List Mode (1)

  final _quantityCtrl = TextEditingController();
  final _amountCtrl   = TextEditingController();
  final _remarksCtrl  = TextEditingController();
  final _searchCtrl   = TextEditingController();

  String? _selectedSupplier;
  String? _selectedGRN;

  final _supplierList = ['Supplier A', 'Supplier B', 'Supplier C', 'Supplier D'];
  final _grnList      = ['GRN-001', 'GRN-002', 'GRN-003', 'GRN-004'];

  final List<DebitRecord> _records = [];
  String _searchQuery = '';

  @override
  void dispose() {
    _quantityCtrl.dispose();
    _amountCtrl.dispose();
    _remarksCtrl.dispose();
    _searchCtrl.dispose();
    super.dispose();
  }

  void _onSave() {
    if (_selectedSupplier == null) { _showError('Please select Supplier/Vendor Name'); return; }
    if (_selectedGRN == null)      { _showError('Please select GRN No'); return; }
    if (_quantityCtrl.text.trim().isEmpty) { _showError('Please enter Quantity'); return; }
    if (_amountCtrl.text.trim().isEmpty)   { _showError('Please enter Amount'); return; }

    setState(() {
      _records.add(DebitRecord(
        id:       _records.length + 1,
        supplier: _selectedSupplier!,
        grn:      _selectedGRN!,
        quantity: _quantityCtrl.text.trim(),
        amount:   _amountCtrl.text.trim(),
        remarks:  _remarksCtrl.text.trim(),
      ));
      _currentTab = 1;
    });
    _clearForm();

    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: const Row(children: [
        Icon(Icons.check_circle_rounded, color: Colors.white, size: 18),
        SizedBox(width: 8),
        Text('Saved successfully!', style: TextStyle(fontWeight: FontWeight.w600)),
      ]),
      backgroundColor: AppColors.voucherSuccess,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      margin: const EdgeInsets.all(16),
      duration: const Duration(seconds: 2),
    ));
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg),
      backgroundColor: AppColors.voucherDanger,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      margin: const EdgeInsets.all(16),
    ));
  }

  void _clearForm() {
    setState(() { _selectedSupplier = null; _selectedGRN = null; });
    _quantityCtrl.clear();
    _amountCtrl.clear();
    _remarksCtrl.clear();
  }

  void _deleteRecord(int index) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        title: const Text('Delete Record',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        content: const Text('Are you sure you want to delete this record?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel', style: TextStyle(color: AppColors.voucherTextMid)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              setState(() { _records.removeAt(index); });
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.voucherDanger,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _editRecord(int index) {
    final r = _records[index];
    setState(() {
      _selectedSupplier = r.supplier;
      _selectedGRN      = r.grn;
      _quantityCtrl.text = r.quantity;
      _amountCtrl.text   = r.amount;
      _remarksCtrl.text  = r.remarks;
      _records.removeAt(index);
      _currentTab = 0; // Switch to Add Mode
    });
  }

  List<DebitRecord> get _filtered {
    if (_searchQuery.isEmpty) return _records;
    final q = _searchQuery.toLowerCase();
    return _records.where((r) =>
      r.supplier.toLowerCase().contains(q) ||
      r.grn.toLowerCase().contains(q) ||
      r.quantity.contains(q) ||
      r.amount.contains(q) ||
      r.remarks.toLowerCase().contains(q),
    ).toList();
  }

  @override
  Widget build(BuildContext context) {
    final sw    = MediaQuery.of(context).size.width;
    final isMob = sw < 600;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: AppColors.voucherPrimary,
        statusBarIconBrightness: Brightness.light,
      ),
      child: Scaffold(
        backgroundColor: AppColors.voucherBg,
        appBar: _buildAppBar(),
        body: _currentTab == 0 ? _buildForm(isMob) : _buildList(isMob),
        floatingActionButton: _currentTab == 1
            ? FloatingActionButton(
          onPressed: () => setState(() => _currentTab = 0),
          backgroundColor: AppColors.voucherPrimary,
          foregroundColor: Colors.white,
          child: const Icon(Icons.add),
        )
            : null,
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() => AppBar(
    systemOverlayStyle: const SystemUiOverlayStyle(
      statusBarColor: AppColors.voucherPrimary,
      statusBarIconBrightness: Brightness.light,
    ),
    flexibleSpace: Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.voucherGradStart, AppColors.voucherGradEnd],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
    ),
    backgroundColor: Colors.transparent,
    elevation: 0,
    iconTheme: const IconThemeData(color: Colors.white),
    leading: IconButton(
      icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 20),
      onPressed: () {
        if (_currentTab == 0) {
          setState(() => _currentTab = 1);
        } else {
          Navigator.pop(context);
        }
      },
    ),
    title: Text(_currentTab == 0 ? 'Add Debit Voucher' : 'Debit Voucher',
        style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w800,
            fontSize: 17,
            letterSpacing: 0.3)),
    actions: const [],
  );

  Widget _buildForm(bool isMob) {
    final hPad = isMob ? 14.0 : 28.0;
    final vGap = isMob ? 14.0 : 18.0;

    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(hPad, 20, hPad, 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _DebitHeaderBanner(),
          SizedBox(height: vGap + 4),
          Container(
            decoration: debitCardDec(),
            padding: EdgeInsets.all(isMob ? 16 : 22),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const _DebitSectionLabel(
                    icon: Icons.info_outline_rounded,
                    label: 'Debit Entry Information'),
                SizedBox(height: vGap),
                _debitRow2(isMob, vGap,
                  _DebitFieldBox(label: 'Supplier / Vendor Name',
                    child: _DebitDropdownField(
                      value: _selectedSupplier,
                      items: _supplierList,
                      hint: 'Select Option',
                      onChanged: (v) => setState(() => _selectedSupplier = v),
                    ),
                  ),
                  _DebitFieldBox(label: 'GRN No',
                    child: _DebitDropdownField(
                      value: _selectedGRN,
                      items: _grnList,
                      hint: 'Select Option',
                      onChanged: (v) => setState(() => _selectedGRN = v),
                    ),
                  ),
                ),
                SizedBox(height: vGap),
                _debitRow2(isMob, vGap,
                  _DebitFieldBox(label: 'Quantity',
                    child: TextField(
                      controller: _quantityCtrl,
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      style: _ts(),
                      decoration: debitFieldDec('Enter quantity'),
                    ),
                  ),
                  _DebitFieldBox(label: 'Amount',
                    child: TextField(
                      controller: _amountCtrl,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}'))
                      ],
                      style: _ts(),
                      decoration: debitFieldDec('0.00'),
                    ),
                  ),
                ),
                SizedBox(height: vGap),
                _DebitFieldBox(label: 'Remarks',
                  child: TextField(
                    controller: _remarksCtrl,
                    maxLines: 4,
                    style: _ts(),
                    decoration: debitFieldDec('Add remarks...'),
                  ),
                ),
                SizedBox(height: vGap + 4),
                _DebitSaveBtn(onTap: _onSave),
              ],
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildList(bool isMob) {
    final records = _filtered;
    return Column(
      children: [
        Container(
          color: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _searchCtrl,
                  onChanged: (v) => setState(() => _searchQuery = v),
                  style: const TextStyle(fontSize: 14),
                  decoration: InputDecoration(
                    hintText: 'Search records...',
                    hintStyle: const TextStyle(color: AppColors.voucherHint),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(color: AppColors.voucherBorder)),
                    enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(color: AppColors.voucherBorder)),
                    focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(color: AppColors.voucherPrimary, width: 1.8)),
                    filled: true,
                    fillColor: AppColors.voucherFieldFill,
                  ),
                ),
              ),
            ],
          ),
        ),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [AppColors.voucherGradStart, AppColors.voucherGradEnd],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Row(children: [
            const Icon(Icons.table_rows_rounded, color: Colors.white, size: 16),
            const SizedBox(width: 8),
            const Text('Debit Records',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 13)),
            const Spacer(),
            if (records.isNotEmpty)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.voucherWhite22,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text('${records.length} record${records.length > 1 ? 's' : ''}',
                    style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w600)),
              ),
          ]),
        ),
        Container(
          color: AppColors.voucherTableHeader,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          child: isMob ? _mobHeader() : _deskHeader(),
        ),
        Expanded(
          child: records.isEmpty
              ? _buildEmptyState()
              : ListView.builder(
            itemCount: records.length,
            itemBuilder: (_, i) {
              final r = records[i];
              final realIdx = _records.indexOf(r);
              return Container(
                color: i.isEven ? Colors.white : AppColors.voucherTableRowAlt,
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                child: isMob ? _mobRow(r, realIdx) : _deskRow(r, realIdx),
              );
            },
          ),
        ),
        if (records.isNotEmpty)
          Container(
            color: AppColors.voucherTableHeader,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Row(children: [
              const Text('Total Entries: ',
                  style: TextStyle(fontSize: 12, color: AppColors.voucherTextMid, fontWeight: FontWeight.w500)),
              Text('${records.length}',
                  style: const TextStyle(fontSize: 12, color: AppColors.voucherPrimary, fontWeight: FontWeight.w800)),
              const Spacer(),
              const Text('Total Amount: ',
                  style: TextStyle(fontSize: 12, color: AppColors.voucherTextMid, fontWeight: FontWeight.w500)),
              Text(
                '₹ ${records.fold(0.0, (s, r) => s + (double.tryParse(r.amount) ?? 0)).toStringAsFixed(2)}',
                style: const TextStyle(fontSize: 12, color: AppColors.voucherPrimary, fontWeight: FontWeight.w800),
              ),
            ]),
          ),
      ],
    );
  }

  Widget _mobHeader() {
    const s = TextStyle(fontSize: 10, fontWeight: FontWeight.w700,
        color: AppColors.voucherTextMid, letterSpacing: 0.4);
    return const Row(children: [
      SizedBox(width: 28, child: Text('#', style: s)),
      Expanded(child: Text('SUPPLIER / GRN', style: s)),
      SizedBox(width: 60, child: Text('AMT', style: s, textAlign: TextAlign.right)),
      SizedBox(width: 70, child: Text('ACTION', style: s, textAlign: TextAlign.center)),
    ]);
  }

  Widget _deskHeader() {
    const s = TextStyle(fontSize: 11, fontWeight: FontWeight.w700,
        color: AppColors.voucherTextMid, letterSpacing: 0.5);
    return const Row(children: [
      SizedBox(width: 44,  child: Text('ID', style: s)),
      SizedBox(width: 160, child: Text('SUPPLIER / VENDOR', style: s)),
      SizedBox(width: 100, child: Text('GRN NO', style: s)),
      SizedBox(width: 80,  child: Text('QTY', style: s, textAlign: TextAlign.right)),
      SizedBox(width: 100, child: Text('AMOUNT', style: s, textAlign: TextAlign.right)),
      Expanded(            child: Text('REMARKS', style: s)),
      SizedBox(width: 90,  child: Text('ACTION', style: s, textAlign: TextAlign.center)),
    ]);
  }

  Widget _mobRow(DebitRecord r, int idx) => Row(children: [
    SizedBox(width: 28, child: Container(
      width: 22, height: 22, alignment: Alignment.center,
      decoration: BoxDecoration(color: AppColors.voucherPrimaryLight, borderRadius: BorderRadius.circular(6)),
      child: Text('${r.id}', style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: AppColors.voucherPrimary)),
    )),
    Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(r.supplier, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.voucherText)),
      Text(r.grn, style: const TextStyle(fontSize: 11, color: AppColors.voucherTextMid)),
    ])),
    SizedBox(width: 60, child: Text('₹${r.amount}',
        textAlign: TextAlign.right,
        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.voucherPrimary))),
    SizedBox(width: 70, child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
      _actionBtn(Icons.edit_rounded, AppColors.voucherPrimary, () => _editRecord(idx)),
      const SizedBox(width: 6),
      _actionBtn(Icons.delete_rounded, AppColors.voucherDanger, () => _deleteRecord(idx)),
    ])),
  ]);

  Widget _deskRow(DebitRecord r, int idx) => Row(children: [
    SizedBox(width: 44, child: Container(
      width: 28, height: 28, alignment: Alignment.center,
      decoration: BoxDecoration(color: AppColors.voucherPrimaryLight, borderRadius: BorderRadius.circular(7)),
      child: Text('${r.id}', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.voucherPrimary)),
    )),
    SizedBox(width: 160, child: Row(children: [
      Container(width: 6, height: 6, decoration: const BoxDecoration(color: AppColors.voucherPrimary, shape: BoxShape.circle)),
      const SizedBox(width: 6),
      Expanded(child: Text(r.supplier, overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.voucherText))),
    ])),
    SizedBox(width: 100, child: Text(r.grn, style: const TextStyle(fontSize: 12, color: AppColors.voucherTextMid))),
    SizedBox(width: 80, child: Text(r.quantity, textAlign: TextAlign.right,
        style: const TextStyle(fontSize: 13, color: AppColors.voucherText))),
    SizedBox(width: 100, child: Text('₹ ${r.amount}', textAlign: TextAlign.right,
        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.voucherPrimary))),
    Expanded(child: Text(r.remarks.isEmpty ? '-' : r.remarks, overflow: TextOverflow.ellipsis,
        style: const TextStyle(fontSize: 12, color: AppColors.voucherTextMid))),
    SizedBox(width: 90, child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
      _actionBtn(Icons.edit_rounded, AppColors.voucherPrimary, () => _editRecord(idx)),
      const SizedBox(width: 8),
      _actionBtn(Icons.delete_rounded, AppColors.voucherDanger, () => _deleteRecord(idx)),
    ])),
  ]);

  Widget _actionBtn(IconData icon, Color color, VoidCallback onTap) =>
      InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(6),
        child: Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Icon(icon, size: 15, color: color),
        ),
      );

  Widget _buildEmptyState() => Center(
    child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      Container(
        width: 60, height: 60,
        decoration: BoxDecoration(color: AppColors.voucherPrimaryLight, borderRadius: BorderRadius.circular(16)),
        child: const Icon(Icons.inbox_rounded, color: AppColors.voucherPrimary, size: 30),
      ),
      const SizedBox(height: 12),
      const Text('No records yet', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.voucherTextMid)),
      const SizedBox(height: 4),
      Text(
        _searchQuery.isNotEmpty ? 'No matching records found' : 'Tap + to add a new debit entry',
        style: const TextStyle(fontSize: 12, color: AppColors.voucherHint),
      ),
    ]),
  );

  Widget _debitRow2(bool isMob, double gap, Widget a, Widget b) => isMob
      ? Column(children: [a, SizedBox(height: gap), b])
      : Row(children: [Expanded(child: a), const SizedBox(width: 18), Expanded(child: b)]);

  static TextStyle _ts() =>
      const TextStyle(fontSize: 13, color: AppColors.voucherText, fontWeight: FontWeight.w500);
}

// ═══════════════════════════════════════════
//  PRIVATE WIDGETS
// ═══════════════════════════════════════════
class _DebitHeaderBanner extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity,
    padding: const EdgeInsets.all(18),
    decoration: BoxDecoration(
      gradient: const LinearGradient(
        colors: [Color(0xFFBD8BF6), Color(0xFF0D8A80)],
        begin: Alignment.topLeft, end: Alignment.bottomRight,
      ),
      borderRadius: BorderRadius.circular(16),
      boxShadow: [BoxShadow(color: AppColors.voucherPrimary30, blurRadius: 18, offset: const Offset(0, 6))],
    ),
    child: Row(children: [
      Container(
        width: 52, height: 52,
        decoration: BoxDecoration(color: AppColors.voucherWhite18, borderRadius: BorderRadius.circular(14)),
        child: const Icon(Icons.remove_circle_outline_rounded, color: Colors.white, size: 28),
      ),
      const SizedBox(width: 14),
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('Debit Voucher', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 18)),
        const SizedBox(height: 3),
        Text('Record debit entries with GRN details', style: TextStyle(color: Colors.white.withValues(alpha: 0.78), fontSize: 12)),
      ])),
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: AppColors.voucherWhite18,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.voucherWhite30),
        ),
        child: const Text('DRAFT', style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w700, letterSpacing: 0.8)),
      ),
    ]),
  );
}

class _DebitSectionLabel extends StatelessWidget {
  final IconData icon;
  final String   label;
  const _DebitSectionLabel({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) => Row(children: [
    Container(
      width: 32, height: 32,
      decoration: BoxDecoration(color: AppColors.voucherPrimaryLight, borderRadius: BorderRadius.circular(8)),
      child: Icon(icon, color: AppColors.voucherPrimary, size: 17),
    ),
    const SizedBox(width: 10),
    Text(label, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.voucherText)),
  ]);
}

class _DebitFieldBox extends StatelessWidget {
  final String label;
  final Widget child;
  const _DebitFieldBox({required this.label, required this.child});

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.voucherLabel)),
      const SizedBox(height: 6),
      child,
    ],
  );
}

class _DebitDropdownField extends StatelessWidget {
  final String?               value;
  final List<String>          items;
  final String                hint;
  final ValueChanged<String?> onChanged;
  const _DebitDropdownField({
    required this.value, required this.items,
    required this.hint,  required this.onChanged,
  });

  @override
  Widget build(BuildContext context) => DropdownButtonFormField<String>(
    initialValue: value,
    decoration: debitFieldDec(''),
    hint: Text(hint, style: const TextStyle(color: AppColors.voucherHint, fontSize: 13)),
    style: const TextStyle(fontSize: 13, color: AppColors.voucherText, fontWeight: FontWeight.w500),
    icon: const Icon(Icons.keyboard_arrow_down_rounded, color: AppColors.voucherHint, size: 20),
    dropdownColor: Colors.white,
    borderRadius: BorderRadius.circular(12),
    items: items.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
    onChanged: onChanged,
  );
}

class _DebitSaveBtn extends StatelessWidget {
  final VoidCallback onTap;
  const _DebitSaveBtn({required this.onTap});

  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity, height: 50,
    decoration: BoxDecoration(
      gradient: const LinearGradient(
        colors: [AppColors.voucherGradStart, AppColors.voucherGradEnd],
        begin: Alignment.topLeft, end: Alignment.bottomRight,
      ),
      borderRadius: BorderRadius.circular(12),
      boxShadow: [BoxShadow(color: AppColors.voucherPrimary38, blurRadius: 14, offset: const Offset(0, 4))],
    ),
    child: Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: const Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          Icon(Icons.save_rounded, color: Colors.white, size: 18),
          SizedBox(width: 8),
          Text('SAVE ENTRY', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 14, letterSpacing: 1.0)),
        ]),
      ),
    ),
  );
}
