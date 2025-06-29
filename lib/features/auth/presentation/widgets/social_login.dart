import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart' show OAuthProvider;
import 'package:vpay/features/auth/providers/auth_provider.dart';

class SocialLogin extends ConsumerWidget {
  const SocialLogin({super.key});

  void _signInWithProvider(BuildContext context, WidgetRef ref, OAuthProvider provider) {
    ref.read(authProvider.notifier).signInWithProvider(provider);
  }
  // TODO: add signup with provider method

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    return Column(
      children: [
        const Text(
          'Or continue with',
          style: TextStyle(fontSize: 14),
        ),
        const SizedBox(height: 10),
        Wrap(
          alignment: WrapAlignment.center,
          spacing: 10,
          runSpacing: 10,
          children: [
            SocialLoginButton(
              icon: Image.asset('assets/images/google logo.png', height: 24),
              label: 'Google',
              isLoading: authState.isLoading,
              onPressed: () => _signInWithProvider(context, ref, OAuthProvider.google),
            ),
            SocialLoginButton(
              icon: Image.asset('assets/images/facebook logo.png', height: 24),
              label: 'Facebook',
              isLoading: authState.isLoading,
              onPressed: () => _signInWithProvider(context, ref, OAuthProvider.facebook),
            ),
            SocialLoginButton(
              icon: const Icon(Icons.apple, size: 24),
              label: 'Apple',
              isLoading: authState.isLoading,
              onPressed: () => _signInWithProvider(context, ref, OAuthProvider.apple),
            ),
          ],
        ),
      ],
    );
  }
}

class SocialLoginButton extends StatelessWidget {
  final Widget icon;
  final String label;
  final bool isLoading;
  final VoidCallback onPressed;

  const SocialLoginButton({
    super.key,
    required this.icon,
    required this.label,
    required this.isLoading,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: isLoading ? null : onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          icon,
          const SizedBox(width: 8),
          Text(label),
          if (isLoading)
            const Padding(
              padding: EdgeInsets.only(left: 8),
              child: SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ),
        ],
      ),
    );
  }
}
