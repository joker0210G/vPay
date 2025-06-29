import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:vpay/features/task/domain/task_model.dart';
import 'package:vpay/features/task/domain/task_status.dart';
import 'package:vpay/shared/config/supabase_config.dart';
import 'package:vpay/features/chat/data/chat_repository.dart';
import 'package:rxdart/rxdart.dart';
import 'package:logging/logging.dart'; // Added logging import

final _log = Logger('TaskRepository'); // Added logger instance

class TaskRepository {
  final SupabaseClient _supabase;
  final ChatRepository _chatRepository;

  // Allow optional injection of ChatRepository for easier testing/mocking
  TaskRepository(this._supabase, [ChatRepository? chatRepo])
      : _chatRepository = chatRepo ?? ChatRepository(_supabase);

  /// Stream all tasks, ordered by creation date (descending)
  Stream<List<TaskModel>> getTasks() {
    return _supabase
        .from(SupabaseConfig.tasksTable)
        .stream(primaryKey: ['id'])
        .order('created_at', ascending: false)
        .map((tasks) => tasks.map((task) => TaskModel.fromJson(task)).toList());
  }

  /// Stream all tasks where the user is either the creator or assignee
  Stream<List<TaskModel>> getMyTasks(String userId) {
    final createdTasksStream = _supabase
        .from(SupabaseConfig.tasksTable)
        .stream(primaryKey: ['id'])
        .eq('creator_id', userId)
        .order('created_at', ascending: false)
        .map((tasks) => tasks.map((task) => TaskModel.fromJson(task)).toList());

    final assignedTasksStream = _supabase
        .from(SupabaseConfig.tasksTable)
        .stream(primaryKey: ['id'])
        .eq('assignee_id', userId)
        .order('created_at', ascending: false)
        .map((tasks) => tasks.map((task) => TaskModel.fromJson(task)).toList());

    // Combine both streams and deduplicate using Set
    return Rx.combineLatest2(
      createdTasksStream,
      assignedTasksStream,
      (List<TaskModel> created, List<TaskModel> assigned) {
        // Ensure TaskModel implements == and hashCode for deduplication
        final allTasks = {...created, ...assigned};
        return allTasks.toList();
      },
    );
  }

  /// Create a new task and (optionally) a chat room if assigned
  Future<TaskModel> createTask({
    required String creatorId,
    required String title,
    required String description,
    required double amount,
    String? assigneeId,
    DateTime? dueDate,
    required String category,
    double? latitude,
    double? longitude,
    List<String>? tags,
  }) async {
    // Input validation
    if (creatorId.isEmpty) throw ArgumentError('Creator ID cannot be empty');
    if (title.isEmpty || title.length > 100) throw ArgumentError('Title must be between 1-100 characters');
    if (description.isEmpty) throw ArgumentError('Description cannot be empty');
    if (amount <= 0) throw ArgumentError('Amount must be positive');
    if (category.isEmpty) throw ArgumentError('Category cannot be empty');
    if (dueDate != null && dueDate.isBefore(DateTime.now())) {
      throw ArgumentError('Due date cannot be in the past');
    }

    final timestamp = DateTime.now().toIso8601String();
    final status = assigneeId != null ? TaskStatus.inProgress : TaskStatus.pending;
    TaskModel task;

    try {
      final response = await _supabase
          .from(SupabaseConfig.tasksTable)
          .insert({
            'creator_id': creatorId,
            'assignee_id': assigneeId,
            'title': title,
            'description': description,
            'amount': amount,
            'due_date': dueDate?.toIso8601String(),
            'category': category,
            'status': status.toJson(),
            'created_at': timestamp,
            'updated_at': timestamp,
            'latitude': latitude,
            'longitude': longitude,
            'tags': tags ?? <String>[],
          })
          .select()
          .single();
      task = TaskModel.fromJson(response);
    } catch (e) {
      _log.severe('Failed to insert task into database: $e', e);
      rethrow; // Rethrow the exception to be handled by the caller
    }

    // Create chat room if task is assigned
    if (assigneeId != null) {
      try {
        await _chatRepository.createChatRoom(
          taskId: task.id, // Renamed task_id to taskId
          creatorId: creatorId,
          participantId: assigneeId,
        );
      } catch (e) { // Removed unused 'st'
        _log.warning('Failed to create chat room for task ${task.id}: $e', e);
      }
    }

    return task;
  }

  /// Update a task and handle chat room creation if assigned for the first time
  Future<TaskModel> updateTask(String taskId, Map<String, dynamic> updates) async { // Renamed task_id to taskId
    // Input validation
    if (taskId.isEmpty) throw ArgumentError('Task ID cannot be empty'); // Renamed task_id to taskId
    if (updates.isEmpty) throw ArgumentError('Updates cannot be empty');

    updates['updated_at'] = DateTime.now().toIso8601String();

    // Convert status to JSON if needed
    if (updates.containsKey('status') && updates['status'] is TaskStatus) {
      updates['status'] = (updates['status'] as TaskStatus).toJson();
    }

    final previousTask = await getTask(taskId); // Renamed task_id to taskId
    TaskModel updatedTask;
    
    // Use transaction for atomic updates
    await _supabase.rpc('begin');
    try {
      final response = await _supabase // Ensure this is part of the try block
          .from(SupabaseConfig.tasksTable)
          .update(updates)
          .eq('id', taskId) // Renamed task_id to taskId
          .select()
          .single();

      updatedTask = TaskModel.fromJson(response);

      // Create chat room if task is being assigned for the first time
      if (updates['assignee_id'] != null && previousTask.assigneeId == null) {
        await _chatRepository.createChatRoom(
          taskId: taskId, // Renamed task_id to taskId
          creatorId: updatedTask.creatorId,
          participantId: updates['assignee_id'],
        );
      }

      await _supabase.rpc('commit');
    } catch (e) { // Removed unused 'st'
      await _supabase.rpc('rollback');
      _log.severe('Failed to update task $taskId: $e', e);
      rethrow;
    }

    return updatedTask;
  }

  /// Delete a task by ID
  Future<void> deleteTask(String taskId) async { // Renamed task_id to taskId
    if (taskId.isEmpty) throw ArgumentError('Task ID cannot be empty'); // Renamed task_id to taskId

    const maxRetries = 3;
    var attempt = 0;
    
    while (true) {
      try {
        await _supabase // Ensure this is part of the try block
            .from(SupabaseConfig.tasksTable)
            .delete()
            .eq('id', taskId); // Renamed task_id to taskId
        return;
      } catch (e) { // Removed unused 'st'
        if (++attempt >= maxRetries) {
          _log.severe('Failed to delete task $taskId after $maxRetries attempts: $e', e);
          rethrow;
        }
        // Exponential backoff
        await Future.delayed(Duration(seconds: 1 * attempt));
      }
    }
  }

  /// Get a single task by ID
  Future<TaskModel> getTask(String taskId) async { // Renamed task_id to taskId
    final response = await _supabase
        .from(SupabaseConfig.tasksTable)
        .select()
        .eq('id', taskId) // Renamed task_id to taskId
        .single();
    return TaskModel.fromJson(response);
  }

  /// Watch a single task for live updates, with null safety
  Stream<TaskModel> watchTask(String taskId) { // Renamed task_id to taskId
    return _supabase
        .from(SupabaseConfig.tasksTable)
        .stream(primaryKey: ['id'])
        .eq('id', taskId) // Renamed task_id to taskId
        .map((data) {
          if (data.isNotEmpty) {
            return TaskModel.fromJson(data.first);
          } else {
            throw Exception('Task not found');
          }
        });
  }

  /// Search tasks by title (full-text search)
  Future<List<TaskModel>> searchTasks(String query) async {
    final response = await _supabase
        .from(SupabaseConfig.tasksTable)
        .select()
        .textSearch('title', query)
        .order('created_at', ascending: false);

    return response.map<TaskModel>((task) => TaskModel.fromJson(task)).toList();
  }


}
