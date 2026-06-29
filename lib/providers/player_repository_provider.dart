import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/player_repository.dart';
import '../models/enums.dart';

final playerRepositoryProvider =
    FutureProvider.family<PlayerRepository, Sport>(
  (ref, sport) => PlayerRepository.load(sport),
);
