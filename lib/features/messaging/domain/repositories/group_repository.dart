import 'package:dartz/dartz.dart' as dartz;
import '../models/group_model.dart';

abstract class GroupRepository {
  Future<dartz.Either<String, List<GroupModel>>> getUserGroups();
  Future<dartz.Either<String, GroupModel>> getGroup(int groupId);
  Future<dartz.Either<String, GroupModel>> createGroup(GroupModel group);
  Future<dartz.Either<String, void>> joinGroup(int groupId);
  Future<dartz.Either<String, void>> leaveGroup(int groupId);
  Future<dartz.Either<String, void>> updateGroup(GroupModel group);
  Future<dartz.Either<String, List<GroupModel>>> searchGroups(String query, {int limit = 20, int offset = 0});
  Future<dartz.Either<String, void>> addMembers(int groupId, List<int> userIds);
  Future<dartz.Either<String, void>> removeMember(int groupId, int memberId);
  Future<dartz.Either<String, List<GroupMemberModel>>> getGroupMembers(int groupId);
  Future<dartz.Either<String, List<GroupMemberModel>>> getPendingMembers(int groupId);
  Future<dartz.Either<String, void>> approveMember(int groupId, int memberId);
  Future<dartz.Either<String, void>> rejectMember(int groupId, int memberId);
  Future<dartz.Either<String, void>> updateMemberRole(int groupId, int memberId, GroupMemberRole role);
}
