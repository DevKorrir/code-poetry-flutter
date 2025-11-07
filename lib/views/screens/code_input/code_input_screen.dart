import 'package:flutter/material.dart';
import '../../../core/theme/text_styles.dart';

class CodeInputScreen extends StatelessWidget {
  const CodeInputScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Paste Your Code'),
      ),
      body: Center(
        child: Text(
          'Code Input Screen\n(Coming next)',
          style: AppTextStyles.h3(),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}