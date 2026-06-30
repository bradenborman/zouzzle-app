import 'package:json_annotation/json_annotation.dart';

import 'enums.dart';

part 'player.g.dart';

@JsonSerializable()
class Player {
  final String fullName;

  @JsonKey(toJson: _sportToJson, fromJson: _sportFromJson)
  final Sport sport;

  final String position;
  final int jerseyNumber;
  final int height; // height in inches (e.g., 76 = 6'4")
  final int startYear;
  final int endYear;
  final bool wentPro;

  @JsonKey(toJson: _tierToJson, fromJson: _tierFromJson)
  final StatisticalTier statisticalTier;

  // Career stats (per-game averages at Missouri)
  final double points;
  final double rebounds;
  final double assists;
  final double steals;

  const Player({
    required this.fullName,
    required this.sport,
    required this.position,
    required this.jerseyNumber,
    this.height = 76,
    required this.startYear,
    required this.endYear,
    required this.wentPro,
    required this.statisticalTier,
    this.points = 0.0,
    this.rebounds = 0.0,
    this.assists = 0.0,
    this.steals = 0.0,
  });

  factory Player.fromJson(Map<String, dynamic> json) => _$PlayerFromJson(json);

  Map<String, dynamic> toJson() => _$PlayerToJson(this);
}

// Top-level helpers required by @JsonKey references.
String _sportToJson(Sport sport) => sport.toJson();
Sport _sportFromJson(String json) => Sport.fromJson(json);

String _tierToJson(StatisticalTier tier) => tier.toJson();
StatisticalTier _tierFromJson(String json) => StatisticalTier.fromJson(json);
