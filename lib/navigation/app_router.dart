import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../domain/models/jatakam_models.dart';
import '../features/about/about_screen.dart';
import '../features/calendar/calendar_screen.dart';
import '../features/calendar/day_detail_screen.dart';
import '../features/festivals/festival_detail_screen.dart';
import '../features/festivals/festivals_screen.dart';
import '../features/home/home_screen.dart';
import '../features/jatakam/graha_details_screen.dart';
import '../features/jatakam/japa_screen.dart';
import '../features/jatakam/jatakam_chart_screen.dart';
import '../features/jatakam/jatakam_overview_screen.dart';
import '../features/jatakam/nakshatra_details_screen.dart';
import '../features/jatakam/rashi_details_screen.dart';
import '../features/notifications/notification_preferences_screen.dart';
import '../features/onboarding/onboarding_screen.dart';
import '../features/profile/birth_details_form_screen.dart';
import '../features/profile/profile_screen.dart';
import '../features/search/search_screen.dart';
import '../features/settings/settings_screen.dart';
import '../features/sources/sources_screen.dart';
import '../features/splash/splash_screen.dart';
import 'app_shell.dart';

final GlobalKey<NavigatorState> rootNavigatorKey = GlobalKey<NavigatorState>();

final GoRouter appRouter = GoRouter(
  navigatorKey: rootNavigatorKey,
  initialLocation: '/splash',
  routes: [
    GoRoute(path: '/splash', builder: (context, state) => const SplashScreen()),
    GoRoute(path: '/onboarding', builder: (context, state) => const OnboardingScreen()),
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) => AppShell(navigationShell: navigationShell),
      branches: [
        StatefulShellBranch(routes: [
          GoRoute(path: '/home', builder: (context, state) => const HomeScreen()),
        ]),
        StatefulShellBranch(routes: [
          GoRoute(path: '/calendar', builder: (context, state) => const CalendarScreen()),
        ]),
        StatefulShellBranch(routes: [
          GoRoute(path: '/jatakam', builder: (context, state) => const JatakamOverviewScreen()),
        ]),
        StatefulShellBranch(routes: [
          GoRoute(path: '/festivals', builder: (context, state) => const FestivalsScreen()),
        ]),
        StatefulShellBranch(routes: [
          GoRoute(path: '/profile', builder: (context, state) => const ProfileScreen()),
        ]),
      ],
    ),
    GoRoute(
      path: '/calendar/day/:date',
      parentNavigatorKey: rootNavigatorKey,
      builder: (context, state) {
        final date = DateTime.parse(state.pathParameters['date']!);
        return DayDetailScreen(date: date);
      },
    ),
    GoRoute(
      path: '/festivals/:id',
      parentNavigatorKey: rootNavigatorKey,
      builder: (context, state) => FestivalDetailScreen(festivalId: state.pathParameters['id']!),
    ),
    GoRoute(
      path: '/search',
      parentNavigatorKey: rootNavigatorKey,
      builder: (context, state) => const SearchScreen(),
    ),
    GoRoute(
      path: '/notifications',
      parentNavigatorKey: rootNavigatorKey,
      builder: (context, state) => const NotificationPreferencesScreen(),
    ),
    GoRoute(
      path: '/profile/birth-details',
      parentNavigatorKey: rootNavigatorKey,
      builder: (context, state) => const BirthDetailsFormScreen(),
    ),
    GoRoute(
      path: '/jatakam/chart',
      parentNavigatorKey: rootNavigatorKey,
      builder: (context, state) => const JatakamChartScreen(),
    ),
    GoRoute(
      path: '/jatakam/graha/:name',
      parentNavigatorKey: rootNavigatorKey,
      builder: (context, state) {
        final graha = Graha.values.firstWhere((g) => g.name == state.pathParameters['name']);
        return GrahaDetailsScreen(graha: graha);
      },
    ),
    GoRoute(
      path: '/jatakam/rashi/:index',
      parentNavigatorKey: rootNavigatorKey,
      builder: (context, state) {
        final index = int.parse(state.pathParameters['index']!);
        return RashiDetailsScreen(rashi: Rashi.all[index - 1]);
      },
    ),
    GoRoute(
      path: '/jatakam/nakshatra/:index',
      parentNavigatorKey: rootNavigatorKey,
      builder: (context, state) {
        final index = int.parse(state.pathParameters['index']!);
        return NakshatraDetailsScreen(nakshatra: Nakshatra.all[index - 1]);
      },
    ),
    GoRoute(
      path: '/jatakam/japa',
      parentNavigatorKey: rootNavigatorKey,
      builder: (context, state) => const JapaScreen(),
    ),
    GoRoute(
      path: '/sources',
      parentNavigatorKey: rootNavigatorKey,
      builder: (context, state) => const SourcesScreen(),
    ),
    GoRoute(
      path: '/settings',
      parentNavigatorKey: rootNavigatorKey,
      builder: (context, state) => const SettingsScreen(),
    ),
    GoRoute(
      path: '/about',
      parentNavigatorKey: rootNavigatorKey,
      builder: (context, state) => const AboutScreen(),
    ),
  ],
);
