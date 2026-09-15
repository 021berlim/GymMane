import 'package:flutter/material.dart';

import '../catalog/body_svg.dart';
import '../theme/app_colors.dart';
import 'svg_icon.dart';

class MuscleIcon extends StatelessWidget {
  const MuscleIcon({
    super.key,
    required this.muscleId,
    this.size = 56.0,
    this.highlightColor,
  });

  final String muscleId;
  final double size;
  final Color? highlightColor;

  @override
  Widget build(BuildContext context) {
    final gc = context.gc;
    final activeGreen = highlightColor ?? const Color(0xFF76E026);
    final idleColor = Color.lerp(gc.bgRaised2, gc.textSecondary, 0.20)!;

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: gc.bgRaised2,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: gc.border.withValues(alpha: 0.5)),
      ),
      clipBehavior: Clip.antiAlias,
      child: Center(
        child: SizedBox(
          width: size * 0.85,
          height: size * 0.85,
          child: CustomPaint(
            painter: _SingleMusclePainter(
              gc: gc,
              targetMuscle: muscleId,
              activeColor: activeGreen,
              idleColor: idleColor,
            ),
          ),
        ),
      ),
    );
  }
}

class _SingleMusclePainter extends CustomPainter {
  _SingleMusclePainter({
    required this.gc,
    required this.targetMuscle,
    required this.activeColor,
    required this.idleColor,
  });

  final GymColors gc;
  final String targetMuscle;
  final Color activeColor;
  final Color idleColor;

  static bool _isBackView(String m) {
    return m == 'back' ||
        m == 'trapezius' ||
        m == 'triceps' ||
        m == 'glutes' ||
        m == 'hamstrings' ||
        m == 'calves';
  }

  @override
  void paint(Canvas canvas, Size size) {
    final useBack = _isBackView(targetMuscle);
    final figWidth = bodyViewW / 2; // 267.5
    final figHeight = bodyViewH; // 462.0

    final scaleX = size.width / figWidth;
    final scaleY = size.height / figHeight;
    final scale = scaleX < scaleY ? scaleX : scaleY;

    final dx = (size.width - (figWidth * scale)) / 2;
    final dy = (size.height - (figHeight * scale)) / 2;

    canvas.save();
    canvas.translate(dx, dy);
    canvas.scale(scale);

    // Recorta exatamente o retângulo da figura única (267.5 x 462) para zerar qualquer visibilidade da outra figura
    canvas.clipRect(Rect.fromLTWH(0, 0, figWidth, figHeight));

    if (useBack) {
      canvas.translate(-figWidth, 0);
    }

    final bodyMain = Color.lerp(gc.bgRaised, gc.textSecondary, 0.15)!;
    final bodyLite = Color.lerp(gc.bgRaised, gc.textSecondary, 0.25)!;

    void fill(String d, Color c) =>
        canvas.drawPath(svgPath(d), Paint()..color = c..style = PaintingStyle.fill..isAntiAlias = true);

    for (final d in bodyBaseMain) {
      fill(d, bodyMain);
    }
    for (final d in bodyBaseLite) {
      fill(d, bodyLite);
    }
    for (final entry in muscleFills.entries) {
      final isTarget = entry.key == targetMuscle ||
          (targetMuscle == 'chest' && entry.key == 'chest') ||
          (targetMuscle == 'back' && (entry.key == 'back' || entry.key == 'trapezius')) ||
          (targetMuscle == 'shoulders' && entry.key == 'shoulders') ||
          (targetMuscle == 'biceps' && entry.key == 'biceps') ||
          (targetMuscle == 'triceps' && entry.key == 'triceps') ||
          (targetMuscle == 'quads' && entry.key == 'quads') ||
          (targetMuscle == 'hamstrings' && entry.key == 'hamstrings') ||
          (targetMuscle == 'glutes' && entry.key == 'glutes') ||
          (targetMuscle == 'calves' && entry.key == 'calves') ||
          (targetMuscle == 'abdomen' && entry.key == 'abdomen') ||
          (targetMuscle == 'forearm' && entry.key == 'forearm');

      final c = isTarget ? activeColor : idleColor;
      for (final d in entry.value) {
        fill(d, c);
      }
    }

    canvas.restore();
  }

  @override
  bool shouldRepaint(_SingleMusclePainter old) =>
      old.gc != gc || old.targetMuscle != targetMuscle || old.activeColor != activeColor;
}
