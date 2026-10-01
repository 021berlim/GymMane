import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../l10n/l10n.dart';
import '../theme/app_colors.dart';
import '../theme/app_theme.dart';
import 'ui_kit.dart';

class GoalRing extends StatelessWidget {
  const GoalRing({super.key, required this.pct, this.size = 40});
  final double pct;
  final double size;
  @override
  Widget build(BuildContext context) {
    final gc = context.gc;
    return SizedBox(
      width: size,
      height: size,
      child: RepaintBoundary(
        child: CustomPaint(painter: _RingPainter(pct, gc.bgRaised2, gc.accent)),
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  _RingPainter(this.pct, this.track, this.accent);
  final double pct;
  final Color track, accent;
  @override
  void paint(Canvas canvas, Size size) {
    canvas.scale(size.width / 40);
    const center = Offset(20, 20);
    const r = 16.0;
    final t = Paint()..style = PaintingStyle.stroke..strokeWidth = 4..color = track;
    canvas.drawCircle(center, r, t);
    final a = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round
      ..color = accent;
    canvas.drawArc(Rect.fromCircle(center: center, radius: r), -math.pi / 2, pct / 100 * 2 * math.pi, false, a);
  }

  @override
  bool shouldRepaint(_RingPainter o) => o.pct != pct || o.accent != accent || o.track != track;
}

class Heatmap extends StatelessWidget {
  const Heatmap({super.key, required this.levels, this.onTapDay});
  final List<int> levels;
  final void Function(int index)? onTapDay;

  Color _color(int level, GymColors gc) {
    switch (level) {
      case 3:
        return gc.accent;
      case 2:
        return gc.brass;
      case 1:
        return gc.mutedFill;
      default:
        return gc.heatEmpty;
    }
  }

  @override
  Widget build(BuildContext context) {
    final gc = context.gc;
    const cols = 12, gap = 4.0;
    return LayoutBuilder(builder: (context, c) {
      final cell = (c.maxWidth - gap * (cols - 1)) / cols;
      return Wrap(
        spacing: gap,
        runSpacing: gap,
        children: [
          for (int i = 0; i < levels.length; i++)
            GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: onTapDay == null ? null : () => onTapDay!(i),
              child: Container(
                width: cell,
                height: cell,
                decoration:
                    BoxDecoration(color: _color(levels[i], gc), borderRadius: BorderRadius.circular(3)),
              ),
            ),
        ],
      );
    });
  }
}

class RadarMuscleChart extends StatelessWidget {
  const RadarMuscleChart({
    super.key,
    required this.entries,
    required this.onExploreDetails,
  });

  final List<({String name, int pct})> entries;
  final VoidCallback onExploreDetails;

  @override
  Widget build(BuildContext context) {
    final gc = context.gc;
    final groupMap = <String, double>{};
    for (final e in entries) {
      groupMap[e.name.toLowerCase()] = e.pct.toDouble();
    }

    final groups = [
      (groupName: t.muscleGroupName('Legs').toUpperCase(), key: 'legs'),
      (groupName: t.muscleGroupName('Arms').toUpperCase(), key: 'arms'),
      (groupName: t.muscleGroupName('Chest').toUpperCase(), key: 'chest'),
      (groupName: t.muscleGroupName('Shoulders').toUpperCase(), key: 'shoulders'),
      (groupName: t.muscleGroupName('Back').toUpperCase(), key: 'back'),
      (groupName: t.muscleGroupName('Core').toUpperCase(), key: 'core'),
    ];

    double maxVal = 0.0;
    for (final g in groups) {
      final v = _getGroupVal(g.key, groupMap);
      if (v > maxVal) maxVal = v;
    }
    if (maxVal <= 0) maxVal = 100.0;

    final values = [
      for (final g in groups) (_getGroupVal(g.key, groupMap) / maxVal).clamp(0.08, 1.0)
    ];

    return SoftCard(
      radius: 20,
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  t.muscleDistribution.toUpperCase(),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTheme.d(14, weight: FontWeight.w600, color: gc.text, letterSpacing: 1),
                ),
              ),
              const SizedBox(width: 8),
              GestureDetector(
                onTap: onExploreDetails,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      t.exploreDetails,
                      style: AppTheme.s(12, color: gc.textSecondary),
                    ),
                    const SizedBox(width: 4),
                    Icon(PhosphorIconsRegular.caretRight, size: 14, color: gc.textSecondary),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 260,
            child: RepaintBoundary(
              child: CustomPaint(
                painter: _RadarChartPainter(
                  gc: gc,
                  labels: [for (final g in groups) g.groupName],
                  values: values,
                ),
              ),
            ),
          ),
              const SizedBox(height: 16),
              FittedBox(
                fit: BoxFit.scaleDown,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(width: 16, height: 2.5, color: gc.accent),
                    const SizedBox(width: 8),
                    Text(
                      t.currentWeekPeriod,
                      style: AppTheme.s(12, color: gc.textSecondary),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
  }

  double _getGroupVal(String key, Map<String, double> map) {
    for (final entry in map.entries) {
      final name = entry.key;
      if (key == 'legs' && (name.contains('leg') || name.contains('perna') || name.contains('pierna'))) {
        return entry.value;
      }
      if (key == 'arms' && (name.contains('arm') || name.contains('braço') || name.contains('brazo'))) {
        return entry.value;
      }
      if (key == 'chest' && (name.contains('chest') || name.contains('peito') || name.contains('pecho'))) {
        return entry.value;
      }
      if (key == 'shoulders' && (name.contains('shoulder') || name.contains('ombro') || name.contains('hombro'))) {
        return entry.value;
      }
      if (key == 'back' && (name.contains('back') || name.contains('costa') || name.contains('espalda'))) {
        return entry.value;
      }
      if (key == 'core' && (name.contains('core') || name.contains('abdo') || name.contains('flexi') || name.contains('warm'))) {
        return entry.value;
      }
    }
    return 0.0;
  }
}

class _RadarChartPainter extends CustomPainter {
  _RadarChartPainter({
    required this.gc,
    required this.labels,
    required this.values,
  });

  final GymColors gc;
  final List<String> labels;
  final List<double> values;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width, size.height) * 0.35;
    const count = 6;
    const angleStep = (2 * math.pi) / count;
    const startAngle = -2 * math.pi / 3;

    // 0. Ambient radial glow & background grid
    final ambientGlowPaint = Paint()
      ..shader = RadialGradient(
        colors: [
          gc.accent.withValues(alpha: 0.14),
          gc.accent.withValues(alpha: 0.03),
          Colors.transparent,
        ],
        stops: const [0.0, 0.55, 1.0],
      ).createShader(Rect.fromCircle(center: center, radius: radius * 1.25));
    canvas.drawCircle(center, radius * 1.25, ambientGlowPaint);

    final bgGridPaint = Paint()
      ..color = gc.accent.withValues(alpha: 0.04)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.8;
    const gridSpacing = 28.0;
    final gridBounds = Rect.fromCircle(center: center, radius: radius * 1.15);
    for (double x = gridBounds.left; x <= gridBounds.right; x += gridSpacing) {
      canvas.drawLine(Offset(x, gridBounds.top), Offset(x, gridBounds.bottom), bgGridPaint);
    }
    for (double y = gridBounds.top; y <= gridBounds.bottom; y += gridSpacing) {
      canvas.drawLine(Offset(gridBounds.left, y), Offset(gridBounds.right, y), bgGridPaint);
    }

    // 1. Draw concentric hexagonal grid rings (5 rings)
    final gridPaint = Paint()
      ..color = gc.accent.withValues(alpha: 0.18)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    const ringCount = 5;
    for (int ring = 1; ring <= ringCount; ring++) {
      final r = radius * (ring / ringCount);
      final ringPath = Path();
      for (int i = 0; i < count; i++) {
        final angle = startAngle + i * angleStep;
        final x = center.dx + r * math.cos(angle);
        final y = center.dy + r * math.sin(angle);
        if (i == 0) {
          ringPath.moveTo(x, y);
        } else {
          ringPath.lineTo(x, y);
        }
      }
      ringPath.close();
      canvas.drawPath(ringPath, gridPaint);
    }

    // 2. Draw radial lines from center to outer vertices
    for (int i = 0; i < count; i++) {
      final angle = startAngle + i * angleStep;
      final x = center.dx + radius * math.cos(angle);
      final y = center.dy + radius * math.sin(angle);
      canvas.drawLine(center, Offset(x, y), gridPaint);
    }

    // 3. Draw data polygon (filled green translucent & outline)
    final dataPath = Path();
    final dataPoints = <Offset>[];

    for (int i = 0; i < count; i++) {
      final val = (i < values.length) ? values[i] : 0.08;
      final r = radius * val;
      final angle = startAngle + i * angleStep;
      final pt = Offset(
        center.dx + r * math.cos(angle),
        center.dy + r * math.sin(angle),
      );
      dataPoints.add(pt);
      if (i == 0) {
        dataPath.moveTo(pt.dx, pt.dy);
      } else {
        dataPath.lineTo(pt.dx, pt.dy);
      }
    }
    dataPath.close();

    final fillPaint = Paint()
      ..color = gc.accent.withValues(alpha: 0.22)
      ..style = PaintingStyle.fill;
    final strokePaint = Paint()
      ..color = gc.accent
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.2;
    final nodePaint = Paint()
      ..color = gc.accent
      ..style = PaintingStyle.fill;

    canvas.drawPath(dataPath, fillPaint);
    canvas.drawPath(dataPath, strokePaint);

    for (final pt in dataPoints) {
      canvas.drawCircle(pt, 3.5, nodePaint);
    }

    // 4. Draw vertex labels
    final textStyle = TextStyle(
      fontSize: 12,
      fontWeight: FontWeight.w800,
      color: gc.text,
      letterSpacing: 1.0,
    );

    for (int i = 0; i < count; i++) {
      final label = (i < labels.length) ? labels[i] : '';
      final angle = startAngle + i * angleStep;
      final labelRadius = radius + 24.0;
      final lx = center.dx + labelRadius * math.cos(angle);
      final ly = center.dy + labelRadius * math.sin(angle);

      final tp = TextPainter(
        text: TextSpan(text: label, style: textStyle),
        textDirection: TextDirection.ltr,
      );
      tp.layout();

      double dx = lx - tp.width / 2;
      double dy = ly - tp.height / 2;

      if (i == 0) { // PERNAS (Top-Left)
        dx = lx - tp.width / 2;
        dy = ly - tp.height - 2;
      } else if (i == 1) { // BRAÇOS (Top-Right)
        dx = lx - tp.width / 2;
        dy = ly - tp.height - 2;
      } else if (i == 2) { // PEITORAL (Right)
        dx = lx + 6;
        dy = ly - tp.height / 2;
      } else if (i == 3) { // OMBROS (Bottom-Right)
        dx = lx - tp.width / 2;
        dy = ly + 4;
      } else if (i == 4) { // COSTAS (Bottom-Left)
        dx = lx - tp.width / 2;
        dy = ly + 4;
      } else if (i == 5) { // CORE (Left)
        dx = lx - tp.width - 6;
        dy = ly - tp.height / 2;
      }

      tp.paint(canvas, Offset(dx, dy));
    }
  }

  @override
  bool shouldRepaint(covariant _RadarChartPainter oldDelegate) =>
      oldDelegate.gc != gc || oldDelegate.values != values || oldDelegate.labels != labels;
}
