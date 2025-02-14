import 'package:flutter/material.dart';

/// Shows a material design alert dialog with Cancel and Continue buttons.
/// Returns true if the user presses Continue and the callback executes successfully.
/// Returns false if the user cancels or the callback fails.
Future<bool> showCustomAlertDialog({
  required BuildContext context,
  required String message,
  required Future<bool> Function() callback,
}) async {
  final bool? result = await showDialog<bool>(
    context: context,
    barrierDismissible: true,
    builder: (BuildContext context) {
      return AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        content: Text(
          message,
          style: Theme.of(context).textTheme.bodyLarge,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(
              'Cancel',
              style: TextStyle(
                color: Theme.of(context).textTheme.bodyLarge?.color?.withOpacity(0.7),
              ),
            ),
          ),
          FilledButton(
            onPressed: () async {
              try {
                final bool success = await callback();
                if (!context.mounted) return;
                Navigator.of(context).pop(success);
              } catch (e) {
                if (!context.mounted) return;
                Navigator.of(context).pop(false);
              }
            },
            child: const Text('Continue'),
          ),
        ],
      );
    },
  );

  return result ?? false;
}
