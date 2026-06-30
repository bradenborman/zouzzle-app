// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'player.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Player _$PlayerFromJson(Map<String, dynamic> json) => Player(
  fullName: json['fullName'] as String,
  sport: _sportFromJson(json['sport'] as String),
  position: json['position'] as String,
  jerseyNumber: (json['jerseyNumber'] as num).toInt(),
  height: (json['height'] as num?)?.toInt() ?? 76,
  startYear: (json['startYear'] as num).toInt(),
  endYear: (json['endYear'] as num).toInt(),
  wentPro: json['wentPro'] as bool,
  statisticalTier: _tierFromJson(json['statisticalTier'] as String),
  points: (json['points'] as num?)?.toDouble() ?? 0.0,
  rebounds: (json['rebounds'] as num?)?.toDouble() ?? 0.0,
  assists: (json['assists'] as num?)?.toDouble() ?? 0.0,
  steals: (json['steals'] as num?)?.toDouble() ?? 0.0,
);

Map<String, dynamic> _$PlayerToJson(Player instance) => <String, dynamic>{
  'fullName': instance.fullName,
  'sport': _sportToJson(instance.sport),
  'position': instance.position,
  'jerseyNumber': instance.jerseyNumber,
  'height': instance.height,
  'startYear': instance.startYear,
  'endYear': instance.endYear,
  'wentPro': instance.wentPro,
  'statisticalTier': _tierToJson(instance.statisticalTier),
  'points': instance.points,
  'rebounds': instance.rebounds,
  'assists': instance.assists,
  'steals': instance.steals,
};
