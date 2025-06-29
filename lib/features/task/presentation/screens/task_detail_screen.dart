import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:vpay/features/task/domain/task_status.dart';
import 'package:vpay/features/task/providers/task_provider.dart';
import 'package:vpay/features/chat/provider/chat_provider.dart';
import 'package:vpay/features/chat/domain/chat_list_item_model.dart';
import 'package:vpay/features/task/domain/task_model.dart';
// import 'package:vpay/core/constants/colors.dart'; // Removed

class TaskDetailScreen extends ConsumerWidget {
  final String taskId;

  const TaskDetailScreen({super.key, required this.taskId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final taskAsync = ref.watch(taskDetailStreamProvider(taskId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Task Details'),
      ),
      body: taskAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
        data: (task) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title
                Text(
                  task.title,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 16),

                // Description
                Text(
                  task.description,
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                const SizedBox(height: 16),

                // Amount
                Row(
                  children: [
                    const Icon(Icons.attach_money, size: 20),
                    const SizedBox(width: 4),
                    Text(
                      task.amount.toStringAsFixed(2),
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Status with color chip
                Row(
                  children: [
                    const Text('Status: ', style: TextStyle(fontWeight: FontWeight.bold)),
                    Chip(
                      label: Text(task.status.displayName),
                      backgroundColor: TaskStatusColor(task.status).color,
                      labelStyle: const TextStyle(color: Colors.white),
                    ),
                  ],
                ),
                const SizedBox(height: 8),

                // Category
                Row(
                  children: [
                    const Text('Category: ', style: TextStyle(fontWeight: FontWeight.bold)),
                    Chip(
                      label: Text(task.category.displayName),
                      backgroundColor: Colors.grey[200],
                    ),
                  ],
                ),
                const SizedBox(height: 8),

                // Due Date
                if (task.dueDate != null)
                  Row(
                    children: [
                      const Icon(Icons.event, size: 18),
                      const SizedBox(width: 4),
                      Text('Due: ${task.dueDate!.toLocal().toString().split(' ')[0]}'),
                    ],
                  ),
                if (task.dueDate != null) const SizedBox(height: 8),

                // Assignee
                Row(
                  children: [
                    const Icon(Icons.person, size: 18),
                    const SizedBox(width: 4),
                    Text('Assignee: ${task.assigneeId ?? 'Unassigned'}'),
                  ],
                ),
                const SizedBox(height: 8),

                // Tags
                if (task.tags.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  const Text('Tags:', style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8.0,
                    runSpacing: 4.0,
                    children: task.tags.map((tag) => Chip(label: Text(tag))).toList(),
                  ),
                ],
                const SizedBox(height: 24),

                // Action Buttons
                if (task.status == TaskStatus.pending && task.assigneeId == null)
                  ElevatedButton.icon(
                    icon: const Icon(Icons.how_to_reg),
                    label: const Text('Apply for Task'),
                    onPressed: () => context.go('/apply-task/${task.id}'),
                  ),

                if (task.assigneeId != null)
                  ElevatedButton.icon(
                    icon: const Icon(Icons.chat_bubble_outline),
                    label: const Text('Chat with Assignee'),
                    onPressed: () async {
                      final chatRepository = ref.read(chatRepositoryProvider);
                      final currentUser = Supabase.instance.client.auth.currentUser;
                      if (currentUser != null) {
                        try {
                          final roomId = await chatRepository.createChatRoom(
                            taskId: task.id,
                            creatorId: currentUser.id,
                            participantId: task.assigneeId!,
                          );
                          if (context.mounted) {
                            context.push('/chat/${task.id}', extra: ChatListItemModel(
                              roomId: roomId,
                              taskId: task.id,
                              taskTitle: task.title,
                              lastMessage: '',
                              participantName: 'Task Assignee',
                              lastActivity: DateTime.now(),
                              status: task.status,
                              category: task.category,
                            ));
                          }
                        } catch (e) {
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Error starting chat: ${e.toString()}'),
                              ),
                            );
                          }
                        }
                      }
                    },
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}