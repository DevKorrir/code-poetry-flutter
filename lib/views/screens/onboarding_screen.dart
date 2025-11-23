import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/theme/text_styles.dart';
import '../../../core/services/storage_service.dart';
import '../widgets/common/custom_button.dart';
import 'auth/guest_mode_prompt.dart';

/// Modern Onboarding Screen with Smooth Animations
class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen>
    with TickerProviderStateMixin {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  late AnimationController _iconController;
  late AnimationController _fadeController;

  final List<OnboardingPage> _pages = const [
    OnboardingPage(
      icon: Icons.favorite_rounded,
      gradient: AppColors.accentGradient,
      title: AppStrings.onboardingTitle1,
      description: AppStrings.onboardingDesc1,
      particles: [
        Particle(icon: Icons.favorite, size: 20, offset: Offset(-30, -50)),
        Particle(icon: Icons.favorite, size: 15, offset: Offset(40, -30)),
        Particle(icon: Icons.favorite, size: 18, offset: Offset(-50, 40)),
        Particle(icon: Icons.favorite, size: 12, offset: Offset(50, 50)),
      ],
    ),
    OnboardingPage(
      icon: Icons.auto_awesome_rounded,
      gradient: AppColors.secondaryGradient,
      title: AppStrings.onboardingTitle2,
      description: AppStrings.onboardingDesc2,
      particles: [
        Particle(icon: Icons.star, size: 16, offset: Offset(-40, -40)),
        Particle(icon: Icons.star, size: 14, offset: Offset(35, -45)),
        Particle(icon: Icons.star, size: 20, offset: Offset(-35, 45)),
        Particle(icon: Icons.star, size: 12, offset: Offset(45, 35)),
      ],
    ),
    OnboardingPage(
      icon: Icons.share_rounded,
      gradient: AppColors.primaryGradient,
      title: AppStrings.onboardingTitle3,
      description: AppStrings.onboardingDesc3,
      particles: [
        Particle(icon: Icons.people, size: 18, offset: Offset(-45, -35)),
        Particle(icon: Icons.favorite, size: 14, offset: Offset(40, -40)),
        Particle(icon: Icons.share, size: 16, offset: Offset(-40, 50)),
        Particle(icon: Icons.people, size: 12, offset: Offset(50, 40)),
      ],
    ),
  ];

  @override
  void initState() {
    super.initState();
    _iconController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _iconController.forward();
    _fadeController.forward();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _iconController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  void _onPageChanged(int page) {
    setState(() {
      _currentPage = page;
    });
    _iconController.reset();
    _fadeController.reset();
    _iconController.forward();
    _fadeController.forward();
  }

  Future<void> _completeOnboarding() async {
    final storage = context.read<StorageService>();
    await storage.saveBool(StorageKeys.isOnboardingComplete, true);

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
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOutCubic,
      );
    } else {
      _completeOnboarding();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Animated background with gradient
          AnimatedContainer(
            duration: const Duration(milliseconds: 600),
            decoration: BoxDecoration(
              gradient: _pages[_currentPage].gradient,
            ),
          ),

          SafeArea(
            child: Column(
              children: [
                // Top bar with skip button
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 12,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      if (_currentPage < _pages.length - 1)
                        Material(
                          color: AppColors.darkSurfaceLight,
                          borderRadius: BorderRadius.circular(20),
                          child: InkWell(
                            onTap: _skip,
                            borderRadius: BorderRadius.circular(20),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 8,
                              ),
                              child: Text(
                                AppStrings.onboardingSkip,
                                style: AppTextStyles.labelLarge(
                                  color: Colors.white,
                                ).copyWith(fontWeight: FontWeight.w600),
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),

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

                // Bottom section
                Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: [
                      // Page indicators
                      _buildPageIndicator(),
                      const SizedBox(height: 32),

                      // Next/Get Started button
                      _buildButton(),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPage(OnboardingPage page) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Animated Icon with particles
          Stack(
            alignment: Alignment.center,
            children: [
              // Floating particles
              ...page.particles.map((particle) {
                return TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0.0, end: 1.0),
                  duration: const Duration(milliseconds: 1200),
                  curve: Curves.easeOutBack,
                  builder: (context, value, child) {
                    return Transform.translate(
                      offset: particle.offset * value,
                      child: Opacity(
                        opacity: value * 0.6,
                        child: Icon(
                          particle.icon,
                          size: particle.size,
                          color: Colors.white,
                        ),
                      ),
                    );
                  },
                );
              }).toList(),

              // Main icon container
              ScaleTransition(
                scale: CurvedAnimation(
                  parent: _iconController,
                  curve: Curves.elasticOut,
                ),
                child: Container(
                  width: 180,
                  height: 180,
                  decoration: BoxDecoration(
                    color: AppColors.darkSurfaceLight,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 40,
                        spreadRadius: 10,
                      ),
                    ],
                  ),
                  child: Container(
                    margin: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.darkSurface,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      page.icon,
                      size: 90,
                      color: AppColors.primaryStart,
                    ),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 60),

          // Title with fade animation
          FadeTransition(
            opacity: _fadeController,
            child: SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0, 0.3),
                end: Offset.zero,
              ).animate(CurvedAnimation(
                parent: _fadeController,
                curve: Curves.easeOut,
              )),
              child: Text(
                page.title,
                style: AppTextStyles.h2(color: Colors.white).copyWith(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  letterSpacing: -0.5,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),

          const SizedBox(height: 20),

          // Description with fade animation
          FadeTransition(
            opacity: _fadeController,
            child: SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0, 0.4),
                end: Offset.zero,
              ).animate(CurvedAnimation(
                parent: _fadeController,
                curve: Curves.easeOut,
              )),
              child: Text(
                page.description,
                style: AppTextStyles.bodyLarge(
                  color: Colors.white,
                ).copyWith(
                  fontSize: 16,
                  height: 1.6,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ],
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
          width: _currentPage == index ? 32 : 8,
          height: 8,
          decoration: BoxDecoration(
            color: _currentPage == index
                ? AppColors.primaryStart
                : AppColors.darkSurfaceLight,
            borderRadius: BorderRadius.circular(4),
            boxShadow: _currentPage == index
                ? [
              BoxShadow(
                color: AppColors.primaryStart.withOpacity(0.5),
                blurRadius: 8,
                spreadRadius: 1,
              ),
            ]
                : [],
          ),
        ),
      ),
    );
  }

  Widget _buildButton() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.darkBackground.withOpacity(0.7),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Material(
        color: AppColors.darkBackground,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          onTap: _next,
          borderRadius: BorderRadius.circular(16),
          child: Container(
            width: double.infinity,
            height: 56,
            alignment: Alignment.center,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  _currentPage == _pages.length - 1
                      ? AppStrings.onboardingGetStarted
                      : AppStrings.onboardingNext,
                  style: AppTextStyles.labelLarge(
                    color: AppColors.primaryStart,
                  ).copyWith(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(width: 8),
                Icon(
                  _currentPage == _pages.length - 1
                      ? Icons.check_circle_rounded
                      : Icons.arrow_forward_rounded,
                  color: AppColors.primaryStart,
                  size: 22,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Particle data model for floating animations
class Particle {
  final IconData icon;
  final double size;
  final Offset offset;

  const Particle({
    required this.icon,
    required this.size,
    required this.offset,
  });
}

/// Onboarding page data model
class OnboardingPage {
  final IconData icon;
  final Gradient gradient;
  final String title;
  final String description;
  final List<Particle> particles;

  const OnboardingPage({
    required this.icon,
    required this.gradient,
    required this.title,
    required this.description,
    required this.particles,
  });
}