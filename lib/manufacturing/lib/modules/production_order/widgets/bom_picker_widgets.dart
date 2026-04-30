import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter/material.dart';
import '../production_order_model.dart';
import 'production_order_widgets.dart';

Future<BomData?> showBomPicker(BuildContext context) async {
  return showModalBottomSheet<BomData>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => const _BomPickerSheet(),
  );
}

class _BomPickerSheet extends StatefulWidget {
  const _BomPickerSheet();

  @override
  State<_BomPickerSheet> createState() => _BomPickerSheetState();
}

class _BomPickerSheetState extends State<_BomPickerSheet> {
  String _search = '';

  List<BomData> get _filtered => kBomRegistry
      .where((b) =>
          b.bomLabel.toLowerCase().contains(_search.toLowerCase()) ||
          b.items.any((i) =>
              i.itemName.toLowerCase().contains(_search.toLowerCase()) ||
              i.itemCode.toLowerCase().contains(_search.toLowerCase())))
      .toList();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.75,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      child: Column(
        children: [
          Container(
            margin: EdgeInsets.only(top: 10.h),
            width: 40.w,
            height: 4.h,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(2.r),
            ),
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(16, 14, 16, 0),
            child: Row(
              children: [
                Icon(Icons.list_alt_outlined, color: joTeal, size: 20.sp),
                SizedBox(width: 8.w),
                Text(
                  'Select BOM',
                  style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w800,
                      color: Colors.black87),
                ),
                const Spacer(),
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    padding: EdgeInsets.all(6.w),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.close,
                        size: 16.sp, color: Colors.grey),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: TextField(
              onChanged: (v) => setState(() => _search = v),
              style: TextStyle(fontSize: 13.sp),
              decoration: InputDecoration(
                hintText: 'Search BOM or item...',
                hintStyle: TextStyle(fontSize: 13.sp, color: Colors.grey),
                prefixIcon:
                    Icon(Icons.search, size: 18.sp, color: Colors.grey),
                filled: true,
                fillColor: const Color(0xFFF4F6F8),
                contentPadding:
                    EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
                isDense: true,
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.r),
                    borderSide: BorderSide.none),
                enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.r),
                    borderSide: BorderSide.none),
                focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.r),
                    borderSide: BorderSide(color: joTeal, width: 1.5.w)),
              ),
            ),
          ),
          Divider(height: 1.h),
          Expanded(
            child: _filtered.isEmpty
                ? Center(
                    child: Text(
                      'No BOM found',
                      style:
                          TextStyle(color: Colors.grey.shade400, fontSize: 14.sp),
                    ),
                  )
                : ListView.separated(
                    padding: EdgeInsets.all(12.w),
                    itemCount: _filtered.length,
                    separatorBuilder: (_, __) => SizedBox(height: 8.h),
                    itemBuilder: (_, i) {
                      final bom = _filtered[i];
                      return _BomPickerCard(
                        bom: bom,
                        onTap: () => Navigator.pop(context, bom),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

class _BomPickerCard extends StatelessWidget {
  final BomData bom;
  final VoidCallback onTap;
  const _BomPickerCard({required this.bom, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(12.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(color: Colors.grey.shade200),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withOpacity(0.03),
                blurRadius: 4,
                offset: const Offset(0, 1)),
          ],
        ),
        child: LayoutBuilder(
          builder: (context, constraints) {
            const badgeW = 60.0;
            const pillW = 52.0;
            const gaps = 8.0 + 6.0;
            final titleW = constraints.maxWidth - badgeW - pillW - gaps;

            const dotW = 5.0;
            const itemGaps = 8.0 + 8.0;
            const codeW = 72.0;
            final nameW = constraints.maxWidth - dotW - itemGaps - codeW;

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      width: badgeW,
                      padding: EdgeInsets.symmetric(
                          horizontal: 8.w, vertical: 3.h),
                      decoration: BoxDecoration(
                        color: joTealLight,
                        borderRadius: BorderRadius.circular(6.r),
                      ),
                      child: Text(
                        'BOM-${bom.bomId.padLeft(3, '0')}',
                        style: TextStyle(
                            fontSize: 11.sp,
                            fontWeight: FontWeight.w800,
                            color: joTealDark),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                    ),
                    SizedBox(width: 8.w),
                    SizedBox(
                      width: titleW > 0 ? titleW : 0,
                      child: Text(
                        bom.bomLabel.contains('·')
                            ? bom.bomLabel.split('·').last.trim()
                            : bom.bomLabel,
                        style: TextStyle(
                            fontSize: 13.sp,
                            fontWeight: FontWeight.w700,
                            color: Colors.black87),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                    ),
                    SizedBox(width: 6.w),
                    SizedBox(
                      width: pillW,
                      child: Container(
                        padding: EdgeInsets.symmetric(
                            horizontal: 7.w, vertical: 3.h),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(6.r),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          '${bom.items.length} items',
                          style: TextStyle(
                              fontSize: 10.sp,
                              color: Colors.grey.shade600,
                              fontWeight: FontWeight.w600),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 8.h),
                ...bom.items.take(2).map((item) => Padding(
                      padding: EdgeInsets.only(bottom: 4.h),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Container(
                            width: dotW,
                            height: dotW,
                            margin: EdgeInsets.only(right: 8.w),
                            decoration: BoxDecoration(
                              color: Colors.grey.shade400,
                              shape: BoxShape.circle,
                            ),
                          ),
                          SizedBox(
                            width: codeW,
                            child: Text(
                              item.itemCode,
                              style: TextStyle(
                                  fontSize: 11.sp,
                                  color: Colors.grey.shade500,
                                  fontFamily: 'monospace'),
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                            ),
                          ),
                          SizedBox(width: 8.w),
                          SizedBox(
                            width: nameW > 0 ? nameW : 0,
                            child: Text(
                              item.itemName,
                              style: TextStyle(
                                  fontSize: 11.sp, color: Colors.black87),
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                            ),
                          ),
                        ],
                      ),
                    )),
                if (bom.items.length > 2)
                  Text(
                    '+${bom.items.length - 2} more items',
                    style: TextStyle(fontSize: 10.sp, color: Colors.grey.shade400),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }
}
