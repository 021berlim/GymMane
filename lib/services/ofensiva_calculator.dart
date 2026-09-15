class OfensivaResult {
  const OfensivaResult({
    required this.days,
    required this.isAtRisk,
  });

  final int days;
  final bool isAtRisk;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is OfensivaResult &&
          runtimeType == other.runtimeType &&
          days == other.days &&
          isAtRisk == other.isAtRisk;

  @override
  int get hashCode => days.hashCode ^ isAtRisk.hashCode;

  @override
  String toString() => 'OfensivaResult(days: $days, isAtRisk: $isAtRisk)';
}

class OfensivaCalculator {
  static DateTime normalizeDate(DateTime d) => DateTime(d.year, d.month, d.day);

  static OfensivaResult calculate({
    required Set<int> scheduledWeekdays,
    required Set<DateTime> workoutDates,
    required DateTime today,
    DateTime? accountCreatedAt,
  }) {
    final todayNormalized = normalizeDate(today);
    final normalizedWorkoutDates = workoutDates.map(normalizeDate).toSet();

    final isScheduledToday = scheduledWeekdays.contains(todayNormalized.weekday);
    final trainedToday = normalizedWorkoutDates.contains(todayNormalized);

    final isAtRisk = isScheduledToday && !trainedToday;

    final twoYearsAgo = normalizeDate(
      DateTime(todayNormalized.year - 2, todayNormalized.month, todayNormalized.day),
    );
    final DateTime cutoff;
    if (accountCreatedAt != null) {
      final normalizedCreated = normalizeDate(accountCreatedAt);
      cutoff = normalizedCreated.isAfter(twoYearsAgo) ? normalizedCreated : twoYearsAgo;
    } else {
      cutoff = twoYearsAgo;
    }

    int pastDays = 0;
    var cursor = todayNormalized.subtract(const Duration(days: 1));

    while (!cursor.isBefore(cutoff)) {
      if (scheduledWeekdays.contains(cursor.weekday)) {
        if (normalizedWorkoutDates.contains(cursor)) {
          pastDays++;
        } else {
          break;
        }
      }
      cursor = cursor.subtract(const Duration(days: 1));
    }

    final days = (isScheduledToday && trainedToday) ? pastDays + 1 : pastDays;

    return OfensivaResult(
      days: days,
      isAtRisk: isAtRisk,
    );
  }
}
