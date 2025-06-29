import 'package:vpay/features/ratings/domain/rating_model.dart';

class RatingsRepository {
  // Replace with your data source (Supabase, REST API, etc.)
  Future<List<RatingModel>> getUserRatings(String userId) async {
    // TODO: Replace with actual data fetching logic
    await Future.delayed(const Duration(milliseconds: 500));
    return [
      RatingModel(
        id: '1',
        taskId: 'task1', // Changed task_id to taskId
        fromUserId: 'userA',
        toUserId: userId,
        score: 5,
        feedback: 'Great work!',
        createdAt: DateTime.now().subtract(const Duration(days: 2)),
      ),
      RatingModel(
        id: '2',
        taskId: 'task2', // Changed task_id to taskId
        fromUserId: 'userB',
        toUserId: userId,
        score: 4,
        feedback: 'Very helpful.',
        createdAt: DateTime.now().subtract(const Duration(days: 5)),
      ),
    ];
  }
}
