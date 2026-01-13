import 'package:equatable/equatable.dart';
import '../../data/models/notification_model.dart';

abstract class NotificationEvent extends Equatable {
  const NotificationEvent();

  @override
  List<Object?> get props => [];
}

class LoadNotifications extends NotificationEvent {
  const LoadNotifications();
}

class MarkAsRead extends NotificationEvent {
  final String notificationId;

  const MarkAsRead(this.notificationId);

  @override
  List<Object?> get props => [notificationId];
}

class DeleteNotification extends NotificationEvent {
  final String notificationId;

  const DeleteNotification(this.notificationId);

  @override
  List<Object?> get props => [notificationId];
}

class DeleteAllNotifications extends NotificationEvent {
  const DeleteAllNotifications();
}

class NewNotificationReceived extends NotificationEvent {
  final List<NotificationModel> notifications;

  const NewNotificationReceived(this.notifications);

  @override
  List<Object?> get props => [notifications];
}

class ScheduleNotification extends NotificationEvent {
  final String title;
  final String body;
  final DateTime? scheduledDate;
  final String? payload;

  const ScheduleNotification({
    required this.title,
    required this.body,
    this.scheduledDate,
    this.payload,
  });

  @override
  List<Object?> get props => [title, body, scheduledDate, payload];
}
