import 'package:flutter/material.dart';
import 'app_shell.dart';

class VerdiApp extends StatelessWidget {
  const VerdiApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Verdi',
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: const Color(0xFF16A34A),
      ),
      home: const AppShell(),
    );
  }
}
