import 'package:flutter_test/flutter_test.dart';
import 'package:fitiron/app/fitiron_app.dart';
import 'package:fitiron/l10n/l10n.dart';
import 'package:fitiron/models/exercise.dart';
import 'package:fitiron/models/goal.dart';
import 'package:fitiron/state/fit_state.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    setAppLanguage('pt');
    fit.onboarded = true;
    fit.session = null;
    fit.goals.clear();
    fit.goals.add(Goal(id: 'g1', type: GoalType.sessionsWeekly, target: 5, isPrimary: true));
    fit.route = 'home';
    fit.setCatalogExercises([
      const Exercise(
        id: '0001',
        name: 'Barbell Bench Press',
        namePt: 'Supino Reto com Barra',
        primary: 'chest',
        equipment: 'Barbell',
        equipmentPt: 'Barra',
      ),
    ]);
  });

  testWidgets('This Week card renders balanced columns with proper labels without truncation', (tester) async {
    await tester.pumpWidget(const FitIronApp());
    await tester.pump(const Duration(milliseconds: 400));

    expect(find.text('VOLUME'), findsOneWidget);
    expect(find.text('SÉRIES'), findsOneWidget);
    expect(find.text('RECORDES'), findsOneWidget);
    expect(find.text('META'), findsOneWidget);

    // Ensure RECORDES PES... is no longer present
    expect(find.textContaining('RECORDES PES...'), findsNothing);
  });

  testWidgets('Recommended exercise cards render with rounded frame and correct exercise title', (tester) async {
    await tester.pumpWidget(const FitIronApp());
    await tester.pump(const Duration(milliseconds: 400));

    // The recommended section should display Supino Reto com Barra
    expect(find.text('RECOMENDADO'), findsOneWidget);
    expect(find.text('Supino Reto com Barra'), findsOneWidget);
  });
}
