// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'dashboard_dto.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

StudentDashboardDto _$StudentDashboardDtoFromJson(Map<String, dynamic> json) {
  return _StudentDashboardDto.fromJson(json);
}

/// @nodoc
mixin _$StudentDashboardDto {
  String get id => throw _privateConstructorUsedError;
  String get studentId => throw _privateConstructorUsedError;
  int get totalBookings => throw _privateConstructorUsedError;
  int get upcomingBookings => throw _privateConstructorUsedError;
  int get completedBookings => throw _privateConstructorUsedError;
  int get cancelledBookings => throw _privateConstructorUsedError;
  double get totalSpent => throw _privateConstructorUsedError;
  double get averageSessionCost => throw _privateConstructorUsedError;
  int get totalHoursLearned => throw _privateConstructorUsedError;
  int get totalTutorsWorkedWith => throw _privateConstructorUsedError;
  List<String> get favoriteSubjects => throw _privateConstructorUsedError;
  List<RecentBookingDto> get recentBookings =>
      throw _privateConstructorUsedError;
  List<RecentTransactionDto> get recentTransactions =>
      throw _privateConstructorUsedError;
  StudentProgressDto? get progress => throw _privateConstructorUsedError;
  DateTime get lastUpdated => throw _privateConstructorUsedError;
  DateTime get createdAt => throw _privateConstructorUsedError;
  Map<String, dynamic>? get metadata => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $StudentDashboardDtoCopyWith<StudentDashboardDto> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $StudentDashboardDtoCopyWith<$Res> {
  factory $StudentDashboardDtoCopyWith(
          StudentDashboardDto value, $Res Function(StudentDashboardDto) then) =
      _$StudentDashboardDtoCopyWithImpl<$Res, StudentDashboardDto>;
  @useResult
  $Res call(
      {String id,
      String studentId,
      int totalBookings,
      int upcomingBookings,
      int completedBookings,
      int cancelledBookings,
      double totalSpent,
      double averageSessionCost,
      int totalHoursLearned,
      int totalTutorsWorkedWith,
      List<String> favoriteSubjects,
      List<RecentBookingDto> recentBookings,
      List<RecentTransactionDto> recentTransactions,
      StudentProgressDto? progress,
      DateTime lastUpdated,
      DateTime createdAt,
      Map<String, dynamic>? metadata});

  $StudentProgressDtoCopyWith<$Res>? get progress;
}

/// @nodoc
class _$StudentDashboardDtoCopyWithImpl<$Res, $Val extends StudentDashboardDto>
    implements $StudentDashboardDtoCopyWith<$Res> {
  _$StudentDashboardDtoCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? studentId = null,
    Object? totalBookings = null,
    Object? upcomingBookings = null,
    Object? completedBookings = null,
    Object? cancelledBookings = null,
    Object? totalSpent = null,
    Object? averageSessionCost = null,
    Object? totalHoursLearned = null,
    Object? totalTutorsWorkedWith = null,
    Object? favoriteSubjects = null,
    Object? recentBookings = null,
    Object? recentTransactions = null,
    Object? progress = freezed,
    Object? lastUpdated = null,
    Object? createdAt = null,
    Object? metadata = freezed,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      studentId: null == studentId
          ? _value.studentId
          : studentId // ignore: cast_nullable_to_non_nullable
              as String,
      totalBookings: null == totalBookings
          ? _value.totalBookings
          : totalBookings // ignore: cast_nullable_to_non_nullable
              as int,
      upcomingBookings: null == upcomingBookings
          ? _value.upcomingBookings
          : upcomingBookings // ignore: cast_nullable_to_non_nullable
              as int,
      completedBookings: null == completedBookings
          ? _value.completedBookings
          : completedBookings // ignore: cast_nullable_to_non_nullable
              as int,
      cancelledBookings: null == cancelledBookings
          ? _value.cancelledBookings
          : cancelledBookings // ignore: cast_nullable_to_non_nullable
              as int,
      totalSpent: null == totalSpent
          ? _value.totalSpent
          : totalSpent // ignore: cast_nullable_to_non_nullable
              as double,
      averageSessionCost: null == averageSessionCost
          ? _value.averageSessionCost
          : averageSessionCost // ignore: cast_nullable_to_non_nullable
              as double,
      totalHoursLearned: null == totalHoursLearned
          ? _value.totalHoursLearned
          : totalHoursLearned // ignore: cast_nullable_to_non_nullable
              as int,
      totalTutorsWorkedWith: null == totalTutorsWorkedWith
          ? _value.totalTutorsWorkedWith
          : totalTutorsWorkedWith // ignore: cast_nullable_to_non_nullable
              as int,
      favoriteSubjects: null == favoriteSubjects
          ? _value.favoriteSubjects
          : favoriteSubjects // ignore: cast_nullable_to_non_nullable
              as List<String>,
      recentBookings: null == recentBookings
          ? _value.recentBookings
          : recentBookings // ignore: cast_nullable_to_non_nullable
              as List<RecentBookingDto>,
      recentTransactions: null == recentTransactions
          ? _value.recentTransactions
          : recentTransactions // ignore: cast_nullable_to_non_nullable
              as List<RecentTransactionDto>,
      progress: freezed == progress
          ? _value.progress
          : progress // ignore: cast_nullable_to_non_nullable
              as StudentProgressDto?,
      lastUpdated: null == lastUpdated
          ? _value.lastUpdated
          : lastUpdated // ignore: cast_nullable_to_non_nullable
              as DateTime,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      metadata: freezed == metadata
          ? _value.metadata
          : metadata // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>?,
    ) as $Val);
  }

  @override
  @pragma('vm:prefer-inline')
  $StudentProgressDtoCopyWith<$Res>? get progress {
    if (_value.progress == null) {
      return null;
    }

    return $StudentProgressDtoCopyWith<$Res>(_value.progress!, (value) {
      return _then(_value.copyWith(progress: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$StudentDashboardDtoImplCopyWith<$Res>
    implements $StudentDashboardDtoCopyWith<$Res> {
  factory _$$StudentDashboardDtoImplCopyWith(_$StudentDashboardDtoImpl value,
          $Res Function(_$StudentDashboardDtoImpl) then) =
      __$$StudentDashboardDtoImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String studentId,
      int totalBookings,
      int upcomingBookings,
      int completedBookings,
      int cancelledBookings,
      double totalSpent,
      double averageSessionCost,
      int totalHoursLearned,
      int totalTutorsWorkedWith,
      List<String> favoriteSubjects,
      List<RecentBookingDto> recentBookings,
      List<RecentTransactionDto> recentTransactions,
      StudentProgressDto? progress,
      DateTime lastUpdated,
      DateTime createdAt,
      Map<String, dynamic>? metadata});

  @override
  $StudentProgressDtoCopyWith<$Res>? get progress;
}

/// @nodoc
class __$$StudentDashboardDtoImplCopyWithImpl<$Res>
    extends _$StudentDashboardDtoCopyWithImpl<$Res, _$StudentDashboardDtoImpl>
    implements _$$StudentDashboardDtoImplCopyWith<$Res> {
  __$$StudentDashboardDtoImplCopyWithImpl(_$StudentDashboardDtoImpl _value,
      $Res Function(_$StudentDashboardDtoImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? studentId = null,
    Object? totalBookings = null,
    Object? upcomingBookings = null,
    Object? completedBookings = null,
    Object? cancelledBookings = null,
    Object? totalSpent = null,
    Object? averageSessionCost = null,
    Object? totalHoursLearned = null,
    Object? totalTutorsWorkedWith = null,
    Object? favoriteSubjects = null,
    Object? recentBookings = null,
    Object? recentTransactions = null,
    Object? progress = freezed,
    Object? lastUpdated = null,
    Object? createdAt = null,
    Object? metadata = freezed,
  }) {
    return _then(_$StudentDashboardDtoImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      studentId: null == studentId
          ? _value.studentId
          : studentId // ignore: cast_nullable_to_non_nullable
              as String,
      totalBookings: null == totalBookings
          ? _value.totalBookings
          : totalBookings // ignore: cast_nullable_to_non_nullable
              as int,
      upcomingBookings: null == upcomingBookings
          ? _value.upcomingBookings
          : upcomingBookings // ignore: cast_nullable_to_non_nullable
              as int,
      completedBookings: null == completedBookings
          ? _value.completedBookings
          : completedBookings // ignore: cast_nullable_to_non_nullable
              as int,
      cancelledBookings: null == cancelledBookings
          ? _value.cancelledBookings
          : cancelledBookings // ignore: cast_nullable_to_non_nullable
              as int,
      totalSpent: null == totalSpent
          ? _value.totalSpent
          : totalSpent // ignore: cast_nullable_to_non_nullable
              as double,
      averageSessionCost: null == averageSessionCost
          ? _value.averageSessionCost
          : averageSessionCost // ignore: cast_nullable_to_non_nullable
              as double,
      totalHoursLearned: null == totalHoursLearned
          ? _value.totalHoursLearned
          : totalHoursLearned // ignore: cast_nullable_to_non_nullable
              as int,
      totalTutorsWorkedWith: null == totalTutorsWorkedWith
          ? _value.totalTutorsWorkedWith
          : totalTutorsWorkedWith // ignore: cast_nullable_to_non_nullable
              as int,
      favoriteSubjects: null == favoriteSubjects
          ? _value._favoriteSubjects
          : favoriteSubjects // ignore: cast_nullable_to_non_nullable
              as List<String>,
      recentBookings: null == recentBookings
          ? _value._recentBookings
          : recentBookings // ignore: cast_nullable_to_non_nullable
              as List<RecentBookingDto>,
      recentTransactions: null == recentTransactions
          ? _value._recentTransactions
          : recentTransactions // ignore: cast_nullable_to_non_nullable
              as List<RecentTransactionDto>,
      progress: freezed == progress
          ? _value.progress
          : progress // ignore: cast_nullable_to_non_nullable
              as StudentProgressDto?,
      lastUpdated: null == lastUpdated
          ? _value.lastUpdated
          : lastUpdated // ignore: cast_nullable_to_non_nullable
              as DateTime,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      metadata: freezed == metadata
          ? _value._metadata
          : metadata // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$StudentDashboardDtoImpl extends _StudentDashboardDto {
  const _$StudentDashboardDtoImpl(
      {required this.id,
      required this.studentId,
      required this.totalBookings,
      required this.upcomingBookings,
      required this.completedBookings,
      required this.cancelledBookings,
      required this.totalSpent,
      required this.averageSessionCost,
      required this.totalHoursLearned,
      required this.totalTutorsWorkedWith,
      required final List<String> favoriteSubjects,
      required final List<RecentBookingDto> recentBookings,
      required final List<RecentTransactionDto> recentTransactions,
      required this.progress,
      required this.lastUpdated,
      required this.createdAt,
      final Map<String, dynamic>? metadata})
      : _favoriteSubjects = favoriteSubjects,
        _recentBookings = recentBookings,
        _recentTransactions = recentTransactions,
        _metadata = metadata,
        super._();

  factory _$StudentDashboardDtoImpl.fromJson(Map<String, dynamic> json) =>
      _$$StudentDashboardDtoImplFromJson(json);

  @override
  final String id;
  @override
  final String studentId;
  @override
  final int totalBookings;
  @override
  final int upcomingBookings;
  @override
  final int completedBookings;
  @override
  final int cancelledBookings;
  @override
  final double totalSpent;
  @override
  final double averageSessionCost;
  @override
  final int totalHoursLearned;
  @override
  final int totalTutorsWorkedWith;
  final List<String> _favoriteSubjects;
  @override
  List<String> get favoriteSubjects {
    if (_favoriteSubjects is EqualUnmodifiableListView)
      return _favoriteSubjects;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_favoriteSubjects);
  }

  final List<RecentBookingDto> _recentBookings;
  @override
  List<RecentBookingDto> get recentBookings {
    if (_recentBookings is EqualUnmodifiableListView) return _recentBookings;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_recentBookings);
  }

  final List<RecentTransactionDto> _recentTransactions;
  @override
  List<RecentTransactionDto> get recentTransactions {
    if (_recentTransactions is EqualUnmodifiableListView)
      return _recentTransactions;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_recentTransactions);
  }

  @override
  final StudentProgressDto? progress;
  @override
  final DateTime lastUpdated;
  @override
  final DateTime createdAt;
  final Map<String, dynamic>? _metadata;
  @override
  Map<String, dynamic>? get metadata {
    final value = _metadata;
    if (value == null) return null;
    if (_metadata is EqualUnmodifiableMapView) return _metadata;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(value);
  }

  @override
  String toString() {
    return 'StudentDashboardDto(id: $id, studentId: $studentId, totalBookings: $totalBookings, upcomingBookings: $upcomingBookings, completedBookings: $completedBookings, cancelledBookings: $cancelledBookings, totalSpent: $totalSpent, averageSessionCost: $averageSessionCost, totalHoursLearned: $totalHoursLearned, totalTutorsWorkedWith: $totalTutorsWorkedWith, favoriteSubjects: $favoriteSubjects, recentBookings: $recentBookings, recentTransactions: $recentTransactions, progress: $progress, lastUpdated: $lastUpdated, createdAt: $createdAt, metadata: $metadata)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$StudentDashboardDtoImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.studentId, studentId) ||
                other.studentId == studentId) &&
            (identical(other.totalBookings, totalBookings) ||
                other.totalBookings == totalBookings) &&
            (identical(other.upcomingBookings, upcomingBookings) ||
                other.upcomingBookings == upcomingBookings) &&
            (identical(other.completedBookings, completedBookings) ||
                other.completedBookings == completedBookings) &&
            (identical(other.cancelledBookings, cancelledBookings) ||
                other.cancelledBookings == cancelledBookings) &&
            (identical(other.totalSpent, totalSpent) ||
                other.totalSpent == totalSpent) &&
            (identical(other.averageSessionCost, averageSessionCost) ||
                other.averageSessionCost == averageSessionCost) &&
            (identical(other.totalHoursLearned, totalHoursLearned) ||
                other.totalHoursLearned == totalHoursLearned) &&
            (identical(other.totalTutorsWorkedWith, totalTutorsWorkedWith) ||
                other.totalTutorsWorkedWith == totalTutorsWorkedWith) &&
            const DeepCollectionEquality()
                .equals(other._favoriteSubjects, _favoriteSubjects) &&
            const DeepCollectionEquality()
                .equals(other._recentBookings, _recentBookings) &&
            const DeepCollectionEquality()
                .equals(other._recentTransactions, _recentTransactions) &&
            (identical(other.progress, progress) ||
                other.progress == progress) &&
            (identical(other.lastUpdated, lastUpdated) ||
                other.lastUpdated == lastUpdated) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            const DeepCollectionEquality().equals(other._metadata, _metadata));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      studentId,
      totalBookings,
      upcomingBookings,
      completedBookings,
      cancelledBookings,
      totalSpent,
      averageSessionCost,
      totalHoursLearned,
      totalTutorsWorkedWith,
      const DeepCollectionEquality().hash(_favoriteSubjects),
      const DeepCollectionEquality().hash(_recentBookings),
      const DeepCollectionEquality().hash(_recentTransactions),
      progress,
      lastUpdated,
      createdAt,
      const DeepCollectionEquality().hash(_metadata));

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$StudentDashboardDtoImplCopyWith<_$StudentDashboardDtoImpl> get copyWith =>
      __$$StudentDashboardDtoImplCopyWithImpl<_$StudentDashboardDtoImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$StudentDashboardDtoImplToJson(
      this,
    );
  }
}

abstract class _StudentDashboardDto extends StudentDashboardDto {
  const factory _StudentDashboardDto(
      {required final String id,
      required final String studentId,
      required final int totalBookings,
      required final int upcomingBookings,
      required final int completedBookings,
      required final int cancelledBookings,
      required final double totalSpent,
      required final double averageSessionCost,
      required final int totalHoursLearned,
      required final int totalTutorsWorkedWith,
      required final List<String> favoriteSubjects,
      required final List<RecentBookingDto> recentBookings,
      required final List<RecentTransactionDto> recentTransactions,
      required final StudentProgressDto? progress,
      required final DateTime lastUpdated,
      required final DateTime createdAt,
      final Map<String, dynamic>? metadata}) = _$StudentDashboardDtoImpl;
  const _StudentDashboardDto._() : super._();

  factory _StudentDashboardDto.fromJson(Map<String, dynamic> json) =
      _$StudentDashboardDtoImpl.fromJson;

  @override
  String get id;
  @override
  String get studentId;
  @override
  int get totalBookings;
  @override
  int get upcomingBookings;
  @override
  int get completedBookings;
  @override
  int get cancelledBookings;
  @override
  double get totalSpent;
  @override
  double get averageSessionCost;
  @override
  int get totalHoursLearned;
  @override
  int get totalTutorsWorkedWith;
  @override
  List<String> get favoriteSubjects;
  @override
  List<RecentBookingDto> get recentBookings;
  @override
  List<RecentTransactionDto> get recentTransactions;
  @override
  StudentProgressDto? get progress;
  @override
  DateTime get lastUpdated;
  @override
  DateTime get createdAt;
  @override
  Map<String, dynamic>? get metadata;
  @override
  @JsonKey(ignore: true)
  _$$StudentDashboardDtoImplCopyWith<_$StudentDashboardDtoImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

TutorDashboardDto _$TutorDashboardDtoFromJson(Map<String, dynamic> json) {
  return _TutorDashboardDto.fromJson(json);
}

/// @nodoc
mixin _$TutorDashboardDto {
  String get id => throw _privateConstructorUsedError;
  String get tutorId => throw _privateConstructorUsedError;
  double get totalEarnings => throw _privateConstructorUsedError;
  double get thisMonthEarnings => throw _privateConstructorUsedError;
  int get totalBookings => throw _privateConstructorUsedError;
  int get completedBookings => throw _privateConstructorUsedError;
  int get pendingBookings => throw _privateConstructorUsedError;
  int get cancelledBookings => throw _privateConstructorUsedError;
  double get averageRating => throw _privateConstructorUsedError;
  int get totalReviews => throw _privateConstructorUsedError;
  int get totalStudentsWorkedWith => throw _privateConstructorUsedError;
  List<String> get teachingSubjects => throw _privateConstructorUsedError;
  List<RecentBookingDto> get recentBookings =>
      throw _privateConstructorUsedError;
  TutorPerformanceDto? get performance => throw _privateConstructorUsedError;
  @JsonKey(name: 'verification_status')
  String get verificationStatus => throw _privateConstructorUsedError;
  DateTime get lastUpdated => throw _privateConstructorUsedError;
  DateTime get createdAt => throw _privateConstructorUsedError;
  Map<String, dynamic>? get metadata => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $TutorDashboardDtoCopyWith<TutorDashboardDto> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $TutorDashboardDtoCopyWith<$Res> {
  factory $TutorDashboardDtoCopyWith(
          TutorDashboardDto value, $Res Function(TutorDashboardDto) then) =
      _$TutorDashboardDtoCopyWithImpl<$Res, TutorDashboardDto>;
  @useResult
  $Res call(
      {String id,
      String tutorId,
      double totalEarnings,
      double thisMonthEarnings,
      int totalBookings,
      int completedBookings,
      int pendingBookings,
      int cancelledBookings,
      double averageRating,
      int totalReviews,
      int totalStudentsWorkedWith,
      List<String> teachingSubjects,
      List<RecentBookingDto> recentBookings,
      TutorPerformanceDto? performance,
      @JsonKey(name: 'verification_status') String verificationStatus,
      DateTime lastUpdated,
      DateTime createdAt,
      Map<String, dynamic>? metadata});

  $TutorPerformanceDtoCopyWith<$Res>? get performance;
}

/// @nodoc
class _$TutorDashboardDtoCopyWithImpl<$Res, $Val extends TutorDashboardDto>
    implements $TutorDashboardDtoCopyWith<$Res> {
  _$TutorDashboardDtoCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? tutorId = null,
    Object? totalEarnings = null,
    Object? thisMonthEarnings = null,
    Object? totalBookings = null,
    Object? completedBookings = null,
    Object? pendingBookings = null,
    Object? cancelledBookings = null,
    Object? averageRating = null,
    Object? totalReviews = null,
    Object? totalStudentsWorkedWith = null,
    Object? teachingSubjects = null,
    Object? recentBookings = null,
    Object? performance = freezed,
    Object? verificationStatus = null,
    Object? lastUpdated = null,
    Object? createdAt = null,
    Object? metadata = freezed,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      tutorId: null == tutorId
          ? _value.tutorId
          : tutorId // ignore: cast_nullable_to_non_nullable
              as String,
      totalEarnings: null == totalEarnings
          ? _value.totalEarnings
          : totalEarnings // ignore: cast_nullable_to_non_nullable
              as double,
      thisMonthEarnings: null == thisMonthEarnings
          ? _value.thisMonthEarnings
          : thisMonthEarnings // ignore: cast_nullable_to_non_nullable
              as double,
      totalBookings: null == totalBookings
          ? _value.totalBookings
          : totalBookings // ignore: cast_nullable_to_non_nullable
              as int,
      completedBookings: null == completedBookings
          ? _value.completedBookings
          : completedBookings // ignore: cast_nullable_to_non_nullable
              as int,
      pendingBookings: null == pendingBookings
          ? _value.pendingBookings
          : pendingBookings // ignore: cast_nullable_to_non_nullable
              as int,
      cancelledBookings: null == cancelledBookings
          ? _value.cancelledBookings
          : cancelledBookings // ignore: cast_nullable_to_non_nullable
              as int,
      averageRating: null == averageRating
          ? _value.averageRating
          : averageRating // ignore: cast_nullable_to_non_nullable
              as double,
      totalReviews: null == totalReviews
          ? _value.totalReviews
          : totalReviews // ignore: cast_nullable_to_non_nullable
              as int,
      totalStudentsWorkedWith: null == totalStudentsWorkedWith
          ? _value.totalStudentsWorkedWith
          : totalStudentsWorkedWith // ignore: cast_nullable_to_non_nullable
              as int,
      teachingSubjects: null == teachingSubjects
          ? _value.teachingSubjects
          : teachingSubjects // ignore: cast_nullable_to_non_nullable
              as List<String>,
      recentBookings: null == recentBookings
          ? _value.recentBookings
          : recentBookings // ignore: cast_nullable_to_non_nullable
              as List<RecentBookingDto>,
      performance: freezed == performance
          ? _value.performance
          : performance // ignore: cast_nullable_to_non_nullable
              as TutorPerformanceDto?,
      verificationStatus: null == verificationStatus
          ? _value.verificationStatus
          : verificationStatus // ignore: cast_nullable_to_non_nullable
              as String,
      lastUpdated: null == lastUpdated
          ? _value.lastUpdated
          : lastUpdated // ignore: cast_nullable_to_non_nullable
              as DateTime,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      metadata: freezed == metadata
          ? _value.metadata
          : metadata // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>?,
    ) as $Val);
  }

  @override
  @pragma('vm:prefer-inline')
  $TutorPerformanceDtoCopyWith<$Res>? get performance {
    if (_value.performance == null) {
      return null;
    }

    return $TutorPerformanceDtoCopyWith<$Res>(_value.performance!, (value) {
      return _then(_value.copyWith(performance: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$TutorDashboardDtoImplCopyWith<$Res>
    implements $TutorDashboardDtoCopyWith<$Res> {
  factory _$$TutorDashboardDtoImplCopyWith(_$TutorDashboardDtoImpl value,
          $Res Function(_$TutorDashboardDtoImpl) then) =
      __$$TutorDashboardDtoImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String tutorId,
      double totalEarnings,
      double thisMonthEarnings,
      int totalBookings,
      int completedBookings,
      int pendingBookings,
      int cancelledBookings,
      double averageRating,
      int totalReviews,
      int totalStudentsWorkedWith,
      List<String> teachingSubjects,
      List<RecentBookingDto> recentBookings,
      TutorPerformanceDto? performance,
      @JsonKey(name: 'verification_status') String verificationStatus,
      DateTime lastUpdated,
      DateTime createdAt,
      Map<String, dynamic>? metadata});

  @override
  $TutorPerformanceDtoCopyWith<$Res>? get performance;
}

/// @nodoc
class __$$TutorDashboardDtoImplCopyWithImpl<$Res>
    extends _$TutorDashboardDtoCopyWithImpl<$Res, _$TutorDashboardDtoImpl>
    implements _$$TutorDashboardDtoImplCopyWith<$Res> {
  __$$TutorDashboardDtoImplCopyWithImpl(_$TutorDashboardDtoImpl _value,
      $Res Function(_$TutorDashboardDtoImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? tutorId = null,
    Object? totalEarnings = null,
    Object? thisMonthEarnings = null,
    Object? totalBookings = null,
    Object? completedBookings = null,
    Object? pendingBookings = null,
    Object? cancelledBookings = null,
    Object? averageRating = null,
    Object? totalReviews = null,
    Object? totalStudentsWorkedWith = null,
    Object? teachingSubjects = null,
    Object? recentBookings = null,
    Object? performance = freezed,
    Object? verificationStatus = null,
    Object? lastUpdated = null,
    Object? createdAt = null,
    Object? metadata = freezed,
  }) {
    return _then(_$TutorDashboardDtoImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      tutorId: null == tutorId
          ? _value.tutorId
          : tutorId // ignore: cast_nullable_to_non_nullable
              as String,
      totalEarnings: null == totalEarnings
          ? _value.totalEarnings
          : totalEarnings // ignore: cast_nullable_to_non_nullable
              as double,
      thisMonthEarnings: null == thisMonthEarnings
          ? _value.thisMonthEarnings
          : thisMonthEarnings // ignore: cast_nullable_to_non_nullable
              as double,
      totalBookings: null == totalBookings
          ? _value.totalBookings
          : totalBookings // ignore: cast_nullable_to_non_nullable
              as int,
      completedBookings: null == completedBookings
          ? _value.completedBookings
          : completedBookings // ignore: cast_nullable_to_non_nullable
              as int,
      pendingBookings: null == pendingBookings
          ? _value.pendingBookings
          : pendingBookings // ignore: cast_nullable_to_non_nullable
              as int,
      cancelledBookings: null == cancelledBookings
          ? _value.cancelledBookings
          : cancelledBookings // ignore: cast_nullable_to_non_nullable
              as int,
      averageRating: null == averageRating
          ? _value.averageRating
          : averageRating // ignore: cast_nullable_to_non_nullable
              as double,
      totalReviews: null == totalReviews
          ? _value.totalReviews
          : totalReviews // ignore: cast_nullable_to_non_nullable
              as int,
      totalStudentsWorkedWith: null == totalStudentsWorkedWith
          ? _value.totalStudentsWorkedWith
          : totalStudentsWorkedWith // ignore: cast_nullable_to_non_nullable
              as int,
      teachingSubjects: null == teachingSubjects
          ? _value._teachingSubjects
          : teachingSubjects // ignore: cast_nullable_to_non_nullable
              as List<String>,
      recentBookings: null == recentBookings
          ? _value._recentBookings
          : recentBookings // ignore: cast_nullable_to_non_nullable
              as List<RecentBookingDto>,
      performance: freezed == performance
          ? _value.performance
          : performance // ignore: cast_nullable_to_non_nullable
              as TutorPerformanceDto?,
      verificationStatus: null == verificationStatus
          ? _value.verificationStatus
          : verificationStatus // ignore: cast_nullable_to_non_nullable
              as String,
      lastUpdated: null == lastUpdated
          ? _value.lastUpdated
          : lastUpdated // ignore: cast_nullable_to_non_nullable
              as DateTime,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      metadata: freezed == metadata
          ? _value._metadata
          : metadata // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$TutorDashboardDtoImpl extends _TutorDashboardDto {
  const _$TutorDashboardDtoImpl(
      {required this.id,
      required this.tutorId,
      required this.totalEarnings,
      required this.thisMonthEarnings,
      required this.totalBookings,
      required this.completedBookings,
      required this.pendingBookings,
      required this.cancelledBookings,
      required this.averageRating,
      required this.totalReviews,
      required this.totalStudentsWorkedWith,
      required final List<String> teachingSubjects,
      required final List<RecentBookingDto> recentBookings,
      required this.performance,
      @JsonKey(name: 'verification_status') required this.verificationStatus,
      required this.lastUpdated,
      required this.createdAt,
      final Map<String, dynamic>? metadata})
      : _teachingSubjects = teachingSubjects,
        _recentBookings = recentBookings,
        _metadata = metadata,
        super._();

  factory _$TutorDashboardDtoImpl.fromJson(Map<String, dynamic> json) =>
      _$$TutorDashboardDtoImplFromJson(json);

  @override
  final String id;
  @override
  final String tutorId;
  @override
  final double totalEarnings;
  @override
  final double thisMonthEarnings;
  @override
  final int totalBookings;
  @override
  final int completedBookings;
  @override
  final int pendingBookings;
  @override
  final int cancelledBookings;
  @override
  final double averageRating;
  @override
  final int totalReviews;
  @override
  final int totalStudentsWorkedWith;
  final List<String> _teachingSubjects;
  @override
  List<String> get teachingSubjects {
    if (_teachingSubjects is EqualUnmodifiableListView)
      return _teachingSubjects;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_teachingSubjects);
  }

  final List<RecentBookingDto> _recentBookings;
  @override
  List<RecentBookingDto> get recentBookings {
    if (_recentBookings is EqualUnmodifiableListView) return _recentBookings;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_recentBookings);
  }

  @override
  final TutorPerformanceDto? performance;
  @override
  @JsonKey(name: 'verification_status')
  final String verificationStatus;
  @override
  final DateTime lastUpdated;
  @override
  final DateTime createdAt;
  final Map<String, dynamic>? _metadata;
  @override
  Map<String, dynamic>? get metadata {
    final value = _metadata;
    if (value == null) return null;
    if (_metadata is EqualUnmodifiableMapView) return _metadata;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(value);
  }

  @override
  String toString() {
    return 'TutorDashboardDto(id: $id, tutorId: $tutorId, totalEarnings: $totalEarnings, thisMonthEarnings: $thisMonthEarnings, totalBookings: $totalBookings, completedBookings: $completedBookings, pendingBookings: $pendingBookings, cancelledBookings: $cancelledBookings, averageRating: $averageRating, totalReviews: $totalReviews, totalStudentsWorkedWith: $totalStudentsWorkedWith, teachingSubjects: $teachingSubjects, recentBookings: $recentBookings, performance: $performance, verificationStatus: $verificationStatus, lastUpdated: $lastUpdated, createdAt: $createdAt, metadata: $metadata)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$TutorDashboardDtoImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.tutorId, tutorId) || other.tutorId == tutorId) &&
            (identical(other.totalEarnings, totalEarnings) ||
                other.totalEarnings == totalEarnings) &&
            (identical(other.thisMonthEarnings, thisMonthEarnings) ||
                other.thisMonthEarnings == thisMonthEarnings) &&
            (identical(other.totalBookings, totalBookings) ||
                other.totalBookings == totalBookings) &&
            (identical(other.completedBookings, completedBookings) ||
                other.completedBookings == completedBookings) &&
            (identical(other.pendingBookings, pendingBookings) ||
                other.pendingBookings == pendingBookings) &&
            (identical(other.cancelledBookings, cancelledBookings) ||
                other.cancelledBookings == cancelledBookings) &&
            (identical(other.averageRating, averageRating) ||
                other.averageRating == averageRating) &&
            (identical(other.totalReviews, totalReviews) ||
                other.totalReviews == totalReviews) &&
            (identical(
                    other.totalStudentsWorkedWith, totalStudentsWorkedWith) ||
                other.totalStudentsWorkedWith == totalStudentsWorkedWith) &&
            const DeepCollectionEquality()
                .equals(other._teachingSubjects, _teachingSubjects) &&
            const DeepCollectionEquality()
                .equals(other._recentBookings, _recentBookings) &&
            (identical(other.performance, performance) ||
                other.performance == performance) &&
            (identical(other.verificationStatus, verificationStatus) ||
                other.verificationStatus == verificationStatus) &&
            (identical(other.lastUpdated, lastUpdated) ||
                other.lastUpdated == lastUpdated) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            const DeepCollectionEquality().equals(other._metadata, _metadata));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      tutorId,
      totalEarnings,
      thisMonthEarnings,
      totalBookings,
      completedBookings,
      pendingBookings,
      cancelledBookings,
      averageRating,
      totalReviews,
      totalStudentsWorkedWith,
      const DeepCollectionEquality().hash(_teachingSubjects),
      const DeepCollectionEquality().hash(_recentBookings),
      performance,
      verificationStatus,
      lastUpdated,
      createdAt,
      const DeepCollectionEquality().hash(_metadata));

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$TutorDashboardDtoImplCopyWith<_$TutorDashboardDtoImpl> get copyWith =>
      __$$TutorDashboardDtoImplCopyWithImpl<_$TutorDashboardDtoImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$TutorDashboardDtoImplToJson(
      this,
    );
  }
}

abstract class _TutorDashboardDto extends TutorDashboardDto {
  const factory _TutorDashboardDto(
      {required final String id,
      required final String tutorId,
      required final double totalEarnings,
      required final double thisMonthEarnings,
      required final int totalBookings,
      required final int completedBookings,
      required final int pendingBookings,
      required final int cancelledBookings,
      required final double averageRating,
      required final int totalReviews,
      required final int totalStudentsWorkedWith,
      required final List<String> teachingSubjects,
      required final List<RecentBookingDto> recentBookings,
      required final TutorPerformanceDto? performance,
      @JsonKey(name: 'verification_status')
      required final String verificationStatus,
      required final DateTime lastUpdated,
      required final DateTime createdAt,
      final Map<String, dynamic>? metadata}) = _$TutorDashboardDtoImpl;
  const _TutorDashboardDto._() : super._();

  factory _TutorDashboardDto.fromJson(Map<String, dynamic> json) =
      _$TutorDashboardDtoImpl.fromJson;

  @override
  String get id;
  @override
  String get tutorId;
  @override
  double get totalEarnings;
  @override
  double get thisMonthEarnings;
  @override
  int get totalBookings;
  @override
  int get completedBookings;
  @override
  int get pendingBookings;
  @override
  int get cancelledBookings;
  @override
  double get averageRating;
  @override
  int get totalReviews;
  @override
  int get totalStudentsWorkedWith;
  @override
  List<String> get teachingSubjects;
  @override
  List<RecentBookingDto> get recentBookings;
  @override
  TutorPerformanceDto? get performance;
  @override
  @JsonKey(name: 'verification_status')
  String get verificationStatus;
  @override
  DateTime get lastUpdated;
  @override
  DateTime get createdAt;
  @override
  Map<String, dynamic>? get metadata;
  @override
  @JsonKey(ignore: true)
  _$$TutorDashboardDtoImplCopyWith<_$TutorDashboardDtoImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

RecentBookingDto _$RecentBookingDtoFromJson(Map<String, dynamic> json) {
  return _RecentBookingDto.fromJson(json);
}

/// @nodoc
mixin _$RecentBookingDto {
  String get id => throw _privateConstructorUsedError;
  String get studentId => throw _privateConstructorUsedError;
  String get tutorId => throw _privateConstructorUsedError;
  String get subject => throw _privateConstructorUsedError;
  DateTime get scheduledDate => throw _privateConstructorUsedError;
  String get status => throw _privateConstructorUsedError;
  double get amount => throw _privateConstructorUsedError;
  int get duration => throw _privateConstructorUsedError;
  String? get notes => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $RecentBookingDtoCopyWith<RecentBookingDto> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $RecentBookingDtoCopyWith<$Res> {
  factory $RecentBookingDtoCopyWith(
          RecentBookingDto value, $Res Function(RecentBookingDto) then) =
      _$RecentBookingDtoCopyWithImpl<$Res, RecentBookingDto>;
  @useResult
  $Res call(
      {String id,
      String studentId,
      String tutorId,
      String subject,
      DateTime scheduledDate,
      String status,
      double amount,
      int duration,
      String? notes});
}

/// @nodoc
class _$RecentBookingDtoCopyWithImpl<$Res, $Val extends RecentBookingDto>
    implements $RecentBookingDtoCopyWith<$Res> {
  _$RecentBookingDtoCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? studentId = null,
    Object? tutorId = null,
    Object? subject = null,
    Object? scheduledDate = null,
    Object? status = null,
    Object? amount = null,
    Object? duration = null,
    Object? notes = freezed,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      studentId: null == studentId
          ? _value.studentId
          : studentId // ignore: cast_nullable_to_non_nullable
              as String,
      tutorId: null == tutorId
          ? _value.tutorId
          : tutorId // ignore: cast_nullable_to_non_nullable
              as String,
      subject: null == subject
          ? _value.subject
          : subject // ignore: cast_nullable_to_non_nullable
              as String,
      scheduledDate: null == scheduledDate
          ? _value.scheduledDate
          : scheduledDate // ignore: cast_nullable_to_non_nullable
              as DateTime,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as String,
      amount: null == amount
          ? _value.amount
          : amount // ignore: cast_nullable_to_non_nullable
              as double,
      duration: null == duration
          ? _value.duration
          : duration // ignore: cast_nullable_to_non_nullable
              as int,
      notes: freezed == notes
          ? _value.notes
          : notes // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$RecentBookingDtoImplCopyWith<$Res>
    implements $RecentBookingDtoCopyWith<$Res> {
  factory _$$RecentBookingDtoImplCopyWith(_$RecentBookingDtoImpl value,
          $Res Function(_$RecentBookingDtoImpl) then) =
      __$$RecentBookingDtoImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String studentId,
      String tutorId,
      String subject,
      DateTime scheduledDate,
      String status,
      double amount,
      int duration,
      String? notes});
}

/// @nodoc
class __$$RecentBookingDtoImplCopyWithImpl<$Res>
    extends _$RecentBookingDtoCopyWithImpl<$Res, _$RecentBookingDtoImpl>
    implements _$$RecentBookingDtoImplCopyWith<$Res> {
  __$$RecentBookingDtoImplCopyWithImpl(_$RecentBookingDtoImpl _value,
      $Res Function(_$RecentBookingDtoImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? studentId = null,
    Object? tutorId = null,
    Object? subject = null,
    Object? scheduledDate = null,
    Object? status = null,
    Object? amount = null,
    Object? duration = null,
    Object? notes = freezed,
  }) {
    return _then(_$RecentBookingDtoImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      studentId: null == studentId
          ? _value.studentId
          : studentId // ignore: cast_nullable_to_non_nullable
              as String,
      tutorId: null == tutorId
          ? _value.tutorId
          : tutorId // ignore: cast_nullable_to_non_nullable
              as String,
      subject: null == subject
          ? _value.subject
          : subject // ignore: cast_nullable_to_non_nullable
              as String,
      scheduledDate: null == scheduledDate
          ? _value.scheduledDate
          : scheduledDate // ignore: cast_nullable_to_non_nullable
              as DateTime,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as String,
      amount: null == amount
          ? _value.amount
          : amount // ignore: cast_nullable_to_non_nullable
              as double,
      duration: null == duration
          ? _value.duration
          : duration // ignore: cast_nullable_to_non_nullable
              as int,
      notes: freezed == notes
          ? _value.notes
          : notes // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$RecentBookingDtoImpl extends _RecentBookingDto {
  const _$RecentBookingDtoImpl(
      {required this.id,
      required this.studentId,
      required this.tutorId,
      required this.subject,
      required this.scheduledDate,
      required this.status,
      required this.amount,
      required this.duration,
      this.notes})
      : super._();

  factory _$RecentBookingDtoImpl.fromJson(Map<String, dynamic> json) =>
      _$$RecentBookingDtoImplFromJson(json);

  @override
  final String id;
  @override
  final String studentId;
  @override
  final String tutorId;
  @override
  final String subject;
  @override
  final DateTime scheduledDate;
  @override
  final String status;
  @override
  final double amount;
  @override
  final int duration;
  @override
  final String? notes;

  @override
  String toString() {
    return 'RecentBookingDto(id: $id, studentId: $studentId, tutorId: $tutorId, subject: $subject, scheduledDate: $scheduledDate, status: $status, amount: $amount, duration: $duration, notes: $notes)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$RecentBookingDtoImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.studentId, studentId) ||
                other.studentId == studentId) &&
            (identical(other.tutorId, tutorId) || other.tutorId == tutorId) &&
            (identical(other.subject, subject) || other.subject == subject) &&
            (identical(other.scheduledDate, scheduledDate) ||
                other.scheduledDate == scheduledDate) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.amount, amount) || other.amount == amount) &&
            (identical(other.duration, duration) ||
                other.duration == duration) &&
            (identical(other.notes, notes) || other.notes == notes));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(runtimeType, id, studentId, tutorId, subject,
      scheduledDate, status, amount, duration, notes);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$RecentBookingDtoImplCopyWith<_$RecentBookingDtoImpl> get copyWith =>
      __$$RecentBookingDtoImplCopyWithImpl<_$RecentBookingDtoImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$RecentBookingDtoImplToJson(
      this,
    );
  }
}

abstract class _RecentBookingDto extends RecentBookingDto {
  const factory _RecentBookingDto(
      {required final String id,
      required final String studentId,
      required final String tutorId,
      required final String subject,
      required final DateTime scheduledDate,
      required final String status,
      required final double amount,
      required final int duration,
      final String? notes}) = _$RecentBookingDtoImpl;
  const _RecentBookingDto._() : super._();

  factory _RecentBookingDto.fromJson(Map<String, dynamic> json) =
      _$RecentBookingDtoImpl.fromJson;

  @override
  String get id;
  @override
  String get studentId;
  @override
  String get tutorId;
  @override
  String get subject;
  @override
  DateTime get scheduledDate;
  @override
  String get status;
  @override
  double get amount;
  @override
  int get duration;
  @override
  String? get notes;
  @override
  @JsonKey(ignore: true)
  _$$RecentBookingDtoImplCopyWith<_$RecentBookingDtoImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

RecentTransactionDto _$RecentTransactionDtoFromJson(Map<String, dynamic> json) {
  return _RecentTransactionDto.fromJson(json);
}

/// @nodoc
mixin _$RecentTransactionDto {
  String get id => throw _privateConstructorUsedError;
  String get userId => throw _privateConstructorUsedError;
  String get type => throw _privateConstructorUsedError;
  double get amount => throw _privateConstructorUsedError;
  String get description => throw _privateConstructorUsedError;
  String get status => throw _privateConstructorUsedError;
  DateTime get createdAt => throw _privateConstructorUsedError;
  String? get bookingId => throw _privateConstructorUsedError;
  Map<String, dynamic>? get metadata => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $RecentTransactionDtoCopyWith<RecentTransactionDto> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $RecentTransactionDtoCopyWith<$Res> {
  factory $RecentTransactionDtoCopyWith(RecentTransactionDto value,
          $Res Function(RecentTransactionDto) then) =
      _$RecentTransactionDtoCopyWithImpl<$Res, RecentTransactionDto>;
  @useResult
  $Res call(
      {String id,
      String userId,
      String type,
      double amount,
      String description,
      String status,
      DateTime createdAt,
      String? bookingId,
      Map<String, dynamic>? metadata});
}

/// @nodoc
class _$RecentTransactionDtoCopyWithImpl<$Res,
        $Val extends RecentTransactionDto>
    implements $RecentTransactionDtoCopyWith<$Res> {
  _$RecentTransactionDtoCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? userId = null,
    Object? type = null,
    Object? amount = null,
    Object? description = null,
    Object? status = null,
    Object? createdAt = null,
    Object? bookingId = freezed,
    Object? metadata = freezed,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      userId: null == userId
          ? _value.userId
          : userId // ignore: cast_nullable_to_non_nullable
              as String,
      type: null == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as String,
      amount: null == amount
          ? _value.amount
          : amount // ignore: cast_nullable_to_non_nullable
              as double,
      description: null == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as String,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      bookingId: freezed == bookingId
          ? _value.bookingId
          : bookingId // ignore: cast_nullable_to_non_nullable
              as String?,
      metadata: freezed == metadata
          ? _value.metadata
          : metadata // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$RecentTransactionDtoImplCopyWith<$Res>
    implements $RecentTransactionDtoCopyWith<$Res> {
  factory _$$RecentTransactionDtoImplCopyWith(_$RecentTransactionDtoImpl value,
          $Res Function(_$RecentTransactionDtoImpl) then) =
      __$$RecentTransactionDtoImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String userId,
      String type,
      double amount,
      String description,
      String status,
      DateTime createdAt,
      String? bookingId,
      Map<String, dynamic>? metadata});
}

/// @nodoc
class __$$RecentTransactionDtoImplCopyWithImpl<$Res>
    extends _$RecentTransactionDtoCopyWithImpl<$Res, _$RecentTransactionDtoImpl>
    implements _$$RecentTransactionDtoImplCopyWith<$Res> {
  __$$RecentTransactionDtoImplCopyWithImpl(_$RecentTransactionDtoImpl _value,
      $Res Function(_$RecentTransactionDtoImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? userId = null,
    Object? type = null,
    Object? amount = null,
    Object? description = null,
    Object? status = null,
    Object? createdAt = null,
    Object? bookingId = freezed,
    Object? metadata = freezed,
  }) {
    return _then(_$RecentTransactionDtoImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      userId: null == userId
          ? _value.userId
          : userId // ignore: cast_nullable_to_non_nullable
              as String,
      type: null == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as String,
      amount: null == amount
          ? _value.amount
          : amount // ignore: cast_nullable_to_non_nullable
              as double,
      description: null == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as String,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      bookingId: freezed == bookingId
          ? _value.bookingId
          : bookingId // ignore: cast_nullable_to_non_nullable
              as String?,
      metadata: freezed == metadata
          ? _value._metadata
          : metadata // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$RecentTransactionDtoImpl extends _RecentTransactionDto {
  const _$RecentTransactionDtoImpl(
      {required this.id,
      required this.userId,
      required this.type,
      required this.amount,
      required this.description,
      required this.status,
      required this.createdAt,
      this.bookingId,
      final Map<String, dynamic>? metadata})
      : _metadata = metadata,
        super._();

  factory _$RecentTransactionDtoImpl.fromJson(Map<String, dynamic> json) =>
      _$$RecentTransactionDtoImplFromJson(json);

  @override
  final String id;
  @override
  final String userId;
  @override
  final String type;
  @override
  final double amount;
  @override
  final String description;
  @override
  final String status;
  @override
  final DateTime createdAt;
  @override
  final String? bookingId;
  final Map<String, dynamic>? _metadata;
  @override
  Map<String, dynamic>? get metadata {
    final value = _metadata;
    if (value == null) return null;
    if (_metadata is EqualUnmodifiableMapView) return _metadata;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(value);
  }

  @override
  String toString() {
    return 'RecentTransactionDto(id: $id, userId: $userId, type: $type, amount: $amount, description: $description, status: $status, createdAt: $createdAt, bookingId: $bookingId, metadata: $metadata)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$RecentTransactionDtoImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.userId, userId) || other.userId == userId) &&
            (identical(other.type, type) || other.type == type) &&
            (identical(other.amount, amount) || other.amount == amount) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.bookingId, bookingId) ||
                other.bookingId == bookingId) &&
            const DeepCollectionEquality().equals(other._metadata, _metadata));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      userId,
      type,
      amount,
      description,
      status,
      createdAt,
      bookingId,
      const DeepCollectionEquality().hash(_metadata));

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$RecentTransactionDtoImplCopyWith<_$RecentTransactionDtoImpl>
      get copyWith =>
          __$$RecentTransactionDtoImplCopyWithImpl<_$RecentTransactionDtoImpl>(
              this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$RecentTransactionDtoImplToJson(
      this,
    );
  }
}

abstract class _RecentTransactionDto extends RecentTransactionDto {
  const factory _RecentTransactionDto(
      {required final String id,
      required final String userId,
      required final String type,
      required final double amount,
      required final String description,
      required final String status,
      required final DateTime createdAt,
      final String? bookingId,
      final Map<String, dynamic>? metadata}) = _$RecentTransactionDtoImpl;
  const _RecentTransactionDto._() : super._();

  factory _RecentTransactionDto.fromJson(Map<String, dynamic> json) =
      _$RecentTransactionDtoImpl.fromJson;

  @override
  String get id;
  @override
  String get userId;
  @override
  String get type;
  @override
  double get amount;
  @override
  String get description;
  @override
  String get status;
  @override
  DateTime get createdAt;
  @override
  String? get bookingId;
  @override
  Map<String, dynamic>? get metadata;
  @override
  @JsonKey(ignore: true)
  _$$RecentTransactionDtoImplCopyWith<_$RecentTransactionDtoImpl>
      get copyWith => throw _privateConstructorUsedError;
}

StudentProgressDto _$StudentProgressDtoFromJson(Map<String, dynamic> json) {
  return _StudentProgressDto.fromJson(json);
}

/// @nodoc
mixin _$StudentProgressDto {
  String get studentId => throw _privateConstructorUsedError;
  Map<String, double> get subjectProgress => throw _privateConstructorUsedError;
  List<String> get completedMilestones => throw _privateConstructorUsedError;
  Map<String, dynamic> get learningStats => throw _privateConstructorUsedError;
  DateTime get lastProgressUpdate => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $StudentProgressDtoCopyWith<StudentProgressDto> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $StudentProgressDtoCopyWith<$Res> {
  factory $StudentProgressDtoCopyWith(
          StudentProgressDto value, $Res Function(StudentProgressDto) then) =
      _$StudentProgressDtoCopyWithImpl<$Res, StudentProgressDto>;
  @useResult
  $Res call(
      {String studentId,
      Map<String, double> subjectProgress,
      List<String> completedMilestones,
      Map<String, dynamic> learningStats,
      DateTime lastProgressUpdate});
}

/// @nodoc
class _$StudentProgressDtoCopyWithImpl<$Res, $Val extends StudentProgressDto>
    implements $StudentProgressDtoCopyWith<$Res> {
  _$StudentProgressDtoCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? studentId = null,
    Object? subjectProgress = null,
    Object? completedMilestones = null,
    Object? learningStats = null,
    Object? lastProgressUpdate = null,
  }) {
    return _then(_value.copyWith(
      studentId: null == studentId
          ? _value.studentId
          : studentId // ignore: cast_nullable_to_non_nullable
              as String,
      subjectProgress: null == subjectProgress
          ? _value.subjectProgress
          : subjectProgress // ignore: cast_nullable_to_non_nullable
              as Map<String, double>,
      completedMilestones: null == completedMilestones
          ? _value.completedMilestones
          : completedMilestones // ignore: cast_nullable_to_non_nullable
              as List<String>,
      learningStats: null == learningStats
          ? _value.learningStats
          : learningStats // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>,
      lastProgressUpdate: null == lastProgressUpdate
          ? _value.lastProgressUpdate
          : lastProgressUpdate // ignore: cast_nullable_to_non_nullable
              as DateTime,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$StudentProgressDtoImplCopyWith<$Res>
    implements $StudentProgressDtoCopyWith<$Res> {
  factory _$$StudentProgressDtoImplCopyWith(_$StudentProgressDtoImpl value,
          $Res Function(_$StudentProgressDtoImpl) then) =
      __$$StudentProgressDtoImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String studentId,
      Map<String, double> subjectProgress,
      List<String> completedMilestones,
      Map<String, dynamic> learningStats,
      DateTime lastProgressUpdate});
}

/// @nodoc
class __$$StudentProgressDtoImplCopyWithImpl<$Res>
    extends _$StudentProgressDtoCopyWithImpl<$Res, _$StudentProgressDtoImpl>
    implements _$$StudentProgressDtoImplCopyWith<$Res> {
  __$$StudentProgressDtoImplCopyWithImpl(_$StudentProgressDtoImpl _value,
      $Res Function(_$StudentProgressDtoImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? studentId = null,
    Object? subjectProgress = null,
    Object? completedMilestones = null,
    Object? learningStats = null,
    Object? lastProgressUpdate = null,
  }) {
    return _then(_$StudentProgressDtoImpl(
      studentId: null == studentId
          ? _value.studentId
          : studentId // ignore: cast_nullable_to_non_nullable
              as String,
      subjectProgress: null == subjectProgress
          ? _value._subjectProgress
          : subjectProgress // ignore: cast_nullable_to_non_nullable
              as Map<String, double>,
      completedMilestones: null == completedMilestones
          ? _value._completedMilestones
          : completedMilestones // ignore: cast_nullable_to_non_nullable
              as List<String>,
      learningStats: null == learningStats
          ? _value._learningStats
          : learningStats // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>,
      lastProgressUpdate: null == lastProgressUpdate
          ? _value.lastProgressUpdate
          : lastProgressUpdate // ignore: cast_nullable_to_non_nullable
              as DateTime,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$StudentProgressDtoImpl extends _StudentProgressDto {
  const _$StudentProgressDtoImpl(
      {required this.studentId,
      required final Map<String, double> subjectProgress,
      required final List<String> completedMilestones,
      required final Map<String, dynamic> learningStats,
      required this.lastProgressUpdate})
      : _subjectProgress = subjectProgress,
        _completedMilestones = completedMilestones,
        _learningStats = learningStats,
        super._();

  factory _$StudentProgressDtoImpl.fromJson(Map<String, dynamic> json) =>
      _$$StudentProgressDtoImplFromJson(json);

  @override
  final String studentId;
  final Map<String, double> _subjectProgress;
  @override
  Map<String, double> get subjectProgress {
    if (_subjectProgress is EqualUnmodifiableMapView) return _subjectProgress;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_subjectProgress);
  }

  final List<String> _completedMilestones;
  @override
  List<String> get completedMilestones {
    if (_completedMilestones is EqualUnmodifiableListView)
      return _completedMilestones;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_completedMilestones);
  }

  final Map<String, dynamic> _learningStats;
  @override
  Map<String, dynamic> get learningStats {
    if (_learningStats is EqualUnmodifiableMapView) return _learningStats;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_learningStats);
  }

  @override
  final DateTime lastProgressUpdate;

  @override
  String toString() {
    return 'StudentProgressDto(studentId: $studentId, subjectProgress: $subjectProgress, completedMilestones: $completedMilestones, learningStats: $learningStats, lastProgressUpdate: $lastProgressUpdate)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$StudentProgressDtoImpl &&
            (identical(other.studentId, studentId) ||
                other.studentId == studentId) &&
            const DeepCollectionEquality()
                .equals(other._subjectProgress, _subjectProgress) &&
            const DeepCollectionEquality()
                .equals(other._completedMilestones, _completedMilestones) &&
            const DeepCollectionEquality()
                .equals(other._learningStats, _learningStats) &&
            (identical(other.lastProgressUpdate, lastProgressUpdate) ||
                other.lastProgressUpdate == lastProgressUpdate));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      studentId,
      const DeepCollectionEquality().hash(_subjectProgress),
      const DeepCollectionEquality().hash(_completedMilestones),
      const DeepCollectionEquality().hash(_learningStats),
      lastProgressUpdate);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$StudentProgressDtoImplCopyWith<_$StudentProgressDtoImpl> get copyWith =>
      __$$StudentProgressDtoImplCopyWithImpl<_$StudentProgressDtoImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$StudentProgressDtoImplToJson(
      this,
    );
  }
}

abstract class _StudentProgressDto extends StudentProgressDto {
  const factory _StudentProgressDto(
      {required final String studentId,
      required final Map<String, double> subjectProgress,
      required final List<String> completedMilestones,
      required final Map<String, dynamic> learningStats,
      required final DateTime lastProgressUpdate}) = _$StudentProgressDtoImpl;
  const _StudentProgressDto._() : super._();

  factory _StudentProgressDto.fromJson(Map<String, dynamic> json) =
      _$StudentProgressDtoImpl.fromJson;

  @override
  String get studentId;
  @override
  Map<String, double> get subjectProgress;
  @override
  List<String> get completedMilestones;
  @override
  Map<String, dynamic> get learningStats;
  @override
  DateTime get lastProgressUpdate;
  @override
  @JsonKey(ignore: true)
  _$$StudentProgressDtoImplCopyWith<_$StudentProgressDtoImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

TutorPerformanceDto _$TutorPerformanceDtoFromJson(Map<String, dynamic> json) {
  return _TutorPerformanceDto.fromJson(json);
}

/// @nodoc
mixin _$TutorPerformanceDto {
  String get tutorId => throw _privateConstructorUsedError;
  double get responseRate => throw _privateConstructorUsedError;
  double get completionRate => throw _privateConstructorUsedError;
  double get punctualityScore => throw _privateConstructorUsedError;
  Map<String, dynamic> get performanceMetrics =>
      throw _privateConstructorUsedError;
  DateTime get lastPerformanceUpdate => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $TutorPerformanceDtoCopyWith<TutorPerformanceDto> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $TutorPerformanceDtoCopyWith<$Res> {
  factory $TutorPerformanceDtoCopyWith(
          TutorPerformanceDto value, $Res Function(TutorPerformanceDto) then) =
      _$TutorPerformanceDtoCopyWithImpl<$Res, TutorPerformanceDto>;
  @useResult
  $Res call(
      {String tutorId,
      double responseRate,
      double completionRate,
      double punctualityScore,
      Map<String, dynamic> performanceMetrics,
      DateTime lastPerformanceUpdate});
}

/// @nodoc
class _$TutorPerformanceDtoCopyWithImpl<$Res, $Val extends TutorPerformanceDto>
    implements $TutorPerformanceDtoCopyWith<$Res> {
  _$TutorPerformanceDtoCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? tutorId = null,
    Object? responseRate = null,
    Object? completionRate = null,
    Object? punctualityScore = null,
    Object? performanceMetrics = null,
    Object? lastPerformanceUpdate = null,
  }) {
    return _then(_value.copyWith(
      tutorId: null == tutorId
          ? _value.tutorId
          : tutorId // ignore: cast_nullable_to_non_nullable
              as String,
      responseRate: null == responseRate
          ? _value.responseRate
          : responseRate // ignore: cast_nullable_to_non_nullable
              as double,
      completionRate: null == completionRate
          ? _value.completionRate
          : completionRate // ignore: cast_nullable_to_non_nullable
              as double,
      punctualityScore: null == punctualityScore
          ? _value.punctualityScore
          : punctualityScore // ignore: cast_nullable_to_non_nullable
              as double,
      performanceMetrics: null == performanceMetrics
          ? _value.performanceMetrics
          : performanceMetrics // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>,
      lastPerformanceUpdate: null == lastPerformanceUpdate
          ? _value.lastPerformanceUpdate
          : lastPerformanceUpdate // ignore: cast_nullable_to_non_nullable
              as DateTime,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$TutorPerformanceDtoImplCopyWith<$Res>
    implements $TutorPerformanceDtoCopyWith<$Res> {
  factory _$$TutorPerformanceDtoImplCopyWith(_$TutorPerformanceDtoImpl value,
          $Res Function(_$TutorPerformanceDtoImpl) then) =
      __$$TutorPerformanceDtoImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String tutorId,
      double responseRate,
      double completionRate,
      double punctualityScore,
      Map<String, dynamic> performanceMetrics,
      DateTime lastPerformanceUpdate});
}

/// @nodoc
class __$$TutorPerformanceDtoImplCopyWithImpl<$Res>
    extends _$TutorPerformanceDtoCopyWithImpl<$Res, _$TutorPerformanceDtoImpl>
    implements _$$TutorPerformanceDtoImplCopyWith<$Res> {
  __$$TutorPerformanceDtoImplCopyWithImpl(_$TutorPerformanceDtoImpl _value,
      $Res Function(_$TutorPerformanceDtoImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? tutorId = null,
    Object? responseRate = null,
    Object? completionRate = null,
    Object? punctualityScore = null,
    Object? performanceMetrics = null,
    Object? lastPerformanceUpdate = null,
  }) {
    return _then(_$TutorPerformanceDtoImpl(
      tutorId: null == tutorId
          ? _value.tutorId
          : tutorId // ignore: cast_nullable_to_non_nullable
              as String,
      responseRate: null == responseRate
          ? _value.responseRate
          : responseRate // ignore: cast_nullable_to_non_nullable
              as double,
      completionRate: null == completionRate
          ? _value.completionRate
          : completionRate // ignore: cast_nullable_to_non_nullable
              as double,
      punctualityScore: null == punctualityScore
          ? _value.punctualityScore
          : punctualityScore // ignore: cast_nullable_to_non_nullable
              as double,
      performanceMetrics: null == performanceMetrics
          ? _value._performanceMetrics
          : performanceMetrics // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>,
      lastPerformanceUpdate: null == lastPerformanceUpdate
          ? _value.lastPerformanceUpdate
          : lastPerformanceUpdate // ignore: cast_nullable_to_non_nullable
              as DateTime,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$TutorPerformanceDtoImpl extends _TutorPerformanceDto {
  const _$TutorPerformanceDtoImpl(
      {required this.tutorId,
      required this.responseRate,
      required this.completionRate,
      required this.punctualityScore,
      required final Map<String, dynamic> performanceMetrics,
      required this.lastPerformanceUpdate})
      : _performanceMetrics = performanceMetrics,
        super._();

  factory _$TutorPerformanceDtoImpl.fromJson(Map<String, dynamic> json) =>
      _$$TutorPerformanceDtoImplFromJson(json);

  @override
  final String tutorId;
  @override
  final double responseRate;
  @override
  final double completionRate;
  @override
  final double punctualityScore;
  final Map<String, dynamic> _performanceMetrics;
  @override
  Map<String, dynamic> get performanceMetrics {
    if (_performanceMetrics is EqualUnmodifiableMapView)
      return _performanceMetrics;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_performanceMetrics);
  }

  @override
  final DateTime lastPerformanceUpdate;

  @override
  String toString() {
    return 'TutorPerformanceDto(tutorId: $tutorId, responseRate: $responseRate, completionRate: $completionRate, punctualityScore: $punctualityScore, performanceMetrics: $performanceMetrics, lastPerformanceUpdate: $lastPerformanceUpdate)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$TutorPerformanceDtoImpl &&
            (identical(other.tutorId, tutorId) || other.tutorId == tutorId) &&
            (identical(other.responseRate, responseRate) ||
                other.responseRate == responseRate) &&
            (identical(other.completionRate, completionRate) ||
                other.completionRate == completionRate) &&
            (identical(other.punctualityScore, punctualityScore) ||
                other.punctualityScore == punctualityScore) &&
            const DeepCollectionEquality()
                .equals(other._performanceMetrics, _performanceMetrics) &&
            (identical(other.lastPerformanceUpdate, lastPerformanceUpdate) ||
                other.lastPerformanceUpdate == lastPerformanceUpdate));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      tutorId,
      responseRate,
      completionRate,
      punctualityScore,
      const DeepCollectionEquality().hash(_performanceMetrics),
      lastPerformanceUpdate);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$TutorPerformanceDtoImplCopyWith<_$TutorPerformanceDtoImpl> get copyWith =>
      __$$TutorPerformanceDtoImplCopyWithImpl<_$TutorPerformanceDtoImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$TutorPerformanceDtoImplToJson(
      this,
    );
  }
}

abstract class _TutorPerformanceDto extends TutorPerformanceDto {
  const factory _TutorPerformanceDto(
          {required final String tutorId,
          required final double responseRate,
          required final double completionRate,
          required final double punctualityScore,
          required final Map<String, dynamic> performanceMetrics,
          required final DateTime lastPerformanceUpdate}) =
      _$TutorPerformanceDtoImpl;
  const _TutorPerformanceDto._() : super._();

  factory _TutorPerformanceDto.fromJson(Map<String, dynamic> json) =
      _$TutorPerformanceDtoImpl.fromJson;

  @override
  String get tutorId;
  @override
  double get responseRate;
  @override
  double get completionRate;
  @override
  double get punctualityScore;
  @override
  Map<String, dynamic> get performanceMetrics;
  @override
  DateTime get lastPerformanceUpdate;
  @override
  @JsonKey(ignore: true)
  _$$TutorPerformanceDtoImplCopyWith<_$TutorPerformanceDtoImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
