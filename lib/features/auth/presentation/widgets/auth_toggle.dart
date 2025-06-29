import 'package:flutter/material.dart';
import 'package:vpay/core/constants/colors.dart';

class AuthToggle extends StatelessWidget {
  final TabController tabController;

  const AuthToggle({super.key, required this.tabController});

  @override
  Widget build(BuildContext context) {
    // int alpha = (0.1 * 255).round(); // Unused local variable
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 35),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: .9), // Direct alpha value used
        borderRadius: BorderRadius.circular(200),
      ),
      child: TabBar(
        controller: tabController,
        indicator: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
          shape: BoxShape.rectangle,
          color: AppColors.secondary,
        ),
        labelColor: Colors.black,
        unselectedLabelColor: Colors.white,
        labelStyle: Theme.of(context).textTheme.bodyLarge?.copyWith(
          fontWeight: FontWeight.w600
        ),
        tabs: const [
          Tab(text: '        Sign In        '),
          Tab(text: '        Sign Up        '),
        ],
      ),
    );
  }
}
