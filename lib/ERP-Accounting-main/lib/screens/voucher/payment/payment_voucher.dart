import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../widgets/app_colors.dart';
import '../../../services/voucher/payment_view_api.dart';

class PaymentVoucherScreen extends StatefulWidget {
  const PaymentVoucherScreen({super.key});

  @override
  State<PaymentVoucherScreen> createState() => _PaymentVoucherScreenState();
}

class _PaymentVoucherScreenState extends State<PaymentVoucherScreen> {
  late final TextEditingController _dateCtrl;
  late final TextEditingController _chequeDateCtrl;
  final _nameCtrl = TextEditingController();
  final _balCtrl = TextEditingController();
  final _amtCtrl = TextEditingController();
  final _remarksCtrl = TextEditingController();
  final _searchCtrl = TextEditingController();

  final _paymentTypes = ['Supplier Payment', 'Advance Payment', 'Other Payment'];
  final _categories = ['Supplier', 'Customer', 'Other'];
  final _payTypes = ['Cash', 'Cheque', 'NEFT'];
  final _payAccounts = ['demo cash', 'HDFC Bank', 'SBI Bank', 'ICICI Bank', 'Axis Bank'];

  String? _paymentType;
  String? _category;
  String? _payType = 'Cash';
  String? _payAccount = 'demo cash';

  bool _isAddMode = false;
  late Future<List<PaymentItemModel>> _paymentListFuture;
  String _searchQuery = '';
  PaymentAutofillModel? _selectedSupplier;

  @override
  void initState() {
    super.initState();
    final today = _todayText();
    _dateCtrl = TextEditingController(text: today);
    _chequeDateCtrl = TextEditingController(text: today);
    _paymentListFuture = PaymentViewApiService.fetchPaymentList();
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
    final supplierName = _nameCtrl.text.trim();
    final paymentAmt = _amtCtrl.text.trim();
    final remark = _remarksCtrl.text.trim();
    final payMode = _payType ?? 'Cash';
    final payAccount = _payAccount ?? 'demo cash';

    if (supplierName.isEmpty || paymentAmt.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please enter supplier name and amount.'),
          backgroundColor: AppColors.voucherDanger,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          margin: const EdgeInsets.all(16),
        ),
      );
      return;
    }

    final response = await PaymentViewApiService.insertPaymentVoucher(
      supplierName: supplierName,
      payMode: payMode.toUpperCase(),
      paymentAmt: paymentAmt,
      payAccount: payAccount,
      remark: remark,
    );

    if (response['error'] == false) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              response['message'] ?? 'Payment saved successfully!',
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            backgroundColor: AppColors.voucherSuccess,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            margin: const EdgeInsets.all(16),
          ),
        );
      }
      
      // Give the backend a tiny delay to commit the database row before fetching
      await Future.delayed(const Duration(milliseconds: 500));
      
      setState(() {
        _nameCtrl.clear();
        _amtCtrl.clear();
        _remarksCtrl.clear();
        _balCtrl.clear();
        _selectedSupplier = null;
        _isAddMode = false;
        _paymentListFuture = PaymentViewApiService.fetchPaymentList();
      });
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(response['message'] ?? 'Failed to save payment'),
            backgroundColor: AppColors.voucherDanger,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            margin: const EdgeInsets.all(16),
          ),
        );
      }
    }
  }

  void _showAllocationSheet(PaymentAutofillModel supplier) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.75,
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                decoration: const BoxDecoration(
                  border: Border(bottom: BorderSide(color: Color(0xFFE5ECF5))),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Allocate Pending Invoices',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AppColors.text1),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, color: AppColors.text2),
                      onPressed: () => Navigator.pop(context),
                    )
                  ],
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: _AllocationList(supplier: supplier),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.brand,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text('CONFIRM ALLOCATION', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
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
            _isAddMode ? 'Add Payment' : 'Payment Voucher',
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
                        title: 'Add Payment Voucher',
                        subtitle: 'Record supplier payment details',
                        icon: Icons.payments_rounded,
                        dateCtrl: _dateCtrl,
                        nameCtrl: _nameCtrl,
                        balCtrl: _balCtrl,
                        amtCtrl: _amtCtrl,
                        remarksCtrl: _remarksCtrl,
                        chequeDateCtrl: _chequeDateCtrl,
                        paymentType: _paymentType,
                        paymentTypes: _paymentTypes,
                        category: _category,
                        categories: _categories,
                        payType: _payType,
                        payTypes: _payTypes,
                        payAccount: _payAccount,
                        payAccounts: _payAccounts,
                        selectedSupplier: _selectedSupplier,
                        onPaymentTypeChanged: (value) => setState(() => _paymentType = value),
                        onCategoryChanged: (value) => setState(() => _category = value),
                        onPayTypeChanged: (value) => setState(() => _payType = value),
                        onPayAccountChanged: (value) => setState(() => _payAccount = value),
                        onSupplierSelected: (supplier) {
                          setState(() {
                            _selectedSupplier = supplier;
                            if (supplier != null) {
                              _nameCtrl.text = supplier.name ?? '';
                              _balCtrl.text = supplier.balance ?? '';
                            }
                          });
                          if (supplier != null) {
                            _showAllocationSheet(supplier);
                          }
                        },
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
                              hintText: 'Search payments...',
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
                          child: FutureBuilder<List<PaymentItemModel>>(
                            future: _paymentListFuture,
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
                                return (item.ledgerName?.toLowerCase().contains(q) ?? false) ||
                                    (item.id?.toString().contains(q) ?? false);
                              }).toList();

                              return ListView.separated(
                                padding: EdgeInsets.all(isMobile ? 16 : 24),
                                itemCount: data.length,
                                separatorBuilder: (context, index) => const SizedBox(height: 14),
                                itemBuilder: (context, index) {
                                  return _PaymentCard(item: data[index]);
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

class _PaymentCard extends StatelessWidget {
  final PaymentItemModel item;
  const _PaymentCard({required this.item});

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
                child: const Icon(Icons.payments_rounded, color: AppColors.brand, size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.ledgerName ?? 'N/A',
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
                '₹ ${item.total ?? '0.00'}',
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
                  item.payMode ?? 'N/A',
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
  final String? paymentType;
  final List<String> paymentTypes;
  final String? category;
  final List<String> categories;
  final String? payType;
  final List<String> payTypes;
  final String? payAccount;
  final List<String> payAccounts;
  final PaymentAutofillModel? selectedSupplier;
  final ValueChanged<String?> onPaymentTypeChanged;
  final ValueChanged<String?> onCategoryChanged;
  final ValueChanged<String?> onPayTypeChanged;
  final ValueChanged<String?> onPayAccountChanged;
  final ValueChanged<PaymentAutofillModel?> onSupplierSelected;
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
    required this.paymentType,
    required this.paymentTypes,
    required this.category,
    required this.categories,
    required this.payType,
    required this.payTypes,
    required this.payAccount,
    required this.payAccounts,
    required this.selectedSupplier,
    required this.onPaymentTypeChanged,
    required this.onCategoryChanged,
    required this.onPayTypeChanged,
    required this.onPayAccountChanged,
    required this.onSupplierSelected,
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
          _row(_LabeledField(label: 'Date', child: _TextInput(controller: dateCtrl, hint: 'DD-MM-YYYY', readOnly: true)), _LabeledField(label: 'Payment Type', child: _SelectInput(value: paymentType, items: paymentTypes, hint: '', onChanged: onPaymentTypeChanged))),
          _row(_LabeledField(label: 'Category', child: _SelectInput(value: category, items: categories, hint: '', onChanged: onCategoryChanged)), _LabeledField(label: 'Balance', child: _TextInput(controller: balCtrl, hint: 'Balance', fillColor: const Color(0xFFE8EEF8), keyboardType: const TextInputType.numberWithOptions(decimal: true), inputFormatters: [_amountFormatter]))),
          _row(
            _LabeledField(label: 'Name', child: _SupplierAutocomplete(controller: nameCtrl, onSelected: onSupplierSelected)),
            _LabeledField(label: 'Amount', child: _TextInput(controller: amtCtrl, hint: 'Amount', keyboardType: const TextInputType.numberWithOptions(decimal: true), inputFormatters: [_amountFormatter]))
          ),
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

class _SupplierAutocomplete extends StatefulWidget {
  final TextEditingController controller;
  final ValueChanged<PaymentAutofillModel?> onSelected;

  const _SupplierAutocomplete({required this.controller, required this.onSelected});

  @override
  State<_SupplierAutocomplete> createState() => _SupplierAutocompleteState();
}

class _SupplierAutocompleteState extends State<_SupplierAutocomplete> {
  final FocusNode _focusNode = FocusNode();
  PaymentAutofillModel? _lastSelected;

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(_onFocusChanged);
  }

  Future<void> _onFocusChanged() async {
    if (!_focusNode.hasFocus && widget.controller.text.isNotEmpty && _lastSelected == null) {
      // The user typed something but didn't pick from the list. Auto-fetch and pick the first match.
      final results = await PaymentViewApiService.fetchAutofill(widget.controller.text);
      if (results.isNotEmpty && mounted) {
        _lastSelected = results.first;
        widget.controller.text = _lastSelected!.name ?? '';
        widget.onSelected(_lastSelected);
      }
    }
  }

  @override
  void dispose() {
    _focusNode.removeListener(_onFocusChanged);
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RawAutocomplete<PaymentAutofillModel>(
      textEditingController: widget.controller,
      focusNode: _focusNode,
      optionsBuilder: (TextEditingValue textEditingValue) async {
        if (textEditingValue.text.isEmpty) {
          return const Iterable<PaymentAutofillModel>.empty();
        }
        return await PaymentViewApiService.fetchAutofill(textEditingValue.text);
      },
      displayStringForOption: (PaymentAutofillModel option) => option.name ?? '',
      onSelected: (option) {
        _lastSelected = option;
        widget.onSelected(option);
      },
      fieldViewBuilder: (context, textEditingController, focusNode, onFieldSubmitted) {
        return TextField(
          controller: textEditingController,
          focusNode: focusNode,
          onChanged: (v) {
            _lastSelected = null;
            widget.onSelected(null);
          },
          decoration: _inputDecoration(hint: 'Supplier Name'),
          style: _fieldTextStyle,
        );
      },
      optionsViewBuilder: (context, onSelected, options) {
        return Align(
          alignment: Alignment.topLeft,
          child: Material(
            elevation: 4.0,
            borderRadius: BorderRadius.circular(8),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 200, maxWidth: 350),
              child: ListView.builder(
                padding: EdgeInsets.zero,
                shrinkWrap: true,
                itemCount: options.length,
                itemBuilder: (BuildContext context, int index) {
                  final option = options.elementAt(index);
                  return InkWell(
                    onTap: () => onSelected(option),
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Text(option.name ?? '', style: _fieldTextStyle),
                    ),
                  );
                },
              ),
            ),
          ),
        );
      },
    );
  }
}

class _AllocationList extends StatelessWidget {
  final PaymentAutofillModel? supplier;
  const _AllocationList({required this.supplier});

  @override
  Widget build(BuildContext context) {
    final invoices = supplier?.invoices ?? [];

    if (invoices.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.receipt_long_rounded, size: 48, color: AppColors.text2.withOpacity(0.3)),
            const SizedBox(height: 16),
            const Text(
              'No pending invoices to allocate.',
              style: TextStyle(color: AppColors.text2, fontSize: 16, fontWeight: FontWeight.w600),
            ),
          ],
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.symmetric(vertical: 16),
      itemCount: invoices.length,
      separatorBuilder: (context, index) => const SizedBox(height: 16),
      itemBuilder: (context, index) {
        final inv = invoices[index];
        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFE5ECF5)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: const BoxDecoration(
                  color: Color(0xFFF9FAFB),
                  borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                  border: Border(bottom: BorderSide(color: Color(0xFFE5ECF5))),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Invoice #${inv.invoiceId ?? '-'}',
                      style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15, color: AppColors.text1),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.brand.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        inv.date ?? 'N/A',
                        style: const TextStyle(color: AppColors.brand, fontWeight: FontWeight.w700, fontSize: 12),
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Amount', style: TextStyle(color: AppColors.text2, fontSize: 13, fontWeight: FontWeight.w600)),
                        Text('₹ ${inv.amount ?? '0.00'}', style: const TextStyle(color: AppColors.text1, fontSize: 14, fontWeight: FontWeight.w700)),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Left to Allocate', style: TextStyle(color: AppColors.text2, fontSize: 13, fontWeight: FontWeight.w600)),
                        Text('₹ ${inv.leftToAllocate ?? '0.00'}', style: const TextStyle(color: AppColors.voucherDanger, fontSize: 14, fontWeight: FontWeight.w800)),
                      ],
                    ),
                    const SizedBox(height: 16),
                    const Divider(height: 1, color: Color(0xFFE5ECF5)),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        const Text('This Allocation', style: TextStyle(color: AppColors.text1, fontSize: 14, fontWeight: FontWeight.w800)),
                        const Spacer(),
                        SizedBox(
                          width: 140,
                          height: 42,
                          child: TextField(
                            keyboardType: const TextInputType.numberWithOptions(decimal: true),
                            decoration: InputDecoration(
                              hintText: inv.thisAllocation ?? '0.00',
                              hintStyle: const TextStyle(color: Color(0xFF6B7C9D)),
                              filled: true,
                              fillColor: const Color(0xFFE8EEF8),
                              contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
                              prefixText: '₹ ',
                              prefixStyle: const TextStyle(color: AppColors.text1, fontWeight: FontWeight.w600, fontSize: 14),
                            ),
                            style: const TextStyle(fontWeight: FontWeight.w700, color: AppColors.text1, fontSize: 14),
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
      },
    );
  }
}
