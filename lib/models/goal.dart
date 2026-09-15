enum GoalType {
  weeklyFrequency,
  weightTarget,
  sessionsWeekly, // Legacy alias for weeklyFrequency
  bodyweight,     // Legacy alias for weightTarget
  volumeMonthly,
  strength,
  setsWeekly,
  durationMonthly,
}

class Goal {
  Goal({
    required this.id,
    required this.type,
    double? targetValue,
    double? target,
    DateTime? createdAt,
    bool? pinnedToHome,
    bool? isPrimary,
    this.exerciseId,
  })  : targetValue = targetValue ?? target ?? 0.0,
        createdAt = createdAt ?? DateTime.now(),
        pinnedToHome = pinnedToHome ?? isPrimary ?? false;

  final String id;
  final GoalType type;
  final double targetValue;
  final DateTime createdAt;
  bool pinnedToHome;
  final String? exerciseId;

  // Legacy getter/setter aliases for backward compatibility across codebase
  double get target => targetValue;
  bool get isPrimary => pinnedToHome;
  set isPrimary(bool val) => pinnedToHome = val;

  Map<String, dynamic> toJson() => {
        'id': id,
        'type': type.name,
        'val': targetValue,
        'targetValue': targetValue,
        'createdAt': createdAt.toIso8601String(),
        'pinnedToHome': pinnedToHome,
        'pri': pinnedToHome,
        'exId': exerciseId,
      };

  factory Goal.fromJson(Map<String, dynamic> j) {
    GoalType parseType(String typeStr) {
      if (typeStr == 'sessionsWeekly') return GoalType.weeklyFrequency;
      if (typeStr == 'bodyweight') return GoalType.weightTarget;
      return GoalType.values.firstWhere(
        (e) => e.name == typeStr,
        orElse: () => GoalType.weeklyFrequency,
      );
    }

    final rawVal = j['targetValue'] ?? j['val'];
    final targetVal = rawVal != null ? (rawVal as num).toDouble() : 0.0;
    final created = j['createdAt'] != null
        ? DateTime.tryParse(j['createdAt'] as String) ?? DateTime.now()
        : DateTime.now();
    final pinned = j['pinnedToHome'] as bool? ?? j['pri'] as bool? ?? false;

    return Goal(
      id: j['id'] as String,
      type: parseType(j['type'] as String),
      targetValue: targetVal,
      createdAt: created,
      pinnedToHome: pinned,
      exerciseId: j['exId'] as String?,
    );
  }
}
