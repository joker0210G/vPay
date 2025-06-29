import 'package:flutter/material.dart';

/// Achievement Model representing user achievements
class AchievementModel {
  final String id;
  final BadgeType type;
  final DateTime unlockedAt;
  final bool isUnlocked;
  final double progress;

  AchievementModel({
    required this.id,
    required this.type,
    required this.unlockedAt,
    this.isUnlocked = false,
    this.progress = 0.0,
  });

  /// Create AchievementModel from JSON
  factory AchievementModel.fromJson(Map<String, dynamic> json) {
    return AchievementModel(
      id: json['id'],
      type: BadgeType.values.firstWhere((e) => e.toString() == json['type']),
      unlockedAt: DateTime.parse(json['unlockedAt']),
      isUnlocked: json['isUnlocked'] ?? false,
      progress: json['progress']?.toDouble() ?? 0.0,
    );
  }

  /// Convert AchievementModel to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type.toString(),
      'unlockedAt': unlockedAt.toIso8601String(),
      'isUnlocked': isUnlocked,
      'progress': progress,
    };
  }
}


/// Types of achievements with their metadata
enum BadgeType {
  firstTask,
  topEarner,
  helpingHand,
  verifiedPro,
  earlyAdopter,
  taskMaster,      // New: Complete 100 tasks
  quickResponder,  // New: Average response time under 5 minutes
  problemSolver,   // New: Resolved 5+ disputed tasks
  nightOwl,        // New: Complete tasks between 10 PM - 5 AM
  localLegend,     // New: Most tasks in your area
  multiTasker,     // New: Handle 3+ tasks simultaneously
  perfectScore,    // New: Maintain 5-star rating for a month
  speedster,       // New: Complete 5 tasks in a day
}

extension BadgeTypeExtension on BadgeType {
  /// Get display name for the badge type
  String get displayName {
    switch (this) {
      case BadgeType.firstTask:
        return 'First Task Completed';
      case BadgeType.topEarner:
        return 'Top Earner';
      case BadgeType.helpingHand:
        return 'Helping Hand';
      case BadgeType.verifiedPro:
        return 'Verified Pro';
      case BadgeType.earlyAdopter:
        return 'Early Adopter';
      case BadgeType.taskMaster:
        return 'Task Master';
      case BadgeType.quickResponder:
        return 'Quick Responder';
      case BadgeType.problemSolver:
        return 'Problem Solver';
      case BadgeType.nightOwl:
        return 'Night Owl';
      case BadgeType.localLegend:
        return 'Local Legend';
      case BadgeType.multiTasker:
        return 'Multi-Tasker';
      case BadgeType.perfectScore:
        return 'Perfect Score';
      case BadgeType.speedster:
        return 'Speedster';
    }
  }

  String get description {
    switch (this) {
      case BadgeType.firstTask:
        return 'Completed your first task';
      case BadgeType.topEarner:
        return 'Earned after completing 50+ tasks';
      case BadgeType.helpingHand:
        return 'Helped 10+ users';
      case BadgeType.verifiedPro:
        return 'Received 5+ positive reviews';
      case BadgeType.earlyAdopter:
        return 'Joined in the first 1000 users';
      case BadgeType.taskMaster:
        return 'Completed 100 tasks successfully';
      case BadgeType.quickResponder:
        return 'Maintained average response time under 5 minutes';
      case BadgeType.problemSolver:
        return 'Successfully resolved 5+ disputed tasks';
      case BadgeType.nightOwl:
        return 'Completed tasks during night hours';
      case BadgeType.localLegend:
        return 'Most active helper in your area';
      case BadgeType.multiTasker:
        return 'Handled 3+ tasks simultaneously';
      case BadgeType.perfectScore:
        return 'Maintained 5-star rating for a month';
      case BadgeType.speedster:
        return 'Completed 5 tasks in a single day';
    }
  }

  IconData get icon {
    switch (this) {
      case BadgeType.firstTask:
        return Icons.stars;
      case BadgeType.topEarner:
        return Icons.monetization_on;
      case BadgeType.helpingHand:
        return Icons.handshake;
      case BadgeType.verifiedPro:
        return Icons.verified;
      case BadgeType.earlyAdopter:
        return Icons.rocket_launch;
      case BadgeType.taskMaster:
        return Icons.workspace_premium;
      case BadgeType.quickResponder:
        return Icons.speed;
      case BadgeType.problemSolver:
        return Icons.psychology;
      case BadgeType.nightOwl:
        return Icons.nightlight_round;
      case BadgeType.localLegend:
        return Icons.location_city;
      case BadgeType.multiTasker:
        return Icons.developer_board;
      case BadgeType.perfectScore:
        return Icons.star_rate;
      case BadgeType.speedster:
        return Icons.flash_on;
    }
  }

  // New: Get XP reward for unlocking this badge
  int get xpReward {
    switch (this) {
      case BadgeType.firstTask:
        return 50;
      case BadgeType.topEarner:
        return 500;
      case BadgeType.helpingHand:
        return 200;
      case BadgeType.verifiedPro:
        return 300;
      case BadgeType.earlyAdopter:
        return 100;
      case BadgeType.taskMaster:
        return 1000;
      case BadgeType.quickResponder:
        return 150;
      case BadgeType.problemSolver:
        return 400;
      case BadgeType.nightOwl:
        return 200;
      case BadgeType.localLegend:
        return 800;
      case BadgeType.multiTasker:
        return 300;
      case BadgeType.perfectScore:
        return 600;
      case BadgeType.speedster:
        return 250;
    }
  }
}
