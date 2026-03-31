import 'package:flutter/material.dart';
import 'package:fitcraft/core/utils/theme.dart';
import 'package:fitcraft/features/auth/presentation/auth_strings.dart';

/// Returns a score from 0–4 based on basic password heuristics.
int calculatePasswordStrength(String password) {
  var score = 0;
  if (password.length >= 8) score++;
  if (password.contains(RegExp(r'[A-Z]'))) score++;
  if (password.contains(RegExp(r'[0-9]'))) score++;
  if (password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'))) score++;
  return score;
}

/// Returns the color associated with a password strength score.
Color passwordStrengthColor(int score) {
  switch (score) {
    case 0:
    case 1:
      return AppTheme.error;
    case 2:
      return AppTheme.warning;
    case 3:
      return AppTheme.accent;
    default:
      return AppTheme.success;
  }
}

/// Returns the label associated with a password strength score.
String passwordStrengthLabel(int score) {
  switch (score) {
    case 0:
      return AuthStrings.veryWeak;
    case 1:
      return AuthStrings.weak;
    case 2:
      return AuthStrings.fair;
    case 3:
      return AuthStrings.strong;
    default:
      return AuthStrings.veryStrong;
  }
}
