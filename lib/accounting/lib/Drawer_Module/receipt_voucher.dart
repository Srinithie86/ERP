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

  // Gradient helpers
  static const gradStart    = Color(0xFF26A69A);
  static const gradEnd      = Color(0xFF00ACC1);
}

// ═══════════════════════════════════════════
//  SHARED DECORATION
// ═══════════════════════════════════════════
BoxDecoration cardDec({Color? border, double radius = 14}) => BoxDecoration(
  color: T.card,
  borderRadius: BorderRadius.circular(radius),
  border: Border.all(color: border ?? T.border, width: 1),
  boxShadow: [
    BoxShadow(
      color: Colors.black.withOpacity(0.055),
      blurRadius: 12,
      offset: const Offset(0, 3),
    ),
  ],
);

InputDecoration fieldDec(String hint, {IconData? icon, bool focused = false}) =>
    InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: T.hint, fontSize: 13),
      prefixIcon: icon != null
          ? Icon(icon, color: T.hint, size: 18)
          : null,
      isDense: true,
      contentPadding:
      const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
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
class InvoiceRow {
  final int sno;
  final String date, reference;
  final double amount;
  double leftToAllocate, thisAllocation;

  InvoiceRow({
    required this.sno,
    required this.date,
    required this.reference,
    required this.amount,
    required this.leftToAllocate,
    this.thisAllocation = 0,
  });

  void reset() {
    thisAllocation = 0;
    leftToAllocate = amount;
  }
}

// ═══════════════════════════════════════════
//  MAIN FORM
// ═══════════════════════════════════════════
class SupplierPaymentForm1 extends StatefulWidget {
  const SupplierPaymentForm1({super.key});

  @override
  State<SupplierPaymentForm1> createState() => _SupplierPaymentForm1State();
}

class _SupplierPaymentForm1State extends State<SupplierPaymentForm1>
    with SingleTickerProviderStateMixin {
  final _dateCtrl    = TextEditingController(text: '06-04-2026');
  final _nameCtrl    = TextEditingController();
  final _balCtrl     = TextEditingController();
  final _amtCtrl     = TextEditingController();
  final _remarksCtrl = TextEditingController();

  String? _payType, _payAccount;
  bool    _showTable = false;
  double  _total     = 0;

  List<InvoiceRow>              _invoices    = [];
  final List<TextEditingController> _allocCtrl = [];

  late final AnimationController _animCtrl;
  late final Animation<double>   _fadeAnim;
  late final Animation<Offset>   _slideAnim;

  final _payTypes    = ['Cash', 'Bank Transfer', 'Cheque', 'UPI', 'NEFT', 'RTGS'];
  final _payAccounts = ['Cash Account', 'HDFC Bank', 'SBI Bank', 'ICICI Bank', 'Axis Bank'];

  @override
  void initState() {
    super.initState();
    _animCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 380));
    _fadeAnim  = CurvedAnimation(parent: _animCtrl, curve: Curves.easeIn);
    _slideAnim = Tween<Offset>(begin: const Offset(0, .08), end: Offset.zero)
        .animate(CurvedAnimation(parent: _animCtrl, curve: Curves.easeOut));
  }

  @override
  void dispose() {
    _animCtrl.dispose();
    _dateCtrl.dispose(); _nameCtrl.dispose();
    _balCtrl.dispose();  _amtCtrl.dispose(); _remarksCtrl.dispose();
    for (final c in _allocCtrl) c.dispose();
    super.dispose();
  }

  // ─────────────────────────────────────────
  // LOGIC
  // ─────────────────────────────────────────
  void _onBalanceChanged(String v) {
    final bal  = double.tryParse(v) ?? 0;
    final name = _nameCtrl.text.trim();
    _updateTableVisibility(bal > 0 && name.isNotEmpty);
  }

  void _onNameChanged(String v) {
    final bal = double.tryParse(_balCtrl.text) ?? 0;
    _updateTableVisibility(v.isNotEmpty && bal > 0);
  }

  void _updateTableVisibility(bool show) {
    if (show == _showTable) return;
    setState(() {
      _showTable = show;
      if (show) {
        if (_invoices.isEmpty) _loadInvoices();
        final amt = double.tryParse(_amtCtrl.text) ?? 0;
        if (amt > 0) _autoSplit(amt);
        _animCtrl.forward();
      } else {
        _animCtrl.reverse();
        _invoices.clear();
        for (final c in _allocCtrl) c.dispose();
        _allocCtrl.clear();
        _total = 0;
        _amtCtrl.clear();
      }
    });
  }

  void _onAmountChanged(String v) {
    final amt = double.tryParse(v) ?? 0;
    setState(() {
      if (amt > 0 && _showTable && _invoices.isNotEmpty) {
        _autoSplit(amt);
      } else {
        _clearAllocations();
      }
    });
  }

  void _loadInvoices() {
    _invoices = [
      InvoiceRow(sno:1, date:'01-04-2026', reference:'INV-001', amount:5000, leftToAllocate:5000),
      InvoiceRow(sno:2, date:'03-04-2026', reference:'INV-002', amount:3200, leftToAllocate:3200),
      InvoiceRow(sno:3, date:'05-04-2026', reference:'INV-003', amount:1800, leftToAllocate:1800),
    ];
    _allocCtrl.clear();
    for (var _ in _invoices) _allocCtrl.add(TextEditingController(text: ''));
  }

  void _autoSplit(double amt) {
    double rem = amt;
    for (int i = 0; i < _invoices.length; i++) {
      final inv = _invoices[i];
      if (rem <= 0) {
        inv.thisAllocation = 0; inv.leftToAllocate = inv.amount;
        _allocCtrl[i].text = '';
      } else if (rem >= inv.amount) {
        inv.thisAllocation = inv.amount; inv.leftToAllocate = 0;
        _allocCtrl[i].text = inv.amount.toStringAsFixed(2);
        rem -= inv.amount;
      } else {
        inv.thisAllocation = rem; inv.leftToAllocate = inv.amount - rem;
        _allocCtrl[i].text = rem.toStringAsFixed(2);
        rem = 0;
      }
    }
    _recalc();
  }

  void _clearAllocations() {
    for (int i = 0; i < _invoices.length; i++) {
      _invoices[i].reset();
      _allocCtrl[i].text = '';
    }
    _total = 0;
  }

  void _recalc() => _total = _invoices.fold(0, (s, r) => s + r.thisAllocation);

  void _save() {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: const Row(children: [
        Icon(Icons.check_circle_rounded, color: Colors.white, size: 18),
        SizedBox(width: 10),
        Text('Payment saved successfully!',
            style: TextStyle(fontWeight: FontWeight.w600)),
      ]),
      backgroundColor: T.success,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      margin: const EdgeInsets.all(16),
    ));
  }

  // ─────────────────────────────────────────
  // BUILD
  // ─────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final sw      = MediaQuery.of(context).size.width;
    final isMob   = sw < 600;
    final hPad    = isMob ? 14.0 : (sw < 900 ? 28.0 : 48.0);
    final vGap    = isMob ? 14.0 : 18.0;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Color(0xFF26A69A),
        statusBarIconBrightness: Brightness.light,
      ),
      child: Scaffold(
        backgroundColor: T.bg,
        appBar: _buildAppBar(),
        body: SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(hPad, 20, hPad, 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              // ── Header Banner ──────────────────────────
              _HeaderBanner(),
              SizedBox(height: vGap + 4),

              // ── FORM CARD ──────────────────────────────
              Container(
                decoration: cardDec(),
                padding: EdgeInsets.all(isMob ? 16 : 22),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [

                    // Section label
                    _SectionLabel(icon: Icons.info_outline_rounded,
                        label: 'Payment Information'),
                    SizedBox(height: vGap),

                    // Row 1: Date | Balance
                    _row2(isMob, vGap,
                      _FieldBox(label: 'Date',
                          child: TextField(controller: _dateCtrl,
                              style: _ts(), decoration: fieldDec('DD-MM-YYYY',
                                  icon: Icons.calendar_today_rounded))),
                      _FieldBox(label: 'Balance',
                          child: TextField(
                              controller: _balCtrl,
                              onChanged: _onBalanceChanged,
                              keyboardType: const TextInputType.numberWithOptions(decimal: true),
                              inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}'))],
                              style: _ts(),
                              decoration: fieldDec('0.00',
                                  icon: Icons.account_balance_wallet_outlined))),
                    ),
                    SizedBox(height: vGap),

                    // Row 2: Name | Amount
                    _row2(isMob, vGap,
                      _FieldBox(label: 'Supplier Name',
                          child: TextField(
                              controller: _nameCtrl,
                              onChanged: _onNameChanged,
                              style: _ts(),
                              decoration: fieldDec('Type supplier name...',
                                  icon: Icons.person_outline_rounded))),
                      _FieldBox(label: 'Amount',
                          child: TextField(
                              controller: _amtCtrl,
                              onChanged: _onAmountChanged,
                              keyboardType: const TextInputType.numberWithOptions(decimal: true),
                              inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}'))],
                              style: _ts(),
                              decoration: fieldDec('0.00',
                                  icon: Icons.currency_rupee_rounded))),
                    ),
                  ],
                ),
              ),

              SizedBox(height: vGap),

              // ── INVOICE TABLE CARD ─────────────────────
              Container(
                decoration: cardDec(),
                clipBehavior: Clip.antiAlias,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Table header strip
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.symmetric(
                          horizontal: isMob ? 14 : 20, vertical: 12),
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          colors: [T.gradStart, T.gradEnd],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                      ),
                      child: Row(children: [
                        const Icon(Icons.receipt_long_rounded,
                            color: Colors.white, size: 18),
                        const SizedBox(width: 8),
                        const Text('Pending Invoices',
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w700,
                                fontSize: 14)),
                        const Spacer(),
                        if (_showTable)
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 3),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.22),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text('${_invoices.length} invoices',
                                style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600)),
                          ),
                      ]),
                    ),

                    // Column headers
                    _TableHeader(isMob: isMob),

                    // Rows
                    if (!_showTable)
                      _EmptyState()
                    else
                      FadeTransition(
                        opacity: _fadeAnim,
                        child: SlideTransition(
                          position: _slideAnim,
                          child: Column(
                            children: _invoices.asMap().entries.map((e) =>
                                _InvoiceDataRow(
                                  inv: e.value,
                                  idx: e.key,
                                  isMob: isMob,
                                  ctrl: _allocCtrl[e.key],
                                  onChanged: (v) => setState(() {
                                    final val = double.tryParse(v) ?? 0;
                                    _invoices[e.key].thisAllocation = val;
                                    _invoices[e.key].leftToAllocate =
                                        _invoices[e.key].amount - val;
                                    _recalc();
                                  }),
                                ),
                            ).toList(),
                          ),
                        ),
                      ),

                    // Total
                    _TotalRow(total: _total, isMob: isMob),
                  ],
                ),
              ),

              SizedBox(height: vGap),

              // ── PAYMENT CARD ───────────────────────────
              Container(
                decoration: cardDec(),
                padding: EdgeInsets.all(isMob ? 16 : 22),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _SectionLabel(icon: Icons.payment_rounded,
                        label: 'Payment Method'),
                    SizedBox(height: vGap),

                    // Pay Type | Pay Account
                    _row2(isMob, vGap,
                      _FieldBox(label: 'Pay Type',
                          child: _Dropdown(
                              value: _payType,
                              items: _payTypes,
                              hint: '-- Select --',
                              icon: Icons.account_balance_rounded,
                              onChanged: (v) => setState(() => _payType = v))),
                      _FieldBox(label: 'Pay Account',
                          child: _Dropdown(
                              value: _payAccount,
                              items: _payAccounts,
                              hint: '-- Select --',
                              icon: Icons.credit_card_rounded,
                              onChanged: (v) => setState(() => _payAccount = v))),
                    ),
                    SizedBox(height: vGap),

                    // Remarks | Save
                    isMob
                        ? Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _FieldBox(label: 'Remarks',
                            child: TextField(
                                controller: _remarksCtrl,
                                style: _ts(),
                                decoration: fieldDec('Add remarks...',
                                    icon: Icons.notes_rounded))),
                        SizedBox(height: vGap),
                        _SaveBtn(onTap: _save, full: true),
                      ],
                    )
                        : Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Expanded(child: _FieldBox(label: 'Remarks',
                            child: TextField(
                                controller: _remarksCtrl,
                                style: _ts(),
                                decoration: fieldDec('Add remarks...',
                                    icon: Icons.notes_rounded)))),
                        const SizedBox(width: 20),
                        _SaveBtn(onTap: _save, full: false),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),


            ],
          ),
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
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
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          Text('Receipt Voucher',
              style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                  fontSize: 17,
                  letterSpacing: 0.3)),

        ],
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
  }

  static TextStyle _ts() =>
      const TextStyle(fontSize: 13, color: T.text, fontWeight: FontWeight.w500);

  Widget _row2(bool isMob, double gap, Widget a, Widget b) => isMob
      ? Column(children: [a, SizedBox(height: gap), b])
      : Row(children: [
    Expanded(child: a),
    const SizedBox(width: 18),
    Expanded(child: b),
  ]);
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
            child: const Icon(Icons.receipt_long_rounded,
                color: Colors.white, size: 28),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Supplier Payment',
                    style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w900,
                        fontSize: 18)),
                const SizedBox(height: 3),
                Text('Allocate invoices & record payment',
                    style: TextStyle(
                        color: Colors.white.withOpacity(0.78),
                        fontSize: 12)),
              ],
            ),
          ),
          // Status badge
          Container(
            padding: const EdgeInsets.symmetric(
                horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.18),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                  color: Colors.white.withOpacity(0.3)),
            ),
            child: const Text('DRAFT',
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.8)),
          ),
        ],
      ),
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
          style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: T.text)),
    ],
  );
}

// ═══════════════════════════════════════════
//  FIELD BOX (label + input)
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
//  DROPDOWN
// ═══════════════════════════════════════════
class _Dropdown extends StatelessWidget {
  final String?               value;
  final List<String>          items;
  final String                hint;
  final IconData              icon;
  final ValueChanged<String?> onChanged;
  const _Dropdown({
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
//  TABLE HEADER ROW
// ═══════════════════════════════════════════
class _TableHeader extends StatelessWidget {
  final bool isMob;
  const _TableHeader({required this.isMob});

  @override
  Widget build(BuildContext context) {
    const s = TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w700,
        color: T.textMid,
        letterSpacing: 0.5);

    return Container(
      color: const Color(0xFFF1F8F7),
      padding: EdgeInsets.symmetric(
          horizontal: isMob ? 14 : 20, vertical: 10),
      child: isMob
          ? Row(children: const [
        SizedBox(width: 28, child: Text('#', style: s)),
        Expanded(child: Text('REF / DATE', style: s)),
        SizedBox(width: 72,
            child: Text('AMT', style: s, textAlign: TextAlign.right)),
        SizedBox(width: 90,
            child: Text('ALLOCATE', style: s, textAlign: TextAlign.right)),
      ])
          : Row(children: const [
        SizedBox(width: 44,  child: Text('SNO', style: s)),
        SizedBox(width: 105, child: Text('DATE', style: s)),
        Expanded(child: Text('REFERENCE', style: s)),
        SizedBox(width: 100,
            child: Text('AMOUNT', style: s, textAlign: TextAlign.right)),
        SizedBox(width: 140,
            child: Text('LEFT TO ALLOCATE', style: s, textAlign: TextAlign.right)),
        SizedBox(width: 120,
            child: Text('THIS ALLOCATION', style: s, textAlign: TextAlign.right)),
      ]),
    );
  }
}

// ═══════════════════════════════════════════
//  INVOICE DATA ROW
// ═══════════════════════════════════════════
class _InvoiceDataRow extends StatelessWidget {
  final InvoiceRow           inv;
  final int                  idx;
  final bool                 isMob;
  final TextEditingController ctrl;
  final ValueChanged<String> onChanged;
  const _InvoiceDataRow({
    required this.inv,
    required this.idx,
    required this.isMob,
    required this.ctrl,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final fully = inv.leftToAllocate == 0 && inv.thisAllocation > 0;
    final odd   = idx.isOdd;

    return Container(
      color: odd ? const Color(0xFFF8FBFB) : Colors.white,
      padding: EdgeInsets.symmetric(
          horizontal: isMob ? 14 : 20, vertical: 10),
      child: isMob ? _mobRow(fully) : _deskRow(fully),
    );
  }

  Widget _mobRow(bool fully) => Row(
    crossAxisAlignment: CrossAxisAlignment.center,
    children: [
      SizedBox(
        width: 28,
        child: Text('${inv.sno}',
            style: const TextStyle(
                fontSize: 12, color: T.textMid)),
      ),
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(inv.reference,
                style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: T.text)),
            Text(inv.date,
                style: const TextStyle(
                    fontSize: 11, color: T.textMid)),
          ],
        ),
      ),
      SizedBox(
        width: 72,
        child: Text('₹${inv.amount.toStringAsFixed(0)}',
            textAlign: TextAlign.right,
            style: const TextStyle(
                fontSize: 12, color: T.text)),
      ),
      SizedBox(
          width: 90, child: _allocField()),
    ],
  );

  Widget _deskRow(bool fully) => Row(
    children: [
      SizedBox(
        width: 44,
        child: Container(
          width: 24, height: 24,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: T.primaryLight,
            borderRadius: BorderRadius.circular(6),
          ),
          child: Text('${inv.sno}',
              style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: T.primary)),
        ),
      ),
      SizedBox(width: 105,
          child: Text(inv.date,
              style: const TextStyle(fontSize: 12, color: T.textMid))),
      Expanded(
        child: Row(children: [
          Container(
            width: 6, height: 6,
            decoration: const BoxDecoration(
                color: T.primary, shape: BoxShape.circle),
          ),
          const SizedBox(width: 6),
          Text(inv.reference,
              style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: T.text)),
        ]),
      ),
      SizedBox(
        width: 100,
        child: Text('₹${inv.amount.toStringAsFixed(2)}',
            textAlign: TextAlign.right,
            style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: T.text)),
      ),
      SizedBox(
        width: 140,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            if (fully)
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: T.success.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text('PAID',
                    style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: T.success)),
              )
            else
              Text('₹${inv.leftToAllocate.toStringAsFixed(2)}',
                  textAlign: TextAlign.right,
                  style: const TextStyle(
                      fontSize: 13, color: T.warn)),
          ],
        ),
      ),
      SizedBox(width: 120,
          child: Padding(
              padding: const EdgeInsets.only(left: 12),
              child: _allocField())),
    ],
  );

  Widget _allocField() => TextField(
    controller: ctrl,
    onChanged: onChanged,
    keyboardType: const TextInputType.numberWithOptions(decimal: true),
    inputFormatters: [
      FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}'))
    ],
    textAlign: TextAlign.right,
    style: const TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        color: T.primary),
    decoration: InputDecoration(
      isDense: true,
      contentPadding:
      const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
      filled: true,
      fillColor: T.primaryLight,
      border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: T.border)),
      enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: T.primary.withOpacity(0.3))),
      focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: T.primary, width: 1.8)),
      hintText: '0.00',
      hintStyle: const TextStyle(color: T.hint, fontSize: 12),
    ),
  );
}

// ═══════════════════════════════════════════
//  EMPTY STATE
// ═══════════════════════════════════════════
class _EmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity,
    padding: const EdgeInsets.symmetric(vertical: 40),
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 56, height: 56,
          decoration: BoxDecoration(
            color: T.primaryLight,
            borderRadius: BorderRadius.circular(16),
          ),
          child: const Icon(Icons.inbox_rounded,
              color: T.primary, size: 28),
        ),
        const SizedBox(height: 12),
        const Text('No invoices loaded',
            style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: T.textMid)),
        const SizedBox(height: 4),
        const Text('Enter supplier name & balance to load invoices',
            style: TextStyle(fontSize: 12, color: T.hint)),
      ],
    ),
  );
}

// ═══════════════════════════════════════════
//  TOTAL ROW
// ═══════════════════════════════════════════
class _TotalRow extends StatelessWidget {
  final double total;
  final bool   isMob;
  const _TotalRow({required this.total, required this.isMob});

  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity,
    padding: EdgeInsets.symmetric(
        horizontal: isMob ? 14 : 20, vertical: 12),
    decoration: const BoxDecoration(
      color: Color(0xFFF1F8F7),
      border: Border(top: BorderSide(color: T.border)),
    ),
    child: Row(
      children: [
        const Spacer(),
        const Text('TOTAL',
            style: TextStyle(
                fontWeight: FontWeight.w800,
                fontSize: 13,
                color: T.text,
                letterSpacing: 0.5)),
        const SizedBox(width: 16),
        Container(
          constraints: const BoxConstraints(minWidth: 120),
          padding: const EdgeInsets.symmetric(
              horizontal: 14, vertical: 9),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [T.gradStart, T.gradEnd],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(8),
            boxShadow: [
              BoxShadow(
                color: T.primary.withOpacity(0.30),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Text(
            '₹ ${total.toStringAsFixed(2)}',
            textAlign: TextAlign.right,
            style: const TextStyle(
                fontWeight: FontWeight.w800,
                fontSize: 14,
                color: Colors.white),
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
  final bool         full;
  const _SaveBtn({required this.onTap, required this.full});

  @override
  Widget build(BuildContext context) => Container(
    width: full ? double.infinity : null,
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
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 36),
          child: Row(
            mainAxisSize: full ? MainAxisSize.max : MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              Icon(Icons.save_rounded, color: Colors.white, size: 18),
              SizedBox(width: 8),
              Text('SAVE PAYMENT',
                  style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                      fontSize: 14,
                      letterSpacing: 1.0)),
            ],
          ),
        ),
      ),
    ),
  );
}