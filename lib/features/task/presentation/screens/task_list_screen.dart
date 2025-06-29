import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:vpay/features/task/providers/task_provider.dart';
// import 'package:vpay/core/constants/colors.dart'; // Removed
import 'package:vpay/features/task/domain/task_model.dart';
import 'package:vpay/features/task/domain/task_status.dart';

class TaskListScreen extends ConsumerWidget {
  final String? categoryName;
  const TaskListScreen({super.key, this.categoryName});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tasksAsync = ref.watch(tasksStreamProvider);
    String appBarTitle = 'Tasks';
    TaskCategory? selectedCategory;

    if (categoryName != null && categoryName!.isNotEmpty) {
      try {
        // Assumes Dart 2.15+ for byName
        selectedCategory = TaskCategory.values.byName(categoryName!);
        appBarTitle = 'Tasks - ${selectedCategory.displayName}';
      } catch (e) {
        // Handle invalid category name, e.g., log error or show all tasks
        debugPrint('Error parsing category name: $categoryName, error: $e'); // Changed print to debugPrint
        appBarTitle = 'Tasks - Invalid Category';
        // Optionally, reset categoryName or selectedCategory to null to show all tasks
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(appBarTitle),
      ),
      body: tasksAsync.when(
        data: (allTasks) {
          List<TaskModel> filteredTasks = allTasks;
          if (selectedCategory != null) {
            filteredTasks = allTasks
                .where((task) => task.category == selectedCategory)
                .toList();
          }

          if (filteredTasks.isEmpty) {
            return Center(
                child: Text(selectedCategory != null
                    ? 'No tasks found for ${selectedCategory.displayName}'
                    : 'No tasks found'));
          }
          return ListView.builder(
            itemCount: filteredTasks.length,
            itemBuilder: (context, index) {
              final task = filteredTasks[index];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: TaskStatusColor(task.status).color.withAlpha((0.8 * 255).toInt()),
                    child: Icon(Icons.assignment, color: Colors.white),
                  ),
                  title: Text(task.title, style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${task.category.displayName} • ${task.status.displayName}',
                        style: TextStyle(
                          color: TaskStatusColor(task.status).color,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      if (task.dueDate != null)
                        Text(
                          'Due: ${task.dueDate!.toLocal().toString().split(' ')[0]}',
                          style: TextStyle(color: Colors.grey[700], fontSize: 12),
                        ),
                      Text(
                        task.description,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(color: Colors.black87),
                      ),
                    ],
                  ),
                  trailing: Text('\$${task.amount.toStringAsFixed(2)}',
                      style: const TextStyle(fontWeight: FontWeight.bold)),
                  onTap: () => context.go('/task-details/${task.id}'),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                ),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.go('/create-task'),
        tooltip: 'Create Task',
        child: const Icon(Icons.add),
      ),
    );
  }
}
