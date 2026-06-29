import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/completion_state.dart';
import '../models/enums.dart';

/// Persists and retrieves [CompletionState] records via [SharedPreferences].
///
/// Each record is keyed by sport and date so that one entry exists per
/// (sport, calendar-day) pair:
///   `completion_<sport>_<YYYY-MM-DD>`
class CompletionRepository {
  // ---------------------------------------------------------------------------
  // Key derivation
  // ---------------------------------------------------------------------------

  String _key(Sport sport, DateTime date) {
    final dateStr = date.toIso8601String().substring(0, 10);
    return 'completion_${sport.name}_$dateStr';
  }

  // ---------------------------------------------------------------------------
  // 5.1  Load
  // ---------------------------------------------------------------------------

  /// Returns the [CompletionState] stored for [sport] on [date], or `null` if
  /// no record exists or the stored data is corrupt / unreadable.
  ///
  /// Never throws — any error is swallowed and `null` is returned so the app
  /// treats the puzzle as unplayed (Requirements 8.1, 8.4).
  Future<CompletionState?> loadForDate(Sport sport, DateTime date) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_key(sport, date));
      if (raw == null) return null;
      final json = jsonDecode(raw) as Map<String, dynamic>;
      return CompletionState.fromJson(json);
    } catch (_) {
      // Corrupt or unexpected data — treat as unplayed.
      return null;
    }
  }

  // ---------------------------------------------------------------------------
  // 5.2  Save
  // ---------------------------------------------------------------------------

  /// Serialises [state] to JSON and writes it to [SharedPreferences] under the
  /// derived key for the state's sport and date (Requirement 8.1).
  Future<void> save(CompletionState state) async {
    final prefs = await SharedPreferences.getInstance();
    final sport = Sport.fromJson(state.sport);
    final date = DateTime.parse(state.date);
    final key = _key(sport, date);
    await prefs.setString(key, jsonEncode(state.toJson()));
  }
}
