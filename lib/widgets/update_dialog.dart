import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../services/update_service.dart';
import '../theme/app_colors.dart';
import '../theme/app_theme.dart';
import 'glass.dart';
import 'ui_kit.dart';

/// Shows an in-app update bottom sheet with clean patch notes and download progress.
///
/// Designed after Samsung OneUI, Xiaomi HyperOS, and Discord update sheets while
/// preserving FIT//IRON's signature dark neon design system.
void showUpdateDialog(BuildContext context, UpdateInfo info) {
  showAppSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    enableDrag: !info.isForced,
    isDismissible: !info.isForced,
    builder: (_) => _UpdateSheet(info: info),
  );
}

class _UpdateSheet extends StatefulWidget {
  final UpdateInfo info;
  const _UpdateSheet({required this.info});

  @override
  State<_UpdateSheet> createState() => _UpdateSheetState();
}

class _UpdateSheetState extends State<_UpdateSheet> {
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
        // Automatically close bottom sheet on completion
        Navigator.of(context).pop();
        AppToast.showDownload(context, 'Download concluído! Abrindo instalador...');
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
    final screenHeight = MediaQuery.of(context).size.height;

    return PopScope(
      canPop: !widget.info.isForced && !_downloading,
      child: Container(
        constraints: BoxConstraints(maxHeight: screenHeight * 0.85),
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          color: gc.bgRaised,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
          border: Border.all(color: gc.border),
          boxShadow: const [
            BoxShadow(color: Colors.black54, blurRadius: 24, offset: Offset(0, -6)),
          ],
        ),
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Drag handle
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: gc.bgRaised2,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Header Section: Icon + Title + Version Chip
            Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: gc.accentSoft,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: gc.accent.withValues(alpha: 0.3)),
                  ),
                  child: Icon(PhosphorIconsRegular.sparkle, size: 24, color: gc.accent),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'NOVA ATUALIZAÇÃO DISPONÍVEL',
                        style: AppTheme.d(10, weight: FontWeight.w700, color: gc.accent, letterSpacing: 1.8),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'FIT//IRON v${widget.info.version}',
                        style: AppTheme.d(20, weight: FontWeight.w700, color: gc.text),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: gc.accentSoft,
                    borderRadius: BorderRadius.circular(100),
                    border: Border.all(color: gc.accent.withValues(alpha: 0.4)),
                  ),
                  child: Text(
                    'v${widget.info.version}',
                    style: AppTheme.d(12, weight: FontWeight.w700, color: gc.accent),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // Patch Notes Subtitle Label
            Text(
              'O QUE MUDOU NESTA VERSÃO',
              style: AppTheme.d(11, weight: FontWeight.w700, color: gc.textTertiary, letterSpacing: 1.5),
            ),
            const SizedBox(height: 8),

            // Patch Notes Card Container
            Flexible(
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: gc.bgRaised,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: gc.border),
                ),
                child: SingleChildScrollView(
                  child: _buildPatchNotesContent(gc),
                ),
              ),
            ),

            const SizedBox(height: 20),

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
                        style: AppTheme.s(12, weight: FontWeight.w500, color: gc.textSecondary),
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
              const SizedBox(height: 16),
            ],

            // Error display
            if (_error != null) ...[
              Text(
                _error!,
                style: AppTheme.s(12, color: Colors.redAccent),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 14),
            ],

            // Action Buttons
            if (!_downloading)
              Column(
                children: [
                  PrimaryButton(
                    label: 'ATUALIZAR AGORA',
                    onTap: _startDownload,
                  ),
                  if (!widget.info.isForced) ...[
                    const SizedBox(height: 8),
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: Text(
                        'Agora não',
                        style: AppTheme.s(13, weight: FontWeight.w600, color: gc.textSecondary),
                      ),
                    ),
                  ],
                ],
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildPatchNotesContent(GymColors gc) {
    final raw = widget.info.changelog.trim();
    final cleanLines = _parseCleanChangelog(raw);

    if (cleanLines.isEmpty) {
      return _buildDefaultHighlights(gc);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: cleanLines.map((line) => _buildPatchNotesRow(gc, line)).toList(),
    );
  }

  List<String> _parseCleanChangelog(String raw) {
    if (raw.isEmpty) return [];

    final lines = raw.split('\n');
    final result = <String>[];

    for (final line in lines) {
      final trimmed = line.trim();
      if (trimmed.isEmpty) continue;

      // Filter out GitHub automated link junk / commit compare URLs
      final lower = trimmed.toLowerCase();
      if (lower.contains('full changelog') ||
          lower.contains('github.com/') ||
          lower.contains('compare/') ||
          lower.contains('@github-actions')) {
        continue;
      }

      // Clean up markdown formatting symbols (*, -, #)
      var clean = trimmed
          .replaceAll(RegExp(r'\*\*'), '')
          .replaceFirst(RegExp(r'^[-*•#]+\s*'), '')
          .trim();

      if (clean.isNotEmpty) {
        result.add(clean);
      }
    }

    return result;
  }

  Widget _buildDefaultHighlights(GymColors gc) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildPatchNotesRow(gc, 'Melhorias de estabilidade e desempenho do sistema'),
        _buildPatchNotesRow(gc, 'Otimizações no controle de treinos e sincronização'),
        _buildPatchNotesRow(gc, 'Aprimoramentos visuais e na experiência do usuário'),
      ],
    );
  }

  Widget _buildPatchNotesRow(GymColors gc, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
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
              text,
              style: AppTheme.s(13, color: gc.textSecondary, height: 1.4),
            ),
          ),
        ],
      ),
    );
  }
}
