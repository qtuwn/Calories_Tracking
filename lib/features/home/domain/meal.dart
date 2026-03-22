import 'diary_meal_item.dart';
import 'package:calories_app/features/meal_plans/domain/models/shared/meal_type.dart';

/// Model đại diện cho một bữa ăn cụ thể trong ngày (ví dụ: Bữa sáng, Bữa trưa)
/// Một [Meal] sẽ bao gồm loại bữa ăn và danh sách các món ăn [DiaryMealItem]
class Meal {
  /// Loại bữa ăn (Breakfast, Lunch, Dinner, Snack,...)
  final MealType type;
  
  /// Danh sách các món ăn có trong bữa này
  final List<DiaryMealItem> items;

  Meal({
    required this.type,
    List<DiaryMealItem>? items,
  }) : items = items ?? []; // Nếu không truyền items, mặc định là danh sách rỗng

  // --- PHẦN TÍNH TOÁN (GETTERS) ---

  /// Tổng năng lượng (kcal) của tất cả món ăn trong bữa
  double get totalCalories =>
      items.fold(0, (sum, item) => sum + item.totalCalories);

  /// Tổng lượng đạm (protein) của cả bữa ăn
  double get totalProtein =>
      items.fold(0, (sum, item) => sum + item.totalProtein);

  /// Tổng lượng đường/tinh bột (carbs) của cả bữa ăn
  double get totalCarbs =>
      items.fold(0, (sum, item) => sum + item.totalCarbs);

  /// Tổng lượng chất béo (fat) của cả bữa ăn
  double get totalFat =>
      items.fold(0, (sum, item) => sum + item.totalFat);

  /// Đếm xem bữa ăn này có bao nhiêu món
  int get itemCount => items.length;

  // --- PHẦN XỬ LÝ DỮ LIỆU ---

  /// Tạo một bản sao của đối tượng Meal nhưng có thể thay đổi một vài thuộc tính
  /// Thường dùng khi cập nhật trạng thái (State Management như Bloc, Riverpod)
  Meal copyWith({
    MealType? type,
    List<DiaryMealItem>? items,
  }) {
    return Meal(
      type: type ?? this.type,
      items: items ?? this.items,
    );
  }

  /// Chuyển đối tượng Meal thành Map để lưu vào database hoặc gửi lên Server (JSON)
  Map<String, dynamic> toJson() {
    return {
      'type': type.name, // Lưu tên của Enum (ví dụ: "breakfast")
      'items': items.map((item) => item.toJson()).toList(), // Chuyển từng món ăn thành JSON
    };
  }

  /// Khởi tạo đối tượng Meal từ dữ liệu Map (nhận từ API hoặc Database)
  factory Meal.fromJson(Map<String, dynamic> json) {
    return Meal(
      // Tìm giá trị Enum tương ứng với string được lưu trong JSON
      type: MealType.values.firstWhere(
        (e) => e.name == json['type'],
      ),
      // Chuyển danh sách JSON items ngược lại thành List<DiaryMealItem>
      items: (json['items'] as List<dynamic>)
          .map((item) => DiaryMealItem.fromJson(item as Map<String, dynamic>))
          .toList(),
    );
  }
}