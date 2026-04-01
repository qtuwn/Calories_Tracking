import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:calories_app/domain/diary/diary_entry.dart';
import 'package:calories_app/shared/state/diary_providers.dart' as diary_providers;
import 'package:calories_app/data/firebase/weight_repository.dart';
import 'package:calories_app/core/health/health_providers.dart';
import 'package:calories_app/features/home/domain/statistics_models.dart';
import 'package:calories_app/shared/state/auth_providers.dart';
import 'package:calories_app/data/firebase/date_utils.dart';


final weightRepositoryProvider = Provider<WeightRepository>((ref) {
  return WeightRepository();
});

final currentUserIdProvider = Provider<String?>((ref) {
  return ref.watch(authStateProvider).whenOrNull(
        data: (user) => user?.uid,
      );
});


final todayNutritionStatsProvider = FutureProvider<NutritionStats>((ref) async {
  final uid = ref.watch(currentUserIdProvider);
  if (uid == null) {
    throw Exception('User not logged in');
  }

  try {
    final now = DateTime.now();
    final today = DateUtils.normalizeToMidnight(now);
    
    final repository = ref.read(diary_providers.diaryRepositoryProvider);
    final entries = await repository.fetchEntriesForDateRange(
      uid,
      today,
      today, 
    );

    final foodEntries = entries.where((e) => e.type == DiaryEntryType.food).toList();

    double totalCalories = 0.0;
    double totalProtein = 0.0;
    double totalCarbs = 0.0;
    double totalFat = 0.0;

    for (final entry in foodEntries) {
      totalCalories += entry.calories;
      totalProtein += entry.protein ?? 0.0;
      totalCarbs += entry.carbs ?? 0.0;
      totalFat += entry.fat ?? 0.0;
    }

    final profileAsync = ref.read(currentUserProfileProvider);
    final targetCalories = profileAsync.maybeWhen(
      data: (profile) => profile?.targetKcal,
      orElse: () => null,
    );

    return NutritionStats(
      totalCalories: totalCalories,
      totalProtein: totalProtein,
      totalCarbs: totalCarbs,
      totalFat: totalFat,
      entryCount: foodEntries.length,
      targetCalories: targetCalories,
    );
  } catch (e) {
    throw Exception('Không thể tải dữ liệu dinh dưỡng hôm nay: ${e.toString()}');
  }
});

final weekNutritionStatsProvider = FutureProvider<NutritionStats>((ref) async {
  final uid = ref.watch(currentUserIdProvider);
  if (uid == null) {
    throw Exception('User not logged in');
  }

  final now = DateTime.now();
  final startDate = now.subtract(const Duration(days: 6)); 
  final normalizedStart = DateUtils.normalizeToMidnight(startDate);
  
  final repository = ref.read(diary_providers.diaryRepositoryProvider);
  final entries = await repository.fetchEntriesForDateRange(
    uid,
    normalizedStart,
    now,
  );

  final foodEntries = entries.where((e) => e.type == DiaryEntryType.food).toList();

  double totalCalories = 0.0;
  double totalProtein = 0.0;
  double totalCarbs = 0.0;
  double totalFat = 0.0;

  for (final entry in foodEntries) {
    totalCalories += entry.calories;
    totalProtein += entry.protein ?? 0.0;
    totalCarbs += entry.carbs ?? 0.0;
    totalFat += entry.fat ?? 0.0;
  }

  final profileAsync = ref.read(currentUserProfileProvider);
  final dailyTarget = profileAsync.maybeWhen(
    data: (profile) => profile?.targetKcal,
    orElse: () => null,
  );
  final targetCalories = dailyTarget != null ? dailyTarget * 7 : null;

  return NutritionStats(
    totalCalories: totalCalories,
    totalProtein: totalProtein,
    totalCarbs: totalCarbs,
    totalFat: totalFat,
    entryCount: foodEntries.length,
    targetCalories: targetCalories,
  );
});

final monthNutritionStatsProvider = FutureProvider<NutritionStats>((ref) async {
  final uid = ref.watch(currentUserIdProvider);
  if (uid == null) {
    throw Exception('User not logged in');
  }

  final now = DateTime.now();
  final startDate = DateTime(now.year, now.month, 1); 
  final normalizedStart = DateUtils.normalizeToMidnight(startDate);
  
  final repository = ref.read(diary_providers.diaryRepositoryProvider);
  final entries = await repository.fetchEntriesForDateRange(
    uid,
    normalizedStart,
    now,
  );

  final foodEntries = entries.where((e) => e.type == DiaryEntryType.food).toList();

  double totalCalories = 0.0;
  double totalProtein = 0.0;
  double totalCarbs = 0.0;
  double totalFat = 0.0;

  for (final entry in foodEntries) {
    totalCalories += entry.calories;
    totalProtein += entry.protein ?? 0.0;
    totalCarbs += entry.carbs ?? 0.0;
    totalFat += entry.fat ?? 0.0;
  }

  final profileAsync = ref.read(currentUserProfileProvider);
  final dailyTarget = profileAsync.maybeWhen(
    data: (profile) => profile?.targetKcal,
    orElse: () => null,
  );
  final daysInMonth = DateTime(now.year, now.month + 1, 0).day;
  final targetCalories = dailyTarget != null ? dailyTarget * daysInMonth : null;

  return NutritionStats(
    totalCalories: totalCalories,
    totalProtein: totalProtein,
    totalCarbs: totalCarbs,
    totalFat: totalFat,
    entryCount: foodEntries.length,
    targetCalories: targetCalories,
  );
});


final todayWorkoutStatsProvider = FutureProvider<WorkoutStats>((ref) async {
  final uid = ref.watch(currentUserIdProvider);
  if (uid == null) {
    throw Exception('User not logged in');
  }

  try {
    final now = DateTime.now();
    final today = DateUtils.normalizeToMidnight(now);
    
    final repository = ref.read(diary_providers.diaryRepositoryProvider);
    final entries = await repository.fetchEntriesForDateRange(
      uid,
      today,
      today, 
    );

    final exerciseEntries = entries.where((e) => e.type == DiaryEntryType.exercise).toList();

    double totalCaloriesBurned = 0.0;
    double totalDurationMinutes = 0.0;
    final exerciseNames = <String>{};

    for (final entry in exerciseEntries) {
      totalCaloriesBurned += entry.calories;
      totalDurationMinutes += entry.durationMinutes ?? 0.0;
      if (entry.exerciseName != null) {
        exerciseNames.add(entry.exerciseName!);
      }
    }

    return WorkoutStats(
      totalCaloriesBurned: totalCaloriesBurned,
      totalDurationMinutes: totalDurationMinutes,
      workoutCount: exerciseEntries.length,
      exerciseNames: exerciseNames.toList()..sort(),
    );
  } catch (e) {
    throw Exception('Không thể tải dữ liệu tập luyện hôm nay: ${e.toString()}');
  }
});

final weekWorkoutStatsProvider = FutureProvider<WorkoutStats>((ref) async {
  final uid = ref.watch(currentUserIdProvider);
  if (uid == null) {
    throw Exception('User not logged in');
  }

  final now = DateTime.now();
  final startDate = now.subtract(const Duration(days: 6));
  final normalizedStart = DateUtils.normalizeToMidnight(startDate);
  
  final repository = ref.read(diary_providers.diaryRepositoryProvider);
  final entries = await repository.fetchEntriesForDateRange(
    uid,
    normalizedStart,
    now,
  );

  final exerciseEntries = entries.where((e) => e.type == DiaryEntryType.exercise).toList();

  double totalCaloriesBurned = 0.0;
  double totalDurationMinutes = 0.0;
  final exerciseNames = <String>{};

  for (final entry in exerciseEntries) {
    totalCaloriesBurned += entry.calories;
    totalDurationMinutes += entry.durationMinutes ?? 0.0;
    if (entry.exerciseName != null) {
      exerciseNames.add(entry.exerciseName!);
    }
  }

  return WorkoutStats(
    totalCaloriesBurned: totalCaloriesBurned,
    totalDurationMinutes: totalDurationMinutes,
    workoutCount: exerciseEntries.length,
    exerciseNames: exerciseNames.toList()..sort(),
  );
});

final monthWorkoutStatsProvider = FutureProvider<WorkoutStats>((ref) async {
  final uid = ref.watch(currentUserIdProvider);
  if (uid == null) {
    throw Exception('User not logged in');
  }

  final now = DateTime.now();
  final startDate = DateTime(now.year, now.month, 1);
  final normalizedStart = DateUtils.normalizeToMidnight(startDate);
  
  final repository = ref.read(diary_providers.diaryRepositoryProvider);
  final entries = await repository.fetchEntriesForDateRange(
    uid,
    normalizedStart,
    now,
  );

  final exerciseEntries = entries.where((e) => e.type == DiaryEntryType.exercise).toList();

  double totalCaloriesBurned = 0.0;
  double totalDurationMinutes = 0.0;
  final exerciseNames = <String>{};

  for (final entry in exerciseEntries) {
    totalCaloriesBurned += entry.calories;
    totalDurationMinutes += entry.durationMinutes ?? 0.0;
    if (entry.exerciseName != null) {
      exerciseNames.add(entry.exerciseName!);
    }
  }

  return WorkoutStats(
    totalCaloriesBurned: totalCaloriesBurned,
    totalDurationMinutes: totalDurationMinutes,
    workoutCount: exerciseEntries.length,
    exerciseNames: exerciseNames.toList()..sort(),
  );
});


final todayStepsStatsProvider = FutureProvider<StepsStats>((ref) async {
  final healthRepo = ref.read(healthRepositoryProvider);
  
  try {
    final steps = await healthRepo.getTodaySteps();
    
    const targetSteps = null; 
    
    return StepsStats(
      totalSteps: steps,
      targetSteps: targetSteps,
    );
  } catch (e) {
    return StepsStats(totalSteps: 0, targetSteps: null);
  }
});

final weekStepsStatsProvider = FutureProvider<StepsStats>((ref) async {
  final healthRepo = ref.read(healthRepositoryProvider);
  
  try {
    final now = DateTime.now();
    final startOfWeek = now.subtract(const Duration(days: 6));
    final normalizedStart = DateTime(startOfWeek.year, startOfWeek.month, startOfWeek.day);
    
    final totalSteps = await healthRepo.getStepsForDateRange(
      startDate: normalizedStart,
      endDate: now,
    );
    
    const targetSteps = null;
    
    return StepsStats(
      totalSteps: totalSteps,
      targetSteps: targetSteps,
    );
  } catch (e) {
    if (kDebugMode) {
      debugPrint('[WeekStepsStats] Error: $e');
    }
    return StepsStats(totalSteps: 0, targetSteps: null);
  }
});

final monthStepsStatsProvider = FutureProvider<StepsStats>((ref) async {
  final healthRepo = ref.read(healthRepositoryProvider);
  
  try {
    final now = DateTime.now();
    final startOfMonth = DateTime(now.year, now.month, 1);
    
    final totalSteps = await healthRepo.getStepsForDateRange(
      startDate: startOfMonth,
      endDate: now,
    );
    
    const targetSteps = null;
    
    return StepsStats(
      totalSteps: totalSteps,
      targetSteps: targetSteps,
    );
  } catch (e) {
    if (kDebugMode) {
      debugPrint('[MonthStepsStats] Error: $e');
    }
    return StepsStats(totalSteps: 0, targetSteps: null);
  }
});

final weekDailyStepsProvider = FutureProvider<Map<DateTime, int>>((ref) async {
  final healthRepo = ref.read(healthRepositoryProvider);
  
  try {
    final now = DateTime.now();
    final weekday = now.weekday; 
    final startOfWeek = now.subtract(Duration(days: weekday - 1));
    final normalizedStart = DateTime(startOfWeek.year, startOfWeek.month, startOfWeek.day);
    
    return await healthRepo.getDailySteps(
      startDate: normalizedStart,
      endDate: now,
    );
  } catch (e) {
    if (kDebugMode) {
      debugPrint('[WeekDailySteps] Error: $e');
    }
    return {};
  }
});

final monthDailyStepsProvider = FutureProvider<Map<DateTime, int>>((ref) async {
  final healthRepo = ref.read(healthRepositoryProvider);
  
  try {
    final now = DateTime.now();
    final startOfMonth = DateTime(now.year, now.month, 1);
    
    return await healthRepo.getDailySteps(
      startDate: startOfMonth,
      endDate: now,
    );
  } catch (e) {
    if (kDebugMode) {
      debugPrint('[MonthDailySteps] Error: $e');
    }
    return {};
  }
});


final todayWeightStatsProvider = FutureProvider<WeightStats>((ref) async {
  final uid = ref.watch(currentUserIdProvider);
  if (uid == null) {
    throw Exception('User not logged in');
  }

  try {
    final repository = ref.read(weightRepositoryProvider);
    final now = DateTime.now();
    final today = DateUtils.normalizeToMidnight(now);
    final yesterday = today.subtract(const Duration(days: 1));
    
    final todayWeights = await repository.getWeightHistory(
      uid: uid,
      startDate: today,
      endDate: today,
    );
    
    final yesterdayWeights = await repository.getWeightHistory(
      uid: uid,
      startDate: yesterday,
      endDate: yesterday,
    );
    
    final recentWeightsStream = repository.watchRecentWeights(uid: uid, days: 7);
    final recentWeights = await recentWeightsStream.first;
    
    final todayWeight = todayWeights.isNotEmpty ? todayWeights.last.weightKg : null;
    final yesterdayWeight = yesterdayWeights.isNotEmpty ? yesterdayWeights.last.weightKg : null;
    
    final latestWeight = todayWeight ?? (recentWeights.isNotEmpty ? recentWeights.last.weightKg : null);
    
    final weightHistory = recentWeights
        .map((entry) => WeightPoint(
              date: entry.date,
              weight: entry.weightKg,
            ))
        .toList();

    final profileAsync = ref.read(currentUserProfileProvider);
    final targetWeight = profileAsync.maybeWhen(
      data: (profile) => profile?.targetWeight,
      orElse: () => null,
    );

    return WeightStats(
      latestWeight: latestWeight,
      earliestWeight: recentWeights.isNotEmpty ? recentWeights.first.weightKg : null,
      weightChange: todayWeight != null && yesterdayWeight != null
          ? todayWeight - yesterdayWeight
          : null,
      entryCount: todayWeights.length,
      weightHistory: weightHistory,
      targetWeight: targetWeight,
      previousPeriodWeight: yesterdayWeight,
    );
  } catch (e) {
    throw Exception('Không thể tải dữ liệu cân nặng hôm nay: ${e.toString()}');
  }
});

final weekWeightStatsProvider = FutureProvider<WeightStats>((ref) async {
  final uid = ref.watch(currentUserIdProvider);
  if (uid == null) {
    throw Exception('User not logged in');
  }

  try {
    final repository = ref.read(weightRepositoryProvider);
    final now = DateTime.now();
    
    final weekday = now.weekday;
    final startOfWeek = DateUtils.normalizeToMidnight(now.subtract(Duration(days: weekday - 1)));
    
    final lastWeekEnd = startOfWeek.subtract(const Duration(days: 1));
    final lastWeekStart = lastWeekEnd.subtract(const Duration(days: 6));
    
    final weekWeights = await repository.getWeightHistory(
      uid: uid,
      startDate: startOfWeek,
      endDate: now,
    );
    
    final lastWeekWeights = await repository.getWeightHistory(
      uid: uid,
      startDate: lastWeekStart,
      endDate: lastWeekEnd,
    );
    
    if (weekWeights.isEmpty) {
      return WeightStats(
        entryCount: 0,
        weightHistory: [],
        targetWeight: null,
        previousPeriodWeight: lastWeekWeights.isNotEmpty ? lastWeekWeights.last.weightKg : null,
      );
    }

    final latestWeight = weekWeights.last.weightKg;
    final earliestWeight = weekWeights.first.weightKg;
    final weightChange = latestWeight - earliestWeight;
    final lastWeekEndWeight = lastWeekWeights.isNotEmpty ? lastWeekWeights.last.weightKg : null;

    final weightHistory = weekWeights
        .map((entry) => WeightPoint(
              date: entry.date,
              weight: entry.weightKg,
            ))
        .toList();

    final profileAsync = ref.read(currentUserProfileProvider);
    final targetWeight = profileAsync.maybeWhen(
      data: (profile) => profile?.targetWeight,
      orElse: () => null,
    );

    return WeightStats(
      latestWeight: latestWeight,
      earliestWeight: earliestWeight,
      weightChange: weightChange,
      entryCount: weekWeights.length,
      weightHistory: weightHistory,
      targetWeight: targetWeight,
      previousPeriodWeight: lastWeekEndWeight,
    );
  } catch (e) {
    throw Exception('Không thể tải dữ liệu cân nặng tuần này: ${e.toString()}');
  }
});

final monthWeightStatsProvider = FutureProvider<WeightStats>((ref) async {
  final uid = ref.watch(currentUserIdProvider);
  if (uid == null) {
    throw Exception('User not logged in');
  }

  try {
    final repository = ref.read(weightRepositoryProvider);
    final now = DateTime.now();
    final startOfMonth = DateTime(now.year, now.month, 1);
    final normalizedStart = DateUtils.normalizeToMidnight(startOfMonth);
    
    final lastMonthEnd = normalizedStart.subtract(const Duration(days: 1));
    final lastMonthStart = DateTime(lastMonthEnd.year, lastMonthEnd.month, 1);
    
    final monthWeights = await repository.getWeightHistory(
      uid: uid,
      startDate: normalizedStart,
      endDate: now,
    );
    
    final lastMonthWeights = await repository.getWeightHistory(
      uid: uid,
      startDate: lastMonthStart,
      endDate: lastMonthEnd,
    );
    
    if (monthWeights.isEmpty) {
      return WeightStats(
        entryCount: 0,
        weightHistory: [],
        targetWeight: null,
        previousPeriodWeight: lastMonthWeights.isNotEmpty ? lastMonthWeights.last.weightKg : null,
      );
    }

    final latestWeight = monthWeights.last.weightKg;
    final earliestWeight = monthWeights.first.weightKg;
    final weightChange = latestWeight - earliestWeight;
    final lastMonthEndWeight = lastMonthWeights.isNotEmpty ? lastMonthWeights.last.weightKg : null;

    final weightHistory = monthWeights
        .map((entry) => WeightPoint(
              date: entry.date,
              weight: entry.weightKg,
            ))
        .toList();

    final profileAsync = ref.read(currentUserProfileProvider);
    final targetWeight = profileAsync.maybeWhen(
      data: (profile) => profile?.targetWeight,
      orElse: () => null,
    );

    return WeightStats(
      latestWeight: latestWeight,
      earliestWeight: earliestWeight,
      weightChange: weightChange,
      entryCount: monthWeights.length,
      weightHistory: weightHistory,
      targetWeight: targetWeight,
      previousPeriodWeight: lastMonthEndWeight,
    );
  } catch (e) {
    throw Exception('Không thể tải dữ liệu cân nặng tháng này: ${e.toString()}');
  }
});

