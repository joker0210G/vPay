// features/home/presentation/widgets/stats_section.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shimmer/shimmer.dart';
import 'package:vpay/core/constants/colors.dart';
import 'package:vpay/features/home/provider/home_provider.dart';
// import 'package:vpay/features/task/domain/task_model.dart'; // Unused
import 'package:vpay/features/task/domain/task_status.dart';
import 'package:vpay/features/task/providers/task_provider.dart';

class StatsSection extends ConsumerWidget {
  const StatsSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsync = ref.watch(userProvider);

    // Determine overall loading/error state from userProvider first
    bool isUserLoading = userAsync.isLoading;
    bool isUserError = userAsync.hasError || userAsync.value == null && !userAsync.isLoading;
    String? userId = userAsync.value?.id;

    // Available Tasks
    final availableTasksData = ref.watch(tasksStreamProvider);
    bool isLoadingAvailable = isUserLoading || availableTasksData.isLoading;
    bool hasErrorAvailable = isUserError || availableTasksData.hasError;
    String displayAvailableCount;
    if (isLoadingAvailable) {
      displayAvailableCount = ''; // Handled by shimmer
    } else if (hasErrorAvailable || userId == null) {
      displayAvailableCount = 'N/A';
      // if (availableTasksData.hasError) print('Error fetching all tasks: ${availableTasksData.error}');
    } else {
      displayAvailableCount = availableTasksData.value!
          .where((task) => task.status == TaskStatus.pending)
          .length
          .toString();
    }

    // My Tasks (In-Progress and Completed)
    // Only watch if userId is available, otherwise, it's an error or loading state for these cards.
    final myTasksData = userId != null ? ref.watch(myTasksStreamProvider(userId)) : null;
    bool isLoadingMyTasks = isUserLoading || (userId != null && (myTasksData?.isLoading ?? true));
    bool hasErrorMyTasks = isUserError || (userId != null && (myTasksData?.hasError ?? false)) || userId == null;

    String displayInProgressCount;
    if (isLoadingMyTasks) {
      displayInProgressCount = '';
    } else if (hasErrorMyTasks) {
      displayInProgressCount = 'N/A';
      // if (userId != null && myTasksData!.hasError) print('Error fetching my tasks: ${myTasksData.error}');
    } else {
      displayInProgressCount = myTasksData!.value!
          .where((task) =>
              task.assigneeId == userId &&
              task.status == TaskStatus.inProgress)
          .length
          .toString();
    }

    String displayCompletedCount;
    if (isLoadingMyTasks) {
      displayCompletedCount = '';
    } else if (hasErrorMyTasks) {
      displayCompletedCount = 'N/A';
      // Error already printed for myTasksData if applicable
    } else {
      displayCompletedCount = myTasksData!.value!
          .where((task) =>
              task.status == TaskStatus.completed &&
              (task.assigneeId == userId || task.creatorId == userId))
          .length
          .toString();
    }
    
    // if (userAsync.hasError) print('Error fetching user for stats: ${userAsync.error}');


    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          _StatCard(
            isLoading: isLoadingAvailable,
            hasError: hasErrorAvailable && !isLoadingAvailable, // Don't show error state if also loading
            displayCount: displayAvailableCount,
            label: 'Available Tasks',
            color: AppColors.primary,
          ),
          const SizedBox(width: 16),
          _StatCard(
            isLoading: isLoadingMyTasks,
            hasError: hasErrorMyTasks && !isLoadingMyTasks,
            displayCount: displayInProgressCount,
            label: 'My In-Progress',
            color: AppColors.secondary,
            textColor: Colors.black,
          ),
          const SizedBox(width: 16),
          _StatCard(
            isLoading: isLoadingMyTasks, // Uses the same myTasksData stream
            hasError: hasErrorMyTasks && !isLoadingMyTasks,
            displayCount: displayCompletedCount,
            label: 'My Completed',
            color: AppColors.accent,
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final bool isLoading;
  final bool hasError;
  final String displayCount;
  final String label;
  final Color color;
  final Color textColor;

  const _StatCard({
    required this.isLoading,
    required this.hasError,
    required this.displayCount,
    required this.label,
    required this.color,
    this.textColor = Colors.white,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(10),
        ),
        child: isLoading
            ? Shimmer.fromColors(
                baseColor: Colors.grey[300]!.withAlpha(color == AppColors.secondary ? 150 : 70), // Darker base for light backgrounds
                highlightColor: Colors.grey[100]!.withAlpha(color == AppColors.secondary ? 200 : 120), // Brighter highlight
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(width: 60, height: 20, color: Colors.white), // Placeholder for count
                    const SizedBox(height: 4),
                    Container(width: 100, height: 16, color: Colors.white), // Placeholder for label
                  ],
                ),
              )
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    hasError ? "N/A" : displayCount,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: textColor,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  Text(
                    label,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: textColor,
                        ),
                  ),
                ],
              ),
      ),
    );
  }
}
