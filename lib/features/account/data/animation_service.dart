class AnimationService {
  // Singleton pattern
  static final AnimationService _instance = AnimationService._internal();
  factory AnimationService() => _instance;
  AnimationService._internal();

  static const Map<String, String> animationPaths = {
    'night_owl': 'assets/animations/night_owl.json',
    'helper': 'assets/animations/helper.json',
    'speedster': 'assets/animations/speedster.json',
  };

  String? getAnimationPath(String animationId) {
    return animationPaths[animationId];
  }

  bool isAnimationAvailable(String animationId) {
    return animationPaths.containsKey(animationId);
  }
}