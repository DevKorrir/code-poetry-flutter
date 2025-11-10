import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';

/// GitHub Service
/// Provides access to user's repositories and files
class GitHubService {
  static final GitHubService _instance = GitHubService._internal();
  factory GitHubService() => _instance;
  GitHubService._internal();

  static const String _baseUrl = 'https://api.github.com';
  final http.Client _client = http.Client();

  /// Get GitHub access token from Firebase Auth
  String? get _accessToken {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return null;

    // Get GitHub credential token
    for (var info in user.providerData) {
      if (info.providerId == 'github.com') {
        // Token is stored in Firebase, we'll get it from the credential
        return _getTokenFromFirebase();
      }
    }
    return null;
  }

  /// Check if GitHub is connected
  bool get isAuthenticated {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return false;
    
    return user.providerData.any((info) => info.providerId == 'github.com');
  }

  /// Get token from Firebase (stored during auth)
  String? _getTokenFromFirebase() {
    // The token is available during the sign-in process
    // We need to store it when user signs in
    // For now, we'll use a different approach with Firebase
    return null; // We'll update this in auth_service
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
  Future<List<GitHubContent>> getFilesRecursively({
    required String owner,
    required String repo,
    String path = '',
    int maxDepth = 3,
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

  /// Make authenticated request
  Future<dynamic> _makeRequest(String endpoint) async {
    final token = _accessToken;
    
    if (token == null) {
      throw GitHubException('Not authenticated with GitHub');
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
      throw GitHubException('GitHub authentication expired');
    } else if (response.statusCode == 404) {
      throw GitHubException('Resource not found');
    } else if (response.statusCode == 403) {
      final body = jsonDecode(response.body);
      final message = body['message'] ?? 'API rate limit exceeded';
      throw GitHubException(message);
    } else {
      throw GitHubException('Request failed: ${response.statusCode}');
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