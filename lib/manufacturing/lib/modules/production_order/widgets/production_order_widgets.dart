import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/app_theme.dart';
import '../production_order_model.dart';

const Color joTeal = Color(0xFF26A69A);
const Color joTealLight = Color(0xFFE0F2F1);
const Color joTealDark = Color(0xFF00695C);
const Color joAmber = Color(0xFFF57F17);
const Color joAmberLight = Color(0xFFFFF8E1);

PreferredSizeWidget buildTealAppBar({
  required String title,
  String? subtitle,
  List<Widget>? actions,
  bool showBack = true,
  BuildContext? context,
  PreferredSizeWidget? bottom,
}) {
  return AppBar(
    backgroundColor: joTeal,
    elevation: 0,
    systemOverlayStyle: const SystemUiOverlayStyle(
      statusBarColor: joTeal,
      statusBarIconBrightness: Brightness.light,
    ),
    leading: showBack && context != null
        ? IconButton(
            icon: Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          )
        : null,
    automaticallyImplyLeading: false,
    title: subtitle != null
        ? Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title,
                  style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 15.sp)),
              Text(subtitle,
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 11.sp,
                      fontWeight: FontWeight.w700)),
            ],
          )
        : Text(title,
            style: TextStyle(
                color: Colors.white, fontWeight: FontWeight.w700)),
    actions: actions,
    bottom: bottom,
  );
}

class JOStatusBadge extends StatelessWidget {
  final String status;
  final bool light;
  const JOStatusBadge({super.key, required this.status, this.light = false});

  @override
  Widget build(BuildContext context) {
    final isActive = status == 'active';
    final bgColor = light
        ? Colors.white24
        : (isActive ? Colors.green.shade100 : Colors.orange.shade100);
    final textColor = light
        ? Colors.white
        : (isActive ? Colors.green.shade700 : Colors.orange.shade700);

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20.r),
      ),
      child: Text(
        status.toUpperCase(),
        style: TextStyle(
          fontSize: 10.sp,
          fontWeight: FontWeight.w700,
          color: textColor,
        ),
      ),
    );
  }
}

class JOSummaryChip extends StatelessWidget {
  final String label, value;
  const JOSummaryChip({super.key, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        children: [
          Text(value,
              style: TextStyle(
                  fontSize: 14.sp, fontWeight: FontWeight.w700, color: joTeal)),
          Text(label,
              style: TextStyle(fontSize: 10.sp, color: Colors.grey.shade600)),
        ],
      ),
    );
  }
}

class JORoundedCard extends StatelessWidget {
  final Widget child;
  const JORoundedCard({super.key, required this.child});

  @override
  Widget build(BuildContext context) => Container(
        padding: EdgeInsets.all(14.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10.r),
          border: Border.all(color: Colors.grey.shade200),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withOpacity(0.03),
                blurRadius: 6,
                offset: const Offset(0, 2))
          ],
        ),
        child: child,
      );
}


class JOFormRow extends StatelessWidget {
  final List<Widget> children;
  const JOFormRow({super.key, required this.children});

  @override
  Widget build(BuildContext context) {
    final List<Widget> spaced = [];
    for (int i = 0; i < children.length; i++) {
      spaced.add(Expanded(child: children[i]));
      if (i < children.length - 1) spaced.add(SizedBox(width: 10.w));
    }
    return Row(
        crossAxisAlignment: CrossAxisAlignment.start, children: spaced);
  }
}

class JOReadOnlyField extends StatelessWidget {
  final String label, value;
  const JOReadOnlyField({super.key, required this.label, required this.value});

  @override
  Widget build(BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _InputFieldLabel(label),
          SizedBox(height: 4.h),
          Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(horizontal: 11.w, vertical: 11.h),
            decoration: BoxDecoration(
              color: const Color(0xFFF4F6F8),
              borderRadius: BorderRadius.circular(7.r),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Text(value,
                style: TextStyle(fontSize: 13.sp, color: Colors.black87),
                overflow: TextOverflow.ellipsis),
          ),
        ],
      );
}

class JOEditableField extends StatelessWidget {
  final String label;
  final Widget child;
  const JOEditableField({super.key, required this.label, required this.child});

  @override
  Widget build(BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _InputFieldLabel(label),
          SizedBox(height: 4.h),
          child,
        ],
      );
}

class _InputFieldLabel extends StatelessWidget {
  final String text;
  const _InputFieldLabel(this.text);

  @override
  Widget build(BuildContext context) => Text(text,
      style: TextStyle(
          fontSize: 10.sp,
          fontWeight: FontWeight.w600,
          color: Colors.grey,
          letterSpacing: 0.3));
}

class JOTextField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final TextInputType keyboardType;
  final bool readOnly;
  final EdgeInsets? contentPadding;
  const JOTextField({
    super.key,
    required this.controller,
    required this.hint,
    this.keyboardType = TextInputType.text,
    this.readOnly = false,
    this.contentPadding,
  });

  Widget build(BuildContext context) => TextField(
        controller: controller,
        keyboardType: keyboardType,
        readOnly: readOnly,
        style: TextStyle(fontSize: 13.sp),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(fontSize: 13.sp, color: Colors.grey),
          filled: true,
          fillColor: const Color(0xFFF4F6F8),
          contentPadding: contentPadding ??
              EdgeInsets.symmetric(horizontal: 11.w, vertical: 11.h),
          isDense: true,
          border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(7.r),
              borderSide: BorderSide(color: Colors.grey.shade300)),
          enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(7.r),
              borderSide: BorderSide(color: Colors.grey.shade300)),
          focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(7.r),
              borderSide: BorderSide(color: joTeal, width: 1.5.w)),
        ),
      );
}

class JODropdown extends StatelessWidget {
  final String hint;
  final String? value;
  final List<String> items;
  final void Function(String?) onChanged;
  final Color Function(String)? itemColor;

  const JODropdown({
    super.key,
    required this.hint,
    required this.value,
    required this.items,
    required this.onChanged,
    this.itemColor,
  });

  @override
  Widget build(BuildContext context) => Container(
        padding: EdgeInsets.symmetric(horizontal: 11.w),
        decoration: BoxDecoration(
          color: const Color(0xFFF4F6F8),
          borderRadius: BorderRadius.circular(7.r),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<String>(
            value: value,
            isExpanded: true,
            hint: Text(hint,
                style: TextStyle(fontSize: 13.sp, color: Colors.grey)),
            icon: Icon(Icons.keyboard_arrow_down,
                color: Colors.grey, size: 18.sp),
            items: items
                .map((item) => DropdownMenuItem(
                      value: item,
                      child: Text(item,
                          style: TextStyle(
                              fontSize: 13.sp,
                              color: itemColor != null
                                  ? itemColor!(item)
                                  : Colors.black87,
                              fontWeight: itemColor != null
                                  ? FontWeight.w600
                                  : FontWeight.normal)),
                    ))
                .toList(),
            onChanged: onChanged,
          ),
        ),
      );
}

class JOSectionHeader extends StatelessWidget {
  final String label;
  const JOSectionHeader({super.key, required this.label});

  @override
  Widget build(BuildContext context) => Row(children: [
        Container(
          width: 4.w,
          height: 16.h,
          decoration: BoxDecoration(
              color: joTeal, borderRadius: BorderRadius.circular(2.r)),
        ),
        SizedBox(width: 8.w),
        Text(label,
            style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w700,
                color: Colors.black87)),
      ]);
}

class JOPill extends StatelessWidget {
  final String text;
  const JOPill({super.key, required this.text});

  @override
  Widget build(BuildContext context) => Container(
        padding: EdgeInsets.symmetric(horizontal: 9.w, vertical: 3.h),
        decoration: BoxDecoration(
            color: joTealLight, borderRadius: BorderRadius.circular(20.r)),
        child: Text(text,
            style: TextStyle(
                fontSize: 11.sp, color: joTealDark, fontWeight: FontWeight.w600)),
      );
}

class JOAutocompleteField<T extends Object> extends StatefulWidget {
  final TextEditingController controller;
  final String hint;
  final String Function(T) displayStringForOption;
  final Future<List<T>> Function() fetchSuggestions;
  final bool Function(T, String) filterOption;
  final void Function(T) onSelected;
  final double? optionsWidth;

  const JOAutocompleteField({
    super.key,
    required this.controller,
    required this.hint,
    required this.displayStringForOption,
    required this.fetchSuggestions,
    required this.filterOption,
    required this.onSelected,
    this.optionsWidth,
  });

  @override
  State<JOAutocompleteField<T>> createState() => _JOAutocompleteFieldState<T>();
}

class _JOAutocompleteFieldState<T extends Object> extends State<JOAutocompleteField<T>> {
  final FocusNode _focusNode = FocusNode();

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RawAutocomplete<T>(
      textEditingController: widget.controller,
      focusNode: _focusNode,
      displayStringForOption: widget.displayStringForOption,
      optionsBuilder: (TextEditingValue textEditingValue) async {
        if (textEditingValue.text.isEmpty) {
          return const Iterable.empty();
        }
        final suggestions = await widget.fetchSuggestions();
        return suggestions
            .where((option) => widget.filterOption(option, textEditingValue.text));
      },
      onSelected: widget.onSelected,
      fieldViewBuilder: (context, fieldController, focusNode, onFieldSubmitted) {
        return TextField(
          controller: fieldController,
          focusNode: focusNode,
          style: TextStyle(fontSize: 13.sp),
          decoration: InputDecoration(
            hintText: widget.hint,
            hintStyle: TextStyle(fontSize: 13.sp, color: Colors.grey),
            filled: true,
            fillColor: const Color(0xFFF4F6F8),
            contentPadding:
                EdgeInsets.symmetric(horizontal: 11.w, vertical: 11.h),
            isDense: true,
            border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(7.r),
                borderSide: BorderSide(color: Colors.grey.shade300)),
            enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(7.r),
                borderSide: BorderSide(color: Colors.grey.shade300)),
            focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(7.r),
                borderSide: BorderSide(color: joTeal, width: 1.5.w)),
          ),
        );
      },
      optionsViewBuilder: (context, onSelected, options) {
        return Align(
          alignment: Alignment.topLeft,
          child: Material(
            elevation: 4.0,
            borderRadius: BorderRadius.circular(8.r),
            child: Container(
              width: widget.optionsWidth ?? MediaQuery.of(context).size.width * 0.4,
              constraints: const BoxConstraints(maxHeight: 200),
              child: ListView.builder(
                padding: EdgeInsets.zero,
                shrinkWrap: true,
                itemCount: options.length,
                itemBuilder: (BuildContext context, int index) {
                  final T option = options.elementAt(index);
                  return ListTile(
                    title: Text(widget.displayStringForOption(option),
                        style: TextStyle(fontSize: 13.sp)),
                    onTap: () => onSelected(option),
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
