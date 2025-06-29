import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vpay/features/auth/presentation/widgets/social_login.dart';
import 'package:vpay/features/auth/providers/auth_provider.dart';
import 'package:vpay/features/auth/presentation/widgets/auth_form_utils.dart';

// Removed import 'package:go_router/go_router.dart';

class SignUpForm extends ConsumerWidget {
  final TextEditingController nameController;
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final TextEditingController confirmPasswordController;
  final GlobalKey<FormState> formKey;

  const SignUpForm({
    super.key,
    required this.nameController,
    required this.emailController,
    required this.passwordController,
    required this.confirmPasswordController,
    required this.formKey,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    return SingleChildScrollView(
      padding: const EdgeInsets.all(30),
      child: Form(
        key: formKey,
        child: Column(
          children: [
            Text('Create Account', style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 30),
            buildInputField(
              context: context,
              controller: nameController,
              label: 'Full Name',
              icon: Icons.person_outline,
              validator: (value) {
                if (value == null || value.isEmpty) return 'Please enter your name';
                return null;
              },
            ),
            const SizedBox(height: 20),
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
            const SizedBox(height: 20),
            buildInputField(
              context: context,
              controller: confirmPasswordController,
              label: 'Confirm Password',
              icon: Icons.lock_outline,
              obscureText: true,
              validator: (value) {
                if (value != passwordController.text) {
                  return 'Passwords do not match';
                }
                return null;
              },
            ),
            const SizedBox(height: 30),
            buildAuthButton(
              context,
              ref,
              'Sign Up',
              () async {
                if (formKey.currentState!.validate()) {
                  try {
                    await ref.read(authProvider.notifier).signUp(
                      email: emailController.text.trim(),
                      password: passwordController.text.trim(),
                      username: nameController.text.trim(),
                    );
                    // Navigation handled by router
                  } catch (e) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(e.toString())),
                      );
                    }
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
}
