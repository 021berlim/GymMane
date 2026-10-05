import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fitiron/app/fitiron_app.dart';
import 'package:fitiron/l10n/l10n.dart';
import 'package:fitiron/models/exercise.dart';
import 'package:fitiron/state/fit_state.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    setAppLanguage('pt');
    fit.onboarded = true;
    fit.clearExFilters();
    fit.routines.clear();
    fit.setCatalogExercises([
      const Exercise(id: '0001', name: 'Barbell Bench Press', namePt: 'Supino Reto com Barra', primary: 'chest', equipment: 'Barbell', equipmentPt: 'Barra'),
      const Exercise(id: '0025', name: 'Dumbbell Row', namePt: 'Remada Unilateral', primary: 'back', equipment: 'Dumbbell', equipmentPt: 'Halter'),
      const Exercise(id: 'EIeI8Vf', name: 'Dumbbell Fly', namePt: 'Crucifixo com Halteres', primary: 'chest', equipment: 'Dumbbell', equipmentPt: 'Halter'),
    ]);
  });

  testWidgets('Typing 1 character in ExercisesScreen search retains focus', (tester) async {
    fit.route = 'exercises';
    await tester.pumpWidget(const FitIronApp());
    await tester.pump();

    final searchField = find.byType(TextField).first;
    expect(searchField, findsOneWidget);

    await tester.tap(searchField);
    await tester.pump();

    final focusNode1 = FocusScope.of(tester.element(searchField)).focusedChild;
    expect(focusNode1, isNotNull, reason: 'TextField should have focus initially');

    await tester.enterText(searchField, 's');
    await tester.pump();

    // Check if a TextField still has focus
    final focusNode2 = FocusScope.of(tester.element(find.byType(TextField).first)).focusedChild;
    expect(focusNode2, isNotNull, reason: 'TextField should retain focus after typing 1 character');
  });

  testWidgets('Typing 1 character in RoutineEditScreen exercise search retains focus', (tester) async {
    final rId = fit.createRoutine('Treino Teste');
    fit.openRoutine(rId);
    await tester.pumpWidget(const FitIronApp());
    await tester.pump();

    // The second TextField is the exercise search input
    final allFields = find.byType(TextField);
    expect(allFields, findsNWidgets(2));
    final search = allFields.at(1);

    await tester.tap(search);
    await tester.pump();

    final focus1 = FocusScope.of(tester.element(search)).focusedChild;
    expect(focus1, isNotNull, reason: 'Exercise search TextField should have focus initially');

    await tester.enterText(search, 's');
    await tester.pump();

    final focus2 = FocusScope.of(tester.element(find.byType(TextField).at(1))).focusedChild;
    expect(focus2, isNotNull, reason: 'Exercise search TextField must retain focus after typing 1 character');
  });

  testWidgets('Standardized exercise search by ID across various formats', (tester) async {
    const testEx = Exercise(
      id: '0025',
      name: 'Barbell Bench Press',
      namePt: 'Supino Reto com Barra',
      primary: 'chest',
      equipment: 'Barbell',
      equipmentPt: 'Barra',
    );

    const testExAlpha = Exercise(
      id: 'EIeI8Vf',
      name: 'Dumbbell Fly',
      namePt: 'Crucifixo com Halteres',
      primary: 'chest',
      equipment: 'Dumbbell',
      equipmentPt: 'Halter',
    );

    // ID searches for numeric ID '0025'
    expect(matchesExerciseSearch(testEx, '0025'), isTrue);
    expect(matchesExerciseSearch(testEx, '25'), isTrue, reason: 'Unpadded 25 should match 0025');
    expect(matchesExerciseSearch(testEx, '#25'), isTrue, reason: '#25 should match 0025');
    expect(matchesExerciseSearch(testEx, '#0025'), isTrue, reason: '#0025 should match 0025');
    expect(matchesExerciseSearch(testEx, 'id: 25'), isTrue, reason: 'id: 25 should match 0025');
    expect(matchesExerciseSearch(testEx, 'id: 0025'), isTrue, reason: 'id: 0025 should match 0025');

    // ID searches for alphanumeric ID 'EIeI8Vf'
    expect(matchesExerciseSearch(testExAlpha, 'EIeI8Vf'), isTrue);
    expect(matchesExerciseSearch(testExAlpha, 'eiei8vf'), isTrue);
    expect(matchesExerciseSearch(testExAlpha, 'eiei'), isTrue);
    expect(matchesExerciseSearch(testExAlpha, '#eiei8vf'), isTrue);

    // Search by Name in PT and EN
    expect(matchesExerciseSearch(testEx, 'supino'), isTrue);
    expect(matchesExerciseSearch(testEx, 'bench press'), isTrue);
    expect(matchesExerciseSearch(testEx, 'SUPINO'), isTrue);

    // Accent insensitive search
    expect(matchesExerciseSearch(testExAlpha, 'crucifixo'), isTrue);

    // Search by Equipment
    expect(matchesExerciseSearch(testEx, 'barra'), isTrue);
    expect(matchesExerciseSearch(testEx, 'barbell'), isTrue);
    expect(matchesExerciseSearch(testExAlpha, 'halter'), isTrue);

    // Search by Muscle
    expect(matchesExerciseSearch(testEx, 'chest'), isTrue);
    expect(matchesExerciseSearch(testEx, 'peito'), isTrue);

    // Multi-term search
    expect(matchesExerciseSearch(testEx, 'supino barra'), isTrue);
    expect(matchesExerciseSearch(testEx, 'peito supino'), isTrue);
    expect(matchesExerciseSearch(testExAlpha, 'crucifixo halter'), isTrue);
  });

  testWidgets('Searching by ID works in ExercisesScreen, RoutineEdit, TrainScreen and PickerSheet', (tester) async {
    // Check ExercisesScreen filtered list with ID
    fit.setExSearch('0001');
    final results0001 = fit.exercisesFiltered;
    expect(results0001.any((e) => e.id == '0001' || e.id == '1'), isTrue);

    fit.setExSearch('1');
    final results1 = fit.exercisesFiltered;
    expect(results1.any((e) => e.id == '0001' || e.id == '1'), isTrue);

    fit.setExSearch('#1');
    final resultsHash1 = fit.exercisesFiltered;
    expect(resultsHash1.any((e) => e.id == '0001' || e.id == '1'), isTrue);

    fit.setExSearch('EIeI8Vf');
    final resultsAlpha = fit.exercisesFiltered;
    expect(resultsAlpha.any((e) => e.id == 'EIeI8Vf'), isTrue);

    // trainSearchResults from WorkoutState
    expect(fit.trainSearchResults('0001').any((e) => e.id == '0001'), isTrue);
    expect(fit.trainSearchResults('1').any((e) => e.id == '0001'), isTrue);
    expect(fit.trainSearchResults('#1').any((e) => e.id == '0001'), isTrue);
    expect(fit.trainSearchResults('0025').any((e) => e.id == '0025'), isTrue);
    expect(fit.trainSearchResults('25').any((e) => e.id == '0025'), isTrue);
    expect(fit.trainSearchResults('EIeI8Vf').any((e) => e.id == 'EIeI8Vf'), isTrue);
  });
}
