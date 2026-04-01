import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:calories_app/features/home/domain/workout_type.dart';
import 'package:calories_app/domain/diary/diary_entry.dart';
import 'package:calories_app/shared/state/diary_providers.dart'
    as diary_providers;
import 'package:calories_app/features/home/presentation/providers/diary_provider.dart';
import 'package:calories_app/shared/state/auth_providers.dart';
import 'package:calories_app/data/firebase/date_utils.dart';

/// Xu ly ghi nhanh hoat dong tap luyen tren man hinh Home.
///
/// Notifier nay tao mot diary entry loai `exercise` de dong bo vao
/// tong calo dot chay va cac bao cao thong ke.
class QuickWorkoutLogNotifier extends Notifier<void> {
  @override
  void build() {
    // Notifier khong luu state, chi dong vai tro xu ly hanh dong.
  }

  /// Ghi nhanh mot buoi tap theo ngay dang duoc chon trong diary.
  ///
  /// Neu [caloriesBurned] de trong, he thong tu uoc tinh theo MET cua
  /// [WorkoutType] va can nang nguoi dung (co fallback mac dinh).
  Future<void> logQuickWorkout({
    required WorkoutType workoutType,
    required double durationMinutes,
    double? caloriesBurned,
    String? note,
  }) async {
    // Bat buoc dang nhap vi du lieu duoc luu theo user.
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

      // Uu tien calo nguoi dung nhap tay, neu khong se tu tinh.
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

      // Luu vao ngay ma nguoi dung dang xem tren diary.
      final diaryNotifier = ref.read(diaryProvider.notifier);
      final selectedDate = diaryNotifier.selectedDate;

      final entry = DiaryEntry.exercise(
        id: '',
        userId: uid,
        date: DateUtils.normalizeToIsoString(selectedDate),
        // ID tong hop de phan biet quick log voi bai tap tu catalog.
        exerciseId: 'quick_${workoutType.value}',
        // Neu co ghi chu thi dung lam ten hien thi cua buoi tap.
        exerciseName: note ?? workoutType.displayName,
        durationMinutes: durationMinutes,
        caloriesBurned: calories,
        exerciseUnit: 'time',
        exerciseValue: durationMinutes,
        exerciseLevelName: null,
        createdAt: DateTime.now(),
      );

      // Luu qua diary service (co xu ly cache/invalidation noi bo).
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

  /// Uoc tinh calo dot chay cho buoi tap.
  ///
  /// Fallback 70kg neu profile chua co can nang de luong ghi nhanh van hoat dong.
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
