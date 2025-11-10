import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/theme/text_styles.dart';
import '../../../viewmodels/poem_generator_viewmodel.dart';
import '../../widgets/common/custom_button.dart';
import '../style_selector/style_selector_screen.dart';
import '../../../core/services/github_service.dart';
import '../github/github_connect_screen.dart';
import '../github/github_repository_browser.dart';

/// Code Input Screen
/// User pastes code and selects language
class CodeInputScreen extends StatefulWidget {
  const CodeInputScreen({super.key});

  @override
  State<CodeInputScreen> createState() => _CodeInputScreenState();
}

class _CodeInputScreenState extends State<CodeInputScreen>
    with SingleTickerProviderStateMixin {
  final TextEditingController _codeController = TextEditingController();

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  final List<String> _languages = [
    'Python',
    'Dart',
    'JavaScript',
    'Java',
    'C++',
    'C#',
    'Ruby',
    'Go',
    'Swift',
    'Kotlin',
    'PHP',
    'TypeScript',
  ];

  @override
  void initState() {
    super.initState();
    _setupAnimations();

    // Load existing code if any
    final viewModel = context.read<PoemGeneratorViewModel>();
    if (viewModel.code.isNotEmpty) {
      _codeController.text = viewModel.code;
    }

    _codeController.addListener(_onCodeChanged);
  }

  void _setupAnimations() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeIn,
    ));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    ));

    _animationController.forward();
  }

  void _onCodeChanged() {
    final viewModel = context.read<PoemGeneratorViewModel>();
    viewModel.updateCode(_codeController.text);
  }

  void _pasteFromClipboard() async {
    final clipboardData = await Clipboard.getData(Clipboard.kTextPlain);
    if (clipboardData?.text != null) {
      _codeController.text = clipboardData!.text!;

      if (mounted) {
        HapticFeedback.mediumImpact();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Code pasted from clipboard'),
            duration: Duration(seconds: 1),
          ),
        );
      }
    }
  }

  void _clearCode() {
    _codeController.clear();
    HapticFeedback.lightImpact();
  }

  Future<void> _importFromGitHub() async {
    // Check if connected
    if (!GitHubService().isAuthenticated) {
      if (!mounted) return;
      final connected = await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const GitHubConnectScreen(),
        ),
      );
      
      if (connected != true) return;
    }

    // Browse repositories
    if (!mounted) return;
    final code = await Navigator.push<String>(
      context,
      MaterialPageRoute(
        builder: (context) => const GitHubRepositoryBrowser(),
      ),
    );

    // Set code
    if (code != null && code.isNotEmpty) {
      _codeController.text = code;
      if (mounted) {
        HapticFeedback.mediumImpact();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Code imported from GitHub'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    }
  }

  void _continueToStyleSelector() {
    final viewModel = context.read<PoemGeneratorViewModel>();

    if (_codeController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(AppStrings.codeInputError),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    if (!viewModel.isCodeWithinLimit) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(AppStrings.codeInputTooLong),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    HapticFeedback.mediumImpact();

    Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
        const StyleSelectorScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(1, 0),
              end: Offset.zero,
            ).animate(animation),
            child: child,
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    _codeController.removeListener(_onCodeChanged);
    _codeController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<PoemGeneratorViewModel>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.codeInputTitle),
        actions: [
          IconButton(
            icon: const Icon(Icons.code),
            tooltip: 'Import from GitHub',
            onPressed: _importFromGitHub,
          ),
          if (_codeController.text.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.clear),
              onPressed: _clearCode,
              tooltip: 'Clear',
            ),
        ],
      ),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: SlideTransition(
          position: _slideAnimation,
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Instructions
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          gradient: AppColors.primaryGradient,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.lightbulb_outline,
                              color: Colors.white,
                              size: 24,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                AppStrings.tipCodeInput,
                                style: AppTextStyles.bodyMedium(
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Language selector
                      _buildLanguageSelector(viewModel, isDark),

                      const SizedBox(height: 24),

                      // Code editor
                      _buildCodeEditor(viewModel, isDark),

                      const SizedBox(height: 12),

                      // Character counter and paste button
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '${viewModel.codeCharCount} / 10,000 characters',
                            style: AppTextStyles.caption(
                              color: viewModel.isCodeWithinLimit
                                  ? (isDark
                                  ? AppColors.darkTextTertiary
                                  : AppColors.lightTextTertiary)
                                  : AppColors.error,
                            ),
                          ),
                          TextButton.icon(
                            onPressed: _pasteFromClipboard,
                            icon: const Icon(Icons.content_paste, size: 18),
                            label: const Text('Paste'),
                          ),
                        ],
                      ),

                      const SizedBox(height: 8),

                      // Line counter
                      Text(
                        '${viewModel.codeLineCount} lines',
                        style: AppTextStyles.caption(),
                      ),
                    ],
                  ),
                ),
              ),

              // Bottom button
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: isDark
                      ? AppColors.darkSurface
                      : AppColors.lightSurface,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(0, -2),
                    ),
                  ],
                ),
                child: SafeArea(
                  child: CustomButton(
                    text: AppStrings.codeInputNext,
                    onPressed: viewModel.isInputValid
                        ? _continueToStyleSelector
                        : null,
                    trailingIcon: const Icon(Icons.arrow_forward, size: 20),
                    width: double.infinity,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLanguageSelector(
      PoemGeneratorViewModel viewModel,
      bool isDark,
      ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppStrings.codeInputLanguageLabel,
          style: AppTextStyles.labelLarge(),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: isDark
                ? AppColors.darkSurfaceLight
                : AppColors.lightSurfaceDark,
            borderRadius: BorderRadius.circular(12),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: viewModel.language,
              isExpanded: true,
              icon: const Icon(Icons.arrow_drop_down),
              style: AppTextStyles.bodyMedium(),
              dropdownColor: isDark
                  ? AppColors.darkSurface
                  : AppColors.lightSurface,
              items: _languages.map((String language) {
                return DropdownMenuItem<String>(
                  value: language.toLowerCase(),
                  child: Row(
                    children: [
                      Icon(
                        Icons.code,
                        size: 18,
                        color: AppColors.primaryStart,
                      ),
                      const SizedBox(width: 12),
                      Text(language),
                    ],
                  ),
                );
              }).toList(),
              onChanged: (String? newValue) {
                if (newValue != null) {
                  viewModel.updateLanguage(newValue);
                  HapticFeedback.selectionClick();
                }
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCodeEditor(PoemGeneratorViewModel viewModel, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Your Code',
          style: AppTextStyles.labelLarge(),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: AppColors.codeBackground,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: viewModel.code.isNotEmpty
                  ? AppColors.primaryStart.withOpacity(0.3)
                  : Colors.transparent,
              width: 2,
            ),
          ),
          child: TextField(
            controller: _codeController,
            maxLines: null,
            minLines: 15,
            maxLength: 10000,
            style: AppTextStyles.codeMedium(
              color: const Color(0xFFD4D4D4), // VS Code text color
            ),
            decoration: InputDecoration(
              hintText: AppStrings.codeInputHint,
              hintStyle: AppTextStyles.codeMedium(
                color: const Color(0xFF6A9955), // VS Code comment color
              ),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.all(16),
              counterText: '', // Hide default counter
            ),
            keyboardType: TextInputType.multiline,
            textInputAction: TextInputAction.newline,
          ),
        ),
      ],
    );
  }
}