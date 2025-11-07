import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

/// API Service for Gemini AI integration
/// Handles all communication with Google's Gemini API for poem generation
class ApiService {
  // Singleton pattern
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal();

  // Gemini API Configuration
  static const String _baseUrl = 'https://generativelanguage.googleapis.com/v1beta';
  late final String _apiKey;
  late final http.Client _client;

  /// Initialize the service with API key from .env
  void initialize() async {
    _apiKey = dotenv.env['GEMINI_API_KEY'] ?? '';
    if (_apiKey.isEmpty) {
      throw Exception('GEMINI_API_KEY not found in .env file');
    }
    _client = http.Client();
  }

  /// Generate poem from code
  ///
  /// Parameters:
  /// - [code]: The code snippet to analyze
  /// - [language]: Programming language (e.g., 'python', 'dart', 'javascript')
  /// - [style]: Poetry style (e.g., 'haiku', 'sonnet', 'free verse', 'cyberpunk')
  ///
  /// Returns: Generated poem as String
  /// Throws: [ApiException] if generation fails
  Future<String> generatePoem({
    required String code,
    required String language,
    required String style,
  }) async {
    try {
      // Build the prompt
      final prompt = _buildPrompt(code, language, style);

      // Make API request
      final response = await _makeRequest(prompt);

      // Extract poem from response
      final poem = _extractPoemFromResponse(response);

      return poem;
    } catch (e) {
      throw ApiException('Failed to generate poem: ${e.toString()}');
    }
  }

  /// Build optimized prompt for Gemini
  String _buildPrompt(String code, String language, String style) {
    // Analyze code complexity
    final lineCount = code.split('\n').length;
    final hasLoops = code.contains('for') || code.contains('while');
    final hasConditions = code.contains('if') || code.contains('else');
    final hasFunctions = code.contains('function') ||
        code.contains('def') ||
        code.contains('void') ||
        code.contains('=>');

    final complexity = lineCount > 50 ? 'complex' :
    lineCount > 20 ? 'moderate' : 'simple';

    // Style-specific instructions
    final styleInstructions = _getStyleInstructions(style);

    return '''
You are a code poet. Your task is to analyze this $language code and write a $style poem about it.

CODE:
$code

CODE ANALYSIS:
- Lines: $lineCount
- Complexity: $complexity
- Contains loops: $hasLoops
- Contains conditionals: $hasConditions
- Contains functions: $hasFunctions

$styleInstructions

CRITICAL RULES:
1. Write ONLY the poem - no explanations, no meta-commentary
2. Capture the ESSENCE of what this code does
3. Reference specific programming concepts poetically
4. Make it sound beautiful when read aloud
5. Be creative and avoid clichés
6. The poem should make developers smile

Generate the poem now:''';
  }

  /// Get style-specific instructions
  String _getStyleInstructions(String style) {
    switch (style.toLowerCase()) {
      case 'haiku':
        return '''
STYLE: HAIKU
- EXACTLY 3 lines
- Syllable pattern: 5-7-5 (STRICT)
- Minimalist and zen
- Capture a moment or essence
- Use nature/code metaphors
Example structure:
Line 1 (5 syllables): [code element]
Line 2 (7 syllables): [what it does/feeling]
Line 3 (5 syllables): [resolution/insight]''';

      case 'sonnet':
        return '''
STYLE: SONNET
- 14 lines total
- Follow ABAB CDCD EFEF GG rhyme scheme
- Iambic pentameter preferred but not required
- Elegant and classical
- Build narrative about the code
- Final couplet should provide insight or resolution''';

      case 'free verse':
        return '''
STYLE: FREE VERSE
- 8-16 lines (flexible)
- No rhyme scheme required
- Natural rhythm and flow
- Creative line breaks for emphasis
- Vivid imagery
- Emotional and expressive
- Let the code's personality shine''';

      case 'cyberpunk':
        return '''
STYLE: CYBERPUNK
- 8-12 lines
- Edgy, futuristic tone
- Tech noir aesthetic
- Use cyber/digital metaphors
- Dark but energetic
- References: neon, circuits, matrix, electric
- Make it feel like code in the future''';

      default:
        return '''
STYLE: CREATIVE
- 8-12 lines
- Choose the best poetic form for this code
- Be creative and surprising
- Make it memorable''';
    }
  }

  /// Make HTTP request to Gemini API
  Future<Map<String, dynamic>> _makeRequest(String prompt) async {
    final url = Uri.parse(
                       //gemini-pro-latest
                       //gemini-2.0-flash
      '$_baseUrl/models/gemini-2.0-flash:generateContent?key=$_apiKey',
    );

    final body = jsonEncode({
      'contents': [
        {
          'parts': [
            {'text': prompt}
          ]
        }
      ],
      'generationConfig': {
        'temperature': 0.9, // High creativity
        'topK': 40,
        'topP': 0.95,
        'maxOutputTokens': 500,
      },
      'safetySettings': [
        {
          'category': 'HARM_CATEGORY_HARASSMENT',
          'threshold': 'BLOCK_NONE',
        },
        {
          'category': 'HARM_CATEGORY_HATE_SPEECH',
          'threshold': 'BLOCK_NONE',
        },
        {
          'category': 'HARM_CATEGORY_SEXUALLY_EXPLICIT',
          'threshold': 'BLOCK_NONE',
        },
        {
          'category': 'HARM_CATEGORY_DANGEROUS_CONTENT',
          'threshold': 'BLOCK_NONE',
        },
      ],
    });

    final response = await _client.post(
      url,
      headers: {
        'Content-Type': 'application/json',
      },
      body: body,
    );

    if (response.statusCode != 200) {
      throw ApiException(
        'API request failed with status ${response.statusCode}: ${response.body}',
        //print('API request failed with status ${response.statusCode}: ${response.body}');
      );
    }

    return jsonDecode(response.body) as Map<String, dynamic>;
  }

  /// Extract poem text from Gemini response
  String _extractPoemFromResponse(Map<String, dynamic> response) {
    try {
      // Check for null *before* casting.
      // Use 'as List?' to allow for a null value.
      final candidates = response['candidates'] as List?;

      // Check if the list is null or empty
      if (candidates == null || candidates.isEmpty) {

        // Check if the API returned a safety block instead
        if (response.containsKey('promptFeedback')) {
          final feedback = response['promptFeedback'];
          final blockReason = feedback['blockReason'] ?? 'Unknown safety block';
          throw ApiException('Poem blocked: $blockReason. Adjust safety settings or prompt.');
        }

        // If not a safety block, just no poem
        throw ApiException('No poem generated (empty candidates list)');
      }

      // Use safe casting for maps and lists
      final content = candidates[0]['content'] as Map<String, dynamic>?;
      if (content == null) {
        throw ApiException('Failed to parse: "content" key is missing or null');
      }

      final parts = content['parts'] as List?;
      if (parts == null || parts.isEmpty) {
        throw ApiException('Failed to parse: "parts" list is missing or empty');
      }

      final text = parts[0]['text'] as String?;
      if (text == null) {
        throw ApiException('Failed to parse: "text" is missing or null');
      }

      // Clean up the poem text
      return _cleanPoem(text);

    } catch (e) {
      // If it's already an ApiException, just re-throw it
      if (e is ApiException) rethrow;

      // Otherwise, wrap the casting error
      throw ApiException('Failed to parse API response: ${e.toString()}');
    }
  }

  /// Clean and format poem text
  String _cleanPoem(String rawPoem) {
    String cleaned = rawPoem.trim();

    // Remove common prefixes that AI might add
    final prefixesToRemove = [
      'Here is the poem:',
      'Here\'s the poem:',
      'Poem:',
      'Here you go:',
    ];

    for (final prefix in prefixesToRemove) {
      if (cleaned.toLowerCase().startsWith(prefix.toLowerCase())) {
        cleaned = cleaned.substring(prefix.length).trim();
      }
    }

    // Remove markdown code blocks if present
    cleaned = cleaned.replaceAll('```', '').trim();

    // Remove extra blank lines (keep single line breaks)
    cleaned = cleaned.replaceAll(RegExp(r'\n\s*\n\s*\n+'), '\n\n');

    return cleaned;
  }

  /// Check if API key is valid by making a test request
  Future<bool> validateApiKey() async {
    try {
      await generatePoem(
        code: 'print("Hello World")',
        language: 'python',
        style: 'haiku',
      );
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Get available models (for future features)
  Future<List<String>> getAvailableModels() async {
    try {
      final url = Uri.parse('$_baseUrl/models?key=$_apiKey');
      final response = await _client.get(url);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        final models = data['models'] as List<dynamic>;
        return models
            .map((model) => model['name'] as String)
            .toList();
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  /// Dispose resources
  void dispose() {
    _client.close();
  }
}

/// Custom exception for API errors
class ApiException implements Exception {
  final String message;
  ApiException(this.message);

  @override
  String toString() => 'ApiException: $message';
}

/// Response model for better type safety (optional but recommended)
class PoemResponse {
  final String poem;
  final String style;
  final String language;
  final DateTime createdAt;

  PoemResponse({
    required this.poem,
    required this.style,
    required this.language,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() => {
    'poem': poem,
    'style': style,
    'language': language,
    'createdAt': createdAt.toIso8601String(),
  };

  factory PoemResponse.fromJson(Map<String, dynamic> json) => PoemResponse(
    poem: json['poem'] as String,
    style: json['style'] as String,
    language: json['language'] as String,
    createdAt: DateTime.parse(json['createdAt'] as String),
  );
}