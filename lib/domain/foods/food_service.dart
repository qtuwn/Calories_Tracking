/// ===============================
/// DACK-30: Xử lý CRUD thực phẩm với database
/// File này định nghĩa service quản lý thực phẩm, phối hợp cache và repository
/// ===============================
import 'dart:async';
import 'package:flutter/foundation.dart'; // For debugPrint
import 'food.dart';
import 'food_repository.dart';
import 'food_cache.dart';

/// Service for managing foods with a hybrid cache-first, then network strategy.
/// 
/// This service orchestrates between the local cache (FoodCache) and
/// the remote data source (FoodRepository) to provide instant UI feedback
/// and background synchronization.
class FoodService {
  final FoodRepository _repository;
  final FoodCache _cache;

  FoodService(this._repository, this._cache);

  /// Watches all foods, loading from cache first and then syncing with Firestore.
  /// 
  /// Emits the cached foods immediately if available.
  /// Then subscribes to Firestore updates, emitting new foods and saving them to cache.
  Stream<List<Food>> watchAllWithCache() {
    debugPrint('[FoodService] 🔵 Watching all foods with cache');
    final controller = StreamController<List<Food>>();

    // 1. Load from cache first and emit immediately
    _cache.loadAll().then((cachedFoods) {
      if (cachedFoods.isNotEmpty) {
        debugPrint('[FoodService] ✅ Emitting ${cachedFoods.length} cached foods');
        controller.add(cachedFoods);
      } else {
        debugPrint('[FoodService] ℹ️ No cached foods found');
      }
    }).catchError((e, st) {
      debugPrint('[FoodService] 🔥 Error loading from cache: $e');
      debugPrintStack(stackTrace: st);
    });

    // 2. Subscribe to Firestore updates
    final subscription = _repository.watchAll().listen(
      (firestoreFoods) async {
        if (firestoreFoods.isNotEmpty) {
          debugPrint('[FoodService] ✅ Firestore updated: ${firestoreFoods.length} foods');
          controller.add(firestoreFoods);
          // Save to cache for future instant loads
          await _cache.saveAll(firestoreFoods);
        } else {
          debugPrint('[FoodService] ℹ️ Firestore returned empty list');
          controller.add([]);
        }
      },
      onError: (error, stackTrace) {
        debugPrint('[FoodService] 🔥 Firestore stream error: $error');
        debugPrintStack(stackTrace: stackTrace);
        // Do not add error to controller, keep streaming cached data if available
      },
      onDone: () {
        debugPrint('[FoodService] ℹ️ Firestore foods stream done');
        controller.close();
      },
    );

    // Ensure subscription is cancelled when the stream controller is closed
    controller.onCancel = () {
      debugPrint('[FoodService] 🗑️ Cancelling Firestore foods subscription');
      subscription.cancel();
    };

    return controller.stream;
  }

  /// Loads all foods once, prioritizing cache over Firestore.
  /// 
  /// Attempts to load from cache first. If not found, fetches from Firestore.
  /// The fetched foods are then saved to cache.
  Future<List<Food>> loadAllOnce() async {
    debugPrint('[FoodService] 🔵 Loading all foods once (cache-first)');
    try {
      // Try loading from cache
      final cachedFoods = await _cache.loadAll();
      if (cachedFoods.isNotEmpty) {
        debugPrint('[FoodService] ✅ Loaded ${cachedFoods.length} foods from cache');
        return cachedFoods;
      }

      // If not in cache, fetch from Firestore
      debugPrint('[FoodService] ℹ️ No cached foods, fetching from Firestore');
      // Note: watchAll() returns a stream, so we need to get the first value
      final firestoreFoods = await _repository.watchAll().first;
      await _cache.saveAll(firestoreFoods); // Save to cache
      debugPrint('[FoodService] ✅ Loaded ${firestoreFoods.length} foods from Firestore and cached');
      return firestoreFoods;
    } catch (e, st) {
      debugPrint('[FoodService] 🔥 Error loading foods once: $e');
      debugPrintStack(stackTrace: st);
      return [];
    }
  }

  /// Searches foods with cache support.
  /// 
  /// For search, we don't cache results (they're dynamic).
  /// But we can still provide instant feedback by searching cached foods first.
  Stream<List<Food>> searchWithCache(String query) {
    debugPrint('[FoodService] 🔵 Searching foods with cache: query="$query"');
    
    if (query.trim().isEmpty) {
      return Stream.value([]);
    }

    final controller = StreamController<List<Food>>();

    // 1. Search in cache first for instant results
    _cache.loadAll().then((cachedFoods) {
      final queryLower = query.toLowerCase();
      final cachedResults = cachedFoods.where((food) {
        return food.nameLower.contains(queryLower);
      }).toList();
      
      if (cachedResults.isNotEmpty) {
        debugPrint('[FoodService] ✅ Found ${cachedResults.length} cached results');
        controller.add(cachedResults);
      }
    }).catchError((e, st) {
      debugPrint('[FoodService] 🔥 Error searching cache: $e');
      debugPrintStack(stackTrace: st);
    });

    // 2. Subscribe to Firestore search results
    final subscription = _repository.search(query).listen(
      (firestoreResults) {
        debugPrint('[FoodService] ✅ Firestore search returned ${firestoreResults.length} results');
        controller.add(firestoreResults);
      },
      onError: (error, stackTrace) {
        debugPrint('[FoodService] 🔥 Firestore search error: $error');
        debugPrintStack(stackTrace: stackTrace);
      },
      onDone: () {
        debugPrint('[FoodService] ℹ️ Firestore search stream done');
        controller.close();
      },
    );

    controller.onCancel = () {
      debugPrint('[FoodService] 🗑️ Cancelling Firestore search subscription');
      subscription.cancel();
    };

    return controller.stream;
  }

  /// Clears the cached foods.
  Future<void> clearCache() async {
    debugPrint('[FoodService] 🔵 Clearing foods cache');
    try {
      await _cache.clear();
      debugPrint('[FoodService] ✅ Foods cache cleared');
    } catch (e, st) {
      debugPrint('[FoodService] 🔥 Error clearing cache: $e');
      debugPrintStack(stackTrace: st);
    }
  }
}

