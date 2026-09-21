import 'dart:convert';
import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:share_plus/share_plus.dart';

import '../state/fit_state.dart';
import '../theme/app_colors.dart';
import '../theme/app_theme.dart';
import 'ui_kit.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Public API — unchanged signature for callers
// ─────────────────────────────────────────────────────────────────────────────

/// Opens the interactive watermark photo editor and sharing modal.
void showSharePhotoSheet(
  BuildContext context, {
  required String durationStr,
  required int prCount,
  required double volumeKg,
  required int calories,
  required String muscleGroupsStr,
  String? initialImagePath,
  String? initialImageBase64,
}) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => SharePhotoSheet(
      durationStr: durationStr,
      prCount: prCount,
      volumeKg: volumeKg,
      calories: calories,
      muscleGroupsStr: muscleGroupsStr,
      initialImagePath: initialImagePath,
      initialImageBase64: initialImageBase64,
    ),
  );
}

// ─────────────────────────────────────────────────────────────────────────────
// Widget
// ─────────────────────────────────────────────────────────────────────────────

class SharePhotoSheet extends StatefulWidget {
  final String durationStr;
  final int prCount;
  final double volumeKg;
  final int calories;
  final String muscleGroupsStr;
  final String? initialImagePath;
  final String? initialImageBase64;

  const SharePhotoSheet({
    super.key,
    required this.durationStr,
    required this.prCount,
    required this.volumeKg,
    required this.calories,
    required this.muscleGroupsStr,
    this.initialImagePath,
    this.initialImageBase64,
  });

  @override
  State<SharePhotoSheet> createState() => _SharePhotoSheetState();
}

// ─────────────────────────────────────────────────────────────────────────────
// Preset positions for quick-pick chips
// ─────────────────────────────────────────────────────────────────────────────

enum _PresetPosition {
  topLeft('Top-Left', Alignment.topLeft),
  topRight('Top-Right', Alignment.topRight),
  center('Center', Alignment.center),
  bottomLeft('Bottom-Left', Alignment.bottomLeft),
  bottomRight('Bottom-Right', Alignment.bottomRight);

  final String label;
  final Alignment alignment;
  const _PresetPosition(this.label, this.alignment);
}

// ─────────────────────────────────────────────────────────────────────────────
// Aspect ratio presets
// ─────────────────────────────────────────────────────────────────────────────

enum _AspectPreset {
  ratio1x1('1:1', 1.0),
  ratio4x5('4:5', 4 / 5),
  ratio9x16('9:16', 9 / 16);

  final String label;
  final double value;
  const _AspectPreset(this.label, this.value);
}

// ─────────────────────────────────────────────────────────────────────────────
// State
// ─────────────────────────────────────────────────────────────────────────────

class _SharePhotoSheetState extends State<SharePhotoSheet> {
  // Keys for capture & measurement
  final GlobalKey _boundaryKey = GlobalKey();
  final GlobalKey _watermarkKey = GlobalKey();

  // Photo source
  File? _photoFile;

  // Watermark positioning
  Alignment _alignment = Alignment.bottomLeft;
  Offset? _customOffset;
  bool _useCustomOffset = false;
  bool _isDragging = false;

  // Style / scale
  int _styleIndex = 0; // 0 = Full, 1 = Compact, 2 = Minimal
  double _watermarkScale = 1.0;

  // Aspect ratio
  _AspectPreset _aspect = _AspectPreset.ratio4x5;

  // Share state
  bool _isSharing = false;

  // ─── Lifecycle ────────────────────────────────────────────────────────────

  @override
  void initState() {
    super.initState();
    if (widget.initialImagePath != null) {
      _photoFile = File(widget.initialImagePath!);
    }
    if (widget.initialImageBase64 != null &&
        widget.initialImageBase64!.isNotEmpty) {
      _loadBase64Image(widget.initialImageBase64!);
    }
  }

  Future<void> _loadBase64Image(String base64Str) async {
    try {
      final bytes = base64Decode(base64Str);
      final tempDir = await getTemporaryDirectory();
      final file = File(
        '${tempDir.path}/fitiron_gallery_${DateTime.now().millisecondsSinceEpoch}.png',
      );
      await file.writeAsBytes(bytes, flush: true);
      if (mounted) setState(() => _photoFile = file);
    } catch (_) {}
  }

  // ─── Watermark measurement ───────────────────────────────────────────────
  // Reads the actual rendered size of the watermark widget via its RenderBox.
  // Falls back to style-based estimates if the box hasn't laid out yet.

  Size _getWatermarkSize() {
    final rb =
        _watermarkKey.currentContext?.findRenderObject() as RenderBox?;
    if (rb != null && rb.hasSize) return rb.size;
    // Fallback estimates per style * scale
    switch (_styleIndex) {
      case 1:
        return Size(200 * _watermarkScale, 64 * _watermarkScale);
      case 2:
        return Size(140 * _watermarkScale, 36 * _watermarkScale);
      default:
        return Size(250 * _watermarkScale, 180 * _watermarkScale);
    }
  }

  /// Converts an Alignment preset to an absolute Offset inside the canvas,
  /// using the real watermark size and a 16 px margin from edges.
  Offset _getOffsetFromAlignment(double canvasW, double canvasH) {
    const margin = 16.0;
    final wm = _getWatermarkSize();
    final align = _alignment;
    double x = margin;
    double y = margin;

    if (align == Alignment.topRight || align == Alignment.bottomRight) {
      x = canvasW - wm.width - margin;
    } else if (align == Alignment.center) {
      x = (canvasW - wm.width) / 2;
    }

    if (align == Alignment.bottomLeft || align == Alignment.bottomRight) {
      y = canvasH - wm.height - margin;
    } else if (align == Alignment.center) {
      y = (canvasH - wm.height) / 2;
    }

    return Offset(
      x.clamp(0, canvasW - wm.width),
      y.clamp(0, canvasH - wm.height),
    );
  }

  // ─── Share flow ──────────────────────────────────────────────────────────
  //
  // CRITICAL FIX: Share FIRST, pop the sheet AFTER.
  // The previous code called Navigator.pop() before SharePlus.share(),
  // which destroyed the widget tree and invalidated the context, causing
  // the Android share sheet to silently fail on most devices.

  Future<void> _shareImage() async {
    if (_photoFile == null) {
      AppToast.showError(
        context,
        'Por favor, selecione ou tire uma foto primeiro.',
      );
      return;
    }

    setState(() => _isSharing = true);

    try {
      // 1. Let the render pipeline settle
      await Future.delayed(const Duration(milliseconds: 200));
      await WidgetsBinding.instance.endOfFrame;

      // 2. Capture the RepaintBoundary
      final boundary = _boundaryKey.currentContext?.findRenderObject()
          as RenderRepaintBoundary?;
      if (boundary == null) throw Exception('Boundary rendering failed');

      if (boundary.debugNeedsPaint) {
        await Future.delayed(const Duration(milliseconds: 200));
      }

      final image = await boundary.toImage(pixelRatio: 3.0);
      final byteData =
          await image.toByteData(format: ui.ImageByteFormat.png);
      if (byteData == null) throw Exception('PNG byte encoding failed');

      // 3. Save to temp file
      final pngBytes = byteData.buffer.asUint8List();
      final tempDir = await getTemporaryDirectory();
      final file = File(
        '${tempDir.path}/fitiron_workout_share_${DateTime.now().millisecondsSinceEpoch}.png',
      );
      await file.writeAsBytes(pngBytes, flush: true);

      if (!mounted) return;

      // 4. Share FIRST — keep the sheet alive so the Activity context is valid
      await SharePlus.instance.share(
        ShareParams(
          files: [XFile(file.path)],
          subject: 'FIT//IRON Workout',
        ),
      );

      // 5. Only AFTER share returns, close the sheet
      if (mounted) Navigator.of(context).pop();
    } catch (e) {
      if (mounted) {
        AppToast.showError(context, 'Erro ao compartilhar foto: $e');
      }
    } finally {
      if (mounted) setState(() => _isSharing = false);
    }
  }

  // ─── Build ───────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final gc = context.gc;
    final screenHeight = MediaQuery.of(context).size.height;

    return Container(
      height: screenHeight * 0.92,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: gc.bgRaised,
        border: Border.all(color: gc.border),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        children: [
          // ── Header ──────────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: Column(
              children: [
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: gc.bgRaised2,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'COMPARTILHAR FOTO',
                      style: AppTheme.d(
                        16,
                        weight: FontWeight.w700,
                        color: gc.text,
                        letterSpacing: 2,
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.close, color: gc.textSecondary),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // ── Scrollable controls ─────────────────────────────────────────
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                children: [
                  // Photo preview + draggable watermark
                  _buildPreviewCanvas(gc),
                  const SizedBox(height: 16),

                  // Aspect ratio selector
                  _sectionLabel(gc, 'PROPORÇÃO DA IMAGEM'),
                  const SizedBox(height: 8),
                  _buildAspectRatioBar(gc),
                  const SizedBox(height: 16),

                  // Preset position chips
                  _sectionLabel(gc, 'POSICIONAMENTO (Arraste ou selecione)'),
                  const SizedBox(height: 8),
                  _buildPositionBar(gc),
                  const SizedBox(height: 16),

                  // Watermark style selector
                  _sectionLabel(gc, "ESTILO DA MARCA D'ÁGUA"),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      _styleChip(gc, 0, 'Completo'),
                      const SizedBox(width: 8),
                      _styleChip(gc, 1, 'Compacto'),
                      const SizedBox(width: 8),
                      _styleChip(gc, 2, 'Mínimo'),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Watermark size slider
                  _sectionLabel(gc, "TAMANHO DA MARCA D'ÁGUA"),
                  const SizedBox(height: 8),
                  _buildScaleSlider(gc),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),

          // ── Bottom share button ─────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 20),
            child: PrimaryButton(
              label:
                  _isSharing ? 'Preparando Imagem...' : 'COMPARTILHAR FOTO',
              onTap: _isSharing ? () {} : _shareImage,
            ),
          ),
        ],
      ),
    );
  }

  // ─── Section label helper ────────────────────────────────────────────────

  Widget _sectionLabel(GymColors gc, String text) => Align(
        alignment: Alignment.centerLeft,
        child: Text(
          text,
          style: AppTheme.d(
            10,
            weight: FontWeight.w700,
            color: gc.textTertiary,
            letterSpacing: 1.5,
          ),
        ),
      );

  // ─── Aspect ratio bar ───────────────────────────────────────────────────

  Widget _buildAspectRatioBar(GymColors gc) {
    return Row(
      children: _AspectPreset.values.map((ar) {
        final isSel = _aspect == ar;
        return Expanded(
          child: Padding(
            padding: EdgeInsets.only(
              right: ar != _AspectPreset.values.last ? 8 : 0,
            ),
            child: GestureDetector(
              onTap: () => setState(() => _aspect = ar),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: isSel ? gc.accentSoft : gc.bgRaised,
                  borderRadius: BorderRadius.circular(12),
                  border:
                      Border.all(color: isSel ? gc.accent : gc.border),
                ),
                alignment: Alignment.center,
                child: Text(
                  ar.label,
                  style: AppTheme.s(
                    12,
                    weight: isSel ? FontWeight.w700 : FontWeight.w500,
                    color: isSel ? gc.accent : gc.textSecondary,
                  ),
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  // ─── Position preset bar ────────────────────────────────────────────────

  Widget _buildPositionBar(GymColors gc) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: _PresetPosition.values.map((pos) {
          final isSelected =
              !_useCustomOffset && _alignment == pos.alignment;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ChoiceChip(
              label: Text(pos.label),
              selected: isSelected,
              onSelected: (_) {
                setState(() {
                  _useCustomOffset = false;
                  _customOffset = null;
                  _alignment = pos.alignment;
                });
              },
              selectedColor: gc.accentSoft,
              labelStyle: AppTheme.s(
                12,
                weight: isSelected ? FontWeight.w700 : FontWeight.w500,
                color: isSelected ? gc.accent : gc.textSecondary,
              ),
              backgroundColor: gc.bgRaised,
              side: BorderSide(
                color: isSelected ? gc.accent : gc.border,
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  // ─── Style chip ─────────────────────────────────────────────────────────

  Widget _styleChip(GymColors gc, int index, String label) {
    final isSelected = _styleIndex == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() {
          _styleIndex = index;
          // Reset custom offset so preset recalculates with new size
          if (!_useCustomOffset) _customOffset = null;
        }),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isSelected ? gc.accentSoft : gc.bgRaised,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected ? gc.accent : gc.border,
            ),
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: AppTheme.s(
              12,
              weight: isSelected ? FontWeight.w700 : FontWeight.w500,
              color: isSelected ? gc.accent : gc.textSecondary,
            ),
          ),
        ),
      ),
    );
  }

  // ─── Scale slider ──────────────────────────────────────────────────────

  Widget _buildScaleSlider(GymColors gc) {
    return Row(
      children: [
        Icon(
          PhosphorIcons.textAa(PhosphorIconsStyle.bold),
          size: 16,
          color: gc.textTertiary,
        ),
        Expanded(
          child: SliderTheme(
            data: SliderThemeData(
              activeTrackColor: gc.accent,
              inactiveTrackColor: gc.border,
              thumbColor: gc.accent,
              overlayColor: gc.accent.withValues(alpha: 0.2),
              trackHeight: 3,
              thumbShape:
                  const RoundSliderThumbShape(enabledThumbRadius: 7),
            ),
            child: Slider(
              value: _watermarkScale,
              min: 0.5,
              max: 1.5,
              onChanged: (v) => setState(() => _watermarkScale = v),
            ),
          ),
        ),
        Icon(
          PhosphorIcons.textAa(PhosphorIconsStyle.fill),
          size: 22,
          color: gc.textSecondary,
        ),
      ],
    );
  }

  // ─── Preview canvas ─────────────────────────────────────────────────────

  Widget _buildPreviewCanvas(GymColors gc) {
    return AspectRatio(
      aspectRatio: _aspect.value,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Container(
          decoration: BoxDecoration(
            color: const Color(0xFF141712),
            border: Border.all(color: gc.border),
            borderRadius: BorderRadius.circular(20),
          ),
          child: RepaintBoundary(
            key: _boundaryKey,
            child: LayoutBuilder(
              builder: (context, constraints) {
                final canvasW = constraints.maxWidth;
                final canvasH = constraints.maxHeight;

                return Stack(
                  children: [
                    // Photo background or placeholder
                    Positioned.fill(
                      child: _photoFile != null
                          ? Image.file(_photoFile!, fit: BoxFit.cover)
                          : Container(
                              color: const Color(0xFF1A1F18),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.camera_alt,
                                    size: 48,
                                    color: gc.textTertiary,
                                  ),
                                  const SizedBox(height: 12),
                                  Text(
                                    'Selecione ou tire uma foto',
                                    style: AppTheme.s(
                                      14,
                                      color: gc.textSecondary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                    ),

                    // Draggable watermark — always Positioned with absolute coords
                    Positioned(
                      left: _useCustomOffset && _customOffset != null
                          ? _customOffset!.dx
                          : _getOffsetFromAlignment(canvasW, canvasH).dx,
                      top: _useCustomOffset && _customOffset != null
                          ? _customOffset!.dy
                          : _getOffsetFromAlignment(canvasW, canvasH).dy,
                      child: _buildDraggableWatermark(
                        gc,
                        canvasW,
                        canvasH,
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  // ─── Draggable watermark wrapper ────────────────────────────────────────

  Widget _buildDraggableWatermark(
    GymColors gc,
    double canvasW,
    double canvasH,
  ) {
    final card = KeyedSubtree(
      key: _watermarkKey,
      child: _buildWatermarkCard(gc),
    );

    // Apply scale via FittedBox
    final scaledCard = _watermarkScale == 1.0
        ? card
        : SizedBox(
            width: (_styleIndex == 2
                    ? 140.0
                    : _styleIndex == 1
                        ? 200.0
                        : 250.0) *
                _watermarkScale,
            child: FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.topLeft,
              child: card,
            ),
          );

    return GestureDetector(
      onPanStart: (_) {
        HapticFeedback.selectionClick();
        setState(() => _isDragging = true);
      },
      onPanUpdate: (details) {
        setState(() {
          final current = _customOffset ??
              _getOffsetFromAlignment(canvasW, canvasH);
          final wmSize = _getWatermarkSize();

          // FIXED: Clamp to [0, canvasW-wmW] × [0, canvasH-wmH]
          // so the sticker can reach ALL edges but never overflow.
          final newDx = (current.dx + details.delta.dx)
              .clamp(0.0, (canvasW - wmSize.width).clamp(0.0, canvasW));
          final newDy = (current.dy + details.delta.dy)
              .clamp(0.0, (canvasH - wmSize.height).clamp(0.0, canvasH));

          _useCustomOffset = true;
          _customOffset = Offset(newDx, newDy);
        });
      },
      onPanEnd: (_) => setState(() => _isDragging = false),
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 120),
        opacity: _isDragging ? 0.7 : 1.0,
        child: scaledCard,
      ),
    );
  }

  // ─── Watermark card variants ────────────────────────────────────────────

  Widget _buildWatermarkCard(GymColors gc) {
    switch (_styleIndex) {
      case 2:
        return _buildMinimalBadge();
      case 1:
        return _buildCompactCard(gc);
      default:
        return _buildFullStatsCard(gc);
    }
  }

  /// Style 2: Minimal logo badge — fully transparent, Strava-style
  Widget _buildMinimalBadge() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 22,
            height: 22,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(6),
              boxShadow: const [BoxShadow(color: Color(0x66000000), blurRadius: 6)],
              image: const DecorationImage(
                image: AssetImage('assets/icon/ic_1024.png'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            'FIT//IRON',
            style: AppTheme.d(
              13,
              weight: FontWeight.w700,
              color: Colors.white,
              letterSpacing: 2,
            ),
          ),
        ],
      ),
    );
  }

  /// Style 1: Compact card — fully transparent, Strava-style
  Widget _buildCompactCard(GymColors gc) {
    return Padding(
      padding: const EdgeInsets.all(4),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(6),
                  boxShadow: const [BoxShadow(color: Color(0x66000000), blurRadius: 6)],
                  image: const DecorationImage(
                    image: AssetImage('assets/icon/ic_1024.png'),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                'FIT//IRON',
                style: AppTheme.d(
                  14,
                  weight: FontWeight.w700,
                  color: const Color(0xFFA3E635),
                  letterSpacing: 2,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            '${widget.durationStr} · ${fit.volumeLabel(widget.volumeKg)}',
            style: AppTheme.d(
              14,
              weight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  /// Style 0: Full Stats Card with all metrics — fully transparent, Strava-style
  Widget _buildFullStatsCard(GymColors gc) {
    return SizedBox(
      width: 250,
      child: Padding(
        padding: const EdgeInsets.all(4),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // FIT//IRON header
            Row(
              children: [
                Container(
                  width: 26,
                  height: 26,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(7),
                    boxShadow: const [BoxShadow(color: Color(0x66000000), blurRadius: 6)],
                    image: const DecorationImage(
                      image: AssetImage('assets/icon/ic_1024.png'),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  'FIT//IRON',
                  style: AppTheme.d(
                    16,
                    weight: FontWeight.w700,
                    color: const Color(0xFFA3E635),
                    letterSpacing: 2.5,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),

            // Row 1: Tempo & Recordes
            Row(
              children: [
                Expanded(
                  child: _buildMetricItem('Tempo', widget.durationStr),
                ),
                Expanded(
                  child: _buildMetricItemWithIcon(
                    'Recordes',
                    '${widget.prCount}',
                    PhosphorIcons.trophy(PhosphorIconsStyle.fill),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Row 2: Calorias & Peso total
            Row(
              children: [
                Expanded(
                  child: _buildMetricItem(
                    'Calorias',
                    '${widget.calories} KCAL',
                  ),
                ),
                Expanded(
                  child: _buildMetricItem(
                    'Peso total',
                    fit.volumeLabel(widget.volumeKg),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ─── Metric helpers ─────────────────────────────────────────────────────

  Widget _buildMetricItem(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTheme.s(
            11,
            weight: FontWeight.w500,
            color: const Color(0x99FFFFFF),
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: AppTheme.d(16, weight: FontWeight.w700, color: Colors.white),
        ),
      ],
    );
  }

  Widget _buildMetricItemWithIcon(
    String label,
    String value,
    IconData icon,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTheme.s(
            11,
            weight: FontWeight.w500,
            color: const Color(0x99FFFFFF),
          ),
        ),
        const SizedBox(height: 2),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              value,
              style: AppTheme.d(
                16,
                weight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
            const SizedBox(width: 4),
            Icon(icon, size: 16, color: const Color(0xFFA3E635)),
          ],
        ),
      ],
    );
  }
}
