

class PoetryStyleModel {
  final String name;
  final String displayName;
  final String description;
  final String icon;
  final String gradientStart;
  final String gradientEnd;

  const PoetryStyleModel({
    required this.name,
    required this.displayName,
    required this.description,
    required this.icon,
    required this.gradientStart,
    required this.gradientEnd,
  });

  // Predefined poetry styles
  static const List<PoetryStyleModel> allStyles = [
    PoetryStyleModel(
      name: 'haiku',
      displayName: 'Haiku',
      description: 'Minimalist, 5-7-5 syllables. Calm and zen.',
      icon: '🍃',
      gradientStart: '#4FACFE',
      gradientEnd: '#38F9D7',
    ),
    PoetryStyleModel(
      name: 'sonnet',
      displayName: 'Sonnet',
      description: 'Classical, 14 lines. Elegant and structured.',
      icon: '👑',
      gradientStart: '#764BA2',
      gradientEnd: '#FFD700',
    ),
    PoetryStyleModel(
      name: 'free verse',
      displayName: 'Free Verse',
      description: 'No rules. Creative and flowing.',
      icon: '🎨',
      gradientStart: '#F093FB',
      gradientEnd: '#F5576C',
    ),
    PoetryStyleModel(
      name: 'cyberpunk',
      displayName: 'Cyberpunk',
      description: 'Futuristic, edgy. Tech noir vibes.',
      icon: '⚡',
      gradientStart: '#00F2FE',
      gradientEnd: '#43E97B',
    ),
  ];

  // Get style by name
  static PoetryStyleModel? getByName(String name) {
    try {
      return allStyles.firstWhere(
            (style) => style.name.toLowerCase() == name.toLowerCase(),
      );
    } catch (e) {
      return null;
    }
  }
}