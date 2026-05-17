import 'package:flutter/material.dart';

class BackButtonHandler {
  static DateTime? _currentBackPressTime;

  // Call this method in every screen's back button
  static Future<bool> handleBackButton(BuildContext context) async {
    final now = DateTime.now();

    // If back button is pressed twice within 2 seconds, exit app
    if (_currentBackPressTime == null ||
        now.difference(_currentBackPressTime!) > const Duration(seconds: 2)) {
      _currentBackPressTime = now;

      return false; // Don't exit app
    }

    return true; // Exit app
  }
}
