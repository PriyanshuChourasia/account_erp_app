import 'package:flutter/material.dart';

import '../app_exception.dart';

/// Shared helpers for surfacing errors and messages to the user.
///
/// Screens use these instead of inlining `ScaffoldMessenger` logic so that
/// error presentation stays consistent across the app.
class ErrorHandler {
  const ErrorHandler._();

  /// Shows a SnackBar for an arbitrary thrown [error].
  ///
  /// [AppException]s render their own message; anything else falls back to a
  /// generic message.
  static void showError(BuildContext context, Object error) {
    final message = error is AppException
        ? error.message
        : 'Something went wrong. Please try again.';
    _show(context, message, isError: true);
  }

  /// Shows a plain (non-error) SnackBar.
  static void showMessage(BuildContext context, String message) {
    _show(context, message);
  }

  static void _show(
    BuildContext context,
    String message, {
    bool isError = false,
  }) {
    final messenger = ScaffoldMessenger.of(context);
    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: isError
              ? Theme.of(context).colorScheme.error
              : Theme.of(context).colorScheme.inverseSurface,
          behavior: SnackBarBehavior.floating,
        ),
      );
  }
}
