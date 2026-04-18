import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../widgets/app_theme.dart';

// ─── Notification Model ───────────────────────────────────────────────────────
class NotificationItem {
  final String id;
  final String title;
  final String subtitle;
  final String time;
  final NotificationType type;
  final bool isRead;

  const NotificationItem({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.time,
    required this.type,
    this.isRead = false,
  });

  NotificationItem copyWith({bool? isRead}) => NotificationItem(
    id: id,
    title: title,
    subtitle: subtitle,
    time: time,
    type: type,
    isRead: isRead ?? this.isRead,
  );
}

enum NotificationType { order, invoice, payment, delivery, alert, approval }

// ─── Notification Page ────────────────────────────────────────────────────────
class NotificationPage extends StatefulWidget {
  const NotificationPage({super.key});

  @override
  State<NotificationPage> createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  final List<NotificationItem> _notifications = [
    const NotificationItem(
      id: '1',
      title: 'New Sales Order Received',
      subtitle: 'SO-2026-249 from Acme Corp Ltd · ₹1,24,500',
      time: '2 min ago',
      type: NotificationType.order,
      isRead: false,
    ),
    const NotificationItem(
      id: '2',
      title: 'Invoice Approved',
      subtitle: 'INV-2026-186 approved by Finance Team',
      time: '15 min ago',
      type: NotificationType.approval,
      isRead: false,
    ),
    const NotificationItem(
      id: '3',
      title: 'Payment Received',
      subtitle: '₹85,000 received from TechStar Industries',
      time: '1 hr ago',
      type: NotificationType.payment,
      isRead: false,
    ),
    const NotificationItem(
      id: '4',
      title: 'Delivery Completed',
      subtitle: 'DO-2026-134 delivered to Global Traders',
      time: '2 hr ago',
      type: NotificationType.delivery,
      isRead: true,
    ),
    const NotificationItem(
      id: '5',
      title: 'Invoice Overdue',
      subtitle: 'INV-2026-171 is 7 days overdue · ₹67,200',
      time: '3 hr ago',
      type: NotificationType.alert,
      isRead: false,
    ),
    const NotificationItem(
      id: '6',
      title: 'Sales Order Confirmed',
      subtitle: 'SO-2026-248 confirmed by Sunrise Pvt Ltd',
      time: 'Yesterday',
      type: NotificationType.order,
      isRead: true,
    ),
    const NotificationItem(
      id: '7',
      title: 'New Invoice Generated',
      subtitle: 'INV-2026-187 for ₹2,18,000 created',
      time: 'Yesterday',
      type: NotificationType.invoice,
      isRead: true,
    ),
    const NotificationItem(
      id: '8',
      title: 'Low Stock Alert',
      subtitle: 'Product Alpha X200 — only 5 units remaining',
      time: '2 days ago',
      type: NotificationType.alert,
      isRead: true,
    ),
    const NotificationItem(
      id: '9',
      title: 'Payment Pending',
      subtitle: '₹2,18,000 from Sunrise Pvt Ltd is due today',
      time: '2 days ago',
      type: NotificationType.payment,
      isRead: true,
    ),
    const NotificationItem(
      id: '10',
      title: 'Approval Required',
      subtitle: 'Sales Return SR-2026-018 needs your approval',
      time: '3 days ago',
      type: NotificationType.approval,
      isRead: true,
    ),
  ];

  int get _unreadCount => _notifications.where((n) => !n.isRead).length;

  void _markAllRead() {
    setState(() {
      for (int i = 0; i < _notifications.length; i++) {
        _notifications[i] = _notifications[i].copyWith(isRead: true);
      }
    });
  }

  void _markRead(String id) {
    setState(() {
      final idx = _notifications.indexWhere((n) => n.id == id);
      if (idx != -1) {
        _notifications[idx] = _notifications[idx].copyWith(isRead: true);
      }
    });
  }

  void _deleteNotification(String id) {
    setState(() {
      _notifications.removeWhere((n) => n.id == id);
    });
  }

  List<NotificationItem> get _unread =>
      _notifications.where((n) => !n.isRead).toList();
  List<NotificationItem> get _all => _notifications;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: AppTheme.statusBarTeal,
      child: Scaffold(
        backgroundColor: const Color(0xFFF5F7FA),
        body: NestedScrollView(
          headerSliverBuilder: (context, _) => [
            _buildAppBar(),
            _buildTabBar(),
          ],
          body: TabBarView(
            controller: _tabController,
            children: [
              _NotificationList(
                notifications: _unread,
                onMarkRead: _markRead,
                onDelete: _deleteNotification,
                emptyMessage: 'All caught up!',
                emptySubtitle: 'No unread notifications',
                emptyIcon: Icons.mark_email_read_rounded,
              ),
              _NotificationList(
                notifications: _all,
                onMarkRead: _markRead,
                onDelete: _deleteNotification,
                emptyMessage: 'No notifications',
                emptySubtitle: 'You have no notifications yet',
                emptyIcon: Icons.notifications_off_rounded,
              ),
            ],
          ),
        ),
      ),
    );
  }

  SliverAppBar _buildAppBar() {
    return SliverAppBar(
      pinned: true,
      backgroundColor: AppColors.primaryDark,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      systemOverlayStyle: AppTheme.statusBarTeal,
      leading: IconButton(
        onPressed: () => Navigator.pop(context),
        icon: const Icon(Icons.arrow_back_rounded,
            color: Colors.white, size: 22),
      ),
      title: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Flexible(
            child: Text(
              'Notifications',
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w700,
                fontFamily: 'Poppins',
              ),
            ),
          ),
          if (_unreadCount > 0) ...[
            const SizedBox(width: 8),
            Container(
              padding:
              const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: AppColors.amber,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                '$_unreadCount',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  fontFamily: 'Poppins',
                ),
              ),
            ),
          ],
        ],
      ),
      actions: [
        if (_unreadCount > 0)
          TextButton.icon(
            onPressed: _markAllRead,
            icon: const Icon(Icons.done_all_rounded,
                color: Colors.white70, size: 16),
            label: const Text(
              'Mark all read',
              style: TextStyle(
                color: Colors.white70,
                fontSize: 12,
                fontFamily: 'Poppins',
              ),
            ),
          ),
        const SizedBox(width: 4),
      ],
    );
  }

  SliverPersistentHeader _buildTabBar() {
    return SliverPersistentHeader(
      pinned: true,
      delegate: _TabBarDelegate(
        TabBar(
          controller: _tabController,
          labelColor: AppColors.primary,
          unselectedLabelColor: AppColors.textMuted,
          labelStyle: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            fontFamily: 'Poppins',
          ),
          unselectedLabelStyle: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w400,
            fontFamily: 'Poppins',
          ),
          indicatorColor: AppColors.primary,
          indicatorWeight: 2.5,
          indicatorSize: TabBarIndicatorSize.label,
          dividerColor: AppColors.divider,
          tabs: [
            Tab(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('Unread'),
                  if (_unreadCount > 0) ...[
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 1),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '$_unreadCount',
                        style: const TextStyle(
                          color: AppColors.primary,
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          fontFamily: 'Poppins',
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const Tab(text: 'All'),
          ],
        ),
      ),
    );
  }
}

// ─── Tab Bar Delegate ─────────────────────────────────────────────────────────
class _TabBarDelegate extends SliverPersistentHeaderDelegate {
  final TabBar tabBar;
  const _TabBarDelegate(this.tabBar);

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) =>
      Container(color: Colors.white, child: tabBar);

  @override
  double get maxExtent => 46;
  @override
  double get minExtent => 46;
  @override
  bool shouldRebuild(_TabBarDelegate old) => old.tabBar != tabBar;
}

// ─── Notification List ────────────────────────────────────────────────────────
class _NotificationList extends StatelessWidget {
  final List<NotificationItem> notifications;
  final void Function(String) onMarkRead;
  final void Function(String) onDelete;
  final String emptyMessage;
  final String emptySubtitle;
  final IconData emptyIcon;

  const _NotificationList({
    required this.notifications,
    required this.onMarkRead,
    required this.onDelete,
    required this.emptyMessage,
    required this.emptySubtitle,
    required this.emptyIcon,
  });

  // Group by Today / Yesterday / Earlier
  Map<String, List<NotificationItem>> _grouped() {
    final Map<String, List<NotificationItem>> map = {};
    for (final n in notifications) {
      final key = n.time.contains('ago') || n.time == 'Today'
          ? 'Today'
          : n.time == 'Yesterday'
          ? 'Yesterday'
          : 'Earlier';
      map.putIfAbsent(key, () => []).add(n);
    }
    return map;
  }

  @override
  Widget build(BuildContext context) {
    if (notifications.isEmpty) {
      return _EmptyState(
        icon: emptyIcon,
        message: emptyMessage,
        subtitle: emptySubtitle,
      );
    }

    final grouped = _grouped();
    final keys = ['Today', 'Yesterday', 'Earlier']
        .where((k) => grouped.containsKey(k))
        .toList();

    return ListView.builder(
      padding: const EdgeInsets.only(top: 12, bottom: 24),
      itemCount: keys.fold(0, (sum, k) => sum! + 1 + grouped[k]!.length),
      itemBuilder: (context, index) {
        int cursor = 0;
        for (final key in keys) {
          if (index == cursor) {
            return _GroupLabel(label: key);
          }
          cursor++;
          final items = grouped[key]!;
          if (index < cursor + items.length) {
            final item = items[index - cursor];
            return _NotificationCard(
              item: item,
              onMarkRead: () => onMarkRead(item.id),
              onDelete: () => onDelete(item.id),
            );
          }
          cursor += items.length;
        }
        return const SizedBox.shrink();
      },
    );
  }
}

// ─── Group Label ──────────────────────────────────────────────────────────────
class _GroupLabel extends StatelessWidget {
  final String label;
  const _GroupLabel({required this.label});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 6),
      child: Text(
        label,
        style: const TextStyle(
          color: AppColors.textMuted,
          fontSize: 11,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.5,
          fontFamily: 'Poppins',
        ),
      ),
    );
  }
}

// ─── Notification Card ────────────────────────────────────────────────────────
class _NotificationCard extends StatelessWidget {
  final NotificationItem item;
  final VoidCallback onMarkRead;
  final VoidCallback onDelete;

  const _NotificationCard({
    required this.item,
    required this.onMarkRead,
    required this.onDelete,
  });

  // Type config
  static const _typeConfig = {
    NotificationType.order: _TypeConfig(
      icon: Icons.shopping_cart_rounded,
      color: Color(0xFF26A69A),
      bgColor: Color(0xFFE0F7F4),
      label: 'Order',
    ),
    NotificationType.invoice: _TypeConfig(
      icon: Icons.receipt_long_rounded,
      color: Color(0xFF0045BC),
      bgColor: Color(0xFFE3F2FD),
      label: 'Invoice',
    ),
    NotificationType.payment: _TypeConfig(
      icon: Icons.payments_rounded,
      color: Color(0xFF66BB6A),
      bgColor: Color(0xFFE8F5E9),
      label: 'Payment',
    ),
    NotificationType.delivery: _TypeConfig(
      icon: Icons.local_shipping_rounded,
      color: Color(0xFFAB47BC),
      bgColor: Color(0xFFF3E5F5),
      label: 'Delivery',
    ),
    NotificationType.alert: _TypeConfig(
      icon: Icons.warning_amber_rounded,
      color: Color(0xFFEF5350),
      bgColor: Color(0xFFFFEBEE),
      label: 'Alert',
    ),
    NotificationType.approval: _TypeConfig(
      icon: Icons.approval_rounded,
      color: Color(0xFFFFA726),
      bgColor: Color(0xFFFFF8E1),
      label: 'Approval',
    ),
  };

  @override
  Widget build(BuildContext context) {
    final config = _typeConfig[item.type]!;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Dismissible(
        key: Key(item.id),
        direction: DismissDirection.endToStart,
        background: Container(
          alignment: Alignment.centerRight,
          padding: const EdgeInsets.only(right: 20),
          decoration: BoxDecoration(
            color: AppColors.red.withOpacity(0.12),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              Icon(Icons.delete_outline_rounded,
                  color: AppColors.red, size: 22),
              SizedBox(height: 3),
              Text(
                'Delete',
                style: TextStyle(
                  color: AppColors.red,
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  fontFamily: 'Poppins',
                ),
              ),
            ],
          ),
        ),
        onDismissed: (_) => onDelete(),
        child: GestureDetector(
          onTap: item.isRead ? null : onMarkRead,
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: item.isRead ? Colors.white : config.bgColor,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: item.isRead
                    ? AppColors.divider
                    : config.color.withOpacity(0.22),
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: item.isRead
                      ? Colors.black.withOpacity(0.03)
                      : config.color.withOpacity(0.08),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Icon
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: config.bgColor,
                    borderRadius: BorderRadius.circular(13),
                    border: Border.all(
                        color: config.color.withOpacity(0.20), width: 1),
                  ),
                  child: Icon(config.icon, color: config.color, size: 20),
                ),
                const SizedBox(width: 12),
                // Content
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          // Type badge
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: config.color.withOpacity(0.12),
                              borderRadius: BorderRadius.circular(5),
                            ),
                            child: Text(
                              config.label,
                              style: TextStyle(
                                color: config.color,
                                fontSize: 9,
                                fontWeight: FontWeight.w700,
                                fontFamily: 'Poppins',
                              ),
                            ),
                          ),
                          const Spacer(),
                          Text(
                            item.time,
                            style: const TextStyle(
                              color: AppColors.textMuted,
                              fontSize: 10,
                              fontFamily: 'Poppins',
                            ),
                          ),
                          if (!item.isRead) ...[
                            const SizedBox(width: 6),
                            Container(
                              width: 7,
                              height: 7,
                              decoration: BoxDecoration(
                                color: config.color,
                                shape: BoxShape.circle,
                              ),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        item.title,
                        style: TextStyle(
                          color: const Color(0xFF1A2332),
                          fontSize: 13,
                          fontWeight: item.isRead
                              ? FontWeight.w500
                              : FontWeight.w700,
                          fontFamily: 'Poppins',
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        item.subtitle,
                        style: const TextStyle(
                          color: AppColors.textMuted,
                          fontSize: 11,
                          fontFamily: 'Poppins',
                          height: 1.4,
                        ),
                      ),
                      if (!item.isRead) ...[
                        const SizedBox(height: 8),
                        GestureDetector(
                          onTap: onMarkRead,
                          child: Text(
                            'Mark as read',
                            style: TextStyle(
                              color: config.color,
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              fontFamily: 'Poppins',
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Type Config ──────────────────────────────────────────────────────────────
class _TypeConfig {
  final IconData icon;
  final Color color;
  final Color bgColor;
  final String label;
  const _TypeConfig({
    required this.icon,
    required this.color,
    required this.bgColor,
    required this.label,
  });
}

// ─── Empty State ──────────────────────────────────────────────────────────────
class _EmptyState extends StatelessWidget {
  final IconData icon;
  final String message;
  final String subtitle;
  const _EmptyState({
    required this.icon,
    required this.message,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.08),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: AppColors.primary, size: 36),
          ),
          const SizedBox(height: 16),
          Text(
            message,
            style: const TextStyle(
              color: Color(0xFF1A2332),
              fontSize: 16,
              fontWeight: FontWeight.w700,
              fontFamily: 'Poppins',
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: const TextStyle(
              color: AppColors.textMuted,
              fontSize: 13,
              fontFamily: 'Poppins',
            ),
          ),
        ],
      ),
    );
  }
}