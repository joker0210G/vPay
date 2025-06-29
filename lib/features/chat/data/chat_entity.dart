// chat_entity.dart
// If you want to define a pure entity (no logic, just data):
class ChatEntity {
  final String id;
  final String content;
  final String senderId;
  final String roomId;
  final DateTime createdAt;
  final bool isRead;

  ChatEntity({
    required this.id,
    required this.content,
    required this.senderId,
    required this.roomId,
    required this.createdAt,
    required this.isRead,
  });
}
