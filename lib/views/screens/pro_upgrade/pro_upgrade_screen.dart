import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/theme/text_styles.dart';
import '../../../viewmodels/auth_viewmodel.dart';
import '../../widgets/common/custom_button.dart';

/// Pro Upgrade Screen
/// Feature comparison and upgrade flow
class ProUpgradeScreen extends StatefulWidget {
  const ProUpgradeScreen({super.key});

  @override
  State<ProUpgradeScreen> createState() => _ProUpgradeScreenState();
}

class _ProUpgradeScreenState extends State<ProUpgradeScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  bool _isAnnual = true; // Toggle between monthly and annual

  @override
  void initState() {
    super.initState();
    _setupAnimations();
  }

  void _setupAnimations() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutBack,
    ));

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _upgradeToPro() async {
    // Show loading
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(),
      ),
    );

    // Simulate payment processing
    await Future.delayed(const Duration(seconds: 2));

    final authViewModel = context.read<AuthViewModel>();
    final success = await authViewModel.upgradeToPro();

    if (mounted) {
      Navigator.pop(context); // Close loading

      if (success) {
        // Show success dialog
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    gradient: AppColors.successGradient,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.star,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(width: 12),
                const Text('Welcome to Pro!'),
              ],
            ),
            content: const Text(
              'You now have unlimited access to all features. Enjoy creating beautiful code poetry!',
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context); // Close dialog
                  Navigator.pop(context); // Close upgrade screen
                },
                child: const Text('Start Creating'),
              ),
            ],
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // App bar
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.arrow_back,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Content
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: [
                      // Animated star icon
                      ScaleTransition(
                        scale: _scaleAnimation,
                        child: Container(
                          width: 100,
                          height: 100,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.star,
                            size: 50,
                            color: Colors.white,
                          ),
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Title
                      Text(
                        'Upgrade to Pro',
                        style: AppTextStyles.h2(color: Colors.white),
                      ),

                      const SizedBox(height: 8),

                      // Subtitle
                      Text(
                        'Unlock unlimited poetry and all features',
                        style: AppTextStyles.bodyLarge(
                          color: Colors.white.withOpacity(0.9),
                        ),
                        textAlign: TextAlign.center,
                      ),

                      const SizedBox(height: 40),

                      // Pricing toggle
                      _buildPricingToggle(),

                      const SizedBox(height: 32),

                      // Feature comparison
                      _buildFeatureComparison(),

                      const SizedBox(height: 32),

                      // Upgrade button
                      CustomButton(
                        text: 'Upgrade Now',
                        onPressed: _upgradeToPro,
                        backgroundColor: Colors.white,
                        textColor: AppColors.primaryStart,
                        width: double.infinity,
                        height: 60,
                        leadingIcon: const Icon(Icons.star, size: 24),
                        isGradient: false,
                      ),

                      const SizedBox(height: 16),

                      // Restore purchase
                      TextButton(
                        onPressed: () async {
                          final authViewModel = context.read<AuthViewModel>();
                          final restored =
                          await authViewModel.restoreProPurchase();

                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  restored
                                      ? 'Pro subscription restored!'
                                      : 'No Pro subscription found',
                                ),
                                backgroundColor: restored
                                    ? AppColors.success
                                    : AppColors.error,
                              ),
                            );
                          }
                        },
                        child: Text(
                          'Restore Purchase',
                          style: AppTextStyles.labelMedium(
                            color: Colors.white,
                          ),
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Terms
                      Text(
                        'Terms apply. Cancel anytime.',
                        style: AppTextStyles.caption(
                          color: Colors.white.withOpacity(0.7),
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPricingToggle() {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () {
                HapticFeedback.selectionClick();
                setState(() {
                  _isAnnual = false;
                });
              },
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: !_isAnnual
                      ? Colors.white
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  children: [
                    Text(
                      'Monthly',
                      style: AppTextStyles.labelLarge(
                        color: !_isAnnual
                            ? AppColors.primaryStart
                            : Colors.white,
                      ).copyWith(fontWeight: FontWeight.bold),
                    ),
                    Text(
                      '\$4.99/mo',
                      style: AppTextStyles.bodyMedium(
                        color: !_isAnnual
                            ? AppColors.primaryStart
                            : Colors.white.withOpacity(0.8),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Expanded(
            child: GestureDetector(
              onTap: () {
                HapticFeedback.selectionClick();
                setState(() {
                  _isAnnual = true;
                });
              },
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: _isAnnual
                      ? Colors.white
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Stack(
                  children: [
                    Column(
                      children: [
                        Text(
                          'Annual',
                          style: AppTextStyles.labelLarge(
                            color: _isAnnual
                                ? AppColors.primaryStart
                                : Colors.white,
                          ).copyWith(fontWeight: FontWeight.bold),
                        ),
                        Text(
                          '\$29.99/yr',
                          style: AppTextStyles.bodyMedium(
                            color: _isAnnual
                                ? AppColors.primaryStart
                                : Colors.white.withOpacity(0.8),
                          ),
                        ),
                      ],
                    ),
                    // Save badge
                    Positioned(
                      top: -8,
                      right: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.warning,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          'SAVE 50%',
                          style: AppTextStyles.labelSmall(
                            color: Colors.black,
                          ).copyWith(fontSize: 9),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureComparison() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.white.withOpacity(0.2),
          width: 2,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Expanded(
                child: Text(
                  'Features',
                  style: AppTextStyles.labelLarge(color: Colors.white)
                      .copyWith(fontWeight: FontWeight.bold),
                ),
              ),
              Text(
                'Free',
                style: AppTextStyles.labelMedium(
                  color: Colors.white.withOpacity(0.7),
                ),
              ),
              const SizedBox(width: 24),
              Text(
                'Pro',
                style: AppTextStyles.labelMedium(color: Colors.white)
                    .copyWith(fontWeight: FontWeight.bold),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // Features
          _buildFeatureRow('Poems per day', '5', 'Unlimited'),
          _buildFeatureRow('Poetry styles', '4', '4'),
          _buildFeatureRow('Save poems', true, true),
          _buildFeatureRow('Cloud sync', true, true),
          _buildFeatureRow('Voice reading', false, true),
          _buildFeatureRow('Export as image', false, true),
          _buildFeatureRow('Custom styles', false, true),
          _buildFeatureRow('No watermark', false, true),
          _buildFeatureRow('Priority support', false, true),
        ],
      ),
    );
  }

  Widget _buildFeatureRow(String feature, dynamic free, dynamic pro) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: Text(
              feature,
              style: AppTextStyles.bodyMedium(
                color: Colors.white.withOpacity(0.9),
              ),
            ),
          ),
          SizedBox(
            width: 50,
            child: Center(
              child: _buildFeatureValue(free),
            ),
          ),
          const SizedBox(width: 24),
          SizedBox(
            width: 50,
            child: Center(
              child: _buildFeatureValue(pro, isPro: true),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureValue(dynamic value, {bool isPro = false}) {
    if (value is bool) {
      return Icon(
        value ? Icons.check_circle : Icons.cancel,
        color: value
            ? (isPro ? AppColors.warning : Colors.white.withOpacity(0.6))
            : Colors.white.withOpacity(0.3),
        size: 20,
      );
    } else {
      return Text(
        value.toString(),
        style: AppTextStyles.labelMedium(
          color: isPro ? AppColors.warning : Colors.white.withOpacity(0.7),
        ).copyWith(fontWeight: isPro ? FontWeight.bold : null),
      );
    }
  }
}