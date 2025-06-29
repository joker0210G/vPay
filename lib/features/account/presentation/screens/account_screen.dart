import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:vpay/core/constants/colors.dart';
import 'package:vpay/shared/models/achievement_model.dart';
import 'package:vpay/shared/models/user_level_model.dart';
import 'package:vpay/features/account/data/achievement_repository.dart';
import 'package:vpay/features/account/presentation/widgets/animated_avatar.dart'; // Import AnimatedAvatar
import 'package:vpay/features/account/presentation/widgets/skills_section.dart';
import 'package:vpay/features/account/presentation/widgets/testimonials_section.dart';
import 'package:vpay/features/auth/providers/auth_provider.dart' as auth;
// Removed import 'package:vpay/features/auth/providers/auth_state.dart';

class AccountScreen extends ConsumerStatefulWidget {
  const AccountScreen({super.key});

  @override
  ConsumerState<AccountScreen> createState() => _AccountScreenState();
}

class _AccountScreenState extends ConsumerState<AccountScreen> {
  final AchievementRepository _achievementRepository = AchievementRepository();
  UserLevelModel? _userLevel;
  List<AchievementModel> _achievements = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    if (!mounted) return;
    
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
final currentUser = ref.read(auth.authProvider).user;
      if (currentUser == null) return;

      final futures = await Future.wait([
        _achievementRepository.getUserLevel(currentUser.id),
        _achievementRepository.getUserAchievements(currentUser.id),
      ]);
      
      if (mounted) {
        setState(() {
          _userLevel = futures[0] as UserLevelModel?;
          _achievements = futures[1] as List<AchievementModel>;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _handleSignOut() async {
    final shouldSignOut = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sign Out'),
        content: const Text('Are you sure you want to sign out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Sign Out', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (shouldSignOut == true) {
      try {
await ref.read(auth.authProvider.notifier).signOut();
        if (mounted) {
          context.go('/auth');
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error signing out: $e')),
          );
        }
      }
    }
  }

  Widget _buildLevelProgress() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha((0.05 * 255).round()),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Level ${_userLevel?.level}',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                _userLevel?.title ?? '',
                style: TextStyle(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: _userLevel?.progressPercentage ?? 0,
              backgroundColor: Colors.grey[200],
              valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
              minHeight: 10,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '${_userLevel?.currentXp} / ${_userLevel?.requiredXp} XP',
            style: const TextStyle(
              color: Colors.grey,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Current Perks:',
            style: TextStyle(
              fontWeight: FontWeight.w500,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 8),
          ...List.generate(
            _userLevel?.perks.length ?? 0,
            (index) => Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Row(
                children: [
                  Icon(Icons.check_circle, color: AppColors.primary, size: 16),
                  const SizedBox(width: 8),
                  Text(_userLevel?.perks[index] ?? ''),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAchievements() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha((0.05 * 255).round()),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Achievements',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: _achievements.map((achievement) {
              return _buildAchievementBadge(achievement);
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildAchievementBadge(AchievementModel achievement) {
    return InkWell(
      onTap: () {
        _showAchievementDetails(achievement);
      },
      child: Stack(
        children: [
          Container(
            width: 80,
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: achievement.isUnlocked
                  ? AppColors.primary.withAlpha((0.1 * 255).round())
                  : Colors.grey[200],
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: achievement.isUnlocked
                    ? AppColors.primary
                    : Colors.grey[400]!,
                width: 1,
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  achievement.type.icon,
                  color: achievement.isUnlocked
                      ? AppColors.primary
                      : Colors.grey[400],
                  size: 32,
                ),
                const SizedBox(height: 4),
                Text(
                  achievement.type.displayName,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 10,
                    color: achievement.isUnlocked
                        ? AppColors.primary
                        : Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          // Progress indicator for locked achievements
          if (!achievement.isUnlocked && achievement.progress > 0)
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
                child: FractionallySizedBox(
                  alignment: Alignment.centerLeft,
                  widthFactor: achievement.progress,
                  child: Container(
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
              ),
            ),
          // Lock icon for locked achievements
          if (!achievement.isUnlocked)
            Positioned(
              top: 4,
              right: 4,
              child: Icon(
                Icons.lock,
                size: 12,
                color: Colors.grey[400],
              ),
            ),
        ],
      ),
    );
  }

  void _showAchievementDetails(AchievementModel achievement) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(achievement.type.displayName),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              achievement.type.icon,
              size: 48,
              color: AppColors.primary,
            ),
            const SizedBox(height: 16),
            Text(achievement.type.description),
            const SizedBox(height: 8),
            if (!achievement.isUnlocked && achievement.progress > 0)
              Column(
                children: [
                  const SizedBox(height: 8),
                  LinearProgressIndicator(
                    value: achievement.progress,
                    backgroundColor: Colors.grey[200],
                    valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${(achievement.progress * 100).toInt()}% Complete',
                    style: const TextStyle(
                      color: Colors.grey,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            if (achievement.isUnlocked)
              Column(
                children: [
                  const SizedBox(height: 8),
                  Text(
                    'Unlocked on ${achievement.unlockedAt.day}/${achievement.unlockedAt.month}/${achievement.unlockedAt.year}',
                    style: const TextStyle(
                      color: Colors.grey,
                      fontSize: 12,
                    ),
                  ),
                  Text(
                    '+${achievement.type.xpReward} XP',
                    style: const TextStyle(
                      color: Colors.green,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
final authState = ref.watch(auth.authProvider);
final currentUser = authState.user;

if (currentUser == null) {
  return const Scaffold(
        body: Center(child: Text('Please login to access your account')),
      );
    }

    return Scaffold(
      body: Column(
        children: [
          // Header Section
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(20),
                bottomRight: Radius.circular(20),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Profile',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.settings, color: Colors.white),
                      onPressed: () {
                        // Navigation to PersonalizationScreen:
                        // The '/personalization' route is the current destination for the settings icon.
                        // This is because a separate general '/settings' screen has not been implemented yet.
                        // PersonalizationScreen contains user-configurable settings like profile picture, theme, etc.
                        // TODO: Consider creating a dedicated '/settings' page if more general app settings are needed in the future.
                        context.go('/personalization');
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    AnimatedAvatar(
                      userId: currentUser.id,
                      size: 60, // Adjusted size
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            currentUser.username,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            currentUser.email,
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 14,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // Content
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : RefreshIndicator(
                    onRefresh: _loadUserData,
                    child: ListView(
                      padding: const EdgeInsets.all(16),
                      children: [
                        if (_error != null)
                          Text(
                            'Error: $_error',
                            style: const TextStyle(color: Colors.red),
                          ),
                        if (_userLevel != null) _buildLevelProgress(),
                        const SizedBox(height: 16),
                        _buildAchievements(),
                        const SizedBox(height: 16),
                        SkillsSection(
                          userId: currentUser.id,
                          isCurrentUser: true,
                        ),
                        const SizedBox(height: 16),
                        TestimonialsSection(
                          userId: currentUser.id,
                        ),
                        const SizedBox(height: 16),
                        Card(
                          child: Column(
                            children: [
                              ListTile(
                                leading: Icon(Icons.person, color: AppColors.primary),
                                title: const Text('Edit Profile'),
                                trailing: const Icon(Icons.chevron_right),
                                onTap: () {
                  debugPrint("Navigating to Edit Profile screen");
                  context.push('/edit-profile');
                                },
                              ),
                              ListTile(
                                leading: Icon(Icons.badge, color: AppColors.primary),
                                title: const Text('My Tasks'),
                                trailing: const Icon(Icons.chevron_right),
                                onTap: () {
                                  debugPrint("Navigating to My Tasks screen via push");
                                  context.push('/my-tasks');
                                },
                              ),
                              ListTile(
                                leading: Icon(Icons.star, color: AppColors.primary),
                                title: const Text('My Ratings'),
                                trailing: const Icon(Icons.chevron_right),
                                onTap: () {
                                  debugPrint("Navigating to My Ratings screen via push");
                                  context.push('/ratings');
                                },
                              ),
                              ListTile(
                                leading: Icon(Icons.palette, color: AppColors.primary),
                                title: const Text('Personalization'),
                                trailing: const Icon(Icons.chevron_right),
                                onTap: () {
                                  debugPrint("Navigating to Personalization screen via push");
                                  context.push('/personalization');
                                },
                              ),
                              ListTile(
                                leading: const Icon(Icons.logout, color: Colors.red),
                                title: const Text('Sign Out'),
                                onTap: _handleSignOut,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 32),
                      ],
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}
