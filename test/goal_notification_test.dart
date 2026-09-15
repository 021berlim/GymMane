import 'package:flutter_test/flutter_test.dart';
import 'package:fitiron/models/goal.dart';
import 'package:fitiron/state/fit_state.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    fit.goals.clear();
    fit.sessions.clear();
    fit.bodyweight.clear();
  });

  test('adding a weight entry that meets a weight target goal triggers celebration message', () {
    fit.goals.add(Goal(
      id: 'weight_goal_1',
      type: GoalType.weightTarget,
      targetValue: 70.0,
      pinnedToHome: true,
    ));

    // Log a bodyweight meeting target (<= 70 kg)
    fit.addBodyweight(69.5);

    expect(fit.consumePendingCelebrationMessage(), equals('Meta semanal batida!'));
  });

  test('celebratedGoalKeys is serialized in fit.toJson()', () {
    final json = fit.toJson();
    expect(json.containsKey('celebratedGoalKeys'), isTrue);
  });
}
