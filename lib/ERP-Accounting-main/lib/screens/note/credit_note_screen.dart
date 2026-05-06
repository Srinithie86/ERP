import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../widgets/app_colors.dart';
import '../../services/note/credit_view_api.dart';

class CreditNoteScreen extends StatefulWidget {
  const CreditNoteScreen({super.key});

  @override
  State<CreditNoteScreen> createState() => _CreditNoteScreenState();
}

class _CreditNoteScreenState extends State<CreditNoteScreen> {
  late final TextEditingController _dateCtrl;
  final _nameCtrl = TextEditingController();
  final _amountCtrl = TextEditingController();
  final _referenceCtrl = TextEditingController();
  final _searchCtrl = TextEditingController();

  bool _isAddMode = false;
  late Future<List<CreditNoteItemModel>> _creditListFuture;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _dateCtrl = TextEditingController(text: _todayText());
    _creditListFuture = CreditViewApiService.fetchCreditNoteList();
  }

  @override
  void dispose() {
    _dateCtrl.dispose();
    _nameCtrl.dispose();
    _amountCtrl.dispose();
    _referenceCtrl.dispose();
    _searchCtrl.dispose();
    super.dispose();
  }

  static String _todayText() {
    final now = DateTime.now();
    String two(int value) => value.toString().padLeft(2, '0');
    return '${two(now.day)}-${two(now.month)}-${now.year}';
  }

  Future<void> _save() async {
    final customerName = _nameCtrl.text.trim();
    final amount = _amountCtrl.text.trim();

    if (customerName.isEmpty || amount.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please enter customer name and amount.'),
          backgroundColor: AppColors.voucherDanger,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          margin: const EdgeInsets.all(16),
        ),
      );
      return;
    }

    final response = await CreditViewApiService.insertCreditNote(
      customerName: customerName,
      amount: amount,
    );

    if (response['error'] == false) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(response['message'] ?? 'Credit note saved successfully!', style: const TextStyle(fontWeight: FontWeight.w600)),
            backgroundColor: AppColors.voucherSuccess,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            margin: const EdgeInsets.all(16),
          ),
        );
      }

      await Future.delayed(const Duration(milliseconds: 500));

      setState(() {
        _nameCtrl.clear();
        _amountCtrl.clear();
        _referenceCtrl.clear();
        _isAddMode = false;
        _creditListFuture = CreditViewApiService.fetchCreditNoteList();
      });
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(response['message'] ?? 'Failed to save credit note'),
            backgroundColor: AppColors.voucherDanger,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
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
            _isAddMode ? 'Add Credit Note' : 'Credit Note',
            style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w700),
          ),
        ),
        body: Column(
          children: [
            Expanded(
              child: _isAddMode
                  ? SingleChildScrollView(
                      padding: EdgeInsets.fromLTRB(isMobile ? 16 : 26, 24, isMobile ? 16 : 26, 32),
                      child: Center(
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 1180),
                          child: Container(
                            padding: EdgeInsets.all(isMobile ? 16 : 22),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: const Color(0xFFE5ECF5)),
                              boxShadow: [
                                BoxShadow(color: Colors.black.withValues(alpha: 0.06), blurRadius: 18, offset: const Offset(0, 8)),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      width: 42, height: 42,
                                      decoration: BoxDecoration(color: AppColors.brand.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(12)),
                                      child: const Icon(Icons.note_add_rounded, color: AppColors.brand, size: 22),
                                    ),
                                    const SizedBox(width: 12),
                                    const Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text('Add Credit Note', style: TextStyle(color: AppColors.text1, fontSize: 18, fontWeight: FontWeight.w800)),
                                          SizedBox(height: 2),
                                          Text('Record customer credit details', style: TextStyle(color: AppColors.text2, fontSize: 12, fontWeight: FontWeight.w500)),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 24),
                                _CreditFormGrid(isMobile: isMobile, dateCtrl: _dateCtrl, nameCtrl: _nameCtrl, amountCtrl: _amountCtrl, referenceCtrl: _referenceCtrl, onSave: _save),
                              ],
                            ),
                          ),
                        ),
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
                              hintText: 'Search records...',
                              filled: true,
                              fillColor: Colors.white,
                              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFE5ECF5))),
                              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFE5ECF5))),
                              focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.brand, width: 1.5)),
                            ),
                          ),
                        ),
                        Expanded(
                          child: FutureBuilder<List<CreditNoteItemModel>>(
                            future: _creditListFuture,
                            builder: (context, snapshot) {
                              if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
                              if (snapshot.hasError) return Center(child: Text('Error: ${snapshot.error}'));
                              if (!snapshot.hasData || snapshot.data!.isEmpty) return const Center(child: Text('No records found.'));

                              final data = snapshot.data!.where((item) {
                                final q = _searchQuery.toLowerCase();
                                return (item.assetName?.toLowerCase().contains(q) ?? false) || (item.id?.toString().contains(q) ?? false);
                              }).toList();

                              return ListView.separated(
                                padding: EdgeInsets.all(isMobile ? 16 : 24),
                                itemCount: data.length,
                                separatorBuilder: (_, _) => const SizedBox(height: 14),
                                itemBuilder: (context, index) => _CreditNoteCard(item: data[index]),
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

class _CreditFormGrid extends StatelessWidget {
  final bool isMobile;
  final TextEditingController dateCtrl, nameCtrl, amountCtrl, referenceCtrl;
  final VoidCallback onSave;
  const _CreditFormGrid({required this.isMobile, required this.dateCtrl, required this.nameCtrl, required this.amountCtrl, required this.referenceCtrl, required this.onSave});

  @override
  Widget build(BuildContext context) {
    final fields = [
      _CreditField(label: 'Date', child: _CreditTextField(controller: dateCtrl, hint: 'DD-MM-YYYY', readOnly: true, icon: Icons.calendar_today_rounded)),
      _CreditField(label: 'Amount', child: _CreditTextField(controller: amountCtrl, hint: 'Amount', icon: Icons.currency_rupee_rounded, keyboardType: const TextInputType.numberWithOptions(decimal: true), inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}'))])),
      _CreditField(label: 'Name', child: _CreditTextField(controller: nameCtrl, hint: 'Customer Name', icon: Icons.person_outline_rounded)),
      _CreditField(label: 'Reference', child: _CreditTextField(controller: referenceCtrl, hint: 'Reference', icon: Icons.tag_rounded)),
    ];

    if (isMobile) {
      return Column(children: [...fields.map((f) => Padding(padding: const EdgeInsets.only(bottom: 16), child: f)), const SizedBox(height: 8), _CreditSaveButton(onPressed: onSave)]);
    }

    return Column(children: [
      Row(children: [Expanded(child: fields[0]), const SizedBox(width: 24), Expanded(child: fields[1])]),
      const SizedBox(height: 18),
      Row(children: [Expanded(child: fields[2]), const SizedBox(width: 24), Expanded(child: fields[3])]),
      const SizedBox(height: 26),
      Row(children: [const Spacer(), Expanded(child: _CreditSaveButton(onPressed: onSave))]),
    ]);
  }
}

class _CreditField extends StatelessWidget {
  final String label;
  final Widget child;
  const _CreditField({required this.label, required this.child});
  @override
  Widget build(BuildContext context) => LayoutBuilder(builder: (context, constraints) {
    final inline = constraints.maxWidth >= 440;
    if (!inline) return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [_CreditLabel(label), const SizedBox(height: 8), child]);
    return Row(children: [SizedBox(width: 150, child: _CreditLabel(label)), Expanded(child: child)]);
  });
}

class _CreditLabel extends StatelessWidget {
  final String text;
  const _CreditLabel(this.text);
  @override
  Widget build(BuildContext context) => Text(text, style: const TextStyle(color: Color(0xFF001245), fontSize: 15, fontWeight: FontWeight.w600));
}

class _CreditTextField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final bool readOnly;
  final IconData icon;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  const _CreditTextField({required this.controller, required this.hint, required this.icon, this.readOnly = false, this.keyboardType, this.inputFormatters});
  @override
  Widget build(BuildContext context) => SizedBox(height: 48, child: TextField(controller: controller, readOnly: readOnly, keyboardType: keyboardType, inputFormatters: inputFormatters, style: const TextStyle(color: Color(0xFF2F406B), fontSize: 15, fontWeight: FontWeight.w500), decoration: InputDecoration(hintText: hint, hintStyle: const TextStyle(color: Color(0xFF6B7C9D)), prefixIcon: Icon(icon, color: AppColors.text2, size: 19), filled: true, fillColor: readOnly ? const Color(0xFFF5F8FC) : Colors.white, isDense: true, contentPadding: const EdgeInsets.symmetric(horizontal: 14), border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFD7E1ED))), enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFD7E1ED))), focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.brand, width: 1.5)))));
}

class _CreditSaveButton extends StatelessWidget {
  final VoidCallback onPressed;
  const _CreditSaveButton({required this.onPressed});
  @override
  Widget build(BuildContext context) => SizedBox(width: double.infinity, height: 48, child: ElevatedButton(onPressed: onPressed, style: ElevatedButton.styleFrom(backgroundColor: AppColors.brand, foregroundColor: Colors.white, elevation: 3, shadowColor: AppColors.brand.withValues(alpha: 0.25), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))), child: const Text('SAVE', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800))));
}

class _CreditNoteCard extends StatelessWidget {
  final CreditNoteItemModel item;
  const _CreditNoteCard({required this.item});
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14), border: Border.all(color: const Color(0xFFE5ECF5)), boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.08), blurRadius: 16, offset: const Offset(0, 6))]),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Container(width: 42, height: 42, decoration: BoxDecoration(color: AppColors.brand.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(12)), child: const Icon(Icons.receipt_long_rounded, color: AppColors.brand, size: 22)),
          const SizedBox(width: 12),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(item.assetName?.isNotEmpty == true ? item.assetName! : 'N/A', style: const TextStyle(color: AppColors.text1, fontSize: 16, fontWeight: FontWeight.w800)), const SizedBox(height: 3), Text('Ref: #${item.id ?? '-'}', style: const TextStyle(color: AppColors.text2, fontSize: 12, fontWeight: FontWeight.w600))])),
          Text('₹ ${item.purchaseValue ?? '0.00'}', style: const TextStyle(color: AppColors.brand, fontSize: 15, fontWeight: FontWeight.w800)),
        ]),
        const SizedBox(height: 14),
        const Divider(height: 1, color: Color(0xFFE5ECF5)),
        const SizedBox(height: 12),
        Row(children: [const Icon(Icons.calendar_today_rounded, size: 15, color: AppColors.text2), const SizedBox(width: 8), Text(item.purchaseDate ?? 'N/A', style: const TextStyle(color: AppColors.text2, fontSize: 13, fontWeight: FontWeight.w600))]),
      ]),
    );
  }
}
