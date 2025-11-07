import 'package:uuid/uuid.dart';

class PoemModel {
  final String id;
  final String code;
  final String language;
  final String style;
  final String poem;
  final DateTime createdAt;
  final bool isFavorite;

  PoemModel({
    String? id,
    required this.code,
    required this.language,
    required this.style,
    required this.poem,
    DateTime? createdAt,
    this.isFavorite = false,
  })  : id = id ?? const Uuid().v4(),
        createdAt = createdAt ?? DateTime.now();

  // Convert to JSON for storage
  Map<String, dynamic> toJson() => {
    'id': id,
    'code': code,
    'language': language,
    'style': style,
    'poem': poem,
    'createdAt': createdAt.toIso8601String(),
    'isFavorite': isFavorite,
  };

  // Create from JSON
  factory PoemModel.fromJson(Map<String, dynamic> json) => PoemModel(
    id: json['id'] as String,
    code: json['code'] as String,
    language: json['language'] as String,
    style: json['style'] as String,
    poem: json['poem'] as String,
    createdAt: DateTime.parse(json['createdAt'] as String),
    isFavorite: json['isFavorite'] as bool? ?? false,
  );

  // Copy with method for updates
  PoemModel copyWith({
    String? id,
    String? code,
    String? language,
    String? style,
    String? poem,
    DateTime? createdAt,
    bool? isFavorite,
  }) =>
      PoemModel(
        id: id ?? this.id,
        code: code ?? this.code,
        language: language ?? this.language,
        style: style ?? this.style,
        poem: poem ?? this.poem,
        createdAt: createdAt ?? this.createdAt,
        isFavorite: isFavorite ?? this.isFavorite,
      );
}