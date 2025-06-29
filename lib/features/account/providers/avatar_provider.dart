import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
//import 'package:vpay/features/account/data/animation_service.dart';

class AvatarState {
  final String? avatarUrl;
  final String? activeAnimation;
  final List<String> unlockedAnimations;

  const AvatarState({
    this.avatarUrl,
    this.activeAnimation,
    this.unlockedAnimations = const [],
  });

  AvatarState copyWith({
    String? avatarUrl,
    String? activeAnimation,
    List<String>? unlockedAnimations,
  }) {
    return AvatarState(
      avatarUrl: avatarUrl ?? this.avatarUrl,
      activeAnimation: activeAnimation ?? this.activeAnimation,
      unlockedAnimations: unlockedAnimations ?? this.unlockedAnimations,
    );
  }
}

class AvatarNotifier extends StateNotifier<AsyncValue<AvatarState>> {
  final String userId;
  final _supabase = Supabase.instance.client;
  // final _animationService = AnimationService(); // Removed as unused

  AvatarNotifier(this.userId) : super(const AsyncValue.loading()) {
    _loadAvatarState();
  }

  Future<void> _loadAvatarState() async {
    try {
      state = const AsyncValue.loading();

      // Get user preferences from Supabase
      final Map<String, dynamic>? responseData = await _supabase
          .from('user_preferences')
          .select('avatar_url, active_animation, unlocked_animations')
          .eq('user_id', userId)
          .maybeSingle();

      // Errors (like network issues or RLS violations if select is restricted) 
      // will be caught by the try-catch block.
      // .maybeSingle() returns null if no record is found, which is handled below.

      if (responseData == null) {
        // No preferences found, provide a default state
        state = AsyncValue.data(const AvatarState(unlockedAnimations: []));
      } else {
        state = AsyncValue.data(AvatarState(
          avatarUrl: responseData['avatar_url'] as String?,
          activeAnimation: responseData['active_animation'] as String?,
          unlockedAnimations: List<String>.from(responseData['unlocked_animations'] ?? []),
        ));
      }
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> setAvatarUrl(String url) async {
    debugPrint("AvatarNotifier.setAvatarUrl called with URL: $url for userId: $userId");
    try {
      final currentState = state.valueOrNull;
      if (currentState == null) {
        debugPrint("AvatarNotifier: Current state is null, cannot update avatarUrl.");
        return;
      }

      final updateData = {
        'user_id': userId,
        'avatar_url': url,
        'updated_at': DateTime.now().toIso8601String(),
      };
      debugPrint("AvatarNotifier: Updating Supabase user_preferences with data: $updateData");

      await _supabase
          .from('user_preferences')
          .upsert(updateData);
      debugPrint("AvatarNotifier: Supabase user_preferences update successful.");
      
      state = AsyncValue.data(currentState.copyWith(avatarUrl: url));
      debugPrint("AvatarNotifier state updated. New avatarUrl: ${state.valueOrNull?.avatarUrl}");
    } catch (e, st) {
      debugPrint("AvatarNotifier: Error in setAvatarUrl: $e");
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> setActiveAnimation(String? animationId) async {
    try {
      final currentState = state.valueOrNull;
      if (currentState == null) return;

      await _supabase
          .from('user_preferences')
          .upsert({
            'user_id': userId,
            'active_animation': animationId,
            'updated_at': DateTime.now().toIso8601String(),
          });
      
      state = AsyncValue.data(currentState.copyWith(activeAnimation: animationId));
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}

final avatarProvider = StateNotifierProvider.family<AvatarNotifier, AsyncValue<AvatarState>, String>(
  (ref, userId) => AvatarNotifier(userId),
);
