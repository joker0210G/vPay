import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vpay/features/account/data/testimonial_repository.dart';
import 'package:vpay/shared/models/testimonial_model.dart';

final testimonialRepositoryProvider = Provider((ref) => TestimonialRepository());

final userTestimonialsProvider = FutureProvider.family<List<TestimonialModel>, String>((ref, userId) async {
  final repository = ref.watch(testimonialRepositoryProvider);
  return repository.getUserTestimonials(userId);
});

final userRatingProvider = FutureProvider.family<double, String>((ref, userId) async {
  final repository = ref.watch(testimonialRepositoryProvider);
  return repository.getUserAverageRating(userId);
});

final recentTestimonialsProvider = FutureProvider.family<List<TestimonialModel>, String>((ref, userId) async {
  final repository = ref.watch(testimonialRepositoryProvider);
  return repository.getRecentTestimonials(userId);
});

class TestimonialNotifier extends StateNotifier<AsyncValue<void>> {
  final TestimonialRepository _repository;

  TestimonialNotifier(this._repository) : super(const AsyncValue.data(null));

  Future<void> addTestimonial({
    required String taskId,
    required String fromUserId,
    required String toUserId,
    required String comment,
    required double rating,
  }) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _repository.addTestimonial(
          taskId: taskId,
          fromUserId: fromUserId,
          toUserId: toUserId,
          comment: comment,
          rating: rating,
        ));
  }

  Future<bool> canAddTestimonial(String taskId, String fromUserId, String toUserId) async {
    return _repository.canAddTestimonial(taskId, fromUserId, toUserId);
  }
}

final testimonialNotifierProvider = StateNotifierProvider<TestimonialNotifier, AsyncValue<void>>((ref) {
  final repository = ref.watch(testimonialRepositoryProvider);
  return TestimonialNotifier(repository);
});