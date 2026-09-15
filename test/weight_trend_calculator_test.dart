import 'package:flutter_test/flutter_test.dart';
import 'package:fitiron/models/weight_entry.dart';
import 'package:fitiron/services/weight_trend_calculator.dart';

void main() {
  group('WeightTrendCalculator', () {
    test('série vazia retorna valores padrão', () {
      final res = WeightTrendCalculator.calculate(entries: []);
      expect(res.trendSeries, isEmpty);
      expect(res.currentTrendWeight, 0.0);
      expect(res.weeklyRateKg, 0.0);
      expect(res.goalEtaDate, isNull);
      expect(res.isRateAggressive, isFalse);
    });

    test('série com apenas 1 ponto', () {
      final now = DateTime(2026, 1, 1, 8, 0);
      final entries = [
        WeightEntry(
          id: '1',
          timestamp: now,
          weightKg: 80.0,
          context: WeightContext.manual,
        ),
      ];

      final res = WeightTrendCalculator.calculate(entries: entries);
      expect(res.trendSeries.length, 1);
      expect(res.trendSeries.first.trendKg, 80.0);
      expect(res.currentTrendWeight, 80.0);
      expect(res.weeklyRateKg, 0.0);
      expect(res.goalEtaDate, isNull);
      expect(res.isRateAggressive, isFalse);
    });

    test('série sem gaps (pesagens diárias consecutivas)', () {
      final start = DateTime(2026, 1, 1, 8, 0);
      final entries = List.generate(10, (i) {
        return WeightEntry(
          id: '$i',
          timestamp: start.add(Duration(days: i)),
          weightKg: 80.0 - i * 0.4,
          context: WeightContext.morning,
        );
      });

      final res = WeightTrendCalculator.calculate(entries: entries);
      expect(res.trendSeries.length, 10);
      expect(res.trendSeries.first.trendKg, 80.0);
      expect(res.currentTrendWeight, lessThan(80.0));
      expect(res.currentTrendWeight, greaterThan(77.0));
      expect(res.weeklyRateKg, lessThan(0.0));
      expect(res.isRateAggressive, isTrue);
    });

    test('série com gaps (intervalos de múltiplos dias entre pesagens)', () {
      final start = DateTime(2026, 1, 1, 8, 0);
      final entries = [
        WeightEntry(id: '1', timestamp: start, weightKg: 80.0, context: WeightContext.manual),
        WeightEntry(id: '2', timestamp: start.add(const Duration(days: 3)), weightKg: 78.0, context: WeightContext.manual),
        WeightEntry(id: '3', timestamp: start.add(const Duration(days: 6)), weightKg: 76.0, context: WeightContext.manual),
      ];

      final res = WeightTrendCalculator.calculate(entries: entries);
      expect(res.trendSeries.length, 3);

      final expectedTrend2 = 80.0 + (1 - (0.88 * 0.88 * 0.88)) * (78.0 - 80.0);
      expect(res.trendSeries[1].trendKg, closeTo(expectedTrend2, 0.001));
    });

    test('taxa zero (peso constante, sem meta)', () {
      final start = DateTime(2026, 1, 1, 8, 0);
      final entries = List.generate(14, (i) {
        return WeightEntry(
          id: '$i',
          timestamp: start.add(Duration(days: i)),
          weightKg: 75.0,
          context: WeightContext.manual,
        );
      });

      final res = WeightTrendCalculator.calculate(entries: entries, goalWeight: 70.0);
      expect(res.trendSeries.length, 14);
      expect(res.currentTrendWeight, closeTo(75.0, 0.001));
      expect(res.weeklyRateKg, closeTo(0.0, 0.001));
      expect(res.goalEtaDate, isNull);
      expect(res.isRateAggressive, isFalse);
    });

    test('ignora entradas com contexto postWorkout', () {
      final start = DateTime(2026, 1, 1, 8, 0);
      final entries = [
        WeightEntry(id: '1', timestamp: start, weightKg: 80.0, context: WeightContext.preWorkout),
        WeightEntry(id: '2', timestamp: start.add(const Duration(hours: 2)), weightKg: 78.5, context: WeightContext.postWorkout),
        WeightEntry(id: '3', timestamp: start.add(const Duration(days: 1)), weightKg: 79.8, context: WeightContext.manual),
      ];

      final res = WeightTrendCalculator.calculate(entries: entries);
      expect(res.trendSeries.length, 2);
      expect(res.trendSeries[0].rawKg, 80.0);
      expect(res.trendSeries[1].rawKg, 79.8);
    });

    test('calcula projecaoData quando há meta válida e ritmo na direção correta', () {
      final start = DateTime(2026, 1, 1, 8, 0);
      final entries = List.generate(30, (i) {
        return WeightEntry(
          id: '$i',
          timestamp: start.add(Duration(days: i)),
          weightKg: 80.0 - (i * (0.5 / 7.0)),
          context: WeightContext.manual,
        );
      });

      final res = WeightTrendCalculator.calculate(
        entries: entries,
        goalWeight: 75.0,
      );

      expect(res.goalEtaDate, isNotNull);
      expect(res.goalEtaDate!.isAfter(entries.last.timestamp), isTrue);
    });
  });
}
