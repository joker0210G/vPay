import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vpay/features/account/presentation/providers/testimonial_provider.dart';
import 'package:vpay/shared/models/testimonial_model.dart';

class TestimonialsSection extends ConsumerWidget {
  final String userId;

  const TestimonialsSection({
    super.key,
    required this.userId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final testimonialAsync = ref.watch(userTestimonialsProvider(userId));
    final ratingAsync = ref.watch(userRatingProvider(userId));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Testimonials',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        ratingAsync.when(
          data: (rating) => _buildRatingBar(rating),
          loading: () => const CircularProgressIndicator(),
          error: (error, stack) => Text('Error: $error'),
        ),
        const SizedBox(height: 16),
        testimonialAsync.when(
          data: (testimonials) => _buildTestimonialsList(testimonials),
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, stack) => Text('Error: $error'),
        ),
      ],
    );
  }

  Widget _buildRatingBar(double rating) {
    return Row(
      children: [
        Row(
          children: List.generate(5, (index) {
            final isActive = index < rating.floor();
            final isHalf = index == rating.floor() && rating % 1 != 0;
            
            return Icon(
              isHalf ? Icons.star_half : (isActive ? Icons.star : Icons.star_border),
              color: isActive || isHalf ? Colors.amber : Colors.grey,
              size: 24,
            );
          }),
        ),
        const SizedBox(width: 8),
        Text(
          rating.toStringAsFixed(1),
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildTestimonialsList(List<TestimonialModel> testimonials) {
    if (testimonials.isEmpty) {
      return const Text('No testimonials yet.');
    }

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: testimonials.length,
      separatorBuilder: (_, __) => const Divider(),
      itemBuilder: (context, index) {
        final testimonial = testimonials[index];
        return _TestimonialCard(testimonial: testimonial);
      },
    );
  }
}

class _TestimonialCard extends StatelessWidget {
  final TestimonialModel testimonial;

  const _TestimonialCard({
    required this.testimonial,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: List.generate(5, (index) {
                return Icon(
                  index < testimonial.rating 
                      ? Icons.star 
                      : Icons.star_border,
                  color: Colors.amber,
                  size: 16,
                );
              }),
            ),
            const SizedBox(height: 8),
            Text(
              testimonial.comment,
              style: const TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 8),
            Text(
              'Task #${testimonial.taskId}', // Changed task_id to taskId
              // TODO: need to fetch task title from task repository
              style: TextStyle(
                color: Theme.of(context).colorScheme.primary,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }
}