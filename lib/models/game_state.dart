import 'package:freezed_annotation/freezed_annotation.dart';

import 'enums.dart';
import 'feedback_row.dart';
import 'player.dart';

part 'game_state.freezed.dart';

@freezed
abstract class GameState with _$GameState {
  const factory GameState({
    required Sport sport,
    required List<FeedbackRow> guesses,
    @Default(6) int remainingGuesses,
    required GameStatus status,
    required Player? mysteryPlayer,
    String? validationMessage,
  }) = _GameState;
}
