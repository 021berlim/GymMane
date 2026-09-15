import 'package:flutter_test/flutter_test.dart';
import 'package:fitiron/app/fitiron_app.dart';
import 'package:fitiron/models/goal.dart';
import 'package:fitiron/state/fit_state.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    fit.onboarded = true;
    fit.session = null;
    fit.goals.clear();
    fit.goals.add(Goal(id: 'g1', type: GoalType.sessionsWeekly, target: 4, isPrimary: true));
    fit.route = 'home';
  });

  testWidgets('adding and deleting goals updates HomeScreen automatically', (tester) async {
    await tester.pumpWidget(const FitIronApp());
    await tester.pump(const Duration(milliseconds: 400));

    expect(find.textContaining('4×'), findsOneWidget);

    fit.addGoal(GoalType.setsWeekly, 99);
    fit.setPrimaryGoal(fit.goals.last.id);
    await tester.pump(const Duration(milliseconds: 400));

    expect(find.textContaining('99'), findsOneWidget);

    fit.deleteGoal('g1');
    await tester.pump(const Duration(milliseconds: 400));

    expect(find.textContaining('99'), findsOneWidget);
  });
}
