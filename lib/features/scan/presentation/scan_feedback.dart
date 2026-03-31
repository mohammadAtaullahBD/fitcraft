import 'package:flutter/material.dart';
import 'package:fitcraft/core/utils/theme.dart';

/// Shows a standard scan snackbar message.
void showScanMessage(BuildContext context, String message) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text(message)),
  );
}

/// Shows a scan error snackbar with error styling.
void showScanError(BuildContext context, String message) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(message),
      backgroundColor: AppTheme.error,
    ),
  );
}
