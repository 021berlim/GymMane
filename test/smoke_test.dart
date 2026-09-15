import 'package:flutter_test/flutter_test.dart';
import 'package:fitiron/app/fitiron_app.dart';
import 'package:fitiron/l10n/l10n.dart';
import 'package:fitiron/models/workout.dart';
import 'package:fitiron/state/fit_state.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    fit.onboarded = true;
    fit.session = null;
    fit.sessions
      ..clear()
      ..add(LoggedSession(DateTime.now(), 1800, [
        LoggedExercise('EIeI8Vf', 'Barbell Bench Press', 'chest', [
          LoggedSet(10, 60),
          LoggedSet(8, 65),
        ]),
      ]));
  });

  Future<void> visit(WidgetTester tester, String route) async {
    fit.route = route;
    await tester.pumpWidget(const FitIronApp());
    await tester.pump(const Duration(milliseconds: 400));
    expect(tester.takeException(), isNull, reason: 'la pantalla $route reventó');
  }

  for (final route in const [
    'home',
    'progress',
    'exercises',
    'settings',
    'routines',
    'tools',
    'train',
    'routine-choice',
    'about',
  ]) {
    testWidgets('$route draws without blowing up', (tester) async {
      await visit(tester, route);
    });
  }

  testWidgets('every tool screen opens', (tester) async {
    for (final id in const ['rm', 'bmi', 'cal', 'bf', 'plate', 'warmup']) {
      fit.activeToolId = id;
      await visit(tester, 'tools-detail');
    }
  });

  testWidgets('the exercise detail opens on a real exercise', (tester) async {
    fit.activeExerciseId = 'EIeI8Vf';
    await visit(tester, 'exercise-detail');
  });

  testWidgets('the app draws in every shipped language', (tester) async {
    final before = fit.language;
    for (final code in appLanguages) {
      fit.setLanguage(code);
      fit.persistNow();
      await visit(tester, 'home');
      await visit(tester, 'progress');
    }
    fit.setLanguage(before);
    fit.persistNow();
  });
}
