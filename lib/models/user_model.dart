import 'package:firebase_auth/firebase_auth.dart' as auth;

class UserModel {
  final String id;
  final String? email;
  final String? displayName;
  final String? photoUrl;
  final bool isGuest;
  final bool isPro;
  final bool emailVerified;
  final DateTime createdAt;

  UserModel({
    required this.id,
    this.email,
    this.displayName,
    this.photoUrl,
    this.isGuest = false,
    this.isPro = false,
    DateTime? createdAt,
    this.emailVerified = false,
  }) : createdAt = createdAt ?? DateTime.now();

  // Create from Firebase User
  factory UserModel.fromFirebaseUser(
      auth.User user, {
        bool isGuest = false,
        bool isPro = false,
      }) =>
      UserModel(
        id: user.uid,
        email: user.email,
        displayName: user.displayName,
        photoUrl: user.photoURL,
        isGuest: isGuest || user.isAnonymous,
        isPro: isPro,
        emailVerified: user.emailVerified,
        createdAt: user.metadata.creationTime ?? DateTime.now(),
      );

  // Convert to JSON
  Map<String, dynamic> toJson() => {
    'id': id,
    'email': email,
    'displayName': displayName,
    'photoUrl': photoUrl,
    'isGuest': isGuest,
    'isPro': isPro,
    'emailVerified': emailVerified,
    'createdAt': createdAt.toIso8601String(),
  };

  // Create from JSON
  factory UserModel.fromJson(Map<String, dynamic> json) => UserModel(
    id: json['id'] as String,
    email: json['email'] as String?,
    displayName: json['displayName'] as String?,
    photoUrl: json['photoUrl'] as String?,
    isGuest: json['isGuest'] as bool? ?? false,
    isPro: json['isPro'] as bool? ?? false,
    emailVerified: json['emailVerified'] as bool? ?? false,
    createdAt: DateTime.parse(json['createdAt'] as String),
  );

  // Copy with method
  UserModel copyWith({
    String? id,
    String? email,
    String? displayName,
    String? photoUrl,
    bool? isGuest,
    bool? isPro,
    bool? emailVerified,
    DateTime? createdAt,
  }) =>
      UserModel(
        id: id ?? this.id,
        email: email ?? this.email,
        displayName: displayName ?? this.displayName,
        photoUrl: photoUrl ?? this.photoUrl,
        isGuest: isGuest ?? this.isGuest,
        isPro: isPro ?? this.isPro,
        emailVerified: emailVerified ?? this.emailVerified,
        createdAt: createdAt ?? this.createdAt,
      );
}