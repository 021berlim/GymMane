import 'package:fitiron/catalog/exercise_catalog.dart';
import 'package:fitiron/l10n/l10n.dart';
import 'package:fitiron/models/exercise.dart';
import 'package:fitiron/models/workout.dart';
import 'package:fitiron/screens/progress_screen.dart';
import 'package:fitiron/state/fit_state.dart';
import 'package:fitiron/theme/app_theme.dart';
import 'package:fitiron/widgets/body_map.dart';
import 'package:fitiron/widgets/ui_kit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

String idOf(String name) => kExercises.firstWhere((e) => e.name == name).id;

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    fit.sessions.clear();
    setAppLanguage('en');
  });

  group('Muscle Recovery Logic', () {
    test('nothing trained means fully recovered', () {
      expect(fit.overallRecovery(), 100);
      expect(fit.stillRecovering(), isEmpty);
      final r = fit.muscleRecovery();
      for (final m in kMuscles) {
        expect(r[m.id], 1.0);
      }
    });

    test('a hard chest day tires chest and secondary muscles, recovering exponentially', () {
      final now = DateTime(2026, 9, 18, 18);
      fit.sessions.add(LoggedSession(
        now.subtract(const Duration(hours: 1)),
        3600,
        [
          LoggedExercise(
            idOf('Barbell Bench Press'),
            'Bench',
            'chest',
            [for (var i = 0; i < 8; i++) LoggedSet(8, 80, rpe: 9)],
          ),
        ],
      ));

      final fresh = fit.muscleRecovery(now: now);
      expect(fresh['chest'], lessThan(0.3));
      expect(fresh['quads'], 1.0);
      expect(fit.hoursUntilRecovered('chest', now: now), greaterThan(12));
      expect(fit.stillRecovering(now: now), contains('chest'));
      expect(fit.overallRecovery(now: now), lessThan(100));

      final later = fit.muscleRecovery(now: now.add(const Duration(days: 4)));
      expect(later['chest'], greaterThan(0.8));
    });

    test('warmup sets do not cause working fatigue', () {
      final now = DateTime(2026, 9, 18, 18);
      fit.sessions.add(LoggedSession(
        now.subtract(const Duration(hours: 1)),
        1800,
        [
          LoggedExercise(
            idOf('Barbell Full Squat'),
            'Squat',
            'quads',
            [
              LoggedSet(10, 20, kind: SetKind.warmup),
              LoggedSet(10, 40, kind: SetKind.warmup),
            ],
          ),
        ],
      ));

      expect(fit.muscleRecovery(now: now)['quads'], 1.0);
      expect(fit.overallRecovery(now: now), 100);
      expect(fit.stillRecovering(now: now), isEmpty);
    });

    test('failure sets receive higher effort weight than normal sets without RPE', () {
      final now = DateTime(2026, 9, 18, 18);
      final sessionTime = now.subtract(const Duration(hours: 2));

      fit.sessions.add(LoggedSession(
        sessionTime,
        1800,
        [
          LoggedExercise(
            idOf('Barbell Curl'),
            'Curl',
            'biceps',
            [LoggedSet(10, 30, kind: SetKind.normal)],
          ),
        ],
      ));
      final normalFatigue = fit.muscleFatigue(now: now)['biceps']!;

      fit.sessions.clear();
      fit.sessions.add(LoggedSession(
        sessionTime,
        1800,
        [
          LoggedExercise(
            idOf('Barbell Curl'),
            'Curl',
            'biceps',
            [LoggedSet(10, 30, kind: SetKind.failure)],
          ),
        ],
      ));
      final failureFatigue = fit.muscleFatigue(now: now)['biceps']!;

      expect(failureFatigue, greaterThan(normalFatigue));
    });
  });

  group('Muscle Recovery UI in ProgressScreen', () {
    testWidgets('renders recovery tab and toggles between volume map and recovery card', (tester) async {
      tester.view.physicalSize = const Size(1080, 3200);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.dark,
          home: const Scaffold(body: ProgressScreen()),
        ),
      );
      await tester.pumpAndSettle();

      // Find 'Recovery' option in SegToggle
      final recoveryFinder = find.text('Recovery');
      expect(recoveryFinder, findsOneWidget);

      // Initially on 7D: BodyHeatMap should be present
      expect(find.byType(BodyHeatMap), findsOneWidget);
      expect(find.byType(BodyRecoveryMap), findsNothing);

      // Tap on 'Recovery'
      await tester.tap(recoveryFinder);
      await tester.pumpAndSettle();

      // Now BodyRecoveryMap should be present
      expect(find.byType(BodyRecoveryMap), findsOneWidget);
      expect(find.byType(BodyHeatMap), findsNothing);
      expect(find.text('Fatigued'), findsOneWidget);
      expect(find.text('Fresh'), findsOneWidget);
      expect(find.text('Body 100% recovered'), findsOneWidget);
      expect(find.text('Everything is recovered. Good day to train anything.'), findsOneWidget);

      // Tapping back to 7D restores BodyHeatMap
      final muscleMapCard = find.ancestor(of: recoveryFinder, matching: find.byType(SoftCard)).first;
      await tester.tap(find.descendant(of: muscleMapCard, matching: find.text('7D')));
      await tester.pumpAndSettle();
      expect(find.byType(BodyHeatMap), findsOneWidget);
      expect(find.byType(BodyRecoveryMap), findsNothing);
    });

    testWidgets('BodyRecoveryMap standalone widget renders with recovery levels', (tester) async {
      final recovery = {'chest': 0.2, 'quads': 0.8, 'biceps': 1.0};
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.dark,
          home: Scaffold(
            body: SizedBox(
              width: 300,
              child: BodyRecoveryMap(
                recovery: recovery,
                focus: 'chest',
              ),
            ),
          ),
        ),
      );
      expect(find.byType(BodyRecoveryMap), findsOneWidget);
    });

    testWidgets('card maintains exact same height across 7D, 30D, and Recovery modes', (tester) async {
      tester.view.physicalSize = const Size(1080, 3200);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.dark,
          home: const Scaffold(body: ProgressScreen()),
        ),
      );
      await tester.pumpAndSettle();

      final recoveryFinder = find.text('Recovery');
      final muscleMapCard = find.ancestor(of: recoveryFinder, matching: find.byType(SoftCard)).first;

      final height7d = tester.getSize(muscleMapCard).height;

      // Switch to 30D
      await tester.tap(find.descendant(of: muscleMapCard, matching: find.text('30D')));
      await tester.pumpAndSettle();
      final height30d = tester.getSize(muscleMapCard).height;
      expect(height30d, equals(height7d));

      // Switch to Recovery
      await tester.tap(recoveryFinder);
      await tester.pumpAndSettle();
      final heightRecovery = tester.getSize(muscleMapCard).height;
      expect(heightRecovery, equals(height7d));

      // Switch back to 7D
      await tester.tap(find.descendant(of: muscleMapCard, matching: find.text('7D')));
      await tester.pumpAndSettle();
      final height7dBack = tester.getSize(muscleMapCard).height;
      expect(height7dBack, equals(height7d));
    });
  });
}
