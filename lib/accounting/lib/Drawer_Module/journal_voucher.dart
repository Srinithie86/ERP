import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// ═══════════════════════════════════════════
//  THEME COLORS
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
  border: Border.all(color: T.border),
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
//  MODELS
// ═══════════════════════════════════════════
class LedgerRow {
  String type;
  String ledgerCode;
  String ledgerName;
  String amount;
  String referenceNo;
  DateTime referenceDate;
  String narration;

  LedgerRow({
    this.type = '',
    this.ledgerCode = '',
    this.ledgerName = '',
    this.amount = '',
    this.referenceNo = '',
    DateTime? referenceDate,
    this.narration = '',
  }) : referenceDate = referenceDate ?? DateTime.now();
}

class SavedVoucherEntry {
  final int id;
  final int voucherEntry;
  final String voucherType;
  final String type;
  final String documentNo;
  final DateTime documentDate;
  final String ledgerCode;
  final String payAccount;
  final String ledgerName;
  final String amount;
  final String referenceNo;
  final DateTime referenceDate;
  final String narration;

  SavedVoucherEntry({
    required this.id,
    required this.voucherEntry,
    required this.voucherType,
    required this.type,
    required this.documentNo,
    required this.documentDate,
    required this.ledgerCode,
    required this.payAccount,
    required this.ledgerName,
    required this.amount,
    required this.referenceNo,
    required this.referenceDate,
    required this.narration,
  });
}

class _RowCtrl {
  final ledgerCode = TextEditingController();
  final ledgerName = TextEditingController();
  final amount     = TextEditingController();
  final refNo      = TextEditingController();
  final narration  = TextEditingController();
  void dispose() {
    ledgerCode.dispose();
    ledgerName.dispose();
    amount.dispose();
    refNo.dispose();
    narration.dispose();
  }
}

// ═══════════════════════════════════════════
//  ROOT  ←  IndexedStack-friendly wrapper
// ═══════════════════════════════════════════
class VoucherEntryRoot extends StatefulWidget {
  const VoucherEntryRoot({super.key});
  @override
  State<VoucherEntryRoot> createState() => _VoucherEntryRootState();
}

class _VoucherEntryRootState extends State<VoucherEntryRoot> {
  final List<SavedVoucherEntry> _savedEntries = [];
  int _nextId = 1;

  void _onSaved(List<SavedVoucherEntry> newEntries) {
    setState(() {
      for (final e in newEntries) {
        _savedEntries.add(SavedVoucherEntry(
          id: _nextId++,
          voucherEntry: e.voucherEntry,
          voucherType:  e.voucherType,
          type:         e.type,
          documentNo:   e.documentNo,
          documentDate: e.documentDate,
          ledgerCode:   e.ledgerCode,
          payAccount:   e.payAccount,
          ledgerName:   e.ledgerName,
          amount:       e.amount,
          referenceNo:  e.referenceNo,
          referenceDate: e.referenceDate,
          narration:    e.narration,
        ));
      }
    });
  }

  void _onDelete(int id) =>
      setState(() => _savedEntries.removeWhere((e) => e.id == id));

  @override
  Widget build(BuildContext context) => VoucherEntryScreen(
    savedEntries: _savedEntries,
    onSaved:      _onSaved,
    onDelete:     _onDelete,
  );
}

// ═══════════════════════════════════════════
//  MAIN SCREEN
// ═══════════════════════════════════════════
class VoucherEntryScreen extends StatefulWidget {
  final List<SavedVoucherEntry> savedEntries;
  final void Function(List<SavedVoucherEntry>) onSaved;
  final void Function(int) onDelete;

  const VoucherEntryScreen({
    super.key,
    required this.savedEntries,
    required this.onSaved,
    required this.onDelete,
  });

  @override
  State<VoucherEntryScreen> createState() => _VoucherEntryScreenState();
}

class _VoucherEntryScreenState extends State<VoucherEntryScreen>
    with SingleTickerProviderStateMixin {

  late TabController _tabController;

  String?  _voucherType;
  final _docNoCtrl      = TextEditingController();
  final _payAccountCtrl = TextEditingController();
  DateTime _docDate     = DateTime.now();

  final List<LedgerRow>    _rows    = [LedgerRow()];
  final Map<int, _RowCtrl> _ctrlMap = {};

  static const _voucherTypes = ['Payment','Receipt','Journal','Contra','Sales','Purchase'];
  static const _typeOptions  = ['Dr', 'Cr'];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _docNoCtrl.dispose();
    _payAccountCtrl.dispose();
    for (final c in _ctrlMap.values) c.dispose();
    super.dispose();
  }

  _RowCtrl _ctrl(int i) => _ctrlMap.putIfAbsent(i, () => _RowCtrl());

  String _fmt(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  Future<void> _pickDate(DateTime initial, ValueChanged<DateTime> cb) async {
    final p = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(2000),
      lastDate:  DateTime(2100),
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
          colorScheme: const ColorScheme.light(primary: T.primary),
        ),
        child: child!,
      ),
    );
    if (p != null) cb(p);
  }

  void _addRow() => setState(() => _rows.add(LedgerRow()));

  void _deleteRow(int i) {
    if (_rows.length == 1) return;
    setState(() {
      _ctrlMap[i]?.dispose();
      _ctrlMap.remove(i);
      _rows.removeAt(i);
      final rebuilt = <int, _RowCtrl>{};
      _ctrlMap.forEach((k, v) => rebuilt[k < i ? k : k - 1] = v);
      _ctrlMap..clear()..addAll(rebuilt);
    });
  }

  void _onSave() {
    for (int i = 0; i < _rows.length; i++) {
      final c = _ctrl(i);
      _rows[i]
        ..ledgerCode  = c.ledgerCode.text
        ..ledgerName  = c.ledgerName.text
        ..amount      = c.amount.text
        ..referenceNo = c.refNo.text
        ..narration   = c.narration.text;
    }

    final newEntries = _rows.asMap().entries.map((e) {
      final row = e.value;
      return SavedVoucherEntry(
        id:            0,
        voucherEntry:  e.key + 1,
        voucherType:   _voucherType ?? '-',
        type:          row.type.isEmpty ? '-' : row.type,
        documentNo:    _docNoCtrl.text.isEmpty ? '-' : _docNoCtrl.text,
        documentDate:  _docDate,
        ledgerCode:    row.ledgerCode.isEmpty ? '-' : row.ledgerCode,
        payAccount:    _payAccountCtrl.text.isEmpty ? '-' : _payAccountCtrl.text,
        ledgerName:    row.ledgerName.isEmpty ? '-' : row.ledgerName,
        amount:        row.amount.isEmpty ? '-' : row.amount,
        referenceNo:   row.referenceNo.isEmpty ? '-' : row.referenceNo,
        referenceDate: row.referenceDate,
        narration:     row.narration.isEmpty ? '-' : row.narration,
      );
    }).toList();

    widget.onSaved(newEntries);

    setState(() {
      _voucherType = null;
      _docNoCtrl.clear();
      _payAccountCtrl.clear();
      _docDate = DateTime.now();
      for (final c in _ctrlMap.values) c.dispose();
      _ctrlMap.clear();
      _rows.clear();
      _rows.add(LedgerRow());
    });

    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: const Row(children: [
        Icon(Icons.check_circle_rounded, color: Colors.white, size: 18),
        SizedBox(width: 10),
        Text('Voucher saved successfully!',
            style: TextStyle(fontWeight: FontWeight.w600)),
      ]),
      backgroundColor: T.success,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      margin: const EdgeInsets.all(16),
      duration: const Duration(seconds: 2),
    ));

    _tabController.animateTo(1);
  }

  // ══════════════════════════════════════════
  //  BUILD
  // ══════════════════════════════════════════
  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Color(0xFF26A69A),
        statusBarIconBrightness: Brightness.light,
      ),
      child: Scaffold(
        backgroundColor: T.bg,
        appBar: _buildAppBar(),
        body: TabBarView(
          controller: _tabController,
          children: [_buildEntryTab(), _buildTableTab()],
        ),
      ),
    );
  }

  // ── AppBar ─────────────────────────────────
  PreferredSizeWidget _buildAppBar() {
    // ✅ Navigator.canPop check — IndexedStack inside ஆ,
    //    push பண்ணி வந்தா pop, இல்லன்னா bottom nav index 0 போகும்
    final canPop = Navigator.canPop(context);

    return AppBar(
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

      // ✅ KEY FIX — automaticallyImplyLeading: false, custom leading
      automaticallyImplyLeading: false,
      leading: IconButton(
        icon: Container(
          width: 34, height: 34,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.15),
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Icon(
            Icons.arrow_back_ios_rounded,
            color: Colors.white,
            size: 16,
          ),
        ),
        onPressed: () {
          if (canPop) {
            // Navigator.push வழியா வந்தா — back போ
            Navigator.pop(context);
          } else {
            // IndexedStack-ல இருந்தா — Dashboard tab க்கு switch பண்ணு
            // MainShell-ல உள்ள parent-ஐ trigger பண்ண callback use பண்ணலாம்
            // Simple approach: bottom nav index change பண்ண
            // Parent widget வழியா போகணும் — DefaultTabController இல்லன்னா
            // context.findAncestorStateOfType use பண்ணலாம்
            final shell = context.findAncestorStateOfType<_MainShellStateAccess>();
            shell?.goToDashboard();
          }
        },
      ),

      title: const Text(
        'Voucher Entry',
        style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w800,
          fontSize: 17,
          letterSpacing: 0.3,
        ),
      ),
      actions: [
        Container(
          margin: const EdgeInsets.only(right: 12, top: 10, bottom: 10),
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.15),
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Center(
            child: Text('ID: 1760',
                style: TextStyle(fontSize: 12, color: Colors.white)),
          ),
        ),
      ],
      bottom: TabBar(
        controller: _tabController,
        indicatorColor: Colors.white,
        indicatorWeight: 3,
        labelColor: Colors.white,
        unselectedLabelColor: Colors.white60,
        labelStyle:
        const TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
        tabs: [
          const Tab(
            icon: Icon(Icons.edit_note_rounded, size: 20),
            text: 'Entry',
          ),
          Tab(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.table_rows_rounded, size: 18),
                const SizedBox(width: 6),
                const Text('Saved Entries'),
                if (widget.savedEntries.isNotEmpty) ...[
                  const SizedBox(width: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 6, vertical: 1),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      '${widget.savedEntries.length}',
                      style: const TextStyle(
                        fontSize: 11,
                        color: T.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Entry Tab ──────────────────────────────
  Widget _buildEntryTab() {
    final sw    = MediaQuery.of(context).size.width;
    final isMob = sw < 600;
    final hPad  = isMob ? 14.0 : (sw < 900 ? 28.0 : 48.0);

    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(hPad, 20, hPad, 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _HeaderBanner(),
          const SizedBox(height: 18),

          // Voucher Details Card
          Container(
            decoration: cardDec(),
            padding: EdgeInsets.all(isMob ? 16 : 22),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const _SectionLabel(
                  icon: Icons.receipt_long_rounded,
                  label: 'Voucher Details',
                ),
                const SizedBox(height: 16),
                _row2(
                  isMob,
                  _FieldBox(
                    label: 'Voucher Type',
                    child: _DropdownField(
                      value: _voucherType,
                      hint: 'Select voucher type',
                      items: _voucherTypes,
                      icon: Icons.category_outlined,
                      onChanged: (v) => setState(() => _voucherType = v),
                    ),
                  ),
                  _FieldBox(
                    label: 'Document No',
                    child: TextField(
                      controller: _docNoCtrl,
                      style: _ts(),
                      decoration: fieldDec('Enter document number',
                          icon: Icons.tag_rounded),
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                _row2(
                  isMob,
                  _FieldBox(
                    label: 'Document Date',
                    child: _DateTile(
                      date: _docDate,
                      fmt: _fmt,
                      onTap: () => _pickDate(
                          _docDate, (d) => setState(() => _docDate = d)),
                    ),
                  ),
                  _FieldBox(
                    label: 'Pay Account',
                    child: TextField(
                      controller: _payAccountCtrl,
                      style: _ts(),
                      decoration: fieldDec('Enter pay account',
                          icon: Icons.account_balance_wallet_outlined),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          ..._rows.asMap().entries
              .map((e) => _ledgerCard(e.key, e.value, isMob)),
          const SizedBox(height: 6),

          // Add / Delete bar
          Row(children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: _rows.length > 1
                    ? () => _deleteRow(_rows.length - 1)
                    : null,
                icon: const Icon(Icons.remove_circle_outline, size: 18),
                label: const Text('Delete Last Row'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: T.danger,
                  side: const BorderSide(color: T.danger),
                  padding: const EdgeInsets.symmetric(vertical: 13),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton.icon(
                onPressed: _addRow,
                icon: const Icon(Icons.add_circle_outline, size: 18),
                label: const Text('Add Row'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: T.success,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(vertical: 13),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                ),
              ),
            ),
          ]),
          const SizedBox(height: 20),

          _SaveBtn(onTap: _onSave),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  // ── Single Ledger Card ─────────────────────
  Widget _ledgerCard(int i, LedgerRow row, bool isMob) {
    final c = _ctrl(i);
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: cardDec(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [T.gradStart, T.gradEnd],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius:
              BorderRadius.vertical(top: Radius.circular(14)),
            ),
            child: Row(
              children: [
                Container(
                  width: 28, height: 28,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.22),
                    borderRadius: BorderRadius.circular(7),
                  ),
                  child: Center(
                    child: Text('${i + 1}',
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 13,
                            fontWeight: FontWeight.bold)),
                  ),
                ),
                const SizedBox(width: 10),
                const Text('Ledger Entry',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w700)),
                const Spacer(),
                if (_rows.length > 1)
                  GestureDetector(
                    onTap: () => _deleteRow(i),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.18),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Row(children: [
                        Icon(Icons.delete_outline_rounded,
                            size: 14, color: Colors.white),
                        SizedBox(width: 4),
                        Text('Remove',
                            style: TextStyle(
                                fontSize: 12,
                                color: Colors.white,
                                fontWeight: FontWeight.w600)),
                      ]),
                    ),
                  ),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.all(isMob ? 14 : 18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _row2(
                  isMob,
                  _FieldBox(
                    label: 'Type',
                    child: _DropdownField(
                      value: row.type.isEmpty ? null : row.type,
                      hint: 'Select Dr / Cr',
                      items: _typeOptions,
                      icon: Icons.swap_horiz_rounded,
                      onChanged: (v) =>
                          setState(() => _rows[i].type = v ?? ''),
                    ),
                  ),
                  _FieldBox(
                    label: 'Ledger Code',
                    child: TextField(
                      controller: c.ledgerCode,
                      style: _ts(),
                      decoration: fieldDec('Enter ledger code',
                          icon: Icons.code_rounded),
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                _row2(
                  isMob,
                  _FieldBox(
                    label: 'Ledger Name',
                    child: TextField(
                      controller: c.ledgerName,
                      style: _ts(),
                      decoration: fieldDec('Enter ledger name',
                          icon: Icons.text_fields_rounded),
                    ),
                  ),
                  _FieldBox(
                    label: 'Amount',
                    child: TextField(
                      controller: c.amount,
                      keyboardType: const TextInputType.numberWithOptions(
                          decimal: true),
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(
                            RegExp(r'^\d+\.?\d{0,2}'))
                      ],
                      style: _ts(),
                      decoration: fieldDec('0.00',
                          icon: Icons.currency_rupee_rounded),
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                _row2(
                  isMob,
                  _FieldBox(
                    label: 'Reference No',
                    child: TextField(
                      controller: c.refNo,
                      style: _ts(),
                      decoration: fieldDec('Enter reference number',
                          icon: Icons.confirmation_number_outlined),
                    ),
                  ),
                  _FieldBox(
                    label: 'Reference Date',
                    child: _DateTile(
                      date: row.referenceDate,
                      fmt: _fmt,
                      onTap: () => _pickDate(
                        row.referenceDate,
                            (d) => setState(
                                () => _rows[i].referenceDate = d),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                _FieldBox(
                  label: 'Narration',
                  child: TextField(
                    controller: c.narration,
                    maxLines: 2,
                    style: _ts(),
                    decoration: fieldDec('Enter narration / remarks',
                        icon: Icons.notes_rounded),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Table Tab ──────────────────────────────
  Widget _buildTableTab() {
    final entries = widget.savedEntries;
    return Column(
      children: [
        Expanded(
          child: entries.isEmpty
              ? _EmptyTableState(
            onGoToEntry: () => _tabController.animateTo(0),
          )
              : SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _savedEntriesTable(entries),
                const SizedBox(height: 10),
                Padding(
                  padding: const EdgeInsets.only(left: 4),
                  child: Text(
                    'Showing 1 to ${entries.length} of ${entries.length} rows',
                    style: const TextStyle(
                      fontSize: 13,
                      color: T.primary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
        if (entries.isNotEmpty)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: _SaveBtn(
              label: 'Add New Voucher',
              icon: Icons.add_rounded,
              onTap: () => _tabController.animateTo(0),
            ),
          ),
      ],
    );
  }

  // ── Saved Entries Table ────────────────────
  Widget _savedEntriesTable(List<SavedVoucherEntry> entries) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: T.primary.withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(14),
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [T.gradStart, T.gradEnd],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Row(children: [
                const Icon(Icons.table_rows_rounded,
                    color: Colors.white, size: 18),
                const SizedBox(width: 8),
                const Text('Voucher Entries',
                    style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 14)),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 3),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.22),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text('${entries.length} entries',
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.w600)),
                ),
              ]),
            ),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                headingRowColor:
                WidgetStateProperty.all(const Color(0xFFF1F8F7)),
                headingTextStyle: const TextStyle(
                    color: T.textMid,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.5),
                dataTextStyle: const TextStyle(
                    fontSize: 12,
                    color: T.text,
                    fontWeight: FontWeight.w500),
                dividerThickness: 0.8,
                columnSpacing: 16,
                horizontalMargin: 14,
                columns: const [
                  DataColumn(label: Text('ID')),
                  DataColumn(label: Text('VOUCHER\nENTRY')),
                  DataColumn(label: Text('VOUCHER\nTYPE')),
                  DataColumn(label: Text('TYPE')),
                  DataColumn(label: Text('DOCUMENT\nNO')),
                  DataColumn(label: Text('DOCUMENT\nDATE')),
                  DataColumn(label: Text('LEDGER\nCODE')),
                  DataColumn(label: Text('PAY\nACCOUNT')),
                  DataColumn(label: Text('LEDGER\nNAME')),
                  DataColumn(label: Text('AMOUNT')),
                  DataColumn(label: Text('REFERENCE\nNO')),
                  DataColumn(label: Text('REFERENCE\nDATE')),
                  DataColumn(label: Text('NARRATION')),
                  DataColumn(label: Text('ACTION')),
                ],
                rows: entries.map((entry) {
                  final odd = entries.indexOf(entry).isOdd;
                  return DataRow(
                    color: WidgetStateProperty.all(
                        odd
                            ? const Color(0xFFF8FBFB)
                            : Colors.white),
                    cells: [
                      DataCell(Text('${entry.id}')),
                      DataCell(Text('${entry.voucherEntry}')),
                      DataCell(_voucherTypeBadge(entry.voucherType)),
                      DataCell(_typeBadge(entry.type)),
                      DataCell(Text(entry.documentNo)),
                      DataCell(Text(_fmt(entry.documentDate))),
                      DataCell(Text(entry.ledgerCode)),
                      DataCell(Text(entry.payAccount)),
                      DataCell(Text(entry.ledgerName)),
                      DataCell(Text(entry.amount)),
                      DataCell(Text(entry.referenceNo)),
                      DataCell(Text(_fmt(entry.referenceDate))),
                      DataCell(SizedBox(
                          width: 90,
                          child: Text(entry.narration,
                              overflow: TextOverflow.ellipsis))),
                      DataCell(Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _ActionBtn(
                            icon: Icons.edit_rounded,
                            color: T.primary,
                            onTap: () =>
                                ScaffoldMessenger.of(context)
                                    .showSnackBar(SnackBar(
                                  content: Text(
                                      'Edit entry ID: ${entry.id}'),
                                  backgroundColor: T.primary,
                                  behavior: SnackBarBehavior.floating,
                                  shape: RoundedRectangleBorder(
                                      borderRadius:
                                      BorderRadius.circular(8)),
                                  duration:
                                  const Duration(seconds: 1),
                                )),
                          ),
                          const SizedBox(width: 6),
                          _ActionBtn(
                            icon: Icons.close_rounded,
                            color: T.danger,
                            onTap: () => _confirmDelete(entry.id),
                          ),
                        ],
                      )),
                    ],
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _typeBadge(String type) {
    if (type == '-' || type.isEmpty) return const Text('-');
    final isDr = type == 'Dr';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: isDr ? T.primaryLight : const Color(0xFFE0F7FA),
        borderRadius: BorderRadius.circular(5),
      ),
      child: Text(type,
          style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: isDr ? T.primary : T.accent)),
    );
  }

  Widget _voucherTypeBadge(String vType) {
    if (vType == '-' || vType.isEmpty) return const Text('-');
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: T.primaryLight,
        borderRadius: BorderRadius.circular(5),
      ),
      child: Text(vType,
          style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: T.primary)),
    );
  }

  void _confirmDelete(int id) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape:
        RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        title: const Row(children: [
          Icon(Icons.warning_amber_rounded, color: T.danger, size: 22),
          SizedBox(width: 8),
          Text('Delete Entry',
              style: TextStyle(
                  fontSize: 16,
                  color: T.danger,
                  fontWeight: FontWeight.w700)),
        ]),
        content: const Text(
            'Are you sure you want to delete this entry?',
            style: TextStyle(fontSize: 14, color: T.label)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel',
                style: TextStyle(
                    color: T.label, fontWeight: FontWeight.w600)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              widget.onDelete(id);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: T.danger,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
            ),
            child: const Text('Delete',
                style: TextStyle(fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }

  static TextStyle _ts() =>
      const TextStyle(fontSize: 13, color: T.text, fontWeight: FontWeight.w500);

  Widget _row2(bool isMob, Widget a, Widget b) => isMob
      ? Column(children: [a, const SizedBox(height: 14), b])
      : Row(children: [
    Expanded(child: a),
    const SizedBox(width: 18),
    Expanded(child: b),
  ]);
}

// ═══════════════════════════════════════════
//  MainShell access mixin — back button support
//  (main_shell.dart-ல இந்த mixin add பண்ணுங்க)
// ═══════════════════════════════════════════
mixin _MainShellStateAccess on State {
  void goToDashboard();
}

// ═══════════════════════════════════════════
//  HEADER BANNER
// ═══════════════════════════════════════════
class _HeaderBanner extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
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
              offset: const Offset(0, 6)),
        ],
      ),
      child: Row(children: [
        Container(
          width: 52, height: 52,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.18),
            borderRadius: BorderRadius.circular(14),
          ),
          child: const Icon(Icons.receipt_long_rounded,
              color: Colors.white, size: 28),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Voucher Entry',
                  style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w900,
                      fontSize: 18)),
              const SizedBox(height: 3),
              Text('Create & manage accounting vouchers',
                  style: TextStyle(
                      color: Colors.white.withOpacity(0.78),
                      fontSize: 12)),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.18),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white.withOpacity(0.3)),
          ),
          child: const Text('DRAFT',
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.8)),
        ),
      ]),
    );
  }
}

// ═══════════════════════════════════════════
//  SECTION LABEL
// ═══════════════════════════════════════════
class _SectionLabel extends StatelessWidget {
  final IconData icon;
  final String   label;
  const _SectionLabel({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) => Row(children: [
    Container(
      width: 32, height: 32,
      decoration: BoxDecoration(
          color: T.primaryLight,
          borderRadius: BorderRadius.circular(8)),
      child: Icon(icon, color: T.primary, size: 17),
    ),
    const SizedBox(width: 10),
    Text(label,
        style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: T.text)),
  ]);
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
          style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: T.label)),
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
  final String                hint;
  final List<String>          items;
  final IconData              icon;
  final ValueChanged<String?> onChanged;
  const _DropdownField({
    required this.value,
    required this.hint,
    required this.items,
    required this.icon,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) => DropdownButtonFormField<String>(
    value: value,
    decoration: fieldDec('', icon: icon),
    hint: Text(hint,
        style: const TextStyle(color: T.hint, fontSize: 13)),
    style: const TextStyle(
        fontSize: 13, color: T.text, fontWeight: FontWeight.w500),
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
//  DATE TILE
// ═══════════════════════════════════════════
class _DateTile extends StatelessWidget {
  final DateTime date;
  final String Function(DateTime) fmt;
  final VoidCallback onTap;
  const _DateTile(
      {required this.date, required this.fmt, required this.onTap});

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Container(
      padding:
      const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFB),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: T.border),
      ),
      child: Row(children: [
        const Icon(Icons.calendar_today_rounded,
            size: 18, color: T.hint),
        const SizedBox(width: 10),
        Text(fmt(date),
            style: const TextStyle(
                fontSize: 13,
                color: T.text,
                fontWeight: FontWeight.w500)),
        const Spacer(),
        const Icon(Icons.edit_calendar_rounded,
            size: 16, color: T.hint),
      ]),
    ),
  );
}

// ═══════════════════════════════════════════
//  ACTION BUTTON (table)
// ═══════════════════════════════════════════
class _ActionBtn extends StatelessWidget {
  final IconData     icon;
  final Color        color;
  final VoidCallback onTap;
  const _ActionBtn(
      {required this.icon, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) => Container(
    width: 32, height: 32,
    decoration: BoxDecoration(
        color: color, borderRadius: BorderRadius.circular(6)),
    child: IconButton(
      padding: EdgeInsets.zero,
      icon: Icon(icon, size: 15, color: Colors.white),
      onPressed: onTap,
    ),
  );
}

// ═══════════════════════════════════════════
//  EMPTY TABLE STATE
// ═══════════════════════════════════════════
class _EmptyTableState extends StatelessWidget {
  final VoidCallback onGoToEntry;
  const _EmptyTableState({required this.onGoToEntry});

  @override
  Widget build(BuildContext context) => Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          padding: const EdgeInsets.all(20),
          decoration: const BoxDecoration(
              color: T.primaryLight, shape: BoxShape.circle),
          child: const Icon(Icons.receipt_long_outlined,
              size: 48, color: T.primary),
        ),
        const SizedBox(height: 16),
        const Text('No entries yet',
            style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: T.primary)),
        const SizedBox(height: 8),
        const Text('Save a voucher to see it here',
            style: TextStyle(fontSize: 13, color: T.label)),
        const SizedBox(height: 20),
        ElevatedButton.icon(
          onPressed: onGoToEntry,
          icon: const Icon(Icons.edit_note_rounded, size: 18),
          label: const Text('Go to Entry'),
          style: ElevatedButton.styleFrom(
            backgroundColor: T.primary,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10)),
          ),
        ),
      ],
    ),
  );
}

// ═══════════════════════════════════════════
//  SAVE BUTTON
// ═══════════════════════════════════════════
class _SaveBtn extends StatelessWidget {
  final VoidCallback onTap;
  final String   label;
  final IconData icon;
  const _SaveBtn({
    required this.onTap,
    this.label = 'SAVE VOUCHER',
    this.icon  = Icons.save_rounded,
  });

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
            offset: const Offset(0, 4)),
      ],
    ),
    child: Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.white, size: 18),
            const SizedBox(width: 8),
            Text(label,
                style: const TextStyle(
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