import 'package:vpay/shared/models/user_model.dart';

class AuthState {
  final bool isLoading;
  final UserModel? user;
  final String? error;
  final String? info;

  const AuthState._({
    required this.isLoading,
    this.user,
    this.error,
    this.info,
  });

  factory AuthState.initial() => const AuthState._(isLoading: false);
  factory AuthState.loading() => const AuthState._(isLoading: true);
  factory AuthState.authenticated(UserModel user) =>
      AuthState._(isLoading: false, user: user);
  factory AuthState.unauthenticated({String? info}) =>
      AuthState._(isLoading: false, info: info);
  factory AuthState.error(String error) =>
      AuthState._(isLoading: false, error: error);

  AuthState copyWith({
    bool? isLoading,
    UserModel? user,
    String? error,
    String? info,
  }) {
    return AuthState._(
      isLoading: isLoading ?? this.isLoading,
      user: user ?? this.user,
      error: error ?? this.error,
      info: info ?? this.info,
    );
  }
}
