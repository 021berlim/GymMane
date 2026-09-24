import 'package:flutter_test/flutter_test.dart';
import 'package:fitiron/l10n/l10n.dart';
import 'package:fitiron/services/sqlite_store.dart';
import 'package:fitiron/state/fit_state.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    await SqliteStore.instance.close();
    await SqliteStore.instance.init();
    fit.resetAllData();
  });

  tearDown(() async {
    await SqliteStore.instance.close();
  });

  test('resets and seeds 1394 exercises in SQLite and synchronizes FitState', () async {
    // 1. Force reseed/reset catalog in SQLite
    await SqliteStore.instance.syncExercises(force: true);

    // 2. Verify all 1,394 exercises are populated
    expect(fit.catalogExercises.length, 1394);
    expect(fit.allExercises.length, greaterThanOrEqualTo(1394));

    // 3. Verify lookup by new PK (ID)
    final ex0001 = fit.exerciseById('0001');
    expect(ex0001, isNotNull);
    expect(ex0001!.name, isNotEmpty);
    expect(ex0001.namePt, isNotEmpty);
    expect(ex0001.instructionsPt, isNotEmpty);
    expect(ex0001.gifPath, 'assets/exercises/0001.gif');

    // 4. Verify PT-BR localization helper
    setAppLanguage('pt');
    expect(ex0001.getLocalizedName(), ex0001.namePt);
    expect(ex0001.getLocalizedInstructions(), ex0001.instructionsPt);

    // 5. Verify backwards compatibility for legacy IDs
    final legacyEx = fit.exerciseById('EIeI8Vf');
    expect(legacyEx, isNotNull);
    expect(legacyEx!.name, 'Barbell Bench Press');

    // 6. Verify intelligent search by ID prefix
    fit.setExSearch('0001');
    expect(fit.exercisesFiltered.any((e) => e.id == '0001'), isTrue);

    // 7. Verify search accent insensitivity and case insensitivity
    fit.setExSearch('triceps');
    final countWithoutAccent = fit.exercisesFiltered.length;
    fit.setExSearch('Tríceps');
    final countWithAccent = fit.exercisesFiltered.length;
    expect(countWithoutAccent, greaterThan(0));
    expect(countWithoutAccent, equals(countWithAccent));

    // 8. Verify cross-lingual search (English and Portuguese)
    fit.setExSearch('bench press');
    final enCount = fit.exercisesFiltered.length;
    expect(enCount, greaterThan(0));

    fit.setExSearch('supino');
    final ptCount = fit.exercisesFiltered.length;
    expect(ptCount, greaterThan(0));
  });
}
