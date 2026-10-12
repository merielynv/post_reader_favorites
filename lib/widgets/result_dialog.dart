import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// Shows a success / failure message dialog (used for the POST result).
Future<void> showResultDialog(
  BuildContext context, {
  required bool success,
  required String message,
}) {
  return showDialog<void>(
    context: context,
    builder:
        (ctx) => AlertDialog(
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 8),
              Icon(
                success ? Icons.check_circle : Icons.cancel,
                size: 60,
                color: success ? AppColors.primary : AppColors.error,
              ),
              const SizedBox(height: 14),
              Text(
                message,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: 120,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text('OK'),
                ),
              ),
            ],
          ),
        ),
  );
}
