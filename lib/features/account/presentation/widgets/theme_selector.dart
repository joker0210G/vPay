import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vpay/features/account/providers/theme_provider.dart';
import 'package:vpay/shared/models/profile_theme_model.dart';
import 'package:flutter_animate/flutter_animate.dart';

class ThemeSelector extends ConsumerWidget {
  final String userId;

  const ThemeSelector({super.key, required this.userId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentTheme = ref.watch(themeProvider(userId));

    return FutureBuilder<List<ProfileTheme>>(
      future: ref.read(themeProvider(userId).notifier).getAvailableThemes(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return const Center(child: Text('Error loading themes'));
        }

        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final themes = snapshot.data!;

        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 1.5,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
          ),
          itemCount: themes.length,
          itemBuilder: (context, index) {
            final theme = themes[index];
            return ThemePreviewCard(
              theme: theme,
              isSelected: currentTheme.value?.id == theme.id,
              onTap: () {
                if (theme.isUnlocked) {
                  ref.read(themeProvider(userId).notifier).setTheme(theme.id);
                } else {
                  _showUnlockRequirements(context, theme);
                }
              },
            );
          },
        );
      },
    );
  }

  void _showUnlockRequirements(BuildContext context, ProfileTheme theme) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Theme Locked'),
        content: Text('To unlock this theme:\n${theme.requirement}'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}

class ThemePreviewCard extends StatelessWidget {
  final ProfileTheme theme;
  final bool isSelected;
  final VoidCallback onTap;

  const ThemePreviewCard({
    super.key,
    required this.theme,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: theme.theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? theme.theme.colorScheme.primary
                : theme.theme.colorScheme.outline,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    theme.name,
                    style: TextStyle(
                      color: theme.theme.colorScheme.onSurface,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    theme.description,
                    style: TextStyle(
                      color: theme.theme.colorScheme.onSurfaceVariant,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            if (!theme.isUnlocked)
              Container(
                decoration: BoxDecoration(
                  color: Colors.black45,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Icon(
                    Icons.lock,
                    color: Colors.white,
                  ).animate(
                    onPlay: (controller) => controller.repeat(),
                  )
                    .scale(duration: 500.milliseconds)
                    .then()
                    .shake(duration: 250.milliseconds),
                ),
              ),
            if (isSelected)
              Positioned(
                top: 8,
                right: 8,
                child: Icon(
                  Icons.check_circle,
                  color: theme.theme.colorScheme.primary,
                ).animate().scale(),
              ),
          ],
        ),
      ),
    );
  }
}