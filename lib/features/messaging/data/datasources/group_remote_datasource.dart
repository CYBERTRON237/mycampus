import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../../config/api_config.dart';
import '../../domain/models/group_model.dart';
import '../../../../features/auth/services/auth_service.dart';

abstract class GroupRemoteDataSource {
  Future<List<GroupModel>> getUserGroups();
  Future<GroupModel> getGroup(int groupId);
  Future<GroupModel> createGroup(GroupModel group);
  Future<void> joinGroup(int groupId);
  Future<void> leaveGroup(int groupId);
  Future<void> updateGroup(GroupModel group);
  Future<List<GroupModel>> searchGroups(String query, {int limit = 20, int offset = 0});
  Future<void> addMembers(int groupId, List<int> userIds);
  Future<void> removeMember(int groupId, int memberId);
  Future<List<GroupMemberModel>> getGroupMembers(int groupId);
  Future<List<GroupMemberModel>> getPendingMembers(int groupId);
  Future<void> approveMember(int groupId, int memberId);
  Future<void> rejectMember(int groupId, int memberId);
  Future<void> updateMemberRole(int groupId, int memberId, GroupMemberRole role);
}

class GroupRemoteDataSourceImpl implements GroupRemoteDataSource {
  final http.Client client;
  final AuthService authService;

  GroupRemoteDataSourceImpl({required this.client, required this.authService});

  @override
  Future<List<GroupModel>> getUserGroups() async {
    final currentUser = await authService.getCurrentUser();
    if (currentUser == null) throw Exception('Utilisateur non authentifié');

    final url = Uri.parse('${ApiConfig.baseUrl}/api/groups/my');
    final response = await client.get(
      url,
      headers: {
        'Content-Type': 'application/json',
        'X-User-Id': currentUser.id.toString(),
      },
    ).timeout(const Duration(seconds: 10));

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);
      final List<dynamic> groupsJson = data['groups'];
      return groupsJson.map((json) => GroupModel.fromJson(json)).toList();
    } else {
      throw Exception('Erreur lors de la récupération des groupes: ${response.statusCode}');
    }
  }

  @override
  Future<GroupModel> getGroup(int groupId) async {
    final currentUser = await authService.getCurrentUser();
    if (currentUser == null) throw Exception('Utilisateur non authentifié');

    final url = Uri.parse('${ApiConfig.baseUrl}/api/groups/$groupId');
    final response = await client.get(
      url,
      headers: {
        'Content-Type': 'application/json',
        'X-User-Id': currentUser.id.toString(),
      },
    ).timeout(const Duration(seconds: 10));

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);
      return GroupModel.fromJson(data['group']);
    } else {
      throw Exception('Erreur lors de la récupération du groupe: ${response.statusCode}');
    }
  }

  @override
  Future<GroupModel> createGroup(GroupModel group) async {
    final currentUser = await authService.getCurrentUser();
    if (currentUser == null) throw Exception('Utilisateur non authentifié');

    final url = Uri.parse('${ApiConfig.baseUrl}/api/groups/create');
    final response = await client.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'X-User-Id': currentUser.id.toString(),
      },
      body: json.encode({
        'name': group.name,
        'description': group.description,
        'group_type': group.groupType.name,
        'visibility': group.visibility.name,
        'avatar_url': group.avatarUrl,
        'cover_image_url': group.coverImageUrl,
        'rules': group.rules,
        'max_members': group.maxMembers,
        'join_approval_required': group.joinApprovalRequired,
        'allow_member_posts': group.allowMemberPosts,
        'allow_member_invites': group.allowMemberInvites,
        'institution_id': group.institutionId,
        'program_id': group.programId,
        'department_id': group.departmentId,
        'created_by': currentUser.id,
      }),
    ).timeout(const Duration(seconds: 10));

    if (response.statusCode == 201) {
      final Map<String, dynamic> data = json.decode(response.body);
      final groupId = data['group_id'];
      return await getGroup(groupId);
    } else {
      final error = json.decode(response.body);
      throw Exception(error['error'] ?? 'Erreur lors de la création du groupe');
    }
  }

  @override
  Future<void> joinGroup(int groupId) async {
    final currentUser = await authService.getCurrentUser();
    if (currentUser == null) throw Exception('Utilisateur non authentifié');

    final url = Uri.parse('${ApiConfig.baseUrl}/api/groups/$groupId/join');
    final response = await client.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'X-User-Id': currentUser.id.toString(),
      },
    ).timeout(const Duration(seconds: 10));

    if (response.statusCode != 201) {
      final error = json.decode(response.body);
      throw Exception(error['error'] ?? 'Erreur lors de l\'adhésion au groupe');
    }
  }

  @override
  Future<void> leaveGroup(int groupId) async {
    final currentUser = await authService.getCurrentUser();
    if (currentUser == null) throw Exception('Utilisateur non authentifié');

    final url = Uri.parse('${ApiConfig.baseUrl}/api/groups/$groupId/leave');
    final response = await client.delete(
      url,
      headers: {
        'Content-Type': 'application/json',
        'X-User-Id': currentUser.id.toString(),
      },
    ).timeout(const Duration(seconds: 10));

    if (response.statusCode != 200) {
      final error = json.decode(response.body);
      throw Exception(error['error'] ?? 'Erreur lors du départ du groupe');
    }
  }

  @override
  Future<void> updateGroup(GroupModel group) async {
    final currentUser = await authService.getCurrentUser();
    if (currentUser == null) throw Exception('Utilisateur non authentifié');

    final url = Uri.parse('${ApiConfig.baseUrl}/api/groups/${group.id}');
    final response = await client.put(
      url,
      headers: {
        'Content-Type': 'application/json',
        'X-User-Id': currentUser.id.toString(),
      },
      body: json.encode({
        'name': group.name,
        'description': group.description,
        'avatar_url': group.avatarUrl,
        'cover_image_url': group.coverImageUrl,
        'rules': group.rules,
        'max_members': group.maxMembers,
        'join_approval_required': group.joinApprovalRequired,
        'allow_member_posts': group.allowMemberPosts,
        'allow_member_invites': group.allowMemberInvites,
      }),
    ).timeout(const Duration(seconds: 10));

    if (response.statusCode != 200) {
      final error = json.decode(response.body);
      throw Exception(error['error'] ?? 'Erreur lors de la mise à jour du groupe');
    }
  }

  @override
  Future<List<GroupModel>> searchGroups(String query, {int limit = 20, int offset = 0}) async {
    final currentUser = await authService.getCurrentUser();
    if (currentUser == null) throw Exception('Utilisateur non authentifié');

    final url = Uri.parse('${ApiConfig.baseUrl}/api/groups/search');
    final response = await client.get(
      url.replace(queryParameters: {
        'q': query,
        'limit': limit.toString(),
        'offset': offset.toString(),
      }),
      headers: {
        'Content-Type': 'application/json',
        'X-User-Id': currentUser.id.toString(),
      },
    ).timeout(const Duration(seconds: 10));

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);
      final List<dynamic> groupsJson = data['groups'];
      return groupsJson.map((json) => GroupModel.fromJson(json)).toList();
    } else {
      throw Exception('Erreur lors de la recherche de groupes: ${response.statusCode}');
    }
  }

  @override
  Future<void> addMembers(int groupId, List<int> userIds) async {
    final currentUser = await authService.getCurrentUser();
    if (currentUser == null) throw Exception('Utilisateur non authentifié');

    final url = Uri.parse('${ApiConfig.baseUrl}/api/groups/$groupId/members');
    final response = await client.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'X-User-Id': currentUser.id.toString(),
      },
      body: json.encode({
        'user_ids': userIds,
      }),
    ).timeout(const Duration(seconds: 10));

    if (response.statusCode != 200) {
      final error = json.decode(response.body);
      throw Exception(error['error'] ?? 'Erreur lors de l\'ajout des membres');
    }
  }

  @override
  Future<void> removeMember(int groupId, int memberId) async {
    final currentUser = await authService.getCurrentUser();
    if (currentUser == null) throw Exception('Utilisateur non authentifié');

    final url = Uri.parse('${ApiConfig.baseUrl}/api/groups/$groupId/members/$memberId');
    final response = await client.delete(
      url,
      headers: {
        'Content-Type': 'application/json',
        'X-User-Id': currentUser.id.toString(),
      },
    ).timeout(const Duration(seconds: 10));

    if (response.statusCode != 200) {
      final error = json.decode(response.body);
      throw Exception(error['error'] ?? 'Erreur lors de la suppression du membre');
    }
  }

  @override
  Future<List<GroupMemberModel>> getGroupMembers(int groupId) async {
    final currentUser = await authService.getCurrentUser();
    if (currentUser == null) throw Exception('Utilisateur non authentifié');

    final url = Uri.parse('${ApiConfig.baseUrl}/api/groups/$groupId/members');
    final response = await client.get(
      url,
      headers: {
        'Content-Type': 'application/json',
        'X-User-Id': currentUser.id.toString(),
      },
    ).timeout(const Duration(seconds: 10));

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);
      final List<dynamic> membersJson = data['members'];
      return membersJson.map((json) => GroupMemberModel.fromJson(json)).toList();
    } else {
      throw Exception('Erreur lors de la récupération des membres: ${response.statusCode}');
    }
  }

  @override
  Future<List<GroupMemberModel>> getPendingMembers(int groupId) async {
    final currentUser = await authService.getCurrentUser();
    if (currentUser == null) throw Exception('Utilisateur non authentifié');

    final url = Uri.parse('${ApiConfig.baseUrl}/api/groups/$groupId/members/pending');
    final response = await client.get(
      url,
      headers: {
        'Content-Type': 'application/json',
        'X-User-Id': currentUser.id.toString(),
      },
    ).timeout(const Duration(seconds: 10));

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);
      final List<dynamic> membersJson = data['members'];
      return membersJson.map((json) => GroupMemberModel.fromJson(json)).toList();
    } else {
      throw Exception('Erreur lors de la récupération des membres en attente: ${response.statusCode}');
    }
  }

  @override
  Future<void> approveMember(int groupId, int memberId) async {
    final currentUser = await authService.getCurrentUser();
    if (currentUser == null) throw Exception('Utilisateur non authentifié');

    final url = Uri.parse('${ApiConfig.baseUrl}/api/groups/$groupId/members/$memberId/approve');
    final response = await client.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'X-User-Id': currentUser.id.toString(),
      },
    ).timeout(const Duration(seconds: 10));

    if (response.statusCode != 200) {
      final error = json.decode(response.body);
      throw Exception(error['error'] ?? 'Erreur lors de l\'approbation du membre');
    }
  }

  @override
  Future<void> rejectMember(int groupId, int memberId) async {
    final currentUser = await authService.getCurrentUser();
    if (currentUser == null) throw Exception('Utilisateur non authentifié');

    final url = Uri.parse('${ApiConfig.baseUrl}/api/groups/$groupId/members/$memberId/reject');
    final response = await client.delete(
      url,
      headers: {
        'Content-Type': 'application/json',
        'X-User-Id': currentUser.id.toString(),
      },
    ).timeout(const Duration(seconds: 10));

    if (response.statusCode != 200) {
      final error = json.decode(response.body);
      throw Exception(error['error'] ?? 'Erreur lors du rejet du membre');
    }
  }

  @override
  Future<void> updateMemberRole(int groupId, int memberId, GroupMemberRole role) async {
    final currentUser = await authService.getCurrentUser();
    if (currentUser == null) throw Exception('Utilisateur non authentifié');

    final url = Uri.parse('${ApiConfig.baseUrl}/api/groups/$groupId/members/$memberId');
    final response = await client.put(
      url,
      headers: {
        'Content-Type': 'application/json',
        'X-User-Id': currentUser.id.toString(),
      },
      body: json.encode({
        'role': role.name,
      }),
    ).timeout(const Duration(seconds: 10));

    if (response.statusCode != 200) {
      final error = json.decode(response.body);
      throw Exception(error['error'] ?? 'Erreur lors de la mise à jour du rôle');
    }
  }
}
