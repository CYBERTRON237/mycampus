enum ContactStatus {
  pending,
  accepted,
  blocked,
  rejected,
  cancelled,
}

enum ContactRequestStatus {
  pending,
  accepted,
  rejected,
  cancelled,
}

class ContactModel {
  final String id;
  final String userId;
  final String contactUserId;
  final String firstName;
  final String lastName;
  final String email;
  final String? avatar;
  final String? phone;
  final String role;
  final ContactStatus status;
  final DateTime createdAt;
  final DateTime? lastSeenAt;
  final bool isFavorite;
  final bool isOnline;

  ContactModel({
    required this.id,
    required this.userId,
    required this.contactUserId,
    required this.firstName,
    required this.lastName,
    required this.email,
    this.avatar,
    this.phone,
    required this.role,
    required this.status,
    required this.createdAt,
    this.lastSeenAt,
    this.isFavorite = false,
    this.isOnline = false,
  });

  String get fullName => '$firstName $lastName';
  String get initials {
    final parts = fullName.split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    } else if (parts.isNotEmpty && parts[0].isNotEmpty) {
      return parts[0][0].toUpperCase();
    }
    return '?';
  }

  factory ContactModel.fromJson(Map<String, dynamic> json) {
    return ContactModel(
      id: json['id']?.toString() ?? '',
      userId: json['user_id']?.toString() ?? '',
      contactUserId: json['contact_user_id']?.toString() ?? '',
      firstName: json['first_name']?.toString() ?? '',
      lastName: json['last_name']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      avatar: json['profile_photo_url']?.toString() ?? json['profile_picture']?.toString(),
      phone: json['phone']?.toString(),
      role: json['primary_role']?.toString() ?? 'student',
      status: ContactStatus.values.firstWhere(
        (e) => e.name == (json['status'] ?? 'pending'),
        orElse: () => ContactStatus.pending,
      ),
      createdAt: DateTime.parse(json['created_at'] ?? DateTime.now().toIso8601String()),
      lastSeenAt: json['last_seen_at'] != null ? DateTime.parse(json['last_seen_at']) : null,
      isFavorite: json['is_favorite'] == 1 || json['is_favorite'] == true,
      isOnline: json['is_online'] == 1 || json['is_online'] == true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'contact_user_id': contactUserId,
      'first_name': firstName,
      'last_name': lastName,
      'email': email,
      'profile_photo_url': avatar,
      'phone': phone,
      'primary_role': role,
      'status': status.name,
      'created_at': createdAt.toIso8601String(),
      'last_seen_at': lastSeenAt?.toIso8601String(),
      'is_favorite': isFavorite,
      'is_online': isOnline,
    }..removeWhere((key, value) => value == null);
  }

  ContactModel copyWith({
    String? id,
    String? userId,
    String? contactUserId,
    String? firstName,
    String? lastName,
    String? email,
    String? avatar,
    String? phone,
    String? role,
    ContactStatus? status,
    DateTime? createdAt,
    DateTime? lastSeenAt,
    bool? isFavorite,
    bool? isOnline,
  }) {
    return ContactModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      contactUserId: contactUserId ?? this.contactUserId,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      email: email ?? this.email,
      avatar: avatar ?? this.avatar,
      phone: phone ?? this.phone,
      role: role ?? this.role,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      lastSeenAt: lastSeenAt ?? this.lastSeenAt,
      isFavorite: isFavorite ?? this.isFavorite,
      isOnline: isOnline ?? this.isOnline,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ContactModel &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'ContactModel{id: $id, fullName: $fullName, status: $status}';
  }
}

class ContactRequestModel {
  final String id;
  final String requesterId;
  final String recipientId;
  final String requesterFirstName;
  final String requesterLastName;
  final String? requesterAvatar;
  final String? message;
  final ContactRequestStatus status;
  final DateTime createdAt;

  ContactRequestModel({
    required this.id,
    required this.requesterId,
    required this.recipientId,
    required this.requesterFirstName,
    required this.requesterLastName,
    this.requesterAvatar,
    this.message,
    required this.status,
    required this.createdAt,
  });

  String get requesterFullName => '$requesterFirstName $requesterLastName';

  factory ContactRequestModel.fromJson(Map<String, dynamic> json) {
    return ContactRequestModel(
      id: json['id']?.toString() ?? '',
      requesterId: json['requester_id']?.toString() ?? '',
      recipientId: json['recipient_id']?.toString() ?? '',
      requesterFirstName: json['requester_first_name']?.toString() ?? '',
      requesterLastName: json['requester_last_name']?.toString() ?? '',
      requesterAvatar: json['requester_avatar']?.toString(),
      message: json['message']?.toString(),
      status: ContactRequestStatus.values.firstWhere(
        (e) => e.name == (json['status'] ?? 'pending'),
        orElse: () => ContactRequestStatus.pending,
      ),
      createdAt: DateTime.parse(json['created_at'] ?? DateTime.now().toIso8601String()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'requester_id': requesterId,
      'recipient_id': recipientId,
      'requester_first_name': requesterFirstName,
      'requester_last_name': requesterLastName,
      'requester_avatar': requesterAvatar,
      'message': message,
      'status': status.name,
      'created_at': createdAt.toIso8601String(),
    }..removeWhere((key, value) => value == null);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ContactRequestModel &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'ContactRequestModel{id: $id, requester: $requesterFullName, status: $status}';
  }
}
