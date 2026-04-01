import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:calories_app/features/exercise/data/exercise_repository.dart';

final exerciseRepositoryProvider = Provider<ExerciseRepository>((ref) {
  return ExerciseRepository();
});

class ExerciseSearchNotifier extends Notifier<String> {
  @override
  String build() => '';

  void setQuery(String value) {
    state = value;
  }

  void clear() {
    state = '';
  }
}

final exerciseSearchProvider =
    NotifierProvider<ExerciseSearchNotifier, String>(
  ExerciseSearchNotifier.new,
);

