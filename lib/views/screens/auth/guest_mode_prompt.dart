
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/theme/text_styles.dart';
import '../../../viewmodels/auth_viewmodel.dart';
import '../../widgets/common/custom_button.dart';
import '../home/home_screen.dart';
import 'login_screen.dart';
import 'signup_screen.dart';

class GuestModePrompt extends StatelessWidget {
  const GuestModePrompt({super.key});

  @override
  Widget build(BuildContext context) {
    final authViewModel = context.watch<AuthViewModel>();

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppColors.primaryGradient,
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Icon
                Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.person_outline,
                    size: 60,
                    color: Colors.white,
                  ),
                ),

                const SizedBox(height: 40),

                // Title
                Text(
                  AppStrings.guestModeTitle,
                  style: AppTextStyles.h2(color: Colors.white),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 16),

                // Description
                Text(
                  AppStrings.guestModeDesc,
                  style: AppTextStyles.bodyLarge(
                    color: Colors.white.withOpacity(0.9),
                  ),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 60),

                // Sign Up button
                CustomButton(
                  text: AppStrings.guestModeSignUp,
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => const SignupScreen(),
                      ),
                    );
                  },
                  backgroundColor: Colors.white,
                  textColor: AppColors.primaryStart,
                  width: double.infinity,
                  isGradient: false,
                ),

                const SizedBox(height: 16),

                // Continue as Guest
                CustomButton(
                  text: AppStrings.guestModeContinue,
                  onPressed: () async {
                    final success = await authViewModel.signInAsGuest();
                    if (success && context.mounted) {
                      Navigator.of(context).pushReplacement(
                        MaterialPageRoute(
                          builder: (context) => const HomeScreen(),
                        ),
                      );
                    }
                  },
                  isOutlined: true,
                  textColor: Colors.white,
                  width: double.infinity,
                  isLoading: authViewModel.isLoading,
                ),

                const SizedBox(height: 24),

                // Sign In link
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      AppStrings.loginHaveAccount,
                      style: AppTextStyles.bodyMedium(
                        color: Colors.white.withOpacity(0.8),
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => const LoginScreen(),
                          ),
                        );
                      },
                      child: Text(
                        AppStrings.loginSignIn,
                        style: AppTextStyles.labelLarge(
                          color: Colors.white,
                        ).copyWith(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
