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
}

class NotificationItem {
  final String id;
  final String title;
  final String message;
  final DateTime dateTime;
  final NotificationType type;
  final bool isRead;

  NotificationItem({
    required this.id,
    required this.title,
    required this.message,
    required this.dateTime,
    required this.type,
    this.isRead = false,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'message': message,
        'dateTime': dateTime.toIso8601String(),
        'type': type.index,
        'isRead': isRead,
      };

  factory NotificationItem.fromJson(Map<String, dynamic> json) => NotificationItem(
        id: json['id'],
        title: json['title'],
        message: json['message'],
        dateTime: DateTime.parse(json['dateTime']),
        type: NotificationType.values[json['type']],
        isRead: json['isRead'] ?? false,
      );

  NotificationItem copyWith({bool? isRead}) => NotificationItem(
        id: id,
        title: title,
        message: message,
        dateTime: dateTime,
        type: type,
        isRead: isRead ?? this.isRead,
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
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final currentData = prefs.getStringList(_storageKey) ?? [];
    
    final newItem = NotificationItem(
      id: const Uuid().v4(),
      title: title,
      message: message,
      dateTime: DateTime.now(),
      type: type,
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
  }) async {
    final newItem = NotificationItem(
      id: const Uuid().v4(),
      title: title,
      message: message,
      dateTime: DateTime.now(),
      type: type,
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
}

final notificationProvider =
    NotifierProvider<NotificationNotifier, List<NotificationItem>>(NotificationNotifier.new);
