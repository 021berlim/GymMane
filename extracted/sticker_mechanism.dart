import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';

// ─────────────────────────────────────────────────────────────────────────────
// NOTAS DE MAPEAMENTO DE DADOS (ORIGEM InlitX/GymMane → DESTINO LOCAL fitiron)
// ─────────────────────────────────────────────────────────────────────────────
//
// 1. Branding:
//    - Origem: Image.asset('assets/img/runner.png') + Text('GymMane')
//    - Local:  AssetImage('assets/icon/ic_1024.png') + Text('FIT//IRON')
//
// 2. Tempo de Treino:
//    - Origem: durationClock(session.durationSec)
//    - Local:  widget.durationStr (já formatado como "45 MIN" ou relógio)
//
// 3. Volume Total:
//    - Origem: fit.volumeLabel(session.volume)
//    - Local:  fit.volumeLabel(widget.volumeKg)
//
// 4. Séries / Sets:
//    - Origem: '${session.setCount}'
//    - Local:  fit.session?.summarySets ?? fit.sessions.lastOrNull?.setCount ?? calculado
//
// 5. Recordes (PRs):
//    - Origem: t.prCount(prs)
//    - Local:  widget.prCount > 0 ? '${widget.prCount} RECORDES' : ''
//
// 6. Lista de Exercícios (Layout 4):
//    - Origem: session.exercises.take(5)
//    - Local:  (fit.session?.exercises ?? fit.sessions.lastOrNull?.exercises ?? [])
//              ou divisão dos grupos musculares informados em widget.muscleGroupsStr.
//
// 7. Sequência (Streak):
//    - Origem: fit.currentStreak + sessions no intervalo da semana
//    - Local:  fit.currentStreak + varredura de fit.sessions na semana atual
//
// 8. Notificações / Toasts:
//    - Origem: showNotchToast(context, t.stickerSaved, ...)
//    - Local:  AppToast.showSuccess(context, 'Salvo na galeria') e AppToast.showError(context, ...)
//
// 9. Ícones:
//    - Origem: phosphoricons_flutter (PhosphorIconsRegular.image, etc.)
//    - Local:  phosphor_flutter (PhosphorIcons.image(PhosphorIconsStyle.regular), etc.)
// ─────────────────────────────────────────────────────────────────────────────

/// Fundo xadrez (checkerboard) exibido quando nenhuma foto está selecionada.
class StickerCheckerPainter extends CustomPainter {
  const StickerCheckerPainter(this.colorA, this.colorB, {this.cellSize = 14.0});

  final Color colorA;
  final Color colorB;
  final double cellSize;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(Offset.zero & size, Paint()..color = colorA);
    final paintB = Paint()..color = colorB;
    for (var y = 0; y * cellSize < size.height; y++) {
      for (var x = (y % 2); x * cellSize < size.width; x += 2) {
        canvas.drawRect(Rect.fromLTWH(x * cellSize, y * cellSize, cellSize, cellSize), paintB);
      }
    }
  }

  @override
  bool shouldRepaint(covariant StickerCheckerPainter oldDelegate) =>
      oldDelegate.colorA != colorA || oldDelegate.colorB != colorB || oldDelegate.cellSize != cellSize;
}

/// Contrato desacoplado para os dados exibidos no sticker.
class StickerStatsData {
  final String duration;
  final String volume;
  final String sets;
  final int prs;
  final int streakDays;
  final Set<int> weekTrainedDays;
  final int todayWeekdayIndex;
  final String dateLine;
  final List<({String name, String best})> exercises;

  const StickerStatsData({
    required this.duration,
    required this.volume,
    required this.sets,
    required this.prs,
    required this.streakDays,
    required this.weekTrainedDays,
    required this.todayWeekdayIndex,
    required this.dateLine,
    this.exercises = const [],
  });
}

/// Mecanismo de captura de imagem de alta resolução a partir do RepaintBoundary.
class StickerCaptureService {
  StickerCaptureService._();

  static Future<Uint8List?> captureBoundary(GlobalKey boundaryKey, {double targetWidth = 1080.0}) async {
    final boundary = boundaryKey.currentContext?.findRenderObject() as RenderRepaintBoundary?;
    if (boundary == null) return null;
    final pixelRatio = (targetWidth / boundary.size.width).clamp(1.0, 4.0);
    final image = await boundary.toImage(pixelRatio: pixelRatio);
    final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    image.dispose();
    return byteData?.buffer.asUint8List();
  }
}

/// Gerenciador de gestos combinados (Pan + Pinch Scale + Rotation).
class StickerTransformController {
  Offset position;
  double scale;
  double rotation;

  double _startScale = 1.0;
  double _startRotation = 0.0;

  StickerTransformController({
    this.position = const Offset(0.5, 0.68),
    this.scale = 1.0,
    this.rotation = 0.0,
  });

  void onScaleStart(ScaleStartDetails details) {
    _startScale = scale;
    _startRotation = rotation;
  }

  void onScaleUpdate(ScaleUpdateDetails details, Size canvasSize) {
    if (canvasSize.width <= 0 || canvasSize.height <= 0) return;

    position = Offset(
      (position.dx + details.focalPointDelta.dx / canvasSize.width).clamp(0.0, 1.0),
      (position.dy + details.focalPointDelta.dy / canvasSize.height).clamp(0.0, 1.0),
    );

    if (details.pointerCount > 1) {
      scale = (_startScale * details.scale).clamp(0.45, 2.6);
      rotation = _startRotation + details.rotation;
    }
  }

  void resetRotation() {
    rotation = 0.0;
  }
}
