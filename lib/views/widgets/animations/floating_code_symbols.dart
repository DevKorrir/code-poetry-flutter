import 'dart:math';
import 'package:flutter/material.dart';

class FloatingCodeSymbols extends StatefulWidget {
  final Widget child;

  const FloatingCodeSymbols({super.key, required this.child});

  @override
  State<FloatingCodeSymbols> createState() => _FloatingCodeSymbolsState();
}

class _FloatingCodeSymbolsState extends State<FloatingCodeSymbols>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  final List<CodeSymbol> _symbols = [];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 20),
      vsync: this,
    )..repeat();

    _generateSymbols();
  }

  void _generateSymbols() {
    final random = Random();
    final codeChars = ['<', '>', '{', '}', '(', ')', ';', ':', '=', '+', '-', '*', '/', '!'];

    for (int i = 0; i < 20; i++) {
      _symbols.add(
        CodeSymbol(
          char: codeChars[random.nextInt(codeChars.length)],
          startY: random.nextDouble(),
          startX: random.nextDouble(),
          speed: random.nextDouble() * 0.5 + 0.2,
          size: random.nextDouble() * 20 + 15,
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
        Positioned.fill(
          child: AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              return CustomPaint(
                painter: CodeSymbolPainter(
                  symbols: _symbols,
                  progress: _controller.value,
                ),
              );
            },
          ),
        ),
        widget.child,
      ],
    );
  }
}

class CodeSymbol {
  final String char;
  final double startY;
  final double startX;
  final double speed;
  final double size;

  CodeSymbol({
    required this.char,
    required this.startY,
    required this.startX,
    required this.speed,
    required this.size,
  });
}

class CodeSymbolPainter extends CustomPainter {
  final List<CodeSymbol> symbols;
  final double progress;

  CodeSymbolPainter({
    required this.symbols,
    required this.progress,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final textPainter = TextPainter(
      textDirection: TextDirection.ltr,
    );

    for (var symbol in symbols) {
      final y = ((symbol.startY + progress * symbol.speed) % 1.0) * size.height;
      final x = symbol.startX * size.width;

      textPainter.text = TextSpan(
        text: symbol.char,
        style: TextStyle(
          fontSize: symbol.size,
          color: Colors.white.withOpacity(0.1),
          fontFamily: 'monospace',
        ),
      );

      textPainter.layout();
      textPainter.paint(canvas, Offset(x, y));
    }
  }

  @override
  bool shouldRepaint(CodeSymbolPainter oldDelegate) => true;
}