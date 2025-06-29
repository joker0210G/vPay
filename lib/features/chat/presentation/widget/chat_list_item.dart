// chat_list_item.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart'; // Added Riverpod
import 'package:vpay/core/constants/colors.dart';
import 'package:vpay/features/chat/domain/chat_list_item_model.dart';
import 'package:vpay/features/chat/provider/chat_provider.dart'; // Added provider import
import 'package:vpay/features/task/domain/task_model.dart';

class ChatListItem extends ConsumerWidget { // Changed to ConsumerWidget
  final ChatListItemModel chatItem;
  final VoidCallback onTap;
  final VoidCallback? onTaskDetails;
  final String timeString;
  final bool isHighPriority;
  final Color priorityColor;
  final IconData priorityIcon;
  final Widget statusChip;

  const ChatListItem({
    super.key,
    required this.chatItem,
    required this.onTap,
    required this.timeString,
    required this.isHighPriority,
    required this.priorityColor,
    required this.priorityIcon,
    required this.statusChip,
    this.onTaskDetails,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) { // Added WidgetRef
    final unreadCountAsync = ref.watch(unreadCountProvider(chatItem.roomId)); // Watch the provider

    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: isHighPriority ? Border(
            left: BorderSide(
              color: priorityColor,
              width: 4.0,
            ),
          ) : null,
        ),
        child: Row(
          children: [
            Expanded(
              child: Row(
                children: [
                  Stack(
                    children: [
                      chatItem.participantAvatarUrl != null
                          ? CircleAvatar(
                              backgroundImage: NetworkImage(chatItem.participantAvatarUrl!),
                              backgroundColor: AppColors.primary.withAlpha((0.8 * 255).round()),
                            )
                          : CircleAvatar(
                              backgroundColor: AppColors.primary.withAlpha((0.8 * 255).round()),
                              child: Icon(
                                chatItem.category.icon,
                                color: Colors.white,
                                size: 20,
                              ),
                            ),
                      if (isHighPriority)
                        Positioned(
                          right: 0,
                          bottom: 0,
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: priorityColor,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              priorityIcon,
                              size: 10,
                              color: Colors.white,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                chatItem.taskTitle,
                                style: const TextStyle(fontWeight: FontWeight.w600),
                              ),
                            ),
                            Text(
                              timeString,
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.grey,
                                fontWeight: FontWeight.normal,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        statusChip,
                        const SizedBox(height: 4),
                        Text(
                          chatItem.lastMessage,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            IconButton(
              icon: const Icon(Icons.assignment, color: Colors.grey),
              onPressed: onTaskDetails,
            ),
            unreadCountAsync.when(
              data: (count) {
                if (count > 0) {
                  return CircleAvatar(
                    radius: 10,
                    backgroundColor: AppColors.accent,
                    child: Text(
                      count.toString(),
                      style: const TextStyle(color: Colors.white, fontSize: 12),
                    ),
                  );
                }
                return const SizedBox.shrink();
              },
              loading: () => const SizedBox(width: 20, height: 20), // Placeholder for loading
              error: (err, stack) => const SizedBox.shrink(), // Or an error icon
            ),
          ],
        ),
      ),
    );
  }
}
