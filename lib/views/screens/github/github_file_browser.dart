import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/theme/text_styles.dart';
import '../../../core/services/github_service.dart';
import '../../widgets/common/loading_indicator.dart';

class GitHubFileBrowser extends StatefulWidget {
  final GitHubRepository repository;
  final String? currentPath;

  const GitHubFileBrowser({
    super.key,
    required this.repository,
    this.currentPath,
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
      // Navigate into folder
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => GitHubFileBrowser(
            repository: widget.repository,
            currentPath: content.path,
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

  Future<void> _importFile(GitHubContent file) async {
    // Show loading
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

      if (mounted) {
        Navigator.pop(context); // Close loading
        Navigator.pop(context, code); // Return code
        Navigator.pop(context); // Close file browser
      }
    } catch (e) {
      if (mounted) {
        Navigator.pop(context); // Close loading
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to load file: ${e.toString()}'),
            backgroundColor: AppColors.error,
          ),
        );
      }
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