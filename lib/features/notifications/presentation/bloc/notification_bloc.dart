import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';
import '../../domain/repositories/notification_repository.dart';
import '../../data/models/notification_model.dart';

import 'notification_event.dart';
import 'notification_state.dart';

class NotificationBloc extends Bloc<NotificationEvent, NotificationState> {
  final NotificationRepository repository;
  StreamSubscription? _notificationSubscription;

  NotificationBloc({required this.repository}) : super(NotificationInitial()) {
    on<LoadNotifications>(_onLoadNotifications);
    on<MarkAsRead>(_onMarkAsRead);
    on<DeleteNotification>(_onDeleteNotification);
    on<DeleteAllNotifications>(_onDeleteAllNotifications);
    on<NewNotificationReceived>(_onNewNotificationReceived);
    on<ScheduleNotification>(_onScheduleNotification);

    // Subscribe to notification updates
    _notificationSubscription = repository.notificationsStream.listen(
      (notifications) {
        add(NewNotificationReceived(notifications));
      },
    );

    // Load initial notifications
    add(const LoadNotifications());
  }

  Future<void> _onLoadNotifications(
    LoadNotifications event,
    Emitter<NotificationState> emit,
  ) async {
    emit(NotificationLoadInProgress());
    try {
      final notifications = await repository.getNotifications();
      final unreadCount = await repository.getUnreadCount();
      emit(NotificationLoadSuccess(
        notifications: notifications,
        unreadCount: unreadCount,
      ));
    } catch (e) {
      emit(NotificationLoadFailure(error: e.toString()));
    }
  }

  Future<void> _onMarkAsRead(
    MarkAsRead event,
    Emitter<NotificationState> emit,
  ) async {
    if (state is NotificationLoadSuccess) {
      final currentState = state as NotificationLoadSuccess;
      await repository.markAsRead(event.notificationId);
      final unreadCount = await repository.getUnreadCount();
      
      final updatedNotifications = currentState.notifications.map((notification) {
        if (notification.id == event.notificationId) {
          return notification.copyWithModel(isRead: true);
        }
        return notification;
      }).toList();
      
      emit(NotificationLoadSuccess(
        notifications: updatedNotifications,
        unreadCount: unreadCount,
      ));
    }
  }

  Future<void> _onDeleteNotification(
    DeleteNotification event,
    Emitter<NotificationState> emit,
  ) async {
    if (state is NotificationLoadSuccess) {
      final currentState = state as NotificationLoadSuccess;
      await repository.deleteNotification(event.notificationId);
      final unreadCount = await repository.getUnreadCount();
      
      final updatedNotifications = currentState.notifications
          .where((n) => n.id != event.notificationId)
          .toList();
      
      emit(NotificationLoadSuccess(
        notifications: updatedNotifications,
        unreadCount: unreadCount,
      ));
    }
  }

  Future<void> _onDeleteAllNotifications(
    DeleteAllNotifications event,
    Emitter<NotificationState> emit,
  ) async {
    await repository.deleteAllNotifications();
    emit(const NotificationLoadSuccess(notifications: [], unreadCount: 0));
  }

  void _onNewNotificationReceived(
    NewNotificationReceived event,
    Emitter<NotificationState> emit,
  ) {
    if (state is NotificationLoadSuccess) {
      final unreadCount = event.notifications.where((n) => !n.isRead).length;
      emit(NotificationLoadSuccess(
        notifications: event.notifications,
        unreadCount: unreadCount,
      ));
    }
  }

  Future<void> _onScheduleNotification(
    ScheduleNotification event,
    Emitter<NotificationState> emit,
  ) async {
    try {
      await repository.scheduleNotification(
        title: event.title,
        body: event.body,
        scheduledDate: event.scheduledDate,
        payload: event.payload,
      );
      // Optionally emit a success state or event
    } catch (e) {
      // Handle error
      emit(const NotificationOperationFailure(error: 'Failed to schedule notification'));
    }
  }

  @override
  Future<void> close() {
    _notificationSubscription?.cancel();
    return super.close();
  }
}
