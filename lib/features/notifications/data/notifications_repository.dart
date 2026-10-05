import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/formatters/app_formatters.dart';
import '../../receivables/domain/receivable_model.dart';
import '../domain/notification_models.dart';

class NotificationsRepository {
  NotificationsRepository._() {
    init();
  }

  static final NotificationsRepository instance = NotificationsRepository._();

  final ValueNotifier<List<NotificationItem>> notificationsNotifier =
      ValueNotifier<List<NotificationItem>>([]);

  final ValueNotifier<int> unreadCountNotifier = ValueNotifier<int>(0);

  final ValueNotifier<NotificationSettings> settingsNotifier =
      ValueNotifier<NotificationSettings>(const NotificationSettings());

  final ValueNotifier<bool> isLoadingNotifier = ValueNotifier<bool>(false);

  Set<String> _readIds = {};
  List<ReceivableModel> _rawReceivables = [];

  List<ReceivableModel> get rawReceivables => _rawReceivables;

  Future<void> init() async {
    await loadSettings();
    await fetchNotifications();
  }

  Future<void> loadSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final restockHour = prefs.getInt('notif_restock_hour') ?? prefs.getInt('notif_h0_hour') ?? 7;
      final restockMinute = prefs.getInt('notif_restock_minute') ?? prefs.getInt('notif_h0_minute') ?? 0;
      final debtDueDays = prefs.getInt('notif_debt_due_days') ?? 7;
      final readList = prefs.getStringList('notif_read_ids') ?? [];

      _readIds = readList.toSet();
      settingsNotifier.value = NotificationSettings(
        restockTime: TimeOfDay(hour: restockHour, minute: restockMinute),
        debtDueDays: debtDueDays,
      );
    } catch (e) {
      debugPrint('Error loading notification settings: $e');
    }
  }

  Future<void> updateSettings(NotificationSettings newSettings) async {
    try {
      settingsNotifier.value = newSettings;
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('notif_restock_hour', newSettings.restockTime.hour);
      await prefs.setInt('notif_restock_minute', newSettings.restockTime.minute);
      await prefs.setInt('notif_debt_due_days', newSettings.debtDueDays);
      await fetchNotifications();
    } catch (e) {
      debugPrint('Error saving notification settings: $e');
    }
  }

  Future<void> markAsRead(String id) async {
    _readIds.add(id);
    await _saveReadIds();
    _recalculateUnreadCount();
  }

  Future<void> markAllAsRead() async {
    for (final item in notificationsNotifier.value) {
      _readIds.add(item.id);
    }
    await _saveReadIds();
    _recalculateUnreadCount();
  }

  Future<void> _saveReadIds() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setStringList('notif_read_ids', _readIds.toList());
      // Re-map items with updated read status
      notificationsNotifier.value = notificationsNotifier.value.map((item) {
        return item.copyWith(isRead: _readIds.contains(item.id));
      }).toList();
    } catch (e) {
      debugPrint('Error saving read notification IDs: $e');
    }
  }

  void _recalculateUnreadCount() {
    final count = notificationsNotifier.value.where((n) => !n.isRead).length;
    unreadCountNotifier.value = count;
  }

  Future<void> fetchNotifications() async {
    isLoadingNotifier.value = true;
    try {
      final client = Supabase.instance.client;
      final settings = settingsNotifier.value;
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);

      final List<NotificationItem> items = [];
      _rawReceivables = [];

      // 1. Fetch live receivables
      try {
        final recRes = await client.from('receivables').select('''
          id, original_amount, paid_amount, remaining_amount, status, created_at,
          customers(id, name, phone, address),
          distributions(id, transaction_number, business_date, total)
        ''').neq('status', 'paid').order('remaining_amount', ascending: false);

        for (final row in recRes as List<dynamic>) {
          final r = row as Map<String, dynamic>;
          final customer = r['customers'] as Map<String, dynamic>?;
          final dist = r['distributions'] as Map<String, dynamic>?;

          final customerName = customer?['name']?.toString() ?? 'Pelanggan';
          final remainingAmount = (r['remaining_amount'] as num?)?.toInt() ?? 0;
          final originalAmount = (r['original_amount'] as num?)?.toInt() ?? 0;
          final paidAmount = (r['paid_amount'] as num?)?.toInt() ?? 0;
          final distDateStr = dist?['business_date']?.toString();
          final distDate = DateTime.tryParse(distDateStr ?? '') ?? now;
          final daysElapsed = today.difference(DateTime(distDate.year, distDate.month, distDate.day)).inDays;

          final recModel = ReceivableModel(
            id: r['id'] as String,
            customerId: customer?['id'] as String? ?? '',
            customerName: customerName,
            phone: customer?['phone'] as String? ?? '',
            remainingAmount: remainingAmount,
            originalAmount: originalAmount,
            paidAmount: paidAmount,
            date: distDate,
            invoiceNumber: '#${dist?['transaction_number'] ?? ''}',
            status: r['status']?.toString() ?? 'unpaid',
          );
          _rawReceivables.add(recModel);

          final formattedAmount = AppFormatters.currency(remainingAmount);
          final notifId = 'debt_${r['id']}';
          final bool isOverdue = daysElapsed >= settings.debtDueDays;

          final String message = isOverdue
              ? '$customerName masih memiliki sisa tagihan sebesar $formattedAmount dari transaksi $daysElapsed hari yang lalu. Silakan lakukan penagihan saat pengiriman gas hari ini.'
              : '$customerName memiliki tagihan belum lunas sebesar $formattedAmount dari transaksi $daysElapsed hari yang lalu. Mohon konfirmasi pembayaran saat pengiriman berikutnya.';

          items.add(NotificationItem(
            id: notifId,
            type: NotificationType.debt,
            title: 'Tagihan $customerName',
            message: message,
            dateTime: distDate,
            isRead: _readIds.contains(notifId),
            amount: remainingAmount,
            customerName: customerName,
            receivableId: r['id'] as String,
            actionText: 'Catat bayar',
          ));
        }
      } catch (e) {
        debugPrint('Error fetching receivables for notifications: $e');
      }

      // 2. Fetch live restock schedules
      try {
        final restockRes = await client.from('restock_schedules').select('''
          id, scheduled_date, status, notes,
          suppliers(id, name, phone)
        ''').eq('status', 'scheduled').order('scheduled_date', ascending: true);

        for (final row in restockRes as List<dynamic>) {
          final s = row as Map<String, dynamic>;
          final supplier = s['suppliers'] as Map<String, dynamic>?;
          final supplierName = supplier?['name']?.toString() ?? 'Supplier SPPBE';
          final scheduleDateStr = s['scheduled_date']?.toString();
          final scheduleDate = DateTime.tryParse(scheduleDateStr ?? '') ?? now;
          final daysUntil = DateTime(scheduleDate.year, scheduleDate.month, scheduleDate.day)
              .difference(today)
              .inDays;

          final notifId = 'restock_${s['id']}';
          final notes = s['notes']?.toString();
          final notesPart = (notes != null && notes.isNotEmpty) ? ' ($notes)' : '';

          // Hanya tampilkan pengingat jika hari jadwal sudah tiba atau terlewat
          if (daysUntil > 0) continue;

          String title;
          String message;

          if (daysUntil == 0) {
            title = 'Jadwal muat gas hari ini';
            message = 'Hari ini dijadwalkan pengambilan pasokan tabung gas$notesPart. Pastikan tabung kosong sudah siap diberangkatkan dan koordinasikan dengan pekerja.';
          } else {
            title = 'Jadwal muat gas tertunda';
            message = 'Jadwal pengambilan gas dari ${AppFormatters.relativeDateHeader(scheduleDate)} belum tercatat selesai$notesPart. Silakan periksa status pasokan.';
          }

          items.add(NotificationItem(
            id: notifId,
            type: NotificationType.restock,
            title: title,
            message: message,
            dateTime: scheduleDate,
            isRead: _readIds.contains(notifId),
            supplierName: supplierName,
            actionText: 'Lihat jadwal',
          ));
        }
      } catch (e) {
        debugPrint('Error fetching restock schedules for notifications: $e');
      }

      // Sort: unread first, then by date descending
      items.sort((a, b) {
        if (a.isRead != b.isRead) {
          return a.isRead ? 1 : -1;
        }
        return b.dateTime.compareTo(a.dateTime);
      });

      notificationsNotifier.value = items;
      _recalculateUnreadCount();
    } finally {
      isLoadingNotifier.value = false;
    }
  }

  ReceivableModel? findReceivableById(String id) {
    try {
      return _rawReceivables.firstWhere((r) => r.id == id);
    } catch (_) {
      return null;
    }
  }
}
