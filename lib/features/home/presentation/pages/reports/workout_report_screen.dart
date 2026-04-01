import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:calories_app/features/home/presentation/providers/statistics_providers.dart';
import 'package:calories_app/features/home/domain/statistics_models.dart';

/// Man hinh bao cao thong ke hoat dong tap luyen.
///
/// Hien thi cac chi so theo ngay/tuan/thang:
/// - Tong calo dot chay
/// - Thoi luong va tan suat tap
/// - Cac loai bai tap va xu huong
///
/// Duong dan: Tai Account > "Xem bao cao thong ke" > "Tap luyen"
class WorkoutReportScreen extends ConsumerWidget {
  const WorkoutReportScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Báo cáo tập luyện',
          style: TextStyle(
            color: Colors.black87,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Card mo ta chuc nang bao cao.
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Tổng quan',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Báo cáo này sẽ hiển thị thống kê tập luyện theo ngày, tuần và tháng, bao gồm tổng lượng calo đốt cháy, thời gian tập luyện, tần suất, và xu hướng các loại bài tập.',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.grey[600],
                        ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Bao cao hom nay.
            _buildSection(
              context,
              title: 'Hôm nay',
              child: _buildTodaySection(context, ref),
            ),
            const SizedBox(height: 24),

            // Bao cao tuan nay.
            _buildSection(
              context,
              title: 'Tuần này',
              child: _buildWeekSection(context, ref),
            ),
            const SizedBox(height: 24),

            // Bao cao thang nay.
            _buildSection(
              context,
              title: 'Tháng này',
              child: _buildMonthSection(context, ref),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  /// Tao tieu chi tinh cho cac section ngay/tuan/thang.
  Widget _buildSection(BuildContext context, {required String title, required Widget child}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
        ),
        const SizedBox(height: 16),
        child,
      ],
    );
  }

  /// Lay va hien thi thong ke tap luyen hom nay.
  Widget _buildTodaySection(BuildContext context, WidgetRef ref) {
    final statsAsync = ref.watch(todayWorkoutStatsProvider);

    return statsAsync.when(
      data: (stats) {
        if (stats.workoutCount == 0) {
          return _buildEmptyState(context, 'Chưa có dữ liệu tập luyện hôm nay');
        }
        return _buildWorkoutSummaryCard(context, stats);
      },
      loading: () => const Center(
        child: Padding(
          padding: EdgeInsets.all(40),
          child: CircularProgressIndicator(),
        ),
      ),
      error: (error, stack) => _buildErrorState(context, error.toString(), () {
        ref.invalidate(todayWorkoutStatsProvider);
      }),
    );
  }

  /// Lay va hien thi thong ke tap luyen tuan nay.
  Widget _buildWeekSection(BuildContext context, WidgetRef ref) {
    final statsAsync = ref.watch(weekWorkoutStatsProvider);

    return statsAsync.when(
      data: (stats) {
        if (stats.workoutCount == 0) {
          return _buildEmptyState(context, 'Chưa có dữ liệu tập luyện tuần này');
        }
        return _buildWorkoutSummaryCard(context, stats);
      },
      loading: () => const Center(
        child: Padding(
          padding: EdgeInsets.all(40),
          child: CircularProgressIndicator(),
        ),
      ),
      error: (error, stack) => _buildErrorState(context, error.toString(), () {
        ref.invalidate(weekWorkoutStatsProvider);
      }),
    );
  }

  /// Lay va hien thi thong ke tap luyen thang nay.
  Widget _buildMonthSection(BuildContext context, WidgetRef ref) {
    final statsAsync = ref.watch(monthWorkoutStatsProvider);

    return statsAsync.when(
      data: (stats) {
        if (stats.workoutCount == 0) {
          return _buildEmptyState(context, 'Chưa có dữ liệu tập luyện tháng này');
        }
        return _buildWorkoutSummaryCard(context, stats);
      },
      loading: () => const Center(
        child: Padding(
          padding: EdgeInsets.all(40),
          child: CircularProgressIndicator(),
        ),
      ),
      error: (error, stack) => _buildErrorState(context, error.toString(), () {
        ref.invalidate(monthWorkoutStatsProvider);
      }),
    );
  }

  /// Xay dung card thong ken chi tiet co thong ke tap luyen.
  Widget _buildWorkoutSummaryCard(BuildContext context, WorkoutStats stats) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Tổng quan',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 16),
          _buildStatRow(
            context,
            'Calo đốt cháy',
            '${stats.totalCaloriesBurned.toStringAsFixed(0)} kcal',
            Icons.local_fire_department,
            Colors.orange,
          ),
          const SizedBox(height: 12),
          _buildStatRow(
            context,
            'Thời gian tập luyện',
            '${stats.totalDurationMinutes.toStringAsFixed(0)} phút',
            Icons.timer,
            Colors.blue,
          ),
          const SizedBox(height: 12),
          _buildStatRow(
            context,
            'Số buổi tập',
            '${stats.workoutCount} buổi',
            Icons.fitness_center,
            Colors.green,
          ),
          if (stats.workoutCount > 0) ...[
            const SizedBox(height: 12),
            _buildStatRow(
              context,
              'Trung bình calo/buổi',
              '${stats.avgCaloriesPerWorkout.toStringAsFixed(0)} kcal',
              Icons.trending_up,
              Colors.purple,
            ),
          ],
          if (stats.exerciseNames.isNotEmpty) ...[
            const SizedBox(height: 16),
            Text(
              'Các bài tập',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: stats.exerciseNames.map((name) {
                return Chip(
                  label: Text(name),
                  backgroundColor: Colors.green[50],
                  labelStyle: const TextStyle(fontSize: 12),
                );
              }).toList(),
            ),
          ],
        ],
      ),
    );
  }

  /// Tao hang thong ke voi icon, nhan, gia tri.
  Widget _buildStatRow(
    BuildContext context,
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Row(
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            label,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ),
        Text(
          value,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: color,
              ),
        ),
      ],
    );
  }

  Widget _buildEmptyState(BuildContext context, String message) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(40),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(
            Icons.fitness_center,
            size: 48,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 12),
          Text(
            message,
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 14,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(BuildContext context, String error, VoidCallback onRetry) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.red[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.red[200]!),
      ),
      child: Column(
        children: [
          Icon(Icons.error_outline, color: Colors.red[400], size: 32),
          const SizedBox(height: 8),
          Text(
            'Lỗi tải dữ liệu',
            style: TextStyle(
              color: Colors.red[700],
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            error,
            style: TextStyle(
              color: Colors.red[600],
              fontSize: 12,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          TextButton(
            onPressed: onRetry,
            child: const Text('Thử lại'),
          ),
        ],
      ),
    );
  }
}

