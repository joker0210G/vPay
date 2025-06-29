import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:vpay/shared/models/achievement_model.dart';
import 'package:vpay/core/constants/colors.dart';

class AchievementNotificationService {
  // Firebase Integration
  // - Replace local notifications with Firebase Cloud Messaging
  // - Use Cloud Functions to trigger notifications
  // - Track notification engagement in Firebase Analytics
  // - Store notification history in Firestore
  // - Implement cross-device notification sync

  final FlutterLocalNotificationsPlugin _notificationsPlugin = FlutterLocalNotificationsPlugin();
  
  Future<void> initialize() async {
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings();
    
    const initializationSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );
    
    await _notificationsPlugin.initialize(initializationSettings);
  }

  Future<void> showAchievementNotification(AchievementModel achievement) async {
    final androidDetails = AndroidNotificationDetails(
      'achievements_channel',
      'Achievements',
      channelDescription: 'Notifications for achievement unlocks',
      importance: Importance.high,
      priority: Priority.high,
      ticker: 'Achievement Unlocked!',
      color: AppColors.primary,
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    final details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notificationsPlugin.show(
      achievement.hashCode,
      'Achievement Unlocked!',
      '${achievement.type.displayName}\n+${achievement.type.xpReward} XP',
      details,
    );
  }

  Future<void> showLevelUpNotification(int newLevel, List<String> unlockedPerks) async {
    final androidDetails = AndroidNotificationDetails(
      'level_up_channel',
      'Level Up',
      channelDescription: 'Notifications for level up events',
      importance: Importance.high,
      priority: Priority.high,
      ticker: 'Level Up!',
      color: AppColors.primary,
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    final details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    final perksText = unlockedPerks.isNotEmpty 
      ? '\nUnlocked: ${unlockedPerks.join(", ")}'
      : '';

    await _notificationsPlugin.show(
      newLevel.hashCode,
      'Level Up!',
      'You reached Level $newLevel!$perksText',
      details,
    );
  }

  //  Firebase Integration
  // - Use Firebase Cloud Messaging for cross-device notifications
  // - Track notification engagement in Firebase Analytics
  // - Store notification history in Firebase Realtime Database
}
