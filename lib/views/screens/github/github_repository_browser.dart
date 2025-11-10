
import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/theme/text_styles.dart';
import '../../../core/services/github_service.dart';
import '../../widgets/common/loading_indicator.dart';
import '../../widgets/common/empty_state.dart';
import 'github_file_browser.dart';

class GitHubRepositoryBrowser extends StatefulWidget {
  const GitHubRepositoryBrowser({super.key});

  @override
  State<GitHubRepositoryBrowser> createState() =>
      _GitHubRepositoryBrowserState();
}

class _GitHubRepositoryBrowserState extends State<GitHubRepositoryBrowser> {
  final TextEditingController _searchController = TextEditingController();
  List<GitHubRepository> _repositories = [];
  List<GitHubRepository> _filteredRepos = [];
  bool _isLoading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadRepositories();
    _searchController.addListener(_filterRepositories);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadRepositories() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final repos = await GitHubService().getRepositories();
      setState(() {
        _repositories = repos;
        _filteredRepos = repos;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  void _filterRepositories() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredRepos = _repositories.where((repo) {
        return repo.name.toLowerCase().contains(query) ||
            (repo.description?.toLowerCase().contains(query) ?? false);
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Select Repository'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search repositories...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                  icon: const Icon(Icons.clear),
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
              ),
            ),
          ),
        ),
      ),
      body: _isLoading
          ? const LoadingIndicator(message: 'Loading repositories...')
          : _error != null
          ? Center(child: Text(_error!))
          : _filteredRepos.isEmpty
          ? const EmptyState(
        title: 'No repositories found',
        icon: Icons.folder_open,
      )
          : ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _filteredRepos.length,
        itemBuilder: (context, index) {
          return _buildRepoCard(
            _filteredRepos[index],
            isDark,
          );
        },
      ),
    );
  }

  Widget _buildRepoCard(GitHubRepository repo, bool isDark) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => GitHubFileBrowser(repository: repo),
          ),
        );
      },
      child: Container(
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
            Row(
              children: [
                Icon(
                  repo.isPrivate ? Icons.lock : Icons.folder,
                  size: 20,
                  color: AppColors.primaryStart,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    repo.name,
                    style: AppTextStyles.labelLarge()
                        .copyWith(fontWeight: FontWeight.bold),
                  ),
                ),
                const Icon(Icons.chevron_right),
              ],
            ),
            if (repo.description != null) ...[
              const SizedBox(height: 8),
              Text(
                repo.description!,
                style: AppTextStyles.caption(),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
            const SizedBox(height: 8),
            Row(
              children: [
                Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: _getLanguageColor(repo.language),
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  repo.language,
                  style: AppTextStyles.caption(),
                ),
                const Spacer(),
                Text(
                  _formatDate(repo.updatedAt),
                  style: AppTextStyles.caption(),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Color _getLanguageColor(String language) {
    const colors = {
      'Dart': Color(0xFF00B4AB),
      'Python': Color(0xFF3776AB),
      'JavaScript': Color(0xFFF7DF1E),
      'TypeScript': Color(0xFF3178C6),
      'Java': Color(0xFFB07219),
      'C++': Color(0xFFF34B7D),
      'Go': Color(0xFF00ADD8),
      'Rust': Color(0xFFDEA584),
    };
    return colors[language] ?? AppColors.primaryStart;
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);

    if (diff.inDays < 1) return 'Today';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    if (diff.inDays < 30) return '${(diff.inDays / 7).floor()}w ago';
    return '${date.day}/${date.month}/${date.year}';
  }
}