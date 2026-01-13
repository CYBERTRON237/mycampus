import 'package:equatable/equatable.dart';
import '../../data/models/notification_model.dart';

abstract class NotificationState extends Equatable {
  const NotificationState();

  @override
  List<Object?> get props => [];
}

class NotificationInitial extends NotificationState {}

class NotificationLoadInProgress extends NotificationState {}

class NotificationLoadSuccess extends NotificationState {
  final List<NotificationModel> notifications;
  final int unreadCount;

  const NotificationLoadSuccess({
    required this.notifications,
    required this.unreadCount,
  });

  @override
  List<Object?> get props => [notifications, unreadCount];

  NotificationLoadSuccess copyWith({
    List<NotificationModel>? notifications,
    int? unreadCount,
  }) {
    return NotificationLoadSuccess(
      notifications: notifications ?? this.notifications,
      unreadCount: unreadCount ?? this.unreadCount,
    );
  }
}

class NotificationLoadFailure extends NotificationState {
  final String error;

  const NotificationLoadFailure({required this.error});

  @override
  List<Object?> get props => [error];
}

class NotificationOperationFailure extends NotificationState {
  final String error;

  const NotificationOperationFailure({required this.error});

  @override
  List<Object?> get props => [error];
}
