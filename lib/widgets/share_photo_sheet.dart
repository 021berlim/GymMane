import 'dart:convert';
import 'dart:io';
import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:share_plus/share_plus.dart';

import '../state/fit_state.dart';
import '../theme/app_colors.dart';
import '../theme/app_theme.dart';
import 'photo_source_sheet.dart';
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
// State
// ─────────────────────────────────────────────────────────────────────────────

class _SharePhotoSheetState extends State<SharePhotoSheet> {
  final GlobalKey _boundaryKey = GlobalKey();
  final GlobalKey _watermarkKey = GlobalKey();

  File? _photoFile;
  Size? _imageSize; // Real pixel resolution of the photo (width x height)

  // Relative watermark position [0.0 - 1.0] across available canvas space.
  // Default: Bottom-left (dx = 0.05, dy = 0.88), classic Strava positioning.
  Offset _relativePosition = const Offset(0.05, 0.88);
  bool _isDragging = false;

  // Watermark style and scale
  int _styleIndex = 0; // 0 = Full, 1 = Compact, 2 = Minimal
  double _watermarkScale = 1.0;

  bool _isSharing = false;

  // ─── Lifecycle ────────────────────────────────────────────────────────────

  @override
  void initState() {
    super.initState();
    if (widget.initialImagePath != null && widget.initialImagePath!.isNotEmpty) {
      _photoFile = File(widget.initialImagePath!);
      _resolveImageDimensions(_photoFile!);
    } else if (widget.initialImageBase64 != null && widget.initialImageBase64!.isNotEmpty) {
      _loadBase64Image(widget.initialImageBase64!);
    }
  }

  Future<void> _resolveImageDimensions(File file) async {
    try {
      if (await file.exists()) {
        final bytes = await file.readAsBytes();
        final decoded = await decodeImageFromList(bytes);
        if (mounted) {
          setState(() {
            _imageSize = Size(decoded.width.toDouble(), decoded.height.toDouble());
          });
        }
      }
    } catch (_) {}
  }

  Future<void> _loadBase64Image(String rawBase64) async {
    try {
      String cleanStr = rawBase64;
      if (cleanStr.contains(',')) {
        cleanStr = cleanStr.split(',').last;
      }
      cleanStr = cleanStr.replaceAll('\n', '').replaceAll('\r', '').trim();
      final bytes = base64Decode(cleanStr);
      final tempDir = await getTemporaryDirectory();
      final file = File(
        '${tempDir.path}/fitiron_gallery_${DateTime.now().millisecondsSinceEpoch}.png',
      );
      await file.writeAsBytes(bytes, flush: true);
      Size? size;
      try {
        final decoded = await decodeImageFromList(bytes);
        size = Size(decoded.width.toDouble(), decoded.height.toDouble());
      } catch (_) {}

      if (mounted) {
        setState(() {
          _photoFile = file;
          _imageSize = size;
        });
      }
    } catch (_) {}
  }

  Future<void> _pickImage() async {
    final source = await pickPhotoSource(context);
    if (source == null) return;
    try {
      final picked = await ImagePicker().pickImage(
        source: source,
        maxWidth: 2048,
        maxHeight: 2048,
        imageQuality: 92,
      );
      if (picked == null) return;
      final bytes = await picked.readAsBytes();
      final decoded = await decodeImageFromList(bytes);
      final file = File(picked.path);
      if (mounted) {
        setState(() {
          _photoFile = file;
          _imageSize = Size(decoded.width.toDouble(), decoded.height.toDouble());
        });
      }
    } catch (e) {
      debugPrint('Error picking image: $e');
    }
  }

  // ─── Watermark measurement ───────────────────────────────────────────────

  Size _getWatermarkSize() {
    final rb = _watermarkKey.currentContext?.findRenderObject() as RenderBox?;
    if (rb != null && rb.hasSize && rb.size.width > 0 && rb.size.height > 0) {
      return rb.size;
    }
    // Reliable estimates based on style and scale
    switch (_styleIndex) {
      case 2:
        return Size(140 * _watermarkScale, 36 * _watermarkScale);
      case 1:
        return Size(200 * _watermarkScale, 64 * _watermarkScale);
      default:
        return Size(250 * _watermarkScale, 180 * _watermarkScale);
    }
  }

  // ─── Share flow ──────────────────────────────────────────────────────────

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
      // 1. Brief pause to let the UI update and paint
      await Future.delayed(const Duration(milliseconds: 150));

      // 2. Capture the RepaintBoundary
      final boundary = _boundaryKey.currentContext?.findRenderObject()
          as RenderRepaintBoundary?;
      if (boundary == null) {
        throw Exception('Visualização não pronta para captura');
      }

      // Calculate pixelRatio so that exported image matches high resolution (~1080p)
      final canvasBox = _boundaryKey.currentContext?.findRenderObject() as RenderBox?;
      final displayW = canvasBox?.size.width ?? 360;
      final targetW = (_imageSize != null && _imageSize!.width > 0)
          ? _imageSize!.width
          : 1080.0;
      final pixelRatio = (targetW / displayW).clamp(1.5, 3.5);

      final ui.Image image = await boundary.toImage(pixelRatio: pixelRatio);
      final ByteData? byteData =
          await image.toByteData(format: ui.ImageByteFormat.png);
      if (byteData == null) {
        throw Exception('Falha ao processar imagem PNG');
      }

      // 3. Save to temp file
      final pngBytes = byteData.buffer.asUint8List();
      final tempDir = await getTemporaryDirectory();
      final shareFile = File(
        '${tempDir.path}/fitiron_share_${DateTime.now().millisecondsSinceEpoch}.png',
      );
      await shareFile.writeAsBytes(pngBytes, flush: true);

      if (!mounted) return;

      // 4. Calculate origin rect for iPads and share sheet popovers
      final box = context.findRenderObject() as RenderBox?;
      final origin = box != null && box.hasSize
          ? (box.localToGlobal(Offset.zero) & box.size)
          : null;

      final xFile = XFile(shareFile.path, mimeType: 'image/png');

      // Reset sharing state so the button returns to normal right as the system share sheet appears
      if (mounted) setState(() => _isSharing = false);

      await SharePlus.instance.share(
        ShareParams(
          files: [xFile],
          subject: 'FIT//IRON Treino',
          sharePositionOrigin: origin,
        ),
      );

      if (mounted) {
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isSharing = false);
        AppToast.showError(context, 'Erro ao compartilhar foto: $e');
      }
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
                  const SizedBox(height: 10),

                  // Move hint & swap photo button
                  Row(
                    children: [
                      Icon(
                        PhosphorIcons.arrowsOutCardinal(PhosphorIconsStyle.regular),
                        size: 14,
                        color: gc.textTertiary,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        "Arraste a marca d'água na foto",
                        style: AppTheme.s(
                          12,
                          color: gc.textTertiary,
                          weight: FontWeight.w500,
                        ),
                      ),
                      const Spacer(),
                      if (_photoFile != null)
                        GestureDetector(
                          onTap: _pickImage,
                          child: Row(
                            children: [
                              Icon(
                                PhosphorIcons.camera(PhosphorIconsStyle.bold),
                                size: 14,
                                color: gc.accent,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                'Trocar Foto',
                                style: AppTheme.s(
                                  12,
                                  weight: FontWeight.w700,
                                  color: gc.accent,
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
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

                  // Watermark scale slider
                  _sectionLabel(gc, "TAMANHO DA MARCA D'ÁGUA"),
                  const SizedBox(height: 4),
                  _buildScaleSlider(gc),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),

          // ── Bottom share button ─────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 20),
            child: PrimaryButton(
              label: _isSharing ? 'Preparando Imagem...' : 'COMPARTILHAR FOTO',
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

  // ─── Style chip ─────────────────────────────────────────────────────────

  Widget _styleChip(GymColors gc, int index, String label) {
    final isSelected = _styleIndex == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() {
          _styleIndex = index;
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
              inactiveTrackColor: gc.bgRaised2,
              thumbColor: gc.accent,
              overlayColor: gc.accent.withAlpha(50),
              trackHeight: 3,
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 7),
            ),
            child: Slider(
              value: _watermarkScale,
              min: 0.6,
              max: 1.4,
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

  // ─── Empty placeholder ──────────────────────────────────────────────────

  Widget _buildEmptyPlaceholder(GymColors gc) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: _pickImage,
      child: Container(
        color: const Color(0xFF1A1F18),
        alignment: Alignment.center,
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.add_a_photo_outlined,
              size: 48,
              color: gc.accent,
            ),
            const SizedBox(height: 12),
            Text(
              'Selecione ou tire uma foto',
              style: AppTheme.s(
                15,
                weight: FontWeight.w600,
                color: gc.text,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Toque aqui para abrir galeria ou câmera',
              style: AppTheme.s(
                12,
                color: gc.textTertiary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─── Preview canvas ─────────────────────────────────────────────────────

  Widget _buildPreviewCanvas(GymColors gc) {
    // If the image resolution is known, match its EXACT aspect ratio!
    final double photoAspectRatio = (_imageSize != null && _imageSize!.height > 0)
        ? (_imageSize!.width / _imageSize!.height)
        : (4 / 5);

    final screenH = MediaQuery.of(context).size.height;
    final maxCanvasH = screenH * 0.44;

    return ConstrainedBox(
      constraints: BoxConstraints(maxHeight: maxCanvasH),
      child: AspectRatio(
        aspectRatio: photoAspectRatio,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Container(
            decoration: BoxDecoration(
              color: const Color(0xFF141712),
              border: Border.all(color: gc.border),
              borderRadius: BorderRadius.circular(20),
            ),
            child: _photoFile == null
                ? _buildEmptyPlaceholder(gc)
                : RepaintBoundary(
                    key: _boundaryKey,
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        final canvasW = constraints.maxWidth;
                        final canvasH = constraints.maxHeight;

                        final wmSize = _getWatermarkSize();
                        // 8px margin from edges
                        const margin = 8.0;
                        final maxAvailableW = math.max(0.0, canvasW - wmSize.width - (margin * 2));
                        final maxAvailableH = math.max(0.0, canvasH - wmSize.height - (margin * 2));

                        final posX = margin + (_relativePosition.dx * maxAvailableW).clamp(0.0, maxAvailableW);
                        final posY = margin + (_relativePosition.dy * maxAvailableH).clamp(0.0, maxAvailableH);

                        return Stack(
                          children: [
                            // Full-bleed photo matching exact aspect ratio without cropping
                            Positioned.fill(
                              child: Image.file(
                                _photoFile!,
                                fit: BoxFit.cover,
                              ),
                            ),

                            // Draggable watermark sticker
                            Positioned(
                              left: posX,
                              top: posY,
                              child: _buildDraggableWatermark(
                                gc,
                                canvasW,
                                canvasH,
                                maxAvailableW,
                                maxAvailableH,
                                margin,
                              ),
                            ),
                          ],
                        );
                      },
                    ),
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
    double maxAvailableW,
    double maxAvailableH,
    double margin,
  ) {
    final card = KeyedSubtree(
      key: _watermarkKey,
      child: _buildWatermarkCard(gc),
    );

    // Apply scale via FittedBox with responsive max-width
    final maxWatermarkW = canvasW * 0.88;
    final baseW = (_styleIndex == 2
            ? 140.0
            : _styleIndex == 1
                ? 200.0
                : 250.0) *
        _watermarkScale;
    final clampedW = math.min(baseW, maxWatermarkW);

    final scaledWidget = SizedBox(
      width: clampedW,
      child: FittedBox(
        fit: BoxFit.scaleDown,
        alignment: Alignment.topLeft,
        child: card,
      ),
    );

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onPanStart: (_) {
        HapticFeedback.selectionClick();
        setState(() => _isDragging = true);
      },
      onPanUpdate: (details) {
        if (maxAvailableW <= 0 && maxAvailableH <= 0) return;

        setState(() {
          final currentPxX = _relativePosition.dx * maxAvailableW;
          final currentPxY = _relativePosition.dy * maxAvailableH;

          final newPxX = (currentPxX + details.delta.dx).clamp(0.0, maxAvailableW);
          final newPxY = (currentPxY + details.delta.dy).clamp(0.0, maxAvailableH);

          _relativePosition = Offset(
            maxAvailableW > 0 ? (newPxX / maxAvailableW) : 0.0,
            maxAvailableH > 0 ? (newPxY / maxAvailableH) : 0.0,
          );
        });
      },
      onPanEnd: (_) => setState(() => _isDragging = false),
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 120),
        opacity: _isDragging ? 0.75 : 1.0,
        child: scaledWidget,
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
