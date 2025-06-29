import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:vpay/features/account/presentation/widgets/animated_avatar.dart';
import 'package:vpay/features/account/presentation/widgets/theme_selector.dart';
import 'package:vpay/features/account/providers/avatar_provider.dart';
import 'package:vpay/features/account/data/animation_service.dart'; // Import AnimationService
import 'package:image_picker/image_picker.dart';
import 'package:vpay/features/auth/providers/auth_provider.dart'; // Import authProvider

class PersonalizationScreen extends ConsumerStatefulWidget {
  const PersonalizationScreen({super.key});

  @override
  ConsumerState<PersonalizationScreen> createState() => _PersonalizationScreenState();
}

class _PersonalizationScreenState extends ConsumerState<PersonalizationScreen> {
  final ImagePicker _picker = ImagePicker();
  bool _isUploading = false;

  @override
  Widget build(BuildContext context) {
    final currentUser = Supabase.instance.client.auth.currentUser;
    if (currentUser == null) {
      return const Scaffold(
        body: Center(child: Text('Please login to access personalization')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Personalization'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Profile Picture',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Consumer(
              builder: (context, ref, _) {
                return Row(
                  children: [
                    AnimatedAvatar(
                      userId: currentUser.id,
                      size: 100,
                      onTap: _isUploading ? null : () => _pickImage(context, ref, currentUser.id),
                    ),
                    const SizedBox(width: 16),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).colorScheme.primary,
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                        textStyle: TextStyle(fontSize: 14, color: Theme.of(context).colorScheme.onPrimary),
                      ),
                      onPressed: _isUploading ? null : () => _pickImage(context, ref, currentUser.id),
                      child: _isUploading
                          ? SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(strokeWidth: 2, color: Theme.of(context).colorScheme.onPrimary))
                          : Text('Change Picture', style: TextStyle(color: Theme.of(context).colorScheme.onPrimary)),
                    ),
                  ],
                );
              },
            ),
            const SizedBox(height: 32),
            const Text(
              'Animated Avatars',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Consumer(
              builder: (context, ref, _) {
                final avatarData = ref.watch(avatarProvider(currentUser.id));
                
                return avatarData.when(
                  data: (state) {
                    // Access the animation paths from AnimationService
                    final animationEntries = AnimationService.animationPaths.entries.toList();
                    if (animationEntries.isEmpty) {
                      return const Text("No animations available yet. Stay tuned!");
                    }

                    return Wrap(
                      spacing: 16,
                      runSpacing: 16,
                      children: animationEntries.map((entry) {
                        final animationId = entry.key;
                        final isUnlocked = state.unlockedAnimations.contains(animationId);
                        final isActive = state.activeAnimation == animationId;

                        return GestureDetector(
                          onTap: () {
                            if (isUnlocked) {
                              ref.read(avatarProvider(currentUser.id).notifier)
                                .setActiveAnimation(animationId);
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Animation "$animationId" is locked.')),
                              );
                            }
                          },
                          child: Container(
                            padding: const EdgeInsets.all(2.0), // Space for the border
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: isActive
                                  ? Border.all(
                                      color: Theme.of(context).colorScheme.secondary, // Use theme color
                                      width: 3)
                                  : Border.all(
                                      color: Colors.transparent, 
                                      width: 3),
                            ),
                            child: AnimatedAvatar(
                              userId: currentUser.id,
                              animationId: animationId,
                              size: 80,
                              showLockIfNotUnlocked: true,
                              // No direct onTap here, GestureDetector handles it
                            ),
                          ),
                        );
                      }).toList(),
                    );
                  },
                  loading: () => const CircularProgressIndicator(),
                  error: (_, __) => const Text('Error loading animations data.'),
                );
              },
            ),
            const SizedBox(height: 32),
            // Option to clear active animation
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.secondary,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                textStyle: TextStyle(fontSize: 14, color: Theme.of(context).colorScheme.onSecondary),
              ),
              onPressed: () {
                ref.read(avatarProvider(currentUser.id).notifier).setActiveAnimation(null);
              },
              child: Text('Remove Animated Avatar', style: TextStyle(color: Theme.of(context).colorScheme.onSecondary)),
            ),
            const SizedBox(height: 32),
            const Text(
              'Themes',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            ThemeSelector(userId: currentUser.id),
          ],
        ),
      ),
    );
  }

  Future<void> _pickImage(BuildContext context, WidgetRef ref, String userId) async {
    debugPrint("Starting image pick process.");
    try {
      setState(() => _isUploading = true);
      
      final image = await _picker.pickImage(source: ImageSource.gallery);
      debugPrint("Image picker result: ${image?.path}");
      if (image == null) {
        debugPrint("Image picking cancelled or failed.");
        setState(() => _isUploading = false);
        return;
      }

      debugPrint("Reading image bytes from ${image.path}");
      final bytes = await image.readAsBytes();
      debugPrint("Image bytes read successfully. Length: ${bytes.length}");
      final ext = image.path.split('.').last;
      // final filename = 'avatar.$ext'; // Using a timestamp based filename to avoid caching issues and ensure uniqueness if needed.
      final filename = '${DateTime.now().millisecondsSinceEpoch}.$ext';


      debugPrint("Uploading to Supabase: public/$userId/$filename");
      await Supabase.instance.client.storage
          .from('avatars')
          .uploadBinary(
            'public/$userId/$filename',
            bytes,
            fileOptions: FileOptions(
              contentType: 'image/${ext == 'jpg' ? 'jpeg' : ext}',
              upsert: true, // Add this line
            ),
          );
      debugPrint("Supabase upload finished.");

      debugPrint("Getting public URL for: public/$userId/$filename");
      final imageUrl = Supabase.instance.client.storage
          .from('avatars')
          .getPublicUrl('public/$userId/$filename');
      debugPrint("Retrieved public URL: $imageUrl");

      // Update the main user profile via AuthProvider -> AuthRepository (updates profiles table)
      debugPrint("Calling authProvider.notifier.updateUserAvatar with URL: $imageUrl");
      await ref.read(authProvider.notifier).updateUserAvatar(imageUrl);
      debugPrint("authProvider.notifier.updateUserAvatar call completed.");
      
      // Also update the AvatarProvider's state (which updates user_preferences table)
      debugPrint("Calling avatarProvider.notifier.setAvatarUrl with URL: $imageUrl");
      await ref.read(avatarProvider(userId).notifier).setAvatarUrl(imageUrl);
      debugPrint("avatarProvider.notifier.setAvatarUrl call completed.");
      
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile picture updated successfully')),
        );
      }
    } catch (e) {
      debugPrint("Error in _pickImage: $e");
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error updating profile picture: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isUploading = false);
      }
    }
  }
}
