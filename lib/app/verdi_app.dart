import 'package:flutter/material.dart';
import '../features/shell/presentation/verdi_shell.dart';
import 'app_theme.dart';

class VerdiApp extends StatelessWidget {
  const VerdiApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Verdi',
      theme: AppTheme.lightTheme,
      home: const VerdiShell(),
    );
  }
}