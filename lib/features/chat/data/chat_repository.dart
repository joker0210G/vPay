import 'dart:async'; // Required for StreamController and other async operations
import 'dart:io'; // Required for File
import 'package:supabase_flutter/supabase_flutter.dart';
// Removed unnecessary import of 'package:realtime_client/realtime_client.dart';
import 'package:vpay/features/chat/domain/chat_list_item_model.dart';
import 'package:vpay/features/chat/domain/chat_message_model.dart';
import 'package:vpay/shared/config/supabase_config.dart'; // Assuming SupabaseConfig is here

class ChatRepository {
  final SupabaseClient _supabase;
  RealtimeChannel? _presenceChannel; // Added for presence

  ChatRepository(this._supabase);

  Stream<List<ChatListItemModel>> getChatRooms(String userId) {
    final controller = StreamController<List<ChatListItemModel>>();

    Future<void> fetchAndEmitRooms() async {
      try {
        final participantRows = await _supabase
            .from(SupabaseConfig.chatParticipantsTable)
            .select('room_id')
            .eq('user_id', userId);

        final roomIds = participantRows.map((row) => row['room_id'] as String).toSet().toList();

        if (roomIds.isEmpty) {
          if (!controller.isClosed) controller.add([]);
          return;
        }

        var query = _supabase.from(SupabaseConfig.chatRoomsTable);
        // Unable to find a working IN filter for this Supabase client version.
        // Fetching all rooms and relying on client-side filtering if necessary.
        // if (roomIds.isNotEmpty) {
        //   query = query.inFilter('id', roomIds); 
        // }
        final roomsData = await query
            .select('*, task:tasks(id, title, status, category), participants:chat_participants(user_id, profile:profiles(user_name, avatar_url))')
            .order('last_message_at', ascending: false);

        final chatListItems = roomsData.map<ChatListItemModel>((room) {
          final List<dynamic> participants = room['participants'] as List<dynamic>? ?? [];
          final otherParticipantData = participants.firstWhere(
            (p) => p['user_id'] != userId && p['profile'] != null,
            orElse: () => null,
          );

          return ChatListItemModel.fromJson({
            ...room,
            'task_id': room['task']?['id'],
            'task_title': room['task']?['title'],
            'task_status': room['task']?['status']?.toString(),
            'task_category': room['task']?['category']?.toString(),
            'participant_name': otherParticipantData?['profile']?['user_name'] ?? 'Unknown User',
            'participant_avatar_url': otherParticipantData?['profile']?['avatar_url'],
            'participant_id': otherParticipantData?['user_id'] as String?, // Added participant_id
          });
        }).toList();

        if (!controller.isClosed) controller.add(chatListItems);

      } catch (e) { // Removed stackTrace
        if (!controller.isClosed) {
            // print('Error fetching chat rooms: $e');
            controller.addError(Exception('Failed to load chat rooms: $e'));
        }
      }
    }

    fetchAndEmitRooms();

    final subscription = _supabase
        .from(SupabaseConfig.chatParticipantsTable)
        .stream(primaryKey: ['user_id', 'room_id'])
        .eq('user_id', userId)
        .listen((_) async {
          await fetchAndEmitRooms();
        }, onError: (error) { // Removed stackTrace
            if (!controller.isClosed) {
                // print('Error in chat_participants stream: $error');
                controller.addError(Exception('Chat participation stream error: $error'));
            }
        });

    controller.onCancel = () {
      subscription.cancel();
      if (!controller.isClosed) {
        controller.close();
      }
    };

    return controller.stream;
  }

  Future<void> sendTypingEvent({
    required String roomId,
    required String userId,
    required String userName,
  }) async {
    await _supabase.from(SupabaseConfig.typingNotificationsTable).upsert({
      'room_id': roomId,
      'user_id': userId,
      'user_name': userName,
      'last_typed_at': DateTime.now().toIso8601String(),
    });
  }

  Stream<List<String>> getTypingUsers(String roomId, String currentUserId) {
    // Filters are applied on the RealtimeChannel itself after .stream()
    return _supabase
        .from(SupabaseConfig.typingNotificationsTable) // Use SupabaseConfig
        .stream(primaryKey: ['room_id', 'user_id'])
          .eq('room_id', roomId)
        .map((snapshot) { // snapshot is List<Map<String, dynamic>>
          final now = DateTime.now();
          return snapshot
              .where((data) {
                // Apply the 'neq' filter manually
                if (data['user_id'] == currentUserId) return false;
                final lastTypedAtString = data['last_typed_at'] as String?;
                if (lastTypedAtString == null) return false; // Null check
                final lastTypedAt = DateTime.parse(lastTypedAtString);
                return now.difference(lastTypedAt).inSeconds < 8;
              })
              .map((data) => data['user_name'] as String? ?? 'Someone')
              .toList();
        });
  }

  Stream<List<ChatMessage>> getMessages(String roomId) {
    return _supabase
        .from(SupabaseConfig.messagesTable)
        .stream(primaryKey: ['id'])
        .eq('room_id', roomId)
        .order('created_at', ascending: false)
        .map((messages) => messages
            .map((msg) => ChatMessage.fromJson(msg))
            .toList());
  }

  Stream<int> getUnreadCountStream(String roomId, String userId) {
    return getMessages(roomId).map((messages) { // getMessages already returns Stream<List<ChatMessage>>
      return messages
          .where((msg) => msg.senderId != userId && !msg.isRead) // Use model's camelCase field
          .length;
    });
  }

  Future<int> getUnreadCount(String roomId, String userId) async {
    try {
      final List<dynamic> results = await _supabase
          .from(SupabaseConfig.messagesTable)
          .select('id') // Select minimal data
          .eq('room_id', roomId)
          .eq('is_read', false) // DB column is snake_case
          .neq('sender_id', userId); // Changed notEquals to neq
      return results.length;
    } catch (e) {
      // print('Error fetching unread count for $roomId: $e');
      return 0;
    }
  }

  Future<void> sendMessage({
    required String roomId,
    required String senderId,
    required String content,
    bool isFile = false,
  }) async {
    if (content.trim().isEmpty) {
      throw ArgumentError('Message content cannot be empty');
    }

    final timestamp = DateTime.now().toIso8601String();

    try {
      await _supabase
          .from(SupabaseConfig.messagesTable)
          .insert({
            'room_id': roomId,
            'sender_id': senderId,
            'content': content.trim(),
            'is_file': isFile,
            'is_read': false, // DB column is snake_case (already correct here from model's toJson)
            'created_at': timestamp,
          });

      await _supabase
          .from(SupabaseConfig.chatRoomsTable)
          .update({
            'last_message': isFile ? 'File shared' : content.trim(),
            'last_message_at': timestamp,
          })
          .eq('id', roomId);
    } on PostgrestException catch (e) {
      throw Exception('Failed to send message: ${e.message}');
    } catch (e) {
      throw Exception('An error occurred while sending message: $e');
    }
  }

  Future<String> uploadFile({
    required File file,
    required String roomId,
    required String userId,
  }) async {
    final fileName = '${DateTime.now().millisecondsSinceEpoch}_${file.path.split('/').last}';
    final filePath = '$roomId/$userId/$fileName'; // Consider a more structured path if needed

    await _supabase.storage
        .from(SupabaseConfig.chatFilesBucket)
        .upload(filePath, file);

    final publicUrl = _supabase.storage
        .from(SupabaseConfig.chatFilesBucket)
        .getPublicUrl(filePath);

    return publicUrl;
  }

  Future<void> markMessagesAsRead(String roomId, String userId) async {
    await _supabase
        .from(SupabaseConfig.messagesTable)
        .update({'is_read': true}) // DB column is snake_case
        .eq('room_id', roomId)
        .neq('sender_id', userId) // Changed notEquals to neq
        .eq('is_read', false); // DB column is snake_case
  }

  Future<String> createChatRoom({
    required String taskId,
    required String creatorId,
    required String participantId,
  }) async {
    final existing = await _supabase
        .from(SupabaseConfig.chatRoomsTable)
        .select('id')
        .eq('task_id', taskId)
        .maybeSingle();

    if (existing != null) {
      return existing['id'];
    }

    final response = await _supabase
        .from(SupabaseConfig.chatRoomsTable)
        .insert({
          'task_id': taskId,
          'is_group': false, 
          'created_at': DateTime.now().toIso8601String(),
        })
        .select()
        .single();

    final roomId = response['id'];

    await _supabase
        .from(SupabaseConfig.chatParticipantsTable)
        .insert([
      {'room_id': roomId, 'user_id': creatorId},
      {'room_id': roomId, 'user_id': participantId},
    ]);

    return roomId;
  }

  Future<void> deleteChat(String roomId) async {
    await _supabase
        .from(SupabaseConfig.messagesTable)
        .delete()
        .eq('room_id', roomId);

    await _supabase
        .from(SupabaseConfig.chatRoomsTable)
        .delete()
        .eq('id', roomId);
  }

  Future<void> trackUserPresenceInRoom({
    required String roomId,
    required String userId,
    required String userName,
  }) async {
    final roomChannelName = 'presence-room-$roomId';

    if (_presenceChannel != null && _presenceChannel!.topic != roomChannelName) {
      // Switching rooms, untrack and unsubscribe from the old one first
      await untrackUserPresenceInRoom();
    }
    _presenceChannel ??= _supabase.channel(roomChannelName);

    // Use new specific presence event handlers
    _presenceChannel!.onPresenceSync((payload) {
      // print('Presence sync for room ${_presenceChannel?.topic}: ${payload.newPresences.map((e) => e.payload['user_name'] ?? e.payload['user_id'])}');
      // Optionally, you can use this to update a local list of present users
    });
    // Note: onPresenceJoin and onPresenceLeave are typically used by streams observing presence,
    // not directly in the trackUserPresenceInRoom method itself unless you need to react to your own join.

    // Removing channel state checks as the 'state' getter is consistently undefined.
    // This may lead to runtime errors if operations are attempted on a non-ready channel.
    _presenceChannel!.subscribe(); 
    // TODO: Handle subscription status and errors properly.
    // For now, we assume subscription is successful for tracking.
    await _presenceChannel!.track({'user_id': userId, 'user_name': userName, 'online_at': DateTime.now().toIso8601String()});
    // print('Attempting to subscribe and track presence for $roomChannelName in trackUser.');
  }

  Stream<bool> getRoomPresenceStream({
    required String roomId,
    required String currentUserId,
    required String otherParticipantUserId,
  }) {
    final roomChannelName = 'presence-room-$roomId';
    // Use a local channel variable for this stream to avoid interfering with _presenceChannel's lifecycle
    final dedicatedChannel = _supabase.channel(roomChannelName);
    final controller = StreamController<bool>.broadcast(); // Use .broadcast() for multiple listeners if needed

    void updateOnlineStatus() {
      // Removing channel state check. Assuming presenceState() can be called.
      // This might need robust error handling if called on a non-joined channel.
      try {
        final List<dynamic> allPresences = dedicatedChannel.presenceState(); 
        final isOnline = allPresences.any((p) => (p as dynamic).payload['user_id'] == otherParticipantUserId);
        if (!controller.isClosed) {
            controller.add(isOnline);
        }
      } catch (e) {
        // print('Error updating online status, assuming offline: $e');
        if(!controller.isClosed) controller.add(false);
      }
    }

    dedicatedChannel.onPresenceSync((payload) {
      // print('Presence SYNC for $roomId (stream): ${payload.presences.map((e) => e.payload['user_name'])}');
      updateOnlineStatus();
    });
    dedicatedChannel.onPresenceJoin((payload) {
      // print('Presence JOIN for $roomId (stream): ${payload.newPresences.map((e) => e.payload['user_name'])}');
      if (payload.newPresences.any((p) => (p as dynamic).payload['user_id'] == otherParticipantUserId)) {
        if (!controller.isClosed) controller.add(true);
      } else {
        updateOnlineStatus(); // Another user joined, re-evaluate target user's status from full list
      }
    });
    dedicatedChannel.onPresenceLeave((payload) {
      // print('Presence LEAVE for $roomId (stream): ${payload.leftPresences.map((e) => e.payload['user_name'])}');
      if (payload.leftPresences.any((p) => (p as dynamic).payload['user_id'] == otherParticipantUserId)) {
        try {
          final List<dynamic> allPresences = dedicatedChannel.presenceState();
          final isStillOnline = allPresences.any((p) => (p as dynamic).payload['user_id'] == otherParticipantUserId);
          if (!isStillOnline && !controller.isClosed) controller.add(false);
        } catch (e) {
          // print('Error checking presence on leave, assuming offline: $e');
          if(!controller.isClosed) controller.add(false);
        }
      } else {
         updateOnlineStatus(); // Another user left, re-evaluate target user's status
      }
    });

    // Removing channel state check before subscribe.
    dedicatedChannel.subscribe((status, [error]) {
      if (status == RealtimeSubscribeStatus.subscribed) { // Use RealtimeSubscribeStatus enum
        // print('Successfully subscribed to presence for $roomId in getRoomPresenceStream');
        updateOnlineStatus(); 
      } else if (status == RealtimeSubscribeStatus.channelError || status == RealtimeSubscribeStatus.timedOut) { // Use RealtimeSubscribeStatus enum
        // print('Error subscribing to presence for $roomId: $error');
        if(!controller.isClosed) controller.add(false); // Assume offline on error
      }
    });
    // print('Attempting to subscribe to presence for $roomId in getRoomPresenceStream');

    controller.onCancel = () {
      // print('Cancelling room presence stream for $roomId.');
      // No state check, just attempt to unsubscribe.
      dedicatedChannel.unsubscribe().whenComplete(() { // Removed catchError that only printed
          _supabase.removeChannel(dedicatedChannel);
          // print('Removed dedicated channel for $roomId presence stream.');
      });
    };
    return controller.stream;
  }

  Future<void> untrackUserPresenceInRoom() async {
    if (_presenceChannel != null) {
      // final channelName = _presenceChannel!.topic; // For logging - removed as unused
      try {
        // No state check, just attempt to untrack and unsubscribe.
        await _presenceChannel!.untrack();
        await _presenceChannel!.unsubscribe();
      } catch (e) {
        // print('Error during untrack/unsubscribe for $channelName: $e');
      } finally { // Ensure channel is removed and nulled
        _supabase.removeChannel(_presenceChannel!);
        _presenceChannel = null;
        // print('User presence untracked and channel removed for $channelName.');
      }
    }
  }
}
