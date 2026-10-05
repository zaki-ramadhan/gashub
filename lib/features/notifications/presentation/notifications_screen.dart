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
  static const String _catAll = 'semua';
  static const String _catUnread = 'unread';
  static const String _catDebt = 'debt';
  static const String _catRestock = 'restock';

  static const List<String> _categoryOptions = [
    _catAll,
    _catUnread,
    _catDebt,
    _catRestock,
  ];

  String _selectedCategory = _catAll;
  String? _expandedId;

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
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Notifikasi'),
            const SizedBox(width: AppDimensions.space8),
            ValueListenableBuilder<int>(
              valueListenable:
                  NotificationsRepository.instance.unreadCountNotifier,
              builder: (context, unreadCount, _) {
                if (unreadCount == 0) return const SizedBox.shrink();
                return Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppColors.brandPrimary,
                    borderRadius:
                        BorderRadius.circular(AppDimensions.radiusPill),
                  ),
                  child: Text(
                    '$unreadCount baru',
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                );
              },
            ),
          ],
        ),
        titleSpacing: 0,
        actions: [
          ValueListenableBuilder<int>(
            valueListenable:
                NotificationsRepository.instance.unreadCountNotifier,
            builder: (context, unreadCount, _) {
              if (unreadCount == 0) return const SizedBox.shrink();
              return TextButton(
                onPressed: () {
                  NotificationsRepository.instance.markAllAsRead();
                },
                child: const Text(
                  'Tandai dibaca',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: AppColors.brandPrimary,
                  ),
                ),
              );
            },
          ),
          const SizedBox(width: AppDimensions.space8),
        ],
      ),
      body: RefreshIndicator(
        color: AppColors.brandPrimary,
        onRefresh: () => NotificationsRepository.instance.fetchNotifications(),
        child: ValueListenableBuilder<bool>(
          valueListenable: NotificationsRepository.instance.isLoadingNotifier,
          builder: (context, isLoading, _) {
            return ValueListenableBuilder<List<NotificationItem>>(
              valueListenable:
                  NotificationsRepository.instance.notificationsNotifier,
              builder: (context, allItems, _) {
                final filteredItems = allItems.where((item) {
                  if (_selectedCategory == _catUnread) {
                    return !item.isRead;
                  }
                  if (_selectedCategory == _catDebt) {
                    return item.type == NotificationType.debt;
                  }
                  if (_selectedCategory == _catRestock) {
                    return item.type == NotificationType.restock;
                  }
                  return true;
                }).toList();

                final grouped = groupItemsByDate<NotificationItem>(
                  filteredItems,
                  (item) => item.dateTime,
                );
                final sortedDates = grouped.keys.toList();

                return CustomScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  slivers: [
                    // Subheader: Schedule banner & filter chips in crisp white container
                    SliverToBoxAdapter(
                      child: Container(
                        color: Colors.white,
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
                                  initialSettings: NotificationsRepository
                                      .instance.settingsNotifier.value,
                                );
                              },
                            ),
                            const SizedBox(height: AppDimensions.space12),
                            ValueListenableBuilder<int>(
                              valueListenable: NotificationsRepository
                                  .instance.unreadCountNotifier,
                              builder: (context, unreadCount, _) {
                                return AppFilterChips<String>(
                                  options: _categoryOptions,
                                  selected: _selectedCategory,
                                  labelBuilder: (cat) {
                                    switch (cat) {
                                      case _catAll:
                                        return 'Semua';
                                      case _catUnread:
                                        return unreadCount > 0
                                            ? 'Belum dibaca ($unreadCount)'
                                            : 'Belum dibaca';
                                      case _catDebt:
                                        return 'Tagihan pelanggan';
                                      case _catRestock:
                                        return 'Jadwal muat';
                                      default:
                                        return cat;
                                    }
                                  },
                                  onSelected: (cat) {
                                    setState(() => _selectedCategory = cat);
                                  },
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SliverToBoxAdapter(
                      child: Divider(
                        height: 1,
                        thickness: 1,
                        color: AppColors.border,
                      ),
                    ),

                    if (isLoading && allItems.isEmpty)
                      const SliverFillRemaining(
                        hasScrollBody: false,
                        child: Center(
                          child: CircularProgressIndicator(
                            color: AppColors.brandPrimary,
                          ),
                        ),
                      )
                    else if (filteredItems.isEmpty)
                      SliverFillRemaining(
                        hasScrollBody: false,
                        child: _buildEmptyState(),
                      )
                    else
                      SliverPadding(
                        padding: const EdgeInsets.only(
                          bottom: AppDimensions.space24,
                        ),
                        sliver: SliverList(
                          delegate: SliverChildBuilderDelegate(
                            (context, index) {
                              final dateKey = sortedDates[index];
                              final itemsForDay = grouped[dateKey]!;

                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: AppDimensions.space16,
                                    ),
                                    child: DateSectionHeader(
                                      title: AppFormatters.relativeDateHeader(
                                          dateKey),
                                      topPadding: index == 0
                                          ? AppDimensions.space12
                                          : AppDimensions.space20,
                                    ),
                                  ),
                                  const Divider(
                                    height: 1,
                                    thickness: 1,
                                    color: AppColors.border,
                                  ),
                                  for (int i = 0;
                                      i < itemsForDay.length;
                                      i++) ...[
                                    NotificationExpandableTile(
                                      item: itemsForDay[i],
                                      isExpanded:
                                          _expandedId == itemsForDay[i].id,
                                      onToggle: () {
                                        setState(() {
                                          _expandedId = (_expandedId ==
                                                  itemsForDay[i].id)
                                              ? null
                                              : itemsForDay[i].id;
                                        });
                                      },
                                      onAction: () =>
                                          _handleItemAction(itemsForDay[i]),
                                      onMarkRead: () {
                                        NotificationsRepository.instance
                                            .markAsRead(itemsForDay[i].id);
                                      },
                                    ),
                                  ],
                                ],
                              );
                            },
                            childCount: sortedDates.length,
                          ),
                        ),
                      ),
                  ],
                );
              },
            );
          },
        ),
      ),
      // Fixed bottom bar: Unaffected by scroll, visible only when read notifications exist
      bottomNavigationBar: ValueListenableBuilder<int>(
        valueListenable: NotificationsRepository.instance.readCountNotifier,
        builder: (context, readCount, _) {
          if (readCount == 0) return const SizedBox.shrink();
          return Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              border: Border(
                top: BorderSide(color: AppColors.border, width: 1),
              ),
            ),
            padding: const EdgeInsets.fromLTRB(
              AppDimensions.space16,
              AppDimensions.space12,
              AppDimensions.space16,
              AppDimensions.space12,
            ),
            child: SafeArea(
              top: false,
              child: AppButton(
                text: 'Bersihkan $readCount notifikasi terbaca',
                isSecondary: true,
                borderRadius:
                    BorderRadius.circular(AppDimensions.radiusControl),
                textColor: AppColors.textPrimary,
                onPressed: _confirmClearRead,
              ),
            ),
          );
        },
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

  Future<void> _confirmClearRead() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusCard),
        ),
        title: const Text(
          'Bersihkan notifikasi',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        content: const Text(
          'Hanya notifikasi yang sudah dibaca yang akan dihapus dari daftar.',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w400,
            color: AppColors.textMuted,
            height: 1.4,
          ),
        ),
        actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            style: TextButton.styleFrom(
              foregroundColor: AppColors.textMuted,
              shape: RoundedRectangleBorder(
                borderRadius:
                    BorderRadius.circular(AppDimensions.radiusControl),
              ),
            ),
            child: const Text(
              'Batal',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: TextButton.styleFrom(
              foregroundColor: AppColors.brandPrimary,
              shape: RoundedRectangleBorder(
                borderRadius:
                    BorderRadius.circular(AppDimensions.radiusControl),
              ),
            ),
            child: const Text(
              'Bersihkan',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await NotificationsRepository.instance.clearReadNotifications();
      if (mounted) {
        AppToast.success(title: 'Notifikasi berhasil dibersihkan');
      }
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
              _selectedCategory == _catAll
                  ? 'Semua jadwal muat gas dan tagihan pelanggan telah ditangani dengan baik.'
                  : _selectedCategory == _catUnread
                      ? 'Tidak ada pengingat yang belum dibaca saat ini.'
                      : 'Tidak ada pengingat aktif pada kategori ini saat ini.',
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
