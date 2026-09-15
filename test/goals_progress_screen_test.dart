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
    fit.goals.add(Goal(id: 'g1', type: GoalType.weeklyFrequency, targetValue: 4, pinnedToHome: true));
    fit.route = 'progress';
  });

  testWidgets('Progress screen displays weekly progress card and goals card', (tester) async {
    await tester.pumpWidget(const FitIronApp());
    await tester.pump(const Duration(milliseconds: 400));

    expect(tester.takeException(), isNull);
    expect(find.text('Ofensiva Diária'), findsOneWidget);
    expect(find.text('Sequência Semanal'), findsOneWidget);
    expect(find.text('PROGRESSO SEMANAL'), findsOneWidget);
    expect(find.text('TEMPO'), findsOneWidget);
    expect(find.text('CALORIAS'), findsOneWidget);
    expect(find.text('VOLUME'), findsOneWidget);
    expect(find.text('REPS'), findsOneWidget);
  });
}
