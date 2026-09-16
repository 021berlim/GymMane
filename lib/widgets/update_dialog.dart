import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../services/update_service.dart';
import '../theme/app_colors.dart';
import '../theme/app_theme.dart';
import 'ui_kit.dart';

/// Shows an in-app update dialog with patch notes and download progress.
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
      if (mounted) {
        // Automatically close modal on completion
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Download concluído! Abrindo instalador...',
              style: AppTheme.s(13, color: Colors.white),
            ),
            backgroundColor: const Color(0xFF1F241C),
            duration: const Duration(seconds: 4),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _downloading = false;
          _error = 'Falha no download. Verifique sua conexão e tente novamente.';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final gc = context.gc;

    return PopScope(
      canPop: !widget.info.isForced && !_downloading,
      child: Dialog(
        backgroundColor: gc.bgRaised,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: Container(
          padding: const EdgeInsets.all(22),
          constraints: const BoxConstraints(maxWidth: 400),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header Badge & Title
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: gc.accentSoft,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(PhosphorIconsRegular.sparkle, size: 22, color: gc.accent),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'PATCH NOTES',
                          style: AppTheme.d(11, weight: FontWeight.w700, color: gc.accent, letterSpacing: 2),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Nova Versão Disposta',
                          style: AppTheme.d(18, weight: FontWeight.w700, color: gc.text),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: gc.accentSoft,
                      borderRadius: BorderRadius.circular(100),
                      border: Border.all(color: gc.accent.withValues(alpha: 0.3)),
                    ),
                    child: Text(
                      'v${widget.info.version}',
                      style: AppTheme.d(13, weight: FontWeight.w700, color: gc.accent),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 18),

              // Patch Notes Container Box
              Container(
                constraints: const BoxConstraints(maxHeight: 240),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF141712),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: gc.border),
                ),
                child: SingleChildScrollView(
                  child: _buildPatchNotesContent(gc),
                ),
              ),

              const SizedBox(height: 18),

              // Progress Bar while downloading
              if (_downloading) ...[
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Baixando atualização...',
                          style: AppTheme.s(12, color: gc.textSecondary),
                        ),
                        Text(
                          '${(_progress * 100).toInt()}%',
                          style: AppTheme.d(13, weight: FontWeight.w700, color: gc.accent),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: LinearProgressIndicator(
                        value: _progress,
                        minHeight: 8,
                        backgroundColor: gc.bgRaised2,
                        valueColor: AlwaysStoppedAnimation<Color>(gc.accent),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
              ],

              // Error display
              if (_error != null) ...[
                Text(
                  _error!,
                  style: AppTheme.s(12, color: Colors.redAccent),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
              ],

              // Action buttons
              if (!_downloading)
                Row(
                  children: [
                    if (!widget.info.isForced)
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Navigator.of(context).pop(),
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(color: gc.border),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                          ),
                          child: Text(
                            'AGORA NÃO',
                            style: AppTheme.s(13, weight: FontWeight.w600, color: gc.textSecondary),
                          ),
                        ),
                      ),
                    if (!widget.info.isForced) const SizedBox(width: 10),
                    Expanded(
                      flex: 2,
                      child: PrimaryButton(
                        label: 'ATUALIZAR AGORA',
                        onTap: _startDownload,
                      ),
                    ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPatchNotesContent(GymColors gc) {
    final raw = widget.info.changelog.trim();
    if (raw.isEmpty) {
      return Text(
        'Melhorias de desempenho, correções de bugs e otimizações gerais do FIT//IRON.',
        style: AppTheme.s(13, color: gc.textSecondary, height: 1.4),
      );
    }

    final lines = raw.split('\n');
    final items = <Widget>[];

    for (final line in lines) {
      final trimmed = line.trim();
      if (trimmed.isEmpty) continue;
      if (trimmed.contains('Full Changelog:') || trimmed.startsWith('**Full Changelog**')) continue;

      items.add(_buildPatchNotesRow(gc, trimmed));
    }

    if (items.isEmpty) {
      return Text(
        raw,
        style: AppTheme.s(13, color: gc.textSecondary, height: 1.4),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: items,
    );
  }

  Widget _buildPatchNotesRow(GymColors gc, String line) {
    if (line.startsWith('#')) {
      final headerText = line.replaceAll(RegExp(r'^#+\s*'), '').trim();
      return Padding(
        padding: const EdgeInsets.only(top: 8, bottom: 6),
        child: Text(
          headerText.toUpperCase(),
          style: AppTheme.d(11, weight: FontWeight.w700, color: gc.accent, letterSpacing: 1.5),
        ),
      );
    }

    final cleanText = line.replaceFirst(RegExp(r'^[-*•]\s*'), '').trim();

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: const EdgeInsets.only(top: 6, right: 10),
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: gc.accent,
              shape: BoxShape.circle,
            ),
          ),
          Expanded(
            child: Text(
              cleanText,
              style: AppTheme.s(13, color: gc.textSecondary, height: 1.4),
            ),
          ),
        ],
      ),
    );
  }
}
