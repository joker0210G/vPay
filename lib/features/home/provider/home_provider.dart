// features/home/providers/home_provider.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:vpay/features/auth/providers/auth_provider.dart';
import 'package:vpay/shared/models/user_model.dart';

final userProvider = FutureProvider<UserModel?>((ref) async {
  final currentUser = ref.watch(authProvider).user;
  if (currentUser == null) return null;

  // Make a database query to retrieve the user's data
  final response = await Supabase.instance.client
      .from('profiles')
      .select()
      .eq('user_id', currentUser.id)
      .single();

  return UserModel.fromJson(response);
});

final searchProvider = FutureProvider.family<List<String>, String>((ref, query) async {
  // Implement search logic here
  // This is just a placeholder implementation
  await Future.delayed(const Duration(milliseconds: 500));
  return ['Result 1 for $query', 'Result 2 for $query'];
});
