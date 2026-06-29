// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'game_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$GameState {

 Sport get sport; List<FeedbackRow> get guesses; int get remainingGuesses; GameStatus get status; Player? get mysteryPlayer; String? get validationMessage;
/// Create a copy of GameState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$GameStateCopyWith<GameState> get copyWith => _$GameStateCopyWithImpl<GameState>(this as GameState, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is GameState&&(identical(other.sport, sport) || other.sport == sport)&&const DeepCollectionEquality().equals(other.guesses, guesses)&&(identical(other.remainingGuesses, remainingGuesses) || other.remainingGuesses == remainingGuesses)&&(identical(other.status, status) || other.status == status)&&(identical(other.mysteryPlayer, mysteryPlayer) || other.mysteryPlayer == mysteryPlayer)&&(identical(other.validationMessage, validationMessage) || other.validationMessage == validationMessage));
}


@override
int get hashCode => Object.hash(runtimeType,sport,const DeepCollectionEquality().hash(guesses),remainingGuesses,status,mysteryPlayer,validationMessage);

@override
String toString() {
  return 'GameState(sport: $sport, guesses: $guesses, remainingGuesses: $remainingGuesses, status: $status, mysteryPlayer: $mysteryPlayer, validationMessage: $validationMessage)';
}


}

/// @nodoc
abstract mixin class $GameStateCopyWith<$Res>  {
  factory $GameStateCopyWith(GameState value, $Res Function(GameState) _then) = _$GameStateCopyWithImpl;
@useResult
$Res call({
 Sport sport, List<FeedbackRow> guesses, int remainingGuesses, GameStatus status, Player? mysteryPlayer, String? validationMessage
});




}
/// @nodoc
class _$GameStateCopyWithImpl<$Res>
    implements $GameStateCopyWith<$Res> {
  _$GameStateCopyWithImpl(this._self, this._then);

  final GameState _self;
  final $Res Function(GameState) _then;

/// Create a copy of GameState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? sport = null,Object? guesses = null,Object? remainingGuesses = null,Object? status = null,Object? mysteryPlayer = freezed,Object? validationMessage = freezed,}) {
  return _then(_self.copyWith(
sport: null == sport ? _self.sport : sport // ignore: cast_nullable_to_non_nullable
as Sport,guesses: null == guesses ? _self.guesses : guesses // ignore: cast_nullable_to_non_nullable
as List<FeedbackRow>,remainingGuesses: null == remainingGuesses ? _self.remainingGuesses : remainingGuesses // ignore: cast_nullable_to_non_nullable
as int,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as GameStatus,mysteryPlayer: freezed == mysteryPlayer ? _self.mysteryPlayer : mysteryPlayer // ignore: cast_nullable_to_non_nullable
as Player?,validationMessage: freezed == validationMessage ? _self.validationMessage : validationMessage // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [GameState].
extension GameStatePatterns on GameState {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _GameState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _GameState() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _GameState value)  $default,){
final _that = this;
switch (_that) {
case _GameState():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _GameState value)?  $default,){
final _that = this;
switch (_that) {
case _GameState() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( Sport sport,  List<FeedbackRow> guesses,  int remainingGuesses,  GameStatus status,  Player? mysteryPlayer,  String? validationMessage)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _GameState() when $default != null:
return $default(_that.sport,_that.guesses,_that.remainingGuesses,_that.status,_that.mysteryPlayer,_that.validationMessage);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( Sport sport,  List<FeedbackRow> guesses,  int remainingGuesses,  GameStatus status,  Player? mysteryPlayer,  String? validationMessage)  $default,) {final _that = this;
switch (_that) {
case _GameState():
return $default(_that.sport,_that.guesses,_that.remainingGuesses,_that.status,_that.mysteryPlayer,_that.validationMessage);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( Sport sport,  List<FeedbackRow> guesses,  int remainingGuesses,  GameStatus status,  Player? mysteryPlayer,  String? validationMessage)?  $default,) {final _that = this;
switch (_that) {
case _GameState() when $default != null:
return $default(_that.sport,_that.guesses,_that.remainingGuesses,_that.status,_that.mysteryPlayer,_that.validationMessage);case _:
  return null;

}
}

}

/// @nodoc


class _GameState implements GameState {
  const _GameState({required this.sport, required final  List<FeedbackRow> guesses, this.remainingGuesses = 6, required this.status, required this.mysteryPlayer, this.validationMessage}): _guesses = guesses;
  

@override final  Sport sport;
 final  List<FeedbackRow> _guesses;
@override List<FeedbackRow> get guesses {
  if (_guesses is EqualUnmodifiableListView) return _guesses;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_guesses);
}

@override@JsonKey() final  int remainingGuesses;
@override final  GameStatus status;
@override final  Player? mysteryPlayer;
@override final  String? validationMessage;

/// Create a copy of GameState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$GameStateCopyWith<_GameState> get copyWith => __$GameStateCopyWithImpl<_GameState>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _GameState&&(identical(other.sport, sport) || other.sport == sport)&&const DeepCollectionEquality().equals(other._guesses, _guesses)&&(identical(other.remainingGuesses, remainingGuesses) || other.remainingGuesses == remainingGuesses)&&(identical(other.status, status) || other.status == status)&&(identical(other.mysteryPlayer, mysteryPlayer) || other.mysteryPlayer == mysteryPlayer)&&(identical(other.validationMessage, validationMessage) || other.validationMessage == validationMessage));
}


@override
int get hashCode => Object.hash(runtimeType,sport,const DeepCollectionEquality().hash(_guesses),remainingGuesses,status,mysteryPlayer,validationMessage);

@override
String toString() {
  return 'GameState(sport: $sport, guesses: $guesses, remainingGuesses: $remainingGuesses, status: $status, mysteryPlayer: $mysteryPlayer, validationMessage: $validationMessage)';
}


}

/// @nodoc
abstract mixin class _$GameStateCopyWith<$Res> implements $GameStateCopyWith<$Res> {
  factory _$GameStateCopyWith(_GameState value, $Res Function(_GameState) _then) = __$GameStateCopyWithImpl;
@override @useResult
$Res call({
 Sport sport, List<FeedbackRow> guesses, int remainingGuesses, GameStatus status, Player? mysteryPlayer, String? validationMessage
});




}
/// @nodoc
class __$GameStateCopyWithImpl<$Res>
    implements _$GameStateCopyWith<$Res> {
  __$GameStateCopyWithImpl(this._self, this._then);

  final _GameState _self;
  final $Res Function(_GameState) _then;

/// Create a copy of GameState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? sport = null,Object? guesses = null,Object? remainingGuesses = null,Object? status = null,Object? mysteryPlayer = freezed,Object? validationMessage = freezed,}) {
  return _then(_GameState(
sport: null == sport ? _self.sport : sport // ignore: cast_nullable_to_non_nullable
as Sport,guesses: null == guesses ? _self._guesses : guesses // ignore: cast_nullable_to_non_nullable
as List<FeedbackRow>,remainingGuesses: null == remainingGuesses ? _self.remainingGuesses : remainingGuesses // ignore: cast_nullable_to_non_nullable
as int,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as GameStatus,mysteryPlayer: freezed == mysteryPlayer ? _self.mysteryPlayer : mysteryPlayer // ignore: cast_nullable_to_non_nullable
as Player?,validationMessage: freezed == validationMessage ? _self.validationMessage : validationMessage // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
