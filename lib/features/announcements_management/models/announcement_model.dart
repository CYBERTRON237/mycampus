import 'package:json_annotation/json_annotation.dart';

part 'announcement_model.g.dart';

@JsonSerializable()
class AnnouncementModel {
  final int? id;
  final String? uuid;
  final int? institutionId;
  final int? authorId;
  final int? publishedBy;
  final AnnouncementScope? scope;
  final List<int>? scopeIds;
  final List<String>? targetAudience;
  final List<String>? targetLevels;
  final AnnouncementPriority priority;
  final AnnouncementCategory category;
  final AnnouncementType announcementType;
  final String title;
  final String content;
  final String? excerpt;
  final String? coverImageUrl;
  final List<Attachment>? attachments;
  final String? attachmentsUrl;
  final String? externalLink;
  final bool isPinned;
  final bool isFeatured;
  final bool showOnHomepage;
  final bool requiresAcknowledgment;
  final int acknowledgmentCount;
  final DateTime? publishAt;
  final DateTime? publishedAt;
  final DateTime? expireAt;
  final DateTime? expiresAt;
  final AnnouncementStatus status;
  final int viewsCount;
  final int sharesCount;
  final int commentsCount;
  final bool allowComments;
  final List<String>? tags;
  final Map<String, dynamic>? metadata;
  final DateTime? archivedAt;
  final DateTime? deletedAt;
  final DateTime createdAt;
  final DateTime updatedAt;

  // Author information (from JOIN)
  final String? authorName;
  final String? authorEmail;
  final String? institutionName;

  const AnnouncementModel({
    this.id,
    this.uuid,
    this.institutionId,
    this.authorId,
    this.publishedBy,
    this.scope,
    this.scopeIds,
    this.targetAudience,
    this.targetLevels,
    required this.priority,
    required this.category,
    required this.announcementType,
    required this.title,
    required this.content,
    this.excerpt,
    this.coverImageUrl,
    this.attachments,
    this.attachmentsUrl,
    this.externalLink,
    required this.isPinned,
    required this.isFeatured,
    required this.showOnHomepage,
    required this.requiresAcknowledgment,
    required this.acknowledgmentCount,
    this.publishAt,
    this.publishedAt,
    this.expireAt,
    this.expiresAt,
    required this.status,
    required this.viewsCount,
    required this.sharesCount,
    required this.commentsCount,
    required this.allowComments,
    this.tags,
    this.metadata,
    this.archivedAt,
    this.deletedAt,
    required this.createdAt,
    required this.updatedAt,
    this.authorName,
    this.authorEmail,
    this.institutionName,
  });

  factory AnnouncementModel.fromJson(Map<String, dynamic> json) =>
      _$AnnouncementModelFromJson(json);

  Map<String, dynamic> toJson() => _$AnnouncementModelToJson(this);

  // Getter to safely access scope with default value
  AnnouncementScope get effectiveScope => scope ?? AnnouncementScope.institution;

  AnnouncementModel copyWith({
    int? id,
    String? uuid,
    int? institutionId,
    int? authorId,
    int? publishedBy,
    AnnouncementScope? scope,
    List<int>? scopeIds,
    List<String>? targetAudience,
    List<String>? targetLevels,
    AnnouncementPriority? priority,
    AnnouncementCategory? category,
    AnnouncementType? announcementType,
    String? title,
    String? content,
    String? excerpt,
    String? coverImageUrl,
    List<Attachment>? attachments,
    String? attachmentsUrl,
    String? externalLink,
    bool? isPinned,
    bool? isFeatured,
    bool? showOnHomepage,
    bool? requiresAcknowledgment,
    int? acknowledgmentCount,
    DateTime? publishAt,
    DateTime? publishedAt,
    DateTime? expireAt,
    DateTime? expiresAt,
    AnnouncementStatus? status,
    int? viewsCount,
    int? sharesCount,
    int? commentsCount,
    bool? allowComments,
    List<String>? tags,
    Map<String, dynamic>? metadata,
    DateTime? archivedAt,
    DateTime? deletedAt,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? authorName,
    String? authorEmail,
    String? institutionName,
  }) {
    return AnnouncementModel(
      id: id ?? this.id,
      uuid: uuid ?? this.uuid,
      institutionId: institutionId ?? this.institutionId,
      authorId: authorId ?? this.authorId,
      publishedBy: publishedBy ?? this.publishedBy,
      scope: scope ?? this.scope,
      scopeIds: scopeIds ?? this.scopeIds,
      targetAudience: targetAudience ?? this.targetAudience,
      targetLevels: targetLevels ?? this.targetLevels,
      priority: priority ?? this.priority,
      category: category ?? this.category,
      announcementType: announcementType ?? this.announcementType,
      title: title ?? this.title,
      content: content ?? this.content,
      excerpt: excerpt ?? this.excerpt,
      coverImageUrl: coverImageUrl ?? this.coverImageUrl,
      attachments: attachments ?? this.attachments,
      attachmentsUrl: attachmentsUrl ?? this.attachmentsUrl,
      externalLink: externalLink ?? this.externalLink,
      isPinned: isPinned ?? this.isPinned,
      isFeatured: isFeatured ?? this.isFeatured,
      showOnHomepage: showOnHomepage ?? this.showOnHomepage,
      requiresAcknowledgment: requiresAcknowledgment ?? this.requiresAcknowledgment,
      acknowledgmentCount: acknowledgmentCount ?? this.acknowledgmentCount,
      publishAt: publishAt ?? this.publishAt,
      publishedAt: publishedAt ?? this.publishedAt,
      expireAt: expireAt ?? this.expireAt,
      expiresAt: expiresAt ?? this.expiresAt,
      status: status ?? this.status,
      viewsCount: viewsCount ?? this.viewsCount,
      sharesCount: sharesCount ?? this.sharesCount,
      commentsCount: commentsCount ?? this.commentsCount,
      allowComments: allowComments ?? this.allowComments,
      tags: tags ?? this.tags,
      metadata: metadata ?? this.metadata,
      archivedAt: archivedAt ?? this.archivedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      authorName: authorName ?? this.authorName,
      authorEmail: authorEmail ?? this.authorEmail,
      institutionName: institutionName ?? this.institutionName,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AnnouncementModel &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'AnnouncementModel{id: $id, title: $title, status: $status}';
  }

  // Helper getters
  bool get isPublished => status == AnnouncementStatus.published;
  bool get isDraft => status == AnnouncementStatus.draft;
  bool get isScheduled => status == AnnouncementStatus.scheduled;
  bool get isExpired => expiresAt != null && expiresAt!.isBefore(DateTime.now());
  bool get isUrgent => priority == AnnouncementPriority.urgent || priority == AnnouncementPriority.critical;
  bool get hasAttachments => attachments != null && attachments!.isNotEmpty;
  bool get hasTags => tags != null && tags!.isNotEmpty;
  bool get hasCoverImage => coverImageUrl != null && coverImageUrl!.isNotEmpty;

  String get priorityLabel => priority.label;
  String get categoryLabel => category.label;
  String get scopeLabel => effectiveScope.label;
  String get statusLabel => status.label;
}

@JsonSerializable()
class Attachment {
  final String id;
  final String name;
  final String url;
  final String type;
  final int size;
  final DateTime? uploadedAt;

  const Attachment({
    required this.id,
    required this.name,
    required this.url,
    required this.type,
    required this.size,
    this.uploadedAt,
  });

  factory Attachment.fromJson(Map<String, dynamic> json) =>
      _$AttachmentFromJson(json);

  Map<String, dynamic> toJson() => _$AttachmentToJson(this);
}

enum AnnouncementScope {
  @JsonValue('institution')
  institution,
  @JsonValue('local')
  local,
  @JsonValue('faculty')
  faculty,
  @JsonValue('department')
  department,
  @JsonValue('program')
  program,
  @JsonValue('national')
  national,
  @JsonValue('inter_university')
  interUniversity,
  @JsonValue('multi_institutions')
  multiInstitutions,
}

extension AnnouncementScopeExtension on AnnouncementScope {
  String get label {
    switch (this) {
      case AnnouncementScope.institution:
        return 'Institution';
      case AnnouncementScope.local:
        return 'Local';
      case AnnouncementScope.faculty:
        return 'Faculté';
      case AnnouncementScope.department:
        return 'Département';
      case AnnouncementScope.program:
        return 'Programme/Filière';
      case AnnouncementScope.national:
        return 'National';
      case AnnouncementScope.interUniversity:
        return 'Inter-universitaire';
      case AnnouncementScope.multiInstitutions:
        return 'Multi-institutions';
    }
  }
}

enum AnnouncementPriority {
  @JsonValue('low')
  low,
  @JsonValue('normal')
  normal,
  @JsonValue('high')
  high,
  @JsonValue('urgent')
  urgent,
  @JsonValue('critical')
  critical,
}

extension AnnouncementPriorityExtension on AnnouncementPriority {
  String get label {
    switch (this) {
      case AnnouncementPriority.low:
        return 'Faible';
      case AnnouncementPriority.normal:
        return 'Normal';
      case AnnouncementPriority.high:
        return 'Élevé';
      case AnnouncementPriority.urgent:
        return 'Urgent';
      case AnnouncementPriority.critical:
        return 'Critique';
    }
  }
}

enum AnnouncementCategory {
  @JsonValue('academic')
  academic,
  @JsonValue('administrative')
  administrative,
  @JsonValue('event')
  event,
  @JsonValue('exam')
  exam,
  @JsonValue('registration')
  registration,
  @JsonValue('scholarship')
  scholarship,
  @JsonValue('alert')
  alert,
  @JsonValue('general')
  general,
  @JsonValue('emergency')
  emergency,
  @JsonValue('urgent')
  urgent,
}

extension AnnouncementCategoryExtension on AnnouncementCategory {
  String get label {
    switch (this) {
      case AnnouncementCategory.academic:
        return 'Académique';
      case AnnouncementCategory.administrative:
        return 'Administratif';
      case AnnouncementCategory.event:
        return 'Événement';
      case AnnouncementCategory.exam:
        return 'Examen';
      case AnnouncementCategory.registration:
        return 'Inscription';
      case AnnouncementCategory.scholarship:
        return 'Bourse';
      case AnnouncementCategory.alert:
        return 'Alerte';
      case AnnouncementCategory.general:
        return 'Général';
      case AnnouncementCategory.emergency:
        return 'Urgence';
      case AnnouncementCategory.urgent:
        return 'Urgent';
    }
  }
}

enum AnnouncementType {
  @JsonValue('academic')
  academic,
  @JsonValue('administrative')
  administrative,
  @JsonValue('event')
  event,
  @JsonValue('urgent')
  urgent,
  @JsonValue('general')
  general,
}

extension AnnouncementTypeExtension on AnnouncementType {
  String get label {
    switch (this) {
      case AnnouncementType.academic:
        return 'Académique';
      case AnnouncementType.administrative:
        return 'Administratif';
      case AnnouncementType.event:
        return 'Événement';
      case AnnouncementType.urgent:
        return 'Urgent';
      case AnnouncementType.general:
        return 'Général';
    }
  }
}

enum AnnouncementStatus {
  @JsonValue('draft')
  draft,
  @JsonValue('scheduled')
  scheduled,
  @JsonValue('published')
  published,
  @JsonValue('archived')
  archived,
  @JsonValue('deleted')
  deleted,
}

extension AnnouncementStatusExtension on AnnouncementStatus {
  String get label {
    switch (this) {
      case AnnouncementStatus.draft:
        return 'Brouillon';
      case AnnouncementStatus.scheduled:
        return 'Programmé';
      case AnnouncementStatus.published:
        return 'Publié';
      case AnnouncementStatus.archived:
        return 'Archivé';
      case AnnouncementStatus.deleted:
        return 'Supprimé';
    }
  }
}

// Helper class for pagination
class AnnouncementPagination {
  final int page;
  final int limit;
  final int total;
  final int totalPages;

  const AnnouncementPagination({
    required this.page,
    required this.limit,
    required this.total,
    required this.totalPages,
  });

  factory AnnouncementPagination.fromJson(Map<String, dynamic> json) {
    return AnnouncementPagination(
      page: json['page'] as int,
      limit: json['limit'] as int,
      total: json['total'] as int,
      totalPages: json['total_pages'] as int,
    );
  }

  bool get hasNextPage => page < totalPages;
  bool get hasPreviousPage => page > 1;
}

// Helper class for API response
class AnnouncementResponse {
  final bool success;
  final String? message;
  final List<AnnouncementModel>? data;
  final AnnouncementModel? announcement;
  final AnnouncementPagination? pagination;
  final Map<String, dynamic>? filters;

  const AnnouncementResponse({
    required this.success,
    this.message,
    this.data,
    this.announcement,
    this.pagination,
    this.filters,
  });

  factory AnnouncementResponse.fromJson(Map<String, dynamic> json) {
    return AnnouncementResponse(
      success: json['success'] as bool,
      message: json['message'] as String?,
      data: json['data'] != null
          ? (json['data'] as List)
              .map((item) => AnnouncementModel.fromJson(item))
              .toList()
          : null,
      announcement: json['data'] != null && json['data'] is Map
          ? AnnouncementModel.fromJson(json['data'])
          : null,
      pagination: json['pagination'] != null
          ? AnnouncementPagination.fromJson(json['pagination'])
          : null,
      filters: json['filters'] as Map<String, dynamic>?,
    );
  }
}

// Helper class for statistics
class AnnouncementStatistics {
  final int total;
  final int published;
  final int draft;
  final int scheduled;
  final int pinned;
  final int requiresAck;
  final int expired;

  const AnnouncementStatistics({
    required this.total,
    required this.published,
    required this.draft,
    required this.scheduled,
    required this.pinned,
    required this.requiresAck,
    required this.expired,
  });

  factory AnnouncementStatistics.fromJson(Map<String, dynamic> json) {
    return AnnouncementStatistics(
      total: json['total'] as int,
      published: json['published'] as int,
      draft: json['draft'] as int,
      scheduled: json['scheduled'] as int,
      pinned: json['pinned'] as int,
      requiresAck: json['requires_ack'] as int,
      expired: json['expired'] as int,
    );
  }
}

// Constants for dropdowns and filters
class AnnouncementConstants {
  static List<AnnouncementScope> get allScopes => AnnouncementScope.values;
  
  static List<AnnouncementPriority> get allPriorities => AnnouncementPriority.values;
  
  static List<AnnouncementCategory> get allCategories => AnnouncementCategory.values;
  
  static List<AnnouncementType> get allTypes => AnnouncementType.values;
  
  static List<AnnouncementStatus> get allStatuses => AnnouncementStatus.values;

  static List<String> get targetAudienceOptions => [
    'students',
    'teachers',
    'staff',
    'administrators',
    'all_users',
    'specific_roles',
  ];

  static List<String> get targetLevelOptions => [
    'undergraduate',
    'graduate',
    'postgraduate',
    'phd',
    'all_levels',
  ];
}
