import 'package:flutter/material.dart';

import 'screens/teduh_ready_page.dart';

void main() => runApp(const TeduhReadyApp());

class TeduhReadyApp extends StatelessWidget {
  const TeduhReadyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'TEDUH READY',
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: const Color(0xFF1B6F57),
      ),
      home: const TeduhReadyPage(),
    );
  }
}
