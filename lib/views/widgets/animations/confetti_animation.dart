import 'dart:math';
import 'package:flutter/material.dart';

class ConfettiAnimation extends StatefulWidget {
  final Widget child;
  final bool isPlaying;

  const ConfettiAnimation({
    super.key,
    required this.child,
    this.isPlaying = false,
  });

  @override
  State<ConfettiAnimation> createState() => _ConfettiAnimationState();
}

class _ConfettiAnimationState extends State<ConfettiAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  final List<Confetti> _confettiPieces = [];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    );

    _controller.addListener(() {
      if (mounted) setState(() {});
    });

    if (widget.isPlaying) {
      _generateConfetti();
      _controller.forward();
    }
  }

  @override
  void didUpdateWidget(ConfettiAnimation oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isPlaying && !oldWidget.isPlaying) {
      _generateConfetti();
      _controller.forward(from: 0);
    }
  }

  void _generateConfetti() {
    _confettiPieces.clear();
    final random = Random();

    for (int i = 0; i < 50; i++) {
      _confettiPieces.add(
        Confetti(
          color: Color.fromRGBO(
            random.nextInt(256),
            random.nextInt(256),
            random.nextInt(256),
            1,
          ),
          size: random.nextDouble() * 10 + 5,
          startX: random.nextDouble(),
          endX: random.nextDouble(),
          duration: random.nextDouble() * 2 + 1,
        ),
      );
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        widget.child,
        if (widget.isPlaying)
          Positioned.fill(
            child: CustomPaint(
              painter: ConfettiPainter(
                confetti: _confettiPieces,
                progress: _controller.value,
              ),
            ),
          ),
      ],
    );
  }
}

class Confetti {
  final Color color;
  final double size;
  final double startX;
  final double endX;
  final double duration;

  Confetti({
    required this.color,
    required this.size,
    required this.startX,
    required this.endX,
    required this.duration,
  });
}

class ConfettiPainter extends CustomPainter {
  final List<Confetti> confetti;
  final double progress;

  ConfettiPainter({
    required this.confetti,
    required this.progress,
  });

  @override
  void paint(Canvas canvas, Size size) {
    for (var piece in confetti) {
      final adjustedProgress = (progress * 3).clamp(0.0, 1.0);

      final x = size.width * (piece.startX +
          (piece.endX - piece.startX) * adjustedProgress);
      final y = size.height * adjustedProgress;

      final rotation = adjustedProgress * 4 * pi;

      canvas.save();
      canvas.translate(x, y);
      canvas.rotate(rotation);

      final paint = Paint()
        ..color = piece.color.withOpacity(1 - adjustedProgress)
        ..style = PaintingStyle.fill;

      canvas.drawRect(
        Rect.fromCenter(
          center: Offset.zero,
          width: piece.size,
          height: piece.size,
        ),
        paint,
      );

      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(ConfettiPainter oldDelegate) => true;
}