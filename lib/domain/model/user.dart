class User {
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
  final String deletedAt;
  final List<String> features;

  const User({
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
    required this.deletedAt,
    required this.features,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
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
      deletedAt: json['deletedAt'] as String? ?? '',
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
      'features': features,
    };
  }
}