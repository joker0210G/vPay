import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:vpay/core/constants/themes.dart';
import 'package:vpay/shared/models/profile_theme_model.dart';

class ThemeRepository {
  final _supabase = Supabase.instance.client;

  // Singleton pattern
  static final ThemeRepository _instance = ThemeRepository._internal();
  factory ThemeRepository() => _instance;
  ThemeRepository._internal();

  // Predefined themes
  final List<ProfileTheme> _availableThemes = [
    ProfileTheme(
      id: 'default',
      name: 'Default',
      description: 'Classic VPay theme',
      theme: appTheme(),
      requirement: 'Default theme',
      isUnlocked: true,
    ),
    ProfileTheme(
      id: 'night_owl',
      name: 'Night Owl',
      description: 'Dark theme for night owls',
      theme: ThemeData.dark().copyWith(
        primaryColor: Colors.indigo,
        colorScheme: const ColorScheme.dark(
          primary: Colors.indigo,
          secondary: Colors.indigoAccent,
        ),
      ),
      requirement: 'Complete 10 night-time tasks',
    ),
    // Add more themes as needed
  ];

  Future<List<ProfileTheme>> getAvailableThemes(String userId) async {
    try {
      // Get user's unlocked themes from Supabase
      final data = await _supabase
          .from('user_themes')
          .select()
          .eq('user_id', userId);

      // Create a map of unlocked theme IDs
      final unlockedThemes = Map.fromEntries(
        data.map((item) => MapEntry(item['theme_id'] as String, true)),
      );

      // Update the unlocked status of available themes
      return _availableThemes.map((theme) {
        return ProfileTheme(
          id: theme.id,
          name: theme.name,
          description: theme.description,
          theme: theme.theme,
          requirement: theme.requirement,
          isUnlocked: unlockedThemes[theme.id] ?? theme.id == 'default',
        );
      }).toList();
    } catch (e) {
      throw Exception('Failed to fetch themes: $e');
    }
  }

  Future<void> unlockTheme(String userId, String themeId) async {
    try {
      await _supabase.from('user_themes').upsert({
        'user_id': userId,
        'theme_id': themeId,
        'unlocked_at': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      throw Exception('Failed to unlock theme: $e');
    }
  }

  Future<void> setUserTheme(String userId, String themeId) async {
    try {
      await _supabase.from('user_preferences').upsert({
        'user_id': userId,
        'active_theme_id': themeId,
        'updated_at': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      throw Exception('Failed to set user theme: $e');
    }
  }

  Future<String?> getCurrentTheme(String userId) async {
    try {
      final data = await _supabase
          .from('user_preferences')
          .select('active_theme_id')
          .eq('user_id', userId)
          .single();
      
      return data['active_theme_id'] as String?; // Removed unnecessary null-aware operator
    } catch (e) {
      return 'default'; // Return default theme if no preference is set
    }
  }
}