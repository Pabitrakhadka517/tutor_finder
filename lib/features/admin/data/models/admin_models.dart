import '../../domain/entities/admin_entities.dart';

class AdminUserModel extends AdminUserEntity {
  const AdminUserModel({
    required super.id,
    required super.fullName,
    required super.email,
    required super.role,
    super.profileImage,
    super.phone,
    super.balance,
    super.isActive,
    required super.createdAt,
    required super.updatedAt,
  });

  factory AdminUserModel.fromJson(Map<String, dynamic> json) {
    return AdminUserModel(
      id: json['_id']?.toString() ?? json['id']?.toString() ?? '',
      fullName: json['fullName']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      role: json['role']?.toString() ?? 'student',
      profileImage: json['profileImage']?.toString(),
      phone: json['phone']?.toString(),
      balance: (json['balance'] is num) ? (json['balance'] as num).toDouble() : 0.0,
      isActive: json['isActive'] != false,
      createdAt: DateTime.tryParse(json['createdAt']?.toString() ?? '') ?? DateTime.now(),
      updatedAt: DateTime.tryParse(json['updatedAt']?.toString() ?? '') ?? DateTime.now(),
    );
  }
}

class PlatformStatsModel extends PlatformStatsEntity {
  const PlatformStatsModel({
    super.totalUsers,
    super.totalStudents,
    super.totalTutors,
    super.totalAdmins,
    super.totalBookings,
    super.totalTransactions,
    super.totalRevenue,
    super.pendingVerifications,
  });

  factory PlatformStatsModel.fromJson(Map<String, dynamic> json) {
    return PlatformStatsModel(
      totalUsers: json['totalUsers'] as int? ?? 0,
      totalStudents: json['totalStudents'] as int? ?? 0,
      totalTutors: json['totalTutors'] as int? ?? 0,
      totalAdmins: json['totalAdmins'] as int? ?? 0,
      totalBookings: json['totalBookings'] as int? ?? 0,
      totalTransactions: json['totalTransactions'] as int? ?? 0,
      totalRevenue: (json['totalRevenue'] is num) ? (json['totalRevenue'] as num).toDouble() : 0.0,
      pendingVerifications: json['pendingVerifications'] as int? ?? 0,
    );
  }
}

class AnnouncementModel extends AnnouncementEntity {
  const AnnouncementModel({
    required super.id,
    required super.title,
    required super.content,
    super.targetRole,
    super.type,
    super.createdById,
    super.createdByName,
    super.isActive,
    super.expiresAt,
    required super.createdAt,
    required super.updatedAt,
  });

  factory AnnouncementModel.fromJson(Map<String, dynamic> json) {
    // Parse createdBy
    String? createdById;
    String? createdByName;
    if (json['createdBy'] is Map) {
      final c = json['createdBy'] as Map<String, dynamic>;
      createdById = c['_id']?.toString();
      createdByName = c['fullName']?.toString();
    } else {
      createdById = json['createdBy']?.toString();
    }

    return AnnouncementModel(
      id: json['_id']?.toString() ?? json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      content: json['content']?.toString() ?? '',
      targetRole: json['targetRole']?.toString() ?? 'ALL',
      type: json['type']?.toString() ?? 'INFO',
      createdById: createdById,
      createdByName: createdByName,
      isActive: json['isActive'] != false,
      expiresAt: json['expiresAt'] != null
          ? DateTime.tryParse(json['expiresAt'].toString())
          : null,
      createdAt: DateTime.tryParse(json['createdAt']?.toString() ?? '') ?? DateTime.now(),
      updatedAt: DateTime.tryParse(json['updatedAt']?.toString() ?? '') ?? DateTime.now(),
    );
  }
}
