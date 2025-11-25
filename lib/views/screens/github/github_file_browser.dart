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
        
        // Pop back to the screen that initiated the GitHub flow
        // This replaces the brittle approach of multiple Navigator.pop() calls
        // with a robust Navigator.popUntil() that identifies the target route

        int githubScreenCount = 0;
        Navigator.popUntil(context, (route) {
          // Count how many GitHub-related screens we need to pop through
          // This is more reliable than fixed pop() calls

          if (route.isFirst) {
            // We've reached the root - stop here
            return true;
          }

          // Check if this route is likely a GitHub screen by examining the builder
          // This is more robust than string matching
          try {
            final settings = route.settings;

            // If this route has arguments that indicate it's a GitHub screen
            if (settings.arguments is GitHubRepository) {
              githubScreenCount++;
              return false; // Continue popping
            }

            // If we haven't found any GitHub screens yet, we might be at the target
            if (githubScreenCount == 0) {
              return true; // Stop popping - we're likely at the originating screen
            }

            // If we've seen GitHub screens and now we're at a different screen type
            return true; // Stop popping
          } catch (e) {
            // Fallback: if we can't determine the route type, stop popping
            return true;
          }
        });
      } else {
        // Fallback: Return to originating screen with result
        // Use the same robust popUntil approach as the callback version
        Navigator.popUntil(context, (route) {
          if (route.isFirst) {
            return true; // Stop at root route
          }

          // Use the same logic as the callback approach for consistency
          try {
            final settings = route.settings;
            if (settings.arguments is GitHubRepository) {
              return false; // Continue popping through GitHub screens
            }
            return true; // Stop at non-GitHub screen
          } catch (e) {
            return true; // Fallback: stop popping
          }
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