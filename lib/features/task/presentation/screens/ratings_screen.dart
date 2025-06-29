import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:vpay/features/auth/providers/auth_provider.dart';
import 'package:vpay/features/ratings/providers/ratings_provider.dart';
// import 'package:vpay/features/ratings/domain/rating_model.dart'; // Unused import

class RatingsScreen extends ConsumerWidget {
  const RatingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentUser = ref.watch(authProvider).user;

    if (currentUser == null) {
      return const Scaffold(
        body: Center(child: Text('Please log in to view your ratings.')),
      );
    }

    final ratingsAsync = ref.watch(myRatingsProvider(currentUser.id));

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Ratings'),
      ),
      body: ratingsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
        data: (ratings) {
          if (ratings.isEmpty) {
            return const Center(child: Text('No ratings yet.'));
          }
          return ListView.separated(
            itemCount: ratings.length,
            separatorBuilder: (_, __) => const Divider(),
            itemBuilder: (context, index) {
              final rating = ratings[index];
              // Assuming RatingModel has: score, feedback, task_id, fromUserId, createdAt
              // We might need to fetch task details and user details for names.
              // For now, using IDs or placeholders.
              return ListTile(
                leading: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: List.generate(
                    5,
                    (i) => Icon(
                      Icons.star,
                      color: i < rating.score ? Colors.amber : Colors.grey[300],
                      size: 20,
                    ),
                  ),
                ),
                title: Text('Task ID: ${rating.taskId}'), // Changed task_id to taskId
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(rating.feedback),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Text('From User ID: ${rating.fromUserId}', // Placeholder, ideally rater name
                            style: const TextStyle(fontSize: 12, color: Colors.grey)),
                        Padding(
                          padding: const EdgeInsets.only(left: 16.0),
                          child: Text('Date: ${DateFormat.yMd().format(rating.createdAt)}',
                              style: const TextStyle(fontSize: 12, color: Colors.grey)),
                        ),
                      ],
                    ),
                  ],
                ),
                isThreeLine: true,
              );
            },
          );
        },
      ),
    );
  }
}
