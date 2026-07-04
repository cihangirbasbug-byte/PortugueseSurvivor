import 'package:flutter/material.dart';

import '../../features/splash/presentation/splash_page.dart';

class AppRouter {
  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    return MaterialPageRoute(
      builder: (_) => const SplashPage(),
    );
  }
}