import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/theme/text_styles.dart';
import '../../../viewmodels/auth_viewmodel.dart';
import '../../widgets/common/custom_button.dart';

class GitHubConnectScreen extends StatefulWidget {
  const GitHubConnectScreen({super.key});

  @override
  State<GitHubConnectScreen> createState() => _GitHubConnectScreenState();
}

class _GitHubConnectScreenState extends State<GitHubConnectScreen> {
  bool _isLoading = false;

  Future<void> _connectGitHub() async {
    setState(() => _isLoading = true);

    try {
      final authViewModel = context.read<AuthViewModel>();
      
      // Sign in with GitHub via Firebase
      await authViewModel.signInWithGitHub();

      if (mounted) {
        Navigator.pop(context, true);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('GitHub connected successfully!'),
            backgroundColor: AppColors.success,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to connect: ${e.toString()}'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF24292E), Color(0xFF0D1117)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // GitHub logo
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.code_rounded,
                    size: 50,
                    color: Color(0xFF24292E),
                  ),
                ),

                const SizedBox(height: 32),

                Text(
                  'Connect GitHub',
                  style: AppTextStyles.h2(color: Colors.white),
                ),

                const SizedBox(height: 16),

                Text(
                  'Import code directly from your repositories',
                  style: AppTextStyles.bodyLarge(
                    color: Colors.white.withOpacity(0.8),
                  ),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 48),

                // Benefits
                _buildBenefit('✓ One-tap sign in'),
                _buildBenefit('✓ Secure OAuth connection'),
                _buildBenefit('✓ Browse all repositories'),
                _buildBenefit('✓ No tokens to manage'),

                const Spacer(),

                // Connect Button
                CustomButton(
                  text: 'Connect with GitHub',
                  onPressed: _isLoading ? null : _connectGitHub,
                  isLoading: _isLoading,
                  backgroundColor: Colors.white,
                  textColor: const Color(0xFF24292E),
                  width: double.infinity,
                  height: 56,
                  leadingIcon: const Icon(Icons.code, size: 24),
                  isGradient: false,
                ),

                const SizedBox(height: 16),

                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(
                    'Skip for now',
                    style: AppTextStyles.labelMedium(
                      color: Colors.white.withOpacity(0.7),
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                // Info
                Text(
                  'We only request read access to your repositories',
                  style: AppTextStyles.caption(
                    color: Colors.white.withOpacity(0.5),
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBenefit(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          const Icon(
            Icons.check_circle,
            color: AppColors.success,
            size: 20,
          ),
          const SizedBox(width: 12),
          Text(
            text,
            style: AppTextStyles.bodyMedium(
              color: Colors.white.withOpacity(0.9),
            ),
          ),
        ],
      ),
    );
  }
}

