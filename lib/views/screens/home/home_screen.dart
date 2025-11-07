import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/theme/text_styles.dart';
import '../../../viewmodels/auth_viewmodel.dart';
import '../../../viewmodels/home_viewmodel.dart';
import '../../../models/poem_model.dart';
import '../../widgets/common/custom_button.dart';
import '../../widgets/common/loading_indicator.dart';
import '../../widgets/common/error_view.dart';
import '../../widgets/common/empty_state.dart';
import '../code_input/code_input_screen.dart';
import '../gallery/gallery_screen.dart';
import '../profile/profile_screen.dart';
import '../settings/settings_screen.dart';

/// Home Screen
/// Main dashboard showing recent poems and quick actions
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<HomeViewModel>().initialize();
    });
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final pages = [
      const HomePage(),
      const GalleryScreen(),
      const ProfileScreen(),
      const SettingsScreen(),
    ];

    return Scaffold(
      body: pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.collections_outlined),
            activeIcon: Icon(Icons.collections),
            label: 'Gallery',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: 'Profile',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings_outlined),
            activeIcon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
      ),
    );
  }
}

/// Home Page (Dashboard content)
class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final authViewModel = context.watch<AuthViewModel>();
    final homeViewModel = context.watch<HomeViewModel>();

    return Scaffold(
      body: SafeArea(
        child: homeViewModel.isLoading
            ? const LoadingIndicator(message: 'Loading dashboard...')
            : homeViewModel.error != null
            ? ErrorView(
          message: homeViewModel.error!,
          onRetry: () => homeViewModel.refresh(),
        )
            : RefreshIndicator(
          onRefresh: () => homeViewModel.refresh(),
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  _buildHeader(context, authViewModel),

                  const SizedBox(height: 24),

                  // Stats cards
                  _buildStatsCards(homeViewModel, authViewModel),

                  const SizedBox(height: 32),

                  // Create new poem button
                  CustomButton(
                    text: AppStrings.homeNewPoem,
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) =>
                          const CodeInputScreen(),
                        ),
                      );
                    },
                    leadingIcon: const Icon(Icons.add, size: 24),
                    width: double.infinity,
                  ),

                  const SizedBox(height: 32),

                  // Recent poems section
                  _buildRecentPoemsSection(
                    context,
                    homeViewModel,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, AuthViewModel authViewModel) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                authViewModel.isGuest
                    ? AppStrings.homeWelcome
                    : '${AppStrings.homeWelcomeBack}, ${authViewModel.displayName}!',
                style: AppTextStyles.h3(),
              ),
              const SizedBox(height: 4),
              Text(
                AppStrings.homeSubtitle,
                style: AppTextStyles.bodyMedium(),
              ),
            ],
          ),
        ),
        // User tier badge
        if (authViewModel.isPro)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              gradient: AppColors.successGradient,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              children: [
                const Icon(Icons.star, size: 16, color: Colors.white),
                const SizedBox(width: 4),
                Text(
                  'PRO',
                  style: AppTextStyles.labelSmall(color: Colors.white)
                      .copyWith(fontWeight: FontWeight.bold),
                ),
              ],
            ),
          )
        else if (authViewModel.isGuest)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.guest.withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.guest),
            ),
            child: Text(
              'GUEST',
              style: AppTextStyles.labelSmall(color: AppColors.guest)
                  .copyWith(fontWeight: FontWeight.bold),
            ),
          ),
      ],
    );
  }

  Widget _buildStatsCards(
      HomeViewModel homeViewModel,
      AuthViewModel authViewModel,
      ) {
    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            icon: Icons.auto_awesome,
            label: 'Total Poems',
            value: '${homeViewModel.totalPoems}',
            gradient: AppColors.primaryGradient,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            icon: Icons.today,
            label: 'Today',
            value: '${homeViewModel.poemsToday}',
            gradient: AppColors.secondaryGradient,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            icon: Icons.style,
            label: 'Favorite',
            value: homeViewModel.favoriteStyle ?? 'N/A',
            gradient: AppColors.accentGradient,
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String label,
    required String value,
    required Gradient gradient,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: gradient,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(icon, color: Colors.white, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: AppTextStyles.h4(color: Colors.white),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: AppTextStyles.labelSmall(color: Colors.white),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildRecentPoemsSection(
      BuildContext context,
      HomeViewModel homeViewModel,
      ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              AppStrings.homeRecentPoems,
              style: AppTextStyles.h4(),
            ),
            if (homeViewModel.hasRecentPoems)
              TextButton(
                onPressed: () {
                  // Switch to gallery tab
                  // This is handled by the bottom nav bar
                },
                child: Text(
                  'View All',
                  style: AppTextStyles.labelMedium(
                    color: AppColors.primaryStart,
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 16),
        homeViewModel.hasRecentPoems
            ? ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: homeViewModel.recentPoems.length,
          itemBuilder: (context, index) {
            return _buildPoemCard(
              context,
              homeViewModel.recentPoems[index],
            );
          },
        )
            : EmptyState(
          title: AppStrings.homeEmptyState,
          icon: Icons.auto_awesome,
          actionText: 'Create First Poem',
          onAction: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => const CodeInputScreen(),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildPoemCard(BuildContext context, PoemModel poem) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              // Style badge
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  gradient: _getStyleGradient(poem.style),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  poem.style.toUpperCase(),
                  style: AppTextStyles.labelSmall(color: Colors.white),
                ),
              ),
              const Spacer(),
              // Favorite icon
              if (poem.isFavorite)
                const Icon(
                  Icons.favorite,
                  size: 16,
                  color: AppColors.error,
                ),
            ],
          ),

          const SizedBox(height: 12),

          // Poem preview (first 2 lines)
          Text(
            _getPoemPreview(poem.poem),
            style: AppTextStyles.poetryMedium(),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),

          const SizedBox(height: 12),

          // Language tag
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
                style: AppTextStyles.labelSmall(),
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
    );
  }

  LinearGradient _getStyleGradient(String style) {
    switch (style.toLowerCase()) {
      case 'haiku':
        return const LinearGradient(
          colors: [Color(0xFF4FACFE), Color(0xFF38F9D7)],
        );
      case 'sonnet':
        return const LinearGradient(
          colors: [Color(0xFF764BA2), Color(0xFFFFD700)],
        );
      case 'free verse':
        return const LinearGradient(
          colors: [Color(0xFFF093FB), Color(0xFFF5576C)],
        );
      case 'cyberpunk':
        return const LinearGradient(
          colors: [Color(0xFF00F2FE), Color(0xFF43E97B)],
        );
      default:
        return AppColors.primaryGradient;
    }
  }

  String _getPoemPreview(String poem) {
    final lines = poem.split('\n');
    return lines.take(2).join('\n');
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