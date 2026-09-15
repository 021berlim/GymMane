import 'package:flutter_test/flutter_test.dart';
import 'package:fitiron/services/ofensiva_calculator.dart';

void main() {
  group('OfensivaCalculator', () {
    final today = DateTime(2026, 9, 11); // Friday (weekday 5)

    test('1. Todos os dias marcados como "Dia de descanso" (nunca quebra, mas também nunca soma)', () {
      final scheduledWeekdays = <int>{}; // Empty schedule = all rest days
      final workoutDates = {
        DateTime(2026, 9, 11), // Today
        DateTime(2026, 9, 10), // Yesterday (Thu)
        DateTime(2026, 9, 9),  // Wed
        DateTime(2026, 9, 8),  // Tue
      };

      final result = OfensivaCalculator.calculate(
        scheduledWeekdays: scheduledWeekdays,
        workoutDates: workoutDates,
        today: today,
      );

      expect(result.days, 0);
      expect(result.isAtRisk, false);
    });

    test('2. Sequência de dias agendados todos cumpridos', () {
      // Schedule: Mon (1), Wed (3), Fri (5)
      final scheduledWeekdays = {1, 3, 5};
      final workoutDates = {
        DateTime(2026, 9, 11), // Fri (today)
        DateTime(2026, 9, 9),  // Wed
        DateTime(2026, 9, 7),  // Mon
        DateTime(2026, 9, 4),  // Fri (prev week)
      };

      final result = OfensivaCalculator.calculate(
        scheduledWeekdays: scheduledWeekdays,
        workoutDates: workoutDates,
        today: today,
      );

      // All 4 scheduled days fulfilled
      expect(result.days, 4);
      expect(result.isAtRisk, false);
    });

    test('3. Um dia agendado no meio da sequência sem treino (deve zerar a partir dali)', () {
      // Schedule: Mon (1), Wed (3), Fri (5)
      final scheduledWeekdays = {1, 3, 5};
      final workoutDates = {
        DateTime(2026, 9, 11), // Fri (today) - trained
        DateTime(2026, 9, 9),  // Wed - trained
        // Mon 2026-09-07 was missed!
        DateTime(2026, 9, 4),  // Prev Fri - trained, but streak was broken on Mon
      };

      final result = OfensivaCalculator.calculate(
        scheduledWeekdays: scheduledWeekdays,
        workoutDates: workoutDates,
        today: today,
      );

      // Today (1) + Wed (1) = 2, then stopped at missed Monday
      expect(result.days, 2);
      expect(result.isAtRisk, false);
    });

    test('4. Hoje é dia agendado e ainda não treinou (isAtRisk true, ofensiva não quebrada ainda)', () {
      // Schedule: Mon (1), Wed (3), Fri (5)
      final scheduledWeekdays = {1, 3, 5};
      final workoutDates = {
        // Today (Friday 2026-09-11) is NOT in workoutDates!
        DateTime(2026, 9, 9),  // Wed - trained
        DateTime(2026, 9, 7),  // Mon - trained
      };

      final result = OfensivaCalculator.calculate(
        scheduledWeekdays: scheduledWeekdays,
        workoutDates: workoutDates,
        today: today,
      );

      // Past streak is 2 (Wed + Mon), today is not trained yet so days = 2, isAtRisk = true
      expect(result.days, 2);
      expect(result.isAtRisk, true);
    });

    test('5. Usuário reconfigura o Plano Semanal no meio do histórico (avaliação retroativa usa o schedule ATUAL)', () {
      // Note: By simplicity and design, retroactive calculation evaluates history against current scheduledWeekdays.
      // Suppose workout history has workouts on Tue (2) and Thu (4), but schedule was changed to Mon (1) and Wed (3).
      final scheduledWeekdays = {1, 3}; // Current schedule
      final workoutDates = {
        DateTime(2026, 9, 8), // Tuesday - trained (under old schedule)
        DateTime(2026, 9, 10), // Thursday - trained (under old schedule)
      };

      final result = OfensivaCalculator.calculate(
        scheduledWeekdays: scheduledWeekdays,
        workoutDates: workoutDates,
        today: today, // Friday (5) - rest day under current schedule
      );

      // Since Tue and Thu are rest days in the current schedule, they do not add or break.
      // Mon (9/7) and Wed (9/9) were scheduled in current schedule but missed, so retroceded past streak hits missed Wed and breaks at 0.
      expect(result.days, 0);
      expect(result.isAtRisk, false);
    });

    test('6. Corte de segurança: parar de retroceder na data de criação da conta ou 2 anos atrás', () {
      final scheduledWeekdays = {1, 2, 3, 4, 5, 6, 7}; // All days scheduled
      final accountCreatedAt = today.subtract(const Duration(days: 10));

      // Workout on all dates for the past 20 days
      final workoutDates = List.generate(
        20,
        (i) => today.subtract(Duration(days: i)),
      ).toSet();

      final result = OfensivaCalculator.calculate(
        scheduledWeekdays: scheduledWeekdays,
        workoutDates: workoutDates,
        today: today,
        accountCreatedAt: accountCreatedAt,
      );

      // Walking backwards stops at accountCreatedAt (10 days ago), counting 10 past days + 1 today = 11
      expect(result.days, 11);
      expect(result.isAtRisk, false);
    });
  });
}
