import 'dart:convert';
import 'dart:io';
import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:share_plus/share_plus.dart';

import '../l10n/l10n.dart';
import '../models/live_session.dart';
import '../models/workout.dart';
import '../services/gallery.dart';
import '../state/fit_state.dart';
import '../theme/app_colors.dart';
import '../theme/app_theme.dart';
import 'fade_slide_route.dart';
import 'glass.dart';
import 'ui_kit.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Public API — unchanged signatures for callers (session_screen & gallery_screen)
// ─────────────────────────────────────────────────────────────────────────────

/// Opens the interactive sticker photo editor and sharing modal with glass blur backdrop.
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
  showAppSheet(
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

/// Opens the interactive sticker photo editor using the full-screen Fade+Slide transition adapted from GymMane.
Future<void> showSharePhotoScreen(
  BuildContext context, {
  required String durationStr,
  required int prCount,
  required double volumeKg,
  required int calories,
  required String muscleGroupsStr,
  String? initialImagePath,
  String? initialImageBase64,
}) {
  return pushFadeSlideRoute(
    context,
    (_) => Scaffold(
      backgroundColor: Colors.transparent,
      body: SharePhotoSheet(
        durationStr: durationStr,
        prCount: prCount,
        volumeKg: volumeKg,
        calories: calories,
        muscleGroupsStr: muscleGroupsStr,
        initialImagePath: initialImagePath,
        initialImageBase64: initialImageBase64,
      ),
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
  static const _base = 360.0;

  final GlobalKey _canvas = GlobalKey();
  File? _photo;
  Size? _photoSize;
  bool _streak = false;
  bool _date = true;
  int _layout = 0;
  int _swatch = 0;
  Offset _pos = const Offset(0.5, 0.68);
  double _scale = 1.0;
  double _turn = 0.0;
  double _startScale = 1.0;
  double _startTurn = 0.0;
  bool _busy = false;

  List<Color> _swatches(GymColors gc) => [
        Colors.white,
        const Color(0xFF111111),
        gc.accent,
        gc.brass,
        gc.sage,
        const Color(0xFFE8E1D7),
      ];

  // ─── Lifecycle ────────────────────────────────────────────────────────────

  @override
  void initState() {
    super.initState();
    if (widget.initialImagePath != null && widget.initialImagePath!.isNotEmpty) {
      _photo = File(widget.initialImagePath!);
      _resolveDimensions(_photo!);
    } else if (widget.initialImageBase64 != null && widget.initialImageBase64!.isNotEmpty) {
      _loadBase64Image(widget.initialImageBase64!);
    }
  }

  Future<void> _resolveDimensions(File file) async {
    try {
      if (await file.exists()) {
        final bytes = await file.readAsBytes();
        final decoded = await decodeImageFromList(bytes);
        if (mounted) {
          setState(() {
            _photoSize = Size(decoded.width.toDouble(), decoded.height.toDouble());
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
      Directory tempDir;
      try {
        tempDir = await getTemporaryDirectory();
      } catch (_) {
        tempDir = Directory.systemTemp;
      }
      final file = File(
        '${tempDir.path}/fitiron_gallery_${DateTime.now().millisecondsSinceEpoch}.png',
      );
      await file.writeAsBytes(bytes, flush: true);
      final decoded = await decodeImageFromList(bytes);

      if (mounted) {
        setState(() {
          _photo = file;
          _photoSize = Size(decoded.width.toDouble(), decoded.height.toDouble());
        });
      }
    } catch (_) {}
  }

  Future<void> _pick(ImageSource source) async {
    try {
      // Pick image with 100% native sensor resolution (no downscaling or lossy compression)
      final shot = await ImagePicker().pickImage(
        source: source,
        imageQuality: 100,
      );
      if (shot == null || !mounted) return;
      final file = File(shot.path);
      await _resolveDimensions(file);
      if (mounted) {
        setState(() => _photo = file);
      }
    } catch (_) {}
  }

  // ─── Render & Capture ─────────────────────────────────────────────────────

  Future<Uint8List?> _render() async {
    final boundary = _canvas.currentContext?.findRenderObject() as RenderRepaintBoundary?;
    if (boundary == null) return null;

    final boundaryW = boundary.size.width;
    final boundaryH = boundary.size.height;
    if (boundaryW <= 0 || boundaryH <= 0) return null;

    if (_photo != null && (_photoSize == null || _photoSize!.width <= 0)) {
      await _resolveDimensions(_photo!);
    }

    // Determine target resolution:
    // If a photo is loaded, composite at the photo's exact native camera resolution!
    double targetW;
    double targetH;

    if (_photo != null && _photoSize != null && _photoSize!.width > 0 && _photoSize!.height > 0) {
      targetW = _photoSize!.width;
      targetH = _photoSize!.height;
    } else {
      // For standalone sticker export, use 4K Ultra-HD (2160 x 3840)
      targetW = 2160.0;
      targetH = 3840.0;
    }

    double pixelRatio = math.max(targetW / boundaryW, targetH / boundaryH);

    // Safeguard against hardware texture allocation limits (4096 px is universally safe on all mobile GPUs)
    final maxDim = math.max(boundaryW * pixelRatio, boundaryH * pixelRatio);
    if (maxDim > 4096.0) {
      pixelRatio = 4096.0 / math.max(boundaryW, boundaryH);
    }
    pixelRatio = math.max(pixelRatio, 1080.0 / boundaryW);

    final image = await boundary.toImage(pixelRatio: pixelRatio);
    final data = await image.toByteData(format: ui.ImageByteFormat.png);
    image.dispose();
    return data?.buffer.asUint8List();
  }

  Future<void> _run(Future<void> Function(Uint8List png) job) async {
    if (_busy) return;
    setState(() => _busy = true);
    try {
      final png = await _render();
      if (png == null) throw StateError('render');
      await job(png);
    } catch (_) {
      if (mounted) {
        AppToast.showError(context, 'Falha ao gerar imagem');
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _share() async {
    final box = context.findRenderObject() as RenderBox?;
    final origin = box != null && box.hasSize
        ? (box.localToGlobal(Offset.zero) & box.size)
        : null;

    await _run((png) async {
      final dir = await getTemporaryDirectory();
      final file = File('${dir.path}/fitiron-sticker.png');
      await file.writeAsBytes(png, flush: true);
      await SharePlus.instance.share(
        ShareParams(
          files: [XFile(file.path, mimeType: 'image/png')],
          subject: 'FIT//IRON',
          sharePositionOrigin: origin,
        ),
      );
    });
  }

  Future<void> _save() => _run((png) async {
        final ok = await saveImageToGallery(
          png,
          'fitiron-${DateTime.now().millisecondsSinceEpoch}.png',
        );
        if (!ok) throw StateError('save');
        HapticFeedback.lightImpact();
        if (mounted) {
          AppToast.showSuccess(context, 'Salvo na galeria');
        }
      });

  // ─── Build ───────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final gc = context.gc;
    final color = _swatches(gc)[_swatch];
    final screenHeight = MediaQuery.of(context).size.height;
    final double photoAspectRatio = (_photo != null && _photoSize != null && _photoSize!.height > 0)
        ? (_photoSize!.width / _photoSize!.height)
        : (9 / 16);

    return Container(
      height: screenHeight * 0.94,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: gc.bg,
        border: Border.all(color: gc.border.withValues(alpha: 0.5)),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          children: [
            // ── Top Bar ───────────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 6),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 36,
                    height: 4,
                    decoration: BoxDecoration(
                      color: gc.bgRaised2,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      _RoundAction(
                        label: MaterialLocalizations.of(context).closeButtonLabel,
                        onTap: () => Navigator.of(context).pop(),
                        child: Icon(
                          PhosphorIcons.x(PhosphorIconsStyle.regular),
                          size: 18,
                          color: gc.text,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'COMPARTILHAR FOTO',
                              style: AppTheme.d(
                                14,
                                weight: FontWeight.w700,
                                color: gc.text,
                                letterSpacing: 2,
                              ),
                            ),
                            Text(
                              'Arraste para mover · Pinça para escala e giro',
                              style: AppTheme.s(
                                11,
                                color: gc.textTertiary,
                                weight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // ── Canvas Stage ──────────────────────────────────────────────
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 4, 20, 8),
                child: Center(
                  child: AspectRatio(
                    aspectRatio: photoAspectRatio,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(22),
                      child: LayoutBuilder(
                        builder: (context, c) => _stage(gc, c.biggest, color),
                      ),
                    ),
                  ),
                ),
              ),
            ),

            // ── Bottom Controls ───────────────────────────────────────────
            _controls(gc),
          ],
        ),
      ),
    );
  }

  // ─── Stage ────────────────────────────────────────────────────────────────

  Widget _stage(GymColors gc, Size size, Color color) {
    final unit = size.width / _base;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onScaleStart: (_) {
        _startScale = _scale;
        _startTurn = _turn;
      },
      onScaleUpdate: (d) => setState(() {
        _pos = Offset(
          (_pos.dx + d.focalPointDelta.dx / size.width).clamp(0.0, 1.0),
          (_pos.dy + d.focalPointDelta.dy / size.height).clamp(0.0, 1.0),
        );
        if (d.pointerCount > 1) {
          _scale = (_startScale * d.scale).clamp(0.45, 2.6);
          _turn = _startTurn + d.rotation;
        }
      }),
      onDoubleTap: () => setState(() => _turn = 0),
      child: Stack(
        fit: StackFit.expand,
        children: [
          if (_photo == null) CustomPaint(painter: _Checker(gc.bgRaised, gc.bgRaised2)),
          RepaintBoundary(
            key: _canvas,
            child: Stack(
              fit: StackFit.expand,
              children: [
                if (_photo != null)
                  Image.file(
                    _photo!,
                    fit: BoxFit.cover,
                    filterQuality: FilterQuality.high,
                  ),
                Positioned(
                  left: _pos.dx * size.width,
                  top: _pos.dy * size.height,
                  child: FractionalTranslation(
                    translation: const Offset(-0.5, -0.5),
                    child: Transform.rotate(
                      angle: _turn,
                      child: Transform.scale(
                        scale: _scale * unit,
                        child: _Sticker(
                          durationStr: widget.durationStr,
                          volumeKg: widget.volumeKg,
                          prCount: widget.prCount,
                          calories: widget.calories,
                          muscleGroupsStr: widget.muscleGroupsStr,
                          streak: _streak,
                          layout: _layout,
                          showDate: _date,
                          color: color,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ─── Controls ─────────────────────────────────────────────────────────────

  Widget _controls(GymColors gc) {
    final swatches = _swatches(gc);
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      decoration: BoxDecoration(
        color: gc.bgRaised,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(26)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 3 chips: Galeria, Câmera, Sem foto
          Row(children: [
            _chip(
              gc,
              PhosphorIcons.image(PhosphorIconsStyle.regular),
              'Galeria',
              false,
              () => _pick(ImageSource.gallery),
            ),
            const SizedBox(width: 8),
            _chip(
              gc,
              PhosphorIcons.camera(PhosphorIconsStyle.regular),
              'Câmera',
              false,
              () => _pick(ImageSource.camera),
            ),
            const SizedBox(width: 8),
            _chip(
              gc,
              PhosphorIcons.checkerboard(PhosphorIconsStyle.regular),
              'Sem foto',
              _photo == null,
              () => setState(() {
                _photo = null;
                _photoSize = null;
              }),
            ),
          ]),
          const SizedBox(height: 10),

          // Segmented toggle: Treino vs Sequência + Pill Data
          Row(children: [
            SegToggle([
              SegOption('Treino', !_streak, () => setState(() => _streak = false)),
              SegOption('Sequência', _streak, () => setState(() => _streak = true)),
            ]),
            const Spacer(),
            Pill(
              label: 'Data',
              bg: _date ? gc.accentSoft : gc.bgRaised2,
              fg: _date ? gc.text : gc.textTertiary,
              fontSize: 12,
              onTap: () => setState(() => _date = !_date),
            ),
          ]),
          const SizedBox(height: 10),

          // 6 layout icons
          Row(children: [
            for (final (i, icon) in [
              PhosphorIcons.rows(PhosphorIconsStyle.regular),
              PhosphorIcons.columns(PhosphorIconsStyle.regular),
              PhosphorIcons.textAa(PhosphorIconsStyle.regular),
              PhosphorIcons.squaresFour(PhosphorIconsStyle.regular),
              PhosphorIcons.listBullets(PhosphorIconsStyle.regular),
              PhosphorIcons.equals(PhosphorIconsStyle.regular),
            ].indexed) ...[
              if (i > 0) const SizedBox(width: 6),
              Expanded(
                child: _iconToggle(
                  gc,
                  icon,
                  _layout == i,
                  () => setState(() => _layout = i),
                ),
              ),
            ],
          ]),
          const SizedBox(height: 10),

          // 6 color swatches
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              for (final (i, c) in swatches.indexed)
                _Pressable(
                  onTap: () => setState(() => _swatch = i),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    width: 32,
                    height: 32,
                    padding: const EdgeInsets.all(3),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: i == _swatch ? gc.text : Colors.transparent,
                        width: 2,
                      ),
                    ),
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        color: c,
                        shape: BoxShape.circle,
                        border: Border.all(color: gc.border),
                      ),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),

          // Save + Share action buttons
          Row(children: [
            Expanded(
              child: PrimaryButton(
                label: t.save,
                height: 48,
                bg: gc.bgRaised2,
                fg: gc.text,
                onTap: _busy ? () {} : _save,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: PrimaryButton(
                label: _busy ? 'Preparando...' : 'Compartilhar',
                height: 48,
                onTap: _busy ? () {} : _share,
              ),
            ),
          ]),
        ],
      ),
    );
  }

  Widget _chip(GymColors gc, IconData icon, String label, bool on, VoidCallback onTap) => Expanded(
        child: _Pressable(
          onTap: onTap,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            height: 42,
            padding: const EdgeInsets.symmetric(horizontal: 8),
            decoration: BoxDecoration(
              color: on ? gc.accentSoft : gc.bgRaised2,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: on ? gc.accent.withValues(alpha: 0.5) : Colors.transparent,
              ),
            ),
            child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              Icon(icon, size: 16, color: on ? gc.accent : gc.textSecondary),
              const SizedBox(width: 6),
              Flexible(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTheme.s(
                    12,
                    weight: FontWeight.w700,
                    color: on ? gc.text : gc.textSecondary,
                  ),
                ),
              ),
            ]),
          ),
        ),
      );

  Widget _iconToggle(GymColors gc, IconData icon, bool on, VoidCallback onTap) => _Pressable(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          height: 38,
          decoration: BoxDecoration(
            color: on ? gc.accentSoft : gc.bgRaised2,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: on ? gc.accent.withValues(alpha: 0.5) : Colors.transparent,
            ),
          ),
          child: Icon(icon, size: 17, color: on ? gc.accent : gc.textTertiary),
        ),
      );
}

// ─────────────────────────────────────────────────────────────────────────────
// Sticker Card Component
// ─────────────────────────────────────────────────────────────────────────────

class _Sticker extends StatelessWidget {
  const _Sticker({
    required this.durationStr,
    required this.volumeKg,
    required this.prCount,
    required this.calories,
    required this.muscleGroupsStr,
    required this.streak,
    required this.layout,
    required this.showDate,
    required this.color,
  });

  final String durationStr;
  final double volumeKg;
  final int prCount;
  final int calories;
  final String muscleGroupsStr;
  final bool streak;
  final int layout;
  final bool showDate;
  final Color color;

  bool get _light => color.computeLuminance() > 0.5;

  List<Shadow> get _shadow =>
      _light ? const [Shadow(color: Color(0x59000000), blurRadius: 12, offset: Offset(0, 1))] : const [];

  TextStyle _s(
    double size,
    FontWeight w, {
    double alpha = 1,
    double spacing = 0,
    double height = 1.05,
  }) =>
      AppTheme.s(
        size,
        weight: w,
        color: color.withValues(alpha: alpha),
        letterSpacing: spacing,
        height: height,
      ).copyWith(shadows: _shadow, fontFeatures: const [ui.FontFeature.tabularFigures()]);

  TextStyle _d(
    double size,
    FontWeight w, {
    double alpha = 1,
    double spacing = 0,
    double height = 1.05,
  }) =>
      AppTheme.d(
        size,
        weight: w,
        color: color.withValues(alpha: alpha),
        letterSpacing: spacing,
        height: height,
      ).copyWith(shadows: _shadow, fontFeatures: const [ui.FontFeature.tabularFigures()]);

  String get _dateLine {
    final d = DateTime.now();
    final locale = appLanguage == 'pt' ? 'pt_BR' : appLanguage;
    return '${t.longDate(d)} · ${DateFormat.Hm(locale).format(d)}';
  }

  String get _duration => durationStr.isNotEmpty ? durationStr : '0:00';
  String get _volume => fit.volumeLabel(volumeKg);

  int get _setsCount {
    if (fit.session != null) {
      final s = fit.session!;
      if (s.summarySets != null && s.summarySets! > 0) return s.summarySets!;
      final completed = s.exercises.fold<int>(0, (a, e) => a + e.sets.where((st) => st.done).length);
      if (completed > 0) return completed;
    }
    if (fit.sessions.isNotEmpty && fit.sessions.last.setCount > 0) {
      return fit.sessions.last.setCount;
    }
    return volumeKg > 0 ? (volumeKg / 100).round().clamp(3, 30) : 10;
  }

  String get _sets => '$_setsCount';

  List<({String id, String name, String best})> get _exerciseList {
    if (fit.session != null && fit.session!.exercises.isNotEmpty) {
      return fit.session!.exercises.map((e) {
        final top = e.sets.where((s) => s.done || s.reps > 0).fold<SessionSet?>(null, (prev, s) {
          if (prev == null) return s;
          return s.weight * (s.reps + 1) >= prev.weight * (prev.reps + 1) ? s : prev;
        });
        final bestStr = top != null
            ? (top.weight > 0 ? '${fit.weightLabel(top.weight)} × ${top.reps}' : '${top.reps} reps')
            : '';
        return (id: e.id, name: e.name, best: bestStr);
      }).toList();
    }
    if (fit.sessions.isNotEmpty && fit.sessions.last.exercises.isNotEmpty) {
      return fit.sessions.last.exercises.map((e) {
        final top = e.sets.fold<LoggedSet?>(null, (prev, s) {
          if (prev == null) return s;
          return s.weight * (s.reps + 1) >= prev.weight * (prev.reps + 1) ? s : prev;
        });
        final bestStr = top != null
            ? (top.weight > 0 ? '${fit.weightLabel(top.weight)} × ${top.reps}' : '${top.reps} reps')
            : '';
        return (id: e.id, name: e.name, best: bestStr);
      }).toList();
    }
    return const [];
  }

  static const _widths = [230.0, 300.0, 260.0, 280.0, 280.0, 320.0];

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: _widths[layout.clamp(0, 5)],
      child: streak ? _streakBody() : _workoutBody(),
    );
  }

  Widget _mark({double size = 12}) => Row(mainAxisSize: MainAxisSize.min, children: [
        Container(
          width: size + 6,
          height: size + 6,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(4),
            image: const DecorationImage(
              image: AssetImage('assets/icon/ic_1024.png'),
              fit: BoxFit.cover,
            ),
          ),
        ),
        const SizedBox(width: 6),
        Text(
          'FIT//IRON',
          style: _d(size, FontWeight.w700, alpha: 0.95, spacing: 2.0),
        ),
      ]);

  Widget _kicker(String text) =>
      Text(text.toUpperCase(), style: _s(10.5, FontWeight.w800, alpha: 0.75, spacing: 2.2));

  Widget _date({TextAlign align = TextAlign.left}) =>
      Text(_dateLine, textAlign: align, style: _s(12, FontWeight.w600, alpha: 0.75, height: 1.2));

  Widget _stat(String label, String value, {double size = 30}) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(label.toUpperCase(), style: _s(9.5, FontWeight.w700, alpha: 0.7, spacing: 1.5)),
          const SizedBox(height: 2),
          Text(value, maxLines: 1, style: _d(size, FontWeight.w900)),
        ],
      );

  Widget _panel(Widget child) => Container(
        padding: const EdgeInsets.fromLTRB(18, 16, 18, 16),
        decoration: BoxDecoration(
          color: (_light ? Colors.black : Colors.white).withValues(alpha: 0.34),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: color.withValues(alpha: 0.18)),
        ),
        child: child,
      );

  Widget _prs({TextAlign align = TextAlign.left}) =>
      Text('$prCount RECORDES', textAlign: align, style: _s(12, FontWeight.w800, alpha: 0.9));

  Widget _workoutBody() {
    switch (layout) {
      case 1:
        return Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [
          _kicker('Treino'),
          if (showDate) ...[const SizedBox(height: 3), _date()],
          const SizedBox(height: 14),
          Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Expanded(child: _stat('Duração', _duration, size: 24)),
            Expanded(child: _stat('Volume', _volume, size: 24)),
            Expanded(child: _stat('Séries', _sets, size: 24)),
          ]),
          if (prCount > 0) ...[const SizedBox(height: 10), _prs()],
          const SizedBox(height: 14),
          _mark(),
        ]);
      case 2:
        return Column(mainAxisSize: MainAxisSize.min, children: [
          _kicker('Treino'),
          if (showDate) ...[const SizedBox(height: 3), _date(align: TextAlign.center)],
          const SizedBox(height: 6),
          FittedBox(child: Text(_volume, style: _d(64, FontWeight.w900, height: 1))),
          const SizedBox(height: 6),
          Text('$_duration  ·  $_sets séries', style: _s(15, FontWeight.w700, alpha: 0.85)),
          if (prCount > 0) ...[const SizedBox(height: 6), _prs(align: TextAlign.center)],
          const SizedBox(height: 14),
          _mark(),
        ]);
      case 3:
        final exercises = _exerciseList;
        final exCount = exercises.isNotEmpty
            ? exercises.length
            : (muscleGroupsStr.isNotEmpty ? muscleGroupsStr.split(',').length : 4);
        return _panel(Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [
          Row(children: [
            Expanded(child: _kicker('Treino')),
            _mark(size: 11),
          ]),
          if (showDate) ...[const SizedBox(height: 4), _date()],
          const SizedBox(height: 16),
          Row(children: [
            Expanded(child: _stat('Duração', _duration, size: 26)),
            Expanded(child: _stat('Volume', _volume, size: 26)),
          ]),
          const SizedBox(height: 14),
          Row(children: [
            Expanded(child: _stat('Séries', _sets, size: 26)),
            Expanded(child: _stat('Exercícios', '$exCount', size: 26)),
          ]),
          if (prCount > 0) ...[const SizedBox(height: 12), _prs()],
        ]));
      case 4:
        final exercises = _exerciseList;
        final shown = exercises.take(5).toList();
        final more = exercises.length - shown.length;
        return Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [
          _kicker('Treino'),
          if (showDate) ...[const SizedBox(height: 3), _date()],
          const SizedBox(height: 12),
          if (shown.isNotEmpty) ...[
            for (final e in shown) ...[
              Row(
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Expanded(
                    child: Text(
                      t.catalogName(e.id, e.name),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: _s(14, FontWeight.w800, height: 1.2),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text(e.best, style: _s(12.5, FontWeight.w700, alpha: 0.8)),
                ],
              ),
              const SizedBox(height: 7),
            ],
            if (more > 0) ...[
              Text('+$more', style: _s(12, FontWeight.w700, alpha: 0.7)),
              const SizedBox(height: 7),
            ],
          ] else if (muscleGroupsStr.isNotEmpty) ...[
            for (final mg in muscleGroupsStr.split(',').take(4)) ...[
              Row(
                children: [
                  Expanded(
                    child: Text(
                      mg.trim(),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: _s(14, FontWeight.w800, height: 1.2),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 7),
            ],
          ],
          Container(height: 1, color: color.withValues(alpha: 0.3)),
          const SizedBox(height: 9),
          Text(
            '$_duration  ·  $_volume  ·  $_sets séries',
            style: _s(12.5, FontWeight.w800, alpha: 0.9),
          ),
          const SizedBox(height: 12),
          _mark(),
        ]);
      case 5:
        final sep = Container(width: 1, height: 30, color: color.withValues(alpha: 0.35));
        return Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [
          Row(children: [
            _mark(size: 11),
            if (showDate) ...[
              const SizedBox(width: 10),
              Flexible(
                child: Text(
                  _dateLine,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: _s(11, FontWeight.w600, alpha: 0.7),
                ),
              ),
            ],
          ]),
          const SizedBox(height: 10),
          Row(children: [
            Expanded(child: _stat('Duração', _duration, size: 21)),
            sep,
            const SizedBox(width: 12),
            Expanded(child: _stat('Volume', _volume, size: 21)),
            sep,
            const SizedBox(width: 12),
            Expanded(child: _stat('Séries', _sets, size: 21)),
          ]),
        ]);
      default:
        return Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [
          _kicker('Treino'),
          if (showDate) ...[const SizedBox(height: 3), _date()],
          const SizedBox(height: 16),
          _stat('Duração', _duration, size: 34),
          const SizedBox(height: 12),
          _stat('Volume', _volume, size: 34),
          const SizedBox(height: 12),
          _stat('Séries', _sets, size: 34),
          if (prCount > 0) ...[const SizedBox(height: 12), _prs()],
          const SizedBox(height: 16),
          _mark(),
        ]);
    }
  }

  Widget _streakBody() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final start = today.subtract(Duration(days: today.weekday - 1));
    final trained = <int>{};
    for (final s in fit.sessions) {
      final sDate = DateTime(s.date.year, s.date.month, s.date.day);
      final d = sDate.difference(start).inDays;
      if (d >= 0 && d < 7) trained.add(d);
    }
    trained.add(today.weekday - 1);

    final todayIdx = today.weekday - 1;
    final days = fit.currentStreak > 0 ? fit.currentStreak : 1;

    Widget week({double dot = 20, double gap = 4}) => Row(mainAxisSize: MainAxisSize.min, children: [
          for (var i = 0; i < 7; i++)
            Padding(
              padding: EdgeInsets.symmetric(horizontal: gap),
              child: Column(mainAxisSize: MainAxisSize.min, children: [
                Container(
                  width: dot,
                  height: dot,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: trained.contains(i) ? color : Colors.transparent,
                    border: Border.all(
                      color: color.withValues(alpha: i == todayIdx ? 0.95 : 0.4),
                      width: 1.6,
                    ),
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  t.weekdayInitial(i + 1).toUpperCase(),
                  style: _s(9.5, FontWeight.w700, alpha: 0.7),
                ),
              ]),
            ),
        ]);

    Widget big(double size) => Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon(
              PhosphorIcons.fire(PhosphorIconsStyle.fill),
              size: size * 0.7,
              color: color,
              shadows: _shadow,
            ),
            const SizedBox(width: 6),
            Text('$days', style: _d(size, FontWeight.w900, height: 1)),
          ],
        );

    final label = Text('DIAS CONSECUTIVOS', style: _s(10.5, FontWeight.w800, alpha: 0.75, spacing: 1.4));
    final weekCount = _stat('Semana', '${trained.length}/7', size: 22);

    switch (layout) {
      case 1:
        return Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [
          _kicker('Sequência'),
          if (showDate) ...[const SizedBox(height: 3), _date()],
          const SizedBox(height: 10),
          Row(children: [
            big(46),
            const SizedBox(width: 12),
            Expanded(child: label),
          ]),
          const SizedBox(height: 14),
          week(),
          const SizedBox(height: 14),
          _mark(),
        ]);
      case 2:
        return Column(mainAxisSize: MainAxisSize.min, children: [
          _kicker('Sequência'),
          if (showDate) ...[const SizedBox(height: 3), _date(align: TextAlign.center)],
          const SizedBox(height: 8),
          Icon(PhosphorIcons.fire(PhosphorIconsStyle.fill), size: 46, color: color, shadows: _shadow),
          Text('$days', style: _d(96, FontWeight.w900, height: 1)),
          label,
          const SizedBox(height: 16),
          _mark(),
        ]);
      case 3:
        return _panel(Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [
          Row(children: [
            Expanded(child: _kicker('Sequência')),
            _mark(size: 11),
          ]),
          if (showDate) ...[const SizedBox(height: 4), _date()],
          const SizedBox(height: 12),
          big(50),
          const SizedBox(height: 2),
          label,
          const SizedBox(height: 14),
          week(dot: 18, gap: 3.5),
        ]));
      case 4:
        return Column(mainAxisSize: MainAxisSize.min, children: [
          _kicker('Semana'),
          if (showDate) ...[const SizedBox(height: 3), _date(align: TextAlign.center)],
          const SizedBox(height: 14),
          week(dot: 26, gap: 5),
          const SizedBox(height: 14),
          Text('$days dias consecutivos', style: _s(13, FontWeight.w800, alpha: 0.9)),
          const SizedBox(height: 14),
          _mark(),
        ]);
      case 5:
        return Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [
          Row(children: [
            _mark(size: 11),
            if (showDate) ...[
              const SizedBox(width: 10),
              Flexible(
                child: Text(
                  _dateLine,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: _s(11, FontWeight.w600, alpha: 0.7),
                ),
              ),
            ],
          ]),
          const SizedBox(height: 10),
          Row(children: [
            big(30),
            const SizedBox(width: 10),
            Flexible(child: label),
            const SizedBox(width: 12),
            Container(width: 1, height: 26, color: color.withValues(alpha: 0.35)),
            const SizedBox(width: 12),
            weekCount,
          ]),
        ]);
      default:
        return Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [
          _kicker('Sequência'),
          if (showDate) ...[const SizedBox(height: 3), _date()],
          const SizedBox(height: 12),
          big(64),
          const SizedBox(height: 2),
          label,
          const SizedBox(height: 16),
          week(dot: 18, gap: 3),
          const SizedBox(height: 16),
          _mark(),
        ]);
    }
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Checkerboard Background Painter
// ─────────────────────────────────────────────────────────────────────────────

class _Checker extends CustomPainter {
  _Checker(this.a, this.b);

  final Color a, b;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(Offset.zero & size, Paint()..color = a);
    final p = Paint()..color = b;
    const cell = 14.0;
    for (var y = 0; y * cell < size.height; y++) {
      for (var x = (y % 2); x * cell < size.width; x += 2) {
        canvas.drawRect(Rect.fromLTWH(x * cell, y * cell, cell, cell), p);
      }
    }
  }

  @override
  bool shouldRepaint(_Checker old) => old.a != a || old.b != b;
}

// ─────────────────────────────────────────────────────────────────────────────
// Interactive Micro-Components
// ─────────────────────────────────────────────────────────────────────────────

class _Pressable extends StatefulWidget {
  const _Pressable({
    required this.child,
    required this.onTap,
    this.scale = 0.965,
  });

  final Widget child;
  final VoidCallback? onTap;
  final double scale;

  @override
  State<_Pressable> createState() => _PressableState();
}

class _PressableState extends State<_Pressable> {
  bool _down = false;

  void _set(bool v) {
    if (_down != v && mounted) setState(() => _down = v);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: widget.onTap,
      onTapDown: widget.onTap == null ? null : (_) => _set(true),
      onTapUp: widget.onTap == null ? null : (_) => _set(false),
      onTapCancel: () => _set(false),
      child: AnimatedScale(
        scale: _down ? widget.scale : 1.0,
        duration: const Duration(milliseconds: 100),
        curve: Curves.easeOutCubic,
        child: widget.child,
      ),
    );
  }
}

class _RoundAction extends StatelessWidget {
  const _RoundAction({
    required this.child,
    required this.onTap,
    this.label,
  });

  final Widget child;
  final VoidCallback onTap;
  final String? label;

  @override
  Widget build(BuildContext context) {
    final gc = context.gc;
    return _Pressable(
      onTap: onTap,
      scale: 0.9,
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: gc.bgRaised2,
          shape: BoxShape.circle,
        ),
        alignment: Alignment.center,
        child: child,
      ),
    );
  }
}
