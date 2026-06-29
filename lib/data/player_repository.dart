import 'dart:convert';

import 'package:flutter/services.dart';

import '../models/enums.dart';
import '../models/player.dart';

/// Thrown when the player asset cannot be loaded or the top-level JSON
/// structure is malformed (e.g. missing "players" key, not a JSON object).
/// Individual records with missing/invalid fields are silently skipped rather
/// than causing this exception.
class PlayerRepositoryException implements Exception {
  final String message;
  final Object? cause;

  const PlayerRepositoryException(this.message, {this.cause});

  @override
  String toString() =>
      'PlayerRepositoryException: $message${cause != null ? ' (cause: $cause)' : ''}';
}

class PlayerRepository {
  final List<Player> players;

  PlayerRepository._(this.players);

  /// Loads the player dataset for [sport] from the bundled JSON asset.
  ///
  /// - Reads `assets/data/basketball_players.json` or
  ///   `assets/data/football_players.json` depending on [sport].
  /// - Parses each record individually; records that are missing required
  ///   fields or contain invalid values are silently skipped (Requirement 3.6).
  /// - Throws [PlayerRepositoryException] if the asset cannot be read or the
  ///   top-level JSON structure is unusable (not an object, missing "players"
  ///   key, or "players" is not a list).
  static Future<PlayerRepository> load(Sport sport) async {
    final assetPath = sport == Sport.basketball
        ? 'assets/data/basketball_players.json'
        : 'assets/data/football_players.json';

    final String raw;
    try {
      raw = await rootBundle.loadString(assetPath);
    } catch (e) {
      throw PlayerRepositoryException(
        'Failed to load asset: $assetPath',
        cause: e,
      );
    }

    final Map<String, dynamic> decoded;
    try {
      final parsed = jsonDecode(raw);
      if (parsed is! Map<String, dynamic>) {
        throw PlayerRepositoryException(
          'Expected a JSON object at root of $assetPath',
        );
      }
      decoded = parsed;
    } on PlayerRepositoryException {
      rethrow;
    } catch (e) {
      throw PlayerRepositoryException(
        'Malformed JSON in $assetPath',
        cause: e,
      );
    }

    final rawList = decoded['players'];
    if (rawList == null || rawList is! List) {
      throw PlayerRepositoryException(
        'Missing or invalid "players" array in $assetPath',
      );
    }

    final players = <Player>[];
    for (final entry in rawList) {
      try {
        if (entry is! Map<String, dynamic>) continue;
        players.add(Player.fromJson(entry));
      } catch (_) {
        // Skip records that are missing required fields or have invalid values.
      }
    }

    return PlayerRepository._(players);
  }

  /// Returns the [Player] whose [Player.fullName] matches [fullName] exactly,
  /// or `null` if no such player exists.
  Player? findByName(String fullName) {
    for (final player in players) {
      if (player.fullName == fullName) return player;
    }
    return null;
  }

  /// Returns all player names that contain [substring] (case-insensitive).
  List<String> namesContaining(String substring) {
    final lower = substring.toLowerCase();
    return players
        .where((p) => p.fullName.toLowerCase().contains(lower))
        .map((p) => p.fullName)
        .toList();
  }
}
