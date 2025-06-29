import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vpay/features/account/presentation/providers/skill_provider.dart';
import 'package:vpay/features/auth/providers/auth_provider.dart'; // Import authProvider
import 'package:vpay/shared/models/skill_model.dart';

class SkillsSection extends ConsumerWidget {
  final String userId;
  final bool isCurrentUser;

  const SkillsSection({
    super.key,
    required this.userId,
    this.isCurrentUser = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final skillsAsync = ref.watch(userSkillsProvider(userId));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Skills',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            if (isCurrentUser)
              TextButton(
                onPressed: () => _showAddSkillDialog(context, ref),
                child: const Text('Add Skill'),
              ),
          ],
        ),
        const SizedBox(height: 8),
        skillsAsync.when(
          data: (skills) => _buildSkillsList(context, ref, skills),
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, stack) => Text('Error: $error'),
        ),
      ],
    );
  }

  Widget _buildSkillsList(BuildContext context, WidgetRef ref, List<SkillModel> skills) {
    if (skills.isEmpty) {
      return const Text('No skills added yet.');
    }

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: skills.map((skill) => _SkillChip(
        skill: skill,
        canEndorse: !isCurrentUser,
        onEndorse: (skillId) {
          final currentActualUserId = ref.read(authProvider).user?.id;
          if (currentActualUserId != null) {
            ref.read(skillNotifierProvider.notifier).endorseSkill(
                  skillId,
                  currentActualUserId,
                );
          } else {
            // Optionally: Show a message if user ID is not available
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Cannot endorse: User not identified.')),
            );
          }
        },
      )).toList(),
    );
  }

  Future<void> _showAddSkillDialog(BuildContext context, WidgetRef ref) async {
    final controller = TextEditingController();

    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add New Skill'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            labelText: 'Skill Name',
            hintText: 'e.g., Flutter Development',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              if (controller.text.isNotEmpty) {
                ref.read(skillNotifierProvider.notifier).addSkill(
                      userId,
                      controller.text,
                    );
                Navigator.pop(context);
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }
}

class _SkillChip extends ConsumerWidget { // Changed to ConsumerWidget
  final SkillModel skill;
  final bool canEndorse;
  final Function(String) onEndorse;

  const _SkillChip({
    // super.key, // ConsumerWidget doesn't take key in constructor like this if not passing to super.
                 // It's fine to remove if not explicitly needed for other reasons.
                 // Or add super.key if this widget itself might need a key.
    required this.skill,
    required this.canEndorse,
    required this.onEndorse,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) { // Added WidgetRef ref
    final currentActualUserId = ref.watch(authProvider).user?.id;

    return ActionChip(
      label: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(skill.name),
          if (skill.endorsement_count > 0) ...[
            const SizedBox(width: 4),
            Text(
              '${skill.endorsement_count}',
              style: TextStyle(
                color: Theme.of(context).colorScheme.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ],
      ),
      onPressed: currentActualUserId != null &&
              canEndorse &&
              !skill.endorsedByUserIds.contains(currentActualUserId)
          ? () => onEndorse(skill.id)
          : null,
      backgroundColor: skill.endorsement_count > 0
          ? Theme.of(context).colorScheme.primaryContainer
          : null,
    );
  }
}