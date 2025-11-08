import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:share_plus/share_plus.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/theme/text_styles.dart';
import '../../../models/poem_model.dart';

class ExportImageWidget extends StatelessWidget {
  final PoemModel poem;
  final GlobalKey repaintKey;

  const ExportImageWidget({
    super.key,
    required this.poem,
    required this.repaintKey,
  });

  Future<void> exportAsImage() async {
    try {
      final boundary = repaintKey.currentContext!.findRenderObject()
      as RenderRepaintBoundary;

      final image = await boundary.toImage(pixelRatio: 3.0);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      final bytes = byteData!.buffer.asUint8List();

      // Share image
      await Share.shareXFiles(
        [XFile.fromData(bytes, mimeType: 'image/png', name: 'poem.png')],
        text: 'My Code Poetry',
      );
    } catch (e) {
      debugPrint('Error exporting image: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      key: repaintKey,
      child: Container(
        width: 400,
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          gradient: _getStyleGradient(poem.style),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Style badge
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                poem.style.toUpperCase(),
                style: AppTextStyles.labelMedium(color: Colors.white)
                    .copyWith(fontWeight: FontWeight.bold),
              ),
            ),

            const SizedBox(height: 24),

            // Poem text
            Text(
              poem.poem,
              style: AppTextStyles.poetryLarge(color: Colors.white),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 24),

            // Branding
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.code, color: Colors.white, size: 16),
                  const SizedBox(width: 8),
                  Text(
                    'Code Poetry',
                    style: AppTextStyles.labelSmall(color: Colors.white),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  LinearGradient _getStyleGradient(String style) {
    switch (style.toLowerCase()) {
      case 'haiku':
        return const LinearGradient(
          colors: [Color(0xFF4FACFE), Color(0xFF38F9D7)],
        );
      case 'sonnet':
        return const LinearGradient(
          colors: [Color(0xFF764BA2), Color(0xFFFFD700)],
        );
      case 'free verse':
        return const LinearGradient(
          colors: [Color(0xFFF093FB), Color(0xFFF5576C)],
        );
      case 'cyberpunk':
        return const LinearGradient(
          colors: [Color(0xFF00F2FE), Color(0xFF43E97B)],
        );
      default:
        return AppColors.primaryGradient;
    }
  }
}