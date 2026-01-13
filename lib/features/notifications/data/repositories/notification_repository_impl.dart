import 'dart:async';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;

import '../../domain/repositories/notification_repository.dart';
import '../datasources/notification_local_data_source.dart';
import '../datasources/notification_remote_datasource.dart';
import '../models/notification_model.dart';

class NotificationRepositoryImpl implements NotificationRepository {
  final NotificationLocalDataSource localDataSource;
  final NotificationRemoteDataSource remoteDataSource;
  final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  final _controller = StreamController<List<NotificationModel>>.broadcast();
  
  NotificationRepositoryImpl({
    required this.localDataSource,
    required this.remoteDataSource,
  }) {
    _initNotifications();
  }

  Future<void> _initNotifications() async {
    tz.initializeTimeZones();
    
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );
    
    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );
    
    await _notificationsPlugin.initialize(
      initSettings,
      onDidReceiveNotificationResponse: (details) {
        // Handle notification tap
        if (details.payload != null) {
          // Handle payload if needed
        }
      },
    );
  }

  @override
  Future<List<NotificationModel>> getNotifications() async {
    try {
      // Try to fetch from remote first
      final remoteNotifications = await remoteDataSource.getNotifications();
      // Cache the results locally
      await localDataSource.cacheNotifications(remoteNotifications);
      return remoteNotifications;
    } catch (e) {
      // Fallback to local cache if remote fails
      return await localDataSource.getCachedNotifications();
    }
  }

  @override
  Stream<List<NotificationModel>> get notificationsStream async* {
    yield await localDataSource.getCachedNotifications();
    yield* _controller.stream;
  }

  @override
  Future<void> markAsRead(String notificationId) async {
    try {
      // Try remote first
      await remoteDataSource.markAsRead(notificationId);
      // Update local cache
      await localDataSource.markAsRead(notificationId);
    } catch (e) {
      // If remote fails, only update locally
      await localDataSource.markAsRead(notificationId);
    }
    _notifyListeners();
  }

  @override
  Future<void> deleteNotification(String notificationId) async {
    try {
      // Try remote first
      await remoteDataSource.deleteNotification(notificationId);
      // Update local cache
      await localDataSource.deleteNotification(notificationId);
    } catch (e) {
      // If remote fails, only update locally
      await localDataSource.deleteNotification(notificationId);
    }
    _notifyListeners();
  }

  @override
  Future<void> deleteAllNotifications() async {
    await localDataSource.deleteAllNotifications();
    await _notificationsPlugin.cancelAll();
    _notifyListeners();
  }

  @override
  Future<int> getUnreadCount() async {
    try {
      // Try remote first
      return await remoteDataSource.getUnreadCount();
    } catch (e) {
      // Fallback to local cache
      final notifications = await localDataSource.getCachedNotifications();
      return notifications.where((n) => !n.isRead).length;
    }
  }

  @override
  Future<void> scheduleNotification({
    required String title,
    required String body,
    DateTime? scheduledDate,
    String? payload,
  }) async {
    final id = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    
    final androidDetails = AndroidNotificationDetails(
      'mycampus_notifications',
      'MyCampus Notifications',
      channelDescription: 'Notifications from MyCampus app',
      importance: Importance.high,
      priority: Priority.high,
      showWhen: true,
      enableVibration: true,
      playSound: true,
      enableLights: true,
      ledOnMs: 1000,
      ledOffMs: 500,
    );
    
    final iosDetails = DarwinNotificationDetails();
    
    final notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );
    
    if (scheduledDate != null) {
      await _notificationsPlugin.zonedSchedule(
        id,
        title,
        body,
        tz.TZDateTime.from(scheduledDate, tz.local),
        notificationDetails,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        payload: payload,
      );
    } else {
      await _notificationsPlugin.show(
        id,
        title,
        body,
        notificationDetails,
        payload: payload,
      );
    }
  }

  @override
  Future<void> cancelAllScheduledNotifications() async {
    await _notificationsPlugin.cancelAll();
  }

  @override
  Future<void> initializeNotifications() async {
    // Initialization is done in the constructor
    // This method is kept for backward compatibility
  }

  void _notifyListeners() async {
    final notifications = await localDataSource.getCachedNotifications();
    _controller.add(notifications);
  }

  void dispose() {
    _controller.close();
  }
}
