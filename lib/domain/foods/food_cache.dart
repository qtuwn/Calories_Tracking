/// ===============================
/// DACK-30: Xử lý CRUD thực phẩm với database
/// File này định nghĩa interface cache cho thực phẩm (Food)
/// ===============================
import 'food.dart';

/// Abstract interface for local food caching.
/// 
/// This interface defines the contract for storing and retrieving
/// food items from a local cache, independent of the storage mechanism.
/// No Flutter or Firebase imports are allowed in this domain layer file.
abstract class FoodCache {
  /// Loads all cached foods.
  /// Returns empty list if no foods are found in the cache.
  Future<List<Food>> loadAll();

  /// Saves the given foods to the local cache.
  Future<void> saveAll(List<Food> foods);

  /// Clears all cached foods.
  Future<void> clear();
}

