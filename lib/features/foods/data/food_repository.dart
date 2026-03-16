// Legacy FoodRepository file
// Lưu ý: File này chỉ dùng cho code cũ, đang trong quá trình migration sang domain/foods/food_repository.dart.
// Không nên sử dụng cho code mới.
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:calories_app/features/foods/data/food_model.dart';
import 'package:calories_app/shared/utils/audit_logger.dart';

/// Repository for managing foods in Firestore
/// 
/// @Deprecated Use domain/foods/food_repository.dart and FirestoreFoodRepository instead.
/// This legacy repository is kept for backward compatibility during migration.
/// Migration guide: Use FoodService from lib/shared/state/food_providers.dart
@Deprecated('Use domain/foods/food_repository.dart and FirestoreFoodRepository instead. Migration in progress.')
class FoodRepository {
  // Repository quản lý dữ liệu thực phẩm trên Firestore cho legacy code.
  final FirebaseFirestore _firestore;

  FoodRepository({FirebaseFirestore? instance})
    : _firestore = instance ?? FirebaseFirestore.instance;

  /// Search foods by name (case-insensitive prefix search)
  /// Returns empty stream if query is empty
  Stream<List<Food>> searchFoods(String query) {
    // Tìm kiếm thực phẩm theo tên (không phân biệt hoa thường), trả về stream.
    if (query.trim().isEmpty) {
      return const Stream.empty();
    }

    final queryLower = query.toLowerCase();
    final queryUpper = '$queryLower\uf8ff';

    return _firestore
        .collection('foods')
        .where('nameLower', isGreaterThanOrEqualTo: queryLower)
        .where('nameLower', isLessThan: queryUpper)
        .limit(20)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) => Food.fromDoc(doc)).toList();
        });
  }

  /// Get all foods as a stream
  Stream<List<Food>> getAllFoods() {
    // Lấy toàn bộ thực phẩm, trả về stream.
    return _firestore.collection('foods').orderBy('nameLower').snapshots().map((
      snapshot,
    ) {
      return snapshot.docs.map((doc) => Food.fromDoc(doc)).toList();
    });
  }

  /// Create or update a food document
  /// If food.id is empty, creates a new document
  /// Otherwise updates the existing document
  /// [actorUid] - The UID of the admin performing the action (for audit logging)
  Future<void> createOrUpdateFood(Food food, String actorUid) async {
    // Tạo mới hoặc cập nhật thực phẩm, có log audit cho admin.
    try {
      final foodData = food.toMap();
      // Ensure nameLower is set
      foodData['nameLower'] = food.name.toLowerCase();

      if (food.id.isEmpty) {
        // Create new food
        final docRef = _firestore.collection('foods').doc();
        await docRef.set(foodData);
        debugPrint('[FoodRepository] ✅ Created food: ${docRef.id}');

        // Log the action
        await auditLogger.logAdminAction(
          actorUid,
          'create_food',
          'food:${docRef.id}',
          {'name': food.name, 'category': food.category},
        );
      } else {
        // Update existing food
        await _firestore
            .collection('foods')
            .doc(food.id)
            .set(foodData, SetOptions(merge: true));
        debugPrint('[FoodRepository] ✅ Updated food: ${food.id}');

        // Log the action
        await auditLogger.logAdminAction(
          actorUid,
          'update_food',
          'food:${food.id}',
          {'name': food.name, 'category': food.category},
        );
      }
    } catch (e, stackTrace) {
      debugPrint('[FoodRepository] 🔥 Error creating/updating food: $e');
      debugPrintStack(stackTrace: stackTrace);
      rethrow;
    }
  }

  /// Delete a food document
  /// [actorUid] - The UID of the admin performing the action (for audit logging)
  Future<void> deleteFood(
    String id,
    String actorUid, {
    String? foodName,
  }) async {
    // Xóa thực phẩm theo id, có log audit cho admin.
    try {
      await _firestore.collection('foods').doc(id).delete();
      debugPrint('[FoodRepository] ✅ Deleted food: $id');

      // Log the action
      await auditLogger.logAdminAction(
        actorUid,
        'delete_food',
        'food:$id',
        foodName != null ? {'name': foodName} : null,
      );
    } catch (e, stackTrace) {
      debugPrint('[FoodRepository] 🔥 Error deleting food: $e');
      debugPrintStack(stackTrace: stackTrace);
      rethrow;
    }
  }

  /// Get a single food by ID
  Future<Food?> getFoodById(String id) async {
    // Lấy thực phẩm theo id, trả về Food hoặc null.
    try {
      final doc = await _firestore.collection('foods').doc(id).get();
      if (doc.exists) {
        return Food.fromDoc(doc);
      }
      return null;
    } catch (e, stackTrace) {
      debugPrint('[FoodRepository] 🔥 Error getting food: $e');
      debugPrintStack(stackTrace: stackTrace);
      return null;
    }
  }

    /// Search foods by name and filter by goal type
  /// goalType: "lose_fat" | "muscle_gain" | "vegan" | "maintain"
  Stream<List<Food>> searchFoodsByGoal(String query, String goalType) {
    // Tìm kiếm thực phẩm theo tên và lọc theo mục tiêu (goalType), trả về stream.
    if (query.trim().isEmpty) {
      return const Stream.empty();
    }

    final queryLower = query.toLowerCase();
    final queryUpper = '$queryLower\uf8ff';

    // ĐỪNG khai báo là Stream, để Dart tự suy ra Query<Map<String, dynamic>>
    final baseQuery = _firestore
        .collection('foods')
        .where('nameLower', isGreaterThanOrEqualTo: queryLower)
        .where('nameLower', isLessThan: queryUpper)
        .limit(20);

    return baseQuery.snapshots().map((snapshot) {
      var foods = snapshot.docs.map((doc) => Food.fromDoc(doc)).toList();

      // Filter by goal type
      if (goalType == 'vegan') {
        // Vegan: loại món có thịt / động vật
        foods = foods.where((food) {
          final category = food.category?.toLowerCase() ?? '';

          if (category.contains('meat') ||
              category.contains('chicken') ||
              category.contains('pork') ||
              category.contains('beef') ||
              category.contains('fish') ||
              category.contains('seafood') ||
              category.contains('egg') ||
              category.contains('dairy') ||
              category.contains('milk')) {
            return false;
          }
          return true;
        }).toList();
      }

      return foods;
    });
  }


    /// Get all foods filtered by goal type
  /// Similar to searchFoodsByGoal but without name filtering
  Stream<List<Food>> getAllFoodsByGoal(String goalType) {
    // Lấy toàn bộ thực phẩm, lọc theo mục tiêu (goalType), trả về stream.
    final baseQuery = _firestore
        .collection('foods')
        .orderBy('nameLower')
        .limit(100);

    return baseQuery.snapshots().map((snapshot) {
      var foods = snapshot.docs.map((doc) => Food.fromDoc(doc)).toList();

      if (goalType == 'vegan') {
        foods = foods.where((food) {
          final category = food.category?.toLowerCase() ?? '';

          if (category.contains('meat') ||
              category.contains('chicken') ||
              category.contains('pork') ||
              category.contains('beef') ||
              category.contains('fish') ||
              category.contains('seafood') ||
              category.contains('egg') ||
              category.contains('dairy') ||
              category.contains('milk')) {
            return false;
          }
          return true;
        }).toList();
      }

      return foods;
    });
  }
}
