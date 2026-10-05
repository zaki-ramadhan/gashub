import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/core.dart';
import '../../receivables/presentation/receivable_payment_sheet.dart';
import '../data/notifications_repository.dart';
import '../domain/notification_models.dart';
import 'widgets/notification_expandable_tile.dart';
import 'widgets/notification_schedule_banner.dart';
import 'widgets/notification_settings_sheet.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  String _selectedCategory = 'Semua';

  static const List<String> _categoryOptions = [
    'Semua',
    'Tagihan warung',
    'Jadwal muat',
  ];

  @override
  void initState() {
    super.initState();
    NotificationsRepository.instance.fetchNotifications();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Notifikasi'),
        titleSpacing: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.tune_outlined, size: 20),
            tooltip: 'Atur waktu pengingat',
            onPressed: () {
              NotificationSettingsSheet.show(
                context: context,
                initialSettings:
                    NotificationsRepository.instance.settingsNotifier.value,
              );
            },
          ),
          const SizedBox(width: AppDimensions.space8),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Subheader: Schedule notice, Unread status & Filter chips (All unified)
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppDimensions.space16,
              AppDimensions.space10,
              AppDimensions.space16,
              AppDimensions.space12,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                NotificationScheduleBanner(
                  onEdit: () {
                    NotificationSettingsSheet.show(
                      context: context,
                      initialSettings:
                          NotificationsRepository.instance.settingsNotifier.value,
                    );
                  },
                ),
                const SizedBox(height: AppDimensions.space8),
                Row(
                  children: [
                    ValueListenableBuilder<int>(
                      valueListenable:
                          NotificationsRepository.instance.unreadCountNotifier,
                      builder: (context, unreadCount, _) {
                        return Text(
                          unreadCount > 0
                              ? '$unreadCount pengingat belum dibaca'
                              : 'Semua pengingat telah dibaca',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w400,
                            color: AppColors.textMuted,
                          ),
                        );
                      },
                    ),
                    const Spacer(),
                    ValueListenableBuilder<int>(
                      valueListenable:
                          NotificationsRepository.instance.unreadCountNotifier,
                      builder: (context, unreadCount, _) {
                        if (unreadCount == 0) return const SizedBox.shrink();
                        return InkWell(
                          onTap: () {
                            NotificationsRepository.instance.markAllAsRead();
                          },
                          borderRadius: BorderRadius.circular(4),
                          child: const Padding(
                            padding: EdgeInsets.symmetric(
                              horizontal: 4,
                              vertical: 2,
                            ),
                            child: Text(
                              'Tandai semua dibaca',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                color: AppColors.brandPrimary,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
                const SizedBox(height: AppDimensions.space10),
                AppFilterChips<String>(
                  options: _categoryOptions,
                  selected: _selectedCategory,
                  onSelected: (cat) {
                    setState(() => _selectedCategory = cat);
                  },
                ),
              ],
            ),
          ),

          const Divider(height: 1, thickness: 1, color: AppColors.border),

          // Main List Area: Seamless full-width list united in one continuous container
          Expanded(
            child: RefreshIndicator(
              color: AppColors.brandPrimary,
              onRefresh: () =>
                  NotificationsRepository.instance.fetchNotifications(),
              child: ValueListenableBuilder<bool>(
                valueListenable:
                    NotificationsRepository.instance.isLoadingNotifier,
                builder: (context, isLoading, _) {
                  return ValueListenableBuilder<List<NotificationItem>>(
                    valueListenable: NotificationsRepository
                        .instance.notificationsNotifier,
                    builder: (context, allItems, _) {
                      if (isLoading && allItems.isEmpty) {
                        return const Center(
                          child: CircularProgressIndicator(
                            color: AppColors.brandPrimary,
                          ),
                        );
                      }

                      final filteredItems = allItems.where((item) {
                        if (_selectedCategory == 'Tagihan warung') {
                          return item.type == NotificationType.debt;
                        }
                        if (_selectedCategory == 'Jadwal muat') {
                          return item.type == NotificationType.restock;
                        }
                        return true;
                      }).toList();

                      if (filteredItems.isEmpty) {
                        return _buildEmptyState();
                      }

                      return ListView.separated(
                        physics: const AlwaysScrollableScrollPhysics(),
                        padding: const EdgeInsets.only(
                          bottom: AppDimensions.space32,
                        ),
                        itemCount: filteredItems.length,
                        separatorBuilder: (context, index) => const Divider(
                          height: 1,
                          thickness: 1,
                          color: AppColors.border,
                        ),
                        itemBuilder: (context, index) {
                          final item = filteredItems[index];
                          return NotificationExpandableTile(
                            item: item,
                            onAction: () => _handleItemAction(item),
                            onMarkRead: () {
                              NotificationsRepository.instance
                                  .markAsRead(item.id);
                            },
                          );
                        },
                      );
                    },
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _handleItemAction(NotificationItem item) async {
    if (item.type == NotificationType.debt && item.receivableId != null) {
      final rec = NotificationsRepository.instance
          .findReceivableById(item.receivableId!);
      if (rec != null) {
        await ReceivablePaymentSheet.show(
          context: context,
          item: rec,
        );
        NotificationsRepository.instance.fetchNotifications();
      } else {
        context.push('/receivables');
      }
    } else if (item.type == NotificationType.restock) {
      context.push('/inventory');
    }
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppDimensions.space32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: const BoxDecoration(
                color: Color(0xFFE8F5E9),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.done_all,
                size: 26,
                color: AppColors.brandPrimary,
              ),
            ),
            const SizedBox(height: AppDimensions.space16),
            const Text(
              'Tidak ada pengingat',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: AppDimensions.space8),
            Text(
              _selectedCategory == 'Semua'
                  ? 'Semua jadwal muat gas dan tagihan warung telah ditangani dengan baik.'
                  : 'Tidak ada pengingat aktif pada kategori $_selectedCategory saat ini.',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 13,
                color: AppColors.textMuted,
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
