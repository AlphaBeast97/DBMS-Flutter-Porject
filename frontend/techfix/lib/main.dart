import 'package:flutter/material.dart';
import 'package:techfix/screens/home_shell.dart';
import 'package:techfix/theme/app_theme.dart';

void main() {
  runApp(const TechFixApp());
}

class TechFixApp extends StatelessWidget {
  const TechFixApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TechFix',
      theme: AppTheme.lightTheme,
      home: const HomeShell(),
    );
  }
}
