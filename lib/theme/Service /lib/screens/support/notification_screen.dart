import 'package:flutter/material.dart';
import 'package:service_ticket/Widgets/app_status_bar_wrapper.dart';
import 'package:service_ticket/core/size_utils.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  String _selectedTab = 'All';

  // Mutable notification data so taps can mark items as read
  late final List<_NotificationGroupData> _groups = [
    _NotificationGroupData(
      dateLabel: 'Today, 7 Apr 26',
      items: [
        _NotificationItemData(
          assetPath: 'assets/received.png',
          message: 'A new ticket has been assigned to you. Please review and take action.',
          isUnread: false,
        ),
        _NotificationItemData(
          assetPath: 'assets/assinged.png',
          message: 'A new ticket has been assigned to you. Please review and take action.',
          isUnread: true,
        ),
        _NotificationItemData(
          assetPath: 'assets/dispatch.png',
          message: 'A new spare item has been requested for the service.',
          isUnread: false,
        ),
      ],
    ),
    _NotificationGroupData(
      dateLabel: 'Yesterday, 6 Apr 26',
      items: [
        _NotificationItemData(
          assetPath: 'assets/received.png',
          message: 'A new ticket has been assigned to you. Please review and take action.',
          isUnread: true,
        ),
        _NotificationItemData(
          assetPath: 'assets/assinged.png',
          message: 'A new ticket has been assigned to you. Please review and take action.',
          isUnread: false,
        ),
        _NotificationItemData(
          assetPath: 'assets/dispatch.png',
          message: 'A new spare item has been requested for the service.',
          isUnread: true,
        ),
      ],
    ),
  ];

  void _markAsRead(int groupIndex, int itemIndex) {
    setState(() {
      _groups[groupIndex].items[itemIndex].isUnread = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final visibleGroups = _selectedTab == 'Unread'
        ? _groups
            .asMap()
            .entries
            .map(
              (entry) => MapEntry(
                entry.key,
                _NotificationGroupData(
                  dateLabel: entry.value.dateLabel,
                  items: entry.value.items
                      .where((item) => item.isUnread)
                      .toList(),
                ),
              ),
            )
            .where((entry) => entry.value.items.isNotEmpty)
            .toList()
        : _groups
            .asMap()
            .entries
            .toList();

    final bool hasUnread = _groups.any((g) => g.items.any((i) => i.isUnread));

    return Scaffold(
      backgroundColor: Colors.white,
      body: AppStatusBarWrapper(
        child: SafeArea(
          top: false,
          bottom: false,
          child: Column(
            children: [
              Padding(
                padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 8.h),
                child: Row(
                  children: [
                    InkWell(
                      onTap: () => Navigator.pop(context),
                      borderRadius: BorderRadius.circular(20.r),
                      child: Padding(
                        padding: EdgeInsets.all(4.r),
                        child: Icon(
                          Icons.arrow_back_ios_new_rounded,
                          size: 18.sp,
                          color: const Color(0xFF2E4CB9),
                        ),
                      ),
                    ),
                    SizedBox(width: 8.w),
                    Text(
                      'Notification',
                      style: TextStyle(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF2E4CB9),
                      ),
                    ),
                    const Spacer(),
                    Icon(
                      Icons.search_rounded,
                      size: 24.sp,
                      color: const Color(0xFF2E4CB9),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
                child: Row(
                  children: [
                    Expanded(
                      child: _FilterTab(
                        label: 'All',
                        isSelected: _selectedTab == 'All',
                        showDot: hasUnread,
                        onTap: () => setState(() => _selectedTab = 'All'),
                      ),
                    ),
                    SizedBox(width: 14.w),
                    Expanded(
                      child: _FilterTab(
                        label: 'Unread',
                        isSelected: _selectedTab == 'Unread',
                        showDot: hasUnread,
                        onTap: () => setState(() => _selectedTab = 'Unread'),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 20.h),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      for (final entry in visibleGroups) ...[
                        _DateHeader(date: entry.value.dateLabel),
                        SizedBox(height: 12.h),
                        _NotificationGroup(
                          group: _groups[entry.key],
                          groupIndex: entry.key,
                          onItemTap: _markAsRead,
                        ),
                        SizedBox(height: 18.h),
                      ],
                    ],
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

class _FilterTab extends StatelessWidget {
  const _FilterTab({
    required this.label,
    required this.isSelected,
    required this.showDot,
    required this.onTap,
  });

  final String label;
  final bool isSelected;
  final bool showDot;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8.r),
      child: Container(
        height: 34.h,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF2E4CB9) : Colors.white,
          borderRadius: BorderRadius.circular(4.r),
          border: Border.all(
            color: const Color(0xFF2E4CB9),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Center(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w600,
                  color: isSelected ? Colors.white : const Color(0xFF2E4CB9),
                ),
              ),
            ),
            if (showDot)
              const Positioned(
                top: 8,
                right: 10,
                child: _RedDot(),
              ),
          ],
        ),
      ),
    );
  }
}

class _RedDot extends StatelessWidget {
  const _RedDot();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 7.w,
      height: 7.w,
      decoration: const BoxDecoration(
        color: Color(0xFFE53935),
        shape: BoxShape.circle,
      ),
    );
  }
}

class _DateHeader extends StatelessWidget {
  const _DateHeader({required this.date});

  final String date;

  @override
  Widget build(BuildContext context) {
    return Text(
      date,
      style: TextStyle(
        fontSize: 15.sp,
        fontWeight: FontWeight.w700,
        color: const Color(0xFF1D2939),
      ),
    );
  }
}

class _NotificationGroup extends StatelessWidget {
  const _NotificationGroup({
    required this.group,
    required this.groupIndex,
    required this.onItemTap,
  });

  final _NotificationGroupData group;
  final int groupIndex;
  final void Function(int groupIndex, int itemIndex) onItemTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(14.r),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10.r),
        border: Border.all(color: const Color(0xFFF0F2F5)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          for (var index = 0; index < group.items.length; index++) ...[
            _NotificationCard(
              item: group.items[index],
              onTap: () => onItemTap(groupIndex, _findOriginalIndex(index)),
            ),
            if (index != group.items.length - 1) SizedBox(height: 10.h),
          ],
        ],
      ),
    );
  }

  int _findOriginalIndex(int filteredIndex) {
    // Find original index in the parent group's full items list
    final item = group.items[filteredIndex];
    final parentItems = group.items;
    return parentItems.indexOf(item);
  }
}

class _NotificationCard extends StatelessWidget {
  const _NotificationCard({
    required this.item,
    required this.onTap,
  });

  final _NotificationItemData item;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: item.isUnread ? onTap : null,
      borderRadius: BorderRadius.circular(8.r),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            padding: EdgeInsets.all(10.r),
            decoration: BoxDecoration(
              color: item.isUnread
                  ? const Color(0xFFEEF2FF)
                  : const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 40.w,
                  height: 40.w,
                  padding: EdgeInsets.all(7.r),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(6.r),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.04),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Image.asset(
                    item.assetPath,
                    fit: BoxFit.contain,
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.only(top: 1.h),
                    child: Text(
                      item.message,
                      style: TextStyle(
                        fontSize: 11.5.sp,
                        color: const Color(0xFF667085),
                        fontWeight: item.isUnread ? FontWeight.w600 : FontWeight.w400,
                        height: 1.45,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (item.isUnread)
            Positioned(
              top: 8.h,
              right: 8.w,
              child: Container(
                width: 8.w,
                height: 8.w,
                decoration: const BoxDecoration(
                  color: Color(0xFFE53935),
                  shape: BoxShape.circle,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _NotificationGroupData {
  _NotificationGroupData({
    required this.dateLabel,
    required this.items,
  });

  final String dateLabel;
  final List<_NotificationItemData> items;
}

class _NotificationItemData {
  _NotificationItemData({
    required this.assetPath,
    required this.message,
    required this.isUnread,
  });

  final String assetPath;
  final String message;
  bool isUnread;
}
