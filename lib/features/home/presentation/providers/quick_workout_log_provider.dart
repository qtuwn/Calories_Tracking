import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:calories_app/features/home/domain/workout_type.dart';
import 'package:calories_app/domain/diary/diary_entry.dart';
import 'package:calories_app/shared/state/diary_providers.dart'
    as diary_providers;
import 'package:calories_app/features/home/presentation/providers/diary_provider.dart';
import 'package:calories_app/shared/state/auth_providers.dart';
import 'package:calories_app/data/firebase/date_utils.dart';

/// Handles quick workout logging from the Home screen.
///
/// This notifier creates a manual `exercise` diary entry so the workout
/// contributes to calories burned and report statistics.
class QuickWorkoutLogNotifier extends Notifier<void> {
  @override
  void build() {
    // Stateless notifier: acts like an action/service.
  }

  /// Logs a quick workout entry for the currently selected diary date.
  ///
  /// If [caloriesBurned] is not provided, calories are estimated using MET
  /// from [WorkoutType] and user's weight (or a default fallback).
  Future<void> logQuickWorkout({
    required WorkoutType workoutType,
    required double durationMinutes,
    double? caloriesBurned,
    String? note,
  }) async {
    // Require authenticated user because entries are saved under user scope.
    final authState = ref.read(authStateProvider);
    final uid = authState.when(
      data: (user) => user?.uid,
      loading: () => null,
      error: (_, __) => null,
    );

    if (uid == null) {
      throw Exception('Bạn cần đăng nhập để ghi nhật ký tập luyện');
    }

    try {
      debugPrint(
        '[QuickWorkoutLogNotifier] 🔵 Logging quick workout: ${workoutType.displayName}, duration=$durationMinutes min',
      );

      final profileAsync = ref.read(currentUserProfileProvider);
      final profile = profileAsync.when(
        data: (data) => data,
        loading: () => null,
        error: (_, __) => null,
      );

      // Use provided calories when available, otherwise estimate from MET.
      final calories =
          caloriesBurned ??
          _calculateCalories(
            workoutType: workoutType,
            durationMinutes: durationMinutes,
            weightKg: profile?.weightKg,
          );

      debugPrint(
        '[QuickWorkoutLogNotifier] 📊 Calculated calories: $calories kcal (weight=${profile?.weightKg ?? "unknown"} kg)',
      );

      // Save to the date user is currently viewing in diary.
      final diaryNotifier = ref.read(diaryProvider.notifier);
      final selectedDate = diaryNotifier.selectedDate;

      final entry = DiaryEntry.exercise(
        id: '',
        userId: uid,
        date: DateUtils.normalizeToIsoString(selectedDate),
        // Synthetic ID marks this as quick-log (not from exercise catalog).
        exerciseId: 'quick_${workoutType.value}',
        // If note is provided, use it as display name for better context.
        exerciseName: note ?? workoutType.displayName,
        durationMinutes: durationMinutes,
        caloriesBurned: calories,
        exerciseUnit: 'time',
        exerciseValue: durationMinutes,
        exerciseLevelName: null,
        createdAt: DateTime.now(),
      );

      // Persist through diary service (which handles cache/invalidation logic).
      final service = ref.read(diary_providers.diaryServiceProvider);
      await service.addEntry(entry);

      debugPrint(
        '[QuickWorkoutLogNotifier] ✅ Quick workout logged successfully',
      );
    } catch (e, stackTrace) {
      debugPrint(
        '[QuickWorkoutLogNotifier] 🔥 Error logging quick workout: $e',
      );
      debugPrint('[QuickWorkoutLogNotifier] Stack trace: $stackTrace');
      rethrow;
    }
  }

  /// Estimates calories burned for a workout session.
  ///
  /// Falls back to 70kg when profile weight is unavailable so the feature
  /// still works for incomplete profiles.
  double _calculateCalories({
    required WorkoutType workoutType,
    required double durationMinutes,
    double? weightKg,
  }) {
    final weight = weightKg ?? 70.0;

    if (weight <= 0 || durationMinutes <= 0) {
      return 0.0;
    }

    return workoutType.calculateCalories(
      weightKg: weight,
      durationMinutes: durationMinutes,
    );
  }
}

final quickWorkoutLogProvider = NotifierProvider<QuickWorkoutLogNotifier, void>(
  QuickWorkoutLogNotifier.new,
);
