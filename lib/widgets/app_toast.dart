import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../theme/app_colors.dart';
import '../theme/app_theme.dart';

enum AppToastType { success, error, info, download, loading, celebration }

/// Standardized, minimal, and attractive in-app toasts for FIT//IRON.
class AppToast {
  static void show(
    BuildContext context, {
    required String message,
    AppToastType type = AppToastType.info,
    IconData? customIcon,
    Duration duration = const Duration(seconds: 3),
    VoidCallback? onAction,
    String? actionLabel,
  }) {
    final gc = context.gc;

    Color accentColor;
    IconData iconData;
    final bool isLoading = type == AppToastType.loading;

    switch (type) {
      case AppToastType.success:
        accentColor = gc.accent;
        iconData = customIcon ?? PhosphorIcons.checkCircle(PhosphorIconsStyle.fill);
        break;
      case AppToastType.error:
        accentColor = const Color(0xFFFF5555);
        iconData = customIcon ?? PhosphorIcons.xCircle(PhosphorIconsStyle.fill);
        break;
      case AppToastType.download:
        accentColor = gc.accent;
        iconData = customIcon ?? PhosphorIcons.downloadSimple(PhosphorIconsStyle.bold);
        break;
      case AppToastType.celebration:
        accentColor = gc.ember;
        iconData = customIcon ?? PhosphorIcons.trophy(PhosphorIconsStyle.fill);
        break;
      case AppToastType.loading:
        accentColor = gc.accent;
        iconData = customIcon ?? PhosphorIcons.circleNotch(PhosphorIconsStyle.bold);
        break;
      case AppToastType.info:
        accentColor = gc.accent;
        iconData = customIcon ?? PhosphorIcons.info(PhosphorIconsStyle.fill);
        break;
    }

    final messenger = ScaffoldMessenger.of(context);
    messenger.hideCurrentSnackBar();

    messenger.showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        backgroundColor: gc.bgRaised,
        elevation: 12,
        margin: const EdgeInsets.fromLTRB(16, 8, 16, 20),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: accentColor.withValues(alpha: 0.35), width: 1.2),
        ),
        duration: isLoading ? const Duration(minutes: 2) : duration,
        content: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: accentColor.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: isLoading
                  ? SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(accentColor),
                      ),
                    )
                  : Icon(iconData, size: 18, color: accentColor),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: AppTheme.s(13, weight: FontWeight.w600, color: gc.text),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (actionLabel != null && onAction != null) ...[
              const SizedBox(width: 8),
              GestureDetector(
                onTap: () {
                  messenger.hideCurrentSnackBar();
                  onAction();
                },
                child: Text(
                  actionLabel.toUpperCase(),
                  style: AppTheme.d(12, weight: FontWeight.w700, color: accentColor, letterSpacing: 1),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  static void showSuccess(BuildContext context, String message) {
    show(context, message: message, type: AppToastType.success);
  }

  static void showError(BuildContext context, String message) {
    show(context, message: message, type: AppToastType.error);
  }

  static void showDownload(BuildContext context, String message) {
    show(context, message: message, type: AppToastType.download);
  }

  static void showInfo(BuildContext context, String message) {
    show(context, message: message, type: AppToastType.info);
  }

  static void showLoading(BuildContext context, String message) {
    show(context, message: message, type: AppToastType.loading);
  }

  static void hide(BuildContext context) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
  }
}
