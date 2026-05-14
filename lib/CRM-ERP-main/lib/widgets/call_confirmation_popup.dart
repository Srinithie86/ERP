import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CallConfirmationPopup extends StatefulWidget {
  final Map<String, dynamic> lead;
  final void Function(String) onConfirm; // Changed to accept the selected phone
  final VoidCallback onCancel;

  const CallConfirmationPopup({
    super.key,
    required this.lead,
    required this.onConfirm,
    required this.onCancel,
  });

  @override
  State<CallConfirmationPopup> createState() => _CallConfirmationPopupState();
}

class _CallConfirmationPopupState extends State<CallConfirmationPopup> {
  late List<String> _phoneNumbers;
  late String _selectedPhone;

  @override
  void initState() {
    super.initState();
    // Identify all available unique phone numbers
    final Set<String> phones = {};
    void addIfValid(dynamic val) {
      if (val != null) {
        final s = val.toString().trim();
        if (s.isNotEmpty && s != 'null') phones.add(s);
      }
    }

    addIfValid(widget.lead['mobile_1']);
    addIfValid(widget.lead['mobile_2']);
    addIfValid(widget.lead['moble_2']); // Handle misspelled key from API
    addIfValid(widget.lead['mobile']);
    addIfValid(widget.lead['phone']);
    addIfValid(widget.lead['mobile_no']);
    addIfValid(widget.lead['cus_mobile']);
    addIfValid(widget.lead['contact_no']);

    _phoneNumbers = phones.toList();
    _selectedPhone = _phoneNumbers.isNotEmpty ? _phoneNumbers.first : '';
  }

  @override
  Widget build(BuildContext context) {
    final name = (widget.lead['le_name'] ?? widget.lead['cus_name'])?.toString() ?? 'Unknown';
    final status = (widget.lead['lead_status'] ?? widget.lead['status'] ?? 'New Lead').toString();

    return Container(
      padding: EdgeInsets.fromLTRB(24.w, 12.h, 24.w, 40.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(32.r)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle
          Container(
            width: 60.w,
            height: 4.h,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(2.r),
            ),
          ),
          SizedBox(height: 24.h),
          Text(
            'Confirm Call',
            style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 16.h),
          const Divider(thickness: 1, color: Color(0xFFEEEEEE)),
          SizedBox(height: 24.h),
          // Profile Row
          Row(
            children: [
              Container(
                width: 64.w,
                height: 64.w,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.grey.shade400, width: 2.w),
                ),
                child: Icon(Icons.person_outline, size: 36.r, color: Colors.grey),
              ),
              SizedBox(width: 20.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: TextStyle(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    SizedBox(height: 8.h),
                    Row(
                      children: [
                        Text('Status: ',
                            style: TextStyle(
                                color: Colors.grey.shade600, fontSize: 13.sp)),
                        SizedBox(width: 4.w),
                        Container(
                          padding: EdgeInsets.symmetric(
                              horizontal: 12.w, vertical: 4.h),
                          decoration: BoxDecoration(
                            color: const Color(0xFF4A80C9),
                            borderRadius: BorderRadius.circular(6.r),
                          ),
                          child: Text(
                            status,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 12.sp,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 24.h),
          const Divider(thickness: 1, color: Color(0xFFEEEEEE)),
          SizedBox(height: 20.h),
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'Select number to call:',
              style: TextStyle(fontSize: 15.sp, color: Colors.black, fontWeight: FontWeight.w600),
            ),
          ),
          SizedBox(height: 16.h),
          // Number Selection List
          if (_phoneNumbers.isEmpty)
             Text("No phone numbers available", style: TextStyle(color: Colors.red, fontSize: 14.sp))
          else
            Column(
              children: _phoneNumbers.map((p) {
                bool isSelected = _selectedPhone == p;
                return GestureDetector(
                  onTap: () => setState(() => _selectedPhone = p),
                  child: Container(
                    margin: EdgeInsets.only(bottom: 12.h),
                    padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
                    decoration: BoxDecoration(
                      color: isSelected ? const Color(0xFFE8F5E9) : Colors.grey.shade50,
                      borderRadius: BorderRadius.circular(12.r),
                      border: Border.all(
                        color: isSelected ? const Color(0xFF4CAF50) : Colors.grey.shade200,
                        width: 1.5,
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          isSelected ? Icons.radio_button_checked : Icons.radio_button_off,
                          color: isSelected ? const Color(0xFF4CAF50) : Colors.grey,
                          size: 20.r,
                        ),
                        SizedBox(width: 12.w),
                        Text(
                          p,
                          style: TextStyle(
                            fontSize: 16.sp,
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                            color: isSelected ? const Color(0xFF2E7D32) : Colors.black87,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          SizedBox(height: 24.h),
          // Buttons
          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: widget.onCancel,
                  child: Container(
                    height: 52.h,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade300),
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    child: Center(
                      child: Text(
                        'Cancel',
                        style: TextStyle(
                            fontSize: 16.sp, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(width: 16.w),
              Expanded(
                child: GestureDetector(
                  onTap: _phoneNumbers.isEmpty ? null : () => widget.onConfirm(_selectedPhone),
                  child: Container(
                    height: 52.h,
                    decoration: BoxDecoration(
                      color: _phoneNumbers.isEmpty ? Colors.grey : const Color(0xFF4CAF50),
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    child: Center(
                      child: Text(
                        'Call Now',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
