import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';

class AnimatedThemeToggle extends StatelessWidget {
  final bool isDark;
  final ValueChanged<bool> onToggle;

  const AnimatedThemeToggle({
    super.key,
    required this.isDark,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onToggle(!isDark),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        width: 60,
        height: 32,
        decoration: BoxDecoration(
          gradient: isDark
              ? const LinearGradient(
            colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
          )
              : const LinearGradient(
            colors: [Color(0xFFFEE140), Color(0xFFFA709A)],
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: (isDark ? AppColors.primaryStart : AppColors.warning)
                  .withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Stack(
          children: [
            // Sun/Moon icon
            AnimatedPositioned(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              left: isDark ? 4 : 32,
              top: 4,
              child: Container(
                width: 24,
                height: 24,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  isDark ? Icons.nightlight_round : Icons.wb_sunny,
                  size: 16,
                  color: isDark ? AppColors.primaryStart : AppColors.warning,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}