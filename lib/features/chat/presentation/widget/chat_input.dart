// chat_input.dart
import 'package:flutter/material.dart';
import 'package:vpay/core/constants/colors.dart';

class ChatInput extends StatefulWidget {
  final ValueChanged<String> onSend;
  final bool isSending;
  final VoidCallback? onAttach;
  final Function(String)? onChanged; // Added onChanged

  const ChatInput({
    super.key,
    required this.onSend,
    this.isSending = false,
    this.onAttach,
    this.onChanged, // Added onChanged
  });

  @override
  State<ChatInput> createState() => _ChatInputState();
}

class _ChatInputState extends State<ChatInput> {
  final TextEditingController _controller = TextEditingController();

  void _handleSend() {
    final text = _controller.text.trim();
    if (text.isNotEmpty && !widget.isSending) {
      widget.onSend(text);
      _controller.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      child: Row(
        children: [
          if (widget.onAttach != null)
            IconButton(
              icon: Icon(Icons.attach_file, color: AppColors.primary),
              onPressed: widget.onAttach,
              tooltip: 'Attach file',
            ),
          Expanded(
            child: TextField(
              controller: _controller,
              textInputAction: TextInputAction.send,
              enabled: !widget.isSending,
              minLines: 1,
              maxLines: 4,
              decoration: InputDecoration(
                hintText: 'Type your message...',
                filled: true,
                fillColor: AppColors.primary.withAlpha((0.04 * 255).round()),
                contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: BorderSide.none,
                ),
              ),
              onChanged: widget.onChanged, // Pass to TextField
              onSubmitted: (_) => _handleSend(),
            ),
          ),
          const SizedBox(width: 8),
          IconButton(
            icon: Icon(Icons.send, color: AppColors.secondary),
            onPressed: widget.isSending ? null : _handleSend,
            tooltip: 'Send',
          ),
        ],
      ),
    );
  }
}
