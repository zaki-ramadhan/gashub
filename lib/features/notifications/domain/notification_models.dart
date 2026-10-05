import 'package:flutter/material.dart';

enum NotificationType {
  debt,
  restock,
}

enum NotificationTimeGroup {
  today,
  upcoming,
  past,
}

class NotificationItem {
  final String id;
  final NotificationType type;
  final String title;
  final String message;
  final DateTime dateTime;
  final bool isRead;
  final int? amount;
  final String? customerName;
  final String? receivableId;
  final String? supplierName;
  final String actionText;

  const NotificationItem({
    required this.id,
    required this.type,
    required this.title,
    required this.message,
    required this.dateTime,
    this.isRead = false,
    this.amount,
    this.customerName,
    this.receivableId,
    this.supplierName,
    required this.actionText,
  });

  NotificationItem copyWith({
    bool? isRead,
  }) {
    return NotificationItem(
      id: id,
      type: type,
      title: title,
      message: message,
      dateTime: dateTime,
      isRead: isRead ?? this.isRead,
      amount: amount,
      customerName: customerName,
      receivableId: receivableId,
      supplierName: supplierName,
      actionText: actionText,
    );
  }

  NotificationTimeGroup get timeGroup {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final target = DateTime(dateTime.year, dateTime.month, dateTime.day);

    if (target.isAtSameMomentAs(today)) {
      return NotificationTimeGroup.today;
    } else if (target.isAfter(today)) {
      return NotificationTimeGroup.upcoming;
    } else {
      return NotificationTimeGroup.past;
    }
  }
}

class NotificationSettings {
  final TimeOfDay restockTime;
  final int debtDueDays;

  TimeOfDay get h0Time => restockTime;
  TimeOfDay get h1Time => restockTime;

  const NotificationSettings({
    this.restockTime = const TimeOfDay(hour: 7, minute: 0),
    this.debtDueDays = 7,
    TimeOfDay? h0Time,
    TimeOfDay? h1Time,
  });

  NotificationSettings copyWith({
    TimeOfDay? restockTime,
    TimeOfDay? h0Time,
    TimeOfDay? h1Time,
    int? debtDueDays,
  }) {
    return NotificationSettings(
      restockTime: restockTime ?? h0Time ?? this.restockTime,
      debtDueDays: debtDueDays ?? this.debtDueDays,
    );
  }
}
