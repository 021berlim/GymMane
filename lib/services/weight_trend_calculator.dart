import 'dart:math' as math;
import '../models/weight_entry.dart';

class TrendPoint {
  TrendPoint({
    required this.timestamp,
    required this.rawKg,
    required this.trendKg,
  });

  final DateTime timestamp;
  final double rawKg;
  final double trendKg;
}

class TrendResult {
  TrendResult({
    required this.trendSeries,
    required this.currentTrendWeight,
    required this.weeklyRateKg,
    this.goalEtaDate,
    required this.isRateAggressive,
  });

  final List<TrendPoint> trendSeries;
  final double currentTrendWeight;
  final double weeklyRateKg;
  final DateTime? goalEtaDate;
  final bool isRateAggressive;
}

class WeightTrendCalculator {
  static const double baseAlpha = 0.12;

  static TrendResult calculate({
    required List<WeightEntry> entries,
    double? goalWeight,
  }) {
    final eligible = entries
        .where((e) => e.context != WeightContext.postWorkout)
        .toList()
      ..sort((a, b) => a.timestamp.compareTo(b.timestamp));

    if (eligible.isEmpty) {
      return TrendResult(
        trendSeries: [],
        currentTrendWeight: 0.0,
        weeklyRateKg: 0.0,
        goalEtaDate: null,
        isRateAggressive: false,
      );
    }

    final trendSeries = <TrendPoint>[];

    double prevTrend = eligible[0].weightKg;
    trendSeries.add(TrendPoint(
      timestamp: eligible[0].timestamp,
      rawKg: eligible[0].weightKg,
      trendKg: prevTrend,
    ));

    for (int i = 1; i < eligible.length; i++) {
      final current = eligible[i];
      final prev = eligible[i - 1];

      final daysGap = current.timestamp.difference(prev.timestamp).inMilliseconds /
          (1000.0 * 3600.0 * 24.0);

      double alphaAdj;
      if (daysGap <= 0) {
        alphaAdj = baseAlpha;
      } else {
        alphaAdj = 1.0 - math.pow(1.0 - baseAlpha, daysGap);
      }

      final trendKg = prevTrend + alphaAdj * (current.weightKg - prevTrend);
      prevTrend = trendKg;

      trendSeries.add(TrendPoint(
        timestamp: current.timestamp,
        rawKg: current.weightKg,
        trendKg: trendKg,
      ));
    }

    final currentTrendWeight = trendSeries.last.trendKg;
    final lastTimestamp = trendSeries.last.timestamp;

    final cutoff = lastTimestamp.subtract(const Duration(days: 28));
    final window = trendSeries.where((p) => !p.timestamp.isBefore(cutoff)).toList();

    double weeklyRateKg = 0.0;
    if (window.length >= 2) {
      final t0 = window.first.timestamp;
      final xValues = window
          .map((p) => p.timestamp.difference(t0).inMilliseconds / (1000.0 * 3600.0 * 24.0))
          .toList();
      final yValues = window.map((p) => p.trendKg).toList();

      final n = window.length;
      final xMean = xValues.reduce((a, b) => a + b) / n;
      final yMean = yValues.reduce((a, b) => a + b) / n;

      double num = 0.0;
      double den = 0.0;
      for (int i = 0; i < n; i++) {
        final dx = xValues[i] - xMean;
        final dy = yValues[i] - yMean;
        num += dx * dy;
        den += dx * dx;
      }

      if (den > 1e-9) {
        final slopePerDay = num / den;
        weeklyRateKg = slopePerDay * 7.0;
      }
    }

    final isRateAggressive = weeklyRateKg.abs() > (currentTrendWeight * 0.01);

    DateTime? goalEtaDate;
    if (goalWeight != null && goalWeight > 0) {
      final diff = goalWeight - currentTrendWeight;
      if (weeklyRateKg.abs() >= 1e-4) {
        final isMovingTowardsGoal = (diff > 0 && weeklyRateKg > 0) || (diff < 0 && weeklyRateKg < 0);
        if (isMovingTowardsGoal) {
          final weeksNeeded = diff / weeklyRateKg;
          final daysNeeded = (weeksNeeded * 7.0).round();
          if (daysNeeded >= 0) {
            goalEtaDate = lastTimestamp.add(Duration(days: daysNeeded));
          }
        }
      }
    }

    return TrendResult(
      trendSeries: trendSeries,
      currentTrendWeight: currentTrendWeight,
      weeklyRateKg: weeklyRateKg,
      goalEtaDate: goalEtaDate,
      isRateAggressive: isRateAggressive,
    );
  }
}
