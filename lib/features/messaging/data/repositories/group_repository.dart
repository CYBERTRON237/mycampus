import 'package:dartz/dartz.dart' as dartz;
import '../../domain/repositories/group_repository.dart';
import '../../domain/models/group_model.dart';
import '../datasources/group_remote_datasource.dart';

class GroupRepositoryImpl implements GroupRepository {
  final GroupRemoteDataSource remoteDataSource;

  GroupRepositoryImpl({required this.remoteDataSource});

  @override
  Future<dartz.Either<String, List<GroupModel>>> getUserGroups() async {
    try {
      final groups = await remoteDataSource.getUserGroups();
      return dartz.Right(groups);
    } catch (e) {
      return dartz.Left(e.toString());
    }
  }

  @override
  Future<dartz.Either<String, GroupModel>> getGroup(int groupId) async {
    try {
      final group = await remoteDataSource.getGroup(groupId);
      return dartz.Right(group);
    } catch (e) {
      return dartz.Left(e.toString());
    }
  }

  @override
  Future<dartz.Either<String, GroupModel>> createGroup(GroupModel group) async {
    try {
      final createdGroup = await remoteDataSource.createGroup(group);
      return dartz.Right(createdGroup);
    } catch (e) {
      return dartz.Left(e.toString());
    }
  }

  @override
  Future<dartz.Either<String, void>> joinGroup(int groupId) async {
    try {
      await remoteDataSource.joinGroup(groupId);
      return dartz.Right(null);
    } catch (e) {
      return dartz.Left(e.toString());
    }
  }

  @override
  Future<dartz.Either<String, void>> leaveGroup(int groupId) async {
    try {
      await remoteDataSource.leaveGroup(groupId);
      return dartz.Right(null);
    } catch (e) {
      return dartz.Left(e.toString());
    }
  }

  @override
  Future<dartz.Either<String, void>> updateGroup(GroupModel group) async {
    try {
      await remoteDataSource.updateGroup(group);
      return dartz.Right(null);
    } catch (e) {
      return dartz.Left(e.toString());
    }
  }

  @override
  Future<dartz.Either<String, List<GroupModel>>> searchGroups(String query, {int limit = 20, int offset = 0}) async {
    try {
      final groups = await remoteDataSource.searchGroups(query, limit: limit, offset: offset);
      return dartz.Right(groups);
    } catch (e) {
      return dartz.Left(e.toString());
    }
  }

  @override
  Future<dartz.Either<String, void>> addMembers(int groupId, List<int> userIds) async {
    try {
      await remoteDataSource.addMembers(groupId, userIds);
      return dartz.Right(null);
    } catch (e) {
      return dartz.Left(e.toString());
    }
  }

  @override
  Future<dartz.Either<String, void>> removeMember(int groupId, int memberId) async {
    try {
      await remoteDataSource.removeMember(groupId, memberId);
      return dartz.Right(null);
    } catch (e) {
      return dartz.Left(e.toString());
    }
  }

  @override
  Future<dartz.Either<String, List<GroupMemberModel>>> getGroupMembers(int groupId) async {
    try {
      final members = await remoteDataSource.getGroupMembers(groupId);
      return dartz.Right(members);
    } catch (e) {
      return dartz.Left(e.toString());
    }
  }

  @override
  Future<dartz.Either<String, List<GroupMemberModel>>> getPendingMembers(int groupId) async {
    try {
      final members = await remoteDataSource.getPendingMembers(groupId);
      return dartz.Right(members);
    } catch (e) {
      return dartz.Left(e.toString());
    }
  }

  @override
  Future<dartz.Either<String, void>> approveMember(int groupId, int memberId) async {
    try {
      await remoteDataSource.approveMember(groupId, memberId);
      return dartz.Right(null);
    } catch (e) {
      return dartz.Left(e.toString());
    }
  }

  @override
  Future<dartz.Either<String, void>> rejectMember(int groupId, int memberId) async {
    try {
      await remoteDataSource.rejectMember(groupId, memberId);
      return dartz.Right(null);
    } catch (e) {
      return dartz.Left(e.toString());
    }
  }

  @override
  Future<dartz.Either<String, void>> updateMemberRole(int groupId, int memberId, GroupMemberRole role) async {
    try {
      await remoteDataSource.updateMemberRole(groupId, memberId, role);
      return dartz.Right(null);
    } catch (e) {
      return dartz.Left(e.toString());
    }
  }
}
