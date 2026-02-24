import 'package:hive/hive.dart';

part 'user_hive_model.g.dart';

/// Hive-persisted model for cached user data.
///
/// Tokens are stored in a **separate** Hive box (`auth_tokens`) – NOT in this
/// model – so they can be managed independently and securely.
@HiveType(typeId: 10)
class UserHiveModel extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String email;

  @HiveField(2)
  final String name;

  @HiveField(3)
  final String role;

  @HiveField(4)
  final String? createdAt;

  UserHiveModel({
    required this.id,
    required this.email,
    required this.name,
    required this.role,
    this.createdAt,
  });
}
