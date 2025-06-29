import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:vpay/shared/models/testimonial_model.dart';
// import 'package:vpay/features/account/data/achievement_repository.dart'; // For achievement updates
// import 'package:flutter_riverpod/flutter_riverpod.dart'; // If using Riverpod for providers

class TestimonialRepository {
  final _supabase = Supabase.instance.client;
  // Assuming 'testimonials' is the correct table name. Not found in migrations or SupabaseConfig.
  static const String _testimonialsTable = 'testimonials';
  static const String _testimonialSelectionString =
      'id, task_id, from_user_id, to_user_id, rating, comment, created_at';

  // Singleton pattern
  static final TestimonialRepository _instance = TestimonialRepository._internal();
  factory TestimonialRepository() => _instance;
  TestimonialRepository._internal();

  Future<List<TestimonialModel>> getUserTestimonials(String userId) async {
    try {
      final List<Map<String, dynamic>> data = await _supabase
          .from(_testimonialsTable)
          .select(_testimonialSelectionString)
          .eq('to_user_id', userId) // DB uses to_user_id
          .order('created_at', ascending: false); // DB uses created_at
      
      // Errors will be caught by the try-catch block
      return data.map((json) => TestimonialModel.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Failed to fetch user testimonials: $e');
    }
  }

  Future<double> getUserAverageRating(String userId) async {
    try {
      // TODO: For performance optimization on large datasets, consider creating a Supabase RPC function (pl/pgsql) to calculate the average rating directly in the database.
      final List<Map<String, dynamic>> data = await _supabase
          .from(_testimonialsTable)
          .select('rating')
          .eq('to_user_id', userId); // DB uses to_user_id

      // Errors will be caught by the try-catch block
      if (data.isEmpty) return 0.0;
      
      final totalRating = data.fold<double>(
        0.0,
        (sum, item) => sum + (item['rating'] as num).toDouble(),
      );
      
      return totalRating / data.length;
    } catch (e) {
      throw Exception('Failed to calculate average rating: $e');
    }
  }

  Future<List<TestimonialModel>> getRecentTestimonials(
    String userId, {
    int limit = 5,
  }) async {
    try {
      final List<Map<String, dynamic>> data = await _supabase
          .from(_testimonialsTable)
          .select(_testimonialSelectionString)
          .eq('to_user_id', userId) // DB uses to_user_id
          .order('created_at', ascending: false) // DB uses created_at
          .limit(limit);

      // Errors will be caught by the try-catch block
      return data.map((json) => TestimonialModel.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Failed to fetch recent testimonials: $e');
    }
  }

  Future<void> addTestimonial({
    required String taskId,
    required String fromUserId,
    required String toUserId,
    required String comment,
    required double rating,
    // WidgetRef? ref, // Optional: if you need to access providers like AchievementRepository
  }) async {
    try {
      // Check if user has already reviewed this task
      final Map<String, dynamic>? existingReviewData = await _supabase
          .from(_testimonialsTable)
          .select('id') // Only need to check for existence
          .eq('task_id', taskId)       // DB uses task_id
          .eq('from_user_id', fromUserId) // DB uses from_user_id
          .eq('to_user_id', toUserId)     // DB uses to_user_id
          .maybeSingle(); // Expect 0 or 1 record

      // Errors will be caught by the try-catch block (e.g., if table doesn't exist)
      // .maybeSingle() itself returns null if no record, or throws PostgrestException for other issues.

      if (existingReviewData != null) {
        throw Exception('You have already reviewed this task for this user');
      }

      // Add the testimonial
      await _supabase.from(_testimonialsTable).insert({
        'task_id': taskId,
        'from_user_id': fromUserId,
        'to_user_id': toUserId,
        'comment': comment,
        'rating': rating,
        'created_at': DateTime.now().toIso8601String(), // DB uses created_at
      });
      
      // Errors from insert will be caught by the try-catch block.
      // TODO: Update user's achievement progress.
      // This is currently client-side. For robustness and security,
      // consider moving this logic to a Supabase Edge Function (or a trigger if applicable)
      // that is called after a new testimonial is inserted.
      if (rating >= 4.5) { // Example: High rating achievement
        // final achievementRepo = ref?.read(achievementRepositoryProvider);
        // if (achievementRepo != null) {
        //   try {
        //     await achievementRepo.updateAchievementProgress(
        //       userId: toUserId, // The user who received the testimonial
        //       type: BadgeType.perfectScore, // Replace with an appropriate BadgeType e.g., BadgeType.highlyRated
        //       progress: 0.1, // Increment progress or set to 1.0 if unlock condition met
        //     );
        //   } catch (e) {
        //     // Log error, but don't let it fail the testimonial submission
        //     // print('Failed to update achievement progress: $e');
        //   }
        // }
      }
    } catch (e) {
      throw Exception('Failed to add testimonial: $e');
    }
  }

  Future<bool> canAddTestimonial(
    String taskId,
    String fromUserId,
    String toUserId,
  ) async {
    try {
      final Map<String, dynamic>? data = await _supabase
          .from(_testimonialsTable)
          .select('id') // Only need to check for existence
          .eq('task_id', taskId)       // DB uses task_id
          .eq('from_user_id', fromUserId) // DB uses from_user_id
          .eq('to_user_id', toUserId)     // DB uses to_user_id
          .maybeSingle(); // Expect 0 or 1 record
      
      // Errors will be caught by the try-catch block.
      // .maybeSingle() returns null if no record.
      return data == null; // Can add if no existing testimonial is found
    } catch (e) {
      // print('Exception in canAddTestimonial: $e');
      return false; // If any exception occurs, conservatively prevent review
    }
  }
}
