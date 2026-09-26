import '../models/exercise.dart';
import '../models/profile.dart';

/// Serviço responsável pelo algoritmo de recomendação de exercícios dinâmico.
class RecommendationService {
  RecommendationService._();

  /// Retorna as recomendações personalizadas baseadas em pontuação dinâmica.
  static List<Exercise> getRecommendations({
    required List<Exercise> catalog,
    required Profile profile,
    required Map<String, DateTime> lastTrainedByMuscleGroup,
    required Map<String, int> recentUseCountByExerciseId,
    required Map<String, bool> favorites,
    required int totalSessions,
    int count = 10,
    DateTime? now,
  }) {
    if (catalog.isEmpty || count <= 0) return const [];

    final refDate = now ?? DateTime.now();
    final day = dayOfYear(refDate);

    // Garante que só operamos em exercícios únicos pertencentes ao catálogo
    final seen = <String>{};
    final uniqueCatalog = <Exercise>[];
    for (final e in catalog) {
      if (seen.add(e.id)) {
        uniqueCatalog.add(e);
      }
    }

    final scored = uniqueCatalog.map((ex) {
      final fScore = calculateFocusScore(ex, profile.trainingFocus);
      final bScore = calculateBalanceScore(ex, lastTrainedByMuscleGroup, refDate);
      final nScore = calculateNoveltyScore(ex, recentUseCountByExerciseId);
      final favScore = calculateFavoriteScore(ex, favorites);
      final lScore = calculateLevelScore(ex, totalSessions);
      final jScore = calculateJitter(profile.recommendationSeed, day, ex.id.hashCode);

      final totalScore = (0.30 * fScore) +
          (0.25 * bScore) +
          (0.15 * nScore) +
          (0.10 * favScore) +
          (0.10 * lScore) +
          (0.10 * jScore);

      return (exercise: ex, score: totalScore);
    }).toList();

    scored.sort((a, b) {
      final cmp = b.score.compareTo(a.score);
      if (cmp != 0) return cmp;
      return a.exercise.id.compareTo(b.exercise.id);
    });

    return scored.take(count).map((item) => item.exercise).toList();
  }

  /// Calcula o score de foco baseado no grupo muscular e equipamento.
  static double calculateFocusScore(Exercise exercise, String trainingFocus) {
    final family = muscleFamily(exercise.primary);
    final equip = exercise.equipment;
    final diff = exercise.difficulty;
    final prim = exercise.primary;
    final focus = trainingFocus.trim().toLowerCase();

    switch (focus) {
      case 'hipertrofia':
        if (family == 'push' || family == 'pull' || family == 'legs') {
          if (equip == 'Bodyweight' || equip == 'Band') {
            return 0.5;
          }
          return 1.0;
        }
        return 0.1;

      case 'forca':
        if (family == 'push' || family == 'pull' || family == 'legs') {
          if (equip == 'Bodyweight' || equip == 'Band') {
            return 0.5;
          }
          if (diff == 'Intermediate' || diff == 'Advanced') {
            return 1.0;
          }
          return 0.5;
        }
        return 0.1;

      case 'emagrecimento':
        if (equip == 'Bodyweight' || prim == 'cardio' || prim == 'warmup') {
          return 1.0;
        }
        if (equip == 'Band' || equip == 'Kettlebell') {
          return 0.6;
        }
        return 0.2;

      case 'resistencia':
        if (prim == 'cardio') {
          return 1.0;
        }
        if (equip == 'Bodyweight' && (family == 'legs' || family == 'core')) {
          return 0.7;
        }
        return 0.3;

      case 'health':
      default:
        double score = 0.0;
        if (diff == 'Beginner') score += 0.6;
        if (prim == 'warmup' || prim == 'cardio') score += 0.4;
        if (family == 'core') score += 0.2;
        return score.clamp(0.0, 1.0);
    }
  }

  /// Calcula o score de equilíbrio muscular (dias sem treinar aquele grupo).
  static double calculateBalanceScore(
    Exercise exercise,
    Map<String, DateTime> lastTrainedByMuscleGroup,
    DateTime now,
  ) {
    final group = muscleGroup(exercise.primary);
    final lastTrained = lastTrainedByMuscleGroup[group];
    if (lastTrained == null) {
      // Nunca treinado = valor máximo
      return 1.0;
    }
    final diffSec = now.difference(lastTrained).inSeconds;
    if (diffSec <= 0) return 0.0;
    final days = diffSec / 86400.0;
    return (days / 14.0).clamp(0.0, 1.0);
  }

  /// Calcula o score de novidade (inversamente proporcional ao uso recente).
  static double calculateNoveltyScore(
    Exercise exercise,
    Map<String, int> recentUseCountByExerciseId,
  ) {
    final count = recentUseCountByExerciseId[exercise.id] ?? 0;
    return 1.0 / (1.0 + count);
  }

  /// Calcula o score de favorito.
  static double calculateFavoriteScore(
    Exercise exercise,
    Map<String, bool> favorites,
  ) {
    return (favorites[exercise.id] == true) ? 1.0 : 0.0;
  }

  /// Calcula o score de adequação de nível/dificuldade do exercício.
  static double calculateLevelScore(
    Exercise exercise,
    int totalSessions,
  ) {
    final int userLevel;
    if (totalSessions < 8) {
      userLevel = 0; // Beginner
    } else if (totalSessions < 30) {
      userLevel = 1; // Intermediate
    } else {
      userLevel = 2; // Advanced
    }

    final int exerciseLevel;
    final d = exercise.difficulty.trim().toLowerCase();
    if (d == 'advanced') {
      exerciseLevel = 2;
    } else if (d == 'intermediate') {
      exerciseLevel = 1;
    } else {
      exerciseLevel = 0;
    }

    final diff = (userLevel - exerciseLevel).abs();
    if (diff == 0) return 1.0;
    if (diff == 1) return 0.5;
    return 0.15;
  }

  /// Hash determinístico puro de (seed, dia-do-ano, exercise.id.hashCode) normalizado em [0, 1).
  static double calculateJitter(int seed, int dayOfYear, int idHash) {
    int h = seed ^ (dayOfYear * 0x27d4eb2d) ^ (idHash * 0x165667b1);
    h = ((h ^ (h >> 16)) * 0x45d9f3b) & 0x7fffffff;
    h = ((h ^ (h >> 16)) * 0x45d9f3b) & 0x7fffffff;
    h = (h ^ (h >> 16)) & 0x7fffffff;
    return h / 0x80000000;
  }

  /// Retorna o dia do ano (1..366) para uma determinada data.
  static int dayOfYear(DateTime date) {
    return date.difference(DateTime(date.year, 1, 1)).inDays + 1;
  }
}
