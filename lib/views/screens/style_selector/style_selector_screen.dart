import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/theme/text_styles.dart';
import '../../../models/poetry_style_model.dart';
import '../../../viewmodels/poem_generator_viewmodel.dart';
import '../../../viewmodels/auth_viewmodel.dart';
import '../../widgets/common/custom_button.dart';
import '../poem_display/poem_display_screen.dart';

/// Style Selector Screen
/// User chooses poetry style (Haiku, Sonnet, Free Verse, Cyberpunk)
class StyleSelectorScreen extends StatefulWidget {
  const StyleSelectorScreen({super.key});

  @override
  State<StyleSelectorScreen> createState() => _StyleSelectorScreenState();
}

class _StyleSelectorScreenState extends State<StyleSelectorScreen>
    with SingleTickerProviderStateMixin {
  final PageController _pageController = PageController(viewportFraction: 0.85);
  int _currentPage = 0;

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _setupAnimations();

    // Set initial style
    final viewModel = context.read<PoemGeneratorViewModel>();
    final currentStyleIndex = PoetryStyleModel.allStyles.indexWhere(
          (style) => style.name == viewModel.style,
    );
    if (currentStyleIndex != -1) {
      _currentPage = currentStyleIndex;
      _pageController.addListener(_onPageChanged);
    }
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

    _animationController.forward();
  }

  void _onPageChanged() {
    final page = _pageController.page?.round() ?? 0;
    if (page != _currentPage) {
      setState(() {
        _currentPage = page;
      });

      final viewModel = context.read<PoemGeneratorViewModel>();
      viewModel.updateStyle(PoetryStyleModel.allStyles[page].name);

      HapticFeedback.selectionClick();
    }
  }

  Future<void> _generatePoem() async {
    final viewModel = context.read<PoemGeneratorViewModel>();
    final authViewModel = context.read<AuthViewModel>();

    HapticFeedback.mediumImpact();

    // Navigate to poem display screen
    Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            PoemDisplayScreen(
              isGuest: authViewModel.isGuest,
              isPro: authViewModel.isPro,
            ),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(
            opacity: animation,
            child: ScaleTransition(
              scale: Tween<double>(
                begin: 0.8,
                end: 1.0,
              ).animate(CurvedAnimation(
                parent: animation,
                curve: Curves.easeOut,
              )),
              child: child,
            ),
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    _pageController.removeListener(_onPageChanged);
    _pageController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<PoemGeneratorViewModel>();

    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.styleSelectorTitle),
      ),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: Column(
          children: [
            // Subtitle
            Padding(
              padding: const EdgeInsets.all(20),
              child: Text(
                AppStrings.styleSelectorSubtitle,
                style: AppTextStyles.bodyLarge(),
                textAlign: TextAlign.center,
              ),
            ),

            // Style cards carousel
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                itemCount: PoetryStyleModel.allStyles.length,
                onPageChanged: (index) {
                  setState(() {
                    _currentPage = index;
                  });
                  viewModel.updateStyle(
                    PoetryStyleModel.allStyles[index].name,
                  );
                  HapticFeedback.selectionClick();
                },
                itemBuilder: (context, index) {
                  return _buildStyleCard(
                    PoetryStyleModel.allStyles[index],
                    index,
                  );
                },
              ),
            ),

            // Page indicator
            _buildPageIndicator(),

            const SizedBox(height: 24),

            // Tip
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.info.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: AppColors.info.withOpacity(0.3),
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.info_outline,
                      size: 20,
                      color: AppColors.info,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        AppStrings.tipStyleSelect,
                        style: AppTextStyles.caption(
                          color: AppColors.info,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Generate button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: SafeArea(
                child: CustomButton(
                  text: AppStrings.styleGenerate,
                  onPressed: _generatePoem,
                  leadingIcon: const Icon(Icons.auto_awesome, size: 24),
                  width: double.infinity,
                  height: 60,
                ),
              ),
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildStyleCard(PoetryStyleModel style, int index) {
    final isSelected = _currentPage == index;
    final scale = isSelected ? 1.0 : 0.9;

    return AnimatedScale(
      scale: scale,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(isSelected ? 0.3 : 0.1),
              blurRadius: isSelected ? 20 : 10,
              offset: Offset(0, isSelected ? 10 : 5),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: Container(
            decoration: BoxDecoration(
              gradient: PoetryStyleColors.getGradient(style.name),
            ),
            child: Stack(
              children: [
                // Background pattern
                Positioned.fill(
                  child: Opacity(
                    opacity: 0.1,
                    child: CustomPaint(
                      painter: PatternPainter(),
                    ),
                  ),
                ),

                // Content
                Padding(
                  padding: const EdgeInsets.all(32),
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Icon
                        Text(
                          style.icon,
                          style: const TextStyle(fontSize: 80),
                        ),

                        const SizedBox(height: 24),

                        // Style name
                        Text(
                          style.displayName,
                          style: AppTextStyles.h2(color: Colors.white),
                          textAlign: TextAlign.center,
                        ),

                        const SizedBox(height: 16),

                        // Description
                        Text(
                          style.description,
                          style: AppTextStyles.bodyLarge(
                            color: Colors.white.withOpacity(0.9),
                          ),
                          textAlign: TextAlign.center,
                        ),

                        const SizedBox(height: 32),

                        // Example poem
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: Colors.white.withOpacity(0.2),
                            ),
                          ),
                          child: Text(
                            _getExamplePoem(style.name),
                            style: AppTextStyles.poetryMedium(
                              color: Colors.white,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ],
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

  Widget _buildPageIndicator() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(
        PoetryStyleModel.allStyles.length,
            (index) => AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: _currentPage == index ? 32 : 8,
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

  String _getExamplePoem(String styleName) {
    switch (styleName.toLowerCase()) {
      case 'haiku':
        return 'Code flows like water\nVariables dance in light\nLogic finds its peace';
      case 'sonnet':
        return 'When logic speaks in elegant refrain\nAnd functions dance in perfect harmony...';
      case 'free verse':
        return 'Your loops spiral upward,\neach iteration a breath,\nwhispering truths to silicon...';
      case 'cyberpunk':
        return 'Electric pulses race through neon veins\nCircuits hum with digital dreams...';
      default:
        return 'Your code will be transformed into beautiful poetry.';
    }
  }
}

/// Custom painter for decorative pattern
class PatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;

    // Draw grid pattern
    for (var i = 0; i < size.width; i += 40) {
      canvas.drawLine(
        Offset(i.toDouble(), 0),
        Offset(i.toDouble(), size.height),
        paint,
      );
    }

    for (var i = 0; i < size.height; i += 40) {
      canvas.drawLine(
        Offset(0, i.toDouble()),
        Offset(size.width, i.toDouble()),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}