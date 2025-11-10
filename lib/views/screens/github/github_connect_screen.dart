import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/theme/text_styles.dart';
import '../../../core/services/auth_service.dart';

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
      // Sign in with GitHub using Firebase Auth
      final user = await AuthService().signInWithGitHub();

      if (mounted) {
        Navigator.pop(context, true);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Connected as ${user.displayName ?? user.email}'),
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
                  'Access your repositories and import code directly',
                  style: AppTextStyles.bodyLarge(
                    color: Colors.white.withOpacity(0.8),
                  ),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 48),

                // Features list
                _buildFeature('Browse your repositories'),
                _buildFeature('Pick files directly'),
                _buildFeature('No more copy-paste'),
                _buildFeature('Secure OAuth connection'),

                const Spacer(),

                // Connect button
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _connectGitHub,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: const Color(0xFF24292E),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: _isLoading
                        ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                        : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.code),
                        const SizedBox(width: 8),
                        Text(
                          'Connect GitHub',
                          style: AppTextStyles.buttonLarge(
                            color: const Color(0xFF24292E),
                          ),
                        ),
                      ],
                    ),
                  ),
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
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFeature(String text) {
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

