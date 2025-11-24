import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:async';
import '../../../core/constants/app_colors.dart';
import '../../../core/theme/text_styles.dart';
import '../../../viewmodels/auth_viewmodel.dart';
import '../../../core/services/storage_service.dart';
import 'home/home_screen.dart';
import 'onboarding_screen.dart';
import 'auth/email_verification_screen.dart';
/// Splash Screen
/// First screen shown when app opens
/// - Animated logo reveal
/// - Checks if user has completed onboarding
/// - Checks authentication status
/// - Routes to appropriate screen
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _navigateToNextScreen();
  }

  void _setupAnimations() {
    _controller = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    // Fade in animation
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.5, curve: Curves.easeIn),
      ),
    );

    // Scale animation
    _scaleAnimation = Tween<double>(
      begin: 0.5,
      end: 1.0,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.5, curve: Curves.easeOutBack),
      ),
    );

    // Slide up animation for tagline
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 1),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.5, 1.0, curve: Curves.easeOut),
      ),
    );

    _controller.forward();
  }

  Future<void> _navigateToNextScreen() async {
    // Wait for animation + minimum splash duration
    await Future.delayed(const Duration(milliseconds: 2500));

    if (!mounted) return;

    // Get auth viewmodel
    final authViewModel = context.read<AuthViewModel>();
    
    // Give a moment for redirect result to be processed if app just reopened
    // This handles GitHub OAuth redirect on mobile
    await Future.delayed(const Duration(milliseconds: 500));

    if (!mounted) return;

    // Check if onboarding is complete
    final storageService = context.read<StorageService>();
    final hasCompletedOnboarding = storageService.getBool(
      StorageKeys.isOnboardingComplete,
    ) ?? false;

    // Check authentication status (after redirect result check)
    final isAuthenticated = authViewModel.isAuthenticated;

    // Navigate to appropriate screen
    if (!hasCompletedOnboarding) {
      // First time user - show onboarding
      _navigateToOnboarding();
    } else if (isAuthenticated) {
      // User is logged in - go to home
      // Check if user needs email verification (for email/password users)
      if (!authViewModel.isGuest && !authViewModel.isEmailVerified) {
        // User is signed in but email not verified
        _navigateToEmailVerification();
      } else {
        // User is verified or is a guest/OAuth user - go to home
        _navigateToHome();
      }
    } else {
      // User is not authenticated - show login
      _navigateToOnboarding();
    }
  }

  void _navigateToOnboarding() {
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
        const OnboardingScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
        transitionDuration: const Duration(milliseconds: 500),
      ),
    );
  }

  void _navigateToHome() {
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
        const HomeScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
        transitionDuration: const Duration(milliseconds: 500),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }


  void _navigateToEmailVerification() {
    final authViewModel = context.read<AuthViewModel>();
    final email = authViewModel.email ?? '';

    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
        EmailVerificationScreen(email: email),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
        transitionDuration: const Duration(milliseconds: 500),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFF0D1117),
              Color(0xFF161B22),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Animated Logo
              ScaleTransition(
                scale: _scaleAnimation,
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: _buildLogo(),
                ),
              ),

              const SizedBox(height: 24),

              // Animated Tagline
              SlideTransition(
                position: _slideAnimation,
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: _buildTagline(),
                ),
              ),

              const SizedBox(height: 60),

              // Loading indicator
              FadeTransition(
                opacity: _fadeAnimation,
                child: const SizedBox(
                  width: 40,
                  height: 40,
                  child: CircularProgressIndicator(
                    strokeWidth: 3,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLogo() {
    return Container(
      width: 150,
      height: 150,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.2),
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Code brackets icon
            const Icon(
              Icons.code,
              size: 60,
              color: Colors.white,
            ),
            const SizedBox(height: 8),
            // Poetry icon overlay
            Icon(
              Icons.auto_awesome,
              size: 30,
              color: Colors.white.withValues(alpha: 0.9),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTagline() {
    return Column(
      children: [
        Text(
          'CODE POETRY',
          style: AppTextStyles.h2(color: Colors.white).copyWith(
            fontWeight: FontWeight.bold,
            letterSpacing: 2,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Where Logic Meets Emotion',
          style: AppTextStyles.bodyLarge(color: Colors.white.withValues(alpha: 0.9))
              .copyWith(
            fontStyle: FontStyle.italic,
          ),
        ),
      ],
    );
  }
}