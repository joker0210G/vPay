class AnimatedAvatar {
  final String id;
  final String name;
  final String description;
  final String lottieAssetPath;
  final String requirement;
  final int requiredLevel;
  final bool isUnlocked;

  const AnimatedAvatar({
    required this.id,
    required this.name,
    required this.description,
    required this.lottieAssetPath,
    required this.requirement,
    required this.requiredLevel,
    this.isUnlocked = false,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'description': description,
    'lottieAssetPath': lottieAssetPath,
    'requirement': requirement,
    'requiredLevel': requiredLevel,
    'isUnlocked': isUnlocked,
  };

  factory AnimatedAvatar.fromJson(Map<String, dynamic> json) {
    return AnimatedAvatar(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      lottieAssetPath: json['lottieAssetPath'],
      requirement: json['requirement'],
      requiredLevel: json['requiredLevel'],
      isUnlocked: json['isUnlocked'] ?? false,
    );
  }
}