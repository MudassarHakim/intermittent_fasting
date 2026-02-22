import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../screens/body_metrics_screen.dart';
import '../screens/home_screen.dart';
import '../screens/meal_journal_screen.dart';
import '../screens/timer_screen.dart';
import '../screens/history_screen.dart';
import '../screens/settings_screen.dart';
import '../widgets/bottom_nav.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>();
final _shellNavigatorKey = GlobalKey<NavigatorState>();

final router = GoRouter(
  navigatorKey: _rootNavigatorKey,
  initialLocation: '/home',
  routes: [
    ShellRoute(
      navigatorKey: _shellNavigatorKey,
      builder: (context, state, child) => AppShell(child: child),
      routes: [
        GoRoute(
          path: '/home',
          pageBuilder: (context, state) => const NoTransitionPage(
            child: HomeScreen(),
          ),
        ),
        GoRoute(
          path: '/timer',
          pageBuilder: (context, state) => const NoTransitionPage(
            child: TimerScreen(),
          ),
        ),
        GoRoute(
          path: '/history',
          pageBuilder: (context, state) => const NoTransitionPage(
            child: HistoryScreen(),
          ),
        ),
        GoRoute(
          path: '/settings',
          pageBuilder: (context, state) => const NoTransitionPage(
            child: SettingsScreen(),
          ),
        ),
      ],
    ),
    GoRoute(
      path: '/body-metrics',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) => const BodyMetricsScreen(),
    ),
    GoRoute(
      path: '/meal-journal',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) => const MealJournalScreen(),
    ),
  ],
);
