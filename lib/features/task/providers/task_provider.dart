import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:vpay/features/task/data/task_repository.dart';
import 'package:vpay/features/task/domain/task_model.dart';
import 'package:vpay/features/task/domain/task_status.dart';

// Repository Provider 
final taskRepositoryProvider = Provider<TaskRepository>((ref) {
  return TaskRepository(Supabase.instance.client);
});

// Stream provider for all tasks
final tasksStreamProvider = StreamProvider<List<TaskModel>>((ref) {
  final repo = ref.watch(taskRepositoryProvider);
  return repo.getTasks();
});

// Stream provider for current user's tasks
final myTasksStreamProvider = StreamProvider.autoDispose.family<List<TaskModel>, String>((ref, userId) {
  final repo = ref.watch(taskRepositoryProvider);
  return repo.getMyTasks(userId);
});


final taskDetailStreamProvider = StreamProvider.autoDispose.family<TaskModel, String>((ref, taskId) { // Renamed task_id to taskId
  final repo = ref.watch(taskRepositoryProvider);
  return repo.watchTask(taskId); // Renamed task_id to taskId
});

final searchTasksProvider = FutureProvider.autoDispose.family<List<TaskModel>, String>((ref, query) {
  final repo = ref.watch(taskRepositoryProvider);
  return repo.searchTasks(query);
});

final filteredTasksProvider = Provider.autoDispose.family<List<TaskModel>, TaskStatus>((ref, status) {
  final tasks = ref.watch(tasksStreamProvider).asData?.value ?? [];
  return tasks.where((task) => task.status == status).toList();
});

final searchQueryProvider = StateProvider<String>((ref) => '');
final selectedStatusProvider = StateProvider<TaskStatus?>((ref) => null);
