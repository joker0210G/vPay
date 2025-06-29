class UserLevelModel {
  /// Creates a UserLevelModel with the given parameters
  UserLevelModel({
    required this.level,
    required this.currentXp,
    required this.requiredXp,
    required this.title,
    required this.perks,
  });

  /// Creates a initial UserLevelModel
  factory UserLevelModel.initial() {
    return UserLevelModel(
      level: 1,
      currentXp: 0,
      requiredXp: 100,
      title: 'Basic',
      perks: ['Basic task access'],
    );
  }

  /// Creates a UserLevelModel from JSON
  factory UserLevelModel.fromJson(Map<String, dynamic> json) {
    return UserLevelModel(
      level: json['level'] ?? 1,
      currentXp: json['currentXp'] ?? 0,
      requiredXp: json['requiredXp'] ?? 100,
      title: json['title'] ?? 'Basic',
      perks: List<String>.from(json['perks'] ?? []),
    );
  }

  /// Converts this UserLevelModel to JSON
  Map<String, dynamic> toJson() {
    return {
      'level': level,
      'currentXp': currentXp,
      'requiredXp': requiredXp,
      'title': title,
      'perks': perks,
    };
  }

  /// Calculates the required XP for a given level
  static int calculateRequiredXp(int level) {
    // Basic formula: each level requires 50% more XP than the previous
    return (100 * (1.5 * (level - 1))).round();
  }

  /// Gets the title for a given level
  static String getTitleForLevel(int level) {
    if (level >= 10) return 'Expert';
    if (level >= 5) return 'Trusted Helper';
    return 'Basic';
  }

  /// Gets the perks for a given level
  static List<String> getPerksForLevel(int level) {
    List<String> perks = ['Basic task access'];
    if (level >= 5) {
      perks.addAll([
        'Priority support',
        'Custom profile themes',
      ]);
    }
    if (level >= 10) {
      perks.addAll([
        'Higher task visibility',
        'Early access to features',
      ]);
    }
    return perks;
  }

  final int level;
  final int currentXp;
  final int requiredXp;
  final String title;
  final List<String> perks;

  double get progressPercentage => currentXp / requiredXp;
}
