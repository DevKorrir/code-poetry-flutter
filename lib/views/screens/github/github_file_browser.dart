import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/theme/text_styles.dart';
import '../../../core/services/github_service.dart';
import '../../widgets/common/loading_indicator.dart';

/// Callback type for when a file is successfully imported
typedef OnFileImported = void Function(String code);

class GitHubFileBrowser extends StatefulWidget {
  final GitHubRepository repository;
  final String? currentPath;
  final OnFileImported? onFileImported;

  const GitHubFileBrowser({
    super.key,
    required this.repository,
    this.currentPath,
    this.onFileImported,
  });

  @override
  State<GitHubFileBrowser> createState() => _GitHubFileBrowserState();
}

class _GitHubFileBrowserState extends State<GitHubFileBrowser> {
  List<GitHubContent> _contents = [];
  bool _isLoading = false;
  String? _error;
  String _currentPath = '';

  @override
  void initState() {
    super.initState();
    _currentPath = widget.currentPath ?? '';
    _loadContents();
  }

  Future<void> _loadContents() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final contents = await GitHubService().getContents(
        owner: widget.repository.owner,
        repo: widget.repository.repo,
        path: _currentPath,
      );

      setState(() {
        _contents = contents;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _onItemTap(GitHubContent content) async {
    if (content.isDirectory) {
      // Navigate into folder, passing the callback through
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => GitHubFileBrowser(
            repository: widget.repository,
            currentPath: content.path,
            onFileImported: widget.onFileImported,
          ),
        ),
      );
    } else if (content.isFile) {
      // Check if it's a code file
      if (content.language != null) {
        await _importFile(content);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please select a code file'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  /// Import a file and navigate back to the originating screen
  /// 
  /// Uses Navigator.popUntil to safely return to the screen that initiated
  /// the GitHub browsing flow, avoiding brittle multiple Navigator.pop() calls.
  /// 
  /// The navigation stack is typically:
  /// 1. CodeInputScreen (or other originating screen)
  /// 2. GitHubRepositoryBrowser
  /// 3. GitHubFileBrowser (current screen)
  /// 4. Loading dialog
  /// 
  /// This method pops back to the originating screen (#1) with the file content.
  Future<void> _importFile(GitHubContent file) async {
    // Show loading dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(),
      ),
    );

    try {
      final code = await GitHubService().getFileContent(
        owner: widget.repository.owner,
        repo: widget.repository.repo,
        path: file.path,
      );

      if (!mounted) return;

      // Close loading dialog
      Navigator.pop(context);

      // Use callback if provided (callback-based approach)
      if (widget.onFileImported != null) {
        // Callback will handle navigation and data passing
        widget.onFileImported!(code);
        
        // Pop all GitHub screens to return to CodeInputScreen
        Navigator.pop(context); // Pop file browser
        Navigator.pop(context); // Pop repository browser
      } else {
        // Fallback: Use popUntil to return to originating screen
        // Pop until we're back at the first route (originating screen)
        Navigator.popUntil(context, (route) {
          // Check if this is the second-to-last route
          // (we want to keep the originating screen)
          return route.isFirst || 
                 (route.settings.arguments == null && 
                  route.settings.name == null);
        });
        
        // Return the code to the originating screen
        Navigator.pop(context, code);
      }
    } catch (e) {
      if (!mounted) return;

      // Close loading dialog
      Navigator.pop(context);

      // Show error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to load file: ${e.toString()}'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widget.repository.name),
            if (_currentPath.isNotEmpty)
              Text(
                _currentPath,
                style: AppTextStyles.caption(),
              ),
          ],
        ),
      ),
      body: _isLoading
          ? const LoadingIndicator(message: 'Loading files...')
          : _error != null
          ? Center(child: Text(_error!))
          : _contents.isEmpty
          ? const Center(child: Text('Empty folder'))
          : ListView.builder(
        itemCount: _contents.length,
        itemBuilder: (context, index) {
          return _buildContentTile(
            _contents[index],
            isDark,
          );
        },
      ),
    );
  }

  Widget _buildContentTile(GitHubContent content, bool isDark) {
    final isCodeFile = content.isFile && content.language != null;

    return ListTile(
      leading: Icon(
        content.isDirectory
            ? Icons.folder
            : isCodeFile
            ? Icons.code
            : Icons.insert_drive_file,
        color: content.isDirectory
            ? AppColors.warning
            : isCodeFile
            ? AppColors.success
            : null,
      ),
      title: Text(content.name),
      subtitle: content.isFile
          ? Text(
        content.language ?? 'Unknown',
        style: AppTextStyles.caption(),
      )
          : null,
      trailing: Icon(
        content.isDirectory ? Icons.chevron_right : null,
      ),
      onTap: () => _onItemTap(content),
    );
  }
}