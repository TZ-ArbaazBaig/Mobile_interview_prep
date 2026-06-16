import 'package:flutter/material.dart';
import 'package:clerk_flutter/clerk_flutter.dart';
import 'package:clerk_auth/clerk_auth.dart';
import '../core/router/app_router.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';
import 'package:url_launcher/url_launcher.dart';

typedef ClerkUser = User;

class AuthProvider extends ChangeNotifier {
  final AuthService _authService;
  
  ClerkUser? _user;
  UserModel? _currentUser;
  bool _isLoading = true;

  AuthProvider(this._authService);

  ClerkUser? get user => _user;
  UserModel? get currentUser => _currentUser;
  bool get isAuthenticated => _user != null;
  bool get isLoading => _isLoading;

  Future<void> initialize() async {
    _isLoading = true;
    notifyListeners();

    try {
      final context = AppRouter.navigatorKey.currentContext;
      if (context != null) {
        _user = ClerkAuth.userOf(context);
        if (_user != null) {
          await syncBackendUser();
        }
      }
    } catch (_) {
      // Fail-soft for initialization errors
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> syncBackendUser() async {
    if (_user == null) return;
    
    final email = (_user!.emailAddresses != null && _user!.emailAddresses!.isNotEmpty)
        ? _user!.emailAddresses!.first.emailAddress
        : '';
        
    try {
      _currentUser = await _authService.syncUser(
        _user!.id,
        email,
        _user!.firstName,
        _user!.lastName,
        _user!.imageUrl,
      );
    } catch (_) {
      // Fail-soft if database sync fails
    }
  }

  Future<void> signIn(String email, String password) async {
    _isLoading = true;
    notifyListeners();

    try {
      final context = AppRouter.navigatorKey.currentContext;
      if (context != null) {
        final authState = ClerkAuth.of(context);
        await authState.attemptSignIn(
          strategy: Strategy.password,
          identifier: email,
          password: password,
        );
        if (context.mounted) {
          _user = ClerkAuth.userOf(context);
          if (_user != null) {
            await syncBackendUser();
          }
        }
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> signUp(String email, String password, String name) async {
    _isLoading = true;
    notifyListeners();

    try {
      final context = AppRouter.navigatorKey.currentContext;
      if (context != null) {
        final authState = ClerkAuth.of(context);
        await authState.attemptSignUp(
          strategy: Strategy.password,
          emailAddress: email,
          password: password,
        );
        
        // Wait: Some Clerk strategies automatically sign the user in, 
        // but if not, we can fetch the user.
        if (context.mounted) {
          _user = ClerkAuth.userOf(context);
          if (_user != null) {
            await syncBackendUser();
          }
        }
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> signInWithGoogle() async {
    _isLoading = true;
    notifyListeners();

    try {
      final context = AppRouter.navigatorKey.currentContext;
      if (context != null) {
        final authState = ClerkAuth.of(context);
        
        // Capture hidden API errors from Clerk
        String? clerkError;
        final errorSub = authState.errorStream.listen((err) {
          clerkError = err.message;
          debugPrint('Clerk API Error: ${err.message}');
        });
        
        try {
          // Initiate OAuth flow
          debugPrint('Initiating Google OAuth flow...');
          await authState.oauthSignIn(
            strategy: Strategy.oauthGoogle,
            redirect: Uri.parse('interviewprep://oauth-callback'),
          );
          
          if (clerkError != null) {
            throw Exception(clerkError);
          }
          
          final signIn = authState.client.signIn;
          final verification = signIn?.firstFactorVerification;
          
          debugPrint('SignIn object: $signIn');
          debugPrint('Verification object: $verification');
          
          if (verification != null) {
            final redirectUrl = verification.externalVerificationRedirectUrl;
            debugPrint('Redirect URL: $redirectUrl');
            
            if (redirectUrl != null && redirectUrl.toString().isNotEmpty) {
              final uri = Uri.parse(redirectUrl.toString());
              debugPrint('Launching URL in app browser: $uri');
              // Use inAppBrowserView so it doesn't leave the app visually
              await launchUrl(
                uri, 
                mode: LaunchMode.inAppBrowserView,
              );
            } else {
              debugPrint('Redirect URL is null or empty');
            }
          } else {
            debugPrint('Verification object is null. Cannot extract redirect URL.');
            throw Exception('Clerk did not return a valid Google Sign-In verification URL.');
          }
        } catch (e) {
          debugPrint('Error starting OAuth flow: $e');
          throw Exception('Failed to start Google Sign-In: $e');
        } finally {
          await errorSub.cancel();
        }

        if (context.mounted) {
          _user = ClerkAuth.userOf(context);
          if (_user != null) {
            await syncBackendUser();
          }
        }
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> signOut() async {
    _isLoading = true;
    notifyListeners();

    try {
      final context = AppRouter.navigatorKey.currentContext;
      if (context != null) {
        final authState = ClerkAuth.of(context);
        await authState.signOut();
        _user = null;
        _currentUser = null;
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<String?> getToken() async {
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
  }
}
