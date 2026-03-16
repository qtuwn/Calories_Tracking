// Legacy food providers file
// Lưu ý: File này chỉ dùng cho code cũ, đang trong quá trình migration sang shared/state/food_providers.dart.
// Không nên sử dụng cho code mới.
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:calories_app/features/foods/data/food_repository.dart';

/// Provider for FoodRepository
/// 
/// @Deprecated Use shared/state/food_providers.dart::foodRepositoryProvider instead.
/// The new provider uses FirestoreFoodRepository with cache support.
@Deprecated('Use shared/state/food_providers.dart::foodRepositoryProvider instead. Migration in progress.')
final foodRepositoryProvider = Provider<FoodRepository>((ref) {
  // Provider cũ cho FoodRepository, không hỗ trợ cache.
  return FoodRepository();
});

/// Notifier for category filter state
class FoodCategoryFilterNotifier extends Notifier<String?> {
  // Notifier quản lý trạng thái filter theo category cho legacy UI.
  @override
  String? build() => 'All';

  void setCategory(String? value) {
    state = value;
  }
}

/// Provider for category filter
final foodCategoryFilterProvider =
    NotifierProvider<FoodCategoryFilterNotifier, String?>(
      FoodCategoryFilterNotifier.new,
      // Provider cho filter category, chỉ dùng cho legacy code.
    );
