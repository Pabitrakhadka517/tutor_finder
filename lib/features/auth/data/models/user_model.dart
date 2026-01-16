import 'package:hive/hive.dart';
import '../../domain/entities/user.dart';

part 'user_model.g.dart';

/// Data model for User with Hive support
/// This extends the domain entity and adds serialization
@HiveType(typeId: 0)
class UserModel extends User {
  @HiveField(0)
  final String hiveId;

  @HiveField(1)
  final String hiveEmail;

  @HiveField(2)
  final String hiveName;

  @HiveField(3)
  final String hashedPassword;

  @HiveField(4)
  final DateTime hiveCreatedAt;

  @HiveField(5)
  final String hiveRole;

  const UserModel({
    required this.hiveId,
    required this.hiveEmail,
    required this.hiveName,
    required this.hashedPassword,
    required this.hiveCreatedAt,
    this.hiveRole = 'student',
  }) : super(
         id: hiveId,
         email: hiveEmail,
         name: hiveName,
         role: hiveRole == 'admin'
             ? UserRole.admin
             : hiveRole == 'tutor'
             ? UserRole.tutor
             : UserRole.student,
         createdAt: hiveCreatedAt,
       );

  /// Create from domain entity
  factory UserModel.fromEntity(User user, String hashedPassword) {
    return UserModel(
      hiveId: user.id,
      hiveEmail: user.email,
      hiveName: user.name,
      hashedPassword: hashedPassword,
      hiveCreatedAt: user.createdAt,
      hiveRole: user.role.name,
    );
  }

  /// Convert to domain entity
  User toEntity() {
    return User(
      id: hiveId,
      email: hiveEmail,
      name: hiveName,
      role: hiveRole == 'admin'
          ? UserRole.admin
          : hiveRole == 'tutor'
          ? UserRole.tutor
          : UserRole.student,
      createdAt: hiveCreatedAt,
    );
  }

  /// Create from JSON (for future API integration)
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      hiveId: json['id'] as String,
      hiveEmail: json['email'] as String,
      hiveName: json['name'] as String,
      hashedPassword: json['hashedPassword'] as String? ?? '',
      hiveCreatedAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : DateTime.now(),
      hiveRole: json['role'] as String? ?? 'student',
    );
  }

  /// Convert to JSON (for future API integration)
  Map<String, dynamic> toJson() {
    return {
      'id': hiveId,
      'email': hiveEmail,
      'name': hiveName,
      'hashedPassword': hashedPassword,
      'createdAt': hiveCreatedAt.toIso8601String(),
      'role': hiveRole,
    };
  }

  /// Copy with method for UserModel-specific fields
  @override
  User copyWith({
    String? id,
    String? email,
    String? name,
    UserRole? role,
    String? token,
    String? refreshToken,
    DateTime? createdAt,
  }) {
    return UserModel(
      hiveId: id ?? hiveId,
      hiveEmail: email ?? hiveEmail,
      hiveName: name ?? hiveName,
      hashedPassword: hashedPassword,
      hiveCreatedAt: createdAt ?? hiveCreatedAt,
      hiveRole: role?.name ?? hiveRole,
    );
  }

  /// Copy with method for UserModel-specific fields including hashedPassword
  UserModel copyWithModel({
    String? hiveId,
    String? hiveEmail,
    String? hiveName,
    String? hashedPassword,
    DateTime? hiveCreatedAt,
    String? hiveRole,
  }) {
    return UserModel(
      hiveId: hiveId ?? this.hiveId,
      hiveEmail: hiveEmail ?? this.hiveEmail,
      hiveName: hiveName ?? this.hiveName,
      hashedPassword: hashedPassword ?? this.hashedPassword,
      hiveCreatedAt: hiveCreatedAt ?? this.hiveCreatedAt,
      hiveRole: hiveRole ?? this.hiveRole,
    );
  }
}
