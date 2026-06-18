import 'package:flutter/material.dart';
import 'package:clerk_flutter/clerk_flutter.dart';
import 'package:clerk_auth/clerk_auth.dart';
import '../core/router/app_router.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';
import '../shared/widgets/oauth_bottom_sheet.dart';

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

  Future<bool> signUp(String email, String password, String firstName, String lastName) async {
    _isLoading = true;
    notifyListeners();

    try {
      final context = AppRouter.navigatorKey.currentContext;
      if (context != null) {
        final authState = ClerkAuth.of(context);
        final client = await authState.attemptSignUp(
          strategy: Strategy.emailCode,
          emailAddress: email,
          password: password,
          passwordConfirmation: password,
          firstName: firstName,
          lastName: lastName,
        );
        
        if (client.signUp != null && client.signUp!.unverifiedFields.contains(Field.emailAddress)) {
          return true; // OTP Verification required
        }
        
        _user = ClerkAuth.userOf(context);
        if (_user != null) {
          await syncBackendUser();
        }
        return false; // SignUp complete, no OTP needed
      }
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> verifySignUpCode(String code) async {
    _isLoading = true;
    notifyListeners();

    try {
      final context = AppRouter.navigatorKey.currentContext;
      if (context != null) {
        final authState = ClerkAuth.of(context);
        final client = await authState.attemptSignUp(
          strategy: Strategy.emailCode,
          code: code,
        );
        
        if (client.signUp == null && client.user != null) {
          _user = ClerkAuth.userOf(context);
          if (_user != null) {
            await syncBackendUser();
          }
        } else if (client.signUp != null && client.signUp!.unverifiedFields.contains(Field.emailAddress)) {
          throw Exception("Verification code is incorrect or expired.");
        }
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> signInWithGoogle(BuildContext context) async {
    _isLoading = true;
    notifyListeners();

    try {
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
            debugPrint('Showing URL in bottom sheet WebView: $uri');
            
            if (context.mounted) {
              await showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                backgroundColor: Colors.transparent,
                builder: (context) => OAuthBottomSheet(url: uri),
              );
            }
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
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> handleOAuthRedirect(Uri uri) async {
    final context = AppRouter.navigatorKey.currentContext;
    if (context == null) return;

    // Show success popup to user
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Successfully authenticated! Syncing data...'),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
      ),
    );

    final authState = ClerkAuth.of(context);
    final token = uri.queryParameters['token'] ??
        uri.queryParameters['rotating_token_nonce'];

    try {
      if (token != null) {
        await authState.attemptSignIn(
            strategy: Strategy.oauthGoogle, token: token);
      } else {
        await authState.transfer();
      }
    } catch (e) {
      debugPrint('Error attempting sign in on redirect: $e');
    }

    try {
      await authState.refreshClient();
    } catch (e) {
      debugPrint('Error refreshing client: $e');
    }

    await initialize(); // Re-sync user state from Clerk
    debugPrint(
        'Successfully re-initialized AuthProvider with new Clerk state.');

    // Force the router to evaluate redirects and go to dashboard
    AppRouter.router.refresh();
    AppRouter.router.go(AppRouter.dashboard);
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
