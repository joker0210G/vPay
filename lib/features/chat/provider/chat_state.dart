// chat_state.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vpay/features/chat/domain/chat_message_model.dart';

/// Represents the local state of the chat UI.
class ChatState {
  final List<ChatMessage> messages;
  final bool isSending;
  final String? error;

  ChatState({
    required this.messages,
    this.isSending = false,
    this.error,
  });

  ChatState copyWith({
    List<ChatMessage>? messages,
    bool? isSending,
    String? error,
  }) {
    return ChatState(
      messages: messages ?? this.messages,
      isSending: isSending ?? this.isSending,
      error: error,
    );
  }
}

/// StateNotifier for managing chat UI state (optimistic updates, errors, etc).
class ChatNotifier extends StateNotifier<ChatState> {
  ChatNotifier() : super(ChatState(messages: []));

  void setMessages(List<ChatMessage> newMessages) {
    state = state.copyWith(messages: newMessages, error: null);
  }

  void setSending(bool sending) {
    state = state.copyWith(isSending: sending, error: null);
  }

  void setError(String error) {
    state = state.copyWith(error: error, isSending: false);
  }

  // Example: Optimistically add a message
  void addMessage(ChatMessage message) {
    state = state.copyWith(messages: [message, ...state.messages]);
  }

  // Add more mutation methods as needed
}

final chatNotifierProvider = StateNotifierProvider<ChatNotifier, ChatState>(
  (ref) => ChatNotifier(),
);

