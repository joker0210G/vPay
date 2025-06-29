// lib/features/chat/presentation/widget/message_bubble.dart
import 'package:flutter/material.dart';
import 'package:vpay/features/chat/domain/chat_message_model.dart';
import 'package:vpay/features/chat/provider/chat_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:cached_network_image/cached_network_image.dart';

class MessageBubble extends ConsumerWidget {
  final ChatMessage message;

  const MessageBubble({super.key, required this.message});

  bool _isImageUrl(String url) {
    final lowerUrl = url.toLowerCase();
    return lowerUrl.endsWith('.png') ||
        lowerUrl.endsWith('.jpg') ||
        lowerUrl.endsWith('.jpeg') ||
        lowerUrl.endsWith('.gif');
  }

  Future<void> _launchURL(String url) async {
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
    } else {
      debugPrint('Could not launch $url'); // Changed print to debugPrint
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentUserId = ref.watch(currentUserProvider)?.id;
    final bool isMe = message.senderId == currentUserId;
    final alignment = isMe ? Alignment.centerRight : Alignment.centerLeft;
    final bubbleColor = isMe ? Theme.of(context).colorScheme.primary : Theme.of(context).colorScheme.secondary;
    final textColor = isMe ? Theme.of(context).colorScheme.onPrimary : Theme.of(context).colorScheme.onSecondary;

    Widget messageContent;

    if (message.isFile) {
      if (_isImageUrl(message.content)) {
        messageContent = Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.6,
                maxHeight: MediaQuery.of(context).size.height * 0.3,
              ),
              child: CachedNetworkImage(
                imageUrl: message.content,
                placeholder: (context, url) => Container(
                  width: 50,
                  height: 50,
                  alignment: Alignment.center,
                  child: CircularProgressIndicator(strokeWidth: 2, color: textColor),
                ),
                errorWidget: (context, url, error) => Column(
                  children: [
                    Icon(Icons.error, color: textColor),
                    Text('Failed to load image', style: TextStyle(color: textColor, fontSize: 10)),
                  ],
                ),
                fit: BoxFit.cover,
              ),
            ),
          ],
        );
      } else {
        messageContent = InkWell(
          onTap: () => _launchURL(message.content),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.insert_drive_file, color: textColor, size: 20),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  message.content.split('/').last, // Show filename
                  style: TextStyle(color: textColor, decoration: TextDecoration.underline),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        );
      }
    } else {
      messageContent = Text(message.content, style: TextStyle(color: textColor));
    }

    // Read receipt logic
    Widget? readReceiptWidget;
    if (isMe) {
      if (message.isRead) { // Use model's camelCase
        readReceiptWidget = Icon(Icons.done_all, color: Colors.blueAccent, size: 16);
      } else {
        readReceiptWidget = Icon(Icons.done, color: textColor.withAlpha((0.7 * 255).round()), size: 16); // Changed withOpacity to withAlpha
      }
    }

    return Align(
      alignment: alignment,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 14),
        decoration: BoxDecoration(
          color: bubbleColor,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            messageContent,
            const SizedBox(height: 4),
            Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
              children: [
                Text(
                  '${message.createdAt.hour}:${message.createdAt.minute.toString().padLeft(2, '0')}',
                  style: TextStyle(color: textColor.withAlpha((0.7 * 255).round()), fontSize: 10), // Changed withOpacity to withAlpha
                ),
                if (readReceiptWidget != null) ...[
                  const SizedBox(width: 4),
                  readReceiptWidget,
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}
