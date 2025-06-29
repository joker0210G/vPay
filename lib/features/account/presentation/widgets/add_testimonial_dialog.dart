import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vpay/features/account/presentation/providers/testimonial_provider.dart';

class AddTestimonialDialog extends ConsumerStatefulWidget {
  final String taskId;
  final String fromUserId;
  final String toUserId;

  const AddTestimonialDialog({
    super.key,
    required this.taskId,
    required this.fromUserId,
    required this.toUserId,
  });

  @override
  ConsumerState<AddTestimonialDialog> createState() => _AddTestimonialDialogState();
}

class _AddTestimonialDialogState extends ConsumerState<AddTestimonialDialog> {
  final _commentController = TextEditingController();
  double _rating = 5.0;

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Rate & Review'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(5, (index) {
                return IconButton(
                  onPressed: () {
                    setState(() {
                      _rating = index + 1.0;
                    });
                  },
                  icon: Icon(
                    index < _rating ? Icons.star : Icons.star_border,
                    color: Colors.amber,
                    size: 32,
                  ),
                );
              }),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _commentController,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'Your Review',
                hintText: 'Share your experience working with this person...',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () {
            if (_commentController.text.isNotEmpty) {
              ref.read(testimonialNotifierProvider.notifier).addTestimonial(
                    taskId: widget.taskId,
                    fromUserId: widget.fromUserId,
                    toUserId: widget.toUserId,
                    comment: _commentController.text,
                    rating: _rating,
                  );
              Navigator.pop(context);
            }
          },
          child: const Text('Submit'),
        ),
      ],
    );
  }
}

void showAddTestimonialDialog(
  BuildContext context, {
  required String taskId,
  required String fromUserId,
  required String toUserId,
}) {
  showDialog(
    context: context,
    builder: (context) => AddTestimonialDialog(
      taskId: taskId,
      fromUserId: fromUserId,
      toUserId: toUserId,
    ),
  );
}