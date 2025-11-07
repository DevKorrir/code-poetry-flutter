import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/theme/text_styles.dart';
import '../../../core/services/storage_service.dart';
import '../widgets/common/custom_button.dart';
import 'auth/guest_mode_prompt.dart';

/// Onboarding Screen
/// 3-slide walkthrough introducing the app
class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<OnboardingPage> _pages = const [
    OnboardingPage(
      icon: Icons.favorite,
      gradient: LinearGradient(
        colors: [Color(0xFFF093FB), Color(0xFFF5576C)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      title: AppStrings.onboardingTitle1,
      description: AppStrings.onboardingDesc1,
    ),
    OnboardingPage(
      icon: Icons.style,
      gradient: LinearGradient(
        colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      title: AppStrings.onboardingTitle2,
      description: AppStrings.onboardingDesc2,
    ),
    OnboardingPage(
      icon: Icons.share,
      gradient: LinearGradient(
        colors: [Color(0xFF4FACFE), Color(0xFF00F2FE)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      title: AppStrings.onboardingTitle3,
      description: AppStrings.onboardingDesc3,
    ),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onPageChanged(int page) {
    setState(() {
      _currentPage = page;
    });
  }

  Future<void> _completeOnboarding() async {
    // Mark onboarding as complete
    final storage = context.read<StorageService>();
    await storage.saveBool(StorageKeys.isOnboardingComplete, true);

    // Navigate to guest mode prompt
    if (!mounted) return;

    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (context) => const GuestModePrompt(),
      ),
    );
  }

  void _skip() {
    _completeOnboarding();
  }

  void _next() {
    if (_currentPage < _pages.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _completeOnboarding();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Skip button
            if (_currentPage < _pages.length - 1)
              Align(
                alignment: Alignment.topRight,
                child: TextButton(
                  onPressed: _skip,
                  child: Text(
                    AppStrings.onboardingSkip,
                    style: AppTextStyles.labelLarge(
                      color: AppColors.primaryStart,
                    ),
                  ),
                ),
              )
            else
              const SizedBox(height: 48),

            // Pages
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: _onPageChanged,
                itemCount: _pages.length,
                itemBuilder: (context, index) {
                  return _buildPage(_pages[index]);
                },
              ),
            ),

            // Page indicators
            _buildPageIndicator(),

            const SizedBox(height: 24),

            // Next/Get Started button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: CustomButton(
                text: _currentPage == _pages.length - 1
                    ? AppStrings.onboardingGetStarted
                    : AppStrings.onboardingNext,
                onPressed: _next,
                width: double.infinity,
              ),
            ),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildPage(OnboardingPage page) {
    return Container(
      decoration: BoxDecoration(gradient: page.gradient),
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Icon
            Container(
              width: 150,
              height: 150,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(
                page.icon,
                size: 80,
                color: Colors.white,
              ),
            ),

            const SizedBox(height: 60),

            // Title
            Text(
              page.title,
              style: AppTextStyles.h2(color: Colors.white),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 20),

            // Description
            Text(
              page.description,
              style: AppTextStyles.bodyLarge(
                color: Colors.white.withOpacity(0.9),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPageIndicator() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(
        _pages.length,
            (index) => AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: _currentPage == index ? 24 : 8,
          height: 8,
          decoration: BoxDecoration(
            color: _currentPage == index
                ? AppColors.primaryStart
                : AppColors.primaryStart.withOpacity(0.3),
            borderRadius: BorderRadius.circular(4),
          ),
        ),
      ),
    );
  }
}

/// Onboarding page data model
class OnboardingPage {
  final IconData icon;
  final Gradient gradient;
  final String title;
  final String description;

  const OnboardingPage({
    required this.icon,
    required this.gradient,
    required this.title,
    required this.description,
  });
}