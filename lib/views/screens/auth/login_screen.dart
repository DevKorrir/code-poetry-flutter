import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/theme/text_styles.dart';
import '../../../viewmodels/auth_viewmodel.dart';
import '../../widgets/common/custom_button.dart';
import '../../widgets/common/custom_text_field.dart';
import '../home/home_screen.dart';
import 'signup_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _signIn() async {
    if (!_formKey.currentState!.validate()) return;

    final authViewModel = context.read<AuthViewModel>();
    final success = await authViewModel.signInWithEmail(
      email: _emailController.text.trim(),
      password: _passwordController.text,
    );

    if (success && mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const HomeScreen()),
      );
    } else if (mounted && authViewModel.error != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(authViewModel.error!)),
      );
    }
  }

  Future<void> _signInWithGoogle() async {
    final authViewModel = context.read<AuthViewModel>();
    final success = await authViewModel.signInWithGoogle();

    if (success && mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const HomeScreen()),
      );
    } else if (mounted && authViewModel.error != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(authViewModel.error!)),
      );
    }
  }

  Future<void> _signInWithGitHub() async {
    final authViewModel = context.read<AuthViewModel>();
    
    try {
      final success = await authViewModel.signInWithGitHub();

      if (success && mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const HomeScreen()),
        );
      } else if (mounted && authViewModel.error != null) {
        // Check if this is a redirect in progress (mobile only)
        // Don't show error - app will redirect and come back
        if (authViewModel.error == 'redirect_in_progress') {
          // App will close and reopen after GitHub authorization
          // Redirect result will be handled on app resume
          return;
        }
        
        // Check if it's a sessionStorage error - show dialog instead of snackbar
        final error = authViewModel.error!;
        if (error.contains('browser storage access') || 
            error.contains('sessionStorage') ||
            error.contains('missing initial state')) {
          _showGitHubErrorDialog(error);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(error)),
          );
        }
      }
    } catch (e) {
      // Handle any unexpected errors
      // Don't show error if it's redirect_in_progress
      if (mounted && e.toString().contains('redirect_in_progress')) {
        // App will redirect, don't show error
        return;
      }
      
      if (mounted) {
        final errorMsg = e.toString();
        if (errorMsg.contains('browser storage access') || 
            errorMsg.contains('sessionStorage') ||
            errorMsg.contains('missing initial state')) {
          _showGitHubErrorDialog(errorMsg);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('GitHub sign in failed: $errorMsg')),
          );
        }
      }
    }
  }

  void _showGitHubErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('GitHub Sign-In Issue'),
        content: SingleChildScrollView(
          child: Text(message),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authViewModel = context.watch<AuthViewModel>();

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Header
                Text(
                  AppStrings.loginTitle,
                  style: AppTextStyles.h2(),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  AppStrings.loginSubtitle,
                  style: AppTextStyles.bodyMedium(),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 40),

                // Email field
                CustomTextField(
                  label: AppStrings.loginEmail,
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  prefixIcon: const Icon(Icons.email_outlined),
                  validator: (value) {
                    if (value?.isEmpty ?? true) {
                      return AppStrings.errorEmptyField;
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 16),

                // Password field
                CustomTextField(
                  label: AppStrings.loginPassword,
                  controller: _passwordController,
                  obscureText: true,
                  prefixIcon: const Icon(Icons.lock_outline),
                  validator: (value) {
                    if (value?.isEmpty ?? true) {
                      return AppStrings.errorEmptyField;
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 8),

                // Forgot password
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () {
                      // TODO: Implement forgot password
                    },
                    child: Text(
                      AppStrings.loginForgotPassword,
                      style: AppTextStyles.labelMedium(
                        color: AppColors.primaryStart,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                // Sign in button
                CustomButton(
                  text: AppStrings.loginButton,
                  onPressed: _signIn,
                  isLoading: authViewModel.isLoading,
                ),

                const SizedBox(height: 24),

                // Divider
                Row(
                  children: [
                    const Expanded(child: Divider()),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Text(
                        'OR',
                        style: AppTextStyles.labelSmall(),
                      ),
                    ),
                    const Expanded(child: Divider()),
                  ],
                ),

                const SizedBox(height: 24),

                // Google sign in
                CustomButton(
                  text: AppStrings.loginWithGoogle,
                  onPressed: _signInWithGoogle,
                  isOutlined: true,
                  leadingIcon: const Icon(Icons.g_mobiledata, size: 28),
                  isLoading: authViewModel.isLoading,
                ),

                const SizedBox(height: 16),

                // GitHub sign in
                CustomButton(
                  text: AppStrings.loginWithGitHub,
                  onPressed: _signInWithGitHub,
                  isOutlined: true,
                  leadingIcon: const Icon(Icons.code, size: 24),
                  isLoading: authViewModel.isLoading,
                ),

                const SizedBox(height: 24),

                // Sign up link
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      AppStrings.loginNoAccount,
                      style: AppTextStyles.bodyMedium(),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pushReplacement(
                          MaterialPageRoute(
                            builder: (context) => const SignupScreen(),
                          ),
                        );
                      },
                      child: Text(
                        AppStrings.loginSignUp,
                        style: AppTextStyles.labelLarge(
                          color: AppColors.primaryStart,
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