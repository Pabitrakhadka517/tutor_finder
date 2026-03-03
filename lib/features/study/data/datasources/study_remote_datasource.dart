import 'package:dio/dio.dart';
import '../../../../core/api/api_client.dart';
import '../../../../core/api/api_endpoints.dart';
import '../../../../core/error/exceptions.dart';
import '../models/study_resource_model.dart';

abstract class StudyRemoteDataSource {
  Future<List<StudyResourceModel>> getResources({String? category});
  Future<List<StudyResourceModel>> getMyResources();
  Future<StudyResourceModel> uploadResource({
    required String title,
    required String category,
    required String type,
    required String filePath,
    bool isPublic,
  });
  Future<void> deleteResource(String id);
}

class StudyRemoteDataSourceImpl implements StudyRemoteDataSource {
  final ApiClient apiClient;
  StudyRemoteDataSourceImpl({required this.apiClient});

  List<dynamic> _extractResourcesList(dynamic data) {
    if (data is! Map) return const [];

    final direct = data['resources'];
    if (direct is List) return direct;

    final wrapped = data['data'];
    if (wrapped is Map && wrapped['resources'] is List) {
      return wrapped['resources'] as List;
    }

    return const [];
  }

  Map<String, dynamic>? _extractResourceMap(dynamic data) {
    if (data is! Map) return null;

    final direct = data['resource'];
    if (direct is Map<String, dynamic>) return direct;

    final wrapped = data['data'];
    if (wrapped is Map && wrapped['resource'] is Map<String, dynamic>) {
      return wrapped['resource'] as Map<String, dynamic>;
    }

    return null;
  }

  @override
  Future<List<StudyResourceModel>> getResources({String? category}) async {
    try {
      final queryParams = <String, dynamic>{};
      if (category != null && category.isNotEmpty) {
        queryParams['category'] = category;
      }

      final response = await apiClient.dio.get(
        ApiEndpoints.studyResources,
        queryParameters: queryParams,
      );

      if (response.statusCode == 200) {
        final list = _extractResourcesList(response.data);
        return list
            .map((r) => StudyResourceModel.fromJson(r as Map<String, dynamic>))
            .toList();
      }
      throw ServerException('Failed to fetch resources');
    } on DioException catch (e) {
      throw ServerException(
        e.response?.data['message'] ?? 'Failed to fetch resources',
      );
    }
  }

  @override
  Future<List<StudyResourceModel>> getMyResources() async {
    try {
      final response = await apiClient.dio.get(ApiEndpoints.myStudyResources);

      if (response.statusCode == 200) {
        final list = _extractResourcesList(response.data);
        return list
            .map((r) => StudyResourceModel.fromJson(r as Map<String, dynamic>))
            .toList();
      }
      throw ServerException('Failed to fetch my resources');
    } on DioException catch (e) {
      throw ServerException(
        e.response?.data['message'] ?? 'Failed to fetch my resources',
      );
    }
  }

  @override
  Future<StudyResourceModel> uploadResource({
    required String title,
    required String category,
    required String type,
    required String filePath,
    bool isPublic = true,
  }) async {
    try {
      final formData = FormData.fromMap({
        'title': title,
        'category': category,
        'type': type,
        'isPublic': isPublic,
        'resource': await MultipartFile.fromFile(filePath),
      });

      final response = await apiClient.dio.post(
        ApiEndpoints.studyUpload,
        data: formData,
        options: Options(contentType: 'multipart/form-data'),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        final resource = _extractResourceMap(response.data);
        if (resource == null) {
          throw ServerException('Failed to parse uploaded resource');
        }
        return StudyResourceModel.fromJson(resource);
      }
      throw ServerException(
        response.data['message'] ?? 'Failed to upload resource',
      );
    } on DioException catch (e) {
      throw ServerException(
        e.response?.data['message'] ?? 'Failed to upload resource',
      );
    }
  }

  @override
  Future<void> deleteResource(String id) async {
    try {
      final response = await apiClient.dio.delete(
        ApiEndpoints.deleteStudyResource(id),
      );

      if (response.statusCode == 200) return;
      throw ServerException(
        response.data['message'] ?? 'Failed to delete resource',
      );
    } on DioException catch (e) {
      throw ServerException(
        e.response?.data['message'] ?? 'Failed to delete resource',
      );
    }
  }
}
