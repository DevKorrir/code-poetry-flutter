import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/theme/text_styles.dart';
import '../../../viewmodels/poem_generator_viewmodel.dart';
import '../../../models/poem_model.dart';
import '../../widgets/common/custom_button.dart';
import '../../widgets/common/loading_indicator.dart';
import '../../widgets/common/error_view.dart';

/// Poem Display Screen
/// Shows generated poem with beautiful animations
class PoemDisplayScreen extends StatefulWidget {
  final bool isGuest;
  final bool isPro;

  const PoemDisplayScreen({
    super.key,
    required this.isGuest,
    required this.isPro,
  });

  @override
  State<PoemDisplayScreen> createState() => _PoemDisplayScreenState();
}

class _PoemDisplayScreenState extends State<PoemDisplayScreen>
    with TickerProviderStateMixin {
  late AnimationController _backgroundController;
  late AnimationController _poemController;
  late Animation<double> _backgroundAnimation;

  bool _isGenerating = false;
  bool _showPoem = false;
  String _displayedPoem = '';
  int _currentCharIndex = 0;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _generatePoem();
  }

  void _setupAnimations() {
    // Background gradient animation
    _backgroundController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat(reverse: true);

    _backgroundAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(_backgroundController);

    // Poem typewriter animation controller
    _poemController = AnimationController(
      duration: const Duration(milliseconds: 50),
      vsync: this,
    );
  }

  Future<void> _generatePoem() async {
    setState(() {
      _isGenerating = true;
      _showPoem = false;
    });

    final viewModel = context.read<PoemGeneratorViewModel>();

    final success = await viewModel.generatePoem(
      isGuest: widget.isGuest,
      isPro: widget.isPro,
    );

    if (success && mounted) {
      await Future.delayed(const Duration(milliseconds: 500));
      _startTypewriterEffect(viewModel.generatedPoem!.poem);
    }

    if (mounted) {
      setState(() {
        _isGenerating = false;
      });
    }
  }

  void _startTypewriterEffect(String poem) {
    setState(() {
      _showPoem = true;
      _displayedPoem = '';
      _currentCharIndex = 0;
    });

    // Typewriter effect
    final chars = poem.split('');

    Future.doWhile(() async {
      if (!mounted) return false;
      if (_currentCharIndex >= chars.length) return false;

      await Future.delayed(const Duration(milliseconds: 30));

      if (mounted) {
        setState(() {
          _displayedPoem += chars[_currentCharIndex];
          _currentCharIndex++;
        });
      }

      return _currentCharIndex < chars.length;
    }).then((_) {
      // Celebration animation when complete
      if (mounted) {
        HapticFeedback.heavyImpact();
        _showCelebration();
      }
    });
  }

  void _showCelebration() {
    // Show confetti or success animation
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white),
            const SizedBox(width: 8),
            Text(AppStrings.successMessage ?? 'Poem generated!'),
          ],
        ),
        backgroundColor: AppColors.success,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }

  Future<void> _savePoem() async {
    final viewModel = context.read<PoemGeneratorViewModel>();
    final success = await viewModel.savePoem();

    if (success && mounted) {
      HapticFeedback.mediumImpact();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(AppStrings.poemSaved),
          backgroundColor: AppColors.success,
        ),
      );
    }
  }

  void _sharePoem() {
    final viewModel = context.read<PoemGeneratorViewModel>();
    if (viewModel.generatedPoem != null) {
      HapticFeedback.mediumImpact();

      final poem = viewModel.generatedPoem!;
      final shareText = '''
${poem.poem}

---
Style: ${poem.style}
Language: ${poem.language}

Generated with Code Poetry
      '''.trim();

      Share.share(shareText);
    }
  }

  Future<void> _regeneratePoem() async {
    final viewModel = context.read<PoemGeneratorViewModel>();

    // Show style selector dialog
    final newStyle = await showDialog<String>(
      context: context,
      builder: (context) => _buildStyleDialog(),
    );

    if (newStyle != null && mounted) {
      setState(() {
        _isGenerating = true;
        _showPoem = false;
      });

      final success = await viewModel.regenerateWithStyle(
        newStyle,
        isGuest: widget.isGuest,
        isPro: widget.isPro,
      );

      if (success && mounted) {
        await Future.delayed(const Duration(milliseconds: 500));
        _startTypewriterEffect(viewModel.generatedPoem!.poem);
      }

      if (mounted) {
        setState(() {
          _isGenerating = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _backgroundController.dispose();
    _poemController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<PoemGeneratorViewModel>();

    return Scaffold(
      body: AnimatedBuilder(
        animation: _backgroundAnimation,
        builder: (context, child) {
          return Container(
            decoration: BoxDecoration(
              gradient: _getAnimatedGradient(viewModel.style),
            ),
            child: child,
          );
        },
        child: SafeArea(
          child: Column(
            children: [
              // App bar
              _buildAppBar(),

              // Content
              Expanded(
                child: _isGenerating
                    ? _buildLoadingView()
                    : viewModel.error != null
                    ? _buildErrorView(viewModel)
                    : _showPoem
                    ? _buildPoemView(viewModel)
                    : const SizedBox.shrink(),
              ),

              // Action buttons
              if (_showPoem && !_isGenerating)
                _buildActionButtons(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAppBar() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.of(context).pop(),
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
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              AppStrings.poemDisplayTitle,
              style: AppTextStyles.labelLarge(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingView() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Animated icon
        TweenAnimationBuilder<double>(
          tween: Tween(begin: 0.0, end: 1.0),
          duration: const Duration(seconds: 2),
          builder: (context, value, child) {
            return Transform.scale(
              scale: 0.8 + (value * 0.2),
              child: Transform.rotate(
                angle: value * 6.28, // Full rotation
                child: Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.auto_awesome,
                    size: 50,
                    color: Colors.white,
                  ),
                ),
              ),
            );
          },
          onEnd: () {
            // Repeat animation
            if (mounted && _isGenerating) {
              setState(() {});
            }
          },
        ),

        const SizedBox(height: 32),

        Text(
          AppStrings.poemGenerating,
          style: AppTextStyles.h4(color: Colors.white),
        ),

        const SizedBox(height: 16),

        const SizedBox(
          width: 200,
          child: LinearProgressIndicator(
            backgroundColor: Colors.white24,
            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
          ),
        ),
      ],
    );
  }

  Widget _buildErrorView(PoemGeneratorViewModel viewModel) {
    return ErrorView(
      message: viewModel.error!,
      onRetry: _generatePoem,
    );
  }

  Widget _buildPoemView(PoemGeneratorViewModel viewModel) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          // Style badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(25),
              border: Border.all(
                color: Colors.white.withOpacity(0.3),
                width: 2,
              ),
            ),
            child: Text(
              viewModel.style.toUpperCase(),
              style: AppTextStyles.labelLarge(color: Colors.white)
                  .copyWith(fontWeight: FontWeight.bold),
            ),
          ),

          const SizedBox(height: 40),

          // Poem text with typewriter effect
          Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: Colors.white.withOpacity(0.2),
                width: 2,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Text(
              _displayedPoem,
              style: AppTextStyles.poetryLarge(color: Colors.white)
                  .copyWith(height: 1.8),
              textAlign: TextAlign.center,
            ),
          ),

          const SizedBox(height: 40),

          // Code preview
          if (viewModel.code.isNotEmpty)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.3),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.code,
                        size: 16,
                        color: Colors.white.withOpacity(0.7),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Original Code (${viewModel.language})',
                        style: AppTextStyles.labelSmall(
                          color: Colors.white.withOpacity(0.7),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    _getCodePreview(viewModel.code),
                    style: AppTextStyles.codeSmall(
                      color: Colors.white.withOpacity(0.9),
                    ),
                    maxLines: 5,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.2),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              // Share button
              Expanded(
                child: CustomButton(
                  text: AppStrings.poemShare,
                  onPressed: _sharePoem,
                  leadingIcon: const Icon(Icons.share, size: 20),
                  backgroundColor: Colors.white.withOpacity(0.2),
                  isGradient: false,
                ),
              ),
              const SizedBox(width: 12),
              // Save button
              Expanded(
                child: CustomButton(
                  text: AppStrings.poemSave,
                  onPressed: _savePoem,
                  leadingIcon: const Icon(Icons.favorite, size: 20),
                  backgroundColor: Colors.white,
                  textColor: AppColors.primaryStart,
                  isGradient: false,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Regenerate button
          CustomButton(
            text: AppStrings.poemRegenerate,
            onPressed: _regeneratePoem,
            leadingIcon: const Icon(Icons.refresh, size: 20),
            isOutlined: true,
            textColor: Colors.white,
            width: double.infinity,
          ),
        ],
      ),
    );
  }

  Widget _buildStyleDialog() {
    return AlertDialog(
      title: const Text('Choose New Style'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildStyleOption('haiku', 'Haiku'),
          _buildStyleOption('sonnet', 'Sonnet'),
          _buildStyleOption('free verse', 'Free Verse'),
          _buildStyleOption('cyberpunk', 'Cyberpunk'),
        ],
      ),
    );
  }

  Widget _buildStyleOption(String value, String label) {
    return ListTile(
      title: Text(label),
      onTap: () => Navigator.of(context).pop(value),
    );
  }

  LinearGradient _getAnimatedGradient(String style) {
    final progress = _backgroundAnimation.value;

    switch (style.toLowerCase()) {
      case 'haiku':
        return LinearGradient(
          colors: const [Color(0xFF4FACFE), Color(0xFF38F9D7)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          stops: [progress * 0.3, progress * 0.7 + 0.3],
        );
      case 'sonnet':
        return LinearGradient(
          colors: const [Color(0xFF764BA2), Color(0xFFFFD700)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          stops: [progress * 0.3, progress * 0.7 + 0.3],
        );
      case 'free verse':
        return LinearGradient(
          colors: const [Color(0xFFF093FB), Color(0xFFF5576C)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          stops: [progress * 0.3, progress * 0.7 + 0.3],
        );
      case 'cyberpunk':
        return LinearGradient(
          colors: const [Color(0xFF00F2FE), Color(0xFF43E97B)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          stops: [progress * 0.3, progress * 0.7 + 0.3],
        );
      default:
        return AppColors.primaryGradient;
    }
  }

  String _getCodePreview(String code) {
    final lines = code.split('\n');
    return lines.take(5).join('\n');
  }
}