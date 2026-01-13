import '../datasources/user_management_remote_datasource.dart';
import '../models/user_model.dart';

abstract class UserManagementRepository {
  Future<List<UserModel>> getUsers({UserFilters? filters});
  Future<UserModel> getUserById(int id);
  Future<UserManagementResult> createUser(Map<String, dynamic> userData);
  Future<UserManagementResult> updateUser(int id, Map<String, dynamic> userData);
  Future<UserManagementResult> deleteUser(int id);
  Future<List<UserRoleStats>> getUserStats();
  Future<UserManagementResult> assignRole(int userId, String role);
  Future<CurrentUserInfo> getCurrentUser();
  Future<List<UserModel>> searchUsers(Map<String, dynamic> searchParams);
}

class UserManagementRepositoryImpl implements UserManagementRepository {
  final UserManagementRemoteDataSource remoteDataSource;

  UserManagementRepositoryImpl({required this.remoteDataSource});

  @override
  Future<List<UserModel>> getUsers({UserFilters? filters}) async {
    print('DEBUG: Repository.getUsers - Début avec filtres: ${filters?.toJson()}');
    try {
      final result = await remoteDataSource.getUsers(filters: filters);
      print('DEBUG: Repository.getUsers - ${result.length} utilisateurs reçus');
      return result;
    } catch (e) {
      print('DEBUG: Repository.getUsers - ERREUR: $e');
      throw Exception('Failed to get users: $e');
    }
  }

  @override
  Future<UserModel> getUserById(int id) async {
    try {
      return await remoteDataSource.getUserById(id);
    } catch (e) {
      throw Exception('Failed to get user: $e');
    }
  }

  @override
  Future<UserManagementResult> createUser(Map<String, dynamic> userData) async {
    try {
      return await remoteDataSource.createUser(userData);
    } catch (e) {
      return UserManagementResult.error('Failed to create user: $e');
    }
  }

  @override
  Future<UserManagementResult> updateUser(int id, Map<String, dynamic> userData) async {
    try {
      return await remoteDataSource.updateUser(id, userData);
    } catch (e) {
      return UserManagementResult.error('Failed to update user: $e');
    }
  }

  @override
  Future<UserManagementResult> deleteUser(int id) async {
    try {
      return await remoteDataSource.deleteUser(id);
    } catch (e) {
      return UserManagementResult.error('Failed to delete user: $e');
    }
  }

  @override
  Future<List<UserRoleStats>> getUserStats() async {
    print('DEBUG: Repository.getUserStats - Début');
    try {
      final result = await remoteDataSource.getUserStats();
      print('DEBUG: Repository.getUserStats - ${result.length} statistiques reçues');
      return result;
    } catch (e) {
      print('DEBUG: Repository.getUserStats - ERREUR: $e');
      throw Exception('Failed to get user stats: $e');
    }
  }

  @override
  Future<UserManagementResult> assignRole(int userId, String role) async {
    try {
      return await remoteDataSource.assignRole(userId, role);
    } catch (e) {
      return UserManagementResult.error('Failed to assign role: $e');
    }
  }

  @override
  Future<CurrentUserInfo> getCurrentUser() async {
    print('DEBUG: Repository.getCurrentUser - Début');
    try {
      final result = await remoteDataSource.getCurrentUser();
      print('DEBUG: Repository.getCurrentUser - Utilisateur: ${result.user.fullName}');
      return result;
    } catch (e) {
      print('DEBUG: Repository.getCurrentUser - ERREUR: $e');
      throw Exception('Failed to get current user: $e');
    }
  }

  @override
  Future<List<UserModel>> searchUsers(Map<String, dynamic> searchParams) async {
    try {
      return await remoteDataSource.searchUsers(searchParams);
    } catch (e) {
      throw Exception('Failed to search users: $e');
    }
  }
}
