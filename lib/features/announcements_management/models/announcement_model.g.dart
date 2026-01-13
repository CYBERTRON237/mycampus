// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'announcement_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AnnouncementModel _$AnnouncementModelFromJson(Map<String, dynamic> json) =>
    AnnouncementModel(
      id: (json['id'] as num?)?.toInt(),
      uuid: json['uuid'] as String?,
      institutionId: (json['institutionId'] as num?)?.toInt(),
      authorId: (json['authorId'] as num?)?.toInt(),
      publishedBy: (json['publishedBy'] as num?)?.toInt(),
      scope: $enumDecodeNullable(_$AnnouncementScopeEnumMap, json['scope']),
      scopeIds: (json['scopeIds'] as List<dynamic>?)
          ?.map((e) => (e as num).toInt())
          .toList(),
      targetAudience: (json['targetAudience'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      targetLevels: (json['targetLevels'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      priority: $enumDecode(_$AnnouncementPriorityEnumMap, json['priority']),
      category: $enumDecode(_$AnnouncementCategoryEnumMap, json['category']),
      announcementType:
          $enumDecode(_$AnnouncementTypeEnumMap, json['announcementType']),
      title: json['title'] as String,
      content: json['content'] as String,
      excerpt: json['excerpt'] as String?,
      coverImageUrl: json['coverImageUrl'] as String?,
      attachments: (json['attachments'] as List<dynamic>?)
          ?.map((e) => Attachment.fromJson(e as Map<String, dynamic>))
          .toList(),
      attachmentsUrl: json['attachmentsUrl'] as String?,
      externalLink: json['externalLink'] as String?,
      isPinned: json['isPinned'] as bool,
      isFeatured: json['isFeatured'] as bool,
      showOnHomepage: json['showOnHomepage'] as bool,
      requiresAcknowledgment: json['requiresAcknowledgment'] as bool,
      acknowledgmentCount: (json['acknowledgmentCount'] as num).toInt(),
      publishAt: json['publishAt'] == null
          ? null
          : DateTime.parse(json['publishAt'] as String),
      publishedAt: json['publishedAt'] == null
          ? null
          : DateTime.parse(json['publishedAt'] as String),
      expireAt: json['expireAt'] == null
          ? null
          : DateTime.parse(json['expireAt'] as String),
      expiresAt: json['expiresAt'] == null
          ? null
          : DateTime.parse(json['expiresAt'] as String),
      status: $enumDecode(_$AnnouncementStatusEnumMap, json['status']),
      viewsCount: (json['viewsCount'] as num).toInt(),
      sharesCount: (json['sharesCount'] as num).toInt(),
      commentsCount: (json['commentsCount'] as num).toInt(),
      allowComments: json['allowComments'] as bool,
      tags: (json['tags'] as List<dynamic>?)?.map((e) => e as String).toList(),
      metadata: json['metadata'] as Map<String, dynamic>?,
      archivedAt: json['archivedAt'] == null
          ? null
          : DateTime.parse(json['archivedAt'] as String),
      deletedAt: json['deletedAt'] == null
          ? null
          : DateTime.parse(json['deletedAt'] as String),
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      authorName: json['authorName'] as String?,
      authorEmail: json['authorEmail'] as String?,
      institutionName: json['institutionName'] as String?,
    );

Map<String, dynamic> _$AnnouncementModelToJson(AnnouncementModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'uuid': instance.uuid,
      'institutionId': instance.institutionId,
      'authorId': instance.authorId,
      'publishedBy': instance.publishedBy,
      'scope': _$AnnouncementScopeEnumMap[instance.scope],
      'scopeIds': instance.scopeIds,
      'targetAudience': instance.targetAudience,
      'targetLevels': instance.targetLevels,
      'priority': _$AnnouncementPriorityEnumMap[instance.priority]!,
      'category': _$AnnouncementCategoryEnumMap[instance.category]!,
      'announcementType': _$AnnouncementTypeEnumMap[instance.announcementType]!,
      'title': instance.title,
      'content': instance.content,
      'excerpt': instance.excerpt,
      'coverImageUrl': instance.coverImageUrl,
      'attachments': instance.attachments,
      'attachmentsUrl': instance.attachmentsUrl,
      'externalLink': instance.externalLink,
      'isPinned': instance.isPinned,
      'isFeatured': instance.isFeatured,
      'showOnHomepage': instance.showOnHomepage,
      'requiresAcknowledgment': instance.requiresAcknowledgment,
      'acknowledgmentCount': instance.acknowledgmentCount,
      'publishAt': instance.publishAt?.toIso8601String(),
      'publishedAt': instance.publishedAt?.toIso8601String(),
      'expireAt': instance.expireAt?.toIso8601String(),
      'expiresAt': instance.expiresAt?.toIso8601String(),
      'status': _$AnnouncementStatusEnumMap[instance.status]!,
      'viewsCount': instance.viewsCount,
      'sharesCount': instance.sharesCount,
      'commentsCount': instance.commentsCount,
      'allowComments': instance.allowComments,
      'tags': instance.tags,
      'metadata': instance.metadata,
      'archivedAt': instance.archivedAt?.toIso8601String(),
      'deletedAt': instance.deletedAt?.toIso8601String(),
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
      'authorName': instance.authorName,
      'authorEmail': instance.authorEmail,
      'institutionName': instance.institutionName,
    };

const _$AnnouncementScopeEnumMap = {
  AnnouncementScope.institution: 'institution',
  AnnouncementScope.local: 'local',
  AnnouncementScope.faculty: 'faculty',
  AnnouncementScope.department: 'department',
  AnnouncementScope.program: 'program',
  AnnouncementScope.national: 'national',
  AnnouncementScope.interUniversity: 'inter_university',
  AnnouncementScope.multiInstitutions: 'multi_institutions',
};

const _$AnnouncementPriorityEnumMap = {
  AnnouncementPriority.low: 'low',
  AnnouncementPriority.normal: 'normal',
  AnnouncementPriority.high: 'high',
  AnnouncementPriority.urgent: 'urgent',
  AnnouncementPriority.critical: 'critical',
};

const _$AnnouncementCategoryEnumMap = {
  AnnouncementCategory.academic: 'academic',
  AnnouncementCategory.administrative: 'administrative',
  AnnouncementCategory.event: 'event',
  AnnouncementCategory.exam: 'exam',
  AnnouncementCategory.registration: 'registration',
  AnnouncementCategory.scholarship: 'scholarship',
  AnnouncementCategory.alert: 'alert',
  AnnouncementCategory.general: 'general',
  AnnouncementCategory.emergency: 'emergency',
  AnnouncementCategory.urgent: 'urgent',
};

const _$AnnouncementTypeEnumMap = {
  AnnouncementType.academic: 'academic',
  AnnouncementType.administrative: 'administrative',
  AnnouncementType.event: 'event',
  AnnouncementType.urgent: 'urgent',
  AnnouncementType.general: 'general',
};

const _$AnnouncementStatusEnumMap = {
  AnnouncementStatus.draft: 'draft',
  AnnouncementStatus.scheduled: 'scheduled',
  AnnouncementStatus.published: 'published',
  AnnouncementStatus.archived: 'archived',
  AnnouncementStatus.deleted: 'deleted',
};

Attachment _$AttachmentFromJson(Map<String, dynamic> json) => Attachment(
      id: json['id'] as String,
      name: json['name'] as String,
      url: json['url'] as String,
      type: json['type'] as String,
      size: (json['size'] as num).toInt(),
      uploadedAt: json['uploadedAt'] == null
          ? null
          : DateTime.parse(json['uploadedAt'] as String),
    );

Map<String, dynamic> _$AttachmentToJson(Attachment instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'url': instance.url,
      'type': instance.type,
      'size': instance.size,
      'uploadedAt': instance.uploadedAt?.toIso8601String(),
    };
