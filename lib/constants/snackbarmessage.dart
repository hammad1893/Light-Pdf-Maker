import 'package:flutter/material.dart';
import 'package:top_snackbar_flutter/top_snack_bar.dart';
import 'package:top_snackbar_flutter/top_snack_bar.dart' as ts;

class SnackbarMessage {
  static void success(BuildContext context, String message) {
    _showCustomSnackbar(
      context,
      message: message,
      bgColor: Colors.green.shade600,
      icon: Icons.check_rounded,
      iconColor: Colors.green.shade100,
      position: ts.SnackBarPosition.top,
    );
  }

  static void info(BuildContext context, String message) {
    _showCustomSnackbar(
      context,
      message: message,
      bgColor: Colors.blue.shade600,
      icon: Icons.info_rounded,
      iconColor: Colors.blue.shade100,
      position: ts.SnackBarPosition.top,
    );
  }

  static void error(BuildContext context, String message) {
    _showCustomSnackbar(
      context,
      message: message,
      bgColor: Colors.red.shade600,
      icon: Icons.error_rounded,
      iconColor: Colors.red.shade100,
      position: ts.SnackBarPosition.bottom, // errors slide up from bottom
    );
  }

  static void _showCustomSnackbar(
    BuildContext context, {
    required String message,
    required Color bgColor,
    required IconData icon,
    required Color iconColor,
    required ts.SnackBarPosition position,
  }) {
    showTopSnackBar(
      Overlay.of(context),
      Material(
        color: Colors.transparent,
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: bgColor.withOpacity(0.4),
                blurRadius: 12,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [Colors.white.withOpacity(0.3), Colors.white10],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Icon(icon, color: iconColor, size: 26),
              ),

              const SizedBox(width: 14),

              Expanded(
                child: Text(
                  message,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
      snackBarPosition: position,
      displayDuration: const Duration(milliseconds: 1500),
    );
  }
}
