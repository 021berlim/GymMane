import 'package:flutter_test/flutter_test.dart';
import 'package:fitiron/catalog/exercise_catalog.dart';
import 'package:fitiron/models/exercise.dart';
import 'package:fitiron/models/profile.dart';
import 'package:fitiron/models/workout.dart';
import 'package:fitiron/services/exercise_signals.dart';
import 'package:fitiron/services/recommendation_service.dart';
import 'package:fitiron/services/local_store.dart';
import 'package:fitiron/services/sqlite_store.dart';
import 'package:fitiron/state/fit_state.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Profile recommendationSeed & Persistence', () {
    test('recommendationSeed is generated once upon creation and non-zero', () {
      final p1 = Profile();
      final p2 = Profile();
      expect(p1.recommendationSeed, isNotNull);
      expect(p1.recommendationSeed, isNonZero);
      // Two newly created profiles should have distinct seeds (randomized)
      expect(p1.recommendationSeed != p2.recommendationSeed, isTrue);
    });

    test('toJson and fromJson preserve the exact recommendationSeed', () {
      final p = Profile(recommendationSeed: 123456789);
      final json = p.toJson();
      expect(json['recommendationSeed'], 123456789);

      final restored = Profile.fromJson(json);
      expect(restored.recommendationSeed, 123456789);
    });

    test('updating profile does not change recommendationSeed', () {
      final p = Profile(name: 'Initial', recommendationSeed: 987654);
      p.name = 'Updated';
      p.trainingFocus = 'forca';
      expect(p.recommendationSeed, 987654);
    });

    test('SqliteStore persists and loads recommendationSeed', () async {
      SharedPreferences.setMockInitialValues({});
      await SqliteStore.instance.init();

      final original = Profile(name: 'StoreUser', recommendationSeed: 445566);
      await SqliteStore.instance.saveFullState({
        'profile': original.toJson(),
      });

      final loaded = await SqliteStore.instance.loadFullState();
      expect(loaded['profile'], isNotNull);
      final restored = Profile.fromJson((loaded['profile'] as Map).cast<String, dynamic>());
      expect(restored.name, 'StoreUser');
      expect(restored.recommendationSeed, 445566);
    });
  });

  group('ExerciseSignals', () {
    test('lastTrainedByMuscleGroup captures the latest date per muscle group', () {
      final now = DateTime(2026, 9, 25, 10, 0);
      final yesterday = now.subtract(const Duration(days: 1));
      final threeDaysAgo = now.subtract(const Duration(days: 3));

      // Barbell Bench Press -> primary is chest -> muscleGroup is 'Chest'
      // Barbell Full Squat -> primary is quads -> muscleGroup is 'Legs'
      final s1 = LoggedSession(
        threeDaysAgo,
        1800,
        [
          LoggedExercise('EIeI8Vf', 'Barbell Bench Press', 'chest', [LoggedSet(10, 80)]),
        ],
      );
      final s2 = LoggedSession(
        yesterday,
        1800,
        [
          LoggedExercise('EIeI8Vf', 'Barbell Bench Press', 'chest', [LoggedSet(10, 85)]),
          LoggedExercise('qXTaZnJ', 'Barbell Full Squat', 'quads', [LoggedSet(8, 100)]),
        ],
      );

      final signals = ExerciseSignals.lastTrainedByMuscleGroup([s1, s2]);
      expect(signals['Chest'], yesterday);
      expect(signals['Legs'], yesterday);
      expect(signals.containsKey('Flexibility'), isFalse);
    });

    test('recentUseCountByExerciseId counts occurrences within last 14 sessions', () {
      final now = DateTime(2026, 9, 25);
      final sessions = List.generate(20, (i) {
        final d = now.subtract(Duration(days: i));
        return LoggedSession(
          d,
          1000,
          [
            LoggedExercise('ex_frequent', 'Frequent Ex', 'chest', [LoggedSet(10, 50)]),
            if (i >= 15) LoggedExercise('ex_old_only', 'Old Ex', 'back', [LoggedSet(10, 50)]),
          ],
        );
      });

      final counts = ExerciseSignals.recentUseCountByExerciseId(sessions, sessionLimit: 14);
      // 'ex_frequent' appeared in all top 14 sessions
      expect(counts['ex_frequent'], 14);
      // 'ex_old_only' only appeared in sessions index 15..19 (beyond 14), so count is 0 / not in map
      expect(counts['ex_old_only'] ?? 0, 0);
    });
  });

  group('RecommendationService QA Criteria', () {
    late Profile baseProfile;
    late List<Exercise> sampleCatalog;

    setUp(() {
      baseProfile = Profile(
        trainingFocus: 'hipertrofia',
        recommendationSeed: 777888,
      );
      sampleCatalog = kExercises;
    });

    test('(a) mesmo usuário + mesmo dia → lista idêntica entre duas chamadas seguidas (determinismo)', () {
      final now = DateTime(2026, 9, 25, 12, 0);
      final lastTrained = <String, DateTime>{
        'Chest': now.subtract(const Duration(days: 2)),
        'Legs': now.subtract(const Duration(days: 5)),
      };
      final recentUse = <String, int>{'EIeI8Vf': 2};
      final favorites = <String, bool>{'qXTaZnJ': true};

      final rec1 = RecommendationService.getRecommendations(
        catalog: sampleCatalog,
        profile: baseProfile,
        lastTrainedByMuscleGroup: lastTrained,
        recentUseCountByExerciseId: recentUse,
        favorites: favorites,
        totalSessions: 15,
        count: 10,
        now: now,
      );

      final rec2 = RecommendationService.getRecommendations(
        catalog: sampleCatalog,
        profile: baseProfile,
        lastTrainedByMuscleGroup: lastTrained,
        recentUseCountByExerciseId: recentUse,
        favorites: favorites,
        totalSessions: 15,
        count: 10,
        now: now,
      );

      expect(rec1.length, 10);
      expect(rec2.length, 10);
      final ids1 = rec1.map((e) => e.id).toList();
      final ids2 = rec2.map((e) => e.id).toList();
      expect(ids1, equals(ids2));
    });

    test('(b) dois recommendationSeed diferentes, mesmo histórico → listas diferentes', () {
      final now = DateTime(2026, 9, 25, 12, 0);
      final p1 = Profile(trainingFocus: 'health', recommendationSeed: 10001);
      final p2 = Profile(trainingFocus: 'health', recommendationSeed: 99999);

      final rec1 = RecommendationService.getRecommendations(
        catalog: sampleCatalog,
        profile: p1,
        lastTrainedByMuscleGroup: const {},
        recentUseCountByExerciseId: const {},
        favorites: const {},
        totalSessions: 5,
        count: 10,
        now: now,
      );

      final rec2 = RecommendationService.getRecommendations(
        catalog: sampleCatalog,
        profile: p2,
        lastTrainedByMuscleGroup: const {},
        recentUseCountByExerciseId: const {},
        favorites: const {},
        totalSessions: 5,
        count: 10,
        now: now,
      );

      final ids1 = rec1.map((e) => e.id).toList();
      final ids2 = rec2.map((e) => e.id).toList();
      expect(ids1, isNot(equals(ids2)));
    });

    test('(c) logar um treino reduz o score do exercício repetido na chamada seguinte', () {
      final now = DateTime(2026, 9, 25, 12, 0);
      final targetExercise = sampleCatalog.firstWhere((e) => e.id == 'EIeI8Vf'); // Bench press (chest)

      // Chamada 1: sem uso recente do exercício
      final scoreBefore = _calculateExerciseScore(
        exercise: targetExercise,
        profile: baseProfile,
        lastTrained: const {},
        recentUse: const {},
        favorites: const {},
        totalSessions: 10,
        now: now,
      );

      // Chamada 2: logou um treino com esse exercício (recentUseCount = 1, e treinado hoje)
      final scoreAfter = _calculateExerciseScore(
        exercise: targetExercise,
        profile: baseProfile,
        lastTrained: {'Chest': now}, // acabou de treinar peito
        recentUse: {targetExercise.id: 1}, // usado 1 vez
        favorites: const {},
        totalSessions: 11,
        now: now,
      );

      expect(scoreAfter, lessThan(scoreBefore));
    });

    test('(d) grupo muscular sem treino há muito tempo sobe no ranking', () {
      final now = DateTime(2026, 9, 25, 12, 0);
      // Exercício de pernas (ex: Squat 'qXTaZnJ', primary 'quads' -> muscleGroup 'Legs')
      final legExercise = sampleCatalog.firstWhere((e) => muscleGroup(e.primary) == 'Legs');

      // Cenário 1: Pernas treinadas hoje (0 dias atrás)
      final scoreTrainedToday = _calculateExerciseScore(
        exercise: legExercise,
        profile: baseProfile,
        lastTrained: {'Legs': now},
        recentUse: const {},
        favorites: const {},
        totalSessions: 10,
        now: now,
      );

      // Cenário 2: Pernas não são treinadas há 14 dias
      final scoreNeglected14Days = _calculateExerciseScore(
        exercise: legExercise,
        profile: baseProfile,
        lastTrained: {'Legs': now.subtract(const Duration(days: 14))},
        recentUse: const {},
        favorites: const {},
        totalSessions: 10,
        now: now,
      );

      // Cenário 3: Pernas nunca treinadas
      final scoreNeverTrained = _calculateExerciseScore(
        exercise: legExercise,
        profile: baseProfile,
        lastTrained: const {},
        recentUse: const {},
        favorites: const {},
        totalSessions: 10,
        now: now,
      );

      expect(scoreNeglected14Days, greaterThan(scoreTrainedToday));
      expect(scoreNeverTrained, greaterThan(scoreTrainedToday));
      expect(scoreNeverTrained, closeTo(scoreNeglected14Days, 0.001));
    });

    test('(e) resultado nunca contém IDs fora do catálogo', () {
      final allowedCatalog = sampleCatalog.take(20).toList();
      final allowedIds = allowedCatalog.map((e) => e.id).toSet();

      final recs = RecommendationService.getRecommendations(
        catalog: allowedCatalog,
        profile: baseProfile,
        lastTrainedByMuscleGroup: const {},
        recentUseCountByExerciseId: const {},
        favorites: const {},
        totalSessions: 5,
        count: 10,
      );

      expect(recs.isNotEmpty, isTrue);
      for (final ex in recs) {
        expect(allowedIds.contains(ex.id), isTrue,
            reason: 'Exercise ${ex.id} (${ex.name}) must be in provided catalog');
      }
    });
  });

  group('Scoring Rules Detail Tests', () {
    test('focusScore for forca requires Intermediate or Advanced for 1.0', () {
      final beginnerPush = Exercise(
        id: 'ex1',
        name: 'Beg Push',
        primary: 'chest',
        equipment: 'Barbell',
        difficulty: 'Beginner',
      );
      final advPush = Exercise(
        id: 'ex2',
        name: 'Adv Push',
        primary: 'chest',
        equipment: 'Barbell',
        difficulty: 'Advanced',
      );

      expect(RecommendationService.calculateFocusScore(beginnerPush, 'forca'), 0.5);
      expect(RecommendationService.calculateFocusScore(advPush, 'forca'), 1.0);
    });

    test('focusScore for emagrecimento awards Bodyweight or cardio 1.0', () {
      final bwEx = Exercise(id: 'e1', name: 'BW', primary: 'chest', equipment: 'Bodyweight');
      final cardioEx = Exercise(id: 'e2', name: 'Run', primary: 'cardio', equipment: 'Other');
      final kbEx = Exercise(id: 'e3', name: 'KB', primary: 'legs', equipment: 'Kettlebell');
      final barbEx = Exercise(id: 'e4', name: 'Barb', primary: 'chest', equipment: 'Barbell');

      expect(RecommendationService.calculateFocusScore(bwEx, 'emagrecimento'), 1.0);
      expect(RecommendationService.calculateFocusScore(cardioEx, 'emagrecimento'), 1.0);
      expect(RecommendationService.calculateFocusScore(kbEx, 'emagrecimento'), 0.6);
      expect(RecommendationService.calculateFocusScore(barbEx, 'emagrecimento'), 0.2);
    });

    test('levelScore tests for user levels Beginner (<8), Intermediate (<30), Advanced (30+)', () {
      final begEx = Exercise(id: 'e1', name: 'B', difficulty: 'Beginner');
      final intEx = Exercise(id: 'e2', name: 'I', difficulty: 'Intermediate');
      final advEx = Exercise(id: 'e3', name: 'A', difficulty: 'Advanced');

      // User with 5 sessions -> Beginner
      expect(RecommendationService.calculateLevelScore(begEx, 5), 1.0);
      expect(RecommendationService.calculateLevelScore(intEx, 5), 0.5);
      expect(RecommendationService.calculateLevelScore(advEx, 5), 0.15);

      // User with 20 sessions -> Intermediate
      expect(RecommendationService.calculateLevelScore(begEx, 20), 0.5);
      expect(RecommendationService.calculateLevelScore(intEx, 20), 1.0);
      expect(RecommendationService.calculateLevelScore(advEx, 20), 0.5);

      // User with 40 sessions -> Advanced
      expect(RecommendationService.calculateLevelScore(begEx, 40), 0.15);
      expect(RecommendationService.calculateLevelScore(intEx, 40), 0.5);
      expect(RecommendationService.calculateLevelScore(advEx, 40), 1.0);
    });

    test('calculateJitter is strictly within [0, 1) and deterministic', () {
      final j1 = RecommendationService.calculateJitter(12345, 150, 'my-ex'.hashCode);
      final j2 = RecommendationService.calculateJitter(12345, 150, 'my-ex'.hashCode);
      expect(j1, equals(j2));
      expect(j1, greaterThanOrEqualTo(0.0));
      expect(j1, lessThan(1.0));
    });
  });

  group('LibraryState focusRecommendations Integration', () {
    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      await Store.instance.init();
      fit.loadFromStore();
    });

    test('focusRecommendations returns a non-empty list of exercises from allExercises', () {
      final recs = fit.focusRecommendations;
      expect(recs.isNotEmpty, isTrue);
      expect(recs.length, lessThanOrEqualTo(10));
      final allIds = fit.allExercises.map((e) => e.id).toSet();
      for (final r in recs) {
        expect(allIds.contains(r.id), isTrue);
      }
    });
  });
}

double _calculateExerciseScore({
  required Exercise exercise,
  required Profile profile,
  required Map<String, DateTime> lastTrained,
  required Map<String, int> recentUse,
  required Map<String, bool> favorites,
  required int totalSessions,
  required DateTime now,
}) {
  final day = RecommendationService.dayOfYear(now);
  final fScore = RecommendationService.calculateFocusScore(exercise, profile.trainingFocus);
  final bScore = RecommendationService.calculateBalanceScore(exercise, lastTrained, now);
  final nScore = RecommendationService.calculateNoveltyScore(exercise, recentUse);
  final favScore = RecommendationService.calculateFavoriteScore(exercise, favorites);
  final lScore = RecommendationService.calculateLevelScore(exercise, totalSessions);
  final jScore = RecommendationService.calculateJitter(profile.recommendationSeed, day, exercise.id.hashCode);

  return (0.30 * fScore) +
      (0.25 * bScore) +
      (0.15 * nScore) +
      (0.10 * favScore) +
      (0.10 * lScore) +
      (0.10 * jScore);
}
