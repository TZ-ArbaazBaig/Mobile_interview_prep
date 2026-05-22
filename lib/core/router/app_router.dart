import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:clerk_flutter/clerk_flutter.dart';

import '../../features/home/screens/home_screen.dart';
import '../../features/auth/screens/sign_in_screen.dart';
import '../../features/auth/screens/sign_up_screen.dart';
import '../../features/dashboard/screens/dashboard_screen.dart';
import '../../features/new_session/screens/new_session_screen.dart';
import '../../features/interview/screens/interview_screen.dart';
import '../../features/results/screens/results_screen.dart';

class AppRouter {
  AppRouter._();

  static const String home = '/';
  static const String signIn = '/sign-in';
  static const String signUp = '/sign-up';
  static const String dashboard = '/dashboard';
  static const String newSession = '/new-session';
  static const String interview = '/interview';
  static const String results = '/results';

  static final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  static final GoRouter router = GoRouter(
    navigatorKey: navigatorKey,
    initialLocation: home,
    redirect: (context, state) {
      // Access the session from ClerkAuth
      final session = ClerkAuth.sessionOf(context);
      final isLoggedIn = session != null;
      
      final currentLoc = state.matchedLocation;
      final isAuthRoute = currentLoc == signIn || currentLoc == signUp || currentLoc == '/login';
      final isLandingRoute = currentLoc == home;

      // Unauthenticated users trying to access protected routes
      if (!isLoggedIn && !isAuthRoute && !isLandingRoute) {
        return signIn;
      }

      // Authenticated users trying to access landing or login routes
      if (isLoggedIn && (isAuthRoute || isLandingRoute)) {
        return dashboard;
      }

      return null;
    },
    routes: [
      GoRoute(
        path: home,
        builder: (context, state) => const HomeScreen(),
      ),
      GoRoute(
        path: signIn,
        builder: (context, state) => const SignInScreen(),
      ),
      GoRoute(
        path: '/login', // fallback alias
        redirect: (context, state) => signIn,
      ),
      GoRoute(
        path: signUp,
        builder: (context, state) => const SignUpScreen(),
      ),
      GoRoute(
        path: dashboard,
        builder: (context, state) => const DashboardScreen(),
      ),
      GoRoute(
        path: newSession,
        builder: (context, state) {
          final prefilledJd = state.extra as String?;
          return NewSessionScreen(prefilledJd: prefilledJd);
        },
      ),
      GoRoute(
        path: '$interview/:sessionId',
        builder: (context, state) {
          final sessionId = state.pathParameters['sessionId'] ?? '';
          return InterviewScreen(sessionId: sessionId);
        },
      ),
      GoRoute(
        path: '$results/:sessionId',
        builder: (context, state) {
          final sessionId = state.pathParameters['sessionId'] ?? '';
          return ResultsScreen(sessionId: sessionId);
        },
      ),
    ],
  );
}
