import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/completion_repository.dart';

final completionRepositoryProvider = Provider<CompletionRepository>(
  (ref) => CompletionRepository(),
);
