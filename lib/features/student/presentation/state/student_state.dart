import 'package:equatable/equatable.dart';
import '../../domain/entities/student_profile_entity.dart';
import '../../../auth/domain/entities/user.dart';

/// State for the student home / dashboard screen.
class StudentState extends Equatable {
  final bool isLoading;
  final StudentProfileEntity? profile;
  final List<User> recommendedTutors;
  final String? errorMessage;

  const StudentState({
    this.isLoading = false,
    this.profile,
    this.recommendedTutors = const [],
    this.errorMessage,
  });

  StudentState copyWith({
    bool? isLoading,
    StudentProfileEntity? profile,
    List<User>? recommendedTutors,
    String? errorMessage,
  }) {
    return StudentState(
      isLoading: isLoading ?? this.isLoading,
      profile: profile ?? this.profile,
      recommendedTutors: recommendedTutors ?? this.recommendedTutors,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [
    isLoading,
    profile,
    recommendedTutors,
    errorMessage,
  ];
}

/// State for the tutor search screen (from student perspective).
class StudentSearchState extends Equatable {
  final bool isLoading;
  final List<User> results;
  final String query;
  final String? subject;
  final int currentPage;
  final bool hasMore;
  final String? errorMessage;

  const StudentSearchState({
    this.isLoading = false,
    this.results = const [],
    this.query = '',
    this.subject,
    this.currentPage = 1,
    this.hasMore = true,
    this.errorMessage,
  });

  StudentSearchState copyWith({
    bool? isLoading,
    List<User>? results,
    String? query,
    String? subject,
    int? currentPage,
    bool? hasMore,
    String? errorMessage,
  }) {
    return StudentSearchState(
      isLoading: isLoading ?? this.isLoading,
      results: results ?? this.results,
      query: query ?? this.query,
      subject: subject ?? this.subject,
      currentPage: currentPage ?? this.currentPage,
      hasMore: hasMore ?? this.hasMore,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [
    isLoading,
    results,
    query,
    subject,
    currentPage,
    hasMore,
    errorMessage,
  ];
}
