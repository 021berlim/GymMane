enum WeightContext {
  morning,
  preWorkout,
  postWorkout,
  manual,
}

class WeightEntry {
  WeightEntry({
    required this.id,
    required this.timestamp,
    required this.weightKg,
    this.context = WeightContext.manual,
  });

  final String id;
  final DateTime timestamp;
  final double weightKg;
  final WeightContext context;

  // Retrocompatibility getters for existing code using date & kg
  DateTime get date => timestamp;
  double get kg => weightKg;

  Map<String, dynamic> toJson() => {
        'id': id,
        't': timestamp.toIso8601String(),
        'weightKg': weightKg,
        'context': context.name,
      };

  factory WeightEntry.fromJson(Map<String, dynamic> j) {
    WeightContext parseContext(String? ctxStr) {
      if (ctxStr == null) return WeightContext.manual;
      return WeightContext.values.firstWhere(
        (c) => c.name == ctxStr,
        orElse: () => WeightContext.manual,
      );
    }

    final rawDate = j['t'] ?? j['d'];
    final date = rawDate != null ? DateTime.parse(rawDate as String) : DateTime.now();
    final weight = ((j['weightKg'] ?? j['kg']) as num?)?.toDouble() ?? 0.0;
    final idStr = j['id'] as String? ?? 'entry_${date.millisecondsSinceEpoch}';

    return WeightEntry(
      id: idStr,
      timestamp: date,
      weightKg: weight,
      context: parseContext(j['context'] as String?),
    );
  }
}

class BodyweightEntry extends WeightEntry {
  BodyweightEntry(
    DateTime date,
    double kg, {
    String? id,
    super.context = WeightContext.manual,
  }) : super(
          id: id ?? 'entry_${date.millisecondsSinceEpoch}',
          timestamp: date,
          weightKg: kg,
        );

  factory BodyweightEntry.fromJson(Map<String, dynamic> j) {
    final entry = WeightEntry.fromJson(j);
    return BodyweightEntry(
      entry.timestamp,
      entry.weightKg,
      id: entry.id,
      context: entry.context,
    );
  }
}
