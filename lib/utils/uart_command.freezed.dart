// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'uart_command.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$UartCommand {
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() start,
    required TResult Function() stop,
    required TResult Function(String vth) vth,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? start,
    TResult? Function()? stop,
    TResult? Function(String vth)? vth,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? start,
    TResult Function()? stop,
    TResult Function(String vth)? vth,
    required TResult orElse(),
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(Start value) start,
    required TResult Function(Stop value) stop,
    required TResult Function(Vth value) vth,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(Start value)? start,
    TResult? Function(Stop value)? stop,
    TResult? Function(Vth value)? vth,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(Start value)? start,
    TResult Function(Stop value)? stop,
    TResult Function(Vth value)? vth,
    required TResult orElse(),
  }) =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $UartCommandCopyWith<$Res> {
  factory $UartCommandCopyWith(
          UartCommand value, $Res Function(UartCommand) then) =
      _$UartCommandCopyWithImpl<$Res, UartCommand>;
}

/// @nodoc
class _$UartCommandCopyWithImpl<$Res, $Val extends UartCommand>
    implements $UartCommandCopyWith<$Res> {
  _$UartCommandCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;
}

/// @nodoc
abstract class _$$StartImplCopyWith<$Res> {
  factory _$$StartImplCopyWith(
          _$StartImpl value, $Res Function(_$StartImpl) then) =
      __$$StartImplCopyWithImpl<$Res>;
}

/// @nodoc
class __$$StartImplCopyWithImpl<$Res>
    extends _$UartCommandCopyWithImpl<$Res, _$StartImpl>
    implements _$$StartImplCopyWith<$Res> {
  __$$StartImplCopyWithImpl(
      _$StartImpl _value, $Res Function(_$StartImpl) _then)
      : super(_value, _then);
}

/// @nodoc

class _$StartImpl extends Start {
  const _$StartImpl() : super._();

  @override
  String toString() {
    return 'UartCommand.start()';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType && other is _$StartImpl);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() start,
    required TResult Function() stop,
    required TResult Function(String vth) vth,
  }) {
    return start();
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? start,
    TResult? Function()? stop,
    TResult? Function(String vth)? vth,
  }) {
    return start?.call();
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? start,
    TResult Function()? stop,
    TResult Function(String vth)? vth,
    required TResult orElse(),
  }) {
    if (start != null) {
      return start();
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(Start value) start,
    required TResult Function(Stop value) stop,
    required TResult Function(Vth value) vth,
  }) {
    return start(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(Start value)? start,
    TResult? Function(Stop value)? stop,
    TResult? Function(Vth value)? vth,
  }) {
    return start?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(Start value)? start,
    TResult Function(Stop value)? stop,
    TResult Function(Vth value)? vth,
    required TResult orElse(),
  }) {
    if (start != null) {
      return start(this);
    }
    return orElse();
  }
}

abstract class Start extends UartCommand {
  const factory Start() = _$StartImpl;
  const Start._() : super._();
}

/// @nodoc
abstract class _$$StopImplCopyWith<$Res> {
  factory _$$StopImplCopyWith(
          _$StopImpl value, $Res Function(_$StopImpl) then) =
      __$$StopImplCopyWithImpl<$Res>;
}

/// @nodoc
class __$$StopImplCopyWithImpl<$Res>
    extends _$UartCommandCopyWithImpl<$Res, _$StopImpl>
    implements _$$StopImplCopyWith<$Res> {
  __$$StopImplCopyWithImpl(_$StopImpl _value, $Res Function(_$StopImpl) _then)
      : super(_value, _then);
}

/// @nodoc

class _$StopImpl extends Stop {
  const _$StopImpl() : super._();

  @override
  String toString() {
    return 'UartCommand.stop()';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType && other is _$StopImpl);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() start,
    required TResult Function() stop,
    required TResult Function(String vth) vth,
  }) {
    return stop();
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? start,
    TResult? Function()? stop,
    TResult? Function(String vth)? vth,
  }) {
    return stop?.call();
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? start,
    TResult Function()? stop,
    TResult Function(String vth)? vth,
    required TResult orElse(),
  }) {
    if (stop != null) {
      return stop();
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(Start value) start,
    required TResult Function(Stop value) stop,
    required TResult Function(Vth value) vth,
  }) {
    return stop(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(Start value)? start,
    TResult? Function(Stop value)? stop,
    TResult? Function(Vth value)? vth,
  }) {
    return stop?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(Start value)? start,
    TResult Function(Stop value)? stop,
    TResult Function(Vth value)? vth,
    required TResult orElse(),
  }) {
    if (stop != null) {
      return stop(this);
    }
    return orElse();
  }
}

abstract class Stop extends UartCommand {
  const factory Stop() = _$StopImpl;
  const Stop._() : super._();
}

/// @nodoc
abstract class _$$VthImplCopyWith<$Res> {
  factory _$$VthImplCopyWith(_$VthImpl value, $Res Function(_$VthImpl) then) =
      __$$VthImplCopyWithImpl<$Res>;
  @useResult
  $Res call({String vth});
}

/// @nodoc
class __$$VthImplCopyWithImpl<$Res>
    extends _$UartCommandCopyWithImpl<$Res, _$VthImpl>
    implements _$$VthImplCopyWith<$Res> {
  __$$VthImplCopyWithImpl(_$VthImpl _value, $Res Function(_$VthImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? vth = null,
  }) {
    return _then(_$VthImpl(
      null == vth
          ? _value.vth
          : vth // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc

class _$VthImpl extends Vth {
  const _$VthImpl(this.vth) : super._();

  @override
  final String vth;

  @override
  String toString() {
    return 'UartCommand.vth(vth: $vth)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$VthImpl &&
            (identical(other.vth, vth) || other.vth == vth));
  }

  @override
  int get hashCode => Object.hash(runtimeType, vth);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$VthImplCopyWith<_$VthImpl> get copyWith =>
      __$$VthImplCopyWithImpl<_$VthImpl>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() start,
    required TResult Function() stop,
    required TResult Function(String vth) vth,
  }) {
    return vth(this.vth);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? start,
    TResult? Function()? stop,
    TResult? Function(String vth)? vth,
  }) {
    return vth?.call(this.vth);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? start,
    TResult Function()? stop,
    TResult Function(String vth)? vth,
    required TResult orElse(),
  }) {
    if (vth != null) {
      return vth(this.vth);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(Start value) start,
    required TResult Function(Stop value) stop,
    required TResult Function(Vth value) vth,
  }) {
    return vth(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(Start value)? start,
    TResult? Function(Stop value)? stop,
    TResult? Function(Vth value)? vth,
  }) {
    return vth?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(Start value)? start,
    TResult Function(Stop value)? stop,
    TResult Function(Vth value)? vth,
    required TResult orElse(),
  }) {
    if (vth != null) {
      return vth(this);
    }
    return orElse();
  }
}

abstract class Vth extends UartCommand {
  const factory Vth(final String vth) = _$VthImpl;
  const Vth._() : super._();

  String get vth;
  @JsonKey(ignore: true)
  _$$VthImplCopyWith<_$VthImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
