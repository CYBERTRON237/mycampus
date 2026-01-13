import 'package:equatable/equatable.dart';

enum GroupType {
  program,
  filiere,
  level,
  year,
  club,
  association,
  project,
  sport,
  cultural,
  academic,
  department,
  faculty,
  national,
  inter_university,
  custom,
  chat,
}

enum GroupVisibility {
  public,
  private,
  secret,
  restricted,
  official,
}

enum GroupMemberRole {
  admin,
  moderator,
  leader,
  member,
}

enum GroupMemberStatus {
  active,
  pending,
  banned,
  left,
}

class GroupModel extends Equatable {
  final int? id;
  final String? uuid;
  final int? institutionId;
  final int? programId;
  final int? departmentId;
  final int? parentGroupId;
  final GroupType groupType;
  final GroupVisibility visibility;
  final String name;
  final String slug;
  final String? description;
  final String? coverImageUrl;
  final String? iconUrl;
  final String? avatarUrl;
  final String? academicLevel;
  final int? academicYearId;
  final bool isOfficial;
  final bool isVerified;
  final bool isNational;
  final int? maxMembers;
  final int currentMembersCount;
  final bool joinApprovalRequired;
  final bool allowMemberPosts;
  final bool allowMemberInvites;
  final String? rules;
  final Map<String, dynamic>? tags;
  final Map<String, dynamic>? settings;
  final int? createdBy;
  final DateTime createdAt;
  final DateTime updatedAt;
  final int unreadCount;

  const GroupModel({
    this.id,
    this.uuid,
    this.institutionId,
    this.programId,
    this.departmentId,
    this.parentGroupId,
    required this.groupType,
    required this.visibility,
    required this.name,
    required this.slug,
    this.description,
    this.coverImageUrl,
    this.iconUrl,
    this.avatarUrl,
    this.academicLevel,
    this.academicYearId,
    this.isOfficial = false,
    this.isVerified = false,
    this.isNational = false,
    this.maxMembers,
    this.currentMembersCount = 0,
    this.joinApprovalRequired = false,
    this.allowMemberPosts = true,
    this.allowMemberInvites = false,
    this.rules,
    this.tags,
    this.settings,
    this.createdBy,
    required this.createdAt,
    required this.updatedAt,
    this.unreadCount = 0,
  });

  factory GroupModel.fromJson(Map<String, dynamic> json) {
    return GroupModel(
      id: json['id'] as int?,
      uuid: json['uuid'] as String?,
      institutionId: json['institution_id'] as int?,
      programId: json['program_id'] as int?,
      departmentId: json['department_id'] as int?,
      parentGroupId: json['parent_group_id'] as int?,
      groupType: _parseGroupType(json['group_type'] as String?),
      visibility: _parseVisibility(json['visibility'] as String?),
      name: json['name'] as String,
      slug: json['slug'] as String,
      description: json['description'] as String?,
      coverImageUrl: json['cover_image_url'] as String? ?? json['cover_url'] as String?,
      iconUrl: json['icon_url'] as String?,
      avatarUrl: json['avatar_url'] as String?,
      academicLevel: json['academic_level'] as String?,
      academicYearId: json['academic_year_id'] as int?,
      isOfficial: (json['is_official'] as int?) == 1,
      isVerified: (json['is_verified'] as int?) == 1,
      isNational: (json['is_national'] as int?) == 1,
      maxMembers: json['max_members'] as int?,
      currentMembersCount: json['current_members_count'] as int? ?? 0,
      joinApprovalRequired: (json['join_approval_required'] as int?) == 1,
      allowMemberPosts: (json['allow_member_posts'] as int?) == 1,
      allowMemberInvites: (json['allow_member_invites'] as int?) == 1,
      rules: json['rules'] as String?,
      tags: json['tags'] as Map<String, dynamic>?,
      settings: json['settings'] as Map<String, dynamic>?,
      createdBy: json['created_by'] as int?,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      unreadCount: json['unread_count'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'uuid': uuid,
      'institution_id': institutionId,
      'program_id': programId,
      'department_id': departmentId,
      'parent_group_id': parentGroupId,
      'group_type': groupType.name,
      'visibility': visibility.name,
      'name': name,
      'slug': slug,
      'description': description,
      'cover_image_url': coverImageUrl,
      'icon_url': iconUrl,
      'avatar_url': avatarUrl,
      'academic_level': academicLevel,
      'academic_year_id': academicYearId,
      'is_official': isOfficial ? 1 : 0,
      'is_verified': isVerified ? 1 : 0,
      'is_national': isNational ? 1 : 0,
      'max_members': maxMembers,
      'current_members_count': currentMembersCount,
      'join_approval_required': joinApprovalRequired ? 1 : 0,
      'allow_member_posts': allowMemberPosts ? 1 : 0,
      'allow_member_invites': allowMemberInvites ? 1 : 0,
      'rules': rules,
      'tags': tags,
      'settings': settings,
      'created_by': createdBy,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'unread_count': unreadCount,
    };
  }

  GroupModel copyWith({
    int? id,
    String? uuid,
    int? institutionId,
    int? programId,
    int? departmentId,
    int? parentGroupId,
    GroupType? groupType,
    GroupVisibility? visibility,
    String? name,
    String? slug,
    String? description,
    String? coverImageUrl,
    String? iconUrl,
    String? avatarUrl,
    String? academicLevel,
    int? academicYearId,
    bool? isOfficial,
    bool? isVerified,
    bool? isNational,
    int? maxMembers,
    int? currentMembersCount,
    bool? joinApprovalRequired,
    bool? allowMemberPosts,
    bool? allowMemberInvites,
    String? rules,
    Map<String, dynamic>? tags,
    Map<String, dynamic>? settings,
    int? createdBy,
    DateTime? createdAt,
    DateTime? updatedAt,
    int? unreadCount,
  }) {
    return GroupModel(
      id: id ?? this.id,
      uuid: uuid ?? this.uuid,
      institutionId: institutionId ?? this.institutionId,
      programId: programId ?? this.programId,
      departmentId: departmentId ?? this.departmentId,
      parentGroupId: parentGroupId ?? this.parentGroupId,
      groupType: groupType ?? this.groupType,
      visibility: visibility ?? this.visibility,
      name: name ?? this.name,
      slug: slug ?? this.slug,
      description: description ?? this.description,
      coverImageUrl: coverImageUrl ?? this.coverImageUrl,
      iconUrl: iconUrl ?? this.iconUrl,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      academicLevel: academicLevel ?? this.academicLevel,
      academicYearId: academicYearId ?? this.academicYearId,
      isOfficial: isOfficial ?? this.isOfficial,
      isVerified: isVerified ?? this.isVerified,
      isNational: isNational ?? this.isNational,
      maxMembers: maxMembers ?? this.maxMembers,
      currentMembersCount: currentMembersCount ?? this.currentMembersCount,
      joinApprovalRequired: joinApprovalRequired ?? this.joinApprovalRequired,
      allowMemberPosts: allowMemberPosts ?? this.allowMemberPosts,
      allowMemberInvites: allowMemberInvites ?? this.allowMemberInvites,
      rules: rules ?? this.rules,
      tags: tags ?? this.tags,
      settings: settings ?? this.settings,
      createdBy: createdBy ?? this.createdBy,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      unreadCount: unreadCount ?? this.unreadCount,
    );
  }

  static GroupType _parseGroupType(String? type) {
    if (type == null) return GroupType.custom;
    return GroupType.values.firstWhere(
      (e) => e.name == type,
      orElse: () => GroupType.custom,
    );
  }

  static GroupVisibility _parseVisibility(String? visibility) {
    if (visibility == null) return GroupVisibility.public;
    return GroupVisibility.values.firstWhere(
      (e) => e.name == visibility,
      orElse: () => GroupVisibility.public,
    );
  }

  @override
  List<Object?> get props => [
        id,
        uuid,
        institutionId,
        programId,
        departmentId,
        parentGroupId,
        groupType,
        visibility,
        name,
        slug,
        description,
        coverImageUrl,
        iconUrl,
        avatarUrl,
        academicLevel,
        academicYearId,
        isOfficial,
        isVerified,
        isNational,
        maxMembers,
        currentMembersCount,
        joinApprovalRequired,
        allowMemberPosts,
        allowMemberInvites,
        rules,
        tags,
        settings,
        createdBy,
        createdAt,
        updatedAt,
        unreadCount,
      ];
}

class GroupMemberModel extends Equatable {
  final int? id;
  final int? groupId;
  final int? userId;
  final GroupMemberRole role;
  final GroupMemberStatus status;
  final int? invitedBy;
  final DateTime joinedAt;
  final DateTime? approvedAt;
  final int? approvedBy;
  final DateTime? leftAt;
  final DateTime? bannedAt;
  final int? bannedBy;
  final String? banReason;
  final bool canPost;
  final bool canComment;
  final bool canInvite;
  final bool notificationEnabled;
  final DateTime? mutedUntil;
  final DateTime? lastReadAt;
  final int unreadCount;
  final Map<String, dynamic>? metadata;
  final DateTime createdAt;
  final DateTime updatedAt;
  
  // User information
  final String? firstName;
  final String? lastName;
  final String? email;
  final String? avatarUrl;
  final String? fullName;

  const GroupMemberModel({
    this.id,
    this.groupId,
    this.userId,
    required this.role,
    required this.status,
    this.invitedBy,
    required this.joinedAt,
    this.approvedAt,
    this.approvedBy,
    this.leftAt,
    this.bannedAt,
    this.bannedBy,
    this.banReason,
    this.canPost = true,
    this.canComment = true,
    this.canInvite = false,
    this.notificationEnabled = true,
    this.mutedUntil,
    this.lastReadAt,
    this.unreadCount = 0,
    this.metadata,
    required this.createdAt,
    required this.updatedAt,
    // User information
    this.firstName,
    this.lastName,
    this.email,
    this.avatarUrl,
    this.fullName,
  });

  factory GroupMemberModel.fromJson(Map<String, dynamic> json) {
    return GroupMemberModel(
      id: json['id'] as int?,
      groupId: json['group_id'] as int?,
      userId: json['user_id'] as int?,
      role: _parseRole(json['role'] as String?),
      status: _parseStatus(json['status'] as String?),
      invitedBy: json['invited_by'] as int?,
      joinedAt: DateTime.parse(json['joined_at'] as String),
      approvedAt: json['approved_at'] != null ? DateTime.parse(json['approved_at'] as String) : null,
      approvedBy: json['approved_by'] as int?,
      leftAt: json['left_at'] != null ? DateTime.parse(json['left_at'] as String) : null,
      bannedAt: json['banned_at'] != null ? DateTime.parse(json['banned_at'] as String) : null,
      bannedBy: json['banned_by'] as int?,
      banReason: json['ban_reason'] as String?,
      canPost: (json['can_post'] as int?) == 1,
      canComment: (json['can_comment'] as int?) == 1,
      canInvite: (json['can_invite'] as int?) == 1,
      notificationEnabled: (json['notification_enabled'] as int?) == 1,
      mutedUntil: json['muted_until'] != null ? DateTime.parse(json['muted_until'] as String) : null,
      lastReadAt: json['last_read_at'] != null ? DateTime.parse(json['last_read_at'] as String) : null,
      unreadCount: json['unread_count'] as int? ?? 0,
      metadata: json['metadata'] as Map<String, dynamic>?,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      // User information
      firstName: json['first_name'] as String?,
      lastName: json['last_name'] as String?,
      email: json['email'] as String?,
      avatarUrl: json['avatar_url'] as String?,
      fullName: json['full_name'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'group_id': groupId,
      'user_id': userId,
      'role': role.name,
      'status': status.name,
      'invited_by': invitedBy,
      'joined_at': joinedAt.toIso8601String(),
      'approved_at': approvedAt?.toIso8601String(),
      'approved_by': approvedBy,
      'left_at': leftAt?.toIso8601String(),
      'banned_at': bannedAt?.toIso8601String(),
      'banned_by': bannedBy,
      'ban_reason': banReason,
      'can_post': canPost ? 1 : 0,
      'can_comment': canComment ? 1 : 0,
      'can_invite': canInvite ? 1 : 0,
      'notification_enabled': notificationEnabled ? 1 : 0,
      'muted_until': mutedUntil?.toIso8601String(),
      'last_read_at': lastReadAt?.toIso8601String(),
      'unread_count': unreadCount,
      'metadata': metadata,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      // User information
      'first_name': firstName,
      'last_name': lastName,
      'email': email,
      'avatar_url': avatarUrl,
      'full_name': fullName,
    };
  }

  GroupMemberModel copyWith({
    int? id,
    int? groupId,
    int? userId,
    GroupMemberRole? role,
    GroupMemberStatus? status,
    int? invitedBy,
    DateTime? joinedAt,
    DateTime? approvedAt,
    int? approvedBy,
    DateTime? leftAt,
    DateTime? bannedAt,
    int? bannedBy,
    String? banReason,
    bool? canPost,
    bool? canComment,
    bool? canInvite,
    bool? notificationEnabled,
    DateTime? mutedUntil,
    DateTime? lastReadAt,
    int? unreadCount,
    Map<String, dynamic>? metadata,
    DateTime? createdAt,
    DateTime? updatedAt,
    // User information
    String? firstName,
    String? lastName,
    String? email,
    String? avatarUrl,
    String? fullName,
  }) {
    return GroupMemberModel(
      id: id ?? this.id,
      groupId: groupId ?? this.groupId,
      userId: userId ?? this.userId,
      role: role ?? this.role,
      status: status ?? this.status,
      invitedBy: invitedBy ?? this.invitedBy,
      joinedAt: joinedAt ?? this.joinedAt,
      approvedAt: approvedAt ?? this.approvedAt,
      approvedBy: approvedBy ?? this.approvedBy,
      leftAt: leftAt ?? this.leftAt,
      bannedAt: bannedAt ?? this.bannedAt,
      bannedBy: bannedBy ?? this.bannedBy,
      banReason: banReason ?? this.banReason,
      canPost: canPost ?? this.canPost,
      canComment: canComment ?? this.canComment,
      canInvite: canInvite ?? this.canInvite,
      notificationEnabled: notificationEnabled ?? this.notificationEnabled,
      mutedUntil: mutedUntil ?? this.mutedUntil,
      lastReadAt: lastReadAt ?? this.lastReadAt,
      unreadCount: unreadCount ?? this.unreadCount,
      metadata: metadata ?? this.metadata,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      // User information
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      email: email ?? this.email,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      fullName: fullName ?? this.fullName,
    );
  }

  static GroupMemberRole _parseRole(String? role) {
    if (role == null) return GroupMemberRole.member;
    return GroupMemberRole.values.firstWhere(
      (e) => e.name == role,
      orElse: () => GroupMemberRole.member,
    );
  }

  static GroupMemberStatus _parseStatus(String? status) {
    if (status == null) return GroupMemberStatus.active;
    return GroupMemberStatus.values.firstWhere(
      (e) => e.name == status,
      orElse: () => GroupMemberStatus.active,
    );
  }

  @override
  List<Object?> get props => [
        id,
        groupId,
        userId,
        role,
        status,
        invitedBy,
        joinedAt,
        approvedAt,
        approvedBy,
        leftAt,
        bannedAt,
        bannedBy,
        banReason,
        canPost,
        canComment,
        canInvite,
        notificationEnabled,
        mutedUntil,
        lastReadAt,
        unreadCount,
        metadata,
        createdAt,
        updatedAt,
        // User information
        firstName,
        lastName,
        email,
        avatarUrl,
        fullName,
      ];
}
