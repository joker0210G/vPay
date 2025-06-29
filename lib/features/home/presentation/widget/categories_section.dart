// features/home/presentation/widgets/categories_section.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:vpay/core/constants/colors.dart';
import 'package:vpay/features/task/domain/task_model.dart'; // Provides TaskCategory and its extensions

class CategoriesSection extends ConsumerWidget {
  const CategoriesSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Task Categories',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: TaskCategory.values.map((category) {
              return GestureDetector(
                onTap: () {
                  // Assuming TaskCategory.name gives the string representation like 'academicSupport'
                  // This requires Dart 2.15+
                  // For older versions, you might use category.toString().split('.').last
                  context.go('/tasks?category=${category.name}');
                },
                child: CategoryChip(
                  icon: category.icon, // From TaskCategoryIconExtension
                  label: category.displayName, // From TaskCategoryDisplay extension
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

class CategoryChip extends StatelessWidget {
  final IconData icon;
  final String label;

  const CategoryChip({
    super.key,
    required this.icon,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: AppColors.primary.withAlpha((0.1 * 255).round()),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: AppColors.primary),
          const SizedBox(width: 4),
          Text(label),
        ],
      ),
    );
  }
}
