import '../models/exercise.dart';
import '../models/workout.dart';

/// Funções puras para extração de sinais de treino a partir do histórico de sessões.
class ExerciseSignals {
  ExerciseSignals._();

  /// Retorna a última data em que cada grupo muscular foi treinado,
  /// avaliando todas as sessões fornecidas.
  /// A chave de agrupamento é obtida via [muscleGroup(loggedExercise.primary)].
  static Map<String, DateTime> lastTrainedByMuscleGroup(List<LoggedSession> sessions) {
    final Map<String, DateTime> result = {};
    for (final s in sessions) {
      for (final ex in s.exercises) {
        final group = muscleGroup(ex.primary);
        final current = result[group];
        if (current == null || s.date.isAfter(current)) {
          result[group] = s.date;
        }
      }
    }
    return result;
  }

  /// Retorna a contagem de uso de cada [exercise.id] nas últimas [sessionLimit] sessões
  /// (padrão: 14 sessões). Se [maxDays] for informado, também filtra sessões dentro
  /// dessa janela de dias em relação a [now] (padrão 21 dias se não informado ou null para usar apenas sessões).
  static Map<String, int> recentUseCountByExerciseId(
    List<LoggedSession> sessions, {
    int sessionLimit = 14,
    int? maxDays,
    DateTime? now,
  }) {
    if (sessions.isEmpty) return const {};

    final sorted = [...sessions]..sort((a, b) => b.date.compareTo(a.date));

    Iterable<LoggedSession> recent = sorted;
    if (maxDays != null) {
      final cutoff = (now ?? DateTime.now()).subtract(Duration(days: maxDays));
      recent = recent.where((s) => s.date.isAfter(cutoff));
    }
    recent = recent.take(sessionLimit);

    final Map<String, int> counts = {};
    for (final s in recent) {
      for (final ex in s.exercises) {
        counts[ex.id] = (counts[ex.id] ?? 0) + 1;
      }
    }
    return counts;
  }
}
