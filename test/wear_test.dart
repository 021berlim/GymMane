import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gymmane/l10n/l10n.dart';
import 'package:gymmane/state/fit_state.dart';
import 'package:gymmane/wear/wear_app.dart';

void _reset() {
  fit.saveAndExit();
  fit.sessions.clear();
  fit.routines.clear();
  fit.weeklyPlan.clear();
}

Future<void> _pump(WidgetTester tester) async {
  tester.view.physicalSize = const Size(454, 454);
  tester.view.devicePixelRatio = 2;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(const WearApp());
  await tester.pump();
}

Future<void> _reveal(WidgetTester tester, Finder finder, {double delta = 40}) async {
  await tester.scrollUntilVisible(finder, delta, scrollable: find.byType(Scrollable).last);
  await tester.pump();
}

void main() {
  setUp(_reset);
  tearDown(_reset);

  testWidgets('the watch home offers to start and to browse routines', (tester) async {
    await _pump(tester);
    expect(tester.takeException(), isNull);
    expect(find.text(t.startWorkout), findsOneWidget);

    await _reveal(tester, find.text(t.routines));
    await tester.tap(find.text(t.routines));
    await tester.pumpAndSettle();
    expect(fit.route, 'routines');
    expect(find.text(t.templates), findsOneWidget);

    await tester.tap(find.text('Push Pull Legs'));
    await tester.pumpAndSettle();
    expect(fit.routines, isNotEmpty);
    expect(find.text(t.templates), findsNothing);
  });

  testWidgets('a routine runs on the wrist: sets, rest and finish', (tester) async {
    final id = fit.createRoutine('Push');
    fit.toggleRoutineExercise(id, 'EIeI8Vf');
    await _pump(tester);

    await _reveal(tester, find.text(t.routines));
    await tester.tap(find.text(t.routines));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Push'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
    await tester.pump();
    expect(fit.route, 'session');
    expect(find.byType(Scrollable), findsOneWidget);
    expect(fit.session, isNotNull);
    expect(tester.takeException(), isNull);

    await _reveal(tester, find.text(t.setDone));
    await tester.tap(find.text(t.setDone));
    await tester.pump();
    expect(fit.session!.exercises.first.sets.first.done, isTrue);
    expect(fit.session!.restRemaining, isNotNull);
    await _reveal(tester, find.text(t.rest), delta: -40);
    expect(find.text(t.rest), findsOneWidget);

    await tester.tap(find.text(t.skip));
    await tester.pump();
    expect(fit.session!.restRemaining, isNull);

    await _reveal(tester, find.text(t.finishSession));
    await tester.tap(find.text(t.finishSession));
    await tester.pump();
    expect(fit.isSessionComplete, isTrue);

    await _reveal(tester, find.text(t.saveAndExit));
    await tester.tap(find.text(t.saveAndExit));
    await tester.pump();
    expect(fit.session, isNull);
    expect(fit.sessions.length, 1);
    expect(tester.takeException(), isNull);
  });

  testWidgets('backing out parks the workout and home offers to continue', (tester) async {
    final id = fit.createRoutine('Legs');
    fit.toggleRoutineExercise(id, 'EIeI8Vf');
    fit.startRoutine(fit.routines.first);
    await _pump(tester);
    expect(fit.route, 'session');

    fit.parkSession();
    await tester.pumpAndSettle();
    expect(fit.route, 'home');
    expect(fit.session, isNotNull);
    expect(find.text(t.continueBtn), findsOneWidget);

    await tester.tap(find.text(t.continueBtn));
    await tester.pumpAndSettle();
    expect(fit.route, 'session');
    fit.saveAndExit();
  });
}
