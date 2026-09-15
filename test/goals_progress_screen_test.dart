import 'package:flutter_test/flutter_test.dart';
import 'package:fitiron/app/fitiron_app.dart';
import 'package:fitiron/l10n/l10n.dart';
import 'package:fitiron/models/goal.dart';
import 'package:fitiron/state/fit_state.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    fit.onboarded = true;
    fit.session = null;
    fit.goals.clear();
    fit.goals.add(Goal(id: 'g1', type: GoalType.weeklyFrequency, targetValue: 4, pinnedToHome: true));
    fit.route = 'progress';
  });

  testWidgets('Progress screen displays weekly progress card and goals card', (tester) async {
    await tester.pumpWidget(const FitIronApp());
    await tester.pump(const Duration(milliseconds: 400));

    expect(tester.takeException(), isNull);
    expect(find.text(t.consistency), findsOneWidget);
    expect(find.text(t.volume), findsWidgets);
  });
}
