import 'package:flutter/material.dart';

// ─── Model ───────────────────────────────────────────────────────────────────

class ReceiptVoucher {
  final String id;
  final String date;
  final String customerName;
  final String payType;
  final double amount;
  final String remarks;

  ReceiptVoucher({
    required this.id,
    required this.date,
    required this.customerName,
    required this.payType,
    required this.amount,
    required this.remarks,
  });
}

// ─── Main Screen ─────────────────────────────────────────────────────────────

class ReceiptVoucherScreen extends StatefulWidget {
  const ReceiptVoucherScreen({super.key});

  @override
  State<ReceiptVoucherScreen> createState() => _ReceiptVoucherScreenState();
}

class _ReceiptVoucherScreenState extends State<ReceiptVoucherScreen> {
  bool _showForm = false;
  bool _showList = false;

  final List<ReceiptVoucher> _vouchers = [
    ReceiptVoucher(
      id: 'RV-50200',
      date: '07-04-2026',
      customerName: 'Ravi Kumar',
      payType: 'Cash',
      amount: 15000,
      remarks: 'April payment',
    ),
    ReceiptVoucher(
      id: 'RV-50199',
      date: '06-04-2026',
      customerName: 'Priya Devi',
      payType: 'Bank Transfer',
      amount: 32500,
      remarks: 'Invoice #1023',
    ),
  ];

  void _openForm() => setState(() {
        _showForm = true;
        _showList = false;
      });
  void _openList() => setState(() {
        _showList = true;
        _showForm = false;
      });
  void _openHome() => setState(() {
        _showForm = false;
        _showList = false;
      });

  void _addVoucher(ReceiptVoucher v) {
    setState(() {
      _vouchers.insert(0, v);
      _showForm = false;
      _showList = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F8),
      appBar: _buildAppBar(),
      body: Column(
        children: [
          _buildTabBar(),
          Expanded(
            child: _showForm
                ? ReceiptVoucherForm(onSave: _addVoucher)
                : _showList
                    ? ReceiptVoucherList(vouchers: _vouchers)
                    : _buildHomePlaceholder(),
          ),
        ],
      ),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      backgroundColor: const Color(0xFF0097A7),
      foregroundColor: Colors.white,
      title: Row(
        children: [
          const Text('Receipt Voucher',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
        ],
      ),
      actions: [
        IconButton(
            icon: const Icon(Icons.notifications_none), onPressed: () {}),
        IconButton(icon: const Icon(Icons.account_circle), onPressed: () {}),
      ],
    );
  }

  Widget _buildTabBar() {
    return Container(
      color: Colors.white,
      child: Row(
        children: [
          _tab('Receipt Voucher', !_showForm && !_showList, onTap: _openHome),
          _tab('View List', _showList, icon: Icons.list, onTap: _openList),
          _tab('Add New', _showForm, icon: Icons.add, onTap: _openForm),
          _tab('Filter', false, icon: Icons.filter_list, onTap: _openList),
        ],
      ),
    );
  }

  Widget _tab(String label, bool active,
      {IconData? icon, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: active ? const Color(0xFF0097A7) : Colors.transparent,
              width: 2.5,
            ),
          ),
        ),
        child: Row(
          children: [
            if (icon != null) ...[
              Icon(icon,
                  size: 16,
                  color: active ? const Color(0xFF0097A7) : Colors.grey[600]),
              const SizedBox(width: 4),
            ],
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: active ? FontWeight.w600 : FontWeight.normal,
                color: active ? const Color(0xFF0097A7) : Colors.grey[700],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHomePlaceholder() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.receipt_long, size: 64, color: Colors.grey[300]),
          const SizedBox(height: 16),
          Text('Receipt Voucher',
              style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[600])),
          const SizedBox(height: 8),
          Text('Tap "Add New" to create a voucher',
              style: TextStyle(color: Colors.grey[400])),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: _openForm,
            icon: const Icon(Icons.add),
            label: const Text('Add New'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF0097A7),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Form ─────────────────────────────────────────────────────────────────────

class ReceiptVoucherForm extends StatefulWidget {
  final void Function(ReceiptVoucher) onSave;
  const ReceiptVoucherForm({super.key, required this.onSave});

  @override
  State<ReceiptVoucherForm> createState() => _ReceiptVoucherFormState();
}

class _ReceiptVoucherFormState extends State<ReceiptVoucherForm> {
  final _formKey = GlobalKey<FormState>();

  final _customerCtrl = TextEditingController();
  final _amountCtrl = TextEditingController();
  final _remarksCtrl = TextEditingController();

  String _date = _today();
  String? _payType;

  static String _today() {
    final now = DateTime.now();
    return '${now.day.toString().padLeft(2, '0')}-'
        '${now.month.toString().padLeft(2, '0')}-'
        '${now.year}';
  }

  static int _voucherCounter = 50201;

  final List<String> _payTypes = ['Cash', 'Bank Transfer', 'Cheque', 'UPI'];

  void _save() {
    if (_formKey.currentState!.validate()) {
      final v = ReceiptVoucher(
        id: 'RV-${_voucherCounter++}',
        date: _date,
        customerName: _customerCtrl.text.trim(),
        payType: _payType ?? '',
        amount: double.tryParse(_amountCtrl.text.trim()) ?? 0,
        remarks: _remarksCtrl.text.trim(),
      );
      widget.onSave(v);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Receipt Voucher saved successfully!'),
          backgroundColor: Color(0xFF0097A7),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            _card(
              child: Column(
                children: [
                  // Row 1: Date + Customer Name
                  Row(
                    children: [
                      Expanded(child: _labelField('Date', _dateField())),
                      const SizedBox(width: 16),
                      Expanded(
                          child: _labelField(
                              'Customer Name',
                              _textField(_customerCtrl, 'Customer Name',
                                  required: true))),
                    ],
                  ),
                  const SizedBox(height: 16),
                  // Row 2: Pay Type + Amount
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                          child: _labelField(
                              'Pay Type',
                              _dropdownField(
                                  _payTypes, _payType, 'Select Option', (v) {
                                setState(() => _payType = v);
                              }, required: true))),
                      const SizedBox(width: 16),
                      Expanded(
                          child: _labelField(
                              'Amount',
                              _textField(_amountCtrl, 'Amount',
                                  keyboardType: TextInputType.number,
                                  required: true))),
                    ],
                  ),
                  const SizedBox(height: 16),
                  // Row 3: Remarks
                  _labelField('Remarks', _remarksField()),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Align(
              alignment: Alignment.centerRight,
              child: ElevatedButton(
                onPressed: _save,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1565C0),
                  foregroundColor: Colors.white,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 36, vertical: 14),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(6)),
                ),
                child: const Text('Save',
                    style:
                        TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _card({required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 2))
        ],
      ),
      child: child,
    );
  }

  Widget _labelField(String label, Widget field) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Color(0xFF444444))),
        const SizedBox(height: 6),
        field,
      ],
    );
  }

  Widget _textField(
    TextEditingController ctrl,
    String hint, {
    bool required = false,
    TextInputType? keyboardType,
  }) {
    return TextFormField(
      controller: ctrl,
      keyboardType: keyboardType,
      decoration: _inputDeco(hint),
      validator: required
          ? (v) => (v == null || v.trim().isEmpty) ? 'Required' : null
          : null,
    );
  }

  Widget _dateField() {
    return GestureDetector(
      onTap: () async {
        final picked = await showDatePicker(
          context: context,
          initialDate: DateTime.now(),
          firstDate: DateTime(2020),
          lastDate: DateTime(2030),
          builder: (ctx, child) => Theme(
            data: ThemeData.light().copyWith(
              colorScheme: const ColorScheme.light(primary: Color(0xFF0097A7)),
            ),
            child: child!,
          ),
        );
        if (picked != null) {
          setState(() {
            _date =
                '${picked.day.toString().padLeft(2, '0')}-${picked.month.toString().padLeft(2, '0')}-${picked.year}';
          });
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey[300]!),
          borderRadius: BorderRadius.circular(6),
          color: Colors.white,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(_date,
                  style: const TextStyle(fontSize: 14, color: Colors.black87)),
            ),
            const Icon(Icons.calendar_today,
                size: 16, color: Color(0xFF0097A7)),
          ],
        ),
      ),
    );
  }

  Widget _dropdownField(
    List<String> items,
    String? value,
    String hint,
    void Function(String?) onChanged, {
    bool required = false,
  }) {
    return DropdownButtonFormField<String>(
      initialValue: value,
      isExpanded: true,
      decoration: _inputDeco(hint),
      items:
          items.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
      onChanged: onChanged,
      validator: required ? (v) => v == null ? 'Required' : null : null,
      icon: const Icon(Icons.keyboard_arrow_down, color: Color(0xFF0097A7)),
    );
  }

  Widget _remarksField() {
    return TextFormField(
      controller: _remarksCtrl,
      maxLines: 3,
      decoration: _inputDeco('Remarks'),
    );
  }

  InputDecoration _inputDeco(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(color: Colors.grey[400], fontSize: 13),
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(6),
        borderSide: BorderSide(color: Colors.grey[300]!),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(6),
        borderSide: BorderSide(color: Colors.grey[300]!),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(6),
        borderSide: const BorderSide(color: Color(0xFF0097A7), width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(6),
        borderSide: const BorderSide(color: Colors.red),
      ),
      filled: true,
      fillColor: Colors.white,
    );
  }
}

// ─── List View ────────────────────────────────────────────────────────────────

class ReceiptVoucherList extends StatefulWidget {
  final List<ReceiptVoucher> vouchers;
  const ReceiptVoucherList({super.key, required this.vouchers});

  @override
  State<ReceiptVoucherList> createState() => _ReceiptVoucherListState();
}

class _ReceiptVoucherListState extends State<ReceiptVoucherList> {
  String _searchQuery = '';
  String? _filterPayType;
  String? _filterDate;
  bool _showFilterPanel = false;

  List<String> get _payTypes => ['Cash', 'Bank Transfer', 'Cheque', 'UPI'];

  List<ReceiptVoucher> get _filtered {
    return widget.vouchers.where((v) {
      final matchSearch = _searchQuery.isEmpty ||
          v.customerName.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          v.id.toLowerCase().contains(_searchQuery.toLowerCase());
      final matchPay = _filterPayType == null || v.payType == _filterPayType;
      final matchDate = _filterDate == null || v.date == _filterDate;
      return matchSearch && matchPay && matchDate;
    }).toList();
  }

  void _clearFilters() {
    setState(() {
      _filterPayType = null;
      _filterDate = null;
      _searchQuery = '';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Search + Filter toggle bar
        Container(
          color: Colors.white,
          padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  onChanged: (v) => setState(() => _searchQuery = v),
                  decoration: InputDecoration(
                    hintText: 'Search by customer or voucher ID...',
                    hintStyle: TextStyle(fontSize: 13, color: Colors.grey[400]),
                    prefixIcon: const Icon(Icons.search,
                        size: 20, color: Color(0xFF0097A7)),
                    contentPadding: const EdgeInsets.symmetric(vertical: 10),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: Colors.grey[300]!),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: Colors.grey[300]!),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(
                          color: Color(0xFF0097A7), width: 1.5),
                    ),
                    filled: true,
                    fillColor: const Color(0xFFF9F9F9),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              GestureDetector(
                onTap: () =>
                    setState(() => _showFilterPanel = !_showFilterPanel),
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: _showFilterPanel
                        ? const Color(0xFF0097A7)
                        : const Color(0xFFE0F7FA),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(Icons.filter_list,
                      color: _showFilterPanel
                          ? Colors.white
                          : const Color(0xFF0097A7),
                      size: 20),
                ),
              ),
            ],
          ),
        ),

        // Filter panel
        if (_showFilterPanel) _buildFilterPanel(),

        // Active filter chips
        if (_filterPayType != null || _filterDate != null)
          Container(
            color: const Color(0xFFF0FAFA),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            child: Row(
              children: [
                const Text('Filters: ',
                    style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey)),
                if (_filterPayType != null)
                  _chip(_filterPayType!,
                      () => setState(() => _filterPayType = null)),
                if (_filterDate != null)
                  _chip(_filterDate!, () => setState(() => _filterDate = null)),
                TextButton(
                  onPressed: _clearFilters,
                  child: const Text('Clear All',
                      style: TextStyle(fontSize: 12, color: Colors.red)),
                ),
              ],
            ),
          ),

        // List
        Expanded(
          child: _filtered.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.inbox, size: 48, color: Colors.grey[300]),
                      const SizedBox(height: 8),
                      Text('No vouchers found',
                          style: TextStyle(color: Colors.grey[400])),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: _filtered.length,
                  itemBuilder: (ctx, i) => _voucherCard(_filtered[i]),
                ),
        ),
      ],
    );
  }

  Widget _buildFilterPanel() {
    return Container(
      color: const Color(0xFFF8FFFE),
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Filter Options',
              style: TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 13,
                  color: Color(0xFF0097A7))),
          const SizedBox(height: 10),
          Row(
            children: [
              // Pay Type filter
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Pay Type',
                        style: TextStyle(fontSize: 12, color: Colors.grey)),
                    const SizedBox(height: 4),
                    DropdownButtonFormField<String>(
                      initialValue: _filterPayType,
                      decoration: InputDecoration(
                        hintText: 'All',
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 10),
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(6),
                            borderSide: BorderSide(color: Colors.grey[300]!)),
                        enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(6),
                            borderSide: BorderSide(color: Colors.grey[300]!)),
                        filled: true,
                        fillColor: Colors.white,
                        isDense: true,
                      ),
                      items: [
                        const DropdownMenuItem(value: null, child: Text('All')),
                        ..._payTypes.map(
                            (e) => DropdownMenuItem(value: e, child: Text(e))),
                      ],
                      onChanged: (v) => setState(() => _filterPayType = v),
                      icon: const Icon(Icons.keyboard_arrow_down, size: 18),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              // Date filter
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Date',
                        style: TextStyle(fontSize: 12, color: Colors.grey)),
                    const SizedBox(height: 4),
                    GestureDetector(
                      onTap: () async {
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: DateTime.now(),
                          firstDate: DateTime(2020),
                          lastDate: DateTime(2030),
                          builder: (ctx, child) => Theme(
                            data: ThemeData.light().copyWith(
                              colorScheme: const ColorScheme.light(
                                  primary: Color(0xFF0097A7)),
                            ),
                            child: child!,
                          ),
                        );
                        if (picked != null) {
                          setState(() {
                            _filterDate =
                                '${picked.day.toString().padLeft(2, '0')}-${picked.month.toString().padLeft(2, '0')}-${picked.year}';
                          });
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 12),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey[300]!),
                          borderRadius: BorderRadius.circular(6),
                          color: Colors.white,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              _filterDate ?? 'All Dates',
                              style: TextStyle(
                                  fontSize: 13,
                                  color: _filterDate != null
                                      ? Colors.black87
                                      : Colors.grey[400]),
                            ),
                            const Icon(Icons.calendar_today,
                                size: 14, color: Color(0xFF0097A7)),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _chip(String label, VoidCallback onRemove) {
    return Container(
      margin: const EdgeInsets.only(right: 6),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFF0097A7),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(label,
              style: const TextStyle(color: Colors.white, fontSize: 11)),
          const SizedBox(width: 4),
          GestureDetector(
            onTap: onRemove,
            child: const Icon(Icons.close, size: 12, color: Colors.white),
          ),
        ],
      ),
    );
  }

  Widget _voucherCard(ReceiptVoucher v) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 6,
              offset: const Offset(0, 2))
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: CircleAvatar(
          backgroundColor: const Color(0xFFE0F7FA),
          child: Text(
            v.customerName.isNotEmpty ? v.customerName[0].toUpperCase() : '?',
            style: const TextStyle(
                color: Color(0xFF0097A7), fontWeight: FontWeight.bold),
          ),
        ),
        title: Row(
          children: [
            Text(v.customerName,
                style:
                    const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
            const Spacer(),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: const Color(0xFFE8F5E9),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '₹${v.amount.toStringAsFixed(0)}',
                style: const TextStyle(
                    color: Color(0xFF2E7D32),
                    fontWeight: FontWeight.bold,
                    fontSize: 13),
              ),
            ),
          ],
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Row(
              children: [
                const Icon(Icons.confirmation_number,
                    size: 12, color: Colors.grey),
                const SizedBox(width: 4),
                Text(v.id,
                    style: TextStyle(fontSize: 12, color: Colors.grey[600])),
                const SizedBox(width: 12),
                const Icon(Icons.calendar_today, size: 12, color: Colors.grey),
                const SizedBox(width: 4),
                Text(v.date,
                    style: TextStyle(fontSize: 12, color: Colors.grey[600])),
              ],
            ),
            const SizedBox(height: 2),
            Row(
              children: [
                const Icon(Icons.payment, size: 12, color: Colors.grey),
                const SizedBox(width: 4),
                Text(v.payType,
                    style: TextStyle(fontSize: 12, color: Colors.grey[600])),
              ],
            ),
            if (v.remarks.isNotEmpty) ...[
              const SizedBox(height: 2),
              Text(v.remarks,
                  style: TextStyle(
                      fontSize: 11,
                      color: Colors.grey[400],
                      fontStyle: FontStyle.italic)),
            ],
          ],
        ),
      ),
    );
  }
}
