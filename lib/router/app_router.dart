import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../screens/map_screen.dart';
import '../screens/auth/login_screen.dart';
import '../screens/auth/otp_screen.dart';
import '../screens/onboarding/onboarding_screen.dart';
import '../screens/profile/profile_screen.dart';
import '../screens/notifications/notifications_screen.dart';
import '../screens/schedules/schedule_screen.dart';
import '../screens/schedules/route_details_screen.dart';
import '../screens/settings/settings_screen.dart';
import '../screens/route_comparison/route_comparison_screen.dart';

class AppRouter {
  static final GlobalKey<NavigatorState> _rootNavigatorKey =
      GlobalKey<NavigatorState>();
  static final GlobalKey<NavigatorState> _shellNavigatorKey =
      GlobalKey<NavigatorState>();

  // Helper for fade transitions
  static CustomTransitionPage _fadeTransitionPage({
    required LocalKey key,
    required Widget child,
  }) {
    return CustomTransitionPage(
      key: key,
      child: child,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        final curvedAnimation = CurvedAnimation(
          parent: animation,
          curve: Curves.easeInOutCubic, // Snappier transition
        );

        return FadeTransition(
          opacity: curvedAnimation,
          child: ScaleTransition(
            scale: Tween<double>(begin: 0.96, end: 1.0) // Slight zoom-in effect
            .animate(curvedAnimation),
            child: child,
          ),
        );
      },
    );
  }

  static CustomTransitionPage _slideTransitionPage({
    required LocalKey key,
    required Widget child,
    required Offset beginOffset,
  }) {
    return CustomTransitionPage(
      key: key,
      child: child,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        final curvedAnimation = CurvedAnimation(
          parent: animation,
          curve: Curves.easeInOutSine, // Snappier exit
        );

        return SlideTransition(
          position: Tween<Offset>(
            begin: beginOffset,
            end: Offset.zero,
          ).animate(curvedAnimation),
          child: FadeTransition(
            // Adds a subtle fade effect
            opacity: curvedAnimation,
            child: child,
          ),
        );
      },
    );
  }

  static final GoRouter router = GoRouter(
    initialLocation: '/',
    navigatorKey: _rootNavigatorKey,
    debugLogDiagnostics: true,
    routes: [
      // Onboarding Flow
      GoRoute(
        path: '/',
        pageBuilder:
            (context, state) => _fadeTransitionPage(
              key: state.pageKey,
              child: const OnboardingScreen(),
            ),
      ),
      // Auth Flow
      GoRoute(
        path: '/login',
        pageBuilder:
            (context, state) => _fadeTransitionPage(
              key: state.pageKey,
              child: const LoginScreen(),
            ),
      ),
      GoRoute(
        path: '/otp',
        pageBuilder: (context, state) {
          final phoneNumber = state.extra as String? ?? '';
          return _fadeTransitionPage(
            key: state.pageKey,
            child: OTPScreen(phoneNumber: phoneNumber),
          );
        },
      ),
      // Main App Shell with Bottom Navigation
      ShellRoute(
        navigatorKey: _shellNavigatorKey,
        builder: (context, state, child) => ScaffoldWithNavBar(child: child),
        routes: [
          // Map Screen (Home)
          GoRoute(
            path: '/map',
            pageBuilder:
                (context, state) => _slideTransitionPage(
                  key: state.pageKey,
                  child: const MapScreen(),
                  beginOffset: const Offset(-1, 0),
                ),
            routes: [
              // Route Details as sub-route of Map
              GoRoute(
                path: 'route/:routeId',
                pageBuilder: (context, state) {
                  final routeId = state.pathParameters['routeId'] ?? '';
                  return _slideTransitionPage(
                    key: state.pageKey,
                    child: RouteDetailsScreen(routeId: routeId),
                    beginOffset: const Offset(1, 0),
                  );
                },
              ),
              // Route Comparison
              GoRoute(
                path: 'compare',
                pageBuilder:
                    (context, state) => _slideTransitionPage(
                      key: state.pageKey,
                      child: const RouteComparisonScreen(),
                      beginOffset: const Offset(0, 1),
                    ),
              ),
            ],
          ),
          // Schedules Screen
          GoRoute(
            path: '/schedules',
            pageBuilder:
                (context, state) => _fadeTransitionPage(
                  key: state.pageKey,
                  child: const ScheduleScreen(),
                ),
          ),
          // Notifications Screen
          GoRoute(
            path: '/notifications',
            pageBuilder:
                (context, state) => _fadeTransitionPage(
                  key: state.pageKey,
                  child: const NotificationsScreen(),
                ),
          ),
          // Profile Screen
          GoRoute(
            path: '/profile',
            pageBuilder:
                (context, state) => _slideTransitionPage(
                  key: state.pageKey,
                  child: const ProfileScreen(),
                  beginOffset: const Offset(1, 0),
                ),
            routes: [
              // Settings (sub-route of Profile)
              GoRoute(
                path: 'settings',
                pageBuilder:
                    (context, state) => _slideTransitionPage(
                      key: state.pageKey,
                      child: const SettingsScreen(),
                      beginOffset: const Offset(-1, 0),
                    ),
              ),
            ],
          ),
        ],
      ),
    ],
  );
}

// Scaffold with bottom navigation bar for shell route
class ScaffoldWithNavBar extends StatelessWidget {
  final Widget child;

  const ScaffoldWithNavBar({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: child,
      bottomNavigationBar: NavigationBar(
        selectedIndex: _calculateSelectedIndex(context),
        onDestinationSelected: (index) => _onItemTapped(index, context),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.map), label: 'Map'),
          NavigationDestination(icon: Icon(Icons.schedule), label: 'Schedules'),
          NavigationDestination(
            icon: Icon(Icons.notifications),
            label: 'Notifications',
          ),
          NavigationDestination(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }

  int _calculateSelectedIndex(BuildContext context) {
    final String location = GoRouterState.of(context).matchedLocation;
    if (location.startsWith('/map')) {
      return 0;
    }
    if (location.startsWith('/schedules')) {
      return 1;
    }
    if (location.startsWith('/notifications')) {
      return 2;
    }
    if (location.startsWith('/profile')) {
      return 3;
    }
    return 0;
  }

  void _onItemTapped(int index, BuildContext context) {
    switch (index) {
      case 0:
        GoRouter.of(context).go('/map');
        break;
      case 1:
        GoRouter.of(context).go('/schedules');
        break;
      case 2:
        GoRouter.of(context).go('/notifications');
        break;
      case 3:
        GoRouter.of(context).go('/profile');
        break;
    }
  }
}
