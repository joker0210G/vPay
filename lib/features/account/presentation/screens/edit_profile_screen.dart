import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:vpay/core/constants/colors.dart';
import 'package:vpay/features/auth/data/auth_repository.dart';
import 'package:vpay/features/auth/providers/auth_provider.dart';
// import 'package:vpay/features/auth/providers/auth_state.dart'; // Import AuthState
import 'package:vpay/shared/models/user_model.dart';

// 1. State Class
@immutable
class EditProfileState {
  final bool isLoading;
  final String? errorMessage;
  final UserModel? initialUser;

  const EditProfileState({
    this.isLoading = false,
    this.errorMessage,
    this.initialUser,
  });

  EditProfileState copyWith({
    bool? isLoading,
    String? errorMessage,
    UserModel? initialUser,
  }) {
    return EditProfileState(
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage ?? this.errorMessage,
      initialUser: initialUser ?? this.initialUser,
    );
  }
}

// 2. Notifier Class
class EditProfileNotifier extends StateNotifier<EditProfileState> {
  final AuthRepository _authRepository;
  final AuthNotifier _authNotifier; // To refresh the user state globally

  EditProfileNotifier(this._authRepository, this._authNotifier, UserModel? currentUser)
      : super(EditProfileState(initialUser: currentUser));

  Future<bool> saveProfile({
    required String userId,
    required String username,
    required String phone,
  }) async {
    debugPrint("EditProfileNotifier.saveProfile called. UserID: $userId, FullName: $username");
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final updatedUser = await _authRepository.updateUserProfile(
        userId: userId,
        username: username,
        phone: phone,
      );
      // Refresh the global auth state
      _authNotifier.state = _authNotifier.state.copyWith(user: updatedUser, isLoading: false, error: null);
      debugPrint("EditProfileNotifier: Profile update successful for user $userId. New name: ${updatedUser.username}");
      state = state.copyWith(isLoading: false, initialUser: updatedUser);
      return true;
    } catch (e) {
      debugPrint("EditProfileNotifier: Profile update failed. Error: $e");
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
      return false;
    }
  }
}

// 3. Provider
final editProfileNotifierProvider =
    StateNotifierProvider.autoDispose<EditProfileNotifier, EditProfileState>((ref) {
  final authRepository = ref.watch(authRepositoryProvider);
  final authNotifier = ref.read(authProvider.notifier);
  final currentUser = ref.watch(authProvider).user;
  return EditProfileNotifier(authRepository, authNotifier, currentUser);
});

// 4. Screen Widget
class EditProfileScreen extends ConsumerStatefulWidget {
  const EditProfileScreen({super.key});

  @override
  ConsumerState<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends ConsumerState<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _usernameController;
  late TextEditingController _phoneController;

  @override
  void initState() {
    super.initState();
    final initialUser = ref.read(editProfileNotifierProvider).initialUser;
    _usernameController = TextEditingController(text: initialUser?.username ?? '');
    _phoneController = TextEditingController(text: initialUser?.phone ?? '');
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _saveProfile() async {
    debugPrint("Attempting to save profile. FullName: ${_usernameController.text}, Phone: ${_phoneController.text}");
    if (_formKey.currentState!.validate()) {
      final userId = ref.read(authProvider).user?.id;
      if (userId == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error: User not found.')),
        );
        return;
      }

      final success = await ref
          .read(editProfileNotifierProvider.notifier)
          .saveProfile(
            userId: userId,
            username: _usernameController.text,
            phone: _phoneController.text,
          );

      debugPrint("Save profile result: $success. Error (if any): ${ref.read(editProfileNotifierProvider).errorMessage}");

      if (mounted && success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile updated successfully!')),
        );
        context.pop(); // Go back after successful save
      } else if (mounted) {
        final error = ref.read(editProfileNotifierProvider).errorMessage;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error updating profile: ${error ?? 'Unknown error'}')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(editProfileNotifierProvider);
    // final state = ref.watch(editProfileNotifierProvider); // Already watched
    // Controllers are initialized in initState and their values persist across builds.
    // Re-assigning them in the build method from initialUser is generally not needed
    // and can lead to issues if the user has started editing the text.
    // The initial values are set once in initState. If initialUser can change
    // while the screen is active, didUpdateWidget or a listener should handle controller updates.

    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Profile'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            debugPrint("Back button pressed. Can pop: ${GoRouter.of(context).canPop()}");
            context.pop();
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: <Widget>[
              TextFormField(
                controller: _usernameController,
                decoration: const InputDecoration(
                  labelText: 'Full Name',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.person_outline),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your full name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _phoneController,
                decoration: const InputDecoration(
                  labelText: 'Phone Number (Optional)',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.phone_outlined),
                ),
                keyboardType: TextInputType.phone,
                validator: (value) {
                  // Basic validation: allow empty or a reasonable phone number pattern
                  if (value != null && value.isNotEmpty) {
                    if (!RegExp(r'^\+?[0-9\s-]{7,15}$').hasMatch(value)) {
                       return 'Please enter a valid phone number';
                    }
                  }
                  return null;
                },
              ),
              const SizedBox(height: 30),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  textStyle: const TextStyle(fontSize: 16, color: Colors.white),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onPressed: state.isLoading ? null : _saveProfile,
                child: state.isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                      )
                    : const Text('Save Changes', style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
