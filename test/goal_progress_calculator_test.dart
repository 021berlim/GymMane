import 'package:flutter_test/flutter_test.dart';
import 'package:fitiron/models/goal.dart';
import 'package:fitiron/models/weight_entry.dart';
import 'package:fitiron/models/workout.dart';
import 'package:fitiron/services/goal_progress_calculator.dart';
import 'package:fitiron/state/fit_state.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('GoalProgressCalculator', () {
    test('weeklyFrequency counts current week sessions retroactively', () {
      final goal = Goal(
        id: 'g1',
        type: GoalType.weeklyFrequency,
        targetValue: 4,
        pinnedToHome: true,
      );

      final sessions = [
        LoggedSession(DateTime.now(), 1800, []),
        LoggedSession(DateTime.now(), 2000, []),
      ];

      final res = GoalProgressCalculator.calculate(
        goal: goal,
        currentPeriodSessions: sessions,
        weightEntries: [],
      );

      expect(res.currentValue, 2.0);
      expect(res.targetValue, 4.0);
      expect(res.progressRatio, 0.5);
      expect(res.isCompleted, false);
    });

    test('weeklyFrequency marks completed when target is reached', () {
      final goal = Goal(
        id: 'g2',
        type: GoalType.weeklyFrequency,
        targetValue: 3,
      );

      final sessions = [
        LoggedSession(DateTime.now(), 1800, []),
        LoggedSession(DateTime.now(), 2000, []),
        LoggedSession(DateTime.now(), 2200, []),
      ];

      final res = GoalProgressCalculator.calculate(
        goal: goal,
        currentPeriodSessions: sessions,
        weightEntries: [],
      );

      expect(res.currentValue, 3.0);
      expect(res.progressRatio, 1.0);
      expect(res.isCompleted, true);
    });

    test('weightTarget calculates trend and etaDate', () {
      final goal = Goal(
        id: 'gw1',
        type: GoalType.weightTarget,
        targetValue: 70.0,
      );

      final now = DateTime.now();
      final entries = [
        WeightEntry(id: 'w1', timestamp: now.subtract(const Duration(days: 14)), weightKg: 80.0),
        WeightEntry(id: 'w2', timestamp: now.subtract(const Duration(days: 7)), weightKg: 76.0),
        WeightEntry(id: 'w3', timestamp: now, weightKg: 72.0),
      ];

      final res = GoalProgressCalculator.calculate(
        goal: goal,
        currentPeriodSessions: [],
        weightEntries: entries,
      );

      expect(res.targetValue, 70.0);
      expect(res.currentValue, greaterThan(70.0));
      expect(res.progressRatio, greaterThan(0.0));
      expect(res.hasNoData, false);
      expect(res.etaDate, isNotNull);
    });

    test('weightTarget with empty weightEntries returns hasNoData true', () {
      final goal = Goal(
        id: 'gw2',
        type: GoalType.weightTarget,
        targetValue: 72.1,
      );

      final res = GoalProgressCalculator.calculate(
        goal: goal,
        currentPeriodSessions: [],
        weightEntries: [],
      );

      expect(res.hasNoData, true);
      expect(res.progressRatio, 0.0);
      expect(res.progressPercentage, 0);
      expect(res.isCompleted, false);
      expect(res.etaDate, isNull);
    });
  });

  group('FitState Goal Suggestions & Celebrations', () {
    setUp(() {
      fit.goals.clear();
      fit.sessions.clear();
    });

    test('suggestedWeeklyFrequency returns 4-week rounded average', () {
      final now = DateTime.now();
      // Add 8 sessions in last 28 days = 2 workouts/week
      for (int i = 0; i < 8; i++) {
        fit.sessions.add(LoggedSession(now.subtract(Duration(days: i * 3)), 1800, []));
      }

      expect(fit.suggestedWeeklyFrequency, 2);
    });

    test('celebration message is triggered once when goal is hit', () {
      fit.goals.add(Goal(id: 'g_cel', type: GoalType.weeklyFrequency, targetValue: 2, pinnedToHome: true));

      // 1 session -> 1/2, not completed yet
      fit.sessions.add(LoggedSession(DateTime.now(), 1800, []));
      fit.addGoal(GoalType.setsWeekly, 50); // triggers _checkCelebration
      fit.clearCelebrationMessage();

      // 2nd session -> 2/2 completed
      fit.sessions.add(LoggedSession(DateTime.now(), 1800, []));
      fit.addGoal(GoalType.setsWeekly, 60); // triggers _checkCelebration

      final msg1 = fit.consumePendingCelebrationMessage();
      expect(msg1, equals('Meta semanal batida!'));

      // Re-triggering should NOT produce a 2nd notification for the same period
      fit.addGoal(GoalType.setsWeekly, 70);
      final msg2 = fit.consumePendingCelebrationMessage();
      expect(msg2, isNull);
    });
  });
}
