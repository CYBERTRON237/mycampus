// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'announcement_acknowledgment_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AnnouncementAcknowledgmentModel _$AnnouncementAcknowledgmentModelFromJson(
        Map<String, dynamic> json) =>
    AnnouncementAcknowledgmentModel(
      id: (json['id'] as num?)?.toInt(),
      announcementId: (json['announcementId'] as num).toInt(),
      userId: (json['userId'] as num).toInt(),
      acknowledgedAt: DateTime.parse(json['acknowledgedAt'] as String),
      ipAddress: json['ipAddress'] as String?,
      userAgent: json['userAgent'] as String?,
      announcementTitle: json['announcementTitle'] as String?,
      userFirstName: json['userFirstName'] as String?,
      userLastName: json['userLastName'] as String?,
      userEmail: json['userEmail'] as String?,
      userRole: json['userRole'] as String?,
      category:
          $enumDecodeNullable(_$AnnouncementCategoryEnumMap, json['category']),
      priority:
          $enumDecodeNullable(_$AnnouncementPriorityEnumMap, json['priority']),
    );

Map<String, dynamic> _$AnnouncementAcknowledgmentModelToJson(
        AnnouncementAcknowledgmentModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'announcementId': instance.announcementId,
      'userId': instance.userId,
      'acknowledgedAt': instance.acknowledgedAt.toIso8601String(),
      'ipAddress': instance.ipAddress,
      'userAgent': instance.userAgent,
      'announcementTitle': instance.announcementTitle,
      'userFirstName': instance.userFirstName,
      'userLastName': instance.userLastName,
      'userEmail': instance.userEmail,
      'userRole': instance.userRole,
      'category': _$AnnouncementCategoryEnumMap[instance.category],
      'priority': _$AnnouncementPriorityEnumMap[instance.priority],
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

const _$AnnouncementPriorityEnumMap = {
  AnnouncementPriority.low: 'low',
  AnnouncementPriority.normal: 'normal',
  AnnouncementPriority.high: 'high',
  AnnouncementPriority.urgent: 'urgent',
  AnnouncementPriority.critical: 'critical',
};
