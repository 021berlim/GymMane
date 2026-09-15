import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../l10n/l10n.dart';
import '../models/goal.dart';
import '../services/goal_progress_calculator.dart';
import '../theme/app_colors.dart';
import '../theme/app_theme.dart';

/// Reusable circular progress ring widget displaying a fraction (e.g., "2/4") in the center.
class GoalProgressRing extends StatelessWidget {
  const GoalProgressRing({
    super.key,
    required this.progressRatio,
    required this.currentValue,
    required this.targetValue,
    this.size = 48,
    this.strokeWidth = 5,
  });

  final double progressRatio;
  final double currentValue;
  final double targetValue;
  final double size;
  final double strokeWidth;

  @override
  Widget build(BuildContext context) {
    final gc = context.gc;
    final text = '${currentValue.round()}/${targetValue.round()}';

    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _GoalRingPainter(
          pct: progressRatio.clamp(0.0, 1.0),
          trackColor: gc.bgRaised2,
          accentColor: gc.accent,
          strokeWidth: strokeWidth,
        ),
        child: Center(
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Padding(
              padding: const EdgeInsets.all(4.0),
              child: Text(
                text,
                style: AppTheme.d(12, weight: FontWeight.w700, color: gc.text),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _GoalRingPainter extends CustomPainter {
  _GoalRingPainter({
    required this.pct,
    required this.trackColor,
    required this.accentColor,
    required this.strokeWidth,
  });

  final double pct;
  final Color trackColor;
  final Color accentColor;
  final double strokeWidth;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (math.min(size.width, size.height) - strokeWidth) / 2;

    final trackPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..color = trackColor;
    canvas.drawCircle(center, radius, trackPaint);

    if (pct > 0) {
      final accentPaint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.round
        ..color = accentColor;
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        -math.pi / 2,
        pct * 2 * math.pi,
        false,
        accentPaint,
      );
    }
  }

  @override
  bool shouldRepaint(_GoalRingPainter oldDelegate) =>
      oldDelegate.pct != pct ||
      oldDelegate.trackColor != trackColor ||
      oldDelegate.accentColor != accentColor ||
      oldDelegate.strokeWidth != strokeWidth;
}

/// Reusable linear progress bar widget for weight target goals showing % and etaDate.
class GoalProgressBar extends StatelessWidget {
  const GoalProgressBar({
    super.key,
    required this.progressRatio,
    required this.currentValue,
    required this.targetValue,
    this.hasNoData = false,
    this.etaDate,
  });

  final double progressRatio;
  final double currentValue;
  final double targetValue;
  final bool hasNoData;
  final DateTime? etaDate;

  @override
  Widget build(BuildContext context) {
    final gc = context.gc;
    final pctInt = (progressRatio * 100).round().clamp(0, 100);

    String? etaLabel;
    if (!hasNoData && etaDate != null) {
      etaLabel = 'Meta em ~${t.shortDate(etaDate!)}';
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (hasNoData)
          Text(
            t.logWeightToTrack,
            style: AppTheme.s(11, color: gc.textSecondary, weight: FontWeight.w500),
          )
        else
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '$pctInt%',
                style: AppTheme.d(13, weight: FontWeight.w700, color: gc.accent),
              ),
              if (etaLabel != null)
                Text(
                  etaLabel,
                  style: AppTheme.s(11, color: gc.textSecondary, weight: FontWeight.w500),
                ),
            ],
          ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: Container(
            height: 6,
            width: double.infinity,
            color: gc.bgRaised2,
            child: FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: hasNoData ? 0.0 : progressRatio.clamp(0.0, 1.0),
              child: Container(color: gc.accent),
            ),
          ),
        ),
      ],
    );
  }
}

/// Unified progress widget that routes to GoalProgressRing or GoalProgressBar based on Goal type.
class GoalProgressWidget extends StatelessWidget {
  const GoalProgressWidget({
    super.key,
    required this.goal,
    required this.result,
    this.ringSize = 44,
  });

  final Goal goal;
  final GoalProgressResult result;
  final double ringSize;

  @override
  Widget build(BuildContext context) {
    switch (goal.type) {
      case GoalType.weeklyFrequency:
      case GoalType.sessionsWeekly:
        return GoalProgressRing(
          progressRatio: result.progressRatio,
          currentValue: result.currentValue,
          targetValue: result.targetValue,
          size: ringSize,
        );
      case GoalType.weightTarget:
      case GoalType.bodyweight:
        return SizedBox(
          width: 80,
          child: GoalProgressBar(
            progressRatio: result.progressRatio,
            currentValue: result.currentValue,
            targetValue: result.targetValue,
            hasNoData: result.hasNoData,
            etaDate: result.etaDate,
          ),
        );
      default:
        return SizedBox(
          width: 80,
          child: GoalProgressBar(
            progressRatio: result.progressRatio,
            currentValue: result.currentValue,
            targetValue: result.targetValue,
            hasNoData: result.hasNoData,
          ),
        );
    }
  }
}
