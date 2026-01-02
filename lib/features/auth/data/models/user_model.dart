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

  const UserModel({
    required this.hiveId,
    required this.hiveEmail,
    required this.hiveName,
    required this.hashedPassword,
    required this.hiveCreatedAt,
  }) : super(
         id: hiveId,
         email: hiveEmail,
         name: hiveName,
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
    );
  }

  /// Convert to domain entity
  User toEntity() {
    return User(
      id: hiveId,
      email: hiveEmail,
      name: hiveName,
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
    };
  }

  /// Copy with method
  UserModel copyWith({
    String? hiveId,
    String? hiveEmail,
    String? hiveName,
    String? hashedPassword,
    DateTime? hiveCreatedAt,
  }) {
    return UserModel(
      hiveId: hiveId ?? this.hiveId,
      hiveEmail: hiveEmail ?? this.hiveEmail,
      hiveName: hiveName ?? this.hiveName,
      hashedPassword: hashedPassword ?? this.hashedPassword,
      hiveCreatedAt: hiveCreatedAt ?? this.hiveCreatedAt,
    );
  }
}
