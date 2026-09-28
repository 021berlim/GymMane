import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fitiron/app/fitiron_app.dart';
import 'package:fitiron/models/live_session.dart';
import 'package:fitiron/state/fit_state.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    fit.onboarded = true;
    fit.bodyweightStartPromptShown = true;
    fit.session = null;
  });

  tearDown(() {
    fit.skipRest();
    fit.saveAndExit();
  });

  testWidgets('ProgressCompleteButton displays idle CTA, animates progress bar on tap, and concludes set', (tester) async {
    await tester.binding.setSurfaceSize(const Size(430, 932));

    // Create an active workout session with 2 sets
    final s = WorkoutSession()
      ..exercises = [
        SessionExercise('bench-press', 'Supino Reto', 'chest', [
          SessionSet(10, 60, false),
          SessionSet(10, 60, false),
        ]),
      ]
      ..complete = false;
    fit.session = s;
    fit.route = 'session';

    await tester.pumpWidget(const FitIronApp());
    await tester.pumpAndSettle();

    // 1. Initial State: "CONCLUIR SÉRIE 1" button is present and idle
    final completeBtn = find.text('CONCLUIR SÉRIE 1');
    expect(completeBtn, findsOneWidget);
    expect(fit.session!.exercises[0].sets[0].done, isFalse);

    // 2. Tap down to initiate progress animation
    await tester.tap(completeBtn);
    // Settle to let the 380ms progress animation finish and trigger onComplete
    await tester.pumpAndSettle();

    // 3. Set 1 is now completed!
    expect(fit.session!.exercises[0].sets[0].done, isTrue);

    // 4. Since set 1 was completed and set 2 exists, it automatically advanced to set 2:
    expect(find.text('CONCLUIR SÉRIE 2'), findsOneWidget);
    expect(fit.session!.exercises[0].sets[1].done, isFalse);

    // 5. Complete set 2
    await tester.tap(find.text('CONCLUIR SÉRIE 2'));
    await tester.pumpAndSettle();

    // Set 2 is now completed!
    expect(fit.session!.exercises[0].sets[1].done, isTrue);

    // Allow auto-finish delayed timer to complete
    await tester.pump(const Duration(seconds: 2));
  });

  testWidgets('ProgressCompleteButton reverses and does not complete when gesture is cancelled', (tester) async {
    await tester.binding.setSurfaceSize(const Size(430, 932));

    final s = WorkoutSession()
      ..exercises = [
        SessionExercise('bench-press', 'Supino Reto', 'chest', [
          SessionSet(10, 60, false),
        ]),
      ]
      ..complete = false;
    fit.session = s;
    fit.route = 'session';

    await tester.pumpWidget(const FitIronApp());
    await tester.pumpAndSettle();

    final completeBtn = find.text('CONCLUIR SÉRIE 1');
    expect(completeBtn, findsOneWidget);

    // Start a gesture (press down)
    final gesture = await tester.startGesture(tester.getCenter(completeBtn));
    // Pump 150ms (partial progress)
    await tester.pump(const Duration(milliseconds: 150));
    expect(fit.session!.exercises[0].sets[0].done, isFalse);

    // Cancel gesture (drag off / cancel)
    await gesture.cancel();
    await tester.pumpAndSettle();

    // Set was NOT completed because gesture was cancelled
    expect(fit.session!.exercises[0].sets[0].done, isFalse);
    expect(find.text('CONCLUIR SÉRIE 1'), findsOneWidget);
  });
}
