import '../../data/models/notification_model.dart';

abstract class NotificationRepository {
  Future<List<NotificationModel>> getNotifications();
  Stream<List<NotificationModel>> get notificationsStream;
  Future<void> markAsRead(String notificationId);
  Future<void> deleteNotification(String notificationId);
  Future<void> deleteAllNotifications();
  Future<int> getUnreadCount();
  Future<void> scheduleNotification({
    required String title,
    required String body,
    DateTime? scheduledDate,
    String? payload,
  });
  Future<void> cancelAllScheduledNotifications();
  Future<void> initializeNotifications();
}
