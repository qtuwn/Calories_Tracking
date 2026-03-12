import 'package:flutter/material.dart';
import 'package:calories_app/core/theme/app_colors.dart';

/// foodCategories - Danh sách các loại thực phẩm được nhận diện trong ứng dụng.
/// Dùng để phân loại thực phẩm khi hiển thị và xử lý dữ liệu.
const foodCategories = <String>[
  'All',
  'Rice',
  'Meat',
  'Vegetable',
  'Fruit',
  'Drink',
  'Snack',
];

/// categoryColor - Chuyển tên loại thực phẩm thành màu pastel tương ứng.
/// Giúp giao diện dễ nhận biết và phân biệt các loại thực phẩm.
Color categoryColor(String? category) {
  if (category == null || category.isEmpty) {
    return Colors.grey;
  }

  switch (category.toLowerCase()) {
    case 'rice':
      return AppColors.charmingGreen;
    case 'meat':
      return Colors.redAccent;
    case 'vegetable':
      return AppColors.mintGreen;
    case 'fruit':
      return Colors.orangeAccent;
    case 'drink':
      return Colors.blueAccent;
    case 'snack':
      return Colors.purpleAccent;
    default:
      return Colors.grey;
  }
}
