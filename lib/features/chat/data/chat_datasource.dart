// chat_datasource.dart
import 'package:supabase_flutter/supabase_flutter.dart';

class ChatDatasource {
  final SupabaseClient client;

  ChatDatasource(this.client);

  Future<List<Map<String, dynamic>>> fetchChatRoomsForUser(String userId) async {
    return await client
        .from('chat_participants')
        .select('room_id')
        .eq('user_id', userId);
  }

  Future<List<Map<String, dynamic>>> fetchMessagesForRoom(String roomId) async {
    return await client
        .from('messages')
        .select('*')
        .eq('room_id', roomId)
        .order('created_at', ascending: false);
  }

  Future<void> insertMessage(Map<String, dynamic> data) async {
    await client.from('messages').insert(data);
  }

  Future<void> markMessagesAsRead(String roomId, String userId) async {
    await client
        .from('messages')
        .update({'is_read': true})
        .eq('room_id', roomId)
        .neq('sender_id', userId)
        .eq('is_read', false);
  }

  // Add more methods as needed for your backend schema
}
