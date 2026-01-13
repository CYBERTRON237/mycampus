import 'package:flutter/material.dart';
import '../data/models/user_model.dart';
import '../data/repositories/user_management_repository.dart';

class UserManagementProvider extends ChangeNotifier {
  final UserManagementRepository repository;
  
  List<UserModel> _users = [];
  List<UserRoleStats> _userStats = [];
  CurrentUserInfo? _currentUser;
  UserFilters _filters = UserFilters();
  bool _isLoading = false;
  bool _isLoadingStats = false;
  String? _error;
  int _currentPage = 1;
  final int _totalPages = 1;

  UserManagementProvider({required this.repository}) {
    print('DEBUG: UserManagementProvider - Initialisation');
    _loadCurrentUser();
    _loadUsers();
    _loadUserStats();
    print('DEBUG: UserManagementProvider - Initialisation terminée');
  }

  // Getters
  List<UserModel> get users => _users;
  List<UserRoleStats> get userStats => _userStats;
  CurrentUserInfo? get currentUser => _currentUser;
  UserFilters get filters => _filters;
  bool get isLoading => _isLoading;
  bool get isLoadingStats => _isLoadingStats;
  String? get error => _error;
  int get currentPage => _currentPage;
  int get totalPages => _totalPages;

  // Check permissions
  bool get canCreateUsers => _currentUser != null && _currentUser!.highestLevel >= 80;
  bool get canManageRoles => _currentUser != null && _currentUser!.highestLevel >= 90;
  bool get canViewStats => _currentUser != null && _currentUser!.highestLevel >= 60;

  // Load current user
  Future<void> _loadCurrentUser() async {
    print('DEBUG: _loadCurrentUser - Début chargement utilisateur courant');
    try {
      _currentUser = await repository.getCurrentUser();
      print('DEBUG: _loadCurrentUser - Utilisateur chargé: ${_currentUser?.user.fullName ?? "NULL"}');
      notifyListeners();
    } catch (e) {
      print('DEBUG: _loadCurrentUser - ERREUR: $e');
      _error = e.toString();
      notifyListeners();
    }
  }

  // Load users with filters
  Future<void> _loadUsers() async {
    print('DEBUG: _loadUsers - Début chargement utilisateurs');
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      print('DEBUG: _loadUsers - Appel repository.getUsers avec filtres: ${filters.toJson()}');
      _users = await repository.getUsers(filters: _filters);
      print('DEBUG: _loadUsers - ${_users.length} utilisateurs chargés');
      _currentPage = _filters.page;
      notifyListeners();
    } catch (e) {
      print('DEBUG: _loadUsers - ERREUR: $e');
      _error = e.toString();
      notifyListeners();
    } finally {
      _isLoading = false;
      print('DEBUG: _loadUsers - Fin chargement (loading: $_isLoading)');
      notifyListeners();
    }
  }

  // Load user statistics
  Future<void> _loadUserStats() async {
    print('DEBUG: _loadUserStats - Début chargement statistiques');
    if (!canViewStats) {
      print('DEBUG: _loadUserStats - Permission refusée');
      return;
    }

    _isLoadingStats = true;
    notifyListeners();

    try {
      print('DEBUG: _loadUserStats - Appel repository.getUserStats');
      _userStats = await repository.getUserStats();
      print('DEBUG: _loadUserStats - ${_userStats.length} statistiques chargées');
      notifyListeners();
    } catch (e) {
      print('DEBUG: _loadUserStats - ERREUR: $e');
      _error = e.toString();
      notifyListeners();
    } finally {
      _isLoadingStats = false;
      print('DEBUG: _loadUserStats - Fin chargement statistiques');
      notifyListeners();
    }
  }

  // Refresh users list
  Future<void> refreshUsers() async {
    await _loadUsers();
  }

  // Update filters and reload
  void updateFilters(UserFilters newFilters) {
    _filters = newFilters.copyWith(page: 1); // Reset to first page
    _loadUsers();
  }

  // Search users
  void searchUsers(String query) {
    final newFilters = _filters.copyWith(search: query.isEmpty ? null : query, page: 1);
    updateFilters(newFilters);
  }

  // Filter by role
  void filterByRole(String? role) {
    final newFilters = _filters.copyWith(role: role?.isEmpty == true ? null : role, page: 1);
    updateFilters(newFilters);
  }

  // Filter by status
  void filterByStatus(String? status) {
    final newFilters = _filters.copyWith(status: status?.isEmpty == true ? null : status, page: 1);
    updateFilters(newFilters);
  }

  // Load next page
  void loadNextPage() {
    if (_currentPage < _totalPages && !_isLoading) {
      final newFilters = _filters.copyWith(page: _currentPage + 1);
      updateFilters(newFilters);
    }
  }

  // Load previous page
  void loadPreviousPage() {
    if (_currentPage > 1 && !_isLoading) {
      final newFilters = _filters.copyWith(page: _currentPage - 1);
      updateFilters(newFilters);
    }
  }

  // Create user
  Future<UserManagementResult> createUser(Map<String, dynamic> userData) async {
    if (!canCreateUsers) {
      return UserManagementResult.error('Permission denied');
    }

    try {
      final result = await repository.createUser(userData);
      if (result.success) {
        await refreshUsers();
      }
      return result;
    } catch (e) {
      return UserManagementResult.error('Failed to create user: $e');
    }
  }

  // Update user
  Future<UserManagementResult> updateUser(int userId, Map<String, dynamic> userData) async {
    try {
      final result = await repository.updateUser(userId, userData);
      if (result.success) {
        await refreshUsers();
      }
      return result;
    } catch (e) {
      return UserManagementResult.error('Failed to update user: $e');
    }
  }

  // Delete user
  Future<UserManagementResult> deleteUser(int userId) async {
    try {
      final result = await repository.deleteUser(userId);
      if (result.success) {
        await refreshUsers();
      }
      return result;
    } catch (e) {
      return UserManagementResult.error('Failed to delete user: $e');
    }
  }

  // Assign role to user
  Future<UserManagementResult> assignRole(int userId, String role) async {
    if (!canManageRoles) {
      return UserManagementResult.error('Permission denied');
    }

    try {
      final result = await repository.assignRole(userId, role);
      if (result.success) {
        await refreshUsers();
      }
      return result;
    } catch (e) {
      return UserManagementResult.error('Failed to assign role: $e');
    }
  }

  // Get user by ID
  Future<UserModel?> getUserById(int userId) async {
    try {
      return await repository.getUserById(userId);
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return null;
    }
  }

  // Search users with advanced parameters
  Future<List<UserModel>> searchUsersAdvanced(Map<String, dynamic> searchParams) async {
    try {
      return await repository.searchUsers(searchParams);
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return [];
    }
  }

  // Clear error
  void clearError() {
    _error = null;
    notifyListeners();
  }

  // Reset filters
  void resetFilters() {
    _filters = UserFilters();
    _loadUsers();
  }

  // Toggle user status (activate/deactivate)
  Future<UserManagementResult> toggleUserStatus(int userId, bool isActive) async {
    return await updateUser(userId, {'is_active': isActive ? 1 : 0});
  }

  // Get users by role
  List<UserModel> getUsersByRole(String role) {
    return _users.where((user) => user.primaryRole == role).toList();
  }

  // Get active users count
  int get activeUsersCount => _users.where((user) => user.isActive).length;

  // Get users by status
  List<UserModel> getUsersByStatus(String status) {
    return _users.where((user) => user.accountStatus == status).toList();
  }

  // Get online users
  List<UserModel> get onlineUsers => _users.where((user) => user.isOnline).toList();
}
