import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';
import 'package:clerk_flutter/clerk_flutter.dart';

import 'app.dart';
import 'core/api/dio_client.dart';
import 'core/router/app_router.dart';
import 'services/auth_service.dart';
import 'services/session_service.dart';
import 'services/interview_service.dart';
import 'services/results_service.dart';
import 'providers/auth_provider.dart';
import 'providers/session_provider.dart';
import 'providers/interview_provider.dart';
import 'providers/results_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Load environment variables (.env file)
  try {
    await dotenv.load(fileName: ".env");
  } catch (_) {
    // Fail-soft if .env is missing or cannot load
  }

  // Setup dynamic JWT token resolver for Dio
  DioClient.tokenGetter = () async {
    final context = AppRouter.navigatorKey.currentContext;
    if (context != null) {
      try {
        final authState = ClerkAuth.of(context);
        final sessionToken = await authState.sessionToken();
        return sessionToken.jwt;
      } catch (_) {
        return null;
      }
    }
    return null;
  };

  final clerkKey = dotenv.env['CLERK_PUBLISHABLE_KEY'] ??
      dotenv.env['VITE_CLERK_PUBLISHABLE_KEY'] ??
      '';

  runApp(
    ClerkAuth(
      config: ClerkAuthConfig(publishableKey: clerkKey),
      child: MultiProvider(
        providers: [
          // Network clients & API clients
          Provider<DioClient>(
            create: (_) => DioClient(),
          ),
          
          // API Services
          ProxyProvider<DioClient, AuthService>(
            update: (_, client, __) => AuthService(client),
          ),
          ProxyProvider<DioClient, SessionService>(
            update: (_, client, __) => SessionService(client),
          ),
          ProxyProvider<DioClient, InterviewService>(
            update: (_, client, __) => InterviewService(client),
          ),
          ProxyProvider<DioClient, ResultsService>(
            update: (_, client, __) => ResultsService(client),
          ),

          // ChangeNotifier State Providers
          ChangeNotifierProxyProvider<AuthService, AuthProvider>(
            create: (context) => AuthProvider(context.read<AuthService>()),
            update: (_, service, previous) => previous ?? AuthProvider(service),
          ),
          ChangeNotifierProxyProvider<SessionService, SessionProvider>(
            create: (context) => SessionProvider(context.read<SessionService>()),
            update: (_, service, previous) => previous ?? SessionProvider(service),
          ),
          ChangeNotifierProxyProvider<InterviewService, InterviewProvider>(
            create: (context) => InterviewProvider(context.read<InterviewService>()),
            update: (_, service, previous) => previous ?? InterviewProvider(service),
          ),
          ChangeNotifierProxyProvider<ResultsService, ResultsProvider>(
            create: (context) => ResultsProvider(context.read<ResultsService>()),
            update: (_, service, previous) => previous ?? ResultsProvider(service),
          ),
        ],
        child: const InterviewPrepApp(),
      ),
    ),
  );
}
