import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:vpay/core/constants/colors.dart';
import 'package:vpay/features/auth/providers/auth_provider.dart';
// Removed import 'package:vpay/features/auth/providers/auth_state.dart';

class AuthGuard extends ConsumerWidget {
  final Widget child;
  
  const AuthGuard({super.key, required this.child});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    // final currentRoute = GoRouter.of(context).routerDelegate.currentConfiguration.uri.path;

    if (authState.isLoading) {
      return Center(child: CircularProgressIndicator());
    }

    if (authState.user != null) {
      return child;
    }

    // ... (rest of the build method) ...
    return Scaffold(
      backgroundColor: AppColors.primary,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Authentication Required',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 20),
            Text(
              'Please sign in to access this feature',
              style: TextStyle(
                color: Colors.white70,
                fontSize: 16,
              ),
            ),
            if (authState.error != null) ...[
              SizedBox(height: 10),
              Text(
                authState.error!,
                style: TextStyle(
                  color: Colors.red,
                  fontSize: 14,
                ),
              ),
            ],
            SizedBox(height: 30),
            ElevatedButton(
              onPressed: () => GoRouter.of(context).go('/login'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.accent,
                padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15),
              ),
              child: Text(
                'Go to Login',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
