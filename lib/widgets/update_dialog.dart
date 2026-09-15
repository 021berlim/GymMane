import 'package:flutter/material.dart';

import '../services/update_service.dart';
import '../theme/app_colors.dart';
import '../theme/app_theme.dart';

/// Shows an in-app update dialog with changelog and download progress.
///
/// If [info.isForced], the dismiss button is hidden.
void showUpdateDialog(BuildContext context, UpdateInfo info) {
  showDialog(
    context: context,
    barrierDismissible: !info.isForced,
    builder: (_) => _UpdateDialog(info: info),
  );
}

class _UpdateDialog extends StatefulWidget {
  final UpdateInfo info;
  const _UpdateDialog({required this.info});

  @override
  State<_UpdateDialog> createState() => _UpdateDialogState();
}

class _UpdateDialogState extends State<_UpdateDialog> {
  bool _downloading = false;
  double _progress = 0;
  String? _error;

  Future<void> _startDownload() async {
    setState(() {
      _downloading = true;
      _progress = 0;
      _error = null;
    });
    try {
      await UpdateService.downloadAndInstall(
        widget.info,
        (p) {
          if (mounted) setState(() => _progress = p);
        },
      );
    } catch (e) {
      if (mounted) {
        setState(() {
          _downloading = false;
          _error = e.toString();
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final gc = context.gc;

    return PopScope(
      canPop: !widget.info.isForced,
      child: AlertDialog(
        backgroundColor: gc.bgRaised,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          'New version available',
          style: AppTheme.d(18, weight: FontWeight.w700, color: gc.text),
        ),
        content: SizedBox(
          width: double.maxFinite,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'v${widget.info.version}',
                style: AppTheme.s(14, weight: FontWeight.w600, color: gc.ember),
              ),
              const SizedBox(height: 12),
              if (widget.info.changelog.isNotEmpty) ...[
                ConstrainedBox(
                  constraints: const BoxConstraints(maxHeight: 200),
                  child: SingleChildScrollView(
                    child: Text(
                      widget.info.changelog,
                      style: AppTheme.s(13, color: gc.textSecondary),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
              ],
              if (_downloading) ...[
                ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: LinearProgressIndicator(
                    value: _progress,
                    minHeight: 6,
                    backgroundColor: gc.bgRaised2,
                    valueColor: AlwaysStoppedAnimation<Color>(gc.ember),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '${(_progress * 100).toInt()}%',
                  style: AppTheme.s(12, color: gc.textTertiary),
                ),
              ],
              if (_error != null)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    _error!,
                    style: AppTheme.s(12, color: Colors.redAccent),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
            ],
          ),
        ),
        actions: _downloading
            ? null
            : [
                if (!widget.info.isForced)
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: Text(
                      'Not now',
                      style: AppTheme.s(14, color: gc.textSecondary),
                    ),
                  ),
                TextButton(
                  onPressed: _startDownload,
                  child: Text(
                    'Update now',
                    style: AppTheme.s(
                      14,
                      weight: FontWeight.w700,
                      color: gc.accent,
                    ),
                  ),
                ),
              ],
      ),
    );
  }
}
