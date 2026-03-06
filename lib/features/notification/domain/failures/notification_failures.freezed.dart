// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'notification_failures.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$NotificationFailure {
  String get message => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(String message) validationError,
    required TResult Function(String message) unauthorizedError,
    required TResult Function(String message) forbiddenError,
    required TResult Function(String message) notFoundError,
    required TResult Function(String message) conflictError,
    required TResult Function(String message) networkError,
    required TResult Function(String message) timeoutError,
    required TResult Function(String message) serverError,
    required TResult Function(String message) cacheError,
    required TResult Function(String message) connectionError,
    required TResult Function(String message) subscriptionError,
    required TResult Function(String message) unknownError,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(String message)? validationError,
    TResult? Function(String message)? unauthorizedError,
    TResult? Function(String message)? forbiddenError,
    TResult? Function(String message)? notFoundError,
    TResult? Function(String message)? conflictError,
    TResult? Function(String message)? networkError,
    TResult? Function(String message)? timeoutError,
    TResult? Function(String message)? serverError,
    TResult? Function(String message)? cacheError,
    TResult? Function(String message)? connectionError,
    TResult? Function(String message)? subscriptionError,
    TResult? Function(String message)? unknownError,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(String message)? validationError,
    TResult Function(String message)? unauthorizedError,
    TResult Function(String message)? forbiddenError,
    TResult Function(String message)? notFoundError,
    TResult Function(String message)? conflictError,
    TResult Function(String message)? networkError,
    TResult Function(String message)? timeoutError,
    TResult Function(String message)? serverError,
    TResult Function(String message)? cacheError,
    TResult Function(String message)? connectionError,
    TResult Function(String message)? subscriptionError,
    TResult Function(String message)? unknownError,
    required TResult orElse(),
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(_ValidationError value) validationError,
    required TResult Function(_UnauthorizedError value) unauthorizedError,
    required TResult Function(_ForbiddenError value) forbiddenError,
    required TResult Function(_NotFoundError value) notFoundError,
    required TResult Function(_ConflictError value) conflictError,
    required TResult Function(_NetworkError value) networkError,
    required TResult Function(_TimeoutError value) timeoutError,
    required TResult Function(_ServerError value) serverError,
    required TResult Function(_CacheError value) cacheError,
    required TResult Function(_ConnectionError value) connectionError,
    required TResult Function(_SubscriptionError value) subscriptionError,
    required TResult Function(_UnknownError value) unknownError,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_ValidationError value)? validationError,
    TResult? Function(_UnauthorizedError value)? unauthorizedError,
    TResult? Function(_ForbiddenError value)? forbiddenError,
    TResult? Function(_NotFoundError value)? notFoundError,
    TResult? Function(_ConflictError value)? conflictError,
    TResult? Function(_NetworkError value)? networkError,
    TResult? Function(_TimeoutError value)? timeoutError,
    TResult? Function(_ServerError value)? serverError,
    TResult? Function(_CacheError value)? cacheError,
    TResult? Function(_ConnectionError value)? connectionError,
    TResult? Function(_SubscriptionError value)? subscriptionError,
    TResult? Function(_UnknownError value)? unknownError,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_ValidationError value)? validationError,
    TResult Function(_UnauthorizedError value)? unauthorizedError,
    TResult Function(_ForbiddenError value)? forbiddenError,
    TResult Function(_NotFoundError value)? notFoundError,
    TResult Function(_ConflictError value)? conflictError,
    TResult Function(_NetworkError value)? networkError,
    TResult Function(_TimeoutError value)? timeoutError,
    TResult Function(_ServerError value)? serverError,
    TResult Function(_CacheError value)? cacheError,
    TResult Function(_ConnectionError value)? connectionError,
    TResult Function(_SubscriptionError value)? subscriptionError,
    TResult Function(_UnknownError value)? unknownError,
    required TResult orElse(),
  }) =>
      throw _privateConstructorUsedError;

  @JsonKey(ignore: true)
  $NotificationFailureCopyWith<NotificationFailure> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $NotificationFailureCopyWith<$Res> {
  factory $NotificationFailureCopyWith(
          NotificationFailure value, $Res Function(NotificationFailure) then) =
      _$NotificationFailureCopyWithImpl<$Res, NotificationFailure>;
  @useResult
  $Res call({String message});
}

/// @nodoc
class _$NotificationFailureCopyWithImpl<$Res, $Val extends NotificationFailure>
    implements $NotificationFailureCopyWith<$Res> {
  _$NotificationFailureCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? message = null,
  }) {
    return _then(_value.copyWith(
      message: null == message
          ? _value.message
          : message // ignore: cast_nullable_to_non_nullable
              as String,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$ValidationErrorImplCopyWith<$Res>
    implements $NotificationFailureCopyWith<$Res> {
  factory _$$ValidationErrorImplCopyWith(_$ValidationErrorImpl value,
          $Res Function(_$ValidationErrorImpl) then) =
      __$$ValidationErrorImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String message});
}

/// @nodoc
class __$$ValidationErrorImplCopyWithImpl<$Res>
    extends _$NotificationFailureCopyWithImpl<$Res, _$ValidationErrorImpl>
    implements _$$ValidationErrorImplCopyWith<$Res> {
  __$$ValidationErrorImplCopyWithImpl(
      _$ValidationErrorImpl _value, $Res Function(_$ValidationErrorImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? message = null,
  }) {
    return _then(_$ValidationErrorImpl(
      null == message
          ? _value.message
          : message // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc

class _$ValidationErrorImpl implements _ValidationError {
  const _$ValidationErrorImpl(this.message);

  @override
  final String message;

  @override
  String toString() {
    return 'NotificationFailure.validationError(message: $message)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ValidationErrorImpl &&
            (identical(other.message, message) || other.message == message));
  }

  @override
  int get hashCode => Object.hash(runtimeType, message);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$ValidationErrorImplCopyWith<_$ValidationErrorImpl> get copyWith =>
      __$$ValidationErrorImplCopyWithImpl<_$ValidationErrorImpl>(
          this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(String message) validationError,
    required TResult Function(String message) unauthorizedError,
    required TResult Function(String message) forbiddenError,
    required TResult Function(String message) notFoundError,
    required TResult Function(String message) conflictError,
    required TResult Function(String message) networkError,
    required TResult Function(String message) timeoutError,
    required TResult Function(String message) serverError,
    required TResult Function(String message) cacheError,
    required TResult Function(String message) connectionError,
    required TResult Function(String message) subscriptionError,
    required TResult Function(String message) unknownError,
  }) {
    return validationError(message);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(String message)? validationError,
    TResult? Function(String message)? unauthorizedError,
    TResult? Function(String message)? forbiddenError,
    TResult? Function(String message)? notFoundError,
    TResult? Function(String message)? conflictError,
    TResult? Function(String message)? networkError,
    TResult? Function(String message)? timeoutError,
    TResult? Function(String message)? serverError,
    TResult? Function(String message)? cacheError,
    TResult? Function(String message)? connectionError,
    TResult? Function(String message)? subscriptionError,
    TResult? Function(String message)? unknownError,
  }) {
    return validationError?.call(message);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(String message)? validationError,
    TResult Function(String message)? unauthorizedError,
    TResult Function(String message)? forbiddenError,
    TResult Function(String message)? notFoundError,
    TResult Function(String message)? conflictError,
    TResult Function(String message)? networkError,
    TResult Function(String message)? timeoutError,
    TResult Function(String message)? serverError,
    TResult Function(String message)? cacheError,
    TResult Function(String message)? connectionError,
    TResult Function(String message)? subscriptionError,
    TResult Function(String message)? unknownError,
    required TResult orElse(),
  }) {
    if (validationError != null) {
      return validationError(message);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(_ValidationError value) validationError,
    required TResult Function(_UnauthorizedError value) unauthorizedError,
    required TResult Function(_ForbiddenError value) forbiddenError,
    required TResult Function(_NotFoundError value) notFoundError,
    required TResult Function(_ConflictError value) conflictError,
    required TResult Function(_NetworkError value) networkError,
    required TResult Function(_TimeoutError value) timeoutError,
    required TResult Function(_ServerError value) serverError,
    required TResult Function(_CacheError value) cacheError,
    required TResult Function(_ConnectionError value) connectionError,
    required TResult Function(_SubscriptionError value) subscriptionError,
    required TResult Function(_UnknownError value) unknownError,
  }) {
    return validationError(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_ValidationError value)? validationError,
    TResult? Function(_UnauthorizedError value)? unauthorizedError,
    TResult? Function(_ForbiddenError value)? forbiddenError,
    TResult? Function(_NotFoundError value)? notFoundError,
    TResult? Function(_ConflictError value)? conflictError,
    TResult? Function(_NetworkError value)? networkError,
    TResult? Function(_TimeoutError value)? timeoutError,
    TResult? Function(_ServerError value)? serverError,
    TResult? Function(_CacheError value)? cacheError,
    TResult? Function(_ConnectionError value)? connectionError,
    TResult? Function(_SubscriptionError value)? subscriptionError,
    TResult? Function(_UnknownError value)? unknownError,
  }) {
    return validationError?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_ValidationError value)? validationError,
    TResult Function(_UnauthorizedError value)? unauthorizedError,
    TResult Function(_ForbiddenError value)? forbiddenError,
    TResult Function(_NotFoundError value)? notFoundError,
    TResult Function(_ConflictError value)? conflictError,
    TResult Function(_NetworkError value)? networkError,
    TResult Function(_TimeoutError value)? timeoutError,
    TResult Function(_ServerError value)? serverError,
    TResult Function(_CacheError value)? cacheError,
    TResult Function(_ConnectionError value)? connectionError,
    TResult Function(_SubscriptionError value)? subscriptionError,
    TResult Function(_UnknownError value)? unknownError,
    required TResult orElse(),
  }) {
    if (validationError != null) {
      return validationError(this);
    }
    return orElse();
  }
}

abstract class _ValidationError implements NotificationFailure {
  const factory _ValidationError(final String message) = _$ValidationErrorImpl;

  @override
  String get message;
  @override
  @JsonKey(ignore: true)
  _$$ValidationErrorImplCopyWith<_$ValidationErrorImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$UnauthorizedErrorImplCopyWith<$Res>
    implements $NotificationFailureCopyWith<$Res> {
  factory _$$UnauthorizedErrorImplCopyWith(_$UnauthorizedErrorImpl value,
          $Res Function(_$UnauthorizedErrorImpl) then) =
      __$$UnauthorizedErrorImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String message});
}

/// @nodoc
class __$$UnauthorizedErrorImplCopyWithImpl<$Res>
    extends _$NotificationFailureCopyWithImpl<$Res, _$UnauthorizedErrorImpl>
    implements _$$UnauthorizedErrorImplCopyWith<$Res> {
  __$$UnauthorizedErrorImplCopyWithImpl(_$UnauthorizedErrorImpl _value,
      $Res Function(_$UnauthorizedErrorImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? message = null,
  }) {
    return _then(_$UnauthorizedErrorImpl(
      null == message
          ? _value.message
          : message // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc

class _$UnauthorizedErrorImpl implements _UnauthorizedError {
  const _$UnauthorizedErrorImpl(this.message);

  @override
  final String message;

  @override
  String toString() {
    return 'NotificationFailure.unauthorizedError(message: $message)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$UnauthorizedErrorImpl &&
            (identical(other.message, message) || other.message == message));
  }

  @override
  int get hashCode => Object.hash(runtimeType, message);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$UnauthorizedErrorImplCopyWith<_$UnauthorizedErrorImpl> get copyWith =>
      __$$UnauthorizedErrorImplCopyWithImpl<_$UnauthorizedErrorImpl>(
          this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(String message) validationError,
    required TResult Function(String message) unauthorizedError,
    required TResult Function(String message) forbiddenError,
    required TResult Function(String message) notFoundError,
    required TResult Function(String message) conflictError,
    required TResult Function(String message) networkError,
    required TResult Function(String message) timeoutError,
    required TResult Function(String message) serverError,
    required TResult Function(String message) cacheError,
    required TResult Function(String message) connectionError,
    required TResult Function(String message) subscriptionError,
    required TResult Function(String message) unknownError,
  }) {
    return unauthorizedError(message);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(String message)? validationError,
    TResult? Function(String message)? unauthorizedError,
    TResult? Function(String message)? forbiddenError,
    TResult? Function(String message)? notFoundError,
    TResult? Function(String message)? conflictError,
    TResult? Function(String message)? networkError,
    TResult? Function(String message)? timeoutError,
    TResult? Function(String message)? serverError,
    TResult? Function(String message)? cacheError,
    TResult? Function(String message)? connectionError,
    TResult? Function(String message)? subscriptionError,
    TResult? Function(String message)? unknownError,
  }) {
    return unauthorizedError?.call(message);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(String message)? validationError,
    TResult Function(String message)? unauthorizedError,
    TResult Function(String message)? forbiddenError,
    TResult Function(String message)? notFoundError,
    TResult Function(String message)? conflictError,
    TResult Function(String message)? networkError,
    TResult Function(String message)? timeoutError,
    TResult Function(String message)? serverError,
    TResult Function(String message)? cacheError,
    TResult Function(String message)? connectionError,
    TResult Function(String message)? subscriptionError,
    TResult Function(String message)? unknownError,
    required TResult orElse(),
  }) {
    if (unauthorizedError != null) {
      return unauthorizedError(message);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(_ValidationError value) validationError,
    required TResult Function(_UnauthorizedError value) unauthorizedError,
    required TResult Function(_ForbiddenError value) forbiddenError,
    required TResult Function(_NotFoundError value) notFoundError,
    required TResult Function(_ConflictError value) conflictError,
    required TResult Function(_NetworkError value) networkError,
    required TResult Function(_TimeoutError value) timeoutError,
    required TResult Function(_ServerError value) serverError,
    required TResult Function(_CacheError value) cacheError,
    required TResult Function(_ConnectionError value) connectionError,
    required TResult Function(_SubscriptionError value) subscriptionError,
    required TResult Function(_UnknownError value) unknownError,
  }) {
    return unauthorizedError(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_ValidationError value)? validationError,
    TResult? Function(_UnauthorizedError value)? unauthorizedError,
    TResult? Function(_ForbiddenError value)? forbiddenError,
    TResult? Function(_NotFoundError value)? notFoundError,
    TResult? Function(_ConflictError value)? conflictError,
    TResult? Function(_NetworkError value)? networkError,
    TResult? Function(_TimeoutError value)? timeoutError,
    TResult? Function(_ServerError value)? serverError,
    TResult? Function(_CacheError value)? cacheError,
    TResult? Function(_ConnectionError value)? connectionError,
    TResult? Function(_SubscriptionError value)? subscriptionError,
    TResult? Function(_UnknownError value)? unknownError,
  }) {
    return unauthorizedError?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_ValidationError value)? validationError,
    TResult Function(_UnauthorizedError value)? unauthorizedError,
    TResult Function(_ForbiddenError value)? forbiddenError,
    TResult Function(_NotFoundError value)? notFoundError,
    TResult Function(_ConflictError value)? conflictError,
    TResult Function(_NetworkError value)? networkError,
    TResult Function(_TimeoutError value)? timeoutError,
    TResult Function(_ServerError value)? serverError,
    TResult Function(_CacheError value)? cacheError,
    TResult Function(_ConnectionError value)? connectionError,
    TResult Function(_SubscriptionError value)? subscriptionError,
    TResult Function(_UnknownError value)? unknownError,
    required TResult orElse(),
  }) {
    if (unauthorizedError != null) {
      return unauthorizedError(this);
    }
    return orElse();
  }
}

abstract class _UnauthorizedError implements NotificationFailure {
  const factory _UnauthorizedError(final String message) =
      _$UnauthorizedErrorImpl;

  @override
  String get message;
  @override
  @JsonKey(ignore: true)
  _$$UnauthorizedErrorImplCopyWith<_$UnauthorizedErrorImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$ForbiddenErrorImplCopyWith<$Res>
    implements $NotificationFailureCopyWith<$Res> {
  factory _$$ForbiddenErrorImplCopyWith(_$ForbiddenErrorImpl value,
          $Res Function(_$ForbiddenErrorImpl) then) =
      __$$ForbiddenErrorImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String message});
}

/// @nodoc
class __$$ForbiddenErrorImplCopyWithImpl<$Res>
    extends _$NotificationFailureCopyWithImpl<$Res, _$ForbiddenErrorImpl>
    implements _$$ForbiddenErrorImplCopyWith<$Res> {
  __$$ForbiddenErrorImplCopyWithImpl(
      _$ForbiddenErrorImpl _value, $Res Function(_$ForbiddenErrorImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? message = null,
  }) {
    return _then(_$ForbiddenErrorImpl(
      null == message
          ? _value.message
          : message // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc

class _$ForbiddenErrorImpl implements _ForbiddenError {
  const _$ForbiddenErrorImpl(this.message);

  @override
  final String message;

  @override
  String toString() {
    return 'NotificationFailure.forbiddenError(message: $message)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ForbiddenErrorImpl &&
            (identical(other.message, message) || other.message == message));
  }

  @override
  int get hashCode => Object.hash(runtimeType, message);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$ForbiddenErrorImplCopyWith<_$ForbiddenErrorImpl> get copyWith =>
      __$$ForbiddenErrorImplCopyWithImpl<_$ForbiddenErrorImpl>(
          this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(String message) validationError,
    required TResult Function(String message) unauthorizedError,
    required TResult Function(String message) forbiddenError,
    required TResult Function(String message) notFoundError,
    required TResult Function(String message) conflictError,
    required TResult Function(String message) networkError,
    required TResult Function(String message) timeoutError,
    required TResult Function(String message) serverError,
    required TResult Function(String message) cacheError,
    required TResult Function(String message) connectionError,
    required TResult Function(String message) subscriptionError,
    required TResult Function(String message) unknownError,
  }) {
    return forbiddenError(message);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(String message)? validationError,
    TResult? Function(String message)? unauthorizedError,
    TResult? Function(String message)? forbiddenError,
    TResult? Function(String message)? notFoundError,
    TResult? Function(String message)? conflictError,
    TResult? Function(String message)? networkError,
    TResult? Function(String message)? timeoutError,
    TResult? Function(String message)? serverError,
    TResult? Function(String message)? cacheError,
    TResult? Function(String message)? connectionError,
    TResult? Function(String message)? subscriptionError,
    TResult? Function(String message)? unknownError,
  }) {
    return forbiddenError?.call(message);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(String message)? validationError,
    TResult Function(String message)? unauthorizedError,
    TResult Function(String message)? forbiddenError,
    TResult Function(String message)? notFoundError,
    TResult Function(String message)? conflictError,
    TResult Function(String message)? networkError,
    TResult Function(String message)? timeoutError,
    TResult Function(String message)? serverError,
    TResult Function(String message)? cacheError,
    TResult Function(String message)? connectionError,
    TResult Function(String message)? subscriptionError,
    TResult Function(String message)? unknownError,
    required TResult orElse(),
  }) {
    if (forbiddenError != null) {
      return forbiddenError(message);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(_ValidationError value) validationError,
    required TResult Function(_UnauthorizedError value) unauthorizedError,
    required TResult Function(_ForbiddenError value) forbiddenError,
    required TResult Function(_NotFoundError value) notFoundError,
    required TResult Function(_ConflictError value) conflictError,
    required TResult Function(_NetworkError value) networkError,
    required TResult Function(_TimeoutError value) timeoutError,
    required TResult Function(_ServerError value) serverError,
    required TResult Function(_CacheError value) cacheError,
    required TResult Function(_ConnectionError value) connectionError,
    required TResult Function(_SubscriptionError value) subscriptionError,
    required TResult Function(_UnknownError value) unknownError,
  }) {
    return forbiddenError(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_ValidationError value)? validationError,
    TResult? Function(_UnauthorizedError value)? unauthorizedError,
    TResult? Function(_ForbiddenError value)? forbiddenError,
    TResult? Function(_NotFoundError value)? notFoundError,
    TResult? Function(_ConflictError value)? conflictError,
    TResult? Function(_NetworkError value)? networkError,
    TResult? Function(_TimeoutError value)? timeoutError,
    TResult? Function(_ServerError value)? serverError,
    TResult? Function(_CacheError value)? cacheError,
    TResult? Function(_ConnectionError value)? connectionError,
    TResult? Function(_SubscriptionError value)? subscriptionError,
    TResult? Function(_UnknownError value)? unknownError,
  }) {
    return forbiddenError?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_ValidationError value)? validationError,
    TResult Function(_UnauthorizedError value)? unauthorizedError,
    TResult Function(_ForbiddenError value)? forbiddenError,
    TResult Function(_NotFoundError value)? notFoundError,
    TResult Function(_ConflictError value)? conflictError,
    TResult Function(_NetworkError value)? networkError,
    TResult Function(_TimeoutError value)? timeoutError,
    TResult Function(_ServerError value)? serverError,
    TResult Function(_CacheError value)? cacheError,
    TResult Function(_ConnectionError value)? connectionError,
    TResult Function(_SubscriptionError value)? subscriptionError,
    TResult Function(_UnknownError value)? unknownError,
    required TResult orElse(),
  }) {
    if (forbiddenError != null) {
      return forbiddenError(this);
    }
    return orElse();
  }
}

abstract class _ForbiddenError implements NotificationFailure {
  const factory _ForbiddenError(final String message) = _$ForbiddenErrorImpl;

  @override
  String get message;
  @override
  @JsonKey(ignore: true)
  _$$ForbiddenErrorImplCopyWith<_$ForbiddenErrorImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$NotFoundErrorImplCopyWith<$Res>
    implements $NotificationFailureCopyWith<$Res> {
  factory _$$NotFoundErrorImplCopyWith(
          _$NotFoundErrorImpl value, $Res Function(_$NotFoundErrorImpl) then) =
      __$$NotFoundErrorImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String message});
}

/// @nodoc
class __$$NotFoundErrorImplCopyWithImpl<$Res>
    extends _$NotificationFailureCopyWithImpl<$Res, _$NotFoundErrorImpl>
    implements _$$NotFoundErrorImplCopyWith<$Res> {
  __$$NotFoundErrorImplCopyWithImpl(
      _$NotFoundErrorImpl _value, $Res Function(_$NotFoundErrorImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? message = null,
  }) {
    return _then(_$NotFoundErrorImpl(
      null == message
          ? _value.message
          : message // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc

class _$NotFoundErrorImpl implements _NotFoundError {
  const _$NotFoundErrorImpl(this.message);

  @override
  final String message;

  @override
  String toString() {
    return 'NotificationFailure.notFoundError(message: $message)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$NotFoundErrorImpl &&
            (identical(other.message, message) || other.message == message));
  }

  @override
  int get hashCode => Object.hash(runtimeType, message);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$NotFoundErrorImplCopyWith<_$NotFoundErrorImpl> get copyWith =>
      __$$NotFoundErrorImplCopyWithImpl<_$NotFoundErrorImpl>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(String message) validationError,
    required TResult Function(String message) unauthorizedError,
    required TResult Function(String message) forbiddenError,
    required TResult Function(String message) notFoundError,
    required TResult Function(String message) conflictError,
    required TResult Function(String message) networkError,
    required TResult Function(String message) timeoutError,
    required TResult Function(String message) serverError,
    required TResult Function(String message) cacheError,
    required TResult Function(String message) connectionError,
    required TResult Function(String message) subscriptionError,
    required TResult Function(String message) unknownError,
  }) {
    return notFoundError(message);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(String message)? validationError,
    TResult? Function(String message)? unauthorizedError,
    TResult? Function(String message)? forbiddenError,
    TResult? Function(String message)? notFoundError,
    TResult? Function(String message)? conflictError,
    TResult? Function(String message)? networkError,
    TResult? Function(String message)? timeoutError,
    TResult? Function(String message)? serverError,
    TResult? Function(String message)? cacheError,
    TResult? Function(String message)? connectionError,
    TResult? Function(String message)? subscriptionError,
    TResult? Function(String message)? unknownError,
  }) {
    return notFoundError?.call(message);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(String message)? validationError,
    TResult Function(String message)? unauthorizedError,
    TResult Function(String message)? forbiddenError,
    TResult Function(String message)? notFoundError,
    TResult Function(String message)? conflictError,
    TResult Function(String message)? networkError,
    TResult Function(String message)? timeoutError,
    TResult Function(String message)? serverError,
    TResult Function(String message)? cacheError,
    TResult Function(String message)? connectionError,
    TResult Function(String message)? subscriptionError,
    TResult Function(String message)? unknownError,
    required TResult orElse(),
  }) {
    if (notFoundError != null) {
      return notFoundError(message);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(_ValidationError value) validationError,
    required TResult Function(_UnauthorizedError value) unauthorizedError,
    required TResult Function(_ForbiddenError value) forbiddenError,
    required TResult Function(_NotFoundError value) notFoundError,
    required TResult Function(_ConflictError value) conflictError,
    required TResult Function(_NetworkError value) networkError,
    required TResult Function(_TimeoutError value) timeoutError,
    required TResult Function(_ServerError value) serverError,
    required TResult Function(_CacheError value) cacheError,
    required TResult Function(_ConnectionError value) connectionError,
    required TResult Function(_SubscriptionError value) subscriptionError,
    required TResult Function(_UnknownError value) unknownError,
  }) {
    return notFoundError(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_ValidationError value)? validationError,
    TResult? Function(_UnauthorizedError value)? unauthorizedError,
    TResult? Function(_ForbiddenError value)? forbiddenError,
    TResult? Function(_NotFoundError value)? notFoundError,
    TResult? Function(_ConflictError value)? conflictError,
    TResult? Function(_NetworkError value)? networkError,
    TResult? Function(_TimeoutError value)? timeoutError,
    TResult? Function(_ServerError value)? serverError,
    TResult? Function(_CacheError value)? cacheError,
    TResult? Function(_ConnectionError value)? connectionError,
    TResult? Function(_SubscriptionError value)? subscriptionError,
    TResult? Function(_UnknownError value)? unknownError,
  }) {
    return notFoundError?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_ValidationError value)? validationError,
    TResult Function(_UnauthorizedError value)? unauthorizedError,
    TResult Function(_ForbiddenError value)? forbiddenError,
    TResult Function(_NotFoundError value)? notFoundError,
    TResult Function(_ConflictError value)? conflictError,
    TResult Function(_NetworkError value)? networkError,
    TResult Function(_TimeoutError value)? timeoutError,
    TResult Function(_ServerError value)? serverError,
    TResult Function(_CacheError value)? cacheError,
    TResult Function(_ConnectionError value)? connectionError,
    TResult Function(_SubscriptionError value)? subscriptionError,
    TResult Function(_UnknownError value)? unknownError,
    required TResult orElse(),
  }) {
    if (notFoundError != null) {
      return notFoundError(this);
    }
    return orElse();
  }
}

abstract class _NotFoundError implements NotificationFailure {
  const factory _NotFoundError(final String message) = _$NotFoundErrorImpl;

  @override
  String get message;
  @override
  @JsonKey(ignore: true)
  _$$NotFoundErrorImplCopyWith<_$NotFoundErrorImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$ConflictErrorImplCopyWith<$Res>
    implements $NotificationFailureCopyWith<$Res> {
  factory _$$ConflictErrorImplCopyWith(
          _$ConflictErrorImpl value, $Res Function(_$ConflictErrorImpl) then) =
      __$$ConflictErrorImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String message});
}

/// @nodoc
class __$$ConflictErrorImplCopyWithImpl<$Res>
    extends _$NotificationFailureCopyWithImpl<$Res, _$ConflictErrorImpl>
    implements _$$ConflictErrorImplCopyWith<$Res> {
  __$$ConflictErrorImplCopyWithImpl(
      _$ConflictErrorImpl _value, $Res Function(_$ConflictErrorImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? message = null,
  }) {
    return _then(_$ConflictErrorImpl(
      null == message
          ? _value.message
          : message // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc

class _$ConflictErrorImpl implements _ConflictError {
  const _$ConflictErrorImpl(this.message);

  @override
  final String message;

  @override
  String toString() {
    return 'NotificationFailure.conflictError(message: $message)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ConflictErrorImpl &&
            (identical(other.message, message) || other.message == message));
  }

  @override
  int get hashCode => Object.hash(runtimeType, message);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$ConflictErrorImplCopyWith<_$ConflictErrorImpl> get copyWith =>
      __$$ConflictErrorImplCopyWithImpl<_$ConflictErrorImpl>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(String message) validationError,
    required TResult Function(String message) unauthorizedError,
    required TResult Function(String message) forbiddenError,
    required TResult Function(String message) notFoundError,
    required TResult Function(String message) conflictError,
    required TResult Function(String message) networkError,
    required TResult Function(String message) timeoutError,
    required TResult Function(String message) serverError,
    required TResult Function(String message) cacheError,
    required TResult Function(String message) connectionError,
    required TResult Function(String message) subscriptionError,
    required TResult Function(String message) unknownError,
  }) {
    return conflictError(message);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(String message)? validationError,
    TResult? Function(String message)? unauthorizedError,
    TResult? Function(String message)? forbiddenError,
    TResult? Function(String message)? notFoundError,
    TResult? Function(String message)? conflictError,
    TResult? Function(String message)? networkError,
    TResult? Function(String message)? timeoutError,
    TResult? Function(String message)? serverError,
    TResult? Function(String message)? cacheError,
    TResult? Function(String message)? connectionError,
    TResult? Function(String message)? subscriptionError,
    TResult? Function(String message)? unknownError,
  }) {
    return conflictError?.call(message);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(String message)? validationError,
    TResult Function(String message)? unauthorizedError,
    TResult Function(String message)? forbiddenError,
    TResult Function(String message)? notFoundError,
    TResult Function(String message)? conflictError,
    TResult Function(String message)? networkError,
    TResult Function(String message)? timeoutError,
    TResult Function(String message)? serverError,
    TResult Function(String message)? cacheError,
    TResult Function(String message)? connectionError,
    TResult Function(String message)? subscriptionError,
    TResult Function(String message)? unknownError,
    required TResult orElse(),
  }) {
    if (conflictError != null) {
      return conflictError(message);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(_ValidationError value) validationError,
    required TResult Function(_UnauthorizedError value) unauthorizedError,
    required TResult Function(_ForbiddenError value) forbiddenError,
    required TResult Function(_NotFoundError value) notFoundError,
    required TResult Function(_ConflictError value) conflictError,
    required TResult Function(_NetworkError value) networkError,
    required TResult Function(_TimeoutError value) timeoutError,
    required TResult Function(_ServerError value) serverError,
    required TResult Function(_CacheError value) cacheError,
    required TResult Function(_ConnectionError value) connectionError,
    required TResult Function(_SubscriptionError value) subscriptionError,
    required TResult Function(_UnknownError value) unknownError,
  }) {
    return conflictError(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_ValidationError value)? validationError,
    TResult? Function(_UnauthorizedError value)? unauthorizedError,
    TResult? Function(_ForbiddenError value)? forbiddenError,
    TResult? Function(_NotFoundError value)? notFoundError,
    TResult? Function(_ConflictError value)? conflictError,
    TResult? Function(_NetworkError value)? networkError,
    TResult? Function(_TimeoutError value)? timeoutError,
    TResult? Function(_ServerError value)? serverError,
    TResult? Function(_CacheError value)? cacheError,
    TResult? Function(_ConnectionError value)? connectionError,
    TResult? Function(_SubscriptionError value)? subscriptionError,
    TResult? Function(_UnknownError value)? unknownError,
  }) {
    return conflictError?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_ValidationError value)? validationError,
    TResult Function(_UnauthorizedError value)? unauthorizedError,
    TResult Function(_ForbiddenError value)? forbiddenError,
    TResult Function(_NotFoundError value)? notFoundError,
    TResult Function(_ConflictError value)? conflictError,
    TResult Function(_NetworkError value)? networkError,
    TResult Function(_TimeoutError value)? timeoutError,
    TResult Function(_ServerError value)? serverError,
    TResult Function(_CacheError value)? cacheError,
    TResult Function(_ConnectionError value)? connectionError,
    TResult Function(_SubscriptionError value)? subscriptionError,
    TResult Function(_UnknownError value)? unknownError,
    required TResult orElse(),
  }) {
    if (conflictError != null) {
      return conflictError(this);
    }
    return orElse();
  }
}

abstract class _ConflictError implements NotificationFailure {
  const factory _ConflictError(final String message) = _$ConflictErrorImpl;

  @override
  String get message;
  @override
  @JsonKey(ignore: true)
  _$$ConflictErrorImplCopyWith<_$ConflictErrorImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$NetworkErrorImplCopyWith<$Res>
    implements $NotificationFailureCopyWith<$Res> {
  factory _$$NetworkErrorImplCopyWith(
          _$NetworkErrorImpl value, $Res Function(_$NetworkErrorImpl) then) =
      __$$NetworkErrorImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String message});
}

/// @nodoc
class __$$NetworkErrorImplCopyWithImpl<$Res>
    extends _$NotificationFailureCopyWithImpl<$Res, _$NetworkErrorImpl>
    implements _$$NetworkErrorImplCopyWith<$Res> {
  __$$NetworkErrorImplCopyWithImpl(
      _$NetworkErrorImpl _value, $Res Function(_$NetworkErrorImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? message = null,
  }) {
    return _then(_$NetworkErrorImpl(
      null == message
          ? _value.message
          : message // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc

class _$NetworkErrorImpl implements _NetworkError {
  const _$NetworkErrorImpl(this.message);

  @override
  final String message;

  @override
  String toString() {
    return 'NotificationFailure.networkError(message: $message)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$NetworkErrorImpl &&
            (identical(other.message, message) || other.message == message));
  }

  @override
  int get hashCode => Object.hash(runtimeType, message);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$NetworkErrorImplCopyWith<_$NetworkErrorImpl> get copyWith =>
      __$$NetworkErrorImplCopyWithImpl<_$NetworkErrorImpl>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(String message) validationError,
    required TResult Function(String message) unauthorizedError,
    required TResult Function(String message) forbiddenError,
    required TResult Function(String message) notFoundError,
    required TResult Function(String message) conflictError,
    required TResult Function(String message) networkError,
    required TResult Function(String message) timeoutError,
    required TResult Function(String message) serverError,
    required TResult Function(String message) cacheError,
    required TResult Function(String message) connectionError,
    required TResult Function(String message) subscriptionError,
    required TResult Function(String message) unknownError,
  }) {
    return networkError(message);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(String message)? validationError,
    TResult? Function(String message)? unauthorizedError,
    TResult? Function(String message)? forbiddenError,
    TResult? Function(String message)? notFoundError,
    TResult? Function(String message)? conflictError,
    TResult? Function(String message)? networkError,
    TResult? Function(String message)? timeoutError,
    TResult? Function(String message)? serverError,
    TResult? Function(String message)? cacheError,
    TResult? Function(String message)? connectionError,
    TResult? Function(String message)? subscriptionError,
    TResult? Function(String message)? unknownError,
  }) {
    return networkError?.call(message);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(String message)? validationError,
    TResult Function(String message)? unauthorizedError,
    TResult Function(String message)? forbiddenError,
    TResult Function(String message)? notFoundError,
    TResult Function(String message)? conflictError,
    TResult Function(String message)? networkError,
    TResult Function(String message)? timeoutError,
    TResult Function(String message)? serverError,
    TResult Function(String message)? cacheError,
    TResult Function(String message)? connectionError,
    TResult Function(String message)? subscriptionError,
    TResult Function(String message)? unknownError,
    required TResult orElse(),
  }) {
    if (networkError != null) {
      return networkError(message);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(_ValidationError value) validationError,
    required TResult Function(_UnauthorizedError value) unauthorizedError,
    required TResult Function(_ForbiddenError value) forbiddenError,
    required TResult Function(_NotFoundError value) notFoundError,
    required TResult Function(_ConflictError value) conflictError,
    required TResult Function(_NetworkError value) networkError,
    required TResult Function(_TimeoutError value) timeoutError,
    required TResult Function(_ServerError value) serverError,
    required TResult Function(_CacheError value) cacheError,
    required TResult Function(_ConnectionError value) connectionError,
    required TResult Function(_SubscriptionError value) subscriptionError,
    required TResult Function(_UnknownError value) unknownError,
  }) {
    return networkError(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_ValidationError value)? validationError,
    TResult? Function(_UnauthorizedError value)? unauthorizedError,
    TResult? Function(_ForbiddenError value)? forbiddenError,
    TResult? Function(_NotFoundError value)? notFoundError,
    TResult? Function(_ConflictError value)? conflictError,
    TResult? Function(_NetworkError value)? networkError,
    TResult? Function(_TimeoutError value)? timeoutError,
    TResult? Function(_ServerError value)? serverError,
    TResult? Function(_CacheError value)? cacheError,
    TResult? Function(_ConnectionError value)? connectionError,
    TResult? Function(_SubscriptionError value)? subscriptionError,
    TResult? Function(_UnknownError value)? unknownError,
  }) {
    return networkError?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_ValidationError value)? validationError,
    TResult Function(_UnauthorizedError value)? unauthorizedError,
    TResult Function(_ForbiddenError value)? forbiddenError,
    TResult Function(_NotFoundError value)? notFoundError,
    TResult Function(_ConflictError value)? conflictError,
    TResult Function(_NetworkError value)? networkError,
    TResult Function(_TimeoutError value)? timeoutError,
    TResult Function(_ServerError value)? serverError,
    TResult Function(_CacheError value)? cacheError,
    TResult Function(_ConnectionError value)? connectionError,
    TResult Function(_SubscriptionError value)? subscriptionError,
    TResult Function(_UnknownError value)? unknownError,
    required TResult orElse(),
  }) {
    if (networkError != null) {
      return networkError(this);
    }
    return orElse();
  }
}

abstract class _NetworkError implements NotificationFailure {
  const factory _NetworkError(final String message) = _$NetworkErrorImpl;

  @override
  String get message;
  @override
  @JsonKey(ignore: true)
  _$$NetworkErrorImplCopyWith<_$NetworkErrorImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$TimeoutErrorImplCopyWith<$Res>
    implements $NotificationFailureCopyWith<$Res> {
  factory _$$TimeoutErrorImplCopyWith(
          _$TimeoutErrorImpl value, $Res Function(_$TimeoutErrorImpl) then) =
      __$$TimeoutErrorImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String message});
}

/// @nodoc
class __$$TimeoutErrorImplCopyWithImpl<$Res>
    extends _$NotificationFailureCopyWithImpl<$Res, _$TimeoutErrorImpl>
    implements _$$TimeoutErrorImplCopyWith<$Res> {
  __$$TimeoutErrorImplCopyWithImpl(
      _$TimeoutErrorImpl _value, $Res Function(_$TimeoutErrorImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? message = null,
  }) {
    return _then(_$TimeoutErrorImpl(
      null == message
          ? _value.message
          : message // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc

class _$TimeoutErrorImpl implements _TimeoutError {
  const _$TimeoutErrorImpl(this.message);

  @override
  final String message;

  @override
  String toString() {
    return 'NotificationFailure.timeoutError(message: $message)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$TimeoutErrorImpl &&
            (identical(other.message, message) || other.message == message));
  }

  @override
  int get hashCode => Object.hash(runtimeType, message);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$TimeoutErrorImplCopyWith<_$TimeoutErrorImpl> get copyWith =>
      __$$TimeoutErrorImplCopyWithImpl<_$TimeoutErrorImpl>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(String message) validationError,
    required TResult Function(String message) unauthorizedError,
    required TResult Function(String message) forbiddenError,
    required TResult Function(String message) notFoundError,
    required TResult Function(String message) conflictError,
    required TResult Function(String message) networkError,
    required TResult Function(String message) timeoutError,
    required TResult Function(String message) serverError,
    required TResult Function(String message) cacheError,
    required TResult Function(String message) connectionError,
    required TResult Function(String message) subscriptionError,
    required TResult Function(String message) unknownError,
  }) {
    return timeoutError(message);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(String message)? validationError,
    TResult? Function(String message)? unauthorizedError,
    TResult? Function(String message)? forbiddenError,
    TResult? Function(String message)? notFoundError,
    TResult? Function(String message)? conflictError,
    TResult? Function(String message)? networkError,
    TResult? Function(String message)? timeoutError,
    TResult? Function(String message)? serverError,
    TResult? Function(String message)? cacheError,
    TResult? Function(String message)? connectionError,
    TResult? Function(String message)? subscriptionError,
    TResult? Function(String message)? unknownError,
  }) {
    return timeoutError?.call(message);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(String message)? validationError,
    TResult Function(String message)? unauthorizedError,
    TResult Function(String message)? forbiddenError,
    TResult Function(String message)? notFoundError,
    TResult Function(String message)? conflictError,
    TResult Function(String message)? networkError,
    TResult Function(String message)? timeoutError,
    TResult Function(String message)? serverError,
    TResult Function(String message)? cacheError,
    TResult Function(String message)? connectionError,
    TResult Function(String message)? subscriptionError,
    TResult Function(String message)? unknownError,
    required TResult orElse(),
  }) {
    if (timeoutError != null) {
      return timeoutError(message);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(_ValidationError value) validationError,
    required TResult Function(_UnauthorizedError value) unauthorizedError,
    required TResult Function(_ForbiddenError value) forbiddenError,
    required TResult Function(_NotFoundError value) notFoundError,
    required TResult Function(_ConflictError value) conflictError,
    required TResult Function(_NetworkError value) networkError,
    required TResult Function(_TimeoutError value) timeoutError,
    required TResult Function(_ServerError value) serverError,
    required TResult Function(_CacheError value) cacheError,
    required TResult Function(_ConnectionError value) connectionError,
    required TResult Function(_SubscriptionError value) subscriptionError,
    required TResult Function(_UnknownError value) unknownError,
  }) {
    return timeoutError(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_ValidationError value)? validationError,
    TResult? Function(_UnauthorizedError value)? unauthorizedError,
    TResult? Function(_ForbiddenError value)? forbiddenError,
    TResult? Function(_NotFoundError value)? notFoundError,
    TResult? Function(_ConflictError value)? conflictError,
    TResult? Function(_NetworkError value)? networkError,
    TResult? Function(_TimeoutError value)? timeoutError,
    TResult? Function(_ServerError value)? serverError,
    TResult? Function(_CacheError value)? cacheError,
    TResult? Function(_ConnectionError value)? connectionError,
    TResult? Function(_SubscriptionError value)? subscriptionError,
    TResult? Function(_UnknownError value)? unknownError,
  }) {
    return timeoutError?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_ValidationError value)? validationError,
    TResult Function(_UnauthorizedError value)? unauthorizedError,
    TResult Function(_ForbiddenError value)? forbiddenError,
    TResult Function(_NotFoundError value)? notFoundError,
    TResult Function(_ConflictError value)? conflictError,
    TResult Function(_NetworkError value)? networkError,
    TResult Function(_TimeoutError value)? timeoutError,
    TResult Function(_ServerError value)? serverError,
    TResult Function(_CacheError value)? cacheError,
    TResult Function(_ConnectionError value)? connectionError,
    TResult Function(_SubscriptionError value)? subscriptionError,
    TResult Function(_UnknownError value)? unknownError,
    required TResult orElse(),
  }) {
    if (timeoutError != null) {
      return timeoutError(this);
    }
    return orElse();
  }
}

abstract class _TimeoutError implements NotificationFailure {
  const factory _TimeoutError(final String message) = _$TimeoutErrorImpl;

  @override
  String get message;
  @override
  @JsonKey(ignore: true)
  _$$TimeoutErrorImplCopyWith<_$TimeoutErrorImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$ServerErrorImplCopyWith<$Res>
    implements $NotificationFailureCopyWith<$Res> {
  factory _$$ServerErrorImplCopyWith(
          _$ServerErrorImpl value, $Res Function(_$ServerErrorImpl) then) =
      __$$ServerErrorImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String message});
}

/// @nodoc
class __$$ServerErrorImplCopyWithImpl<$Res>
    extends _$NotificationFailureCopyWithImpl<$Res, _$ServerErrorImpl>
    implements _$$ServerErrorImplCopyWith<$Res> {
  __$$ServerErrorImplCopyWithImpl(
      _$ServerErrorImpl _value, $Res Function(_$ServerErrorImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? message = null,
  }) {
    return _then(_$ServerErrorImpl(
      null == message
          ? _value.message
          : message // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc

class _$ServerErrorImpl implements _ServerError {
  const _$ServerErrorImpl(this.message);

  @override
  final String message;

  @override
  String toString() {
    return 'NotificationFailure.serverError(message: $message)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ServerErrorImpl &&
            (identical(other.message, message) || other.message == message));
  }

  @override
  int get hashCode => Object.hash(runtimeType, message);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$ServerErrorImplCopyWith<_$ServerErrorImpl> get copyWith =>
      __$$ServerErrorImplCopyWithImpl<_$ServerErrorImpl>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(String message) validationError,
    required TResult Function(String message) unauthorizedError,
    required TResult Function(String message) forbiddenError,
    required TResult Function(String message) notFoundError,
    required TResult Function(String message) conflictError,
    required TResult Function(String message) networkError,
    required TResult Function(String message) timeoutError,
    required TResult Function(String message) serverError,
    required TResult Function(String message) cacheError,
    required TResult Function(String message) connectionError,
    required TResult Function(String message) subscriptionError,
    required TResult Function(String message) unknownError,
  }) {
    return serverError(message);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(String message)? validationError,
    TResult? Function(String message)? unauthorizedError,
    TResult? Function(String message)? forbiddenError,
    TResult? Function(String message)? notFoundError,
    TResult? Function(String message)? conflictError,
    TResult? Function(String message)? networkError,
    TResult? Function(String message)? timeoutError,
    TResult? Function(String message)? serverError,
    TResult? Function(String message)? cacheError,
    TResult? Function(String message)? connectionError,
    TResult? Function(String message)? subscriptionError,
    TResult? Function(String message)? unknownError,
  }) {
    return serverError?.call(message);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(String message)? validationError,
    TResult Function(String message)? unauthorizedError,
    TResult Function(String message)? forbiddenError,
    TResult Function(String message)? notFoundError,
    TResult Function(String message)? conflictError,
    TResult Function(String message)? networkError,
    TResult Function(String message)? timeoutError,
    TResult Function(String message)? serverError,
    TResult Function(String message)? cacheError,
    TResult Function(String message)? connectionError,
    TResult Function(String message)? subscriptionError,
    TResult Function(String message)? unknownError,
    required TResult orElse(),
  }) {
    if (serverError != null) {
      return serverError(message);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(_ValidationError value) validationError,
    required TResult Function(_UnauthorizedError value) unauthorizedError,
    required TResult Function(_ForbiddenError value) forbiddenError,
    required TResult Function(_NotFoundError value) notFoundError,
    required TResult Function(_ConflictError value) conflictError,
    required TResult Function(_NetworkError value) networkError,
    required TResult Function(_TimeoutError value) timeoutError,
    required TResult Function(_ServerError value) serverError,
    required TResult Function(_CacheError value) cacheError,
    required TResult Function(_ConnectionError value) connectionError,
    required TResult Function(_SubscriptionError value) subscriptionError,
    required TResult Function(_UnknownError value) unknownError,
  }) {
    return serverError(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_ValidationError value)? validationError,
    TResult? Function(_UnauthorizedError value)? unauthorizedError,
    TResult? Function(_ForbiddenError value)? forbiddenError,
    TResult? Function(_NotFoundError value)? notFoundError,
    TResult? Function(_ConflictError value)? conflictError,
    TResult? Function(_NetworkError value)? networkError,
    TResult? Function(_TimeoutError value)? timeoutError,
    TResult? Function(_ServerError value)? serverError,
    TResult? Function(_CacheError value)? cacheError,
    TResult? Function(_ConnectionError value)? connectionError,
    TResult? Function(_SubscriptionError value)? subscriptionError,
    TResult? Function(_UnknownError value)? unknownError,
  }) {
    return serverError?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_ValidationError value)? validationError,
    TResult Function(_UnauthorizedError value)? unauthorizedError,
    TResult Function(_ForbiddenError value)? forbiddenError,
    TResult Function(_NotFoundError value)? notFoundError,
    TResult Function(_ConflictError value)? conflictError,
    TResult Function(_NetworkError value)? networkError,
    TResult Function(_TimeoutError value)? timeoutError,
    TResult Function(_ServerError value)? serverError,
    TResult Function(_CacheError value)? cacheError,
    TResult Function(_ConnectionError value)? connectionError,
    TResult Function(_SubscriptionError value)? subscriptionError,
    TResult Function(_UnknownError value)? unknownError,
    required TResult orElse(),
  }) {
    if (serverError != null) {
      return serverError(this);
    }
    return orElse();
  }
}

abstract class _ServerError implements NotificationFailure {
  const factory _ServerError(final String message) = _$ServerErrorImpl;

  @override
  String get message;
  @override
  @JsonKey(ignore: true)
  _$$ServerErrorImplCopyWith<_$ServerErrorImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$CacheErrorImplCopyWith<$Res>
    implements $NotificationFailureCopyWith<$Res> {
  factory _$$CacheErrorImplCopyWith(
          _$CacheErrorImpl value, $Res Function(_$CacheErrorImpl) then) =
      __$$CacheErrorImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String message});
}

/// @nodoc
class __$$CacheErrorImplCopyWithImpl<$Res>
    extends _$NotificationFailureCopyWithImpl<$Res, _$CacheErrorImpl>
    implements _$$CacheErrorImplCopyWith<$Res> {
  __$$CacheErrorImplCopyWithImpl(
      _$CacheErrorImpl _value, $Res Function(_$CacheErrorImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? message = null,
  }) {
    return _then(_$CacheErrorImpl(
      null == message
          ? _value.message
          : message // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc

class _$CacheErrorImpl implements _CacheError {
  const _$CacheErrorImpl(this.message);

  @override
  final String message;

  @override
  String toString() {
    return 'NotificationFailure.cacheError(message: $message)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CacheErrorImpl &&
            (identical(other.message, message) || other.message == message));
  }

  @override
  int get hashCode => Object.hash(runtimeType, message);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$CacheErrorImplCopyWith<_$CacheErrorImpl> get copyWith =>
      __$$CacheErrorImplCopyWithImpl<_$CacheErrorImpl>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(String message) validationError,
    required TResult Function(String message) unauthorizedError,
    required TResult Function(String message) forbiddenError,
    required TResult Function(String message) notFoundError,
    required TResult Function(String message) conflictError,
    required TResult Function(String message) networkError,
    required TResult Function(String message) timeoutError,
    required TResult Function(String message) serverError,
    required TResult Function(String message) cacheError,
    required TResult Function(String message) connectionError,
    required TResult Function(String message) subscriptionError,
    required TResult Function(String message) unknownError,
  }) {
    return cacheError(message);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(String message)? validationError,
    TResult? Function(String message)? unauthorizedError,
    TResult? Function(String message)? forbiddenError,
    TResult? Function(String message)? notFoundError,
    TResult? Function(String message)? conflictError,
    TResult? Function(String message)? networkError,
    TResult? Function(String message)? timeoutError,
    TResult? Function(String message)? serverError,
    TResult? Function(String message)? cacheError,
    TResult? Function(String message)? connectionError,
    TResult? Function(String message)? subscriptionError,
    TResult? Function(String message)? unknownError,
  }) {
    return cacheError?.call(message);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(String message)? validationError,
    TResult Function(String message)? unauthorizedError,
    TResult Function(String message)? forbiddenError,
    TResult Function(String message)? notFoundError,
    TResult Function(String message)? conflictError,
    TResult Function(String message)? networkError,
    TResult Function(String message)? timeoutError,
    TResult Function(String message)? serverError,
    TResult Function(String message)? cacheError,
    TResult Function(String message)? connectionError,
    TResult Function(String message)? subscriptionError,
    TResult Function(String message)? unknownError,
    required TResult orElse(),
  }) {
    if (cacheError != null) {
      return cacheError(message);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(_ValidationError value) validationError,
    required TResult Function(_UnauthorizedError value) unauthorizedError,
    required TResult Function(_ForbiddenError value) forbiddenError,
    required TResult Function(_NotFoundError value) notFoundError,
    required TResult Function(_ConflictError value) conflictError,
    required TResult Function(_NetworkError value) networkError,
    required TResult Function(_TimeoutError value) timeoutError,
    required TResult Function(_ServerError value) serverError,
    required TResult Function(_CacheError value) cacheError,
    required TResult Function(_ConnectionError value) connectionError,
    required TResult Function(_SubscriptionError value) subscriptionError,
    required TResult Function(_UnknownError value) unknownError,
  }) {
    return cacheError(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_ValidationError value)? validationError,
    TResult? Function(_UnauthorizedError value)? unauthorizedError,
    TResult? Function(_ForbiddenError value)? forbiddenError,
    TResult? Function(_NotFoundError value)? notFoundError,
    TResult? Function(_ConflictError value)? conflictError,
    TResult? Function(_NetworkError value)? networkError,
    TResult? Function(_TimeoutError value)? timeoutError,
    TResult? Function(_ServerError value)? serverError,
    TResult? Function(_CacheError value)? cacheError,
    TResult? Function(_ConnectionError value)? connectionError,
    TResult? Function(_SubscriptionError value)? subscriptionError,
    TResult? Function(_UnknownError value)? unknownError,
  }) {
    return cacheError?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_ValidationError value)? validationError,
    TResult Function(_UnauthorizedError value)? unauthorizedError,
    TResult Function(_ForbiddenError value)? forbiddenError,
    TResult Function(_NotFoundError value)? notFoundError,
    TResult Function(_ConflictError value)? conflictError,
    TResult Function(_NetworkError value)? networkError,
    TResult Function(_TimeoutError value)? timeoutError,
    TResult Function(_ServerError value)? serverError,
    TResult Function(_CacheError value)? cacheError,
    TResult Function(_ConnectionError value)? connectionError,
    TResult Function(_SubscriptionError value)? subscriptionError,
    TResult Function(_UnknownError value)? unknownError,
    required TResult orElse(),
  }) {
    if (cacheError != null) {
      return cacheError(this);
    }
    return orElse();
  }
}

abstract class _CacheError implements NotificationFailure {
  const factory _CacheError(final String message) = _$CacheErrorImpl;

  @override
  String get message;
  @override
  @JsonKey(ignore: true)
  _$$CacheErrorImplCopyWith<_$CacheErrorImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$ConnectionErrorImplCopyWith<$Res>
    implements $NotificationFailureCopyWith<$Res> {
  factory _$$ConnectionErrorImplCopyWith(_$ConnectionErrorImpl value,
          $Res Function(_$ConnectionErrorImpl) then) =
      __$$ConnectionErrorImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String message});
}

/// @nodoc
class __$$ConnectionErrorImplCopyWithImpl<$Res>
    extends _$NotificationFailureCopyWithImpl<$Res, _$ConnectionErrorImpl>
    implements _$$ConnectionErrorImplCopyWith<$Res> {
  __$$ConnectionErrorImplCopyWithImpl(
      _$ConnectionErrorImpl _value, $Res Function(_$ConnectionErrorImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? message = null,
  }) {
    return _then(_$ConnectionErrorImpl(
      null == message
          ? _value.message
          : message // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc

class _$ConnectionErrorImpl implements _ConnectionError {
  const _$ConnectionErrorImpl(this.message);

  @override
  final String message;

  @override
  String toString() {
    return 'NotificationFailure.connectionError(message: $message)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ConnectionErrorImpl &&
            (identical(other.message, message) || other.message == message));
  }

  @override
  int get hashCode => Object.hash(runtimeType, message);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$ConnectionErrorImplCopyWith<_$ConnectionErrorImpl> get copyWith =>
      __$$ConnectionErrorImplCopyWithImpl<_$ConnectionErrorImpl>(
          this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(String message) validationError,
    required TResult Function(String message) unauthorizedError,
    required TResult Function(String message) forbiddenError,
    required TResult Function(String message) notFoundError,
    required TResult Function(String message) conflictError,
    required TResult Function(String message) networkError,
    required TResult Function(String message) timeoutError,
    required TResult Function(String message) serverError,
    required TResult Function(String message) cacheError,
    required TResult Function(String message) connectionError,
    required TResult Function(String message) subscriptionError,
    required TResult Function(String message) unknownError,
  }) {
    return connectionError(message);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(String message)? validationError,
    TResult? Function(String message)? unauthorizedError,
    TResult? Function(String message)? forbiddenError,
    TResult? Function(String message)? notFoundError,
    TResult? Function(String message)? conflictError,
    TResult? Function(String message)? networkError,
    TResult? Function(String message)? timeoutError,
    TResult? Function(String message)? serverError,
    TResult? Function(String message)? cacheError,
    TResult? Function(String message)? connectionError,
    TResult? Function(String message)? subscriptionError,
    TResult? Function(String message)? unknownError,
  }) {
    return connectionError?.call(message);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(String message)? validationError,
    TResult Function(String message)? unauthorizedError,
    TResult Function(String message)? forbiddenError,
    TResult Function(String message)? notFoundError,
    TResult Function(String message)? conflictError,
    TResult Function(String message)? networkError,
    TResult Function(String message)? timeoutError,
    TResult Function(String message)? serverError,
    TResult Function(String message)? cacheError,
    TResult Function(String message)? connectionError,
    TResult Function(String message)? subscriptionError,
    TResult Function(String message)? unknownError,
    required TResult orElse(),
  }) {
    if (connectionError != null) {
      return connectionError(message);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(_ValidationError value) validationError,
    required TResult Function(_UnauthorizedError value) unauthorizedError,
    required TResult Function(_ForbiddenError value) forbiddenError,
    required TResult Function(_NotFoundError value) notFoundError,
    required TResult Function(_ConflictError value) conflictError,
    required TResult Function(_NetworkError value) networkError,
    required TResult Function(_TimeoutError value) timeoutError,
    required TResult Function(_ServerError value) serverError,
    required TResult Function(_CacheError value) cacheError,
    required TResult Function(_ConnectionError value) connectionError,
    required TResult Function(_SubscriptionError value) subscriptionError,
    required TResult Function(_UnknownError value) unknownError,
  }) {
    return connectionError(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_ValidationError value)? validationError,
    TResult? Function(_UnauthorizedError value)? unauthorizedError,
    TResult? Function(_ForbiddenError value)? forbiddenError,
    TResult? Function(_NotFoundError value)? notFoundError,
    TResult? Function(_ConflictError value)? conflictError,
    TResult? Function(_NetworkError value)? networkError,
    TResult? Function(_TimeoutError value)? timeoutError,
    TResult? Function(_ServerError value)? serverError,
    TResult? Function(_CacheError value)? cacheError,
    TResult? Function(_ConnectionError value)? connectionError,
    TResult? Function(_SubscriptionError value)? subscriptionError,
    TResult? Function(_UnknownError value)? unknownError,
  }) {
    return connectionError?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_ValidationError value)? validationError,
    TResult Function(_UnauthorizedError value)? unauthorizedError,
    TResult Function(_ForbiddenError value)? forbiddenError,
    TResult Function(_NotFoundError value)? notFoundError,
    TResult Function(_ConflictError value)? conflictError,
    TResult Function(_NetworkError value)? networkError,
    TResult Function(_TimeoutError value)? timeoutError,
    TResult Function(_ServerError value)? serverError,
    TResult Function(_CacheError value)? cacheError,
    TResult Function(_ConnectionError value)? connectionError,
    TResult Function(_SubscriptionError value)? subscriptionError,
    TResult Function(_UnknownError value)? unknownError,
    required TResult orElse(),
  }) {
    if (connectionError != null) {
      return connectionError(this);
    }
    return orElse();
  }
}

abstract class _ConnectionError implements NotificationFailure {
  const factory _ConnectionError(final String message) = _$ConnectionErrorImpl;

  @override
  String get message;
  @override
  @JsonKey(ignore: true)
  _$$ConnectionErrorImplCopyWith<_$ConnectionErrorImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$SubscriptionErrorImplCopyWith<$Res>
    implements $NotificationFailureCopyWith<$Res> {
  factory _$$SubscriptionErrorImplCopyWith(_$SubscriptionErrorImpl value,
          $Res Function(_$SubscriptionErrorImpl) then) =
      __$$SubscriptionErrorImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String message});
}

/// @nodoc
class __$$SubscriptionErrorImplCopyWithImpl<$Res>
    extends _$NotificationFailureCopyWithImpl<$Res, _$SubscriptionErrorImpl>
    implements _$$SubscriptionErrorImplCopyWith<$Res> {
  __$$SubscriptionErrorImplCopyWithImpl(_$SubscriptionErrorImpl _value,
      $Res Function(_$SubscriptionErrorImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? message = null,
  }) {
    return _then(_$SubscriptionErrorImpl(
      null == message
          ? _value.message
          : message // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc

class _$SubscriptionErrorImpl implements _SubscriptionError {
  const _$SubscriptionErrorImpl(this.message);

  @override
  final String message;

  @override
  String toString() {
    return 'NotificationFailure.subscriptionError(message: $message)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SubscriptionErrorImpl &&
            (identical(other.message, message) || other.message == message));
  }

  @override
  int get hashCode => Object.hash(runtimeType, message);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$SubscriptionErrorImplCopyWith<_$SubscriptionErrorImpl> get copyWith =>
      __$$SubscriptionErrorImplCopyWithImpl<_$SubscriptionErrorImpl>(
          this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(String message) validationError,
    required TResult Function(String message) unauthorizedError,
    required TResult Function(String message) forbiddenError,
    required TResult Function(String message) notFoundError,
    required TResult Function(String message) conflictError,
    required TResult Function(String message) networkError,
    required TResult Function(String message) timeoutError,
    required TResult Function(String message) serverError,
    required TResult Function(String message) cacheError,
    required TResult Function(String message) connectionError,
    required TResult Function(String message) subscriptionError,
    required TResult Function(String message) unknownError,
  }) {
    return subscriptionError(message);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(String message)? validationError,
    TResult? Function(String message)? unauthorizedError,
    TResult? Function(String message)? forbiddenError,
    TResult? Function(String message)? notFoundError,
    TResult? Function(String message)? conflictError,
    TResult? Function(String message)? networkError,
    TResult? Function(String message)? timeoutError,
    TResult? Function(String message)? serverError,
    TResult? Function(String message)? cacheError,
    TResult? Function(String message)? connectionError,
    TResult? Function(String message)? subscriptionError,
    TResult? Function(String message)? unknownError,
  }) {
    return subscriptionError?.call(message);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(String message)? validationError,
    TResult Function(String message)? unauthorizedError,
    TResult Function(String message)? forbiddenError,
    TResult Function(String message)? notFoundError,
    TResult Function(String message)? conflictError,
    TResult Function(String message)? networkError,
    TResult Function(String message)? timeoutError,
    TResult Function(String message)? serverError,
    TResult Function(String message)? cacheError,
    TResult Function(String message)? connectionError,
    TResult Function(String message)? subscriptionError,
    TResult Function(String message)? unknownError,
    required TResult orElse(),
  }) {
    if (subscriptionError != null) {
      return subscriptionError(message);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(_ValidationError value) validationError,
    required TResult Function(_UnauthorizedError value) unauthorizedError,
    required TResult Function(_ForbiddenError value) forbiddenError,
    required TResult Function(_NotFoundError value) notFoundError,
    required TResult Function(_ConflictError value) conflictError,
    required TResult Function(_NetworkError value) networkError,
    required TResult Function(_TimeoutError value) timeoutError,
    required TResult Function(_ServerError value) serverError,
    required TResult Function(_CacheError value) cacheError,
    required TResult Function(_ConnectionError value) connectionError,
    required TResult Function(_SubscriptionError value) subscriptionError,
    required TResult Function(_UnknownError value) unknownError,
  }) {
    return subscriptionError(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_ValidationError value)? validationError,
    TResult? Function(_UnauthorizedError value)? unauthorizedError,
    TResult? Function(_ForbiddenError value)? forbiddenError,
    TResult? Function(_NotFoundError value)? notFoundError,
    TResult? Function(_ConflictError value)? conflictError,
    TResult? Function(_NetworkError value)? networkError,
    TResult? Function(_TimeoutError value)? timeoutError,
    TResult? Function(_ServerError value)? serverError,
    TResult? Function(_CacheError value)? cacheError,
    TResult? Function(_ConnectionError value)? connectionError,
    TResult? Function(_SubscriptionError value)? subscriptionError,
    TResult? Function(_UnknownError value)? unknownError,
  }) {
    return subscriptionError?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_ValidationError value)? validationError,
    TResult Function(_UnauthorizedError value)? unauthorizedError,
    TResult Function(_ForbiddenError value)? forbiddenError,
    TResult Function(_NotFoundError value)? notFoundError,
    TResult Function(_ConflictError value)? conflictError,
    TResult Function(_NetworkError value)? networkError,
    TResult Function(_TimeoutError value)? timeoutError,
    TResult Function(_ServerError value)? serverError,
    TResult Function(_CacheError value)? cacheError,
    TResult Function(_ConnectionError value)? connectionError,
    TResult Function(_SubscriptionError value)? subscriptionError,
    TResult Function(_UnknownError value)? unknownError,
    required TResult orElse(),
  }) {
    if (subscriptionError != null) {
      return subscriptionError(this);
    }
    return orElse();
  }
}

abstract class _SubscriptionError implements NotificationFailure {
  const factory _SubscriptionError(final String message) =
      _$SubscriptionErrorImpl;

  @override
  String get message;
  @override
  @JsonKey(ignore: true)
  _$$SubscriptionErrorImplCopyWith<_$SubscriptionErrorImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$UnknownErrorImplCopyWith<$Res>
    implements $NotificationFailureCopyWith<$Res> {
  factory _$$UnknownErrorImplCopyWith(
          _$UnknownErrorImpl value, $Res Function(_$UnknownErrorImpl) then) =
      __$$UnknownErrorImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String message});
}

/// @nodoc
class __$$UnknownErrorImplCopyWithImpl<$Res>
    extends _$NotificationFailureCopyWithImpl<$Res, _$UnknownErrorImpl>
    implements _$$UnknownErrorImplCopyWith<$Res> {
  __$$UnknownErrorImplCopyWithImpl(
      _$UnknownErrorImpl _value, $Res Function(_$UnknownErrorImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? message = null,
  }) {
    return _then(_$UnknownErrorImpl(
      null == message
          ? _value.message
          : message // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc

class _$UnknownErrorImpl implements _UnknownError {
  const _$UnknownErrorImpl(this.message);

  @override
  final String message;

  @override
  String toString() {
    return 'NotificationFailure.unknownError(message: $message)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$UnknownErrorImpl &&
            (identical(other.message, message) || other.message == message));
  }

  @override
  int get hashCode => Object.hash(runtimeType, message);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$UnknownErrorImplCopyWith<_$UnknownErrorImpl> get copyWith =>
      __$$UnknownErrorImplCopyWithImpl<_$UnknownErrorImpl>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(String message) validationError,
    required TResult Function(String message) unauthorizedError,
    required TResult Function(String message) forbiddenError,
    required TResult Function(String message) notFoundError,
    required TResult Function(String message) conflictError,
    required TResult Function(String message) networkError,
    required TResult Function(String message) timeoutError,
    required TResult Function(String message) serverError,
    required TResult Function(String message) cacheError,
    required TResult Function(String message) connectionError,
    required TResult Function(String message) subscriptionError,
    required TResult Function(String message) unknownError,
  }) {
    return unknownError(message);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(String message)? validationError,
    TResult? Function(String message)? unauthorizedError,
    TResult? Function(String message)? forbiddenError,
    TResult? Function(String message)? notFoundError,
    TResult? Function(String message)? conflictError,
    TResult? Function(String message)? networkError,
    TResult? Function(String message)? timeoutError,
    TResult? Function(String message)? serverError,
    TResult? Function(String message)? cacheError,
    TResult? Function(String message)? connectionError,
    TResult? Function(String message)? subscriptionError,
    TResult? Function(String message)? unknownError,
  }) {
    return unknownError?.call(message);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(String message)? validationError,
    TResult Function(String message)? unauthorizedError,
    TResult Function(String message)? forbiddenError,
    TResult Function(String message)? notFoundError,
    TResult Function(String message)? conflictError,
    TResult Function(String message)? networkError,
    TResult Function(String message)? timeoutError,
    TResult Function(String message)? serverError,
    TResult Function(String message)? cacheError,
    TResult Function(String message)? connectionError,
    TResult Function(String message)? subscriptionError,
    TResult Function(String message)? unknownError,
    required TResult orElse(),
  }) {
    if (unknownError != null) {
      return unknownError(message);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(_ValidationError value) validationError,
    required TResult Function(_UnauthorizedError value) unauthorizedError,
    required TResult Function(_ForbiddenError value) forbiddenError,
    required TResult Function(_NotFoundError value) notFoundError,
    required TResult Function(_ConflictError value) conflictError,
    required TResult Function(_NetworkError value) networkError,
    required TResult Function(_TimeoutError value) timeoutError,
    required TResult Function(_ServerError value) serverError,
    required TResult Function(_CacheError value) cacheError,
    required TResult Function(_ConnectionError value) connectionError,
    required TResult Function(_SubscriptionError value) subscriptionError,
    required TResult Function(_UnknownError value) unknownError,
  }) {
    return unknownError(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_ValidationError value)? validationError,
    TResult? Function(_UnauthorizedError value)? unauthorizedError,
    TResult? Function(_ForbiddenError value)? forbiddenError,
    TResult? Function(_NotFoundError value)? notFoundError,
    TResult? Function(_ConflictError value)? conflictError,
    TResult? Function(_NetworkError value)? networkError,
    TResult? Function(_TimeoutError value)? timeoutError,
    TResult? Function(_ServerError value)? serverError,
    TResult? Function(_CacheError value)? cacheError,
    TResult? Function(_ConnectionError value)? connectionError,
    TResult? Function(_SubscriptionError value)? subscriptionError,
    TResult? Function(_UnknownError value)? unknownError,
  }) {
    return unknownError?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_ValidationError value)? validationError,
    TResult Function(_UnauthorizedError value)? unauthorizedError,
    TResult Function(_ForbiddenError value)? forbiddenError,
    TResult Function(_NotFoundError value)? notFoundError,
    TResult Function(_ConflictError value)? conflictError,
    TResult Function(_NetworkError value)? networkError,
    TResult Function(_TimeoutError value)? timeoutError,
    TResult Function(_ServerError value)? serverError,
    TResult Function(_CacheError value)? cacheError,
    TResult Function(_ConnectionError value)? connectionError,
    TResult Function(_SubscriptionError value)? subscriptionError,
    TResult Function(_UnknownError value)? unknownError,
    required TResult orElse(),
  }) {
    if (unknownError != null) {
      return unknownError(this);
    }
    return orElse();
  }
}

abstract class _UnknownError implements NotificationFailure {
  const factory _UnknownError(final String message) = _$UnknownErrorImpl;

  @override
  String get message;
  @override
  @JsonKey(ignore: true)
  _$$UnknownErrorImplCopyWith<_$UnknownErrorImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
