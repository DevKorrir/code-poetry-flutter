import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/services/auth_service.dart';
import '../../../core/services/github_service.dart';
import '../../../core/theme/text_styles.dart';
import '../../widgets/common/custom_button.dart';

class GitHubTokenScreen extends StatefulWidget {
  const GitHubTokenScreen({super.key});

  @override
  State<GitHubTokenScreen> createState() => _GitHubTokenScreenState();
}

class _GitHubTokenScreenState extends State<GitHubTokenScreen> {
  final TextEditingController _tokenController = TextEditingController();
  bool _isLoading = false;
  bool _isConnected = false;
  String? _userName;

  @override
  void initState() {
    super.initState();
    _checkConnectionStatus();
  }

  Future<void> _checkConnectionStatus() async {
    final authService = AuthService();
    final hasToken = await authService.hasGitHubToken();

    if (hasToken && mounted) {
      setState(() {
        _isConnected = true;
      });

      // Try to get user info to show username
      try {
        final user = await GitHubService().getCurrentUser();
        if (mounted) {
          setState(() {
            _userName = user.login;
          });
        }
      } catch (e) {
        // Token might be invalid, clear it
        await authService.clearGitHubToken();
        if (mounted) {
          setState(() {
            _isConnected = false;
          });
        }
      }
    }
  }

  Future<void> _connectWithToken() async {
    if (_tokenController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter your GitHub token'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final authService = AuthService();
      final success = await authService.connectWithGitHubToken(_tokenController.text.trim());

      if (success && mounted) {
        // Get user info for display
        final user = await GitHubService().getCurrentUser();

        if (!mounted) return;

        setState(() {
          _isConnected = true;
          _userName = user.login;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Connected to GitHub as ${user.login}!'),
            backgroundColor: AppColors.success,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString()),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _disconnectGitHub() async {
    setState(() => _isLoading = true);

    try {
      await AuthService().disconnectGitHub();

      if (mounted) {
        setState(() {
          _isConnected = false;
          _userName = null;
          _tokenController.clear();
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Disconnected from GitHub'),
            backgroundColor: AppColors.info,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to disconnect: ${e.toString()}'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _copyTokenInstructions() {
    const instructions = '''
1. Go to GitHub Settings → Developer settings → Personal access tokens → Tokens (classic)
2. Click "Generate new token" → "Generate new token (classic)"
3. Give it a name (e.g., "Code Poetry")
4. Select these scopes: repo, read:org, read:user, user:email
5. Click "Generate token" and paste it above''';

    Clipboard.setData(const ClipboardData(text: instructions));

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Instructions copied to clipboard!'),
        duration: Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Connect GitHub'),
        backgroundColor: const Color(0xFF24292E),
        foregroundColor: Colors.white,
      ),
      body: Container(
        color: const Color(0xFF0D1117),
        child: SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  // GitHub logo
                  Container(
                    width: 80,
                    height: 80,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: FaIcon(
                        FontAwesomeIcons.github,
                        size: 40,
                        color: const Color(0xFF24292E),
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  Text(
                    'Connect GitHub',
                    style: AppTextStyles.h2(color: Colors.white),
                  ),

                  const SizedBox(height: 8),

                  Text(
                    'Import code directly from your repositories',
                    style: AppTextStyles.bodyLarge(
                      color: Colors.white.withOpacity(0.8),
                    ),
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: 32),

                  // Connection status
                  if (_isConnected && _userName != null)
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.success.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.success),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.check_circle, color: AppColors.success),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'Connected as $_userName',
                              style: AppTextStyles.bodyMedium(color: Colors.white),
                            ),
                          ),
                        ],
                      ),
                    ),

                  const SizedBox(height: 24),

                  // Token input
                  TextField(
                    controller: _tokenController,
                    decoration: InputDecoration(
                      labelText: 'GitHub Personal Access Token',
                      labelStyle: const TextStyle(color: Colors.white70),
                      hintText: 'ghp_xxxxxxxxxxxxxxxxxxxx',
                      hintStyle: TextStyle(color: Colors.white.withOpacity(0.5)),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.white.withOpacity(0.3)),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.white.withOpacity(0.3)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Colors.white),
                      ),
                      filled: true,
                      fillColor: Colors.white.withOpacity(0.1),
                    ),
                    style: const TextStyle(color: Colors.white),
                    obscureText: true,
                    enabled: !_isConnected,
                  ),

                  const SizedBox(height: 16),

                  // Instructions
                  ExpansionTile(
                    title: const Text(
                      'How to get a GitHub Token',
                      style: TextStyle(color: Colors.white),
                    ),
                    collapsedIconColor: Colors.white,
                    iconColor: Colors.white,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildStep(1, 'Go to GitHub Settings → Developer settings → Personal access tokens → Tokens (classic)'),
                            _buildStep(2, 'Click "Generate new token" → "Generate new token (classic)"'),
                            _buildStep(3, 'Give it a name (e.g., "Code Poetry")'),
                            _buildStep(4, 'Select these scopes: repo, read:org, read:user, user:email'),
                            _buildStep(5, 'Click "Generate token" and paste it above'),

                            const SizedBox(height: 16),

                            CustomButton(
                              text: 'Copy Instructions',
                              onPressed: _copyTokenInstructions,
                              isOutlined: true,
                              width: double.infinity,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 32),

                  // Action buttons
                  if (_isConnected)
                    Column(
                      children: [
                        CustomButton(
                          text: 'Browse Repositories',
                          onPressed: () => Navigator.pop(context, true),
                          backgroundColor: AppColors.success,
                          width: double.infinity,
                          height: 56,
                        ),
                        const SizedBox(height: 12),
                        CustomButton(
                          text: 'Disconnect GitHub',
                          onPressed: _isLoading ? null : _disconnectGitHub,
                          isOutlined: true,
                          textColor: AppColors.error,
                          width: double.infinity,
                          height: 56,
                        ),
                      ],
                    )
                  else
                    Column(
                      children: [
                        CustomButton(
                          text: 'Connect with Token',
                          onPressed: _isLoading ? null : _connectWithToken,
                          isLoading: _isLoading,
                          backgroundColor: Colors.white,
                          textColor: const Color(0xFF24292E),
                          width: double.infinity,
                          height: 56,
                        ),
                        const SizedBox(height: 12),
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
      ),
    );
  }

  Widget _buildStep(int number, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$number. ',
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(color: Colors.white70),
            ),
          ),
        ],
      ),
    );
  }
}