import 'package:dio/dio.dart';
import '../../../../../core/api/api_client.dart';
import '../../../../../core/api/api_endpoints.dart';
import '../../models/tutor_model.dart';
import '../../models/availability_slot_model.dart';
import '../tutor_remote_datasource.dart';

/// Implementation of TutorRemoteDataSource using Dio
class TutorRemoteDataSourceImpl implements TutorRemoteDataSource {
  final ApiClient apiClient;

  TutorRemoteDataSourceImpl({required this.apiClient});

  List<dynamic> _extractSlots(dynamic data) {
    if (data is List) {
      return data;
    }

    if (data is Map<String, dynamic>) {
      final directSlots = data['slots'];
      if (directSlots is List) {
        return directSlots;
      }

      final nestedData = data['data'];
      if (nestedData is Map<String, dynamic>) {
        final nestedSlots = nestedData['slots'];
        if (nestedSlots is List) {
          return nestedSlots;
        }
      }
    }

    return const [];
  }

  @override
  Future<List<TutorModel>> getTutors({
    int page = 1,
    int limit = 10,
    String? search,
    String? speciality,
    String? sortBy,
    String? order,
  }) async {
    try {
      final queryParams = <String, dynamic>{'page': page, 'limit': limit};
      if (search != null && search.isNotEmpty) queryParams['search'] = search;
      if (speciality != null && speciality.isNotEmpty) {
        queryParams['speciality'] = speciality;
      }
      if (sortBy != null) queryParams['sortBy'] = sortBy;
      if (order != null) queryParams['order'] = order;

      final response = await apiClient.get(
        ApiEndpoints.tutors,
        queryParameters: queryParams,
      );

      final data = response.data;
      final tutorsJson = data['tutors'] as List? ?? [];
      return tutorsJson
          .map((json) => TutorModel.fromJson(json as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw Exception(e.response?.data?['message'] ?? 'Failed to fetch tutors');
    }
  }

  @override
  Future<TutorModel> getTutorById(String id) async {
    try {
      final response = await apiClient.get(ApiEndpoints.tutorById(id));
      final data = response.data;
      return TutorModel.fromJson(data['tutor'] ?? data);
    } on DioException catch (e) {
      throw Exception(
        e.response?.data?['message'] ?? 'Failed to fetch tutor details',
      );
    }
  }

  @override
  Future<List<AvailabilitySlotModel>> getMyAvailability({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      final queryParams = <String, dynamic>{};
      if (startDate != null) {
        queryParams['startDate'] = startDate.toIso8601String();
      }
      if (endDate != null) {
        queryParams['endDate'] = endDate.toIso8601String();
      }

      final response = await apiClient.get(
        ApiEndpoints.myAvailability,
        queryParameters: queryParams,
      );

      final data = response.data;
      final slotsJson = _extractSlots(data);
      return slotsJson
          .map(
            (json) =>
                AvailabilitySlotModel.fromJson(json as Map<String, dynamic>),
          )
          .toList();
    } on DioException catch (e) {
      throw Exception(
        e.response?.data?['message'] ?? 'Failed to fetch availability',
      );
    }
  }

  @override
  Future<List<AvailabilitySlotModel>> getTutorAvailability(
    String tutorId, {
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      final queryParams = <String, dynamic>{};
      if (startDate != null) {
        queryParams['startDate'] = startDate.toIso8601String();
      }
      if (endDate != null) {
        queryParams['endDate'] = endDate.toIso8601String();
      }

      final response = await apiClient.get(
        ApiEndpoints.tutorAvailability(tutorId),
        queryParameters: queryParams,
      );

      final data = response.data;
      final slotsJson = _extractSlots(data);
      return slotsJson
          .map(
            (json) =>
                AvailabilitySlotModel.fromJson(json as Map<String, dynamic>),
          )
          .toList();
    } on DioException catch (e) {
      throw Exception(
        e.response?.data?['message'] ?? 'Failed to fetch tutor availability',
      );
    }
  }

  @override
  Future<void> setAvailability(List<AvailabilitySlotModel> slots) async {
    try {
      await apiClient.post(
        ApiEndpoints.myAvailability,
        data: {'slots': slots.map((s) => s.toJson()).toList()},
      );
    } on DioException catch (e) {
      throw Exception(
        e.response?.data?['message'] ?? 'Failed to set availability',
      );
    }
  }

  @override
  Future<void> submitForVerification() async {
    try {
      await apiClient.post(ApiEndpoints.submitVerification);
    } on DioException catch (e) {
      throw Exception(
        e.response?.data?['message'] ?? 'Failed to submit for verification',
      );
    }
  }
}
