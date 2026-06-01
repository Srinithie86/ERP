import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:service_ticket/core/size_utils.dart';
import 'package:image_picker/image_picker.dart';

import '../../../Widgets/app_status_bar_wrapper.dart';
import '../../../core/app_colors.dart';
import '../../../Widgets/workflow_stepper.dart';

class CheckInScaffold extends StatelessWidget {
  const CheckInScaffold({
    super.key,
    required this.title,
    required this.child,
    this.actionLabel,
    this.onAction,
    this.showBackButton = true,
    this.actionEnabled = true,
  });

  final String title;
  final Widget child;
  final String? actionLabel;
  final VoidCallback? onAction;
  final bool showBackButton;
  final bool actionEnabled;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: AppStatusBarWrapper(
        child: SafeArea(
          top: false,
          child: Column(
            children: [
              Padding(
                padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 10.h),
                child: Row(
                  children: [
                    if (showBackButton)
                      InkWell(
                        onTap: () => Navigator.of(context).maybePop(),
                        borderRadius: BorderRadius.circular(20.r),
                        child: Padding(
                          padding: EdgeInsets.all(4.r),
                          child: Icon(
                            Icons.arrow_back_rounded,
                            size: 24.sp,
                            color: const Color(0xFF2644A6),
                          ),
                        ),
                      ),
                    SizedBox(width: showBackButton ? 10.w : 0),
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsets.fromLTRB(16.w, 4.h, 16.w, 18.h),
                  child: child,
                ),
              ),
              if (actionLabel != null && onAction != null)
                Padding(
                  padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 16.h),
                  child: SizedBox(
                    width: double.infinity,
                    height: 48.h,
                    child: ElevatedButton(
                      onPressed: actionEnabled ? onAction : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        disabledBackgroundColor: const Color(0xFFC8D0E6),
                        foregroundColor: Colors.white,
                        disabledForegroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(6.r),
                        ),
                        elevation: 0,
                      ),
                      child: Text(
                        actionLabel!,
                        style: TextStyle(
                          fontSize: 13.sp,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class WorkflowIndicator extends StatelessWidget {
  const WorkflowIndicator({super.key, required this.currentStep});

  final int currentStep;

  @override
  Widget build(BuildContext context) {
    return WorkflowStepper(currentStep: currentStep);
  }
}

class GradientTicketSummary extends StatelessWidget {
  const GradientTicketSummary({
    super.key,
    required this.ticketId,
    required this.customerName,
    required this.issue,
    required this.startTime,
    required this.endTime,
    required this.duration,
  });

  final String ticketId;
  final String customerName;
  final String issue;
  final String startTime;
  final String endTime;
  final String duration;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(14.r),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14.r),
        gradient: const LinearGradient(
          colors: [Color(0xFF4D71F2), Color(0xFF2541AA)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Work Summary',
            style: TextStyle(
              fontSize: 11.sp,
              color: Colors.white.withOpacity(0.92),
            ),
          ),
          SizedBox(height: 6.h),
          Text(
            '$ticketId,$customerName',
            style: TextStyle(
              fontSize: 15.sp,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
          SizedBox(height: 4.h),
          Text(
            issue,
            style: TextStyle(
              fontSize: 11.sp,
              color: Colors.white.withOpacity(0.88),
            ),
          ),
          SizedBox(height: 12.h),
          Row(
            children: [
              Expanded(
                child: _MiniInfoCard(title: 'Start Time', value: startTime),
              ),
              SizedBox(width: 8.w),
              Expanded(
                child: _MiniInfoCard(title: 'End Time', value: endTime),
              ),
              SizedBox(width: 8.w),
              Expanded(
                child: _MiniInfoCard(title: 'Duration', value: duration),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class UploadBox extends StatelessWidget {
  const UploadBox({
    super.key,
    required this.caption,
    this.fileName,
    this.onTap,
    this.imagePath,
    this.file,
    this.imageBytes,
    this.isInvalid = false,
    this.isSignature = false,
  });

  final String caption;
  final String? fileName;
  final VoidCallback? onTap;
  final String? imagePath;
  final File? file;
  final Uint8List? imageBytes;
  final bool isInvalid;
  final bool isSignature;

  static Future<File?> pickImage(BuildContext context) async {
    final picker = ImagePicker();
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt_rounded),
              title: const Text('Camera'),
              onTap: () => Navigator.pop(context, ImageSource.camera),
            ),
            ListTile(
              leading: const Icon(Icons.photo_library_rounded),
              title: const Text('Gallery'),
              onTap: () => Navigator.pop(context, ImageSource.gallery),
            ),
          ],
        ),
      ),
    );

    if (source != null) {
      final pickedFile = await picker.pickImage(
        source: source,
        maxWidth: 512,
        maxHeight: 512,
        imageQuality: 25,
      );
      if (pickedFile != null) {
        return File(pickedFile.path);
      }
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final hasImage =
        imageBytes != null ||
        file != null ||
        (imagePath != null && imagePath!.isNotEmpty);
    final isAsset = imagePath != null && imagePath!.startsWith('assets/');
    ImageProvider? backgroundImage;
    if (imageBytes != null) {
      backgroundImage = MemoryImage(imageBytes!);
    } else if (file != null) {
      backgroundImage = FileImage(file!);
    } else if (isAsset) {
      backgroundImage = AssetImage(imagePath!);
    } else if (imagePath != null && imagePath!.isNotEmpty) {
      backgroundImage = FileImage(File(imagePath!));
    }

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10.r),
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(vertical: 20.h, horizontal: 12.w),
        decoration: BoxDecoration(
          color: const Color(0xFFF1F4F9),
          borderRadius: BorderRadius.circular(10.r),
          border: Border.all(
            color: isInvalid ? const Color(0xFFD92D20) : Colors.transparent,
          ),
          image: hasImage
              ? DecorationImage(
                  image: backgroundImage!,
                  fit: BoxFit.cover,
                  colorFilter: ColorFilter.mode(
                    Colors.black.withOpacity(0.1),
                    BlendMode.darken,
                  ),
                )
              : null,
        ),
        child: Column(
          children: [
            Icon(
              hasImage
                  ? Icons.check_circle_outline_rounded
                  : (isSignature ? Icons.draw_rounded : Icons.file_upload_outlined),
              color: hasImage
                  ? const Color(0xFF3B9541)
                  : const Color(0xFF7A879F),
              size: 22.sp,
            ),
            SizedBox(height: 8.h),
            Text(
              hasImage
                  ? 'Image Selected'
                  : (fileName?.isNotEmpty == true
                        ? fileName!
                        : (isSignature ? 'Click to Sign' : 'Click to Image')),
              style: TextStyle(
                fontSize: 11.sp,
                color: hasImage
                    ? const Color(0xFF3B9541)
                    : const Color(0xFF667085),
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 4.h),
            Text(
              caption,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 8.5.sp,
                color: hasImage
                    ? Colors.white.withOpacity(0.8)
                    : const Color(0xFF98A2B3),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class SectionCard extends StatelessWidget {
  const SectionCard({super.key, required this.child, this.padding});

  final Widget child;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: padding ?? EdgeInsets.all(14.r),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F5F5),
        borderRadius: BorderRadius.circular(14.r),
      ),
      child: child,
    );
  }
}

class LabelValueRow extends StatelessWidget {
  const LabelValueRow({
    super.key,
    required this.label,
    required this.value,
    this.valueColor,
  });

  final String label;
  final String value;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 13.sp,
                color: const Color(0xFF445B87),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: TextStyle(
                fontSize: 13.sp,
                color: valueColor ?? Colors.black87,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class SummaryTable extends StatelessWidget {
  const SummaryTable({
    super.key,
    required this.rows,
    required this.serviceCharge,
    this.nextVisitDate = '',
  });

  final List<Map<String, String>> rows;
  final String serviceCharge;
  final String nextVisitDate;

  @override
  Widget build(BuildContext context) {
    return SectionCard(
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(14.r, 14.r, 14.r, 10.r),
            child: Text(
              'Work Summary',
              style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w700),
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.h),
            decoration: const BoxDecoration(
              border: Border(
                top: BorderSide(color: Color(0xFFD5D5D5)),
                bottom: BorderSide(color: Color(0xFFD5D5D5)),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  flex: 5,
                  child: Text(
                    'Spare Name',
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: const Color(0xFF2644A6),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                Container(
                  width: 1,
                  height: 14.h,
                  color: const Color(0xFFD5D5D5),
                ),
                Expanded(
                  flex: 2,
                  child: Text(
                    'Quantity',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: const Color(0xFF2644A6),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                Container(
                  width: 1,
                  height: 14.h,
                  color: const Color(0xFFD5D5D5),
                ),
                Expanded(
                  flex: 3,
                  child: Text(
                    'Part Code',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: const Color(0xFF2644A6),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
          ...rows.map(
            (row) => Container(
              decoration: const BoxDecoration(
                border: Border(bottom: BorderSide(color: Color(0xFFD5D5D5))),
              ),
              padding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 14.w),
              child: Row(
                children: [
                  Expanded(
                    flex: 5,
                    child: Text(
                      row['name'] ?? '',
                      style: TextStyle(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  Container(
                    width: 1,
                    height: 14.h,
                    color: const Color(0xFFD5D5D5),
                  ),
                  Expanded(
                    flex: 2,
                    child: Text(
                      row['quantity'] ?? '',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  Container(
                    width: 1,
                    height: 14.h,
                    color: const Color(0xFFD5D5D5),
                  ),
                  Expanded(
                    flex: 3,
                    child: Text(
                      row['partCode'] ?? '-',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
            decoration: BoxDecoration(
              color: const Color(0xFF2644A6),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(14.r),
                bottomRight: Radius.circular(14.r),
              ),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Text(
                      'Service Charge',
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      serviceCharge,
                      style: TextStyle(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
                if (nextVisitDate.isNotEmpty) ...[
                  SizedBox(height: 8.h),
                  Row(
                    children: [
                      Text(
                        'Next Visit Date',
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: Colors.white,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        nextVisitDate,
                        style: TextStyle(
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MiniInfoCard extends StatelessWidget {
  const _MiniInfoCard({required this.title, required this.value});

  final String title;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 10.h),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.16),
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 9.sp,
              color: Colors.white.withOpacity(0.84),
            ),
          ),
          SizedBox(height: 6.h),
          Text(
            value,
            style: TextStyle(
              fontSize: 10.sp,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}
