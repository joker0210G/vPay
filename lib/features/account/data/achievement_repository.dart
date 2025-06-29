import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:vpay/shared/config/supabase_config.dart';
import 'package:vpay/shared/models/achievement_model.dart';
import 'package:vpay/shared/models/user_level_model.dart';
import 'package:vpay/features/account/data/achievement_notification_service.dart';
import 'package:vpay/features/account/presentation/widgets/achievement_animations.dart';

class AchievementRepository {
  final SupabaseClient _supabase = Supabase.instance.client;
  final AchievementNotificationService _notificationService = AchievementNotificationService();

  // Assumed table names - these should ideally be in SupabaseConfig or a dedicated constants file
  static const String _userAchievementsTable = 'user_achievements'; 
  // profilesTable is already in SupabaseConfig

  // Singleton pattern
  static final AchievementRepository _instance = AchievementRepository._internal();
  factory AchievementRepository() => _instance;
  AchievementRepository._internal();

  Future<void> initialize() async {
    await _notificationService.initialize();
  }

  Future<List<AchievementModel>> getUserAchievements(String userId) async {
    try {
      // Assumes a 'user_achievements' table with:
      // user_id (uuid), achievement_type (text), unlocked_at (timestamptz), progress (float8), is_unlocked (bool)
      final List<Map<String, dynamic>> data = await _supabase
          .from(_userAchievementsTable)
          .select()
          .eq('user_id', userId);

      // Errors will be caught by the try-catch block.
      // If specific Supabase error handling (like response.error) is needed,
      // .execute() would be required, and the return type would be PostgrestResponse.
      
      return (data).map((item) {
        final typeString = item['achievement_type'] as String;
        BadgeType badgeType;
        try {
          badgeType = BadgeType.values.firstWhere((e) => e.toString().split('.').last == typeString);
        } catch (e) {
          debugPrint("Error parsing BadgeType: $typeString. Defaulting to firstTask.");
          badgeType = BadgeType.firstTask; // Or handle as an error/skip
        }

        return AchievementModel(
          id: item['id']?.toString() ?? typeString, // Assuming 'id' column exists or use type as unique id
          type: badgeType,
          unlockedAt: item['unlocked_at'] != null ? DateTime.parse(item['unlocked_at']) : DateTime.now(), // Handle null unlocked_at
          isUnlocked: item['is_unlocked'] as bool? ?? false,
          progress: (item['progress'] as num?)?.toDouble() ?? 0.0,
        );
      }).toList();
    } catch (e) {
      throw Exception('Failed to fetch achievements: $e');
    }
  }

  Future<UserLevelModel?> getUserLevel(String userId) async {
    try {
      // Assumes 'profiles' table has 'current_xp' (int) and 'level' (int) columns
      // .single() will throw an error if no row or multiple rows are found.
      // If it completes without error, data is guaranteed to be non-null.
      final Map<String, dynamic> data = await _supabase
          .from(SupabaseConfig.profilesTable)
          .select('current_xp, level')
          .eq('user_id', userId) // Changed 'id' to 'user_id' for consistency
          .single(); 

      // Errors will be caught by the try-catch block.
      
      // Removed redundant userId.isEmpty check as it's not relevant for data validity from DB
      // Removed data == null check as .single() would throw if no record.

      final level = data['level'] as int? ?? 1;
      final currentXp = data['current_xp'] as int? ?? 0;
      
      return UserLevelModel(
        level: level,
        currentXp: currentXp,
        requiredXp: UserLevelModel.calculateRequiredXp(level),
        title: UserLevelModel.getTitleForLevel(level),
        perks: UserLevelModel.getPerksForLevel(level),
      );
    } catch (e) {
      debugPrint('Error fetching user level: $e');
      throw Exception('Failed to fetch user level: $e');
    }
  }

  Future<void> checkAndUnlockAchievement(
    String userId,
    BadgeType type,
    BuildContext context,
  ) async {
    try {
      // TODO: This method would involve:
      // 1. Checking if the achievement (userId, type) exists in _userAchievementsTable.
      // 2. If not, or if not unlocked, and conditions are met (e.g. progress >= 1.0), then:
      //    a. Insert or update the achievement in _userAchievementsTable (set is_unlocked = true, unlocked_at = now()).
      //    b. Show animation and notification as currently implemented.
      //    c. Call addXp.
      // For now, just keeping the UI part and XP call, removing mock data creation.

      // Placeholder for fetching/checking actual achievement from DB
      // final existingAchievement = await getSpecificAchievement(userId, type);

      // if (existingAchievement == null || !existingAchievement.isUnlocked) {
      //    await updateAchievementProgress(userId, type, 1.0, forceUnlock: true); // Example
          final achievementToDisplay = AchievementModel( // This would be built from DB data or after unlocking
            id: type.toString(), // Temporary ID
            type: type,
            unlockedAt: DateTime.now(),
            isUnlocked: true,
            progress: 1.0,
          );

          if (context.mounted) {
            showDialog(
              context: context,
              barrierDismissible: false,
              builder: (dialogContext) => Center(
                child: AchievementUnlockAnimation(
                  achievement: achievementToDisplay,
                  onComplete: () {
                    Navigator.of(dialogContext).pop();
                  },
                ),
              ),
            );
          }
          await _notificationService.showAchievementNotification(achievementToDisplay);
          await addXp(userId, type.xpReward);
      // }
    } catch (e) {
      throw Exception('Failed to check and unlock achievement: $e');
    }
  }

  Future<void> addXp(String userId, int amount) async {
    try {
      // TODO: Implement actual XP addition logic with Supabase:
      // 1. Fetch current XP and level from 'profiles' table.
      // 2. Calculate new XP and potentially new level.
      // 3. Update 'profiles' table with new_xp and new_level.
      // 4. If leveled up, show notification.
      
      final currentUserLevel = await getUserLevel(userId);
      if (currentUserLevel == null) {
        debugPrint("Cannot add XP: User level data not found for $userId");
        return;
      }
      
      int newXp = currentUserLevel.currentXp + amount;
      int newLevel = currentUserLevel.level;
      int requiredForNext = UserLevelModel.calculateRequiredXp(newLevel + 1);

      // Level up logic
      while (newXp >= requiredForNext) {
        newLevel++;
        newXp -= requiredForNext; // Or newXp = newXp - requiredForNext;
        if (newLevel > currentUserLevel.level) { // Check if it's a new level up event
             await _notificationService.showLevelUpNotification(
                newLevel,
                UserLevelModel.getPerksForLevel(newLevel), // Show all perks for new level
             );
        }
        requiredForNext = UserLevelModel.calculateRequiredXp(newLevel + 1);
      }
      
      // Update user's XP and level in Supabase
      await _supabase
          .from(SupabaseConfig.profilesTable)
          .update({'current_xp': newXp, 'level': newLevel})
          .eq('user_id', userId); // Changed 'id' to 'user_id' for consistency

      // Errors (like RLS violation or network issues) will be caught by the try-catch block.

    } catch (e) {
      throw Exception('Failed to add XP: $e');
    }
  }

  // Helper method to update achievement progress
  Future<void> updateAchievementProgress(
    String userId,
    BadgeType type,
    double progress, {
    bool forceUnlock = false, // If true, unlocks regardless of progress value (assumes 1.0)
  }) async {
    try {
      // TODO: Implement actual progress update logic with Supabase:
      // Upsert into _userAchievementsTable:
      // Set user_id, achievement_type, progress.
      // If progress >= 1.0 or forceUnlock, set is_unlocked = true, unlocked_at = now().
      final achievementTypeString = type.toString().split('.').last;
      final updates = {
        'user_id': userId,
        'achievement_type': achievementTypeString,
        'progress': progress,
        'updated_at': DateTime.now().toIso8601String(), // Assuming an 'updated_at' column
      };

      bool shouldBeUnlocked = forceUnlock || progress >= 1.0;
      if (shouldBeUnlocked) {
        updates['is_unlocked'] = true;
        updates['unlocked_at'] = DateTime.now().toIso8601String();
      }

      await _supabase
          .from(_userAchievementsTable)
          .upsert(updates, onConflict: 'user_id, achievement_type'); // Assumes PK is (user_id, achievement_type)

      // Errors will be caught by the try-catch block.

      if (shouldBeUnlocked) {
        // Optionally, trigger notification or other actions here if not handled by checkAndUnlockAchievement
        // For example, if this is called directly.
        // Be careful about duplicate notifications if called from checkAndUnlockAchievement.
      }
    } catch (e) {
      throw Exception('Failed to update achievement progress: $e');
    }
  }
}
