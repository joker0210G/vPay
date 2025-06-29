import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
//import 'package:supabase_flutter/supabase_flutter.dart' show OAuthProvider, AuthException;
import 'package:vpay/core/constants/colors.dart';
//import 'package:go_router/go_router.dart';
// import 'package:vpay/features/auth/providers/auth_provider.dart'; // Unused
import 'package:vpay/features/auth/presentation/widgets/header.dart';
import 'package:vpay/features/auth/presentation/widgets/auth_toggle.dart';
import 'package:vpay/features/auth/presentation/widgets/sign_in_form.dart';
import 'package:vpay/features/auth/presentation/widgets/sign_up_form.dart';
// import 'package:vpay/features/auth/presentation/widgets/social_login.dart'; // Unused
// Removed import 'package:vpay/app.dart'; // Import AppRoutes

class AuthScreen extends ConsumerStatefulWidget {
  const AuthScreen({super.key});

  @override
  ConsumerState<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends ConsumerState<AuthScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _signInFormKey = GlobalKey<FormState>();
  final _signUpFormKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _nameController = TextEditingController();
  // bool _isLoading = false; // Removed unused field

  // Removed unused _signIn method
  // Removed unused _signInWithProvider method
  // Removed unused _signUp method
  // Removed unused _resetPassword method

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary,
      body: Column(
        children: [
          _buildTopSection(),
          _buildContentArea(),
        ],
      ),
    );
  }

  Widget _buildTopSection() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.primary,
      ),
      child: Column(
        children: [
          const AuthHeader(),
          _buildAuthToggle(),
          const SizedBox(height: 10),
        ],
      ),
    );
  }

  Widget _buildContentArea() {
    return Expanded(
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.secondary,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(40),
            topRight: Radius.circular(40),
          ),
        ),
        child: ConstrainedBox(
          constraints: BoxConstraints(
            minHeight: MediaQuery.of(context).size.height * 0.3,
          ),
          child: TabBarView(
            controller: _tabController,
            children: [
              SingleChildScrollView(
                child: Column(
                  children: [
                    SignInForm(
                      emailController: _emailController,
                      passwordController: _passwordController,
                      formKey: _signInFormKey,
                    ),
                    const SizedBox(height: 20),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 20),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
              SingleChildScrollView(
                child: SignUpForm(
                  nameController: _nameController,
                  emailController: _emailController,
                  passwordController: _passwordController,
                  confirmPasswordController: _confirmPasswordController,
                  formKey: _signUpFormKey,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAuthToggle() {
    return AuthToggle(tabController: _tabController);
  }

  // Additional refinement: Add a check for tab change
  void _handleTabChange() {
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(_handleTabChange);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
}
