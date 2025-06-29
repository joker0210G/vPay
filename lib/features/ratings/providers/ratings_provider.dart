import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vpay/features/ratings/domain/rating_model.dart';
import 'package:vpay/features/ratings/data/ratings_repository.dart';

final ratingsRepositoryProvider = Provider<RatingsRepository>((ref) {
  return RatingsRepository();
});

final myRatingsProvider = FutureProvider.family<List<RatingModel>, String>((ref, userId) async {
  final repo = ref.read(ratingsRepositoryProvider);
  return repo.getUserRatings(userId);
});
