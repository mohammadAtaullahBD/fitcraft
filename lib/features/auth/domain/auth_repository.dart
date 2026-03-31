import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide AuthException, User;
import 'package:flutter/foundation.dart';
import 'package:fitcraft/core/services/hive_service.dart';

/// Handles all authentication operations.
///
/// Uses **Firebase Auth** for identity management and
/// **Supabase** for extended user-profile storage.
class AuthRepository {
  AuthRepository._();
  static final AuthRepository _instance = AuthRepository._();
  static AuthRepository get instance => _instance;

  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  SupabaseClient get _supabase => Supabase.instance.client;

  // ─── Streams ──────────────────────────────────────────────────

  /// Emits whenever the Firebase auth state changes (login / logout).
  Stream<User?> get authStateChanges => _firebaseAuth.authStateChanges().map((user) {
        if (user != null && !user.emailVerified) {
          return null; // Don't expose unverified users to the router
        }
        return user;
      });

  /// Current Firebase user (null if signed out).
  User? get currentUser => _firebaseAuth.currentUser;

  // ─── Email / Password ─────────────────────────────────────────

  /// Create a new account with email + password and save profile to Supabase.
  Future<UserCredential> signUpWithEmail({
    required String email,
    required String password,
    required String displayName,
  }) async {
    final credential = await _firebaseAuth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );

    // Set the display name on the Firebase user.
    await credential.user?.updateDisplayName(displayName);
    
    // Send email verification
    await credential.user?.sendEmailVerification();
    
    await credential.user?.reload();

    // Upsert profile row in Supabase.
    await _upsertProfile(
      uid: credential.user!.uid,
      email: email,
      displayName: displayName,
    );

    // Sign out immediately to enforce email verification before logging in
    await _firebaseAuth.signOut();

    return credential;
  }

  /// Sign in with an existing email + password.
  Future<UserCredential> signInWithEmail({
    required String email,
    required String password,
  }) async {
    final credential = await _firebaseAuth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
    
    if (credential.user != null && !credential.user!.emailVerified) {
      await _firebaseAuth.signOut();
      throw FirebaseAuthException(
        code: 'email-not-verified',
        message: 'Please verify your email before logging in.',
      );
    }
    
    return credential;
  }

  // ─── Google Sign-In ───────────────────────────────────────────

  /// Launch the Google Sign-In flow and authenticate via Firebase.
  Future<UserCredential> signInWithGoogle() async {
    final googleUser = await _googleSignIn.signIn();
    if (googleUser == null) {
      throw FirebaseAuthException(
        code: 'google-sign-in-cancelled',
        message: 'Google sign-in was cancelled by the user.',
      );
    }

    final googleAuth = await googleUser.authentication;
    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    final userCredential =
        await _firebaseAuth.signInWithCredential(credential);

    // Upsert profile row.
    final user = userCredential.user!;
    await _upsertProfile(
      uid: user.uid,
      email: user.email ?? '',
      displayName: user.displayName ?? '',
      photoUrl: user.photoURL,
    );

    return userCredential;
  }

  // ─── Password Reset ───────────────────────────────────────────

  /// Send a password-reset email.
  Future<void> resetPassword(String email) {
    return _firebaseAuth.sendPasswordResetEmail(email: email);
  }

  // ─── Sign Out ─────────────────────────────────────────────────

  /// Sign out from Firebase + Google, and clear local cache.
  Future<void> signOut() async {
    await _googleSignIn.signOut();
    await _firebaseAuth.signOut();
    await HiveService.instance.clearAll();
  }

  // ─── Supabase Profile ─────────────────────────────────────────

  /// Upsert a row in the `profiles` table.
  Future<void> _upsertProfile({
    required String uid,
    required String email,
    required String displayName,
    String? photoUrl,
  }) async {
    try {
      await _supabase.from('profiles').upsert({
        'uid': uid,
        'email': email,
        'display_name': displayName,
        'photo_url': photoUrl,
        'updated_at': DateTime.now().toUtc().toIso8601String(),
      }, onConflict: 'uid');
    } catch (e) {
      // Non-fatal: profile sync failure should not block auth.
      debugPrint('⚠ Supabase profile upsert failed: $e');
    }
  }
}

/// Custom exception wrapper for auth errors shown in the UI.
class AuthFeedbackException implements Exception {
  final String code;
  final String message;

  const AuthFeedbackException({
    required this.code,
    required this.message,
  });

  @override
  String toString() => message;

  /// Convert an error code to a user-friendly message.
  static String friendlyMessage(String code) {
    switch (code) {
      case 'user-not-found':
        return 'No account found with that email.';
      case 'wrong-password':
        return 'Incorrect password. Please try again.';
      case 'email-not-verified':
        return 'Please check your email and verify your account to log in.';
      case 'email-already-in-use':
        return 'An account with that email already exists.';
      case 'weak-password':
        return 'Password is too weak. Use at least 8 characters.';
      case 'invalid-email':
        return 'Please enter a valid email address.';
      case 'too-many-requests':
        return 'Too many attempts. Please wait a moment.';
      case 'google-sign-in-cancelled':
        return 'Google sign-in was cancelled.';
      case 'invalid-credential':
        return 'Invalid email or password. Please try again.';
      default:
        return 'Something went wrong. Please try again.';
    }
  }
}
