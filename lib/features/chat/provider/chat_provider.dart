// chat_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vpay/features/chat/data/chat_repository.dart';
import 'package:vpay/features/chat/domain/chat_list_item_model.dart';
import 'package:vpay/features/task/domain/task_status.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:vpay/features/chat/domain/chat_message_model.dart';

/// Provides access to the chat repository (Dependency Injection).
final chatRepositoryProvider = Provider<ChatRepository>((ref) {
  return ChatRepository(Supabase.instance.client);
});

/// Provides the current authenticated user.
final currentUserProvider = Provider<User?>((ref) {
  return Supabase.instance.client.auth.currentUser;
});

/// Streams all chat rooms for the current user.
/// Returns an empty stream if not authenticated.
final chatRoomsProvider = StreamProvider.autoDispose<List<ChatListItemModel>>((ref) {
  final repository = ref.watch(chatRepositoryProvider);
  final currentUser = ref.watch(currentUserProvider);

  if (currentUser == null) {
    return const Stream.empty();
  }
  return repository.getChatRooms(currentUser.id);
});

/// Streams all messages for a specific chat room.
final chatMessagesProvider = StreamProvider.autoDispose.family<List<ChatMessage>, String>((ref, roomId) {
  final repository = ref.watch(chatRepositoryProvider);
  return repository.getMessages(roomId);
});

/// Provides the unread message count for a specific chat room.
final unreadCountProvider = StreamProvider.autoDispose.family<int, String>((ref, roomId) {
  final repository = ref.watch(chatRepositoryProvider);
  final currentUser = ref.watch(currentUserProvider);

  if (currentUser == null) {
    return Stream.value(0); // Return a stream with a single value 0 if no user
  }
  return repository.getUnreadCountStream(roomId, currentUser.id);
});

/// Filters chat rooms by search query and tab selection.
/// This is a synchronous provider, as it filters already-fetched chat rooms.
final filteredChatRoomsProvider = Provider.autoDispose.family<List<ChatListItemModel>, ({String query, String tab})>((ref, params) {
  final chatRoomsAsync = ref.watch(chatRoomsProvider);

  // Handle loading/error/empty states gracefully.
  if (chatRoomsAsync.isLoading || chatRoomsAsync.hasError) {
    return <ChatListItemModel>[];
  }
  final chatRooms = chatRoomsAsync.value ?? <ChatListItemModel>[];

  // Tab filtering logic
  List<ChatListItemModel> filtered = chatRooms.where((chat) {
    switch (params.tab) {
      case 'Active':
        return chat.status == TaskStatus.inProgress ||
               chat.status == TaskStatus.awaitingReview;
      case 'Needs Action':
        return chat.status == TaskStatus.paymentDue ||
               chat.status == TaskStatus.pending ||
               chat.status == TaskStatus.disputed;
      case 'Archived':
        return chat.status == TaskStatus.completed ||
               chat.status == TaskStatus.cancelled;
      default:
        return true;
    }
  }).toList();

  // Search filtering logic (case-insensitive)
  if (params.query.trim().isNotEmpty) {
    final searchTerm = params.query.trim().toLowerCase();
    filtered = filtered.where((chat) =>
      chat.taskTitle.toLowerCase().contains(searchTerm) ||
      chat.participantName.toLowerCase().contains(searchTerm) ||
      chat.lastMessage.toLowerCase().contains(searchTerm)
    ).toList();
  }

  return filtered;
});
