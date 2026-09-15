import '../models/goal.dart';
import '../models/weight_entry.dart';
import '../models/workout.dart';
import 'weight_trend_calculator.dart';

class GoalProgressResult {
  const GoalProgressResult({
    required this.progressRatio,
    required this.currentValue,
    required this.targetValue,
    required this.isCompleted,
    this.hasNoData = false,
    this.etaDate,
  });

  final double progressRatio;
  final double currentValue;
  final double targetValue;
  final bool isCompleted;
  final bool hasNoData;
  final DateTime? etaDate;

  int get progressPercentage => hasNoData ? 0 : (progressRatio * 100).round().clamp(0, 100);
}

class GoalProgressCalculator {
  static GoalProgressResult calculate({
    required Goal goal,
    required Iterable<LoggedSession> currentPeriodSessions,
    required List<WeightEntry> weightEntries,
    double? currentWeightFallback,
  }) {
    switch (goal.type) {
      case GoalType.weeklyFrequency:
      case GoalType.sessionsWeekly:
        final current = currentPeriodSessions.length.toDouble();
        final target = goal.targetValue;
        final ratio = target > 0 ? (current / target).clamp(0.0, 1.0) : 0.0;
        return GoalProgressResult(
          progressRatio: ratio,
          currentValue: current,
          targetValue: target,
          isCompleted: ratio >= 1.0,
          etaDate: null,
        );

      case GoalType.weightTarget:
      case GoalType.bodyweight:
        final eligible = weightEntries
            .where((e) => e.context != WeightContext.postWorkout)
            .toList();
        if (eligible.isEmpty) {
          return GoalProgressResult(
            progressRatio: 0.0,
            currentValue: 0.0,
            targetValue: goal.targetValue,
            isCompleted: false,
            hasNoData: true,
            etaDate: null,
          );
        }

        final trendResult = WeightTrendCalculator.calculate(
          entries: weightEntries,
          goalWeight: goal.targetValue,
        );
        final current = trendResult.currentTrendWeight > 0
            ? trendResult.currentTrendWeight
            : (currentWeightFallback ?? 0.0);
        final target = goal.targetValue;

        double ratio;
        bool isDone;
        if (current <= 0) {
          ratio = 0.0;
          isDone = false;
        } else if (current <= target) {
          ratio = 1.0;
          isDone = true;
        } else {
          ratio = (target / current).clamp(0.0, 1.0);
          isDone = ratio >= 1.0;
        }

        return GoalProgressResult(
          progressRatio: ratio,
          currentValue: current,
          targetValue: target,
          isCompleted: isDone,
          hasNoData: false,
          etaDate: trendResult.goalEtaDate,
        );

      case GoalType.setsWeekly:
        final sets = currentPeriodSessions.fold(0, (a, s) => a + s.setCount).toDouble();
        final target = goal.targetValue;
        final ratio = target > 0 ? (sets / target).clamp(0.0, 1.0) : 0.0;
        return GoalProgressResult(
          progressRatio: ratio,
          currentValue: sets,
          targetValue: target,
          isCompleted: ratio >= 1.0,
        );

      case GoalType.volumeMonthly:
        final volume = currentPeriodSessions.fold(0.0, (a, s) => a + s.volume);
        final target = goal.targetValue;
        final ratio = target > 0 ? (volume / target).clamp(0.0, 1.0) : 0.0;
        return GoalProgressResult(
          progressRatio: ratio,
          currentValue: volume,
          targetValue: target,
          isCompleted: ratio >= 1.0,
        );

      case GoalType.durationMonthly:
        final durHours = currentPeriodSessions.fold(0, (a, s) => a + s.durationSec) / 3600.0;
        final target = goal.targetValue;
        final ratio = target > 0 ? (durHours / target).clamp(0.0, 1.0) : 0.0;
        return GoalProgressResult(
          progressRatio: ratio,
          currentValue: durHours,
          targetValue: target,
          isCompleted: ratio >= 1.0,
        );

      case GoalType.strength:
        final target = goal.targetValue;
        return GoalProgressResult(
          progressRatio: 0.0,
          currentValue: 0.0,
          targetValue: target,
          isCompleted: false,
        );
    }
  }
}
