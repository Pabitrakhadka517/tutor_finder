import 'package:equatable/equatable.dart';
import '../../domain/entities/study_resource_entity.dart';

class StudyState extends Equatable {
  final bool isLoading;
  final String? error;
  final List<StudyResourceEntity> resources;
  final List<StudyResourceEntity> myResources;
  final bool uploadSuccess;
  final String? successMessage;

  const StudyState({
    this.isLoading = false,
    this.error,
    this.resources = const [],
    this.myResources = const [],
    this.uploadSuccess = false,
    this.successMessage,
  });

  StudyState copyWith({
    bool? isLoading,
    String? error,
    List<StudyResourceEntity>? resources,
    List<StudyResourceEntity>? myResources,
    bool? uploadSuccess,
    String? successMessage,
  }) {
    return StudyState(
      isLoading: isLoading ?? this.isLoading,
      error: error,
      resources: resources ?? this.resources,
      myResources: myResources ?? this.myResources,
      uploadSuccess: uploadSuccess ?? this.uploadSuccess,
      successMessage: successMessage,
    );
  }

  @override
  List<Object?> get props => [
        isLoading,
        error,
        resources,
        myResources,
        uploadSuccess,
        successMessage,
      ];
}
