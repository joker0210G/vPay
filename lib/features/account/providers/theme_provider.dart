import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vpay/features/account/data/theme_repository.dart';
import 'package:vpay/shared/models/profile_theme_model.dart';

class ThemeNotifier extends StateNotifier<AsyncValue<ProfileTheme>> {
  final ThemeRepository _repository;
  final String userId;

  ThemeNotifier(this._repository, this.userId) : super(const AsyncValue.loading()) {
    _loadCurrentTheme();
  }

  Future<void> _loadCurrentTheme() async {
    try {
      state = const AsyncValue.loading();
      final themeId = await _repository.getCurrentTheme(userId);
      final themes = await _repository.getAvailableThemes(userId);
      final currentTheme = themes.firstWhere(
        (theme) => theme.id == (themeId ?? 'default'),
        orElse: () => themes.first,
      );
      state = AsyncValue.data(currentTheme);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> setTheme(String themeId) async {
    try {
      await _repository.setUserTheme(userId, themeId);
      await _loadCurrentTheme();
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<List<ProfileTheme>> getAvailableThemes() async {
    return await _repository.getAvailableThemes(userId);
  }
}

final themeProvider = StateNotifierProvider.family<ThemeNotifier, AsyncValue<ProfileTheme>, String>(
  (ref, userId) => ThemeNotifier(ThemeRepository(), userId),
);