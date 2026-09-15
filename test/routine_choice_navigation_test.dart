import 'package:flutter_test/flutter_test.dart';
import 'package:fitiron/app/fitiron_app.dart';
import 'package:fitiron/l10n/l10n.dart';
import 'package:fitiron/state/fit_state.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    fit.onboarded = true;
    fit.session = null;
    fit.routines.clear();
    fit.route = 'home';
  });

  testWidgets('startWorkout with multiple routines opens routine choice section in AppShell', (tester) async {
    final r1 = fit.createRoutine('Routine A');
    fit.toggleRoutineExercise(r1, 'EIeI8Vf');
    final r2 = fit.createRoutine('Routine B');
    fit.toggleRoutineExercise(r2, 'EIeI8Vf');

    expect(fit.routines.length, 2);

    fit.startWorkout();
    expect(fit.route, 'routine-choice');

    await tester.pumpWidget(const FitIronApp());
    await tester.pump(const Duration(milliseconds: 400));

    expect(tester.takeException(), isNull);
    expect(find.text(t.chooseRoutineTitle), findsWidgets);
  });
}
