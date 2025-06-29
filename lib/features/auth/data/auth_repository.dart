import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:vpay/shared/models/user_model.dart';
import 'package:vpay/shared/config/supabase_config.dart';

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository(supabase: Supabase.instance.client);
});

class AuthRepository {
  final SupabaseClient supabase;

  AuthRepository({required this.supabase});

  Future<void> signUp({
  required String email,
  required String password,
  required String username,
}) async {
  try {
    final response = await supabase.auth.signUp(
      email: email,
      password: password,
      data: {'user_name': username}, // This data is for auth.users.raw_user_meta_data
    );

    if (response.user == null) {
      // It's good practice to also log this specific unexpected case
      debugPrint('Supabase signUp completed but response.user is null.');
      throw Exception('Supabase signUp completed but returned no user.');
    }

    try {
      final profileDataToUpsert = {
        'user_id': response.user!.id,
        'email': email,               
        'user_name': username,        
        'updated_at': DateTime.now().toIso8601String(),
      };
      debugPrint('Attempting profile upsert with data: ${profileDataToUpsert.toString()}');
      // Ensure the next line uses this 'profileDataToUpsert' map
      await supabase.from(SupabaseConfig.profilesTable).upsert(profileDataToUpsert);
      debugPrint('Profile upsert successful for user: ${response.user!.id}');

    } catch (e) {
      // LOGGING FOR DIAGNOSTICS:
      debugPrint('--------------------------------------------------');
      debugPrint('ERROR DURING PROFILE UPSERT - DIAGNOSTICS');
      debugPrint('Timestamp: ${DateTime.now().toIso8601String()}');
      debugPrint('Supabase User ID from response: ${response.user?.id}'); // Ensure 'response' is accessible here
      debugPrint('Email used for upsert: $email'); // Ensure 'email' is accessible here
      debugPrint('username used for upsert: $username'); // Ensure 'username' is accessible here
      if (e is PostgrestException) {
        debugPrint('PostgrestException Code: ${e.code}');
        debugPrint('PostgrestException Message: ${e.message}');
        debugPrint('PostgrestException Details: ${e.details}');
        debugPrint('PostgrestException Hint: ${e.hint}');
      } else {
        debugPrint('Error type: ${e.runtimeType.toString()}');
        debugPrint('Error message: ${e.toString()}');
      }
      debugPrint('--------------------------------------------------');
      // Consider if you want to re-throw e or a new Exception with more context
      throw Exception('Profile creation failed after signup: ${e.toString()}'); 
    }

  } catch (e) {
    // Catch errors from supabase.auth.signUp or the re-thrown profile error
    // Ensure this log doesn't duplicate the one above if re-throwing.
    if (!e.toString().contains('Profile creation failed after signup')) {
       debugPrint('Error in signUp main catch: ${e.toString()}');
    }
    rethrow;
  }
}

  Future<void> signInWithPassword({
    required String email,
    required String password,
  }) async {
    try {
      await supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );
    } catch (e) {
      rethrow;
    }
  }

Future<UserModel?> getCurrentUser({String? userIdOverride}) async {
  try {
    final supabaseUser = supabase.auth.currentUser;
    final effectiveUserId = userIdOverride ?? supabaseUser?.id;

    if (effectiveUserId == null) {
      return null;
    }

    final data = await supabase
        .from(SupabaseConfig.profilesTable)
        .select()
        .eq('user_id', effectiveUserId) // Ensure this uses effectiveUserId
        .single();

    final userModel = UserModel.fromJson(data);
    return userModel;
  } catch (e) {
    return null;
  }
}

  Future<void> signOut() async {
    await supabase.auth.signOut();
  }

  Future<void> sendPasswordResetEmail(String email) async {
    await supabase.auth.resetPasswordForEmail(email);
  }

  Future<void> signInWithGoogle() async {
    await supabase.auth.signInWithOAuth(OAuthProvider.google);
  }

  Future<void> signInWithFacebook() async {
    await supabase.auth.signInWithOAuth(OAuthProvider.facebook);
  }

  Future<void> signInWithApple() async {
    await supabase.auth.signInWithOAuth(OAuthProvider.apple);
  }

  Future<UserModel> updateUserProfile({
    required String userId,
    String? username,
    String? phone,
    String? avatarUrl,
  }) async {
    debugPrint("AuthRepository.updateUserProfile called with userId: $userId, username: $username, phone: $phone");
    try {
      final updates = <String, dynamic>{
        'user_id': userId, // Using 'user_id' as indicated by runtime error and getCurrentUser structure
        'updated_at': DateTime.now().toIso8601String(),
      };
      if (username != null) {
        updates['user_name'] = username;
      }
      if (phone != null) {
        updates['phone'] = phone;
      }
      if (avatarUrl != null) {
        updates['avatar_url'] = avatarUrl;
      }

      debugPrint("Supabase update data: $updates");

      final response = await supabase
          .from(SupabaseConfig.profilesTable)
          .upsert(updates)
          .select()
          .single();

      // The Supabase SDK for Dart, when using .select().single(), the response itself is the data if successful.
      // If there's an error (e.g., PostgrestException), it's typically thrown and caught in the catch block.
      // So, we assume 'response' here is the successful data.
      // For direct error checking from response, it depends on how Supabase client wraps it,
      // but typically PostgrestErrors are thrown. Let's assume success if no throw.
      debugPrint("Supabase update response: Success (data retrieved)");

      return UserModel.fromJson(response);
    } catch (e) {
      // Consider more specific error handling or logging
      debugPrint("Supabase update response: Error: $e");
      rethrow;
    }
  }

  Future<UserModel> updateUserAvatar({
    required String userId,
    required String avatarUrl,
  }) async {
    debugPrint("AuthRepository.updateUserAvatar called with URL: $avatarUrl. User ID: $userId");
    try {
      final updates = <String, dynamic>{
        'user_id': userId,
        'avatar_url': avatarUrl,
        'updated_at': DateTime.now().toIso8601String(),
      };

      debugPrint("Supabase update data for avatar: $updates");

      final response = await supabase
          .from(SupabaseConfig.profilesTable)
          .upsert(updates)
          .select()
          .single();
      
      debugPrint("Supabase update response for avatar: Success (data retrieved)");
      return UserModel.fromJson(response);
    } catch (e) {
      debugPrint("Supabase update response for avatar: Error: $e");
      rethrow;
    }
  }
}
