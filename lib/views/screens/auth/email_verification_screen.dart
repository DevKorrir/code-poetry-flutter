import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/theme/text_styles.dart';
import '../../../viewmodels/auth_viewmodel.dart';
import '../../widgets/common/custom_button.dart';
import '../home/home_screen.dart';
import 'login_screen.dart';

/// Email Verification Screen
/// Shown after email signup to verify email before accessing the app
class EmailVerificationScreen extends StatefulWidget {
  final String email;

  const EmailVerificationScreen({
    super.key,
    required this.email,
  });

  @override
  State<EmailVerificationScreen> createState() => _EmailVerificationScreenState();
}

class _EmailVerificationScreenState extends State<EmailVerificationScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  bool _isCheckingVerification = false;
  int _resendCooldown = 0;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _startResendCooldown();
  }

  void _setupAnimations() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeIn,
    ));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    ));

    _animationController.forward();
  }

  void _startResendCooldown() {
    setState(() {
      _resendCooldown = 60; // 60 seconds cooldown
    });

    _countdownTimer();
  }

  void _countdownTimer() {
    if (_resendCooldown > 0) {
      Future.delayed(const Duration(seconds: 1), () {
        if (mounted) {
          setState(() {
            _resendCooldown--;
          });
          _countdownTimer();
        }
      });
    }
  }

  Future<void> _checkEmailVerification() async {
    setState(() {
      _isCheckingVerification = true;
    });

    final authViewModel = context.read<AuthViewModel>();
    final isVerified = await authViewModel.checkEmailVerification();

    if (mounted) {
      setState(() {
        _isCheckingVerification = false;
      });

      if (isVerified) {
        // Email is verified, navigate to home
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const HomeScreen()),
        );
      } else {
        // Show message to check email
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Email not verified yet. Please check your inbox and try again.'),
            backgroundColor: AppColors.warning,
          ),
        );
      }
    }
  }

  Future<void> _resendVerificationEmail() async {
    if (_resendCooldown > 0) return;

    final authViewModel = context.read<AuthViewModel>();
    final success = await authViewModel.sendEmailVerification();

    if (mounted && success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Verification email sent! Please check your inbox.'),
          backgroundColor: AppColors.success,
        ),
      );
      _startResendCooldown();
    }
  }

  void _signOut() {
    final authViewModel = context.read<AuthViewModel>();
    authViewModel.signOut().then((_) {
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const LoginScreen()),
        );
      }
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: isDark
                ? [AppColors.darkBackground, AppColors.darkSurfaceLight]
                : [AppColors.lightBackground, AppColors.lightSurface],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: SlideTransition(
              position: _slideAnimation,
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Email icon
                    Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        gradient: AppColors.primaryGradient,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primaryStart.withOpacity(0.3),
                            blurRadius: 20,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.email_outlined,
                        size: 60,
                        color: Colors.white,
                      ),
                    ),

                    const SizedBox(height: 32),

                    // Title
                    Text(
                      'Verify Your Email',
                      style: AppTextStyles.h2(),
                      textAlign: TextAlign.center,
                    ),

                    const SizedBox(height: 16),

                    // Description
                    Text(
                      'We\'ve sent a verification link to:',
                      style: AppTextStyles.bodyLarge(),
                      textAlign: TextAlign.center,
                    ),

                    const SizedBox(height: 8),

                    // Email address
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        color: isDark
                            ? AppColors.darkSurfaceLight.withOpacity(0.7)
                            : AppColors.lightSurface.withValues(alpha: 0.7),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: AppColors.primaryStart.withOpacity(0.3),
                        ),
                      ),
                      child: Text(
                        widget.email,
                        style: AppTextStyles.labelLarge(
                          color: AppColors.primaryStart,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),

                    const SizedBox(height: 32),

                    // Instructions
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: isDark
                            ? AppColors.darkSurface.withOpacity(0.5)
                            : AppColors.lightSurface.withOpacity(0.5),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              const Icon(
                                Icons.info_outline,
                                color: AppColors.info,
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  'Please check your email and click the verification link to continue.',
                                  style: AppTextStyles.bodyMedium(),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'Don\'t forget to check your spam folder if you don\'t see the email.',
                            style: AppTextStyles.caption(),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 40),

                    // Check verification button
                    CustomButton(
                      text: 'I\'ve Verified My Email',
                      onPressed: _isCheckingVerification ? null : _checkEmailVerification,
                      isLoading: _isCheckingVerification,
                      width: double.infinity,
                      height: 56,
                      leadingIcon: const Icon(Icons.check_circle_outline, size: 20),
                    ),

                    const SizedBox(height: 16),

                    // Resend email button
                    CustomButton(
                      text: _resendCooldown > 0
                          ? 'Resend Email ($_resendCooldown s)'
                          : 'Resend Verification Email',
                      onPressed: _resendCooldown > 0 ? null : _resendVerificationEmail,
                      isOutlined: true,
                      width: double.infinity,
                      height: 48,
                      leadingIcon: const Icon(Icons.send, size: 18),
                    ),

                    const SizedBox(height: 32),

                    // Sign out option
                    TextButton(
                      onPressed: _signOut,
                      child: Text(
                        'Sign Out',
                        style: AppTextStyles.labelMedium(
                          color: isDark
                              ? AppColors.darkTextSecondary
                              : AppColors.lightTextSecondary,
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Additional help text
                    Text(
                      'Having trouble? Contact support for assistance.',
                      style: AppTextStyles.caption(),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
