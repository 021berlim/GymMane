import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:fitiron/l10n/l10n.dart';
import 'package:fitiron/screens/train_screen.dart';
import 'package:fitiron/state/fit_state.dart';
import 'package:fitiron/theme/app_theme.dart';
import 'package:fitiron/widgets/exercise_category_widgets.dart';

Widget createTestApp(Widget child) {
  return MaterialApp(
    theme: AppTheme.dark,
    locale: const Locale('pt'),
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    home: Scaffold(body: child),
  );
}

void main() {
  setUp(() {
    setAppLanguage('pt');
    fit.sessions.clear();
    fit.routines.clear();
    fit.sessionPicks.clear();
    fit.selectedMuscles.clear();
    fit.favorites.clear();
    fit.route = 'train';
    fit.trainStep = 'review';
  });

  testWidgets('TrainScreen review step displays search bar and category tabs', (tester) async {
    await tester.pumpWidget(createTestApp(const TrainScreen()));
    await tester.pumpAndSettle();

    // Verify Title and Subtitle
    expect(find.text(t.step2), findsOneWidget);
    expect(find.text(t.buildSession), findsOneWidget);

    // Verify Search hint
    expect(find.text(t.searchAllExercises), findsOneWidget);

    // Verify Tabs
    expect(find.text('POR MÚSCULO'), findsOneWidget);
    expect(find.text('EQUIPAMENTOS'), findsOneWidget);
    expect(find.text('FAVORITOS'), findsOneWidget);

    // By default, Tab 0 (POR MÚSCULO) is active, showing muscle cards
    expect(find.byType(MuscleCategoryCard), findsWidgets);

    // Verify + button for creating custom exercises is NOT present
    expect(find.byIcon(PhosphorIconsRegular.plus), findsNothing);
  });

  testWidgets('Tapping a muscle category opens exercise list and allows picking', (tester) async {
    await tester.pumpWidget(createTestApp(const TrainScreen()));
    await tester.pumpAndSettle();

    // Tap on the first muscle card (e.g. Peito)
    final peitoCard = find.text('Peito');
    expect(peitoCard, findsOneWidget);
    await tester.tap(peitoCard);
    await tester.pumpAndSettle();

    // Category detail header should be visible
    expect(find.text('PEITO'), findsOneWidget);
    expect(find.byType(CategoryTabSelector), findsNothing);

    // Initial picks
    final initialPicks = fit.sessionPicks.length;
    // Tapping exercise card toggles pick
    final supino = find.text('Supino reto com barra');
    expect(supino, findsOneWidget);
    await tester.tap(supino);
    await tester.pumpAndSettle();
    expect(fit.sessionPicks.length, initialPicks + 1);

    // Tapping caret left button returns to tabs
    final backBtn = find.byIcon(PhosphorIconsRegular.caretLeft);
    expect(backBtn, findsOneWidget);
    await tester.tap(backBtn);
    await tester.pumpAndSettle();

    // Tabs should reappear
    expect(find.byType(CategoryTabSelector), findsOneWidget);
    expect(find.text('PEITO'), findsNothing);
  });

  testWidgets('EQUIPAMENTOS tab displays equipment groups and cards', (tester) async {
    await tester.pumpWidget(createTestApp(const TrainScreen()));
    await tester.pumpAndSettle();

    // Tap EQUIPAMENTOS tab
    await tester.tap(find.text('EQUIPAMENTOS'));
    await tester.pumpAndSettle();

    expect(find.text('BARRAS E PESOS'), findsOneWidget);
    expect(find.byType(EquipmentCategoryCard), findsWidgets);
  });

  testWidgets('FAVORITOS tab displays empty message when no favorites, or list when present', (tester) async {
    await tester.pumpWidget(createTestApp(const TrainScreen()));
    await tester.pumpAndSettle();

    // Tap FAVORITOS tab
    await tester.tap(find.text('FAVORITOS'));
    await tester.pumpAndSettle();

    // Initially no favorites
    expect(find.text(t.noExercisesMatch), findsOneWidget);

    // Add a favorite
    final firstEx = fit.allExercises.first;
    fit.favorites[firstEx.id] = true;
    await tester.pumpWidget(createTestApp(const TrainScreen()));
    await tester.pumpAndSettle();

    await tester.tap(find.text('FAVORITOS'));
    await tester.pumpAndSettle();

    expect(find.text(t.noExercisesMatch), findsNothing);
  });

  testWidgets('Searching exercises filters across all exercises', (tester) async {
    await tester.pumpWidget(createTestApp(const TrainScreen()));
    await tester.pumpAndSettle();

    final searchField = find.byType(TextField);
    await tester.enterText(searchField, 'Supino');
    await tester.pumpAndSettle();

    // Tabs should be hidden while searching
    expect(find.byType(CategoryTabSelector), findsNothing);

    // Clear search
    await tester.enterText(searchField, '');
    await tester.pumpAndSettle();

    // Tabs should reappear
    expect(find.byType(CategoryTabSelector), findsOneWidget);
  });
}
