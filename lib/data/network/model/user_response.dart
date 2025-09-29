import 'package:flutter_camera/domain/model/user.dart';

class UserResponse {
  final int id;
  final String username;
  final String email;
  final String fullName;
  final String firstName;
  final String lastMiddleName;
  final String phone;
  final String telegramUsername;
  final double telegramChatId;
  final String status;
  final String roleNames;
  final bool isNewUser;
  final String displayStatus;
  final String createdAt;
  final String updatedAt;
  final String? deletedAt;
  final List<dynamic> areas;
  final List<dynamic> areaIds;
  final List<dynamic> roles;
  final List<dynamic> pageSettings;
  final List<String> features;

  const UserResponse({
    required this.id,
    required this.username,
    required this.email,
    required this.fullName,
    required this.firstName,
    required this.lastMiddleName,
    required this.phone,
    required this.telegramUsername,
    required this.telegramChatId,
    required this.status,
    required this.roleNames,
    required this.isNewUser,
    required this.displayStatus,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
    required this.areas,
    required this.areaIds,
    required this.roles,
    required this.pageSettings,
    required this.features,
  });

  factory UserResponse.fromJson(Map<String, dynamic> json) {
    return UserResponse(
      id: json['id'] as int? ?? 0,
      username: json['username'] as String? ?? '',
      email: json['email'] as String? ?? '',
      fullName: json['fullName'] as String? ?? '',
      firstName: json['firstName'] as String? ?? '',
      lastMiddleName: json['lastMiddleName'] as String? ?? '',
      phone: json['phone'] as String? ?? '',
      telegramUsername: json['telegramUsername'] as String? ?? '',
      telegramChatId: (json['telegramChatId'] as num?)?.toDouble() ?? 0.0,
      status: json['status'] as String? ?? '',
      roleNames: json['roleNames'] as String? ?? '',
      isNewUser: json['isNewUser'] as bool? ?? false,
      displayStatus: json['displayStatus'] as String? ?? '',
      createdAt: json['createdAt'] as String? ?? '',
      updatedAt: json['updatedAt'] as String? ?? '',
      deletedAt: json['deletedAt'] as String?,
      areas: json['areas'] as List<dynamic>? ?? [],
      areaIds: json['areaIds'] as List<dynamic>? ?? [],
      roles: json['roles'] as List<dynamic>? ?? [],
      pageSettings: json['pageSettings'] as List<dynamic>? ?? [],
      features: (json['features'] as List<dynamic>?)?.cast<String>() ?? [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'email': email,
      'fullName': fullName,
      'firstName': firstName,
      'lastMiddleName': lastMiddleName,
      'phone': phone,
      'telegramUsername': telegramUsername,
      'telegramChatId': telegramChatId,
      'status': status,
      'roleNames': roleNames,
      'isNewUser': isNewUser,
      'displayStatus': displayStatus,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
      'deletedAt': deletedAt,
      'areas': areas,
      'areaIds': areaIds,
      'roles': roles,
      'pageSettings': pageSettings,
      'features': features,
    };
  }
}

extension UserResponseExtension on UserResponse {
  // Convert to domain entity
  User toEntity() {
    return User(
      id: id,
      username: username,
      email: email,
      fullName: fullName,
      firstName: firstName,
      lastMiddleName: lastMiddleName,
      phone: phone,
      telegramUsername: telegramUsername,
      telegramChatId: telegramChatId,
      status: status,
      roleNames: roleNames,
      isNewUser: isNewUser,
      displayStatus: displayStatus,
      createdAt: createdAt,
      updatedAt: updatedAt,
      deletedAt: deletedAt ?? '',
      features: features,
    );
  }

  // Convert from domain entity
  static UserResponse fromEntity(User user) {
    return UserResponse(
      id: user.id,
      username: user.username,
      email: user.email,
      fullName: user.fullName,
      firstName: user.firstName,
      lastMiddleName: user.lastMiddleName,
      phone: user.phone,
      telegramUsername: user.telegramUsername,
      telegramChatId: user.telegramChatId,
      status: user.status,
      roleNames: user.roleNames,
      isNewUser: user.isNewUser,
      displayStatus: user.displayStatus,
      createdAt: user.createdAt,
      updatedAt: user.updatedAt,
      deletedAt: user.deletedAt,
      areas: [],
      areaIds: [],
      roles: [],
      pageSettings: [],
      features: user.features,
    );
  }
}
