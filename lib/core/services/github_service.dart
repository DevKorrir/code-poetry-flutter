import 'dart:convert';
import 'package:http/http.dart' as http;
import 'auth_service.dart';
import '../constants/feature_limits.dart';

/// GitHub Service
/// Provides access to user's repositories and files
class GitHubService {
  static final GitHubService _instance = GitHubService._internal();
  factory GitHubService() => _instance;
  GitHubService._internal();

  static const String _baseUrl = 'https://api.github.com';
  final http.Client _client = http.Client();

  /// Get GitHub access token from AuthService (async for secure storage)
  Future<String?> _getAccessToken() async {
    return await AuthService().getGitHubToken();
  }

  /// Check if GitHub is connected (sync check via Firebase provider)
  bool get isAuthenticated {
    return AuthService().hasGitHubProvider();
  }

  /// Check if token is available (async check)
  Future<bool> isTokenAvailable() async {
    final token = await _getAccessToken();
    return token != null && token.isNotEmpty;
  }

  // ============================================================
  // USER INFO
  // ============================================================

  /// Get authenticated user info
  Future<GitHubUser> getCurrentUser() async {
    final response = await _makeRequest('/user');
    return GitHubUser.fromJson(response);
  }

  // ============================================================
  // REPOSITORIES
  // ============================================================

  /// Get user's repositories
  Future<List<GitHubRepository>> getRepositories({
    int page = 1,
    int perPage = 30,
  }) async {
    final response = await _makeRequest(
      '/user/repos?page=$page&per_page=$perPage&sort=updated',
    );

    return (response as List)
        .map((json) => GitHubRepository.fromJson(json))
        .toList();
  }

  /// Search repositories by name
  Future<List<GitHubRepository>> searchRepositories(String query) async {
    final response = await _makeRequest(
      '/search/repositories?q=$query+user:@me',
    );

    return (response['items'] as List)
        .map((json) => GitHubRepository.fromJson(json))
        .toList();
  }

  // ============================================================
  // FILE BROWSING
  // ============================================================

  /// Get repository contents (files and folders)
  Future<List<GitHubContent>> getContents({
    required String owner,
    required String repo,
    String path = '',
  }) async {
    final url = path.isEmpty
        ? '/repos/$owner/$repo/contents'
        : '/repos/$owner/$repo/contents/$path';

    final response = await _makeRequest(url);

    return (response as List)
        .map((json) => GitHubContent.fromJson(json))
        .toList();
  }

  /// Get file content (decoded)
  Future<String> getFileContent({
    required String owner,
    required String repo,
    required String path,
  }) async {
    final response = await _makeRequest(
      '/repos/$owner/$repo/contents/$path',
    );

    final content = response['content'] as String;
    final decoded = utf8.decode(base64.decode(content.replaceAll('\n', '')));

    return decoded;
  }

  /// Get raw file content (for binary files)
  Future<List<int>> getRawFileContent({
    required String owner,
    required String repo,
    required String path,
  }) async {
    final response = await _makeRequest(
      '/repos/$owner/$repo/contents/$path',
    );

    final content = response['content'] as String;
    return base64.decode(content.replaceAll('\n', ''));
  }

  // ============================================================
  // BRANCHES
  // ============================================================

  /// Get repository branches
  Future<List<GitHubBranch>> getBranches({
    required String owner,
    required String repo,
  }) async {
    final response = await _makeRequest(
      '/repos/$owner/$repo/branches',
    );

    return (response as List)
        .map((json) => GitHubBranch.fromJson(json))
        .toList();
  }

  // ============================================================
  // COMMITS
  // ============================================================

  /// Get recent commits
  Future<List<GitHubCommit>> getCommits({
    required String owner,
    required String repo,
    int page = 1,
    int perPage = 10,
  }) async {
    final response = await _makeRequest(
      '/repos/$owner/$repo/commits?page=$page&per_page=$perPage',
    );

    return (response as List)
        .map((json) => GitHubCommit.fromJson(json))
        .toList();
  }

  // ============================================================
  // FILE FILTERING
  // ============================================================

  /// Get only code files from repository
  Future<List<GitHubContent>> getCodeFiles({
    required String owner,
    required String repo,
    String path = '',
  }) async {
    final contents = await getContents(
      owner: owner,
      repo: repo,
      path: path,
    );

    final codeExtensions = [
      '.dart', '.py', '.js', '.ts', '.java', '.cpp', '.c', '.cs',
      '.rb', '.go', '.rs', '.swift', '.kt', '.php', '.scala',
      '.jsx', '.tsx', '.vue', '.html', '.css', '.scss',
    ];

    return contents.where((content) {
      if (content.type != 'file') return false;
      return codeExtensions.any((ext) => content.name.endsWith(ext));
    }).toList();
  }

  /// Get files recursively (with depth limit)
  /// 
  /// Traverses a repository directory structure up to [maxDepth] levels.
  /// 
  /// **Parameters:**
  /// - [owner]: Repository owner username
  /// - [repo]: Repository name
  /// - [path]: Starting path (empty string = root)
  /// - [maxDepth]: Maximum recursion depth (default from FeatureLimits)
  /// - [currentDepth]: Internal counter for recursion (DO NOT SET)
  /// 
  /// **Performance Note:**
  /// Each directory level makes 1 API call. A repo with 10 subdirectories
  /// per level could make up to 10^depth calls in worst case.
  /// Default depth of 3 provides good balance for typical projects.
  /// 
  /// **To adjust depth:** Modify `FeatureLimits.githubMaxRecursionDepth`
  /// or pass custom [maxDepth] value for specific use cases.
  Future<List<GitHubContent>> getFilesRecursively({
    required String owner,
    required String repo,
    String path = '',
    int maxDepth = FeatureLimits.githubMaxRecursionDepth,
    int currentDepth = 0,
  }) async {
    if (currentDepth >= maxDepth) return [];

    final contents = await getContents(
      owner: owner,
      repo: repo,
      path: path,
    );

    List<GitHubContent> allFiles = [];

    for (var content in contents) {
      if (content.type == 'file') {
        allFiles.add(content);
      } else if (content.type == 'dir') {
        final subFiles = await getFilesRecursively(
          owner: owner,
          repo: repo,
          path: content.path,
          maxDepth: maxDepth,
          currentDepth: currentDepth + 1,
        );
        allFiles.addAll(subFiles);
      }
    }

    return allFiles;
  }

  // ============================================================
  // HTTP HELPER
  // ============================================================

  /// Make authenticated request with PAT
  Future<dynamic> _makeRequest(String endpoint) async {
    final token = await _getAccessToken();

    if (token == null || token.isEmpty) {
      throw GitHubException('Not connected to GitHub. Please add your Personal Access Token.');
    }

    final url = Uri.parse('$_baseUrl$endpoint');

    final response = await _client.get(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Accept': 'application/vnd.github.v3+json',
      },
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else if (response.statusCode == 401) {
      throw GitHubException('GitHub token is invalid or expired. Please reconnect.');
    } else if (response.statusCode == 404) {
      throw GitHubException('Resource not found');
    } else if (response.statusCode == 403) {
      final body = jsonDecode(response.body);
      final message = body['message'] ?? 'API rate limit exceeded';
      throw GitHubException(message);
    } else {
      throw GitHubException('GitHub API request failed: ${response.statusCode}');
    }
  }

  /// Dispose
  void dispose() {
    _client.close();
  }
}

/// GitHub User Model
class GitHubUser {
  final String login;
  final String? name;
  final String? avatarUrl;
  final int publicRepos;

  GitHubUser({
    required this.login,
    this.name,
    this.avatarUrl,
    required this.publicRepos,
  });

  factory GitHubUser.fromJson(Map<String, dynamic> json) => GitHubUser(
    login: json['login'] as String,
    name: json['name'] as String?,
    avatarUrl: json['avatar_url'] as String?,
    publicRepos: json['public_repos'] as int,
  );
}

/// GitHub Repository Model
class GitHubRepository {
  final String name;
  final String fullName;
  final String? description;
  final String language;
  final bool isPrivate;
  final String htmlUrl;
  final DateTime updatedAt;

  GitHubRepository({
    required this.name,
    required this.fullName,
    this.description,
    required this.language,
    required this.isPrivate,
    required this.htmlUrl,
    required this.updatedAt,
  });

  factory GitHubRepository.fromJson(Map<String, dynamic> json) =>
      GitHubRepository(
        name: json['name'] as String,
        fullName: json['full_name'] as String,
        description: json['description'] as String?,
        language: json['language'] as String? ?? 'Unknown',
        isPrivate: json['private'] as bool,
        htmlUrl: json['html_url'] as String,
        updatedAt: DateTime.parse(json['updated_at'] as String),
      );

  String get owner => fullName.split('/').first;
  String get repo => fullName.split('/').last;
}

/// GitHub Content Model (File or Directory)
class GitHubContent {
  final String name;
  final String path;
  final String type; // 'file' or 'dir'
  final int? size;
  final String? downloadUrl;

  GitHubContent({
    required this.name,
    required this.path,
    required this.type,
    this.size,
    this.downloadUrl,
  });

  factory GitHubContent.fromJson(Map<String, dynamic> json) => GitHubContent(
    name: json['name'] as String,
    path: json['path'] as String,
    type: json['type'] as String,
    size: json['size'] as int?,
    downloadUrl: json['download_url'] as String?,
  );

  bool get isFile => type == 'file';
  bool get isDirectory => type == 'dir';

  String get extension {
    if (!isFile) return '';
    final parts = name.split('.');
    return parts.length > 1 ? '.${parts.last}' : '';
  }

  String? get language {
    final ext = extension.toLowerCase();
    const languageMap = {
      '.dart': 'Dart',
      '.py': 'Python',
      '.js': 'JavaScript',
      '.ts': 'TypeScript',
      '.java': 'Java',
      '.cpp': 'C++',
      '.c': 'C',
      '.cs': 'C#',
      '.rb': 'Ruby',
      '.go': 'Go',
      '.rs': 'Rust',
      '.swift': 'Swift',
      '.kt': 'Kotlin',
      '.php': 'PHP',
    };
    return languageMap[ext];
  }
}

/// GitHub Branch Model
class GitHubBranch {
  final String name;
  final bool isProtected;

  GitHubBranch({
    required this.name,
    required this.isProtected,
  });

  factory GitHubBranch.fromJson(Map<String, dynamic> json) => GitHubBranch(
    name: json['name'] as String,
    isProtected: json['protected'] as bool? ?? false,
  );
}

/// GitHub Commit Model
class GitHubCommit {
  final String sha;
  final String message;
  final String authorName;
  final DateTime date;

  GitHubCommit({
    required this.sha,
    required this.message,
    required this.authorName,
    required this.date,
  });

  factory GitHubCommit.fromJson(Map<String, dynamic> json) => GitHubCommit(
    sha: json['sha'] as String,
    message: json['commit']['message'] as String,
    authorName: json['commit']['author']['name'] as String,
    date: DateTime.parse(json['commit']['author']['date'] as String),
  );
}

/// GitHub Exception
class GitHubException implements Exception {
  final String message;
  GitHubException(this.message);

  @override
  String toString() => 'GitHubException: $message';
}