import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fitcraft/features/auth/domain/auth_repository.dart';

/// Provides the singleton [AuthRepository].
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository.instance;
});

/// Streams the current Firebase [User] (null when signed out).
///
/// Used by the router redirect guard and any widget that needs
/// to know whether a user is authenticated.
final authStateProvider = StreamProvider<User?>((ref) {
  final repo = ref.watch(authRepositoryProvider);
  return repo.authStateChanges;
});
