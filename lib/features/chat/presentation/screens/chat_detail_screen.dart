import 'dart:async'; // For Timer and StreamSubscription
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';
import 'package:vpay/features/chat/domain/chat_list_item_model.dart';
import 'package:vpay/features/chat/provider/chat_provider.dart';
import 'package:vpay/features/chat/presentation/widget/chat_app_bar.dart';
import 'package:vpay/features/chat/presentation/widget/message_bubble.dart';
import 'package:vpay/features/chat/presentation/widget/chat_input.dart';
import 'package:go_router/go_router.dart'; // Import GoRouter

class ChatDetailScreen extends ConsumerStatefulWidget {
  final ChatListItemModel chatItem;

  const ChatDetailScreen({super.key, required this.chatItem});

  @override
  ConsumerState<ChatDetailScreen> createState() => _ChatDetailScreenState();
}

class _ChatDetailScreenState extends ConsumerState<ChatDetailScreen> {
  final ScrollController _scrollController = ScrollController();
  bool _isSending = false;
  List<String> _typingUsers = [];
  bool _isOtherUserOnline = false; // Added for presence
  StreamSubscription? _typingSubscription;
  ProviderSubscription? _messagesSubscription;
  StreamSubscription? _presenceSubscription; // Added for presence
  Timer? _typingDebouncer;

  @override
  void initState() {
    super.initState();
    final chatRepo = ref.read(chatRepositoryProvider);
    final currentUser = ref.read(currentUserProvider);
    if (currentUser != null) {
      _typingSubscription = chatRepo
          .getTypingUsers(widget.chatItem.roomId, currentUser.id)
          .listen((names) {
        if (mounted) {
          setState(() {
            _typingUsers = names;
          });
        }
      });

      // Mark messages as read when entering the screen or when new data comes in
      // Call it once initially
      chatRepo.markMessagesAsRead(widget.chatItem.roomId, currentUser.id);

      // And call it whenever messages are loaded/updated using ref.listenManual
      _messagesSubscription = ref.listenManual(
        chatMessagesProvider(widget.chatItem.roomId),
        (previous, next) {
          final messages = next.valueOrNull; // Get messages data, null if loading/error
          if (mounted && messages != null && messages.isNotEmpty) {
            // Ensure currentUser is accessible (it is, from the outer scope)
            // Ensure chatRepo is accessible (it is, from the outer scope)
            bool shouldMarkRead = messages.any((m) => m.senderId != currentUser.id && !m.isRead);
            if (shouldMarkRead) {
              chatRepo.markMessagesAsRead(widget.chatItem.roomId, currentUser.id);
            }
          }
        },
        onError: (error, stackTrace) {
          // print('Error in chatMessagesProvider listener: $error');
        }
      );

      // User Presence Tracking
      final String? otherParticipantId = widget.chatItem.participantId; // Assumes participantId is available

      if (otherParticipantId != null && otherParticipantId.isNotEmpty) {
        final userName = currentUser.userMetadata?['user_name'] as String? ?? currentUser.email ?? 'A User';
        chatRepo.trackUserPresenceInRoom(
            roomId: widget.chatItem.roomId,
            userId: currentUser.id,
            userName: userName);

        _presenceSubscription = chatRepo.getRoomPresenceStream(
            roomId: widget.chatItem.roomId,
            currentUserId: currentUser.id,
            otherParticipantUserId: otherParticipantId,
        ).listen((isOnline) {
            if (mounted) {
                setState(() {
                    _isOtherUserOnline = isOnline;
                });
            }
        });
      }
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _typingSubscription?.cancel();
    _typingDebouncer?.cancel();
    _messagesSubscription?.close(); // Dispose for ProviderSubscription
    _presenceSubscription?.cancel(); 
    ref.read(chatRepositoryProvider).untrackUserPresenceInRoom();
    super.dispose();
  }

  void _handleTyping(String text) {
    final chatRepo = ref.read(chatRepositoryProvider);
    final user = ref.read(currentUserProvider);
    // Attempt to get user_name from userMetadata, fallback to email, then to a placeholder
    final userName = user?.userMetadata?['user_name'] as String? ??
                     user?.email ??
                     'A User';

    if (user != null) {
      if (_typingDebouncer?.isActive ?? false) _typingDebouncer!.cancel();
      _typingDebouncer = Timer(const Duration(milliseconds: 500), () {
        // Send event only if there's text.
        // Consider sending a "stopped typing" event if text is empty and was previously not.
        // For this subtask, only send if text is not empty.
        if (text.isNotEmpty) {
          chatRepo.sendTypingEvent(
            roomId: widget.chatItem.roomId,
            userId: user.id,
            userName: userName,
          );
        }
      });
    }
  }

  Future<void> _sendMessage(String content) async {
    if (content.trim().isEmpty || _isSending) return;

    setState(() => _isSending = true);

    try {
      final repository = ref.read(chatRepositoryProvider);
      final user = ref.read(currentUserProvider);
      if (user == null) throw Exception("User not authenticated.");

      await repository.sendMessage(
        roomId: widget.chatItem.roomId,
        content: content,
        senderId: user.id,
      );

      // Optionally scroll to bottom after sending
      if (_scrollController.hasClients) {
        await _scrollController.animateTo(
          0.0,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    } catch (e, stack) {
      debugPrint('EYE: Error sending message: $e\n$stack');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to send message: ${e.toString()}')),
        );
      }
    } finally {
      if (mounted) setState(() => _isSending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final messagesAsync = ref.watch(chatMessagesProvider(widget.chatItem.roomId));
    // ChatAppBar's preferredSize is internally managed now (kToolbarHeight + 20)

    return Scaffold(
      appBar: ChatAppBar(
        participantName: widget.chatItem.participantName,
        taskTitle: widget.chatItem.taskTitle,
        participantAvatarUrl: widget.chatItem.participantAvatarUrl,
        typingUsers: _typingUsers,
        isOtherUserOnline: _isOtherUserOnline, // Pass online status
        onInfoPressed: () {
            if (widget.chatItem.taskId.isNotEmpty) {
              context.go('/task-details/${widget.chatItem.taskId}');
            } else {
              // Optionally, handle the case where task_id is empty or null
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Task ID is not available.')),
              );
            }
          },
        ), // Removed potential extra semicolon here if any
      body: SafeArea( // Ensured body is correctly assigned
        child: Column(
          children: [
            Expanded(
              child: messagesAsync.when(
                data: (messages) {
                  if (messages.isEmpty) {
                    return Center(
                      child: Text(
                        'No messages yet. Say hello!',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    );
                  }
                  return ListView.builder(
                    controller: _scrollController,
                    reverse: true,
                    padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                    itemCount: messages.length,
                    itemBuilder: (context, index) {
                      final message = messages[index];
                      return MessageBubble(message: message); // <-- Use your bubble widget!
                    },
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, stack) {
                  debugPrint('EYE: Error loading messages: $e\n$stack');
                  return Center(
                    child: Text(
                      'Failed to load messages.',
                      style: TextStyle(color: Theme.of(context).colorScheme.error),
                    ),
                  );
                },
              ),
            ),
            ChatInput(
              onSend: _sendMessage,
              isSending: _isSending,
              onChanged: _handleTyping, // Pass _handleTyping
              onAttach: () async {
                // Handle file attachment logic here
                final pickedFile = await FilePicker.platform.pickFiles(
                  type: FileType.any,
                );
                if (pickedFile != null) {
                  final file = File(pickedFile.files.first.path!);
                  // Upload the file to Supabase Storage
                  final repository = ref.read(chatRepositoryProvider);
                  final user = ref.read(currentUserProvider);
                  if (user == null) throw Exception("User not authenticated.");
                  final fileUrl = await repository.uploadFile(
                    file: file,
                    roomId: widget.chatItem.roomId,
                    userId: user.id,
                  );
                  // Send the file message
                  await repository.sendMessage(
                    roomId: widget.chatItem.roomId,
                    content: fileUrl,
                    senderId: user.id,
                    isFile: true,
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}

// Note: The conceptual chatAppBarProviderFamily was removed as it's not needed.
// ChatAppBar now manages its own preferredSize correctly.
