import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vpay/features/account/providers/avatar_provider.dart';
import 'package:vpay/features/account/data/animation_service.dart';

class AnimatedAvatar extends ConsumerWidget {
  final String userId;
  final String? animationId;
  final double size;
  final VoidCallback? onTap;
  final bool showLockIfNotUnlocked;

  const AnimatedAvatar({
    super.key,
    required this.userId,
    this.animationId,
    this.size = 80,
    this.onTap,
    this.showLockIfNotUnlocked = true,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final avatarState = ref.watch(avatarProvider(userId));
    
    return avatarState.when(
      data: (state) {
        final isUnlocked = animationId == null || 
            state.unlockedAnimations.contains(animationId);
        
        return GestureDetector(
          onTap: isUnlocked ? onTap : null,
          child: Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: isUnlocked 
                    ? Theme.of(context).colorScheme.primary 
                    : Colors.grey,
                width: 2,
              ),
            ),
            child: ClipOval(
              child: Stack(
                fit: StackFit.expand,
                children: [
                  // Attempt to get the Lottie path if an animationId is provided
                  // animationId here is this.animationId (widget parameter)
                  // state.activeAnimation is the one selected by the user and stored in AvatarState
                  // For this widget, we use the passed 'animationId' parameter to determine if a Lottie should play.
                  // If 'this.animationId' is null, lottiePath will be null. 
                  // If 'this.animationId' is provided, we check if it's a valid key in AnimationService.
                  ...() {
                    final String? lottiePath = (animationId != null && AnimationService.animationPaths.containsKey(animationId))
                        ? AnimationService.animationPaths[animationId!]
                        : null;

                    if (lottiePath != null && lottiePath.isNotEmpty) {
                      // Display Lottie if path is valid
                      return [
                        Lottie.asset(
                          lottiePath,
                          fit: BoxFit.cover,
                          repeat: true,
                          animate: true,
                        ),
                      ];
                    } else if (state.avatarUrl != null && state.avatarUrl!.isNotEmpty) {
                      // Else, if avatar URL (from AvatarState for the user) exists, show CachedNetworkImage 
                      return [
                        CachedNetworkImage(
                          imageUrl: state.avatarUrl!,
                          fit: BoxFit.cover,
                          placeholder: (context, url) => const CircularProgressIndicator(),
                          errorWidget: (context, url, error) => const Icon(Icons.person),
                        ),
                      ];
                    } else {
                      // Else, show default person icon
                      return [
                        const Icon(Icons.person),
                      ];
                    }
                  }(),
                    
                  if (!isUnlocked && showLockIfNotUnlocked)
                    Container(
                      color: Colors.black45,
                      child: Center(
                        child: Icon(
                          Icons.lock,
                          color: Colors.white,
                          size: size * 0.4,
                        ).animate(
                          onPlay: (controller) => controller.repeat(),
                        )
                          .shake(duration: 1.seconds)
                          .then()
                          .fadeOut(duration: 500.milliseconds)
                          .fadeIn(duration: 500.milliseconds),
                      ),
                    ),
                ],
              ),
            ),
          ),
        );
      },
      loading: () => SizedBox(
        width: size,
        height: size,
        child: const CircularProgressIndicator(),
      ),
      error: (error, stack) => SizedBox(
        width: size,
        height: size,
        child: const Icon(Icons.error),
      ),
    );
  }
}