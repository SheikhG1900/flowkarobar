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

  // New fields for localization and navigation
  final String? cashbookUuid;
  final String? entityId;
  final String? titleKey;
  final String? messageKey;
  final Map<String, String>? parameters;

  NotificationItem({
    required this.id,
    required this.title,
    required this.message,
    required this.dateTime,
    required this.type,
    this.isRead = false,
    this.isUrgent = false,
    this.cashbookUuid,
    this.entityId,
    this.titleKey,
    this.messageKey,
    this.parameters,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'message': message,
        'dateTime': dateTime.toIso8601String(),
        'type': type.index,
        'isRead': isRead,
        'isUrgent': isUrgent,
        'cashbookUuid': cashbookUuid,
        'entityId': entityId,
        'titleKey': titleKey,
        'messageKey': messageKey,
        'parameters': parameters,
      };

  factory NotificationItem.fromJson(Map<String, dynamic> json) => NotificationItem(
        id: json['id'],
        title: json['title'],
        message: json['message'],
        dateTime: DateTime.parse(json['dateTime']),
        type: NotificationType.values[json['type']],
        isRead: json['isRead'] == true,
        isUrgent: json['isUrgent'] == true,
        cashbookUuid: json['cashbookUuid'],
        entityId: json['entityId'],
        titleKey: json['titleKey'],
        messageKey: json['messageKey'],
        parameters: json['parameters'] != null
            ? Map<String, String>.from(json['parameters'])
            : null,
      );

  NotificationItem copyWith({
    bool? isRead,
    bool? isUrgent,
    String? title,
    String? message,
  }) =>
      NotificationItem(
        id: id,
        title: title ?? this.title,
        message: message ?? this.message,
        dateTime: dateTime,
        type: type,
        isRead: isRead ?? this.isRead,
        isUrgent: isUrgent ?? this.isUrgent,
        cashbookUuid: cashbookUuid,
        entityId: entityId,
        titleKey: titleKey,
        messageKey: messageKey,
        parameters: parameters,
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
    String? cashbookUuid,
    String? entityId,
    String? titleKey,
    String? messageKey,
    Map<String, String>? parameters,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final currentData = prefs.getStringList(_storageKey) ?? [];

    // Smart Deduplication: Remove old notification with same key and entity
    final List<String> updatedList = [];
    for (final itemJson in currentData) {
      try {
        final item = json.decode(itemJson);
        final itemMessageKey = item['messageKey'];
        final itemEntityId = item['entityId'];
        final itemCashbookUuid = item['cashbookUuid'];

        // If we have a key/entity match, skip adding this old item to the updated list
        bool isMatch = false;
        if (messageKey != null && itemMessageKey == messageKey) {
          if (entityId != null && itemEntityId == entityId) {
            isMatch = true;
          } else if (entityId == null && itemEntityId == null) {
            // For general notifications without entityId, match by cashbook if provided
            if (cashbookUuid != null && itemCashbookUuid == cashbookUuid) {
              isMatch = true;
            } else if (cashbookUuid == null && itemCashbookUuid == null) {
              isMatch = true;
            }
          }
        }

        if (!isMatch) {
          updatedList.add(itemJson);
        }
      } catch (e) {
        updatedList.add(itemJson);
      }
    }

    final newItem = NotificationItem(
      id: const Uuid().v4(),
      title: title,
      message: message,
      dateTime: DateTime.now(),
      type: type,
      isUrgent: isUrgent,
      cashbookUuid: cashbookUuid,
      entityId: entityId,
      titleKey: titleKey,
      messageKey: messageKey,
      parameters: parameters,
    );

    updatedList.insert(0, json.encode(newItem.toJson()));
    await prefs.setStringList(_storageKey, updatedList);
  }

  Future<void> _loadNotifications() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getStringList(_storageKey);
    if (data != null) {
      state = data
          .map((item) {
            try {
              return NotificationItem.fromJson(json.decode(item));
            } catch (e) {
              return null;
            }
          })
          .whereType<NotificationItem>()
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
    String? cashbookUuid,
    String? entityId,
    String? titleKey,
    String? messageKey,
    Map<String, String>? parameters,
  }) async {
    // Deduplicate in current state
    final existingIndex = state.indexWhere((n) {
      if (messageKey != null && n.messageKey == messageKey) {
        if (entityId != null && n.entityId == entityId) return true;
        if (entityId == null && n.entityId == null) {
          if (cashbookUuid != null && n.cashbookUuid == cashbookUuid) return true;
          if (cashbookUuid == null && n.cashbookUuid == null) return true;
        }
      }
      return false;
    });

    final newItem = NotificationItem(
      id: const Uuid().v4(),
      title: title,
      message: message,
      dateTime: DateTime.now(),
      type: type,
      isUrgent: isUrgent,
      cashbookUuid: cashbookUuid,
      entityId: entityId,
      titleKey: titleKey,
      messageKey: messageKey,
      parameters: parameters,
    );

    if (existingIndex != -1) {
      final newState = List<NotificationItem>.from(state);
      newState.removeAt(existingIndex);
      newState.insert(0, newItem);
      state = newState;
    } else {
      state = [newItem, ...state];
    }
    
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
    NotifierProvider<NotificationNotifier, List<NotificationItem>>(
        NotificationNotifier.new);
