import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/app_theme.dart';
import '../job_order_model.dart';

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
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          )
        : null,
    automaticallyImplyLeading: false,
    title: subtitle != null
        ? Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title,
                  style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 15)),
              Text(subtitle,
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.w700)),
            ],
          )
        : Text(title,
            style: const TextStyle(
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
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        status.toUpperCase(),
        style: TextStyle(
          fontSize: 10,
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
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        children: [
          Text(value,
              style: const TextStyle(
                  fontSize: 14, fontWeight: FontWeight.w700, color: joTeal)),
          Text(label,
              style: TextStyle(fontSize: 10, color: Colors.grey.shade600)),
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
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
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
      if (i < children.length - 1) spaced.add(const SizedBox(width: 10));
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
          const SizedBox(height: 4),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 11),
            decoration: BoxDecoration(
              color: const Color(0xFFF4F6F8),
              borderRadius: BorderRadius.circular(7),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Text(value,
                style: const TextStyle(fontSize: 13, color: Colors.black87),
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
          const SizedBox(height: 4),
          child,
        ],
      );
}

class _InputFieldLabel extends StatelessWidget {
  final String text;
  const _InputFieldLabel(this.text);

  @override
  Widget build(BuildContext context) => Text(text,
      style: const TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w600,
          color: Colors.grey,
          letterSpacing: 0.3));
}

class JOTextField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final TextInputType keyboardType;
  const JOTextField({
    super.key,
    required this.controller,
    required this.hint,
    this.keyboardType = TextInputType.text,
  });

  @override
  Widget build(BuildContext context) => TextField(
        controller: controller,
        keyboardType: keyboardType,
        style: const TextStyle(fontSize: 13),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(fontSize: 13, color: Colors.grey),
          filled: true,
          fillColor: const Color(0xFFF4F6F8),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 11, vertical: 11),
          isDense: true,
          border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(7),
              borderSide: BorderSide(color: Colors.grey.shade300)),
          enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(7),
              borderSide: BorderSide(color: Colors.grey.shade300)),
          focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(7),
              borderSide: const BorderSide(color: joTeal, width: 1.5)),
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
        padding: const EdgeInsets.symmetric(horizontal: 11),
        decoration: BoxDecoration(
          color: const Color(0xFFF4F6F8),
          borderRadius: BorderRadius.circular(7),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<String>(
            value: value,
            isExpanded: true,
            hint: Text(hint,
                style: const TextStyle(fontSize: 13, color: Colors.grey)),
            icon: const Icon(Icons.keyboard_arrow_down,
                color: Colors.grey, size: 18),
            items: items
                .map((item) => DropdownMenuItem(
                      value: item,
                      child: Text(item,
                          style: TextStyle(
                              fontSize: 13,
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
          width: 4,
          height: 16,
          decoration: BoxDecoration(
              color: joTeal, borderRadius: BorderRadius.circular(2)),
        ),
        const SizedBox(width: 8),
        Text(label,
            style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: Colors.black87)),
      ]);
}

class JOPill extends StatelessWidget {
  final String text;
  const JOPill({super.key, required this.text});

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
        decoration: BoxDecoration(
            color: joTealLight, borderRadius: BorderRadius.circular(20)),
        child: Text(text,
            style: const TextStyle(
                fontSize: 11, color: joTealDark, fontWeight: FontWeight.w600)),
      );
}

class JOAutocompleteField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final Future<List<StaffMember>> Function() fetchSuggestions;
  final void Function(StaffMember) onSelected;

  const JOAutocompleteField({
    super.key,
    required this.controller,
    required this.hint,
    required this.fetchSuggestions,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Autocomplete<StaffMember>(
      displayStringForOption: (StaffMember option) => option.name,
      optionsBuilder: (TextEditingValue textEditingValue) async {
        if (textEditingValue.text.isEmpty) {
          return const Iterable<StaffMember>.empty();
        }
        final suggestions = await fetchSuggestions();
        return suggestions.where((StaffMember option) {
          return option.name
              .toLowerCase()
              .contains(textEditingValue.text.toLowerCase());
        });
      },
      onSelected: onSelected,
      fieldViewBuilder: (context, fieldController, focusNode, onFieldSubmitted) {
        // Sync the passed controller with the autocomplete's internal controller
        fieldController.text = controller.text;
        fieldController.addListener(() {
          controller.text = fieldController.text;
        });

        return TextField(
          controller: fieldController,
          focusNode: focusNode,
          style: const TextStyle(fontSize: 13),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(fontSize: 13, color: Colors.grey),
            filled: true,
            fillColor: const Color(0xFFF4F6F8),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 11, vertical: 11),
            isDense: true,
            border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(7),
                borderSide: BorderSide(color: Colors.grey.shade300)),
            enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(7),
                borderSide: BorderSide(color: Colors.grey.shade300)),
            focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(7),
                borderSide: const BorderSide(color: joTeal, width: 1.5)),
          ),
        );
      },
      optionsViewBuilder: (context, onSelected, options) {
        return Align(
          alignment: Alignment.topLeft,
          child: Material(
            elevation: 4.0,
            borderRadius: BorderRadius.circular(8),
            child: Container(
              width: MediaQuery.of(context).size.width * 0.4, // Adjust width
              constraints: const BoxConstraints(maxHeight: 200),
              child: ListView.builder(
                padding: EdgeInsets.zero,
                shrinkWrap: true,
                itemCount: options.length,
                itemBuilder: (BuildContext context, int index) {
                  final StaffMember option = options.elementAt(index);
                  return ListTile(
                    title: Text(option.name,
                        style: const TextStyle(fontSize: 13)),
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
