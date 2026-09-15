import 'package:flutter_test/flutter_test.dart';
import 'package:fitiron/app/fitiron_app.dart';
import 'package:fitiron/state/fit_state.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    fit.onboarded = true;
    fit.goHome();
  });

  testWidgets('navbar changes active section on route changes and taps', (tester) async {
    await tester.pumpWidget(const FitIronApp());
    await tester.pumpAndSettle();

    expect(fit.route, 'home');

    // Go to progress
    fit.goProgress();
    await tester.pumpAndSettle();
    expect(fit.route, 'progress');

    // Go to exercises
    fit.goExercises();
    await tester.pumpAndSettle();
    expect(fit.route, 'exercises');

    // Go to settings
    fit.goSettings();
    await tester.pumpAndSettle();
    expect(fit.route, 'settings');

    // Go back to home
    fit.goHome();
    await tester.pumpAndSettle();
    expect(fit.route, 'home');
  });
}
