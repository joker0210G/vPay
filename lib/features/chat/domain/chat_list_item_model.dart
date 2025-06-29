// chat_list_item_model.dart
import 'package:equatable/equatable.dart'; // Import Equatable
import 'package:vpay/features/task/domain/task_status.dart';
import 'package:vpay/features/task/domain/task_model.dart';


class ChatListItemModel extends Equatable { // Extend Equatable
  final String taskId; // Renamed from task_id
  final String taskTitle;
  final String lastMessage;
  final String participantName;
  final String? participantAvatarUrl;
  final DateTime lastActivity;
  final int unreadCount;
  final TaskStatus status;
  final TaskCategory category;
  final String roomId;
  final String? participantId; // Added participantId

  const ChatListItemModel({ // Make constructor const
    required this.taskId, // Renamed from task_id
    required this.taskTitle,
    required this.lastMessage,
    required this.participantName,
    this.participantAvatarUrl,
    required this.lastActivity,
    this.unreadCount = 0,
    required this.status,
    required this.category,
    required this.roomId,
    this.participantId, // Added participantId
  });

  @override // Add props for Equatable
  List<Object?> get props => [
        taskId, // Renamed from task_id
        taskTitle,
        lastMessage,
        participantName,
        participantAvatarUrl,
        lastActivity,
        unreadCount,
        status,
        category,
        roomId,
        participantId,
      ];

  ChatListItemModel copyWith({
    String? taskId, // Renamed from task_id
    String? taskTitle,
    String? lastMessage,
    String? participantName,
    String? participantAvatarUrl,
    DateTime? lastActivity,
    int? unreadCount,
    TaskStatus? status,
    TaskCategory? category,
    String? roomId,
    String? participantId,
  }) {
    return ChatListItemModel(
      taskId: taskId ?? this.taskId, // Renamed from task_id
      taskTitle: taskTitle ?? this.taskTitle,
      lastMessage: lastMessage ?? this.lastMessage,
      participantName: participantName ?? this.participantName,
      participantAvatarUrl: participantAvatarUrl ?? this.participantAvatarUrl,
      lastActivity: lastActivity ?? this.lastActivity,
      unreadCount: unreadCount ?? this.unreadCount,
      status: status ?? this.status,
      category: category ?? this.category,
      roomId: roomId ?? this.roomId,
      participantId: participantId ?? this.participantId,
    );
  }

  factory ChatListItemModel.fromJson(Map<String, dynamic> json) {
    String? lastMessageAt = json['last_message_at'];
    String? createdAt = json['created_at'];
    DateTime lastActivity;
    if (lastMessageAt != null && DateTime.tryParse(lastMessageAt) != null) {
      lastActivity = DateTime.parse(lastMessageAt);
    } else if (createdAt != null && DateTime.tryParse(createdAt) != null) {
      lastActivity = DateTime.parse(createdAt);
    } else {
      lastActivity = DateTime.now();
    }

    String statusString = (json['task_status'] ?? 'pending').toString();
    TaskStatus status = TaskStatus.values.firstWhere(
      (e) => e.toString().split('.').last.toLowerCase() == statusString.toLowerCase(),
      orElse: () => TaskStatus.pending,
    );

    String categoryString = (json['task_category'] ?? 'other').toString();
    TaskCategory category = TaskCategory.values.firstWhere(
      (e) => e.toString().split('.').last.toLowerCase() == categoryString.toLowerCase(),
      orElse: () => TaskCategory.other,
    );

    // Extract other participant's ID
    // This assumes 'participants' is a list in the JSON and we need the one not matching current user.
    // This logic is typically done in ChatRepository when constructing ChatListItemModel.
    // For now, we assume participant_id is directly available or pre-processed.
    // The prompt suggests `other?['user_id']` where `other` is already identified.
    // We will assume `json['participant_id']` is populated by the repository layer.
    // If `ChatRepository.getChatRooms` is correctly setting up `otherParticipantData`,
    // it should add `participant_id: otherParticipantData?['user_id']` to the map passed to this factory.
    // Let's assume `json['participant_id']` is directly provided for simplicity here.

    return ChatListItemModel(
      roomId: json['id'],
      participantId: json['participant_id'] as String?, // Added participantId
      taskId: json['task_id'], // Reads 'task_id' from JSON, assigns to taskId
      taskTitle: json['task_title'] ?? 'Untitled Task',
      lastMessage: json['last_message'] ?? '',
      participantName: json['participant_name'] ?? 'Unknown',
      participantAvatarUrl: json['participant_avatar_url'],
      lastActivity: lastActivity,
      unreadCount: json['unread_count'] ?? 0,
      status: status,
      category: category,
    );
  }

  Map<String, dynamic> toJson() { // Add toJson method
    return {
      'task_id': taskId, // Writes taskId to 'task_id' in JSON
      'task_title': taskTitle,
      'last_message': lastMessage,
      'participant_name': participantName,
      'participant_avatar_url': participantAvatarUrl,
      'last_message_at': lastActivity.toIso8601String(), // Assuming lastActivity should be stored as last_message_at or similar
      'unread_count': unreadCount,
      'task_status': status.toString().split('.').last,
      'task_category': category.toString().split('.').last,
      'id': roomId,
      'participant_id': participantId,
      // Note: 'created_at' from original fromJson logic is not a field,
      // so it's not included in toJson unless it's part of lastActivity handling.
      // For serialization, we'll primarily use lastActivity as the timestamp.
    };
  }
}
