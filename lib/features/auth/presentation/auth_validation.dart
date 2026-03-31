import 'package:fitcraft/features/auth/presentation/auth_strings.dart';

/// Validates an email address for auth forms.
String? validateEmail(String? value) {
  if (value == null || value.trim().isEmpty) {
    return AuthStrings.emailRequired;
  }

  final emailPattern = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
  if (!emailPattern.hasMatch(value.trim())) {
    return AuthStrings.validEmailRequired;
  }

  return null;
}

/// Validates a login password field.
String? validateLoginPassword(String? value) {
  if (value == null || value.isEmpty) {
    return AuthStrings.passwordRequired;
  }
  if (value.length < 6) {
    return AuthStrings.passwordTooShort;
  }
  return null;
}

/// Validates a signup password field.
String? validateSignupPassword(String? value) {
  if (value == null || value.isEmpty) {
    return AuthStrings.passwordRequired;
  }
  if (value.length < 8) {
    return AuthStrings.passwordMinEight;
  }
  return null;
}

/// Validates a required display name field.
String? validateDisplayName(String? value) {
  if (value == null || value.trim().isEmpty) {
    return AuthStrings.nameRequired;
  }
  return null;
}

/// Validates that password confirmation matches the original password.
String? validatePasswordConfirmation(String? value, String password) {
  if (value == null || value.isEmpty) {
    return AuthStrings.confirmPasswordRequired;
  }
  if (value != password) {
    return AuthStrings.passwordMismatch;
  }
  return null;
}
