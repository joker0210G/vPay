import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vpay/features/auth/providers/auth_provider.dart';
import 'package:vpay/features/auth/presentation/widgets/auth_form_utils.dart';
import 'package:vpay/features/auth/presentation/widgets/social_login.dart';
import 'package:vpay/core/constants/colors.dart';

class SignInForm extends ConsumerWidget {
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final GlobalKey<FormState> formKey;

  const SignInForm({
    super.key,
    required this.emailController,
    required this.passwordController,
    required this.formKey,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    
    // Show messages if they exist
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (authState.error != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(authState.error!))
        );
        ref.read(authProvider.notifier).clearError();
      }
      if (authState.info != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(authState.info!))
        );
        ref.read(authProvider.notifier).clearInfo();
      }
    });

    return SingleChildScrollView(
      padding: const EdgeInsets.all(30),
      child: Form(
        key: formKey,
        child: Column(
          children: [
            Text('Welcome back', style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 30),
            buildInputField(
              context: context,
              controller: emailController,
              label: 'Email',
              icon: Icons.email_outlined,
              keyboardType: TextInputType.emailAddress,
              validator: (value) {
                if (value == null || value.isEmpty) return 'Please enter your email';
                final emailRegex = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
                if (!emailRegex.hasMatch(value)) return 'Please enter a valid email';
                return null;
              },
            ),
            const SizedBox(height: 20),
            buildInputField(
              context: context,
              controller: passwordController,
              label: 'Password',
              icon: Icons.lock_outline,
              obscureText: true,
              validator: (value) {
                if (value == null || value.isEmpty) return 'Please enter password';
                if (value.length < 6) return 'Minimum 6 characters required';
                return null;
              },
            ),
            const SizedBox(height: 15),
            _buildForgotPassword(context, ref),
            const SizedBox(height: 30),
            buildAuthButton(
              context,
              ref,
              'Sign In',
              () async {
                if (formKey.currentState!.validate()) {
                  try {
                    await ref.read(authProvider.notifier).signIn(
                      email: emailController.text.trim(),
                      password: passwordController.text.trim(),
                    );
                    // Navigation handled by router
                  } catch (e) {
                    // Errors are now handled through state
                  }
                }
              },
              authState.isLoading,
            ),
            const SizedBox(height: 25),
            SocialLogin(),
          ],
        ),
      ),
    );
  }

  Widget _buildForgotPassword(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    return Align(
      alignment: Alignment.centerRight,
      child: TextButton(
        onPressed: authState.isLoading ? null : () async {
          if (emailController.text.trim().isEmpty) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Please enter your email address')),
            );
            return;
          }

          try {
            await ref.read(authProvider.notifier).resetPassword(emailController.text.trim());
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Password reset email sent')),
              );
            }
          } catch (e) {
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Failed to send reset email: $e')),
              );
            }
          }
        },
        child: Text(
          'Forgot Password?',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: AppColors.accent,
            fontWeight: FontWeight.w600
          )
        ),
      ),
    );
  }
}
