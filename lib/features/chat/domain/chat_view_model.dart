// chat_view_model.dart
import 'package:vpay/features/chat/domain/chat_message_model.dart';

class ChatViewModel {
  final List<ChatMessage> messages;

  ChatViewModel(this.messages);

  // Example: Group messages by date for UI sections
  Map<String, List<ChatMessage>> get messagesGroupedByDate {
    final map = <String, List<ChatMessage>>{};
    for (final msg in messages) {
      final dateKey = "${msg.createdAt.year}-${msg.createdAt.month.toString().padLeft(2, '0')}-${msg.createdAt.day.toString().padLeft(2, '0')}";
      map.putIfAbsent(dateKey, () => []).add(msg);
    }
    return map;
  }

  // Add more UI-specific helpers as needed
}
