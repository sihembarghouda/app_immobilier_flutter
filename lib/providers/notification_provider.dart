import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class NotificationItem {
  final String id;
  final String title;
  final String message;
  final String type; // 'create', 'update', 'delete'
  final DateTime timestamp;
  bool isRead;

  NotificationItem({
    required this.id,
    required this.title,
    required this.message,
    required this.type,
    required this.timestamp,
    this.isRead = false,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'message': message,
        'type': type,
        'timestamp': timestamp.toIso8601String(),
        'isRead': isRead,
      };

  factory NotificationItem.fromJson(Map<String, dynamic> json) {
    return NotificationItem(
      id: json['id'],
      title: json['title'],
      message: json['message'],
      type: json['type'],
      timestamp: DateTime.parse(json['timestamp']),
      isRead: json['isRead'] ?? false,
    );
  }
}

class NotificationProvider with ChangeNotifier {
  List<NotificationItem> _notifications = [];
  static const String _storageKey = 'app_notifications';

  List<NotificationItem> get notifications => _notifications;

  int get unreadCount => _notifications.where((n) => !n.isRead).length;

  // Initialiser et charger les notifications depuis le stockage local
  Future<void> initialize() async {
    await _loadNotifications();
  }

  // Ajouter une notification
  void addNotification({
    required String title,
    required String message,
    required String type,
  }) {
    final notification = NotificationItem(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: title,
      message: message,
      type: type,
      timestamp: DateTime.now(),
    );

    _notifications.insert(0, notification);
    _saveNotifications();
    notifyListeners();
  }

  // Marquer comme lu
  void markAsRead(String id) {
    final index = _notifications.indexWhere((n) => n.id == id);
    if (index != -1) {
      _notifications[index].isRead = true;
      _saveNotifications();
      notifyListeners();
    }
  }

  // Marquer toutes comme lues
  void markAllAsRead() {
    for (var notification in _notifications) {
      notification.isRead = true;
    }
    _saveNotifications();
    notifyListeners();
  }

  // Supprimer une notification
  void deleteNotification(String id) {
    _notifications.removeWhere((n) => n.id == id);
    _saveNotifications();
    notifyListeners();
  }

  // Supprimer toutes les notifications
  void clearAll() {
    _notifications.clear();
    _saveNotifications();
    notifyListeners();
  }

  // Sauvegarder dans SharedPreferences
  Future<void> _saveNotifications() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonList = _notifications.map((n) => n.toJson()).toList();
      await prefs.setString(_storageKey, json.encode(jsonList));
    } catch (e) {
      print('Error saving notifications: $e');
    }
  }

  // Charger depuis SharedPreferences
  Future<void> _loadNotifications() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = prefs.getString(_storageKey);

      if (jsonString != null) {
        final jsonList = json.decode(jsonString) as List;
        _notifications =
            jsonList.map((json) => NotificationItem.fromJson(json)).toList();
        notifyListeners();
      }
    } catch (e) {
      print('Error loading notifications: $e');
      _notifications = [];
    }
  }

  // Obtenir les notifications non lues
  List<NotificationItem> get unreadNotifications =>
      _notifications.where((n) => !n.isRead).toList();

  // Obtenir les notifications par type
  List<NotificationItem> getNotificationsByType(String type) =>
      _notifications.where((n) => n.type == type).toList();
}
