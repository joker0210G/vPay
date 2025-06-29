// lib/features/chat/domain/chat_message_model.dart
class ChatMessage {
  final String id;
  final String roomId;
  final String senderId;
  final String content;
  final DateTime createdAt;
  final bool isRead; // Standardized to camelCase
  final bool isFile;

  ChatMessage({
    required this.id,
    required this.roomId,
    required this.senderId,
    required this.content,
    required this.createdAt,
    required this.isRead, // Standardized to camelCase
    this.isFile = false,
  });

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    DateTime createdAt;
    if (json['created_at'] != null && DateTime.tryParse(json['created_at']) != null) {
      createdAt = DateTime.parse(json['created_at']);
    } else {
      // Fallback or error handling if created_at is crucial and potentially missing/invalid
      createdAt = DateTime.now(); 
    }

    return ChatMessage(
      id: json['id'] as String, // Assuming id is always a string
      roomId: json['room_id'] as String,
      senderId: json['sender_id'] as String,
      content: json['content'] as String,
      createdAt: createdAt,
      isRead: json['is_read'] as bool? ?? false, // Map from snake_case from JSON
      isFile: json['is_file'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'room_id': roomId,
        'sender_id': senderId,
        'content': content,
        'created_at': createdAt.toIso8601String(),
        'is_read': isRead, // Map to snake_case for JSON/DB
        'is_file': isFile,
      };
}
