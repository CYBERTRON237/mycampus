import 'package:hive/hive.dart';
import '../models/notification_model.dart';

abstract class NotificationLocalDataSource {
  Future<void> cacheNotifications(List<NotificationModel> notifications);
  Future<List<NotificationModel>> getCachedNotifications();
  Future<void> markAsRead(String notificationId);
  Future<void> deleteNotification(String notificationId);
  Future<void> deleteAllNotifications();
}

class NotificationLocalDataSourceImpl implements NotificationLocalDataSource {
  static const String _boxName = 'notifications';
  
  @override
  Future<void> cacheNotifications(List<NotificationModel> notifications) async {
    final box = await Hive.openBox<NotificationModel>(_boxName);
    await box.clear();
    await box.addAll(notifications);
  }

  @override
  Future<List<NotificationModel>> getCachedNotifications() async {
    final box = await Hive.openBox<NotificationModel>(_boxName);
    return box.values.toList();
  }

  @override
  Future<void> markAsRead(String notificationId) async {
    final box = await Hive.openBox<NotificationModel>(_boxName);
    final notification = box.values.firstWhere((n) => n.id == notificationId);
    await box.put(
      box.keys.firstWhere((key) => box.get(key)?.id == notificationId),
      notification.copyWithModel(isRead: true),
    );
  }

  @override
  Future<void> deleteNotification(String notificationId) async {
    final box = await Hive.openBox<NotificationModel>(_boxName);
    final key = box.keys.firstWhere((key) => box.get(key)?.id == notificationId, orElse: () => -1);
    if (key != -1) {
      await box.delete(key);
    }
  }

  @override
  Future<void> deleteAllNotifications() async {
    final box = await Hive.openBox<NotificationModel>(_boxName);
    await box.clear();
  }
}
