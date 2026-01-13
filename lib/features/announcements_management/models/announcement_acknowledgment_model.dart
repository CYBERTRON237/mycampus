import 'package:json_annotation/json_annotation.dart';
import 'announcement_model.dart';

part 'announcement_acknowledgment_model.g.dart';

@JsonSerializable()
class AnnouncementAcknowledgmentModel {
  final int? id;
  final int announcementId;
  final int userId;
  final DateTime acknowledgedAt;
  final String? ipAddress;
  final String? userAgent;

  // Joined fields from related tables
  final String? announcementTitle;
  final String? userFirstName;
  final String? userLastName;
  final String? userEmail;
  final String? userRole;
  final AnnouncementCategory? category;
  final AnnouncementPriority? priority;

  const AnnouncementAcknowledgmentModel({
    this.id,
    required this.announcementId,
    required this.userId,
    required this.acknowledgedAt,
    this.ipAddress,
    this.userAgent,
    this.announcementTitle,
    this.userFirstName,
    this.userLastName,
    this.userEmail,
    this.userRole,
    this.category,
    this.priority,
  });

  factory AnnouncementAcknowledgmentModel.fromJson(Map<String, dynamic> json) =>
      _$AnnouncementAcknowledgmentModelFromJson(json);

  Map<String, dynamic> toJson() => _$AnnouncementAcknowledgmentModelToJson(this);

  AnnouncementAcknowledgmentModel copyWith({
    int? id,
    int? announcementId,
    int? userId,
    DateTime? acknowledgedAt,
    String? ipAddress,
    String? userAgent,
    String? announcementTitle,
    String? userFirstName,
    String? userLastName,
    String? userEmail,
    String? userRole,
    AnnouncementCategory? category,
    AnnouncementPriority? priority,
  }) {
    return AnnouncementAcknowledgmentModel(
      id: id ?? this.id,
      announcementId: announcementId ?? this.announcementId,
      userId: userId ?? this.userId,
      acknowledgedAt: acknowledgedAt ?? this.acknowledgedAt,
      ipAddress: ipAddress ?? this.ipAddress,
      userAgent: userAgent ?? this.userAgent,
      announcementTitle: announcementTitle ?? this.announcementTitle,
      userFirstName: userFirstName ?? this.userFirstName,
      userLastName: userLastName ?? this.userLastName,
      userEmail: userEmail ?? this.userEmail,
      userRole: userRole ?? this.userRole,
      category: category ?? this.category,
      priority: priority ?? this.priority,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AnnouncementAcknowledgmentModel &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'AnnouncementAcknowledgmentModel{id: $id, announcementId: $announcementId, userId: $userId}';
  }

  // Helper getters
  String get userFullName {
    if (userFirstName != null && userLastName != null) {
      return '$userFirstName $userLastName';
    }
    return userFirstName ?? userLastName ?? 'Utilisateur inconnu';
  }

  String get acknowledgedAtFormatted {
    return '${acknowledgedAt.day.toString().padLeft(2, '0')}/'
           '${acknowledgedAt.month.toString().padLeft(2, '0')}/'
           '${acknowledgedAt.year} '
           '${acknowledgedAt.hour.toString().padLeft(2, '0')}:'
           '${acknowledgedAt.minute.toString().padLeft(2, '0')}';
  }

  String get acknowledgedAtDate {
    return '${acknowledgedAt.day.toString().padLeft(2, '0')}/'
           '${acknowledgedAt.month.toString().padLeft(2, '0')}/'
           '${acknowledgedAt.year}';
  }

  String get acknowledgedAtTime {
    return '${acknowledgedAt.hour.toString().padLeft(2, '0')}:'
           '${acknowledgedAt.minute.toString().padLeft(2, '0')}';
  }
}


// Helper class for acknowledgment statistics
class AcknowledgmentStatistics {
  final int totalAcknowledgments;
  final DateTime acknowledgmentDate;
  final int dailyCount;

  const AcknowledgmentStatistics({
    required this.totalAcknowledgments,
    required this.acknowledgmentDate,
    required this.dailyCount,
  });

  factory AcknowledgmentStatistics.fromJson(Map<String, dynamic> json) {
    return AcknowledgmentStatistics(
      totalAcknowledgments: json['total_acknowledgments'] as int,
      acknowledgmentDate: DateTime.parse(json['acknowledgment_date'] as String),
      dailyCount: json['daily_count'] as int,
    );
  }
}

// Helper class for pending acknowledgments
class PendingAcknowledgment {
  final AnnouncementModel announcement;
  final bool isAcknowledged;

  const PendingAcknowledgment({
    required this.announcement,
    required this.isAcknowledged,
  });

  factory PendingAcknowledgment.fromJson(Map<String, dynamic> json) {
    return PendingAcknowledgment(
      announcement: AnnouncementModel.fromJson(json),
      isAcknowledged: json['is_acknowledged'] as bool,
    );
  }
}

