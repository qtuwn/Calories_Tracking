/// Model cho một món ăn trong bữa ăn (dành cho Diary/Home feature)
///
/// NOTE:
/// - KHÔNG dùng cho meal plan (MealItem ở layer khác)
/// - Dùng để hiển thị và lưu log trong diary/home
class DiaryMealItem {
  /// ID duy nhất của item (có thể là UUID hoặc từ DB)
  final String id;

  /// Tên món ăn (ví dụ: "Ức gà luộc")
  final String name;

  /// Số khẩu phần người dùng ăn
  /// Ví dụ: 1.5 = ăn 1.5 phần tiêu chuẩn
  final double servingSize;

  /// Calories tính trên 100g thực phẩm
  final double caloriesPer100g;

  /// Protein (gram) trên 100g
  final double proteinPer100g;

  /// Carbs (gram) trên 100g
  final double carbsPer100g;

  /// Fat (gram) trên 100g
  final double fatPer100g;

  /// Khối lượng (gram) của 1 khẩu phần tiêu chuẩn
  /// Mặc định = 100g nếu không chỉ định
  final double gramsPerServing;

  DiaryMealItem({
    required this.id,
    required this.name,
    required this.servingSize,
    required this.caloriesPer100g,
    required this.proteinPer100g,
    required this.carbsPer100g,
    required this.fatPer100g,
    this.gramsPerServing = 100.0,
  });

  // =========================
  // Computed values (tính toán động)
  // =========================

  /// Tổng calories = (cal/100g * gram mỗi phần * số phần) / 100
  double get totalCalories =>
      (caloriesPer100g * gramsPerServing * servingSize) / 100;

  /// Tổng protein (gram)
  double get totalProtein =>
      (proteinPer100g * gramsPerServing * servingSize) / 100;

  /// Tổng carbs (gram)
  double get totalCarbs =>
      (carbsPer100g * gramsPerServing * servingSize) / 100;

  /// Tổng fat (gram)
  double get totalFat =>
      (fatPer100g * gramsPerServing * servingSize) / 100;

  /// Tổng khối lượng thực tế đã ăn (gram)
  double get totalGrams => gramsPerServing * servingSize;

  // =========================
  // Copy (immutability helper)
  // =========================

  /// Tạo bản sao với field được thay đổi
  /// Giữ immutable pattern (không mutate object gốc)
  DiaryMealItem copyWith({
    String? id,
    String? name,
    double? servingSize,
    double? caloriesPer100g,
    double? proteinPer100g,
    double? carbsPer100g,
    double? fatPer100g,
    double? gramsPerServing,
  }) {
    return DiaryMealItem(
      id: id ?? this.id,
      name: name ?? this.name,
      servingSize: servingSize ?? this.servingSize,
      caloriesPer100g: caloriesPer100g ?? this.caloriesPer100g,
      proteinPer100g: proteinPer100g ?? this.proteinPer100g,
      carbsPer100g: carbsPer100g ?? this.carbsPer100g,
      fatPer100g: fatPer100g ?? this.fatPer100g,
      gramsPerServing: gramsPerServing ?? this.gramsPerServing,
    );
  }

  // =========================
  // Serialization
  // =========================

  /// Convert object -> JSON (dùng cho lưu local/ API)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'servingSize': servingSize,
      'caloriesPer100g': caloriesPer100g,
      'proteinPer100g': proteinPer100g,
      'carbsPer100g': carbsPer100g,
      'fatPer100g': fatPer100g,
      'gramsPerServing': gramsPerServing,
    };
  }

  /// Parse JSON -> Object
  /// Lưu ý: ép kiểu num -> double để tránh lỗi runtime
  factory DiaryMealItem.fromJson(Map<String, dynamic> json) {
    return DiaryMealItem(
      id: json['id'] as String,
      name: json['name'] as String,
      servingSize: (json['servingSize'] as num).toDouble(),
      caloriesPer100g: (json['caloriesPer100g'] as num).toDouble(),
      proteinPer100g: (json['proteinPer100g'] as num).toDouble(),
      carbsPer100g: (json['carbsPer100g'] as num).toDouble(),
      fatPer100g: (json['fatPer100g'] as num).toDouble(),
      gramsPerServing: (json['gramsPerServing'] as num).toDouble(),
    );
  }
}