import 'package:dio/dio.dart';

import '../models/availability_slot_dto.dart';
import '../models/tutor_detail_dto.dart';
import '../models/tutor_list_response_dto.dart';
import 'tutor_remote_datasource.dart';

/// Implementation of tutor remote data source using Dio HTTP client.
/// Handles all API communication for tutor-related operations.
class TutorRemoteDatasourceImpl implements TutorRemoteDatasource {
  const TutorRemoteDatasourceImpl({required this.dio});

  final Dio dio;

  @override
  Future<TutorListResponseDto> getTutors(Map<String, dynamic> query) async {
    try {
      final response = await dio.get('/tutors', queryParameters: query);

      if (response.statusCode == 200) {
        return TutorListResponseDto.fromJson(response.data);
      } else {
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
          type: DioExceptionType.badResponse,
        );
      }
    } on DioException {
      rethrow;
    } catch (e) {
      throw DioException(
        requestOptions: RequestOptions(path: '/tutors'),
        error: e,
        type: DioExceptionType.unknown,
      );
    }
  }

  @override
  Future<TutorDetailDto> getTutorById(String tutorId) async {
    try {
      final response = await dio.get('/tutors/$tutorId');

      if (response.statusCode == 200) {
        return TutorDetailDto.fromJson(response.data['data']);
      } else {
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
          type: DioExceptionType.badResponse,
        );
      }
    } on DioException {
      rethrow;
    } catch (e) {
      throw DioException(
        requestOptions: RequestOptions(path: '/tutors/$tutorId'),
        error: e,
        type: DioExceptionType.unknown,
      );
    }
  }

  @override
  Future<List<AvailabilitySlotDto>> getMyAvailability() async {
    try {
      final response = await dio.get('/tutors/my/availability');

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data['data'] ?? [];
        return data.map((json) => AvailabilitySlotDto.fromJson(json)).toList();
      } else {
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
          type: DioExceptionType.badResponse,
        );
      }
    } on DioException {
      rethrow;
    } catch (e) {
      throw DioException(
        requestOptions: RequestOptions(path: '/tutors/my/availability'),
        error: e,
        type: DioExceptionType.unknown,
      );
    }
  }

  @override
  Future<void> setAvailability(List<Map<String, dynamic>> slots) async {
    try {
      final response = await dio.post(
        '/tutors/my/availability',
        data: {'slots': slots},
      );

      if (response.statusCode != 200 && response.statusCode != 201) {
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
          type: DioExceptionType.badResponse,
        );
      }
    } on DioException {
      rethrow;
    } catch (e) {
      throw DioException(
        requestOptions: RequestOptions(path: '/tutors/my/availability'),
        error: e,
        type: DioExceptionType.unknown,
      );
    }
  }

  @override
  Future<void> submitVerification() async {
    try {
      final response = await dio.post('/tutors/my/verify/submit');

      if (response.statusCode != 200 && response.statusCode != 201) {
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
          type: DioExceptionType.badResponse,
        );
      }
    } on DioException {
      rethrow;
    } catch (e) {
      throw DioException(
        requestOptions: RequestOptions(path: '/tutors/my/verify/submit'),
        error: e,
        type: DioExceptionType.unknown,
      );
    }
  }
}
