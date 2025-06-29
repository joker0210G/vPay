// feature/tasks/presentation/screens/my_tasks_screen.darta

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:vpay/features/auth/providers/auth_provider.dart';
import 'package:vpay/features/task/providers/task_provider.dart';
import 'package:vpay/features/task/domain/task_status.dart';
import 'package:vpay/features/task/domain/task_model.dart';
import 'package:vpay/core/constants/colors.dart';

class MyTasksScreen extends ConsumerWidget {
  const MyTasksScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentUser = ref.watch(authProvider).user;
    if (currentUser == null) {
      return const Scaffold(
        body: Center(child: Text('Please login to view your tasks')),
      );
    }

    final tasksAsync = ref.watch(myTasksStreamProvider(currentUser.id));

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Tasks'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: 'Search tasks',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      prefixIcon: const Icon(Icons.search),
                    ),
                    onChanged: (query) => ref.read(searchQueryProvider.notifier).state = query,
                  ),
                ),
                const SizedBox(width: 8),
                DropdownButton<TaskStatus>(
                  value: ref.watch(selectedStatusProvider),
                  onChanged: (status) => ref.read(selectedStatusProvider.notifier).state = status,
                  items: TaskStatus.values.map((status) => DropdownMenuItem(value: status, child: Text(status.displayName))).toList(),
                ),
              ],
            ),
          ),
          tasksAsync.when(
            loading: () => const Expanded(child: Center(child: CircularProgressIndicator())),
            error: (err, stack) => Expanded(child: Center(child: Text('Error: $err'))),
            data: (tasks) {
              final filteredTasks = tasks
                  .where((task) => task.title.toLowerCase().contains(ref.watch(searchQueryProvider).toLowerCase()))
                  .where((task) => ref.watch(selectedStatusProvider) == null || task.status == ref.watch(selectedStatusProvider))
                  .toList();

              if (filteredTasks.isEmpty) {
                return const Expanded(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('No tasks found', style: TextStyle(fontSize: 18)),
                        SizedBox(height: 16),
                        Text('Create a task or apply for available tasks'),
                      ],
                    ),
                  ),
                );
              }

              return Expanded(
                child: ListView.separated(
                  itemCount: filteredTasks.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 8),
                  itemBuilder: (context, index) {
                    final task = filteredTasks[index];
                    final isCreator = task.creatorId == currentUser.id;

                    return Card(
                      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                      elevation: 2,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      child: ListTile(
                        title: Text(task.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(task.description, maxLines: 1, overflow: TextOverflow.ellipsis),
                            const SizedBox(height: 4),
                            Wrap(
                              spacing: 8,
                              runSpacing: 4,
                              children: [
                                Chip(
                                  label: Text('\$${task.amount.toStringAsFixed(2)}'),
                                  backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                                ),
                                Chip(
                                  label: Text(task.status.displayName),
                                  backgroundColor: TaskStatusColor(task.status).color,
                                  labelStyle: const TextStyle(color: Colors.white),
                                ),
                                Chip(
                                  label: Text(task.category.displayName),
                                  backgroundColor: Colors.grey[200],
                                ),
                                if (task.dueDate != null)
                                  Chip(
                                    label: Text('Due: ${task.dueDate!.toLocal().toString().split(' ')[0]}'),
                                    backgroundColor: Colors.grey[100],
                                  ),
                                Chip(
                                  label: Text(isCreator ? 'Created' : 'Assigned'),
                                  backgroundColor: isCreator ? Colors.blue[50] : Colors.green[50],
                                  labelStyle: TextStyle(
                                    color: isCreator ? Colors.blue : Colors.green,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        onTap: () => context.go('/task-details/${task.id}'),
                      ),
                    );
                  },
                ),
              );
            },
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.go('/create-task'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
    );
}
}
