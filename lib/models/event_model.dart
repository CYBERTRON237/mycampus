// lib/models/event_model.dart
import 'package:intl/intl.dart';

class EventModel {
  // Constantes pour les types d'événements
  static const String typeClass = 'class';
  static const String typeExam = 'exam';
  static const String typeHoliday = 'holiday';
  static const String typeMeeting = 'meeting';
  static const String typeDeadline = 'deadline';
  static const String typeDefault = 'event';

  final String id;
  final String title;
  final String? description;
  final DateTime startDate;
  final DateTime endDate;
  final String? location;
  final String type;
  final String? courseId;
  final String? courseName;
  final String? createdBy;
  final String? institutionId;
  final DateTime createdAt;
  final DateTime updatedAt;

  EventModel({
    required this.id,
    required this.title,
    this.description,
    required this.startDate,
    required this.endDate,
    this.location,
    required this.type,
    this.courseId,
    this.courseName,
    this.createdBy,
    this.institutionId,
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now() {
    if (endDate.isBefore(startDate)) {
      throw ArgumentError('La date de fin doit être postérieure à la date de début');
    }
  }

  factory EventModel.fromJson(Map<String, dynamic> json) {
    if (json['id'] == null || json['title'] == null) {
      throw const FormatException('Les champs id et title sont obligatoires');
    }

    final startDate = json['start_date'] != null 
        ? DateTime.tryParse(json['start_date'])
        : null;
    final endDate = json['end_date'] != null 
        ? DateTime.tryParse(json['end_date'])
        : null;

    if (startDate == null || endDate == null) {
      throw const FormatException('Les dates de début et de fin sont invalides');
    }

    return EventModel(
      id: json['id'].toString(),
      title: json['title'] as String,
      description: json['description'] as String?,
      startDate: startDate,
      endDate: endDate,
      location: json['location'] as String?,
      type: json['type'] as String? ?? typeDefault,
      courseId: json['course_id']?.toString() ?? json['courseId']?.toString(),
      courseName: json['course_name'] as String? ?? json['courseName'] as String?,
      createdBy: json['created_by']?.toString() ?? json['createdBy']?.toString(),
      institutionId: json['institution_id']?.toString() ?? json['institutionId']?.toString(),
      createdAt: json['created_at'] != null 
          ? DateTime.tryParse(json['created_at'])
          : null,
      updatedAt: json['updated_at'] != null 
          ? DateTime.tryParse(json['updated_at'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      if (description != null) 'description': description,
      'start_date': startDate.toIso8601String(),
      'end_date': endDate.toIso8601String(),
      if (location != null) 'location': location,
      'type': type,
      if (courseId != null) 'course_id': courseId,
      if (courseName != null) 'course_name': courseName,
      if (createdBy != null) 'created_by': createdBy,
      if (institutionId != null) 'institution_id': institutionId,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  String get formattedDate {
    try {
      final start = DateFormat('dd/MM/yyyy HH:mm').format(startDate);
      final end = DateFormat('HH:mm').format(endDate);
      return '$start - $end';
    } catch (e) {
      return 'Date invalide';
    }
  }

  bool get isAllDay {
    final difference = endDate.difference(startDate);
    return difference.inHours >= 24;
  }

  bool get isPast => endDate.isBefore(DateTime.now());
  bool get isOngoing => 
      startDate.isBefore(DateTime.now()) && endDate.isAfter(DateTime.now());
  bool get isUpcoming => startDate.isAfter(DateTime.now());

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is EventModel &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          title == other.title &&
          startDate == other.startDate;

  @override
  int get hashCode => Object.hash(id, title, startDate);
}