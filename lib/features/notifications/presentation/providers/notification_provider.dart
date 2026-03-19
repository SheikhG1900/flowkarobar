import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:uuid/uuid.dart';

enum NotificationType {
  receivable,
  payable,
  milestone,
  backup,
  reminder,
  sync,
  creditCard,
}

class NotificationItem {
  final String id;
  final String title;
  final String message;
  final DateTime dateTime;
  final NotificationType type;
  final bool isRead;
  final bool isUrgent;

  NotificationItem({
    required this.id,
    required this.title,
    required this.message,
    required this.dateTime,
    required this.type,
    this.isRead = false,
    this.isUrgent = false,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'message': message,
        'dateTime': dateTime.toIso8601String(),
        'type': type.index,
        'isRead': isRead,
        'isUrgent': isUrgent,
      };

  factory NotificationItem.fromJson(Map<String, dynamic> json) => NotificationItem(
        id: json['id'],
        title: json['title'],
        message: json['message'],
        dateTime: DateTime.parse(json['dateTime']),
        type: NotificationType.values[json['type']],
        isRead: json['isRead'] == true,
        isUrgent: json['isUrgent'] == true,
      );

  NotificationItem copyWith({bool? isRead, bool? isUrgent}) => NotificationItem(
        id: id,
        title: title,
        message: message,
        dateTime: dateTime,
        type: type,
        isRead: isRead ?? this.isRead,
        isUrgent: isUrgent ?? this.isUrgent,
      );
}

class NotificationNotifier extends Notifier<List<NotificationItem>> {
  @override
  List<NotificationItem> build() {
    _loadNotifications();
    return [];
  }

  static const _storageKey = 'local_notifications';

  /// Add a notification without using Riverpod state (for background tasks)
  static Future<void> addNotificationStatic({
    required String title,
    required String message,
    required NotificationType type,
    bool isUrgent = false,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final currentData = prefs.getStringList(_storageKey) ?? [];

    // Check for duplicates in stored data
    final isDuplicate = currentData.any((itemJson) {
      try {
        final item = json.decode(itemJson);
        final itemTime = DateTime.parse(item['dateTime']);
        return item['title'] == title &&
            item['message'] == message &&
            item['type'] == type.index &&
            DateTime.now().difference(itemTime).inMinutes < 1; // Only skip if within 1 minute
      } catch (e) {
        return false;
      }
    });

    if (isDuplicate) return;

    final newItem = NotificationItem(
      id: const Uuid().v4(),
      title: title,
      message: message,
      dateTime: DateTime.now(),
      type: type,
      isUrgent: isUrgent,
    );

    final updatedData = [json.encode(newItem.toJson()), ...currentData];
    await prefs.setStringList(_storageKey, updatedData);
  }

  Future<void> _loadNotifications() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getStringList(_storageKey);
    if (data != null) {
      state = data
          .map((item) => NotificationItem.fromJson(json.decode(item)))
          .toList()
        ..sort((a, b) => b.dateTime.compareTo(a.dateTime));
    }
  }

  Future<void> _saveNotifications() async {
    final prefs = await SharedPreferences.getInstance();
    final data = state.map((item) => json.encode(item.toJson())).toList();
    await prefs.setStringList(_storageKey, data);
  }

  Future<void> addNotification({
    required String title,
    required String message,
    required NotificationType type,
    bool isUrgent = false,
  }) async {
    // Check if a similar notification already exists to avoid duplicates
    final isDuplicate = state.any((n) =>
        n.title == title &&
        n.message == message &&
        n.type == type &&
        DateTime.now().difference(n.dateTime).inMinutes < 1);

    if (isDuplicate) return;

    final newItem = NotificationItem(
      id: const Uuid().v4(),
      title: title,
      message: message,
      dateTime: DateTime.now(),
      type: type,
      isUrgent: isUrgent,
    );
    state = [newItem, ...state];
    await _saveNotifications();
  }

  Future<void> markAsRead(String id) async {
    state = [
      for (final item in state)
        if (item.id == id) item.copyWith(isRead: true) else item
    ];
    await _saveNotifications();
  }

  Future<void> markAllAsRead() async {
    state = [for (final item in state) item.copyWith(isRead: true)];
    await _saveNotifications();
  }

  Future<void> clearAll() async {
    state = [];
    await _saveNotifications();
  }

  Future<void> refresh() async {
    await _loadNotifications();
  }
}

final notificationProvider =
    NotifierProvider<NotificationNotifier, List<NotificationItem>>(NotificationNotifier.new);
