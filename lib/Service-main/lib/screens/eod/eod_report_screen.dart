import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:service_ticket/core/size_utils.dart';
import '../../Widgets/app_status_bar_wrapper.dart';
import '../../services/api_service.dart';
import '../../core/app_colors.dart';

class EodReportScreen extends StatefulWidget {
  const EodReportScreen({super.key});

  @override
  State<EodReportScreen> createState() => _EodReportScreenState();
}

class _EodReportScreenState extends State<EodReportScreen> {
  final TextEditingController _dateController = TextEditingController(
    text: DateFormat('MM /dd /yyyy').format(DateTime.now()),
  );
  final TextEditingController _ticketController = TextEditingController();
  final TextEditingController _completedTasksController =
      TextEditingController();
  final TextEditingController _workInProgressController =
      TextEditingController();
  final TextEditingController _blockersController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _dateController.dispose();
    _ticketController.dispose();
    _completedTasksController.dispose();
    _workInProgressController.dispose();
    _blockersController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.primary,
              onPrimary: Colors.white,
              onSurface: Colors.black,
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(foregroundColor: AppColors.primary),
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        _dateController.text = DateFormat('MM /dd /yyyy').format(picked);
      });
    }
  }

  Future<void> _submitData() async {
    final eodText = _completedTasksController.text.trim();
    final dateText = _dateController.text.trim();

    if (eodText.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter today\'s EOD report')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      // Parse MM /dd /yyyy to yyyy-MM-dd
      String apiDate = "";
      try {
        DateTime parsedDate = DateFormat('MM /dd /yyyy').parse(dateText);
        apiDate = DateFormat('yyyy-MM-dd').format(parsedDate);
      } catch (e) {
        apiDate = DateFormat('yyyy-MM-dd').format(DateTime.now());
      }

      final response = await ApiService.submitEodReport(
        date: apiDate,
        eodReport: eodText,
      );

      if (mounted) {
        setState(() => _isLoading = false);

        if (response != null && response['error'] == false) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                response['message'] ?? 'EOD Report saved successfully',
              ),
            ),
          );
          Navigator.pop(context);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(response['message'] ?? 'Failed to save EOD report'),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig.init(context);

    return Scaffold(
      backgroundColor: Colors.white,
      body: AppStatusBarWrapper(
        child: Column(
          children: [
            // Custom App Bar
            Container(
              padding: EdgeInsets.only(
                left: 8.w,
                right: 16.w,
                bottom: 12.h,
                top: 4.h,
              ),
              decoration: const BoxDecoration(color: AppColors.primary),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  IconButton(
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    icon: Icon(
                      Icons.arrow_back,
                      color: Colors.white,
                      size: 24.sp,
                    ),
                    onPressed: () => Navigator.pop(context),
                  ),
                  SizedBox(width: 12.w),
                  Text(
                    'EOD',
                    style: TextStyle(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),

            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 20.h),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Date and Ticket No Row
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: _buildInputField(
                            label: 'Date',
                            controller: _dateController,
                            readOnly: true,
                            onTap: () => _selectDate(context),
                            suffixIcon: Padding(
                              padding: EdgeInsets.only(right: 12.w),
                              child: Icon(
                                Icons.calendar_month_outlined,
                                color: Colors.red[400],
                                size: 24.sp,
                              ),
                            ),
                          ),
                        ),
                        SizedBox(width: 16.w),
                        // Expanded(
                        //   child: _buildInputField(
                        //     label: 'Ticket No',
                        //     controller: _ticketController,
                        //     hint: 'Enter Ticket No',
                        //   ),
                        // ),
                      ],
                    ),
                    SizedBox(height: 24.h),

                    // Completed Tasks
                    _buildInputField(
                      label: 'Today EOD',
                      controller: _completedTasksController,
                      hint: 'Enter Your Today completed task',
                      maxLines: 5,
                    ),
                    SizedBox(height: 24.h),

                    // Work in Progress
                    // _buildInputField(
                    //   label: 'Work in Progress',
                    //   controller: _workInProgressController,
                    //   hint: 'What are you currently working on? Write here..',
                    //   maxLines: 5,
                    // ),
                    // SizedBox(height: 24.h),

                    // // Blockers / Issues
                    // _buildInputField(
                    //   label: 'Blockers / Issues',
                    //   controller: _blockersController,
                    //   hint: 'Any challenges or delays? Write here',
                    //   maxLines: 5,
                    // ),
                    // SizedBox(height: 24.h),

                    // Attachments Section
                    // Text(
                    //   'Attachments',
                    //   style: TextStyle(
                    //     fontSize: 15.sp,
                    //     fontWeight: FontWeight.w600,
                    //     color: Colors.black87,
                    //   ),
                    // ),
                    // SizedBox(height: 10.h),
                    // GestureDetector(
                    //   onTap: () {
                    //     // Implement image picking
                    //   },
                    //   child: Container(
                    //     width: double.infinity,
                    //     padding: EdgeInsets.symmetric(vertical: 24.h),
                    //     decoration: BoxDecoration(
                    //       color: const Color(0xFFF3F5F7),
                    //       borderRadius: BorderRadius.circular(10.r),
                    //     ),
                    //     child: Column(
                    //       mainAxisAlignment: MainAxisAlignment.center,
                    //       children: [
                    //         Icon(
                    //           Icons.file_upload_outlined,
                    //           size: 32.sp,
                    //           color: Colors.grey[600],
                    //         ),
                    //         SizedBox(height: 10.h),
                    //         Text(
                    //           'Click to Image',
                    //           style: TextStyle(
                    //             fontSize: 13.sp,
                    //             fontWeight: FontWeight.w500,
                    //             color: Colors.black54,
                    //           ),
                    //         ),
                    //         SizedBox(height: 4.h),
                    //         Text(
                    //           'JPG, PNG or PDF (Max 5MB)',
                    //           style: TextStyle(
                    //             fontSize: 11.sp,
                    //             color: Colors.grey[500],
                    //           ),
                    //         ),
                    //       ],
                    //     ),
                    //   ),
                    // ),
                    // SizedBox(height: 32.h),

                    // Submit Button
                    SizedBox(
                      width: double.infinity,
                      height: 52.h,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _submitData,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8.r),
                          ),
                          elevation: 0,
                        ),
                        child: _isLoading
                            ? SizedBox(
                                height: 20.h,
                                width: 20.h,
                                child: const CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                            : Text(
                                'Submit',
                                style: TextStyle(
                                  fontSize: 16.sp,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                              ),
                      ),
                    ),
                    SizedBox(height: 20.h),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInputField({
    required String label,
    required TextEditingController controller,
    String? hint,
    int maxLines = 1,
    bool readOnly = false,
    Widget? suffixIcon,
    VoidCallback? onTap,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 15.sp,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        SizedBox(height: 8.h),
        Container(
          decoration: BoxDecoration(
            color: const Color(0xFFF3F5F7),
            borderRadius: BorderRadius.circular(10.r),
          ),
          child: TextField(
            controller: controller,
            maxLines: maxLines,
            readOnly: readOnly,
            onTap: onTap,
            style: TextStyle(fontSize: 14.sp, color: Colors.black87),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: TextStyle(fontSize: 13.sp, color: Colors.grey[500]),
              suffixIcon: suffixIcon,
              suffixIconConstraints: BoxConstraints(
                minWidth: 40.w,
                minHeight: 24.h,
              ),
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(
                horizontal: 14.w,
                vertical: maxLines > 1 ? 14.h : 0,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
