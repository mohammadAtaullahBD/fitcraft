import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fitcraft/features/auth/domain/auth_repository.dart';
import 'package:fitcraft/features/auth/presentation/auth_strings.dart';
import 'package:fitcraft/features/auth/state/auth_action_state.dart';
import 'package:fitcraft/features/auth/state/auth_provider.dart';

/// Handles login, signup, and password-reset actions for auth screens.
class AuthFormNotifier extends Notifier<AuthActionState> {
  @override
  AuthActionState build() => const AuthActionState.idle();

  /// Signs in a user with email and password.
  Future<void> signInWithEmail({
    required String email,
    required String password,
  }) async {
    state = const AuthActionState.loading();
    try {
      await ref.read(authRepositoryProvider).signInWithEmail(
            email: email,
            password: password,
          );
      state = const AuthActionState.success();
    } catch (error) {
      state = AuthActionState.error(_mapAuthError(error));
    }
  }

  /// Starts the Google sign-in flow.
  Future<void> signInWithGoogle() async {
    state = const AuthActionState.loading();
    try {
      await ref.read(authRepositoryProvider).signInWithGoogle();
      state = const AuthActionState.success();
    } catch (error) {
      state = AuthActionState.error(_mapAuthError(error));
    }
  }

  /// Creates a new user account and requests email verification.
  Future<void> signUpWithEmail({
    required String email,
    required String password,
    required String displayName,
  }) async {
    state = const AuthActionState.loading();
    try {
      await ref.read(authRepositoryProvider).signUpWithEmail(
            email: email,
            password: password,
            displayName: displayName,
          );
      state = const AuthActionState.success(AuthStrings.verificationEmailSent);
    } catch (error) {
      state = AuthActionState.error(_mapAuthError(error));
    }
  }

  /// Sends a password reset email to the provided address.
  Future<void> sendResetLink(String email) async {
    state = const AuthActionState.loading();
    try {
      await ref.read(authRepositoryProvider).resetPassword(email);
      state = AuthActionState.success(email.trim());
    } catch (error) {
      state = AuthActionState.error(_mapAuthError(error));
    }
  }

  /// Returns the notifier to its idle state after UI handling.
  void reset() {
    state = const AuthActionState.idle();
  }

  /// Maps repository/auth exceptions into user-facing messages.
  String _mapAuthError(Object error) {
    if (error is FirebaseAuthException) {
      final friendlyMessage = AuthFeedbackException.friendlyMessage(error.code);
      return error.message == null
          ? friendlyMessage
          : '$friendlyMessage (${error.message})';
    }

    if (error is AuthFeedbackException) {
      return error.message;
    }

    return AuthStrings.fallbackError;
  }
}

final authFormNotifierProvider =
    NotifierProvider<AuthFormNotifier, AuthActionState>(AuthFormNotifier.new);
