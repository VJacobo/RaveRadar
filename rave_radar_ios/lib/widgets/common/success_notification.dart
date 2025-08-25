import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class SuccessNotification {
  static void show({
    required BuildContext context,
    required String title,
    required String subtitle,
    required Color backgroundColor,
    IconData? icon,
    String? emoji,
    String? actionLabel,
    VoidCallback? onActionPressed,
    Duration duration = const Duration(seconds: 4),
  }) {
    // Haptic feedback for success
    HapticFeedback.mediumImpact();
    
    // Clear any existing snackbars
    ScaffoldMessenger.of(context).clearSnackBars();
    
    // Show the notification
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            children: [
              if (emoji != null) 
                Text(
                  emoji,
                  style: const TextStyle(fontSize: 28),
                )
              else if (icon != null)
                Icon(icon, color: Colors.white, size: 24),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    if (subtitle.isNotEmpty)
                      Text(
                        subtitle,
                        style: const TextStyle(fontSize: 14),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
        backgroundColor: backgroundColor,
        behavior: SnackBarBehavior.floating,
        duration: duration,
        margin: const EdgeInsets.all(20),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        action: actionLabel != null
            ? SnackBarAction(
                label: actionLabel,
                textColor: Colors.white,
                onPressed: onActionPressed ?? () {},
              )
            : null,
      ),
    );
  }
  
  static void showQuick({
    required BuildContext context,
    required String message,
    IconData icon = Icons.check_circle,
  }) {
    show(
      context: context,
      title: message,
      subtitle: '',
      backgroundColor: Colors.green,
      icon: icon,
      duration: const Duration(seconds: 2),
    );
  }
}