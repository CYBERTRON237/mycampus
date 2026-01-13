import 'package:flutter/foundation.dart';
import 'package:mycampus/features/notifications/domain/entities/notification.dart';
import 'package:mycampus/features/notifications/data/datasources/notification_remote_datasource.dart';
import 'package:http/http.dart' as http;

class NotificationProvider extends ChangeNotifier {
  final NotificationRemoteDataSource _remoteDataSource;
  
  // State
  List<Notification> _notifications = [];
  Notification? _currentNotification;
  bool _isLoading = false;
  String? _error;
  int _unreadCount = 0;
  
  // Filters
  String? _selectedCategory;
  String? _selectedType;
  bool? _isReadFilter;
  int _currentPage = 1;
  int _pageSize = 20;
  bool _hasMore = true;

  NotificationProvider() : _remoteDataSource = NotificationRemoteDataSourceImpl(client: http.Client()) {
    // Don't auto-load in constructor to avoid issues during provider initialization
    print('DEBUG: NotificationProvider initialized');
  }

  // Getters
  List<Notification> get notifications => _notifications;
  Notification? get currentNotification => _currentNotification;
  bool get isLoading => _isLoading;
  String? get error => _error;
  int get unreadCount => _unreadCount;
  
  String? get selectedCategory => _selectedCategory;
  String? get selectedType => _selectedType;
  bool? get isReadFilter => _isReadFilter;
  int get currentPage => _currentPage;
  int get pageSize => _pageSize;
  bool get hasMore => _hasMore;

  // Loading methods
  Future<void> loadNotifications({bool refresh = false}) async {
    print('DEBUG: NotificationProvider.loadNotifications - Début, refresh: $refresh');
    
    if (refresh) {
      _currentPage = 1;
      _hasMore = true;
      _notifications.clear();
    }
    
    if (!_hasMore) return;
    
    _setLoading(true);
    _clearError();

    try {
      final result = await _remoteDataSource.getNotifications(
        page: _currentPage,
        limit: _pageSize,
        isRead: _isReadFilter?.toString(),
        category: _selectedCategory,
        type: _selectedType,
      );
      
      print('DEBUG: NotificationProvider.loadNotifications - Succès: ${result.length} notifications');
      
      if (_currentPage == 1) {
        _notifications = result;
      } else {
        _notifications.addAll(result);
      }
      
      _hasMore = result.length >= _pageSize;
      if (_hasMore) {
        _currentPage++;
      }
      
      notifyListeners();
    } catch (e) {
      print('DEBUG: NotificationProvider.loadNotifications - Erreur: $e');
      _setError('Exception: $e');
    } finally {
      _setLoading(false);
    }
  }

  Future<void> loadNotificationById(String id) async {
    print('DEBUG: NotificationProvider.loadNotificationById - Début pour ID: $id');
    _setLoading(true);
    _clearError();

    try {
      final result = await _remoteDataSource.getNotificationById(id);
      print('DEBUG: NotificationProvider.loadNotificationById - Succès');
      _currentNotification = result;
      notifyListeners();
    } catch (e) {
      print('DEBUG: NotificationProvider.loadNotificationById - Erreur: $e');
      _setError('Exception: $e');
    } finally {
      _setLoading(false);
    }
  }

  Future<void> markAsRead(String id) async {
    print('DEBUG: NotificationProvider.markAsRead - Début pour ID: $id');
    
    try {
      final success = await _remoteDataSource.markAsRead(id);
      if (success) {
        // Update local notification
        final index = _notifications.indexWhere((n) => n.id == id);
        if (index != -1) {
          final notification = _notifications[index];
          _notifications[index] = notification.copyWith(isRead: true, readAt: DateTime.now());
          notifyListeners();
        }
        
        // Update unread count
        if (_unreadCount > 0) {
          _unreadCount--;
          notifyListeners();
        }
      }
    } catch (e) {
      print('DEBUG: NotificationProvider.markAsRead - Erreur: $e');
      _setError('Erreur lors du marquage comme lu: $e');
    }
  }

  Future<void> markAllAsRead() async {
    print('DEBUG: NotificationProvider.markAllAsRead - Début');
    
    try {
      final updatedCount = await _remoteDataSource.markAllAsRead();
      print('DEBUG: NotificationProvider.markAllAsRead - $updatedCount notifications marquées');
      
      // Update local notifications
      _notifications = _notifications.map((n) => n.copyWith(isRead: true, readAt: DateTime.now())).toList();
      _unreadCount = 0;
      notifyListeners();
    } catch (e) {
      print('DEBUG: NotificationProvider.markAllAsRead - Erreur: $e');
      _setError('Erreur lors du marquage de toutes comme lues: $e');
    }
  }

  Future<void> deleteNotification(String id) async {
    print('DEBUG: NotificationProvider.deleteNotification - Début pour ID: $id');
    
    try {
      final success = await _remoteDataSource.deleteNotification(id);
      if (success) {
        _notifications.removeWhere((n) => n.id == id);
        if (_currentNotification?.id == id) {
          _currentNotification = null;
        }
        
        // Update unread count if it was unread
        final deletedNotification = _notifications.firstWhere((n) => n.id == id, orElse: () => _notifications[0]);
        if (!deletedNotification.isRead && _unreadCount > 0) {
          _unreadCount--;
        }
        
        notifyListeners();
      }
    } catch (e) {
      print('DEBUG: NotificationProvider.deleteNotification - Erreur: $e');
      _setError('Erreur lors de la suppression: $e');
    }
  }

  Future<void> loadUnreadCount() async {
    print('DEBUG: NotificationProvider.loadUnreadCount - Début');
    
    try {
      final count = await _remoteDataSource.getUnreadCount();
      print('DEBUG: NotificationProvider.loadUnreadCount - Count: $count');
      
      if (_unreadCount != count) {
        _unreadCount = count;
        notifyListeners();
      }
    } catch (e) {
      print('DEBUG: NotificationProvider.loadUnreadCount - Erreur: $e');
    }
  }

  // Filter methods
  void filterByCategory(String? category) {
    print('DEBUG: NotificationProvider.filterByCategory - Category: $category');
    _selectedCategory = category;
    loadNotifications(refresh: true);
  }

  void filterByType(String? type) {
    print('DEBUG: NotificationProvider.filterByType - Type: $type');
    _selectedType = type;
    loadNotifications(refresh: true);
  }

  void filterByReadStatus(bool? isRead) {
    print('DEBUG: NotificationProvider.filterByReadStatus - IsRead: $isRead');
    _isReadFilter = isRead;
    loadNotifications(refresh: true);
  }

  void clearFilters() {
    print('DEBUG: NotificationProvider.clearFilters - Réinitialisation des filtres');
    _selectedCategory = null;
    _selectedType = null;
    _isReadFilter = null;
    loadNotifications(refresh: true);
  }

  void refresh() {
    print('DEBUG: NotificationProvider.refresh - Actualisation');
    loadNotifications(refresh: true);
    loadUnreadCount();
  }

  void loadMore() {
    if (!_isLoading && _hasMore) {
      loadNotifications();
    }
  }

  // Private methods
  void _setLoading(bool loading) {
    if (_isLoading != loading) {
      _isLoading = loading;
      notifyListeners();
    }
  }

  void _setError(String error) {
    _error = error;
    notifyListeners();
  }

  void _clearError() {
    if (_error != null) {
      _error = null;
      notifyListeners();
    }
  }

  // Utility methods
  List<Notification> get unreadNotifications => _notifications.where((n) => !n.isRead).toList();
  
  List<Notification> get notificationsByPriority {
    final urgent = _notifications.where((n) => n.priority == NotificationPriority.urgent).toList();
    final high = _notifications.where((n) => n.priority == NotificationPriority.high).toList();
    final normal = _notifications.where((n) => n.priority == NotificationPriority.normal).toList();
    final low = _notifications.where((n) => n.priority == NotificationPriority.low).toList();
    
    return [...urgent, ...high, ...normal, ...low];
  }

  Notification? get latestNotification {
    if (_notifications.isEmpty) return null;
    return _notifications.reduce((a, b) => a.createdAt.isAfter(b.createdAt) ? a : b);
  }
}
