// chat_app_bar.dart
import 'package:flutter/material.dart';
import 'package:vpay/core/constants/colors.dart';

class ChatAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String participantName;
  final String? participantAvatarUrl;
  final String taskTitle;
  final VoidCallback? onInfoPressed;
  final List<String>? typingUsers;
  final bool isOtherUserOnline; // Added isOtherUserOnline

  const ChatAppBar({
    super.key,
    required this.participantName,
    required this.taskTitle,
    this.participantAvatarUrl,
    this.onInfoPressed,
    this.typingUsers,
    this.isOtherUserOnline = false, // Default to false
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: AppColors.primary,
      titleSpacing: 0,
      title: Row(
        children: [
          CircleAvatar(
            backgroundColor: AppColors.secondary.withAlpha((0.2 * 255).round()),
            backgroundImage: participantAvatarUrl != null
                ? NetworkImage(participantAvatarUrl!)
                : null,
            child: participantAvatarUrl == null
                ? Semantics(
                    label: 'Avatar for $participantName',
                    child: Text(
                      participantName.isNotEmpty
                          ? participantName[0].toUpperCase()
                          : '?',
                      style: TextStyle(color: AppColors.primary),
                    ),
                  )
                : null,
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                participantName,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
              ),
              Text(
                taskTitle,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.white.withAlpha((0.7 * 255).round()),
                    ),
              ),
              // Subtitle logic for typing or online status
              _buildSubtitle(context),
            ],
          ),
        ],
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.info_outline, color: Colors.white),
          tooltip: 'Task Details',
          onPressed: onInfoPressed,
        ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight + 20);

  Widget _buildSubtitle(BuildContext context) {
    final bool isTyping = typingUsers != null && typingUsers!.isNotEmpty;
    if (isTyping) {
      return Padding(
        padding: const EdgeInsets.only(top: 2.0),
        child: Text(
          _buildTypingText(typingUsers!),
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.white.withAlpha((0.9 * 255).round()),
                fontStyle: FontStyle.italic,
              ),
          overflow: TextOverflow.ellipsis,
        ),
      );
    } else if (isOtherUserOnline) {
      return Padding(
        padding: const EdgeInsets.only(top: 2.0),
        child: Text(
          'Online',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.greenAccent, // Use a distinct color for online status
                fontWeight: FontWeight.bold,
              ),
          overflow: TextOverflow.ellipsis,
        ),
      );
    }
    return const SizedBox.shrink(); // No subtitle if not typing and not explicitly online
  }

  String _buildTypingText(List<String> names) {
    if (names.isEmpty) return '';
    if (names.length == 1) {
      return '${names[0]} is typing...';
    } else if (names.length == 2) {
      return '${names[0]} and ${names[1]} are typing...';
    } else {
      return 'Multiple users are typing...';
    }
  }
}
