import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/services/mission_onboarding_service.dart';
import '../../features/home/presentation/home_page.dart';
import '../../features/lesson/presentation/lesson_page.dart';
import '../../features/onboarding/presentation/onboarding_page.dart';
import '../../features/settings/presentation/settings_page.dart';
import '../../features/splash/presentation/splash_page.dart';

class AppRouter {
  static const String splashPath = '/splash';
  static const String onboardingPath = '/onboarding';
  static const String homePath = '/home';
  static const String settingsPath = '/settings';
  static const String missionPathPattern = '/mission/:missionId';
  static const String initialMissionId = 'mission_001';

  static GoRouter get router => createRouter();

  static GoRouter createRouter({String initialLocation = splashPath}) {
    return GoRouter(
      initialLocation: initialLocation,
      routes: <RouteBase>[
        GoRoute(path: '/', redirect: (context, state) => splashPath),
        GoRoute(
          path: splashPath,
          builder: (context, state) {
            return SplashPage(onFinished: () => _routeAfterSplash(context));
          },
        ),
        GoRoute(
          path: onboardingPath,
          builder: (context, state) {
            final query = state.uri.queryParameters;
            return OnboardingPage(
              missionId: query['missionId'] ?? initialMissionId,
              entryFromHome: query['entryFromHome'] == 'true',
            );
          },
        ),
        GoRoute(path: homePath, builder: (context, state) => const HomePage()),
        GoRoute(
          path: settingsPath,
          builder: (context, state) => const SettingsPage(),
        ),
        GoRoute(
          path: missionPathPattern,
          builder: (context, state) {
            final missionId =
                state.pathParameters['missionId'] ?? initialMissionId;
            return LessonPage(missionId: missionId);
          },
        ),
      ],
    );
  }

  static String onboardingLocation({
    String missionId = initialMissionId,
    bool entryFromHome = false,
  }) {
    final queryParameters = <String, String>{'missionId': missionId};
    if (entryFromHome) {
      queryParameters['entryFromHome'] = 'true';
    }
    return Uri(
      path: onboardingPath,
      queryParameters: queryParameters,
    ).toString();
  }

  static String missionLocation(String missionId) => '/mission/$missionId';

  static Future<void> _routeAfterSplash(BuildContext context) async {
    final onboardingService = MissionOnboardingService();
    final shouldShowOnboarding = await onboardingService.shouldShow(
      initialMissionId,
    );

    if (!context.mounted) {
      return;
    }

    if (shouldShowOnboarding) {
      context.go(onboardingLocation());
      return;
    }

    context.go(homePath);
  }
}
