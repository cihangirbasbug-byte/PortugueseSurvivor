import 'package:flutter/material.dart';

import '../core/theme/app_theme.dart';
import '../features/splash/presentation/splash_page.dart';

class PortugueseSurvivorApp extends StatelessWidget {
  const PortugueseSurvivorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Portekizli Hayatta Kal',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      home: const SplashPage(),
    );
  }
}
