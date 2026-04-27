import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:erp_localization/erp_localization.dart';

// ═══════════════════════════════════════════
//  THEME COLORS (same as Payment Voucher)
// ═══════════════════════════════════════════
class T {
  static const primary      = Color(0xFF26A69A);
  static const primaryDark  = Color(0xFF00897B);
  static const primaryLight = Color(0xFFE0F2F1);
  static const accent       = Color(0xFF00BCD4);
  static const bg           = Color(0xFFF0F4F8);
  static const card         = Colors.white;
  static const border       = Color(0xFFDDE3EA);
  static const label        = Color(0xFF546E7A);
  static const hint         = Color(0xFFB0BEC5);
  static const text         = Color(0xFF263238);
  static const textMid      = Color(0xFF607D8B);
  static const success      = Color(0xFF43A047);
  static const warn         = Color(0xFFFFA726);
  static const danger       = Color(0xFFEF5350);
  static const gradStart    = Color(0xFF26A69A);
  static const gradEnd      = Color(0xFF00ACC1);
}

// ═══════════════════════════════════════════
//  SHARED DECORATIONS
// ═══════════════════════════════════════════
BoxDecoration cardDec({double radius = 14}) => BoxDecoration(
  color: T.card,
  borderRadius: BorderRadius.circular(radius),
  border: Border.all(color: T.border, width: 1),
  boxShadow: [
    BoxShadow(
      color: Colors.black.withOpacity(0.055),
      blurRadius: 12,
      offset: const Offset(0, 3),
    ),
  ],
);

InputDecoration fieldDec(String hint, {IconData? icon}) => InputDecoration(
  hintText: hint,
  hintStyle: const TextStyle(color: T.hint, fontSize: 13),
  prefixIcon: icon != null ? Icon(icon, color: T.hint, size: 18) : null,
  isDense: true,
  contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
  filled: true,
  fillColor: const Color(0xFFF8FAFB),
  border: OutlineInputBorder(
    borderRadius: BorderRadius.circular(10),
    borderSide: const BorderSide(color: T.border),
  ),
  enabledBorder: OutlineInputBorder(
    borderRadius: BorderRadius.circular(10),
    borderSide: const BorderSide(color: T.border),
  ),
  focusedBorder: OutlineInputBorder(
    borderRadius: BorderRadius.circular(10),
    borderSide: const BorderSide(color: T.primary, width: 1.8),
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
  // Tab: 0 = Entry, 1 = Records
  int _currentTab = 0;

  // Controllers
  final _quantityCtrl = TextEditingController();
  final _amountCtrl   = TextEditingController();
  final _remarksCtrl  = TextEditingController();
  final _searchCtrl   = TextEditingController();

  // Dropdowns
  String? _selectedSupplier;
  String? _selectedGRN;

  final _supplierList = ['Supplier A', 'Supplier B', 'Supplier C', 'Supplier D'];
  final _grnList      = ['GRN-001', 'GRN-002', 'GRN-003', 'GRN-004'];

  // Records
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

  // ─────────────────────────────────────────
  //  LOGIC
  // ─────────────────────────────────────────
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
      content: Row(children: [
        const Icon(Icons.check_circle_rounded, color: Colors.white, size: 18),
        const SizedBox(width: 8),
        Text(AppLocalization.of('Saved successfully!'), style: const TextStyle(fontWeight: FontWeight.w600)),
      ]),
      backgroundColor: T.success,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      margin: const EdgeInsets.all(16),
      duration: const Duration(seconds: 2),
    ));
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg),
      backgroundColor: T.danger,
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
        title: Text(AppLocalization.of('Delete Record'),
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        content: Text(AppLocalization.of('Are you sure you want to delete this record?')),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(AppLocalization.of('Cancel'), style: TextStyle(color: T.textMid)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              setState(() {
                _records.removeAt(index);
              });
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: T.danger,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: Text(AppLocalization.of('Delete')),
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
      _currentTab = 0;
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

  // ─────────────────────────────────────────
  //  BUILD
  // ─────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final sw    = MediaQuery.of(context).size.width;
    final isMob = sw < 600;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Color(0xFF26A69A),
        statusBarIconBrightness: Brightness.light,
      ),
      child: Scaffold(
        backgroundColor: T.bg,
        appBar: _buildAppBar(),
        body: _currentTab == 0 ? _buildForm(isMob) : _buildList(isMob),
        floatingActionButton: _currentTab == 1
            ? FloatingActionButton(
          onPressed: () => setState(() => _currentTab = 0),
          backgroundColor: T.primary,
          foregroundColor: Colors.white,
          child: const Icon(Icons.add),
        )
            : null,
      ),
    );
  }

  // ── APP BAR ───────────────────────────────
  PreferredSizeWidget _buildAppBar() => AppBar(
    systemOverlayStyle: const SystemUiOverlayStyle(
      statusBarColor: Color(0xFF26A69A),
      statusBarIconBrightness: Brightness.light,
    ),
    flexibleSpace: Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [T.gradStart, T.gradEnd],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
    ),
    backgroundColor: Colors.transparent,
    elevation: 0,
    leading: Builder(
      builder: (ctx) => IconButton(
        icon: Container(
          width: 34, height: 34,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.15),
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Icon(Icons.arrow_back_ios_rounded,
              color: Colors.white, size: 16),
        ),
        onPressed: () => Navigator.pop(context),
      ),
    ),
    title: Text(AppLocalization.of('Debit Voucher'),
        style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w800,
            fontSize: 17,
            letterSpacing: 0.3)),
    bottom: PreferredSize(
      preferredSize: const Size.fromHeight(46),
      child: Container(
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [T.gradStart, T.gradEnd],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Row(
          children: [
            _buildTab(0, Icons.edit_note_rounded,  AppLocalization.of('Entry')),
            _buildTab(1, Icons.list_alt_rounded,   AppLocalization.of('Records')),
          ],
        ),
      ),
    ),
    actions: [
      Container(
        margin: const EdgeInsets.only(right: 4),
        child: IconButton(
          icon: Container(
            width: 34, height: 34,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.notifications_outlined,
                color: Colors.white, size: 18),
          ),
          onPressed: () {},
        ),
      ),
    ],
  );

  Widget _buildTab(int index, IconData icon, String label) {
    final active = _currentTab == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _currentTab = index),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: active ? Colors.white : Colors.transparent,
                width: 3,
              ),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 18,
                  color: active ? Colors.white : Colors.white.withOpacity(0.6)),
              const SizedBox(width: 6),
              Text(label,
                  style: TextStyle(
                    color: active ? Colors.white : Colors.white.withOpacity(0.6),
                    fontWeight: active ? FontWeight.w700 : FontWeight.normal,
                    fontSize: 14,
                  )),
            ],
          ),
        ),
      ),
    );
  }

  // ── FORM ──────────────────────────────────
  Widget _buildForm(bool isMob) {
    final hPad = isMob ? 14.0 : 28.0;
    final vGap = isMob ? 14.0 : 18.0;

    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(hPad, 20, hPad, 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header banner
          _HeaderBanner(),
          SizedBox(height: vGap + 4),

          // Form card
          Container(
            decoration: cardDec(),
            padding: EdgeInsets.all(isMob ? 16 : 22),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const _SectionLabel(
                    icon: Icons.info_outline_rounded,
                    label: 'Debit Entry Information'),
                SizedBox(height: vGap),

                // Supplier | GRN
                _row2(isMob, vGap,
                  _FieldBox(label: 'Supplier / Vendor Name',
                    child: _DropdownField(
                      value: _selectedSupplier,
                      items: _supplierList,
                      hint: 'Select Option',
                      icon: Icons.person_outline_rounded,
                      onChanged: (v) => setState(() => _selectedSupplier = v),
                    ),
                  ),
                  _FieldBox(label: 'GRN No',
                    child: _DropdownField(
                      value: _selectedGRN,
                      items: _grnList,
                      hint: 'Select Option',
                      icon: Icons.receipt_outlined,
                      onChanged: (v) => setState(() => _selectedGRN = v),
                    ),
                  ),
                ),
                SizedBox(height: vGap),

                // Quantity | Amount
                _row2(isMob, vGap,
                  _FieldBox(label: 'Quantity',
                    child: TextField(
                      controller: _quantityCtrl,
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      style: _ts(),
                      decoration: fieldDec('Enter quantity',
                          icon: Icons.inventory_2_outlined),
                    ),
                  ),
                  _FieldBox(label: 'Amount',
                    child: TextField(
                      controller: _amountCtrl,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}'))
                      ],
                      style: _ts(),
                      decoration: fieldDec('0.00',
                          icon: Icons.currency_rupee_rounded),
                    ),
                  ),
                ),
                SizedBox(height: vGap),

                // Remarks
                _FieldBox(label: 'Remarks',
                  child: TextField(
                    controller: _remarksCtrl,
                    maxLines: 4,
                    style: _ts(),
                    decoration: fieldDec('Add remarks...',
                        icon: Icons.notes_rounded),
                  ),
                ),
                SizedBox(height: vGap + 4),

                // Save button
                _SaveBtn(onTap: _onSave),
              ],
            ),
          ),

          const SizedBox(height: 16),
        ],
      ),
    );
  }

  // ── LIST ──────────────────────────────────
  Widget _buildList(bool isMob) {
    final records = _filtered;

    return Column(
      children: [
        // Search bar
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
                    hintText: AppLocalization.of('Search records...'),
                    hintStyle: const TextStyle(color: T.hint),
                    prefixIcon: const Icon(Icons.search, color: T.primary, size: 20),
                    suffixIcon: _searchQuery.isNotEmpty
                        ? IconButton(
                      icon: const Icon(Icons.clear, size: 18, color: T.textMid),
                      onPressed: () {
                        _searchCtrl.clear();
                        setState(() => _searchQuery = '');
                      },
                    )
                        : null,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(color: T.border)),
                    enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(color: T.border)),
                    focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(color: T.primary, width: 1.8)),
                    filled: true,
                    fillColor: const Color(0xFFF8FAFB),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              _iconBtn(Icons.refresh_rounded, () {
                _searchCtrl.clear();
                setState(() => _searchQuery = '');
              }),
            ],
          ),
        ),

        // Table header strip
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [T.gradStart, T.gradEnd],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Row(children: [
            const Icon(Icons.table_rows_rounded, color: Colors.white, size: 16),
            const SizedBox(width: 8),
            Text(AppLocalization.of('Debit Records'),
                style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 13)),
            const Spacer(),
            if (records.isNotEmpty)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.22),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text('${records.length} record${records.length > 1 ? 's' : ''}',
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.w600)),
              ),
          ]),
        ),

        // Column headers
        Container(
          color: const Color(0xFFF1F8F7),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          child: isMob ? _mobHeader() : _deskHeader(),
        ),

        // Rows
        Expanded(
          child: records.isEmpty
              ? _buildEmptyState()
              : ListView.builder(
            itemCount: records.length,
            itemBuilder: (_, i) {
              final r = records[i];
              final realIdx = _records.indexOf(r);
              return Container(
                color: i.isEven ? Colors.white : const Color(0xFFF8FBFB),
                padding: const EdgeInsets.symmetric(
                    horizontal: 12, vertical: 10),
                child: isMob
                    ? _mobRow(r, realIdx)
                    : _deskRow(r, realIdx),
              );
            },
          ),
        ),

        // Footer
        if (records.isNotEmpty)
          Container(
            color: const Color(0xFFF1F8F7),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Row(children: [
              Text(AppLocalization.of('Total Entries') + ': ',
                  style: TextStyle(fontSize: 12, color: T.textMid,
                      fontWeight: FontWeight.w500)),
              Text('${records.length}',
                  style: const TextStyle(fontSize: 12, color: T.primary,
                      fontWeight: FontWeight.w800)),
              const Spacer(),
              Text(AppLocalization.of('Total Amount') + ': ',
                  style: TextStyle(fontSize: 12, color: T.textMid,
                      fontWeight: FontWeight.w500)),
              Text(
                '₹ ${records.fold(0.0, (s, r) => s + (double.tryParse(r.amount) ?? 0)).toStringAsFixed(2)}',
                style: const TextStyle(fontSize: 12, color: T.primary,
                    fontWeight: FontWeight.w800),
              ),
            ]),
          ),
      ],
    );
  }

  // ── TABLE HEADERS ─────────────────────────
  Widget _mobHeader() {
    const s = TextStyle(fontSize: 10, fontWeight: FontWeight.w700,
        color: T.textMid, letterSpacing: 0.4);
    return Row(children: const [
      SizedBox(width: 28, child: Text('#', style: s)),
      Expanded(child: Text('SUPPLIER / GRN', style: s)),
      SizedBox(width: 60, child: Text('AMT', style: s, textAlign: TextAlign.right)),
      SizedBox(width: 70, child: Text('ACTION', style: s, textAlign: TextAlign.center)),
    ]);
  }

  Widget _deskHeader() {
    const s = TextStyle(fontSize: 11, fontWeight: FontWeight.w700,
        color: T.textMid, letterSpacing: 0.5);
    return Row(children: const [
      SizedBox(width: 44,  child: Text('ID', style: s)),
      SizedBox(width: 160, child: Text('SUPPLIER / VENDOR', style: s)),
      SizedBox(width: 100, child: Text('GRN NO', style: s)),
      SizedBox(width: 80,  child: Text('QTY', style: s, textAlign: TextAlign.right)),
      SizedBox(width: 100, child: Text('AMOUNT', style: s, textAlign: TextAlign.right)),
      Expanded(            child: Text('REMARKS', style: s)),
      SizedBox(width: 90,  child: Text('ACTION', style: s, textAlign: TextAlign.center)),
    ]);
  }

  // ── TABLE ROWS ────────────────────────────
  Widget _mobRow(DebitRecord r, int idx) => Row(
    children: [
      SizedBox(
        width: 28,
        child: Container(
          width: 22, height: 22,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: T.primaryLight,
            borderRadius: BorderRadius.circular(6),
          ),
          child: Text('${r.id}',
              style: const TextStyle(fontSize: 10,
                  fontWeight: FontWeight.w700, color: T.primary)),
        ),
      ),
      Expanded(
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(r.supplier,
              style: const TextStyle(fontSize: 12,
                  fontWeight: FontWeight.w600, color: T.text)),
          Text(r.grn,
              style: const TextStyle(fontSize: 11, color: T.textMid)),
        ]),
      ),
      SizedBox(
        width: 60,
        child: Text('₹${r.amount}',
            textAlign: TextAlign.right,
            style: const TextStyle(fontSize: 12,
                fontWeight: FontWeight.w600, color: T.primary)),
      ),
      SizedBox(
        width: 70,
        child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          _actionBtn(Icons.edit_rounded, T.primary, () => _editRecord(idx)),
          const SizedBox(width: 6),
          _actionBtn(Icons.delete_rounded, T.danger, () => _deleteRecord(idx)),
        ]),
      ),
    ],
  );

  Widget _deskRow(DebitRecord r, int idx) => Row(
    children: [
      SizedBox(
        width: 44,
        child: Container(
          width: 28, height: 28,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: T.primaryLight,
            borderRadius: BorderRadius.circular(7),
          ),
          child: Text('${r.id}',
              style: const TextStyle(fontSize: 11,
                  fontWeight: FontWeight.w700, color: T.primary)),
        ),
      ),
      SizedBox(
        width: 160,
        child: Row(children: [
          Container(
            width: 6, height: 6,
            decoration: const BoxDecoration(color: T.primary, shape: BoxShape.circle),
          ),
          const SizedBox(width: 6),
          Expanded(
            child: Text(r.supplier,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 13,
                    fontWeight: FontWeight.w600, color: T.text)),
          ),
        ]),
      ),
      SizedBox(width: 100,
          child: Text(r.grn,
              style: const TextStyle(fontSize: 12, color: T.textMid))),
      SizedBox(width: 80,
          child: Text(r.quantity,
              textAlign: TextAlign.right,
              style: const TextStyle(fontSize: 13, color: T.text))),
      SizedBox(width: 100,
          child: Text('₹ ${r.amount}',
              textAlign: TextAlign.right,
              style: const TextStyle(fontSize: 13,
                  fontWeight: FontWeight.w600, color: T.primary))),
      Expanded(
          child: Text(
            r.remarks.isEmpty ? '-' : r.remarks,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 12, color: T.textMid),
          )),
      SizedBox(
        width: 90,
        child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          _actionBtn(Icons.edit_rounded, T.primary, () => _editRecord(idx)),
          const SizedBox(width: 8),
          _actionBtn(Icons.delete_rounded, T.danger, () => _deleteRecord(idx)),
        ]),
      ),
    ],
  );

  Widget _actionBtn(IconData icon, Color color, VoidCallback onTap) =>
      InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(6),
        child: Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Icon(icon, size: 15, color: color),
        ),
      );

  Widget _buildEmptyState() => Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 60, height: 60,
          decoration: BoxDecoration(
            color: T.primaryLight,
            borderRadius: BorderRadius.circular(16),
          ),
          child: const Icon(Icons.inbox_rounded, color: T.primary, size: 30),
        ),
        const SizedBox(height: 12),
        const Text('No records yet',
            style: TextStyle(fontSize: 14,
                fontWeight: FontWeight.w600, color: T.textMid)),
        const SizedBox(height: 4),
        Text(
          _searchQuery.isNotEmpty
              ? 'No matching records found'
              : 'Tap + to add a new debit entry',
          style: const TextStyle(fontSize: 12, color: T.hint),
        ),
      ],
    ),
  );

  Widget _iconBtn(IconData icon, VoidCallback onTap) => InkWell(
    onTap: onTap,
    borderRadius: BorderRadius.circular(8),
    child: Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
            colors: [T.gradStart, T.gradEnd],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(icon, color: Colors.white, size: 20),
    ),
  );

  Widget _row2(bool isMob, double gap, Widget a, Widget b) => isMob
      ? Column(children: [a, SizedBox(height: gap), b])
      : Row(children: [
    Expanded(child: a), const SizedBox(width: 18), Expanded(child: b),
  ]);

  static TextStyle _ts() =>
      const TextStyle(fontSize: 13, color: T.text, fontWeight: FontWeight.w500);
}

// ═══════════════════════════════════════════
//  HEADER BANNER
// ═══════════════════════════════════════════
class _HeaderBanner extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity,
    padding: const EdgeInsets.all(18),
    decoration: BoxDecoration(
      gradient: const LinearGradient(
        colors: [Color(0xFFBD8BF6), Color(0xFF0D8A80)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      borderRadius: BorderRadius.circular(16),
      boxShadow: [
        BoxShadow(
          color: T.primary.withOpacity(0.30),
          blurRadius: 18,
          offset: const Offset(0, 6),
        ),
      ],
    ),
    child: Row(
      children: [
        Container(
          width: 52, height: 52,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.18),
            borderRadius: BorderRadius.circular(14),
          ),
          child: const Icon(Icons.remove_circle_outline_rounded,
              color: Colors.white, size: 28),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text('Debit Voucher',
                style: TextStyle(color: Colors.white,
                    fontWeight: FontWeight.w900, fontSize: 18)),
            const SizedBox(height: 3),
            Text('Record debit entries with GRN details',
                style: TextStyle(
                    color: Colors.white.withOpacity(0.78), fontSize: 12)),
          ]),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.18),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white.withOpacity(0.3)),
          ),
          child: const Text('DRAFT',
              style: TextStyle(color: Colors.white, fontSize: 11,
                  fontWeight: FontWeight.w700, letterSpacing: 0.8)),
        ),
      ],
    ),
  );
}

// ═══════════════════════════════════════════
//  SECTION LABEL
// ═══════════════════════════════════════════
class _SectionLabel extends StatelessWidget {
  final IconData icon;
  final String   label;
  const _SectionLabel({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) => Row(
    children: [
      Container(
        width: 32, height: 32,
        decoration: BoxDecoration(
          color: T.primaryLight,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: T.primary, size: 17),
      ),
      const SizedBox(width: 10),
      Text(label,
          style: const TextStyle(fontSize: 14,
              fontWeight: FontWeight.w700, color: T.text)),
    ],
  );
}

// ═══════════════════════════════════════════
//  FIELD BOX
// ═══════════════════════════════════════════
class _FieldBox extends StatelessWidget {
  final String label;
  final Widget child;
  const _FieldBox({required this.label, required this.child});

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(label,
          style: const TextStyle(fontSize: 12,
              fontWeight: FontWeight.w600, color: T.label)),
      const SizedBox(height: 6),
      child,
    ],
  );
}

// ═══════════════════════════════════════════
//  DROPDOWN FIELD
// ═══════════════════════════════════════════
class _DropdownField extends StatelessWidget {
  final String?               value;
  final List<String>          items;
  final String                hint;
  final IconData              icon;
  final ValueChanged<String?> onChanged;
  const _DropdownField({
    required this.value,
    required this.items,
    required this.hint,
    required this.icon,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) => DropdownButtonFormField<String>(
    value: value,
    decoration: fieldDec('', icon: icon),
    hint: Text(hint,
        style: const TextStyle(color: T.hint, fontSize: 13)),
    style: const TextStyle(fontSize: 13, color: T.text,
        fontWeight: FontWeight.w500),
    icon: const Icon(Icons.keyboard_arrow_down_rounded,
        color: T.hint, size: 20),
    dropdownColor: Colors.white,
    borderRadius: BorderRadius.circular(12),
    items: items
        .map((e) => DropdownMenuItem(value: e, child: Text(e)))
        .toList(),
    onChanged: onChanged,
  );
}

// ═══════════════════════════════════════════
//  SAVE BUTTON
// ═══════════════════════════════════════════
class _SaveBtn extends StatelessWidget {
  final VoidCallback onTap;
  const _SaveBtn({required this.onTap});

  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity,
    height: 50,
    decoration: BoxDecoration(
      gradient: const LinearGradient(
        colors: [T.gradStart, T.gradEnd],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      borderRadius: BorderRadius.circular(12),
      boxShadow: [
        BoxShadow(
          color: T.primary.withOpacity(0.38),
          blurRadius: 14,
          offset: const Offset(0, 4),
        ),
      ],
    ),
    child: Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.save_rounded, color: Colors.white, size: 18),
            SizedBox(width: 8),
            Text('SAVE ENTRY',
                style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                    fontSize: 14,
                    letterSpacing: 1.0)),
          ],
        ),
      ),
    ),
  );
}