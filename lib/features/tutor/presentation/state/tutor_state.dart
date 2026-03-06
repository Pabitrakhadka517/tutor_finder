import 'package:equatable/equatable.dart';
import '../../domain/entities/tutor_entity.dart';

/// State for the tutor list screen
class TutorListState extends Equatable {
  final bool isLoading;
  final List<TutorEntity> tutors;
  final String? errorMessage;
  final int currentPage;
  final bool hasMore;
  final String? searchQuery;
  final String? selectedSpeciality;

  const TutorListState({
    this.isLoading = false,
    this.tutors = const [],
    this.errorMessage,
    this.currentPage = 1,
    this.hasMore = true,
    this.searchQuery,
    this.selectedSpeciality,
  });

  TutorListState copyWith({
    bool? isLoading,
    List<TutorEntity>? tutors,
    String? errorMessage,
    int? currentPage,
    bool? hasMore,
    String? searchQuery,
    String? selectedSpeciality,
  }) {
    return TutorListState(
      isLoading: isLoading ?? this.isLoading,
      tutors: tutors ?? this.tutors,
      errorMessage: errorMessage,
      currentPage: currentPage ?? this.currentPage,
      hasMore: hasMore ?? this.hasMore,
      searchQuery: searchQuery ?? this.searchQuery,
      selectedSpeciality: selectedSpeciality ?? this.selectedSpeciality,
    );
  }

  @override
  List<Object?> get props => [
    isLoading,
    tutors,
    errorMessage,
    currentPage,
    hasMore,
    searchQuery,
    selectedSpeciality,
  ];
}

/// State for a single tutor detail
class TutorDetailState extends Equatable {
  final bool isLoading;
  final TutorEntity? tutor;
  final String? errorMessage;

  const TutorDetailState({
    this.isLoading = false,
    this.tutor,
    this.errorMessage,
  });

  TutorDetailState copyWith({
    bool? isLoading,
    TutorEntity? tutor,
    String? errorMessage,
  }) {
    return TutorDetailState(
      isLoading: isLoading ?? this.isLoading,
      tutor: tutor ?? this.tutor,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [isLoading, tutor, errorMessage];
}
