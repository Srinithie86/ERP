import 'package:flutter/material.dart';
import '../../../core/app_theme.dart';

const Color productionTeal = Color(0xFF26A69A);

class ProductionEntryPage extends StatefulWidget {
  const ProductionEntryPage({super.key});

  @override
  State<ProductionEntryPage> createState() => _ProductionEntryPageState();
}

class _ProductionEntryPageState extends State<ProductionEntryPage> {
  final _formKey = GlobalKey<FormState>();

  final _productionIdCtrl = TextEditingController();
  final _batchIdCtrl = TextEditingController();
  final _productCodeCtrl = TextEditingController();
  final _productNameCtrl = TextEditingController();
  final _quantityCtrl = TextEditingController();
  final _shiftCtrl = TextEditingController();
  final _operatorCtrl = TextEditingController();
  final _orderQtyCtrl = TextEditingController();
  final _producedQtyCtrl = TextEditingController();
  final _serviceEngineerCtrl = TextEditingController();
  final _moveToCtrl = TextEditingController();
  final _remarksCtrl = TextEditingController();

  DateTime _productionDate = DateTime.now();

  @override
  void dispose() {
    _productionIdCtrl.dispose();
    _batchIdCtrl.dispose();
    _productCodeCtrl.dispose();
    _productNameCtrl.dispose();
    _quantityCtrl.dispose();
    _shiftCtrl.dispose();
    _operatorCtrl.dispose();
    _orderQtyCtrl.dispose();
    _producedQtyCtrl.dispose();
    _serviceEngineerCtrl.dispose();
    _moveToCtrl.dispose();
    _remarksCtrl.dispose();
    super.dispose();
  }

  String _formatDate(DateTime dt) =>
      '${dt.day.toString().padLeft(2, '0')}-${dt.month.toString().padLeft(2, '0')}-${dt.year}';

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _productionDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: const ColorScheme.light(primary: productionTeal),
        ),
        child: child!,
      ),
    );
    if (picked != null) setState(() => _productionDate = picked);
  }

  @override
  Widget build(BuildContext context) {
    final sw = MediaQuery.of(context).size.width;
    final labelWidth = sw * 0.32;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding:
              EdgeInsets.symmetric(horizontal: sw * 0.04, vertical: sw * 0.04),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _FormRow(
                label: 'Production Date',
                labelWidth: labelWidth,
                sw: sw,
                child: GestureDetector(
                  onTap: _pickDate,
                  child: _FieldBox(
                    sw: sw,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          _formatDate(_productionDate),
                          style: TextStyle(
                            fontSize: sw * 0.035,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        Icon(Icons.calendar_today_outlined,
                            size: sw * 0.04, color: AppColors.textSecondary),
                      ],
                    ),
                  ),
                ),
              ),
              _FormRow(
                label: 'Production ID :',
                labelWidth: labelWidth,
                sw: sw,
                child: _InputField(
                  controller: _productionIdCtrl,
                  hint: 'Production ID',
                  sw: sw,
                ),
              ),
              _FormRow(
                label: 'Batch ID :',
                labelWidth: labelWidth,
                sw: sw,
                child: _InputField(
                  controller: _batchIdCtrl,
                  hint: 'Batch ID',
                  sw: sw,
                ),
              ),
              _FormRow(
                label: 'Product Code :',
                labelWidth: labelWidth,
                sw: sw,
                child: _InputField(
                  controller: _productCodeCtrl,
                  hint: 'Product Code',
                  sw: sw,
                ),
              ),
              _FormRow(
                label: 'Product Name :',
                labelWidth: labelWidth,
                sw: sw,
                child: _InputField(
                  controller: _productNameCtrl,
                  hint: 'Product Name',
                  sw: sw,
                ),
              ),
              _FormRow(
                label: 'Quantity :',
                labelWidth: labelWidth,
                sw: sw,
                child: _InputField(
                  controller: _quantityCtrl,
                  hint: 'Quantity',
                  sw: sw,
                  keyboardType: TextInputType.number,
                ),
              ),
              _FormRow(
                label: 'Order QTY :',
                labelWidth: labelWidth,
                sw: sw,
                child: _InputField(
                  controller: _orderQtyCtrl,
                  hint: 'Order QTY',
                  sw: sw,
                  keyboardType: TextInputType.number,
                ),
              ),
              _FormRow(
                label: 'Produced QTY :',
                labelWidth: labelWidth,
                sw: sw,
                child: _InputField(
                  controller: _producedQtyCtrl,
                  hint: 'Produced QTY',
                  sw: sw,
                  keyboardType: TextInputType.number,
                ),
              ),
              _FormRow(
                label: 'Service Engineer :',
                labelWidth: labelWidth,
                sw: sw,
                child: _InputField(
                  controller: _serviceEngineerCtrl,
                  hint: 'Service Engineer',
                  sw: sw,
                ),
              ),
              _FormRow(
                label: 'Move To :',
                labelWidth: labelWidth,
                sw: sw,
                child: _InputField(
                  controller: _moveToCtrl,
                  hint: 'Move To',
                  sw: sw,
                ),
              ),
              _FormRow(
                label: 'Remarks',
                labelWidth: labelWidth,
                sw: sw,
                child: _InputField(
                  controller: _remarksCtrl,
                  hint: 'Remarks',
                  sw: sw,
                  maxLines: 3,
                ),
              ),
              SizedBox(height: sw * 0.08),
              Row(children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      _formKey.currentState?.reset();
                      _productionIdCtrl.clear();
                      _batchIdCtrl.clear();
                      _productCodeCtrl.clear();
                      _productNameCtrl.clear();
                      _quantityCtrl.clear();
                      _shiftCtrl.clear();
                      _operatorCtrl.clear();
                      _orderQtyCtrl.clear();
                      _producedQtyCtrl.clear();
                      _serviceEngineerCtrl.clear();
                      _moveToCtrl.clear();
                      _remarksCtrl.clear();
                      setState(() => _productionDate = DateTime.now());
                    },
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.textSecondary,
                      side: const BorderSide(color: AppColors.border),
                      padding: EdgeInsets.symmetric(vertical: sw * 0.035),
                    ),
                    child:
                        Text('Reset', style: TextStyle(fontSize: sw * 0.035)),
                  ),
                ),
                SizedBox(width: sw * 0.03),
                Expanded(
                  flex: 2,
                  child: ElevatedButton(
                    onPressed: () {
                      if (_formKey.currentState?.validate() ?? false) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Production entry saved!'),
                            backgroundColor: productionTeal,
                          ),
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: productionTeal,
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(vertical: sw * 0.035),
                      elevation: 0,
                    ),
                    child: Text('Save Entry',
                        style: TextStyle(
                            fontSize: sw * 0.035, fontWeight: FontWeight.w700)),
                  ),
                ),
              ]),
              SizedBox(height: sw * 0.05),
            ],
          ),
        ),
      ),
    );
  }
}

class _FormRow extends StatelessWidget {
  final String label;
  final double labelWidth;
  final double sw;
  final Widget child;

  const _FormRow({
    required this.label,
    required this.labelWidth,
    required this.sw,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: sw * 0.03),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(
            width: labelWidth,
            child: Text(
              label,
              style: TextStyle(
                fontSize: sw * 0.034,
                fontWeight: FontWeight.w500,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          SizedBox(width: sw * 0.03),
          Expanded(child: child),
        ],
      ),
    );
  }
}

class _InputField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final double sw;
  final TextInputType keyboardType;
  final int maxLines;

  const _InputField({
    required this.controller,
    required this.hint,
    required this.sw,
    this.keyboardType = TextInputType.text,
    this.maxLines = 1,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      style: TextStyle(
        fontSize: sw * 0.034,
        color: AppColors.textPrimary,
      ),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(
          fontSize: sw * 0.034,
          color: const Color(0xFF9CA3AF),
        ),
        contentPadding:
            EdgeInsets.symmetric(horizontal: sw * 0.035, vertical: sw * 0.03),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(sw * 0.02),
          borderSide: const BorderSide(color: Color(0xFFD1D5DB), width: 1),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(sw * 0.02),
          borderSide: const BorderSide(color: Color(0xFFD1D5DB), width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(sw * 0.02),
          borderSide: const BorderSide(color: productionTeal, width: 1.5),
        ),
      ),
    );
  }
}

class _FieldBox extends StatelessWidget {
  final double sw;
  final Widget child;

  const _FieldBox({required this.sw, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding:
          EdgeInsets.symmetric(horizontal: sw * 0.035, vertical: sw * 0.03),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(sw * 0.02),
        border: Border.all(color: const Color(0xFFD1D5DB), width: 1),
      ),
      child: child,
    );
  }
}
