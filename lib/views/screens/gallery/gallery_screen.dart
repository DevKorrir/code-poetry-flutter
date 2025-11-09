import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/theme/text_styles.dart';
import '../../../viewmodels/gallery_viewmodel.dart';
import '../../../models/poem_model.dart';
import '../../widgets/common/loading_indicator.dart';
import '../../widgets/common/empty_state.dart';
import '../poem_display/saved_poem_detail_screen.dart';

/// Gallery Screen - Fully Polished
/// Features: Grid/List view, Filtering, Search, Sort
class GalleryScreen extends StatefulWidget {
  const GalleryScreen({super.key});

  @override
  State<GalleryScreen> createState() => _GalleryScreenState();
}

class _GalleryScreenState extends State<GalleryScreen>
    with SingleTickerProviderStateMixin {
  final TextEditingController _searchController = TextEditingController();
  bool _isGridView = true;
  String _searchQuery = '';

  late AnimationController _filterAnimController;
  bool _showFilters = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<GalleryViewModel>().loadPoems();
    });

    _filterAnimController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text;
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _filterAnimController.dispose();
    super.dispose();
  }

  void _toggleFilters() {
    setState(() {
      _showFilters = !_showFilters;
    });

    if (_showFilters) {
      _filterAnimController.forward();
    } else {
      _filterAnimController.reverse();
    }
  }

  void _toggleView() {
    HapticFeedback.selectionClick();
    setState(() {
      _isGridView = !_isGridView;
    });
  }

  List<PoemModel> _filterPoems(List<PoemModel> poems) {
    if (_searchQuery.isEmpty) return poems;

    return poems.where((poem) {
      final query = _searchQuery.toLowerCase();
      return poem.poem.toLowerCase().contains(query) ||
          poem.style.toLowerCase().contains(query) ||
          poem.language.toLowerCase().contains(query);
    }).toList();
  }

  void _showSortOptions() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => _buildSortSheet(),
    );
  }

  void _deletePoemConfirm(String poemId) {
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
              Navigator.pop(context);
              final viewModel = context.read<GalleryViewModel>();
              await viewModel.deletePoem(poemId);

              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Poem deleted'),
                    backgroundColor: AppColors.error,
                  ),
                );
              }
            },
            child: const Text('Delete', style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<GalleryViewModel>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Custom App Bar with Search
            _buildAppBar(isDark),

            // Filter Bar (collapsible)
            AnimatedSize(
              duration: const Duration(milliseconds: 300),
              child: _showFilters ? _buildFilterBar(viewModel, isDark) : const SizedBox.shrink(),
            ),

            // Content
            Expanded(
              child: viewModel.isLoading
                  ? const LoadingIndicator()
                  : _buildContent(viewModel, isDark),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAppBar(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title and actions
          Row(
            children: [
              Text(
                'My Gallery',
                style: AppTextStyles.h3(),
              ),
              const Spacer(),

              // Grid/List toggle
              IconButton(
                onPressed: _toggleView,
                icon: Icon(_isGridView ? Icons.list : Icons.grid_view),
                tooltip: _isGridView ? 'List View' : 'Grid View',
              ),

              // Sort button
              IconButton(
                onPressed: _showSortOptions,
                icon: const Icon(Icons.sort),
                tooltip: 'Sort',
              ),

              // Filter toggle
              IconButton(
                onPressed: _toggleFilters,
                icon: Icon(
                  _showFilters ? Icons.filter_alt : Icons.filter_alt_outlined,
                  color: _showFilters ? AppColors.primaryStart : null,
                ),
                tooltip: 'Filter',
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Search bar
          TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Search poems...',
              prefixIcon: const Icon(Icons.search, size: 20),
              suffixIcon: _searchQuery.isNotEmpty
                  ? IconButton(
                icon: const Icon(Icons.clear, size: 20),
                onPressed: () => _searchController.clear(),
              )
                  : null,
              filled: true,
              fillColor: isDark
                  ? AppColors.darkSurfaceLight
                  : AppColors.lightSurfaceDark,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterBar(GalleryViewModel viewModel, bool isDark) {
    final styles = viewModel.availableStyles;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: isDark
            ? AppColors.darkSurfaceLight.withOpacity(0.5)
            : AppColors.lightSurfaceDark.withOpacity(0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Filter by Style',
            style: AppTextStyles.labelMedium(),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              // All option
              FilterChip(
                label: const Text('All'),
                selected: viewModel.selectedStyleFilter == null,
                onSelected: (_) {
                  HapticFeedback.selectionClick();
                  viewModel.clearFilter();
                },
              ),

              // Style filters
              ...styles.map((style) {
                return FilterChip(
                  label: Text(style),
                  selected: viewModel.selectedStyleFilter == style,
                  onSelected: (_) {
                    HapticFeedback.selectionClick();
                    viewModel.filterByStyle(style);
                  },
                );
              }).toList(),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildContent(GalleryViewModel viewModel, bool isDark) {
    final poems = _filterPoems(viewModel.filteredPoems);

    if (poems.isEmpty) {
      return EmptyState(
        title: _searchQuery.isNotEmpty
            ? 'No poems found'
            : 'No poems yet',
        message: _searchQuery.isNotEmpty
            ? 'Try a different search term'
            : 'Create your first code poetry!',
        icon: Icons.search_off,
      );
    }

    return RefreshIndicator(
      onRefresh: () => viewModel.refreshPoems(),
      child: _isGridView
          ? _buildGridView(poems, isDark)
          : _buildListView(poems, isDark),
    );
  }

  Widget _buildGridView(List<PoemModel> poems, bool isDark) {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 0.75,
      ),
      itemCount: poems.length,
      itemBuilder: (context, index) {
        return _buildPoemGridCard(poems[index], isDark);
      },
    );
  }

  Widget _buildListView(List<PoemModel> poems, bool isDark) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: poems.length,
      itemBuilder: (context, index) {
        return _buildPoemListCard(poems[index], isDark);
      },
    );
  }

  Widget _buildPoemGridCard(PoemModel poem, bool isDark) {
    return GestureDetector(
      onTap: () => _openPoemDetail(poem),
      onLongPress: () => _showPoemOptions(poem),
      child: Container(
        decoration: BoxDecoration(
          gradient: PoetryStyleColors.getGradient(poem.style),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.15),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Stack(
          children: [
            // Content
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Style badge
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      poem.style.toUpperCase(),
                      style: AppTextStyles.labelSmall(color: Colors.white)
                          .copyWith(fontSize: 9),
                    ),
                  ),

                  const Spacer(),

                  // Poem preview
                  Text(
                    _getPoemPreview(poem.poem, 3),
                    style: AppTextStyles.poetrySmall(color: Colors.white),
                    maxLines: 4,
                    overflow: TextOverflow.ellipsis,
                  ),

                  const SizedBox(height: 8),

                  // Meta info
                  Row(
                    children: [
                      Icon(
                        Icons.code,
                        size: 12,
                        color: Colors.white.withOpacity(0.8),
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          poem.language,
                          style: AppTextStyles.caption(
                            color: Colors.white.withOpacity(0.8),
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Favorite badge
            if (poem.isFavorite)
              Positioned(
                top: 8,
                right: 8,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.3),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.favorite,
                    size: 16,
                    color: Colors.white,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildPoemListCard(PoemModel poem, bool isDark) {
    return GestureDetector(
      onTap: () => _openPoemDetail(poem),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: (isDark
                ? AppColors.darkSurfaceLight
                : AppColors.lightSurfaceDark)
                .withOpacity(0.5),
          ),
        ),
        child: ListTile(
          contentPadding: const EdgeInsets.all(16),
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  gradient: PoetryStyleColors.getGradient(poem.style),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  poem.style.toUpperCase(),
                  style: AppTextStyles.labelSmall(color: Colors.white),
                ),
              ),
              const SizedBox(width: 8),
              if (poem.isFavorite)
                const Icon(Icons.favorite, size: 16, color: AppColors.error),
            ],
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 8),
              Text(
                _getPoemPreview(poem.poem, 2),
                style: AppTextStyles.poetrySmall(),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(
                    Icons.code,
                    size: 14,
                    color: isDark
                        ? AppColors.darkTextTertiary
                        : AppColors.lightTextTertiary,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    poem.language,
                    style: AppTextStyles.caption(),
                  ),
                  const Spacer(),
                  Text(
                    _formatDate(poem.createdAt),
                    style: AppTextStyles.caption(),
                  ),
                ],
              ),
            ],
          ),
          trailing: IconButton(
            icon: const Icon(Icons.more_vert),
            onPressed: () => _showPoemOptions(poem),
          ),
        ),
      ),
    );
  }

  Widget _buildSortSheet() {
    return Consumer<GalleryViewModel>(
      builder: (context, viewModel, child) {
        final currentSort = viewModel.sortOption;

        return Container(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Sort By',
                style: AppTextStyles.h4(),
              ),
              const SizedBox(height: 16),
              ListTile(
                leading: const Icon(Icons.access_time),
                title: const Text('Newest First'),
                trailing: currentSort == SortOption.newestFirst
                    ? const Icon(Icons.check, color: AppColors.primaryStart)
                    : null,
                onTap: () {
                  HapticFeedback.selectionClick();
                  viewModel.setSortOption(SortOption.newestFirst);
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: const Icon(Icons.access_time),
                title: const Text('Oldest First'),
                trailing: currentSort == SortOption.oldestFirst
                    ? const Icon(Icons.check, color: AppColors.primaryStart)
                    : null,
                onTap: () {
                  HapticFeedback.selectionClick();
                  viewModel.setSortOption(SortOption.oldestFirst);
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: const Icon(Icons.favorite),
                title: const Text('Favorites First'),
                trailing: currentSort == SortOption.favoritesFirst
                    ? const Icon(Icons.check, color: AppColors.primaryStart)
                    : null,
                onTap: () {
                  HapticFeedback.selectionClick();
                  viewModel.setSortOption(SortOption.favoritesFirst);
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: const Icon(Icons.style),
                title: const Text('By Style'),
                trailing: currentSort == SortOption.byStyle
                    ? const Icon(Icons.check, color: AppColors.primaryStart)
                    : null,
                onTap: () {
                  HapticFeedback.selectionClick();
                  viewModel.setSortOption(SortOption.byStyle);
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _showPoemOptions(PoemModel poem) {
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
              leading: Icon(
                poem.isFavorite ? Icons.favorite : Icons.favorite_border,
                color: AppColors.error,
              ),
              title: Text(poem.isFavorite ? 'Remove from Favorites' : 'Add to Favorites'),
              onTap: () async {
                Navigator.pop(context);
                final viewModel = context.read<GalleryViewModel>();
                await viewModel.toggleFavorite(poem);
              },
            ),
            ListTile(
              leading: const Icon(Icons.share),
              title: const Text('Share'),
              onTap: () {
                Navigator.pop(context);
                // Share poem
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete, color: AppColors.error),
              title: const Text('Delete', style: TextStyle(color: AppColors.error)),
              onTap: () {
                Navigator.pop(context);
                _deletePoemConfirm(poem.id);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _openPoemDetail(PoemModel poem) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => SavedPoemDetailScreen(poem: poem),
      ),
    );
  }

  String _getPoemPreview(String poem, int lines) {
    final poemLines = poem.split('\n');
    return poemLines.take(lines).join('\n');
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