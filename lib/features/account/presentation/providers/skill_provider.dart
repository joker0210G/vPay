import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vpay/features/account/data/skill_repository.dart';
import 'package:vpay/shared/models/skill_model.dart';

final skillRepositoryProvider = Provider((ref) => SkillRepository());

final userSkillsProvider = FutureProvider.family<List<SkillModel>, String>((ref, userId) async {
  final repository = ref.watch(skillRepositoryProvider);
  return repository.getUserSkills(userId);
});

final topSkillsProvider = FutureProvider.family<List<SkillModel>, String>((ref, userId) async {
  final repository = ref.watch(skillRepositoryProvider);
  return repository.getTopSkills(userId);
});

class SkillNotifier extends StateNotifier<AsyncValue<void>> {
  final SkillRepository _repository;

  SkillNotifier(this._repository) : super(const AsyncValue.data(null));

  Future<void> addSkill(String userId, String skillName) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _repository.addSkill(userId, skillName));
  }

  Future<void> endorseSkill(String skillId, String endorsedByUserId) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _repository.endorseSkill(skillId, endorsedByUserId));
  }
}

final skillNotifierProvider = StateNotifierProvider<SkillNotifier, AsyncValue<void>>((ref) {
  final repository = ref.watch(skillRepositoryProvider);
  return SkillNotifier(repository);
});