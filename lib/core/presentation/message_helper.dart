import 'package:flutter/material.dart';

class MessageHelper {
  static void showIconSnackBar(
    BuildContext context, {
    required String? message,
    bool isSuccess = true,
  }) {
    if (message == null || message.isEmpty) return;

    final theme = Theme.of(context);
    final color = isSuccess ? Colors.green : Colors.red;
    final icon = isSuccess ? Icons.check_circle_outline : Icons.error_outline;

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          backgroundColor: color,
          margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          duration: Duration(seconds: isSuccess ? 3 : 4),
          content: Row(
            children: [
              Icon(icon, color: Colors.white),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  message,
                  style: theme.textTheme.bodyMedium
                      ?.copyWith(color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      );
  }
}
