import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/health/health_providers.dart';
import '../../../core/health/health_repository.dart';
import '../../../core/health/cache/steps_today_cache.dart';
import 'activity_state.dart';

final activityControllerProvider =
    NotifierProvider<ActivityController, ActivityState>(() {
  return ActivityController();
});

class ActivityController extends Notifier<ActivityState> {
  HealthRepository? _repo;
  StepsTodayCache? _cache;
  bool _hasCheckedCache = false;
  bool _scheduledPermissionCheck = false;

  @override
  ActivityState build() {
    _repo = ref.read(healthRepositoryProvider);
    _cache = ref.read(stepsTodayCacheProvider);
    
    if (!_hasCheckedCache) {
      _hasCheckedCache = true;
      final cachedSteps = _cache?.loadCachedSteps();
      if (cachedSteps != null) {
        if (kDebugMode) {
          debugPrint('[ActivityController] ✅ Loaded cached steps: $cachedSteps');
        }
        return ActivityState(connected: true, steps: cachedSteps);
      }
    }
    
    if (!_scheduledPermissionCheck) {
      _scheduledPermissionCheck = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Future.delayed(const Duration(milliseconds: 500), () {
          if (!ref.mounted) return;
          _checkPermissionAndLoad();
        });
      });
    }
    
    return ActivityState.initial();
  }

  Future<void> _checkPermissionAndLoad() async {
    if (_repo == null || _cache == null) return;
    
    try {
      final hasPermission = await _repo!.hasStepsPermission();
      if (hasPermission) {
        if (kDebugMode) {
          debugPrint('[ActivityController] Permission already granted, loading steps');
        }
        final steps = await _repo!.getTodaySteps();
        await _cache!.saveSteps(steps);
        state = state.copyWith(
          connected: true,
          steps: steps,
        );
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('[ActivityController] Error checking permission: $e');
      }
    }
  }

  Future<void> connectAndSync() async {
    if (_repo == null || _cache == null) return;

    try {
      final granted = await _repo!.requestPermission();
      if (!granted) {
        return;
      }

      final steps = await _repo!.getTodaySteps();
      await _cache!.saveSteps(steps);
      state = state.copyWith(
        connected: true,
        steps: steps,
      );
    } catch (e) {
      if (kDebugMode) {
        debugPrint('[ActivityController] Error connecting: $e');
      }
      state = const ActivityState(connected: false, steps: 0);
    }
  }

  Future<void> refreshToday() async {
    if (!state.connected) return;

    await connectAndSync();
  }
}

