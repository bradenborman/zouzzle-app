// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'completion_state.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CompletionState _$CompletionStateFromJson(Map<String, dynamic> json) =>
    CompletionState(
      sport: json['sport'] as String,
      date: json['date'] as String,
      outcome: json['outcome'] as String,
      mysteryPlayerName: json['mysteryPlayerName'] as String,
      guesses: (json['guesses'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
    );

Map<String, dynamic> _$CompletionStateToJson(CompletionState instance) =>
    <String, dynamic>{
      'sport': instance.sport,
      'date': instance.date,
      'outcome': instance.outcome,
      'mysteryPlayerName': instance.mysteryPlayerName,
      'guesses': instance.guesses,
    };
