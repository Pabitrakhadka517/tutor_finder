import '../../../../core/api/api_endpoints.dart';
import '../../domain/entities/tutor_entity.dart';

/// Data model for Tutor with JSON serialization
class TutorModel extends TutorEntity {
  const TutorModel({
    required super.id,
    required super.fullName,
    required super.email,
    super.phone,
    super.profileImage,
    super.speciality,
    super.address,
    super.bio,
    super.experienceYears,
    super.hourlyRate,
    super.languages,
    super.subjects,
    super.verificationStatus,
    super.totalClasses,
    super.averageRating,
    super.totalReviews,
    super.createdAt,
  });

  /// Parse from API JSON response
  /// The backend returns tutor data with nested `user` and `tutorProfile` fields
  factory TutorModel.fromJson(Map<String, dynamic> json) {
    // Handle nested user object or flat structure
    final userData = json['user'] as Map<String, dynamic>? ?? json;
    final tutorProfile = json['tutorProfile'] as Map<String, dynamic>? ?? json;

    return TutorModel(
      id: userData['_id'] ?? userData['id'] ?? json['_id'] ?? json['id'] ?? '',
      fullName:
          userData['fullName'] ?? userData['name'] ?? json['fullName'] ?? '',
      email: userData['email'] ?? json['email'] ?? '',
      phone: userData['phone'] ?? json['phone'],
      profileImage: ApiEndpoints.getImageUrl(
        userData['profileImage'] ?? json['profileImage'],
      ),
      speciality: userData['speciality'] ?? json['speciality'],
      address: userData['address'] ?? json['address'],
      bio: tutorProfile['bio'] ?? json['bio'] ?? '',
      experienceYears: _toInt(
        tutorProfile['experienceYears'] ?? json['experienceYears'],
      ),
      hourlyRate: _toDouble(tutorProfile['hourlyRate'] ?? json['hourlyRate']),
      languages: _toStringList(tutorProfile['languages'] ?? json['languages']),
      subjects: _toStringList(tutorProfile['subjects'] ?? json['subjects']),
      verificationStatus:
          tutorProfile['verificationStatus'] ??
          json['verificationStatus'] ??
          'PENDING',
      totalClasses: _toInt(
        tutorProfile['totalClasses'] ?? json['totalClasses'],
      ),
      averageRating: _toDouble(
        tutorProfile['averageRating'] ??
            tutorProfile['rating'] ??
            json['averageRating'] ??
            json['rating'],
      ),
      totalReviews: _toInt(
        tutorProfile['totalReviews'] ??
            tutorProfile['reviewsCount'] ??
            json['totalReviews'],
      ),
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'].toString())
          : null,
    );
  }

  static int _toInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is double) return value.toInt();
    return int.tryParse(value.toString()) ?? 0;
  }

  static double _toDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    return double.tryParse(value.toString()) ?? 0.0;
  }

  static List<String> _toStringList(dynamic value) {
    if (value == null) return [];
    if (value is List) return value.map((e) => e.toString()).toList();
    return [];
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'fullName': fullName,
      'email': email,
      'phone': phone,
      'profileImage': profileImage,
      'speciality': speciality,
      'address': address,
      'bio': bio,
      'experienceYears': experienceYears,
      'hourlyRate': hourlyRate,
      'languages': languages,
      'subjects': subjects,
      'verificationStatus': verificationStatus,
      'totalClasses': totalClasses,
      'averageRating': averageRating,
      'totalReviews': totalReviews,
    };
  }
}
