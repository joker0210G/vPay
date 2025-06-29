import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vpay/app.dart';
import 'package:vpay/features/auth/presentation/widgets/auth_header.dart';
import 'package:vpay/features/auth/presentation/widgets/auth_toggle.dart';
import 'package:vpay/features/auth/providers/auth_provider.dart';

class AuthLogin extends ConsumerStatefulWidget {
  const AuthLogin({super.key});

  @override
  ConsumerState<AuthLogin> createState() => _AuthLoginState();
}

class _AuthLoginState extends ConsumerState<AuthLogin> with TickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _tabController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          const AuthHeader(
            title: 'Welcome Back',
            subtitle: 'Please sign in to continue',
          ),
          const SizedBox(height: 32),
          _EmailInput(
            controller: _emailController,
          ),
          const SizedBox(height: 16),
          _PasswordInput(
            controller: _passwordController,
          ),
          const SizedBox(height: 24),
          _LoginButton(
            onPressed: _isLoading
                ? null
                : () async {
                    if (_formKey.currentState!.validate()) {
                      setState(() => _isLoading = true);
                      try {
                        await ref.read(authProvider.notifier)
                            .signIn(
                          email: _emailController.text,
                          password: _passwordController.text,
                        );
                        // Navigate to home screen after successful login
                        if (!mounted) return;
                        GoRouter.of(context).goNamed(AppRoutes.home);
                      } catch (error) {
                        if (!mounted) return;
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Sign in failed: $error')),
                        );
                      } finally {
                        // No context usage in finally, but good practice to check if a general setState is involved.
                        // Here it's specific to _isLoading, which is fine.
                        // However, if the async operation was very long, it might be better to check mounted
                        // even before this setState, but for typical login, this is okay.
                        // For safety, especially if _isLoading affects UI that might be gone:
                        if (mounted) {
                          setState(() => _isLoading = false);
                        }
                      }
                    }
                  },
          ),
          const SizedBox(height: 16),
          AuthToggle(tabController: _tabController),
        ],
      ),
    );
  }
}

class _EmailInput extends StatelessWidget {
  final TextEditingController controller;

  const _EmailInput({required this.controller});

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      decoration: const InputDecoration(
        labelText: 'Email',
        border: OutlineInputBorder(),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter your email';
        }
        if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
          return 'Please enter a valid email address';
        }
        return null;
      },
    );
  }
}

class _PasswordInput extends StatelessWidget {
  final TextEditingController controller;

  const _PasswordInput({required this.controller});

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      obscureText: true,
      decoration: const InputDecoration(
        labelText: 'Password',
        border: OutlineInputBorder(),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter your password';
        }
        if (value.length < 8) {
          return 'Password must be at least 8 characters';
        }
        return null;
      },
    );
  }
}

class _LoginButton extends StatelessWidget {
  final VoidCallback? onPressed;

  const _LoginButton({required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        minimumSize: const Size(200, 48),
        maximumSize: const Size(400, 48),
      ),
      onPressed: onPressed,
      child: const Text('Sign In'),
    );
  }
}
