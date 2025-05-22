import 'package:another_flushbar/flushbar.dart';
import 'package:flutter/material.dart';

class TopNotificationUtils {
  static void showSuccessNotification(
    BuildContext context, {
    required String title,
    required String message,
  }) {
    // Create and show the Flushbar, then store the returned future
    final flushbar = Flushbar(
      margin: const EdgeInsets.all(16),
      borderRadius: BorderRadius.circular(12),
      backgroundColor: Colors.green.shade600,
      flushbarPosition: FlushbarPosition.TOP,
      icon: const Icon(Icons.check_circle, color: Colors.white, size: 32),
      titleText: Text(
        title,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 18,
        ),
      ),
      messageText: Text(
        message,
        style: const TextStyle(color: Colors.white, fontSize: 16),
      ),
      duration: const Duration(seconds: 4), // Reduced duration
      animationDuration: const Duration(milliseconds: 500),
      isDismissible: true, // Allow user to dismiss by tapping
      dismissDirection: FlushbarDismissDirection.HORIZONTAL, // Swipe to dismiss
      forwardAnimationCurve: Curves.easeOutCirc,
    );
    
    // Show the flushbar and handle its dismissal
    flushbar.show(context).then((_) {
      // This runs after the flushbar is dismissed
      // No need to do anything here as the flushbar is already gone
    });
  }

  static void showErrorNotification(
    BuildContext context, {
    required String title,
    required String message,
  }) {
    Flushbar(
      margin: const EdgeInsets.all(16),
      borderRadius: BorderRadius.circular(12),
      backgroundColor: Colors.red.shade600,
      flushbarPosition: FlushbarPosition.TOP,
      icon: const Icon(Icons.error_outline, color: Colors.white, size: 32),
      titleText: Text(
        title,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 18,
        ),
      ),
      messageText: Text(
        message,
        style: const TextStyle(color: Colors.white, fontSize: 16),
      ),
      duration: const Duration(seconds: 8),
      animationDuration: const Duration(milliseconds: 500),
    ).show(context);
  }
}
