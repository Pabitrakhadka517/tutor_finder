import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/study_repository.dart';
import '../state/study_state.dart';

class StudyNotifier extends StateNotifier<StudyState> {
  final StudyRepository repository;

  StudyNotifier({required this.repository}) : super(const StudyState());

  /// Fetch public study resources
  Future<void> fetchResources({String? category}) async {
    state = state.copyWith(isLoading: true, error: null);

    final result = await repository.getResources(category: category);
    result.fold(
      (failure) => state = state.copyWith(
        isLoading: false,
        error: failure.message,
      ),
      (resources) => state = state.copyWith(
        isLoading: false,
        resources: resources,
      ),
    );
  }

  /// Fetch tutor's own resources
  Future<void> fetchMyResources() async {
    state = state.copyWith(isLoading: true, error: null);

    final result = await repository.getMyResources();
    result.fold(
      (failure) => state = state.copyWith(
        isLoading: false,
        error: failure.message,
      ),
      (resources) => state = state.copyWith(
        isLoading: false,
        myResources: resources,
      ),
    );
  }

  /// Upload a study resource
  Future<bool> uploadResource({
    required String title,
    required String category,
    required String type,
    required String filePath,
    bool isPublic = true,
  }) async {
    state = state.copyWith(isLoading: true, error: null, uploadSuccess: false);

    final result = await repository.uploadResource(
      title: title,
      category: category,
      type: type,
      filePath: filePath,
      isPublic: isPublic,
    );

    return result.fold(
      (failure) {
        state = state.copyWith(isLoading: false, error: failure.message);
        return false;
      },
      (resource) {
        state = state.copyWith(
          isLoading: false,
          uploadSuccess: true,
          successMessage: 'Resource uploaded successfully!',
          myResources: [resource, ...state.myResources],
        );
        return true;
      },
    );
  }

  /// Delete a study resource
  Future<bool> deleteResource(String id) async {
    state = state.copyWith(isLoading: true, error: null);

    final result = await repository.deleteResource(id);
    return result.fold(
      (failure) {
        state = state.copyWith(isLoading: false, error: failure.message);
        return false;
      },
      (_) {
        state = state.copyWith(
          isLoading: false,
          myResources: state.myResources.where((r) => r.id != id).toList(),
          resources: state.resources.where((r) => r.id != id).toList(),
          successMessage: 'Resource deleted',
        );
        return true;
      },
    );
  }
}
