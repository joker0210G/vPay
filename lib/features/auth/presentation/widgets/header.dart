import 'package:flutter/material.dart';
import 'package:vpay/core/constants/colors.dart';

class AuthHeader extends StatelessWidget {
  const AuthHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      // Use responsive height with constraints
      constraints: BoxConstraints(
        minHeight: 100,
        maxHeight: MediaQuery.of(context).size.height * 0.25,
      ),
      decoration: BoxDecoration(
        color: AppColors.primary,
      ),
      child: Center(
        child: Image.asset(
          'assets/images/logo_1.png',
          height: 100,
        ),
      ),
    );
  }
}
