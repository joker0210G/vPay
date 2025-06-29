import 'dart:async';
import 'package:flutter/foundation.dart'; // Added for debugPrint
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide AuthState;
import 'package:vpay/features/auth/data/auth_repository.dart';
import 'package:vpay/features/auth/providers/auth_state.dart';

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  final repository = ref.watch(authRepositoryProvider);
  return AuthNotifier(repository);
});

class AuthNotifier extends StateNotifier<AuthState> {
  final AuthRepository _repository;
  final _supabase = Supabase.instance.client;
  Timer? _sessionTimer;
  DateTime? _lastResetRequestTime;

  AuthNotifier(this._repository) : super(AuthState.initial()) {
    _init();
    _listenToAuthChanges();
  }

  @override
  void dispose() {
    _sessionTimer?.cancel();
    super.dispose();
  }

  Future<void> _init() async {
    final user = await _repository.getCurrentUser();
    if (user != null) {
      state = AuthState.authenticated(user);
      _resetSessionTimer();
    } else {
      state = AuthState.unauthenticated();
    }
  }

  void _listenToAuthChanges() {
    _supabase.auth.onAuthStateChange.listen((data) {
      final event = data.event;
      final session = data.session;

      switch (event) {
        case AuthChangeEvent.signedIn:
          final userFromSession = session?.user;
          if (userFromSession != null) {
            final userId = userFromSession.id; // userFromSession is non-null here, id on Supabase User is non-null
            _repository.getCurrentUser(userIdOverride: userId).then((user) {
              if (user != null) {
                state = AuthState.authenticated(user);
                _resetSessionTimer();
              } else {
                state = AuthState.error('Session found, but failed to load user profile. Please try logging in manually.');
                _cancelSessionTimer();
              }
            });
          }
          break;
        case AuthChangeEvent.signedOut:
          state = AuthState.unauthenticated();
          _cancelSessionTimer(); // Cancel timer on sign out
          break;
        case AuthChangeEvent.userUpdated:
          if (session?.user != null) {
            _repository.getCurrentUser().then((user) {
              if (user != null) {
                state = AuthState.authenticated(user);
                _resetSessionTimer(); // Reset timer on user update
              }
            });
          }
          break;
        case AuthChangeEvent.tokenRefreshed:
          _handleTokenRefresh(session); // Handle token refresh
          break;
        default:
          break;
      }
    });
  }

  void _startSessionTimer() {
    _cancelSessionTimer();
    
    final session = _supabase.auth.currentSession;
    if (session == null || session.expiresAt == null) return;
    
    final expiryTime = DateTime.fromMillisecondsSinceEpoch(session.expiresAt! * 1000);
    final remaining = expiryTime.difference(DateTime.now());
    
    // Set timer to refresh 5 minutes before expiration
    final refreshTime = remaining - const Duration(minutes: 5);
    final safeRefreshTime = refreshTime > Duration.zero
        ? refreshTime
        : const Duration(seconds: 30);
    
    _sessionTimer = Timer(safeRefreshTime, () async {
      try {
        // Refresh session before it expires
        final response = await _supabase.auth.refreshSession();
        if (response.session != null && response.session!.expiresAt != null) {
          _resetSessionTimer();
        }
      } catch (e) {
        // If refresh fails, sign out
        if (state.user != null) {
          signOut();
        }
      }
    });
  }
  
  void _resetSessionTimer() {
    _cancelSessionTimer();
    _startSessionTimer();
  }
  
  void _handleTokenRefresh(Session? session) {
    if (session != null && session.expiresAt != null) {
      _resetSessionTimer();
    }
  }

  void _cancelSessionTimer() {
    _sessionTimer?.cancel();
    _sessionTimer = null;
  }

Future<void> signIn({
  required String email,
  required String password,
}) async {
  state = AuthState.loading();
  try {
    await _repository.signInWithPassword(
      email: email,
      password: password,
    );

    final user = await _repository.getCurrentUser();

    if (user != null) {
      state = AuthState.authenticated(user);
      _resetSessionTimer();
    } else {
      state = AuthState.error('Authentication successful, but failed to retrieve user profile. Please contact support or try signing up again.');
    }
  } catch (e) {
    if (e is AuthException) {
      state = AuthState.error(_mapAuthException(e));
    } else {
      state = AuthState.error('Unexpected error during login. Please try again.');
    }
  }
}

  Future<void> signUp({
    required String email,
    required String password,
    required String username,
  }) async {
    state = AuthState.loading();
    try {
      await _repository.signUp(
        email: email,
        password: password,
        username: username,
      );
      // REMOVED: await signIn(email: email, password: password); 
      // The onAuthStateChange listener will handle user profile loading and state update.
    } catch (e) {
      if (e is AuthException) {
        state = AuthState.error(_mapAuthException(e));
      } else {
        state = AuthState.error('Unexpected error during registration. Please try again.');
      }
    }
  }

  Future<void> signOut() async {
    try {
      state = AuthState.loading();
      await _repository.signOut();
      state = AuthState.unauthenticated(info: 'You have been signed out.');
    } catch (e) {
      if (e is AuthException && e.message.contains('Network error')) {
        state = AuthState.error('Network error occurred during logout. Please check your connection.');
      } else {
        state = AuthState.error('Error in logout: ${e.toString()}');
      }
    }
  }

  Future<void> resetPassword(String email) async {
    // Rate limiting: only allow one reset request every 2 minutes
    final now = DateTime.now();
    if (_lastResetRequestTime != null &&
        now.difference(_lastResetRequestTime!) < const Duration(minutes: 2)) {
      state = AuthState.error('Please wait before requesting another password reset.');
      return;
    }

    state = AuthState.loading();
    try {
      await _repository.sendPasswordResetEmail(email);
      _lastResetRequestTime = now;
      state = AuthState.unauthenticated(info: 'Password reset email sent. Please check your inbox.');
    } catch (e) {
      if (e is AuthException) {
        state = AuthState.error(_mapAuthException(e));
      } else {
        state = AuthState.error('Unexpected error sending password reset email. Please try again.');
      }
    }
  }

  Future<void> signInWithProvider(OAuthProvider provider) async {
    state = AuthState.loading();
    try {
      await _supabase.auth.signInWithOAuth(
        provider,
        redirectTo: 'io.supabase.vpay://login-callback',
      );
      final user = await _repository.getCurrentUser();
      if (user != null) {
        state = AuthState.authenticated(user);
      }
    } catch (e) {
      if (e is AuthException) {
        state = AuthState.error(_mapAuthException(e));
      } else {
        state = AuthState.error('Unexpected error during ${provider.name} login. Please try again.');
      }
    }
  }

  Future<void> signInWithGoogle() async {
    state = AuthState.loading();
    try {
      await _repository.signInWithGoogle();
      final user = await _repository.getCurrentUser();
      if (user != null) {
        state = AuthState.authenticated(user);
      }
    } catch (e) {
      if (e is AuthException) {
        state = AuthState.error(_mapAuthException(e));
      } else {
        state = AuthState.error('Unexpected error during Google login. Please try again.');
      }
    }
  }

  Future<void> signInWithFacebook() async {
    state = AuthState.loading();
    try {
      await _repository.signInWithFacebook();
      final user = await _repository.getCurrentUser();
      if (user != null) {
        state = AuthState.authenticated(user);
      }
    } catch (e) {
      if (e is AuthException) {
        state = AuthState.error(_mapAuthException(e));
      } else {
        state = AuthState.error('Unexpected error during Facebook login. Please try again.');
      }
    }
  }

  Future<void> signInWithApple() async {
    state = AuthState.loading();
    try {
      await _repository.signInWithApple();
      final user = await _repository.getCurrentUser();
      if (user != null) {
        state = AuthState.authenticated(user);
      }
    } catch (e) {
      if (e is AuthException) {
        state = AuthState.error(_mapAuthException(e));
      } else {
        state = AuthState.error('Unexpected error during Apple login. Please try again.');
      }
    }
  }

  String _mapAuthException(AuthException e) {
    if (e.message.contains('Invalid login credentials')) {
      return 'Invalid email or password';
    } else if (e.message.contains('duplicate key value')) {
      return 'The email is already registered';
    } else if (e.message.contains('weak password')) {
      return 'Password is too weak. Minimum 8 chars with mix of letters, numbers & symbols';
    } else if (e.message.contains('invalid email')) {
      return 'Invalid email format. Please check your email address.';
    } else if (e.message.contains('user not found')) {
      return 'User not found. Please check your email address.';
    } else if (e.message.contains('cancelled')) {
      return 'Login was cancelled';
    } else if (e.message.contains('popup blocked')) {
      return 'Login popup was blocked. Please allow popups for this site.';
    } else if (e.message.contains('Network error')) {
      return 'Network error occurred. Please check your connection.';
    } else if (e.message.contains('email not confirmed')) {
      return 'Email not verified. Please check your inbox for verification link.';
    } else if (e.message.contains('Too many requests') || e.message.contains('rate limit exceeded')) {
      return 'Too many attempts. Please try again later.';
    } else {
      return 'Error: ${e.message}';
    }
  }
  
  void clearInfo() {
    state = state.copyWith(info: null, error: null);
  }
  
  void clearError() {
    state = state.copyWith(error: null, info: null);
  }

  Future<void> updateUserAvatar(String newAvatarUrl) async {
    if (state.user == null) {
      // Or throw an error, or handle as appropriate for your app's logic
      debugPrint("User not logged in, cannot update avatar."); // Changed print to debugPrint
      return;
    }
    final currentUserId = state.user!.id;
    state = state.copyWith(isLoading: true); // Indicate loading if desired
    try {
      final updatedUser = await _repository.updateUserProfile(
        userId: currentUserId,
        avatarUrl: newAvatarUrl,
      );
      state = AuthState.authenticated(updatedUser); // Update with the new user model
    } catch (e) {
      // Handle error, perhaps set state to an error state or rethrow
      debugPrint("Error updating user avatar: $e"); // Changed print to debugPrint
      state = state.copyWith(isLoading: false, error: e.toString()); // Example error handling
    }
  }
}
