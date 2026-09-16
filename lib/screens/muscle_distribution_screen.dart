import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:path_drawing/path_drawing.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../l10n/l10n.dart';
import '../state/fit_state.dart';
import '../theme/app_colors.dart';
import '../theme/app_theme.dart';
import '../widgets/ui_kit.dart';

enum MuscleDistributionGrain { week, month, year }

class MuscleDistributionScreen extends StatefulWidget {
  const MuscleDistributionScreen({super.key});

  @override
  State<MuscleDistributionScreen> createState() => _MuscleDistributionScreenState();
}

class _MuscleDistributionScreenState extends State<MuscleDistributionScreen> {
  MuscleDistributionGrain _grain = MuscleDistributionGrain.week;
  int _periodOffset = 0;

  @override
  Widget build(BuildContext context) {
    final gc = context.gc;
    final periods = _calculatePeriods();
    final data = fit.muscleDistributionForPeriod(
      start: periods.start,
      end: periods.end,
      prevStart: periods.prevStart,
      prevEnd: periods.prevEnd,
    );

    return Scaffold(
      backgroundColor: gc.bg,
      body: SafeArea(
        child: Column(
          children: [
            _buildAppBar(context, gc),
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.fromLTRB(20, 8, 20, 32 + MediaQuery.of(context).padding.bottom),
                child: Column(
                  children: [
                    _buildGrainSelector(gc),
                    const SizedBox(height: 18),
                    _buildPeriodNavigator(gc, periods.label),
                    const SizedBox(height: 20),
                    _DistributionCard(
                      title: t.equivalentSets,
                      infoDescription: t.equivalentSetsInfoDesc,
                      accentColor: gc.accent,
                      currentMap: data.currentSets,
                      previousMap: data.previousSets,
                      currentLegend: _currentPeriodLegend(),
                      previousLegend: _previousPeriodLegend(),
                    ),
                    const SizedBox(height: 20),
                    _DistributionCard(
                      title: t.equivalentVolume,
                      infoDescription: t.equivalentVolumeInfoDesc,
                      accentColor: const Color(0xFFA855F7), // Purple theme as in reference image
                      currentMap: data.currentVolume,
                      previousMap: data.previousVolume,
                      currentLegend: _currentPeriodLegend(),
                      previousLegend: _previousPeriodLegend(),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAppBar(BuildContext context, GymColors gc) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: gc.bgRaised,
                border: Border.all(color: gc.border),
                shape: BoxShape.circle,
              ),
              child: Icon(
                PhosphorIconsRegular.caretLeft,
                size: 20,
                color: gc.text,
              ),
            ),
          ),
          Expanded(
            child: Text(
              t.muscleDistribution,
              textAlign: TextAlign.center,
              style: AppTheme.d(18, weight: FontWeight.w600, color: gc.text),
            ),
          ),
          const SizedBox(width: 48), // Balance leading back button
        ],
      ),
    );
  }

  Widget _buildGrainSelector(GymColors gc) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: gc.bgRaised,
        border: Border.all(color: gc.border),
        borderRadius: BorderRadius.circular(30),
      ),
      child: Row(
        children: [
          _grainPill(gc, t.tabWeek, MuscleDistributionGrain.week),
          _grainPill(gc, t.tabMonth, MuscleDistributionGrain.month),
          _grainPill(gc, t.tabYear, MuscleDistributionGrain.year),
        ],
      ),
    );
  }

  Widget _grainPill(GymColors gc, String label, MuscleDistributionGrain grain) {
    final isSelected = _grain == grain;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          if (_grain != grain) {
            setState(() {
              _grain = grain;
              _periodOffset = 0;
            });
          }
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isSelected ? gc.accent : Colors.transparent,
            borderRadius: BorderRadius.circular(24),
            boxShadow: isSelected
                ? [BoxShadow(color: gc.accent.withValues(alpha: 0.3), blurRadius: 8, offset: const Offset(0, 2))]
                : null,
          ),
          child: Text(
            label.toUpperCase(),
            textAlign: TextAlign.center,
            style: AppTheme.d(
              12,
              weight: isSelected ? FontWeight.w800 : FontWeight.w600,
              color: isSelected ? Colors.black : gc.textSecondary,
              letterSpacing: 1.2,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPeriodNavigator(GymColors gc, String label) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        IconButton(
          onPressed: () => setState(() => _periodOffset--),
          icon: Icon(PhosphorIconsRegular.caretLeft, size: 18, color: gc.textSecondary),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            label,
            style: AppTheme.s(15, weight: FontWeight.w600, color: gc.text),
          ),
        ),
        IconButton(
          onPressed: _periodOffset < 0 ? () => setState(() => _periodOffset++) : null,
          icon: Icon(
            PhosphorIconsRegular.caretRight,
            size: 18,
            color: _periodOffset < 0 ? gc.textSecondary : gc.border,
          ),
        ),
      ],
    );
  }

  String _currentPeriodLegend() {
    switch (_grain) {
      case MuscleDistributionGrain.week:
        return t.currentWeekPeriod;
      case MuscleDistributionGrain.month:
        return t.currentMonthPeriod;
      case MuscleDistributionGrain.year:
        return t.currentYearPeriod;
    }
  }

  String _previousPeriodLegend() {
    switch (_grain) {
      case MuscleDistributionGrain.week:
        return t.previousWeekPeriod;
      case MuscleDistributionGrain.month:
        return t.previousMonthPeriod;
      case MuscleDistributionGrain.year:
        return t.previousYearPeriod;
    }
  }

  ({DateTime start, DateTime end, DateTime prevStart, DateTime prevEnd, String label}) _calculatePeriods() {
    final now = DateTime.now();

    if (_grain == MuscleDistributionGrain.week) {
      final currentMonday = DateTime(now.year, now.month, now.day).subtract(Duration(days: now.weekday - 1));
      final targetMonday = currentMonday.add(Duration(days: _periodOffset * 7));
      final end = targetMonday.add(const Duration(days: 7));
      final prevStart = targetMonday.subtract(const Duration(days: 7));
      final prevEnd = targetMonday;

      final startSunday = targetMonday.add(const Duration(days: 6));
      final startStr = '${targetMonday.day} ${_shortMonthName(targetMonday.month)}';
      final endStr = '${startSunday.day} ${_shortMonthName(startSunday.month)}';

      return (
        start: targetMonday,
        end: end,
        prevStart: prevStart,
        prevEnd: prevEnd,
        label: '$startStr. - $endStr.',
      );
    } else if (_grain == MuscleDistributionGrain.month) {
      final targetMonth = DateTime(now.year, now.month + _periodOffset, 1);
      final end = DateTime(targetMonth.year, targetMonth.month + 1, 1);
      final prevStart = DateTime(targetMonth.year, targetMonth.month - 1, 1);
      final prevEnd = targetMonth;

      return (
        start: targetMonth,
        end: end,
        prevStart: prevStart,
        prevEnd: prevEnd,
        label: t.monthYear(targetMonth),
      );
    } else {
      final targetYear = now.year + _periodOffset;
      final start = DateTime(targetYear, 1, 1);
      final end = DateTime(targetYear + 1, 1, 1);
      final prevStart = DateTime(targetYear - 1, 1, 1);
      final prevEnd = start;

      return (
        start: start,
        end: end,
        prevStart: prevStart,
        prevEnd: prevEnd,
        label: '$targetYear',
      );
    }
  }

  String _shortMonthName(int month) {
    const months = ['jan', 'fev', 'mar', 'abr', 'mai', 'jun', 'jul', 'ago', 'set', 'out', 'nov', 'dez'];
    return months[(month - 1) % 12];
  }
}

class _DistributionCard extends StatelessWidget {
  const _DistributionCard({
    required this.title,
    required this.infoDescription,
    required this.accentColor,
    required this.currentMap,
    required this.previousMap,
    required this.currentLegend,
    required this.previousLegend,
  });

  final String title;
  final String infoDescription;
  final Color accentColor;
  final Map<String, double> currentMap;
  final Map<String, double> previousMap;
  final String currentLegend;
  final String previousLegend;

  void _showInfoSheet(BuildContext context, GymColors gc) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (bctx) {
        return Container(
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            color: gc.bgRaised,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
            border: Border.all(color: gc.border),
          ),
          padding: EdgeInsets.fromLTRB(
            24,
            20,
            24,
            28 + MediaQuery.of(bctx).padding.bottom,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(color: gc.bgRaised2, borderRadius: BorderRadius.circular(2)),
                ),
              ),
              const SizedBox(height: 18),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      title,
                      style: AppTheme.d(20, weight: FontWeight.w700, color: gc.text),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(bctx).pop(),
                    icon: Icon(PhosphorIconsRegular.x, size: 22, color: gc.textSecondary),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                infoDescription,
                style: AppTheme.s(14, color: gc.textSecondary, height: 1.55),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final gc = context.gc;
    final groups = [
      (label: t.muscleGroupName('Legs').toUpperCase(), key: 'legs'),
      (label: t.muscleGroupName('Arms').toUpperCase(), key: 'arms'),
      (label: t.muscleGroupName('Chest').toUpperCase(), key: 'chest'),
      (label: t.muscleGroupName('Shoulders').toUpperCase(), key: 'shoulders'),
      (label: t.muscleGroupName('Back').toUpperCase(), key: 'back'),
      (label: t.muscleGroupName('Core').toUpperCase(), key: 'core'),
    ];

    double maxVal = 0.0;
    for (final g in groups) {
      final c = currentMap[g.key] ?? 0.0;
      final p = previousMap[g.key] ?? 0.0;
      if (c > maxVal) maxVal = c;
      if (p > maxVal) maxVal = p;
    }
    if (maxVal <= 0) maxVal = 100.0;

    final curValues = [
      for (final g in groups) ((currentMap[g.key] ?? 0.0) / maxVal).clamp(0.08, 1.0)
    ];
    final prevValues = [
      for (final g in groups) ((previousMap[g.key] ?? 0.0) / maxVal).clamp(0.08, 1.0)
    ];

    return SoftCard(
      radius: 24,
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTheme.d(18, weight: FontWeight.w600, color: gc.text),
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                onPressed: () => _showInfoSheet(context, gc),
                icon: Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: gc.border),
                  ),
                  child: Icon(
                    PhosphorIconsRegular.info,
                    size: 16,
                    color: gc.textSecondary,
                  ),
                ),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 280,
            child: CustomPaint(
              painter: _HexagonRadarPainter(
                gc: gc,
                accentColor: accentColor,
                labels: [for (final g in groups) g.label],
                currentValues: curValues,
                previousValues: prevValues,
              ),
            ),
          ),
          const SizedBox(height: 16),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(width: 16, height: 2.5, color: accentColor),
                const SizedBox(width: 6),
                Text(
                  currentLegend,
                  style: AppTheme.s(12, color: gc.textSecondary),
                ),
                const SizedBox(width: 16),
                CustomPaint(
                  size: const Size(16, 2.5),
                  painter: _DashedLinePainter(color: accentColor.withValues(alpha: 0.7)),
                ),
                const SizedBox(width: 6),
                Text(
                  previousLegend,
                  style: AppTheme.s(12, color: gc.textSecondary),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DashedLinePainter extends CustomPainter {
  _DashedLinePainter({required this.color});
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke;
    final path = Path()..moveTo(0, size.height / 2)..lineTo(size.width, size.height / 2);
    final dashed = dashPath(path, dashArray: CircularIntervalList<double>([3, 3]));
    canvas.drawPath(dashed, paint);
  }

  @override
  bool shouldRepaint(covariant _DashedLinePainter oldDelegate) => oldDelegate.color != color;
}

class _HexagonRadarPainter extends CustomPainter {
  _HexagonRadarPainter({
    required this.gc,
    required this.accentColor,
    required this.labels,
    required this.currentValues,
    required this.previousValues,
  });

  final GymColors gc;
  final Color accentColor;
  final List<String> labels;
  final List<double> currentValues;
  final List<double> previousValues;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width, size.height) * 0.36;
    const count = 6;
    const angleStep = (2 * math.pi) / count;
    // 0: PERNAS (Top-Left: -120 deg), 1: BRAÇOS (Top-Right: -60 deg), 2: PEITORAL (Right: 0 deg),
    // 3: OMBROS (Bottom-Right: 60 deg), 4: COSTAS (Bottom-Left: 120 deg), 5: CORE (Left: 180 deg)
    const startAngle = -2 * math.pi / 3;

    // 0. Ambient radial glow & background grid
    final ambientGlowPaint = Paint()
      ..shader = RadialGradient(
        colors: [
          accentColor.withValues(alpha: 0.14),
          accentColor.withValues(alpha: 0.03),
          Colors.transparent,
        ],
        stops: const [0.0, 0.55, 1.0],
      ).createShader(Rect.fromCircle(center: center, radius: radius * 1.25));
    canvas.drawCircle(center, radius * 1.25, ambientGlowPaint);

    final bgGridPaint = Paint()
      ..color = accentColor.withValues(alpha: 0.04)
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

    // 1. Grid rings (5 concentric hexagonal rings)
    final gridPaint = Paint()
      ..color = accentColor.withValues(alpha: 0.18)
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

    // 2. Radial axis lines
    for (int i = 0; i < count; i++) {
      final angle = startAngle + i * angleStep;
      final x = center.dx + radius * math.cos(angle);
      final y = center.dy + radius * math.sin(angle);
      canvas.drawLine(center, Offset(x, y), gridPaint);
    }

    // 3. Previous period path (dashed line)
    if (previousValues.any((v) => v > 0.09)) {
      final prevPath = Path();
      for (int i = 0; i < count; i++) {
        final val = (i < previousValues.length) ? previousValues[i] : 0.08;
        final r = radius * val;
        final angle = startAngle + i * angleStep;
        final pt = Offset(center.dx + r * math.cos(angle), center.dy + r * math.sin(angle));
        if (i == 0) {
          prevPath.moveTo(pt.dx, pt.dy);
        } else {
          prevPath.lineTo(pt.dx, pt.dy);
        }
      }
      prevPath.close();

      final prevStrokePaint = Paint()
        ..color = gc.textTertiary.withValues(alpha: 0.7)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.8;

      final dashedPath = dashPath(prevPath, dashArray: CircularIntervalList<double>([4, 4]));
      canvas.drawPath(dashedPath, prevStrokePaint);
    }

    // 4. Current period path (solid line & translucent fill)
    final curPath = Path();
    final curPoints = <Offset>[];
    for (int i = 0; i < count; i++) {
      final val = (i < currentValues.length) ? currentValues[i] : 0.08;
      final r = radius * val;
      final angle = startAngle + i * angleStep;
      final pt = Offset(center.dx + r * math.cos(angle), center.dy + r * math.sin(angle));
      curPoints.add(pt);
      if (i == 0) {
        curPath.moveTo(pt.dx, pt.dy);
      } else {
        curPath.lineTo(pt.dx, pt.dy);
      }
    }
    curPath.close();

    final fillPaint = Paint()
      ..color = accentColor.withValues(alpha: 0.22)
      ..style = PaintingStyle.fill;
    final strokePaint = Paint()
      ..color = accentColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.2;
    final nodePaint = Paint()
      ..color = accentColor
      ..style = PaintingStyle.fill;

    canvas.drawPath(curPath, fillPaint);
    canvas.drawPath(curPath, strokePaint);

    for (final pt in curPoints) {
      canvas.drawCircle(pt, 3.5, nodePaint);
    }

    // 5. Labels
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

      // Fine-tune label offset based on vertex position
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
  bool shouldRepaint(covariant _HexagonRadarPainter oldDelegate) =>
      oldDelegate.gc != gc ||
      oldDelegate.accentColor != accentColor ||
      oldDelegate.currentValues != currentValues ||
      oldDelegate.previousValues != previousValues ||
      oldDelegate.labels != labels;
}
