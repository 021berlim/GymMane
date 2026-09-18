import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gymmane/app/gymmane_app.dart';
import 'package:gymmane/state/fit_state.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';

void main() {
  testWidgets('TrainScreen step 2 displays reset picks button and toggles selection', (tester) async {
    fit.onboarded = true;
    fit.selectedMuscles.clear();
    fit.selectedMuscles.addAll(['chest', 'triceps']);
    fit.trainContinue();
    fit.route = 'train';

    await tester.pumpWidget(const GymManeApp());
    await tester.pumpAndSettle();

    final iconFinder = find.byIcon(PhosphorIconsRegular.arrowCounterClockwise);
    expect(iconFinder, findsOneWidget);
    final initialIcon = tester.widget<Icon>(iconFinder);

    // Verify Plus button icon is present
    expect(find.byIcon(PhosphorIconsRegular.plus), findsOneWidget);

    // Verify picks initially non-empty
    expect(fit.sessionPicks.isNotEmpty, true);

    // Tap reset button -> clears picks, button becomes dimmed
    await tester.tap(iconFinder);
    await tester.pumpAndSettle();
    expect(fit.sessionPicks.isEmpty, true);
    final clearedIcon = tester.widget<Icon>(iconFinder);
    expect(clearedIcon.color != initialIcon.color, true);

    // Tap reset button again -> restores default picks, button lights up again
    await tester.tap(iconFinder);
    await tester.pumpAndSettle();
    expect(fit.sessionPicks.isNotEmpty, true);
    final restoredIcon = tester.widget<Icon>(iconFinder);
    expect(restoredIcon.color == initialIcon.color, true);

    fit.route = 'home';
  });
}
