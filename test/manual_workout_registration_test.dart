import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fitiron/l10n/l10n.dart';
import 'package:fitiron/models/exercise.dart';
import 'package:fitiron/models/workout.dart';
import 'package:fitiron/screens/home_screen.dart';
import 'package:fitiron/state/fit_state.dart';
import 'package:fitiron/theme/app_theme.dart';
import 'package:fitiron/widgets/charts.dart';
import 'package:fitiron/widgets/day_summary_sheet.dart';
import 'package:fitiron/widgets/exercise_category_widgets.dart';
import 'package:fitiron/widgets/exercise_picker_sheet.dart';
import 'package:fitiron/widgets/manual_workout_sheet.dart';

void main() {
  setUp(() {
    setAppLanguage('pt');
    fit.sessions.clear();
    fit.routines.clear();
    fit.onboarded = true;
  });

  group('Manual Workout Logging - State', () {
    test('addLoggedSession registers session and updates day summary', () {
      final date = DateTime(2026, 9, 15, 10, 30);
      expect(fit.daySummary(date), isNull);

      final strengthSet = LoggedSet(12, 60.0, rpe: 8.5);
      final cardioSet = LoggedSet(1200, 2.0, sec: 1200, cardioParam: 2.0, speed: 9.5);

      final session = LoggedSession(
        date,
        3600,
        [
          LoggedExercise('bench-press', 'Bench Press', 'chest', [strengthSet]),
          LoggedExercise('treadmill', 'Treadmill Run', 'cardio', [cardioSet]),
        ],
      );

      fit.addLoggedSession(session);

      final summary = fit.daySummary(date);
      expect(summary, isNotNull);
      expect(summary!.exercises, 2);
      expect(summary.sets, 2);
      expect(summary.durationSec, 3600);
      expect(summary.volume, 12 * 60.0); // cardio does not add to weight volume

      final sessions = fit.sessionsOn(date);
      expect(sessions.length, 1);
      expect(sessions.first.exercises.length, 2);

      final loggedCardio = sessions.first.exercises.firstWhere((e) => e.id == 'treadmill');
      expect(loggedCardio.isCardio, isTrue);
      expect(loggedCardio.sets.first.sec, 1200);
      expect(loggedCardio.sets.first.speed, 9.5);
      expect(loggedCardio.sets.first.cardioParam, 2.0);

      final loggedStrength = sessions.first.exercises.firstWhere((e) => e.id == 'bench-press');
      expect(loggedStrength.sets.first.reps, 12);
      expect(loggedStrength.sets.first.weight, 60.0);
      expect(loggedStrength.sets.first.rpe, 8.5);
    });

    test('multiple sessions on same date are sorted and aggregated in daySummary', () {
      final date1 = DateTime(2026, 9, 20, 8, 0);
      final date2 = DateTime(2026, 9, 20, 18, 0);

      final session1 = LoggedSession(
        date1,
        1800,
        [
          LoggedExercise('squat', 'Squat', 'quads', [LoggedSet(10, 80.0)]),
        ],
      );
      final session2 = LoggedSession(
        date2,
        2400,
        [
          LoggedExercise('pullup', 'Pull Up', 'back', [LoggedSet(8, 0.0)]),
        ],
      );

      fit.addLoggedSession(session1);
      fit.addLoggedSession(session2);

      final summary = fit.daySummary(date1);
      expect(summary, isNotNull);
      expect(summary!.exercises, 2);
      expect(summary.sets, 2);
      expect(summary.durationSec, 4200);

      final onDay = fit.sessionsOn(date1);
      expect(onDay.length, 2);
    });
  });

  group('Heatmap Day Click & DaySummarySheet - Widgets', () {
    testWidgets('tapping heatmap square in HomeScreen opens DaySummarySheet', (tester) async {
      await tester.binding.setSurfaceSize(const Size(430, 932));

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.dark,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: const Scaffold(body: HomeScreen()),
        ),
      );
      await tester.pumpAndSettle();

      // Find the Heatmap widget on HomeScreen
      final heatmapFinder = find.byType(Heatmap);
      expect(heatmapFinder, findsOneWidget);

      // Scroll to heatmap
      await tester.scrollUntilVisible(
        heatmapFinder,
        200,
        scrollable: find.byType(Scrollable).first,
      );

      // Tap the last square in the heatmap (today's cell)
      final squares = find.descendant(
        of: heatmapFinder,
        matching: find.byType(GestureDetector),
      );
      expect(squares, findsWidgets);

      await tester.ensureVisible(squares.last);
      await tester.tap(squares.last);
      await tester.pumpAndSettle();

      // Verify that DaySummarySheet is opened
      expect(find.byType(DaySummarySheet), findsOneWidget);
    });

    testWidgets('DaySummarySheet on empty day shows rest day and register button', (tester) async {
      final testDate = DateTime(2026, 9, 10);

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.dark,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(body: DaySummarySheet(date: testDate)),
        ),
      );
      await tester.pumpAndSettle();

      // Should show rest day text and register workout button
      expect(find.text(t.restDay), findsOneWidget);
      expect(find.text(t.registerWorkout.toUpperCase()), findsOneWidget);
    });

    testWidgets('DaySummarySheet with workouts shows stats and exercises', (tester) async {
      final testDate = DateTime(2026, 9, 10, 14, 0);

      fit.addLoggedSession(
        LoggedSession(
          testDate,
          2700,
          [
            LoggedExercise('bench', 'Supino Reto', 'chest', [
              LoggedSet(10, 50.0),
              LoggedSet(10, 60.0),
            ]),
          ],
        ),
      );

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.dark,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(body: DaySummarySheet(date: testDate)),
        ),
      );
      await tester.pumpAndSettle();

      // Should show exercises count, sets count, volume
      expect(find.text(t.restDay), findsNothing);
      expect(find.text('Supino Reto'), findsOneWidget);
      expect(find.text(t.registerWorkout.toUpperCase()), findsOneWidget);
    });

    testWidgets('ManualWorkoutSheet renders date, source selector, and can save workout', (tester) async {
      final testDate = DateTime(2026, 9, 15);

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.dark,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(body: ManualWorkoutSheet(initialDate: testDate)),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(ManualWorkoutSheet), findsOneWidget);
      expect(find.text(t.registerWorkout), findsOneWidget);
      expect(find.text(t.saveWorkout.toUpperCase()), findsOneWidget);
      expect(find.text(t.existingRoutine), findsOneWidget);
      expect(find.text(t.manualExercises), findsOneWidget);
    });

    testWidgets('ManualWorkoutSheet renders routine card for 1 routine and dropdown for multiple routines', (tester) async {
      await tester.binding.setSurfaceSize(const Size(430, 932));

      final benchEx = fit.allExercises.firstWhere((e) => e.primary == 'chest');
      fit.routines.clear();
      fit.routines.add(Routine(
        'routine-test-1',
        'Treino A',
        [benchEx.id],
      ));

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.dark,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(body: ManualWorkoutSheet(initialDate: DateTime(2026, 9, 28))),
        ),
      );
      await tester.pumpAndSettle();

      // With only 1 routine, it should NOT be a DropdownButton
      expect(find.byType(DropdownButton<String>), findsNothing);
      expect(find.text('Treino A'), findsWidgets);

      // Exercise should be present but minimized (sets editor column header # should not be visible)
      expect(find.text('#'), findsNothing);

      // Tap exercise header to expand
      final exerciseCard = find.text(exerciseName(benchEx));
      expect(exerciseCard, findsOneWidget);
      await tester.tap(exerciseCard);
      await tester.pumpAndSettle();

      // Now sets editor should be visible
      expect(find.text('#'), findsOneWidget);

      // Tap again to collapse
      await tester.tap(exerciseCard);
      await tester.pumpAndSettle();
      expect(find.text('#'), findsNothing);

      // Now add a second routine and verify it becomes a DropdownButton
      fit.routines.add(Routine(
        'routine-test-2',
        'Treino B',
        [benchEx.id],
      ));

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.dark,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(body: ManualWorkoutSheet(initialDate: DateTime(2026, 9, 28))),
        ),
      );
      await tester.pumpAndSettle();

      // With > 1 routine, it MUST be a DropdownButton
      expect(find.byType(DropdownButton<String>), findsOneWidget);
    });

    testWidgets('ExercisePickerSheet renders category tabs and search', (tester) async {
      await tester.binding.setSurfaceSize(const Size(430, 932));

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.dark,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: const Scaffold(body: ExercisePickerSheet()),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(ExercisePickerSheet), findsOneWidget);
      expect(find.byType(CategoryTabSelector), findsOneWidget);
      expect(find.text('POR MÚSCULO'), findsOneWidget);
      expect(find.text('EQUIPAMENTOS'), findsOneWidget);
      expect(find.text('FAVORITOS'), findsOneWidget);

      // Tap on EQUIPAMENTOS tab
      await tester.tap(find.text('EQUIPAMENTOS'));
      await tester.pumpAndSettle();
      expect(find.text('BARRAS E PESOS'), findsOneWidget);

      // Tap on FAVORITOS tab
      await tester.tap(find.text('FAVORITOS'));
      await tester.pumpAndSettle();

      // Test searching
      await tester.enterText(find.byType(TextField), 'Supino');
      await tester.pumpAndSettle();
      expect(find.textContaining('Supino'), findsWidgets);
    });
  });
}
