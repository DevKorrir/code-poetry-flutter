import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/theme/text_styles.dart';
import '../../../models/poem_model.dart';
import '../../../viewmodels/gallery_viewmodel.dart';
import '../../widgets/common/custom_button.dart';

/// Saved Poem Detail Screen
/// Displays a saved poem with full details and actions
class SavedPoemDetailScreen extends StatefulWidget {
  final PoemModel poem;

  const SavedPoemDetailScreen({
    super.key,
    required this.poem,
  });

  @override
  State<SavedPoemDetailScreen> createState() => _SavedPoemDetailScreenState();
}

class _SavedPoemDetailScreenState extends State<SavedPoemDetailScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
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

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    ));

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _sharePoem() async {
    HapticFeedback.mediumImpact();
    await Share.share(
      '${widget.poem.poem}\n\n'
      '- Generated with Code Poetry\n'
      'Style: ${widget.poem.style}\n'
      'Language: ${widget.poem.language}',
      subject: 'Check out my code poetry!',
    );
  }

  Future<void> _toggleFavorite() async {
    HapticFeedback.lightImpact();
    final viewModel = context.read<GalleryViewModel>();
    await viewModel.toggleFavorite(widget.poem);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            widget.poem.isFavorite
                ? 'Added to favorites'
                : 'Removed from favorites',
          ),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  Future<void> _copyToClipboard() async {
    HapticFeedback.lightImpact();
    await Clipboard.setData(ClipboardData(text: widget.poem.poem));

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Poem copied to clipboard'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  void _deletePoem() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Poem'),
        content: const Text('Are you sure you want to delete this poem?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context); // Close dialog
              
              final viewModel = context.read<GalleryViewModel>();
              await viewModel.deletePoem(widget.poem.id);

              if (mounted) {
                Navigator.pop(context); // Go back to gallery
                
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Poem deleted'),
                    backgroundColor: AppColors.error,
                  ),
                );
              }
            },
            child: const Text(
              'Delete',
              style: TextStyle(color: AppColors.error),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: _getStyleGradient(widget.poem.style),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // App bar
              _buildAppBar(),

              // Content
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Style badge
                      _buildStyleBadge(),

                      const SizedBox(height: 32),

                      // Poem content with animation
                      FadeTransition(
                        opacity: _fadeAnimation,
                        child: SlideTransition(
                          position: _slideAnimation,
                          child: _buildPoemContent(),
                        ),
                      ),

                      const SizedBox(height: 32),

                      // Metadata
                      _buildMetadata(),

                      const SizedBox(height: 32),

                      // Actions
                      _buildActions(),
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

  Widget _buildAppBar() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          // Back button
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

          const Spacer(),

          // Favorite button
          IconButton(
            onPressed: _toggleFavorite,
            icon: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(
                widget.poem.isFavorite ? Icons.favorite : Icons.favorite_border,
                color: widget.poem.isFavorite ? Colors.red : Colors.white,
              ),
            ),
          ),

          // More options
          IconButton(
            onPressed: _showMoreOptions,
            icon: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.more_vert,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStyleBadge() {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.25),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          widget.poem.style.toUpperCase(),
          style: AppTextStyles.labelMedium(color: Colors.white).copyWith(
            fontWeight: FontWeight.bold,
            letterSpacing: 1.2,
          ),
        ),
      ),
    );
  }

  Widget _buildPoemContent() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.white.withOpacity(0.3),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Text(
        widget.poem.poem,
        style: AppTextStyles.poetryLarge(color: Colors.white).copyWith(
          height: 1.8,
          letterSpacing: 0.5,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildMetadata() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          _buildMetadataRow(
            Icons.code,
            'Language',
            widget.poem.language,
          ),
          const SizedBox(height: 12),
          _buildMetadataRow(
            Icons.calendar_today,
            'Created',
            _formatDate(widget.poem.createdAt),
          ),
        ],
      ),
    );
  }

  Widget _buildMetadataRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(
          icon,
          size: 18,
          color: Colors.white.withOpacity(0.8),
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: AppTextStyles.bodyMedium(
            color: Colors.white.withOpacity(0.8),
          ),
        ),
        const Spacer(),
        Text(
          value,
          style: AppTextStyles.bodyMedium(color: Colors.white).copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildActions() {
    return Column(
      children: [
        // Share button
        CustomButton(
          text: 'Share Poem',
          onPressed: _sharePoem,
          backgroundColor: Colors.white,
          textColor: _getStyleColor(widget.poem.style),
          width: double.infinity,
          height: 56,
          leadingIcon: const Icon(Icons.share, size: 20),
          isGradient: false,
        ),

        const SizedBox(height: 12),

        // Copy button
        CustomButton(
          text: 'Copy to Clipboard',
          onPressed: _copyToClipboard,
          backgroundColor: Colors.white.withOpacity(0.2),
          textColor: Colors.white,
          width: double.infinity,
          height: 56,
          leadingIcon: const Icon(Icons.copy, size: 20),
          isGradient: false,
        ),
      ],
    );
  }

  void _showMoreOptions() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.delete, color: AppColors.error),
              title: const Text(
                'Delete Poem',
                style: TextStyle(color: AppColors.error),
              ),
              onTap: () {
                Navigator.pop(context);
                _deletePoem();
              },
            ),
          ],
        ),
      ),
    );
  }

  LinearGradient _getStyleGradient(String style) {
    switch (style.toLowerCase()) {
      case 'haiku':
        return const LinearGradient(
          colors: [Color(0xFF4FACFE), Color(0xFF38F9D7)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
      case 'sonnet':
        return const LinearGradient(
          colors: [Color(0xFF764BA2), Color(0xFFFFD700)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
      case 'free verse':
        return const LinearGradient(
          colors: [Color(0xFFF093FB), Color(0xFFF5576C)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
      case 'cyberpunk':
        return const LinearGradient(
          colors: [Color(0xFF00F2FE), Color(0xFF43E97B)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
      default:
        return AppColors.primaryGradient;
    }
  }

  Color _getStyleColor(String style) {
    switch (style.toLowerCase()) {
      case 'haiku':
        return const Color(0xFF4FACFE);
      case 'sonnet':
        return const Color(0xFF764BA2);
      case 'free verse':
        return const Color(0xFFF093FB);
      case 'cyberpunk':
        return const Color(0xFF00F2FE);
      default:
        return AppColors.primaryStart;
    }
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);

    if (diff.inDays == 0) {
      if (diff.inHours == 0) {
        return '${diff.inMinutes}m ago';
      }
      return '${diff.inHours}h ago';
    } else if (diff.inDays == 1) {
      return 'Yesterday';
    } else if (diff.inDays < 7) {
      return '${diff.inDays}d ago';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }
}
