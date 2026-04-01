import 'package:flutter/material.dart';

/// Danh sach loai hoat dong dung cho ghi nhanh tren Home.
///
/// Moi gia tri tuong ung mot chip de nguoi dung ghi nhanh buoi tap ma
/// khong can vao catalog bai tap day du.
enum WorkoutType {
  running('running'),
  cycling('cycling'),
  badminton('badminton'),
  yoga('yoga'),
  other('other');

  final String value;
  const WorkoutType(this.value);

  /// Ten hien thi tieng Viet.
  String get displayName {
    switch (this) {
      case WorkoutType.running:
        return 'Chạy bộ';
      case WorkoutType.cycling:
        return 'Đạp xe';
      case WorkoutType.badminton:
        return 'Cầu lông';
      case WorkoutType.yoga:
        return 'Yoga';
      case WorkoutType.other:
        return 'Khác';
    }
  }

  /// Icon dai dien cho loai hoat dong.
  IconData get icon {
    switch (this) {
      case WorkoutType.running:
        return Icons.directions_run;
      case WorkoutType.cycling:
        return Icons.directions_bike;
      case WorkoutType.badminton:
        return Icons.sports_tennis;
      case WorkoutType.yoga:
        return Icons.self_improvement;
      case WorkoutType.other:
        return Icons.fitness_center;
    }
  }

  /// Gia tri MET mac dinh de uoc tinh calo.
  ///
  /// Su dung muc cuong do vua phai cho luong ghi nhanh.
  /// Khi can do chinh xac cao hon, nen ghi qua danh sach bai tap chi tiet.
  double get defaultMET {
    switch (this) {
      case WorkoutType.running:
        return 8.0; // Running at ~8 km/h (moderate pace)
      case WorkoutType.cycling:
        return 7.5; // Cycling at ~20 km/h (moderate pace)
      case WorkoutType.badminton:
        return 5.5; // Badminton, social singles/doubles
      case WorkoutType.yoga:
        return 2.5; // Hatha yoga
      case WorkoutType.other:
        return 5.0; // General moderate-intensity exercise
    }
  }

  /// Uoc tinh calo dot chay theo cong thuc MET.
  ///
  /// Formula: MET * 3.5 * weight (kg) / 200 * minutes
  double calculateCalories({
    required double weightKg,
    required double durationMinutes,
  }) {
    if (weightKg <= 0 || durationMinutes <= 0) return 0.0;
    return (defaultMET * 3.5 * weightKg / 200) * durationMinutes;
  }

  /// Chuyen tu string sang [WorkoutType].
  static WorkoutType fromString(String? value) {
    return WorkoutType.values.firstWhere(
      (e) => e.value == value,
      orElse: () => WorkoutType.other,
    );
  }
}
