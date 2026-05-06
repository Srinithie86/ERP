import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../widgets/app_colors.dart';
import '../../../services/voucher/receipt_view_api.dart';

class ReceiptVoucherScreen extends StatefulWidget {
  const ReceiptVoucherScreen({super.key});

  @override
  State<ReceiptVoucherScreen> createState() => _ReceiptVoucherScreenState();
}

class _ReceiptVoucherScreenState extends State<ReceiptVoucherScreen> {
  late final TextEditingController _dateCtrl;
  late final TextEditingController _chequeDateCtrl;
  final _nameCtrl = TextEditingController();
  final _balCtrl = TextEditingController();
  final _amtCtrl = TextEditingController();
  final _remarksCtrl = TextEditingController();
  final _searchCtrl = TextEditingController();

  final _receiptTypes = ['Customer Receipt', 'Advance Receipt', 'Other Receipt'];
  final _categories = ['Customer', 'Supplier', 'Other'];
  final _payTypes = ['Cash', 'Cheque', 'NEFT'];
  final _payAccounts = ['demo cash', 'HDFC Bank', 'SBI Bank', 'ICICI Bank', 'Axis Bank'];

  String? _receiptType;
  String? _category;
  String? _payType = 'Cash';
  String? _payAccount = 'demo cash';

  bool _isAddMode = false;
  late Future<List<ReceiptItemModel>> _receiptListFuture;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    final today = _todayText();
    _dateCtrl = TextEditingController(text: today);
    _chequeDateCtrl = TextEditingController(text: today);
    _receiptListFuture = ReceiptViewApiService.fetchReceiptList();
  }

  @override
  void dispose() {
    _dateCtrl.dispose();
    _chequeDateCtrl.dispose();
    _nameCtrl.dispose();
    _balCtrl.dispose();
    _amtCtrl.dispose();
    _remarksCtrl.dispose();
    _searchCtrl.dispose();
    super.dispose();
  }

  static String _todayText() {
    final now = DateTime.now();
    String two(int value) => value.toString().padLeft(2, '0');
    return '${two(now.day)}-${two(now.month)}-${now.year}';
  }

  Future<void> _save() async {
    if (_nameCtrl.text.isEmpty || _amtCtrl.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter name and amount')),
      );
      return;
    }

    final result = await ReceiptViewApiService.insertReceiptVoucher(
      customerName: _nameCtrl.text,
      payType: _payType ?? '',
      payAccount: _payAccount ?? '',
      amount: _amtCtrl.text,
      remarks: _remarksCtrl.text,
    );

    if (mounted) {
      if (result['error'] == false) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              result['message'] ?? 'Receipt saved successfully!',
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            backgroundColor: AppColors.voucherSuccess,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            margin: const EdgeInsets.all(16),
          ),
        );
        setState(() {
          _isAddMode = false;
          _receiptListFuture = ReceiptViewApiService.fetchReceiptList();
          _nameCtrl.clear();
          _amtCtrl.clear();
          _remarksCtrl.clear();
          _balCtrl.clear();
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              result['message'] ?? 'Failed to save receipt',
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            margin: const EdgeInsets.all(16),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final isMobile = width < 760;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: AppColors.brand,
        statusBarIconBrightness: Brightness.light,
      ),
      child: Scaffold(
        backgroundColor: AppColors.bg,
        appBar: AppBar(
          backgroundColor: AppColors.brand,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 20),
            onPressed: () {
              if (_isAddMode) {
                setState(() => _isAddMode = false);
              } else {
                Navigator.pop(context);
              }
            },
          ),
          title: Text(
            _isAddMode ? 'Add Receipt' : 'Receipt Voucher',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        body: Column(
          children: [
            Expanded(
              child: _isAddMode
                  ? SingleChildScrollView(
                      padding: EdgeInsets.fromLTRB(
                        isMobile ? 16 : 26,
                        24,
                        isMobile ? 16 : 26,
                        32,
                      ),
                      child: _VoucherForm(
                        isMobile: isMobile,
                        title: 'Add Receipt Voucher',
                        subtitle: 'Record customer receipt details',
                        icon: Icons.receipt_long_rounded,
                        dateCtrl: _dateCtrl,
                        nameCtrl: _nameCtrl,
                        balCtrl: _balCtrl,
                        amtCtrl: _amtCtrl,
                        remarksCtrl: _remarksCtrl,
                        chequeDateCtrl: _chequeDateCtrl,
                        receiptType: _receiptType,
                        receiptTypes: _receiptTypes,
                        category: _category,
                        categories: _categories,
                        payType: _payType,
                        payTypes: _payTypes,
                        payAccount: _payAccount,
                        payAccounts: _payAccounts,
                        onReceiptTypeChanged: (value) => setState(() => _receiptType = value),
                        onCategoryChanged: (value) => setState(() => _category = value),
                        onPayTypeChanged: (value) => setState(() => _payType = value),
                        onPayAccountChanged: (value) => setState(() => _payAccount = value),
                        onSave: _save,
                      ),
                    )
                  : Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                          child: TextField(
                            controller: _searchCtrl,
                            onChanged: (v) => setState(() => _searchQuery = v),
                            decoration: InputDecoration(
                              hintText: 'Search receipts...',
                              filled: true,
                              fillColor: Colors.white,
                              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(color: Color(0xFFE5ECF5)),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(color: Color(0xFFE5ECF5)),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(color: AppColors.brand, width: 1.5),
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          child: FutureBuilder<List<ReceiptItemModel>>(
                            future: _receiptListFuture,
                            builder: (context, snapshot) {
                              if (snapshot.connectionState == ConnectionState.waiting) {
                                return const Center(child: CircularProgressIndicator());
                              } else if (snapshot.hasError) {
                                return Center(child: Text('Error: ${snapshot.error}'));
                              } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                                return const Center(child: Text('No records found.'));
                              }

                              final data = snapshot.data!.where((item) {
                                final q = _searchQuery.toLowerCase();
                                return (item.customerName?.toLowerCase().contains(q) ?? false) ||
                                    (item.id?.toString().contains(q) ?? false);
                              }).toList();

                              return ListView.separated(
                                padding: EdgeInsets.all(isMobile ? 16 : 24),
                                itemCount: data.length,
                                separatorBuilder: (_, _) => const SizedBox(height: 14),
                                itemBuilder: (context, index) {
                                  return _ReceiptCard(item: data[index]);
                                },
                              );
                            },
                          ),
                        ),
                      ],
                    ),
            ),
          ],
        ),
        floatingActionButton: !_isAddMode
            ? FloatingActionButton(
                onPressed: () => setState(() => _isAddMode = true),
                backgroundColor: AppColors.brand,
                child: const Icon(Icons.add, color: Colors.white),
              )
            : null,
      ),
    );
  }
}

class _ReceiptCard extends StatelessWidget {
  final ReceiptItemModel item;
  const _ReceiptCard({required this.item});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE5ECF5)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: AppColors.brand.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.receipt_long_rounded, color: AppColors.brand, size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.customerName ?? 'N/A',
                      style: const TextStyle(
                        color: AppColors.text1,
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      'Ref: #${item.id ?? '-'}',
                      style: const TextStyle(
                        color: AppColors.text2,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                '₹ ${item.amount ?? '0.00'}',
                style: const TextStyle(
                  color: AppColors.brand,
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          const Divider(height: 1, color: Color(0xFFE5ECF5)),
          const SizedBox(height: 12),
          Row(
            children: [
              const Icon(Icons.calendar_today_rounded, size: 14, color: AppColors.text2),
              const SizedBox(width: 6),
              Text(
                item.date ?? 'N/A',
                style: const TextStyle(color: AppColors.text2, fontSize: 13, fontWeight: FontWeight.w600),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: const Color(0xFFF0F4F8),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  item.payType ?? 'N/A',
                  style: const TextStyle(color: AppColors.brand, fontSize: 11, fontWeight: FontWeight.w700),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _VoucherForm extends StatelessWidget {
  final bool isMobile;
  final String title;
  final String subtitle;
  final IconData icon;
  final TextEditingController dateCtrl;
  final TextEditingController nameCtrl;
  final TextEditingController balCtrl;
  final TextEditingController amtCtrl;
  final TextEditingController remarksCtrl;
  final TextEditingController chequeDateCtrl;
  final String? receiptType;
  final List<String> receiptTypes;
  final String? category;
  final List<String> categories;
  final String? payType;
  final List<String> payTypes;
  final String? payAccount;
  final List<String> payAccounts;
  final ValueChanged<String?> onReceiptTypeChanged;
  final ValueChanged<String?> onCategoryChanged;
  final ValueChanged<String?> onPayTypeChanged;
  final ValueChanged<String?> onPayAccountChanged;
  final VoidCallback onSave;

  const _VoucherForm({
    required this.isMobile,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.dateCtrl,
    required this.nameCtrl,
    required this.balCtrl,
    required this.amtCtrl,
    required this.remarksCtrl,
    required this.chequeDateCtrl,
    required this.receiptType,
    required this.receiptTypes,
    required this.category,
    required this.categories,
    required this.payType,
    required this.payTypes,
    required this.payAccount,
    required this.payAccounts,
    required this.onReceiptTypeChanged,
    required this.onCategoryChanged,
    required this.onPayTypeChanged,
    required this.onPayAccountChanged,
    required this.onSave,
  });

  @override
  Widget build(BuildContext context) {
    final showChequeDate = payType == 'Cheque';
    final form = Container(
      padding: EdgeInsets.all(isMobile ? 16 : 22),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE5ECF5)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _VoucherHeader(icon: icon, title: title, subtitle: subtitle),
          const SizedBox(height: 24),
          _row(_LabeledField(label: 'Date', child: _TextInput(controller: dateCtrl, hint: 'DD-MM-YYYY', readOnly: true)), _LabeledField(label: 'Receipt Type', child: _SelectInput(value: receiptType, items: receiptTypes, hint: '', onChanged: onReceiptTypeChanged))),
          _row(_LabeledField(label: 'Category', child: _SelectInput(value: category, items: categories, hint: '', onChanged: onCategoryChanged)), _LabeledField(label: 'Balance', child: _TextInput(controller: balCtrl, hint: 'Balance', fillColor: const Color(0xFFE8EEF8), keyboardType: const TextInputType.numberWithOptions(decimal: true), inputFormatters: [_amountFormatter]))),
          _row(_LabeledField(label: 'Name', child: _TextInput(controller: nameCtrl, hint: 'Customer Name')), _LabeledField(label: 'Amount', child: _TextInput(controller: amtCtrl, hint: 'Amount', keyboardType: const TextInputType.numberWithOptions(decimal: true), inputFormatters: [_amountFormatter]))),
          _row(_LabeledField(label: 'Pay Type', child: _SelectInput(value: payType, items: payTypes, hint: '', onChanged: onPayTypeChanged)), _LabeledField(label: 'Pay Account', child: _SelectInput(value: payAccount, items: payAccounts, hint: '', onChanged: onPayAccountChanged))),
          showChequeDate ? _row(_LabeledField(label: 'Remarks', child: _TextInput(controller: remarksCtrl, hint: 'Remarks', minLines: 3, maxLines: 4)), _LabeledField(label: 'Cheque Date', child: _TextInput(controller: chequeDateCtrl, hint: 'DD-MM-YYYY', readOnly: true))) : _wideRow(_LabeledField(label: 'Remarks', child: _TextInput(controller: remarksCtrl, hint: 'Remarks', minLines: 3, maxLines: 4))),
          SizedBox(height: isMobile ? 8 : 12),
          _saveRow(_SaveButton(onPressed: onSave)),
        ],
      ),
    );

    return isMobile ? form : Center(child: ConstrainedBox(constraints: const BoxConstraints(maxWidth: 1180), child: form));
  }

  Widget _row(Widget left, Widget right) {
    if (isMobile) return Column(children: [left, const SizedBox(height: 16), right, const SizedBox(height: 16)]);
    return Padding(padding: const EdgeInsets.only(bottom: 18), child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [Expanded(child: left), const SizedBox(width: 24), Expanded(child: right)]));
  }

  Widget _wideRow(Widget child) => Padding(padding: EdgeInsets.only(bottom: isMobile ? 16 : 18), child: child);

  Widget _saveRow(Widget child) {
    if (isMobile) return child;
    return Row(children: [const Spacer(), Expanded(child: _LabeledField(label: '', child: child))]);
  }

  static final _amountFormatter = FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}'));
}

class _VoucherHeader extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  const _VoucherHeader({required this.icon, required this.title, required this.subtitle});
  @override
  Widget build(BuildContext context) {
    return Row(children: [
      Container(width: 42, height: 42, decoration: BoxDecoration(color: AppColors.brand.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(12)), child: Icon(icon, color: AppColors.brand, size: 22)),
      const SizedBox(width: 12),
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(title, style: const TextStyle(color: AppColors.text1, fontSize: 18, fontWeight: FontWeight.w800)), const SizedBox(height: 2), Text(subtitle, style: const TextStyle(color: AppColors.text2, fontSize: 12, fontWeight: FontWeight.w500))])),
    ]);
  }
}

class _LabeledField extends StatelessWidget {
  final String label;
  final Widget child;
  const _LabeledField({required this.label, required this.child});
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      final inline = constraints.maxWidth >= 440;
      if (!inline) return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [_FieldLabel(label), const SizedBox(height: 8), child]);
      return Row(children: [SizedBox(width: 150, child: _FieldLabel(label)), Expanded(child: child)]);
    });
  }
}

class _FieldLabel extends StatelessWidget {
  final String label;
  const _FieldLabel(this.label);
  @override
  Widget build(BuildContext context) => Text(label, style: const TextStyle(color: Color(0xFF001245), fontSize: 15, fontWeight: FontWeight.w600));
}

class _TextInput extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final bool readOnly;
  final Color fillColor;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final int minLines;
  final int maxLines;
  const _TextInput({required this.controller, required this.hint, this.readOnly = false, this.fillColor = Colors.white, this.keyboardType, this.inputFormatters, this.minLines = 1, this.maxLines = 1});
  @override
  Widget build(BuildContext context) => SizedBox(height: maxLines > 1 ? 94 : 48, child: TextField(controller: controller, readOnly: readOnly, keyboardType: keyboardType, inputFormatters: inputFormatters, minLines: minLines, maxLines: maxLines, style: _fieldTextStyle, decoration: _inputDecoration(hint: hint, fillColor: fillColor)));
}

class _SelectInput extends StatelessWidget {
  final String? value;
  final List<String> items;
  final String hint;
  final ValueChanged<String?> onChanged;
  const _SelectInput({required this.value, required this.items, required this.hint, required this.onChanged});
  @override
  Widget build(BuildContext context) => SizedBox(height: 48, child: DropdownButtonFormField<String>(initialValue: value, isExpanded: true, icon: const Icon(Icons.arrow_drop_down, color: Color(0xFF888888)), decoration: _inputDecoration(hint: hint), hint: hint.isEmpty ? null : Text(hint, style: _hintTextStyle), style: _fieldTextStyle, dropdownColor: Colors.white, borderRadius: BorderRadius.circular(12), items: items.map((item) => DropdownMenuItem<String>(value: item, child: Text(item))).toList(), onChanged: onChanged));
}

class _SaveButton extends StatelessWidget {
  final VoidCallback onPressed;
  const _SaveButton({required this.onPressed});
  @override
  Widget build(BuildContext context) => SizedBox(width: double.infinity, height: 48, child: ElevatedButton(onPressed: onPressed, style: ElevatedButton.styleFrom(backgroundColor: AppColors.brand, foregroundColor: Colors.white, elevation: 3, shadowColor: AppColors.brand.withValues(alpha: 0.25), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)), padding: EdgeInsets.zero), child: const Text('SAVE', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800))));
}

const _fieldTextStyle = TextStyle(color: Color(0xFF2F406B), fontSize: 15, fontWeight: FontWeight.w500);
const _hintTextStyle = TextStyle(color: Color(0xFF6B7C9D), fontSize: 15, fontWeight: FontWeight.w400);

InputDecoration _inputDecoration({required String hint, Color fillColor = Colors.white}) => InputDecoration(hintText: hint, hintStyle: _hintTextStyle, filled: true, fillColor: fillColor, isDense: true, contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12), border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFD7E1ED))), enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFD7E1ED))), focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.brand, width: 1.5)));
