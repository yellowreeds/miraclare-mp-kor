// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'align_process_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$AlignProcessState {
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() ready,
    required TResult Function(MeasurementType detail) measuring,
    required TResult Function() finish,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? ready,
    TResult? Function(MeasurementType detail)? measuring,
    TResult? Function()? finish,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? ready,
    TResult Function(MeasurementType detail)? measuring,
    TResult Function()? finish,
    required TResult orElse(),
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(_Ready value) ready,
    required TResult Function(_Measuring value) measuring,
    required TResult Function(_Finish value) finish,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_Ready value)? ready,
    TResult? Function(_Measuring value)? measuring,
    TResult? Function(_Finish value)? finish,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_Ready value)? ready,
    TResult Function(_Measuring value)? measuring,
    TResult Function(_Finish value)? finish,
    required TResult orElse(),
  }) =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $AlignProcessStateCopyWith<$Res> {
  factory $AlignProcessStateCopyWith(
          AlignProcessState value, $Res Function(AlignProcessState) then) =
      _$AlignProcessStateCopyWithImpl<$Res, AlignProcessState>;
}

/// @nodoc
class _$AlignProcessStateCopyWithImpl<$Res, $Val extends AlignProcessState>
    implements $AlignProcessStateCopyWith<$Res> {
  _$AlignProcessStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;
}

/// @nodoc
abstract class _$$ReadyImplCopyWith<$Res> {
  factory _$$ReadyImplCopyWith(
          _$ReadyImpl value, $Res Function(_$ReadyImpl) then) =
      __$$ReadyImplCopyWithImpl<$Res>;
}

/// @nodoc
class __$$ReadyImplCopyWithImpl<$Res>
    extends _$AlignProcessStateCopyWithImpl<$Res, _$ReadyImpl>
    implements _$$ReadyImplCopyWith<$Res> {
  __$$ReadyImplCopyWithImpl(
      _$ReadyImpl _value, $Res Function(_$ReadyImpl) _then)
      : super(_value, _then);
}

/// @nodoc

class _$ReadyImpl extends _Ready {
  const _$ReadyImpl() : super._();

  @override
  String toString() {
    return 'AlignProcessState.ready()';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType && other is _$ReadyImpl);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() ready,
    required TResult Function(MeasurementType detail) measuring,
    required TResult Function() finish,
  }) {
    return ready();
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? ready,
    TResult? Function(MeasurementType detail)? measuring,
    TResult? Function()? finish,
  }) {
    return ready?.call();
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? ready,
    TResult Function(MeasurementType detail)? measuring,
    TResult Function()? finish,
    required TResult orElse(),
  }) {
    if (ready != null) {
      return ready();
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(_Ready value) ready,
    required TResult Function(_Measuring value) measuring,
    required TResult Function(_Finish value) finish,
  }) {
    return ready(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_Ready value)? ready,
    TResult? Function(_Measuring value)? measuring,
    TResult? Function(_Finish value)? finish,
  }) {
    return ready?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_Ready value)? ready,
    TResult Function(_Measuring value)? measuring,
    TResult Function(_Finish value)? finish,
    required TResult orElse(),
  }) {
    if (ready != null) {
      return ready(this);
    }
    return orElse();
  }
}

abstract class _Ready extends AlignProcessState {
  const factory _Ready() = _$ReadyImpl;
  const _Ready._() : super._();
}

/// @nodoc
abstract class _$$MeasuringImplCopyWith<$Res> {
  factory _$$MeasuringImplCopyWith(
          _$MeasuringImpl value, $Res Function(_$MeasuringImpl) then) =
      __$$MeasuringImplCopyWithImpl<$Res>;
  @useResult
  $Res call({MeasurementType detail});
}

/// @nodoc
class __$$MeasuringImplCopyWithImpl<$Res>
    extends _$AlignProcessStateCopyWithImpl<$Res, _$MeasuringImpl>
    implements _$$MeasuringImplCopyWith<$Res> {
  __$$MeasuringImplCopyWithImpl(
      _$MeasuringImpl _value, $Res Function(_$MeasuringImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? detail = null,
  }) {
    return _then(_$MeasuringImpl(
      null == detail
          ? _value.detail
          : detail // ignore: cast_nullable_to_non_nullable
              as MeasurementType,
    ));
  }
}

/// @nodoc

class _$MeasuringImpl extends _Measuring {
  const _$MeasuringImpl(this.detail) : super._();

  @override
  final MeasurementType detail;

  @override
  String toString() {
    return 'AlignProcessState.measuring(detail: $detail)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$MeasuringImpl &&
            (identical(other.detail, detail) || other.detail == detail));
  }

  @override
  int get hashCode => Object.hash(runtimeType, detail);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$MeasuringImplCopyWith<_$MeasuringImpl> get copyWith =>
      __$$MeasuringImplCopyWithImpl<_$MeasuringImpl>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() ready,
    required TResult Function(MeasurementType detail) measuring,
    required TResult Function() finish,
  }) {
    return measuring(detail);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? ready,
    TResult? Function(MeasurementType detail)? measuring,
    TResult? Function()? finish,
  }) {
    return measuring?.call(detail);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? ready,
    TResult Function(MeasurementType detail)? measuring,
    TResult Function()? finish,
    required TResult orElse(),
  }) {
    if (measuring != null) {
      return measuring(detail);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(_Ready value) ready,
    required TResult Function(_Measuring value) measuring,
    required TResult Function(_Finish value) finish,
  }) {
    return measuring(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_Ready value)? ready,
    TResult? Function(_Measuring value)? measuring,
    TResult? Function(_Finish value)? finish,
  }) {
    return measuring?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_Ready value)? ready,
    TResult Function(_Measuring value)? measuring,
    TResult Function(_Finish value)? finish,
    required TResult orElse(),
  }) {
    if (measuring != null) {
      return measuring(this);
    }
    return orElse();
  }
}

abstract class _Measuring extends AlignProcessState {
  const factory _Measuring(final MeasurementType detail) = _$MeasuringImpl;
  const _Measuring._() : super._();

  MeasurementType get detail;
  @JsonKey(ignore: true)
  _$$MeasuringImplCopyWith<_$MeasuringImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$FinishImplCopyWith<$Res> {
  factory _$$FinishImplCopyWith(
          _$FinishImpl value, $Res Function(_$FinishImpl) then) =
      __$$FinishImplCopyWithImpl<$Res>;
}

/// @nodoc
class __$$FinishImplCopyWithImpl<$Res>
    extends _$AlignProcessStateCopyWithImpl<$Res, _$FinishImpl>
    implements _$$FinishImplCopyWith<$Res> {
  __$$FinishImplCopyWithImpl(
      _$FinishImpl _value, $Res Function(_$FinishImpl) _then)
      : super(_value, _then);
}

/// @nodoc

class _$FinishImpl extends _Finish {
  const _$FinishImpl() : super._();

  @override
  String toString() {
    return 'AlignProcessState.finish()';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType && other is _$FinishImpl);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() ready,
    required TResult Function(MeasurementType detail) measuring,
    required TResult Function() finish,
  }) {
    return finish();
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? ready,
    TResult? Function(MeasurementType detail)? measuring,
    TResult? Function()? finish,
  }) {
    return finish?.call();
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? ready,
    TResult Function(MeasurementType detail)? measuring,
    TResult Function()? finish,
    required TResult orElse(),
  }) {
    if (finish != null) {
      return finish();
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(_Ready value) ready,
    required TResult Function(_Measuring value) measuring,
    required TResult Function(_Finish value) finish,
  }) {
    return finish(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_Ready value)? ready,
    TResult? Function(_Measuring value)? measuring,
    TResult? Function(_Finish value)? finish,
  }) {
    return finish?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_Ready value)? ready,
    TResult Function(_Measuring value)? measuring,
    TResult Function(_Finish value)? finish,
    required TResult orElse(),
  }) {
    if (finish != null) {
      return finish(this);
    }
    return orElse();
  }
}

abstract class _Finish extends AlignProcessState {
  const factory _Finish() = _$FinishImpl;
  const _Finish._() : super._();
}
