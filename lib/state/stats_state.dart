part of 'fit_state.dart';

mixin StatsState on FitCore, ToolsState, LibraryState {
  List<double> bodyweightSeriesOver(int days) {
    final start = DateTime.now().subtract(Duration(days: days));
    final sorted = [...bodyweight]..sort((a, b) => a.date.compareTo(b.date));
    return sorted.where((e) => e.date.isAfter(start)).map((e) => e.kg).toList();
  }

  double? bodyweightChangeOver(int days) {
    final series = bodyweightSeriesOver(days);
    if (series.length < 2) return null;
    return series.last - series.first;
  }

  List<({DateTime date, double diff})> get workoutBwDiffs => sessions
      .where((s) => s.bwBefore != null && s.bwAfter != null)
      .map((s) => (date: s.date, diff: s.bwAfter! - s.bwBefore!))
      .toList()
    ..sort((a, b) => b.date.compareTo(a.date));

  List<Exercise> recommendedExercises(int n) {
    final muscles = suggestedFocus.muscles;
    final picks = <Exercise>[];
    final usedMuscle = <String>{};

    for (final m in muscles) {
      final ex = kExercises.firstWhere(
        (e) => e.primary == m && !picks.contains(e),
        orElse: () => kExercises.first,
      );
      if (ex.primary == m && usedMuscle.add(m)) picks.add(ex);
    }

    for (final e in kExercises) {
      if (picks.length >= n) break;
      if (muscles.contains(e.primary) && !picks.contains(e)) picks.add(e);
    }
    return picks.take(n).toList();
  }

  int get athleteLevel => 1 + totalSessions ~/ 10;

  BodyweightEntry? get latestBodyweight =>
      bodyweight.isEmpty ? null : bodyweight.reduce((a, b) => a.date.isAfter(b.date) ? a : b);

  List<double> get bodyweightSeries {
    final sorted = [...bodyweight]..sort((a, b) => b.date.compareTo(a.date));
    return sorted.map((e) => e.kg).toList();
  }

  void addBodyweight(double kg, {WeightContext context = WeightContext.manual}) {
    final now = DateTime.now();
    bodyweight.add(BodyweightEntry(
      now,
      _round3(kg),
      id: 'entry_${now.millisecondsSinceEpoch}',
      context: context,
    ));
    profile.weightKg = _round3(kg);
    _seedCalculatorsFromProfile();
    _checkCelebration();
    _persist();
    notifyListeners();
  }

  int get todayIndex => DateTime.now().weekday - 1;

  DateTime get _weekStart {
    final t = _dayKey(DateTime.now());
    return t.subtract(Duration(days: t.weekday - 1));
  }

  Iterable<LoggedSession> get _thisWeekSessions {
    final start = _weekStart;
    final end = start.add(const Duration(days: 7));
    return sessions.where((s) {
      final k = _dayKey(s.date);
      return !k.isBefore(start) && k.isBefore(end);
    });
  }

  List<double> _dailyVolumes(int days) {
    final today = _dayKey(DateTime.now());
    final byDay = <DateTime, double>{};
    for (final s in sessions) {
      final k = _dayKey(s.date);
      byDay[k] = (byDay[k] ?? 0) + s.volume;
    }
    return List.generate(days, (i) {
      final d = today.subtract(Duration(days: days - 1 - i));
      return byDay[d] ?? 0;
    });
  }

  double _volumeBetween(DateTime start, DateTime end) => sessions
      .where((s) => s.date.isAfter(start) && !s.date.isAfter(end))
      .fold(0.0, (a, s) => a + s.volume);

  bool get hasData => sessions.isNotEmpty;
  int get totalSessions => sessions.length;

  double get volume30dKg {
    final now = DateTime.now();
    return _volumeBetween(now.subtract(const Duration(days: 30)), now);
  }

  int? get volumeChangePct {
    final now = DateTime.now();
    final cur = _volumeBetween(now.subtract(const Duration(days: 30)), now);
    final prev = _volumeBetween(
        now.subtract(const Duration(days: 60)), now.subtract(const Duration(days: 30)));
    if (prev <= 0) return null;
    return (((cur - prev) / prev) * 100).round();
  }

  List<double> get volumeChartPoints {
    final daily = _dailyVolumes(30);
    final cum = <double>[];
    double run = 0;
    for (final v in daily) {
      run += v;
      cum.add(run);
    }
    const n = 12;
    return List.generate(n, (i) {
      final idx = ((cum.length - 1) * i / (n - 1)).round();
      return cum[idx];
    });
  }

  List<int> get heatmapLevels => heatmapLevelsFor(kHeatmapDays);

  List<int> heatmapLevelsFor(int days) {
    final daily = _dailyVolumes(days);
    final maxV = daily.fold(0.0, (m, v) => v > m ? v : m);
    if (maxV <= 0) return List.filled(days, 0);
    return daily.map((v) {
      if (v <= 0) return 0;
      final r = v / maxV;
      if (r > 0.66) return 3;
      if (r > 0.33) return 2;
      return 1;
    }).toList();
  }

  DateTime heatmapDate(int i) =>
      _dayKey(DateTime.now()).subtract(Duration(days: kHeatmapDays - 1 - i));

  int sessionsInMonth(DateTime month) =>
      sessions.where((s) => s.date.year == month.year && s.date.month == month.month).length;

  double volumeInMonth(DateTime month) => sessions
      .where((s) => s.date.year == month.year && s.date.month == month.month)
      .fold(0.0, (total, s) => total + s.volume);

  bool hasActivityOn(DateTime day) => sessionsOn(day).isNotEmpty || checkins.contains(_dayId(day));

  List<LoggedSession> sessionsOn(DateTime day) {
    final k = _dayKey(day);
    return sessions.where((s) => _dayKey(s.date) == k).toList()
      ..sort((a, b) => b.date.compareTo(a.date));
  }

  void deleteSession(LoggedSession s) {
    sessions.remove(s);
    persistNow();
    _refreshWidgets();
    notifyListeners();
  }

  void deleteLoggedExercise(LoggedSession s, LoggedExercise e) {
    s.exercises.remove(e);
    if (s.exercises.isEmpty) sessions.remove(s);
    persistNow();
    notifyListeners();
  }

  void deleteBodyweight(BodyweightEntry e) {
    bodyweight.remove(e);
    final latest = latestBodyweight;
    if (latest != null) {
      profile.weightKg = latest.kg;
      _seedCalculatorsFromProfile();
    }
    persistNow();
    notifyListeners();
  }

  List<BodyweightEntry> get bodyweightHistory =>
      [...bodyweight]..sort((a, b) => b.date.compareTo(a.date));

  ({int exercises, int sets, double volume, int durationSec, List<String> names})? daySummary(
      DateTime day) {
    final k = _dayKey(day);
    final ofDay = sessions.where((s) => _dayKey(s.date) == k).toList();
    if (ofDay.isEmpty) return null;
    final names = <String>[];
    for (final s in ofDay) {
      for (final e in s.exercises) {
        if (!names.contains(e.name)) names.add(e.name);
      }
    }
    return (
      exercises: names.length,
      sets: ofDay.fold(0, (a, s) => a + s.setCount),
      volume: ofDay.fold(0.0, (a, s) => a + s.volume),
      durationSec: ofDay.fold(0, (a, s) => a + s.durationSec),
      names: names,
    );
  }

  OfensivaResult get ofensivaResult {
    final days = sessions.map((s) => _dayKey(s.date)).toSet();
    for (final id in checkins) {
      final p = id.split('-');
      if (p.length == 3) {
        final y = int.tryParse(p[0]), m = int.tryParse(p[1]), d = int.tryParse(p[2]);
        if (y != null && m != null && d != null) days.add(DateTime(y, m, d));
      }
    }
    final earliestSession = sessions.isEmpty
        ? null
        : sessions.map((s) => s.date).reduce((a, b) => a.isBefore(b) ? a : b);
    return OfensivaCalculator.calculate(
      scheduledWeekdays: scheduledWeekdays,
      workoutDates: days,
      today: DateTime.now(),
      accountCreatedAt: earliestSession,
    );
  }

  DateTime get earliestActivityDate {
    DateTime? earliest;
    for (final s in sessions) {
      if (earliest == null || s.date.isBefore(earliest)) earliest = s.date;
    }
    for (final b in bodyweight) {
      if (earliest == null || b.date.isBefore(earliest)) earliest = b.date;
    }
    for (final id in checkins) {
      final p = id.split('-');
      if (p.length == 3) {
        final y = int.tryParse(p[0]), m = int.tryParse(p[1]), d = int.tryParse(p[2]);
        if (y != null && m != null && d != null) {
          final dt = DateTime(y, m, d);
          if (earliest == null || dt.isBefore(earliest)) earliest = dt;
        }
      }
    }
    return earliest ?? DateTime.now();
  }

  OfensivaResult get ofensiva => ofensivaResult;

  int get currentStreak => ofensivaResult.days;

  List<bool> get weekMask {
    final start = _weekStart;
    final days = sessions.map((s) => _dayKey(s.date)).toSet();
    return List.generate(7, (i) => days.contains(start.add(Duration(days: i))));
  }

  String _dayId(DateTime d) => '${d.year}-${d.month}-${d.day}';

  DateTime _dateForWeekday(int i) => _weekStart.add(Duration(days: i));

  bool _hasSessionOn(DateTime day) {
    final k = _dayKey(day);
    return sessions.any((s) => _dayKey(s.date) == k);
  }

  bool isDayDone(int i) {
    final d = _dateForWeekday(i);
    return _hasSessionOn(d) || checkins.contains(_dayId(d));
  }

  bool isSessionDay(int i) => _hasSessionOn(_dateForWeekday(i));

  bool canToggleDay(int i) => i <= todayIndex;

  void toggleCheckin(int i) {
    if (!canToggleDay(i)) return;
    final d = _dateForWeekday(i);
    if (_hasSessionOn(d)) return;
    final id = _dayId(d);
    if (checkins.contains(id)) {
      checkins.remove(id);
    } else {
      checkins.add(id);
    }
    _checkCelebration();
    _persist();
    _refreshWidgets();
    notifyListeners();
  }

  int get sessionsThisWeek => _thisWeekSessions.length;

  double get volumeThisWeekKg => _thisWeekSessions.fold(0.0, (a, s) => a + s.volume);

  int get setsThisWeek => _thisWeekSessions.fold(0, (a, s) => a + s.setCount);

  Iterable<LoggedSession> _sessionsForWeek(DateTime weekStart) {
    final end = weekStart.add(const Duration(days: 7));
    return sessions.where((s) {
      final k = _dayKey(s.date);
      return !k.isBefore(weekStart) && k.isBefore(end);
    });
  }

  /// Duration in minutes per day of the week [Mon=0 .. Sun=6]
  List<double> weeklyDurationMinutes(DateTime weekStart) {
    final ws = _sessionsForWeek(weekStart);
    final byDay = <int, double>{};
    for (final s in ws) {
      final idx = _dayKey(s.date).weekday - 1; // 0=Mon
      byDay[idx] = (byDay[idx] ?? 0) + s.durationSec / 60.0;
    }
    return List.generate(7, (i) => byDay[i] ?? 0);
  }

  /// Volume in kg per day of the week [Mon=0 .. Sun=6]
  List<double> weeklyVolumeKg(DateTime weekStart) {
    final ws = _sessionsForWeek(weekStart);
    final byDay = <int, double>{};
    for (final s in ws) {
      final idx = _dayKey(s.date).weekday - 1;
      byDay[idx] = (byDay[idx] ?? 0) + s.volume;
    }
    return List.generate(7, (i) => byDay[i] ?? 0);
  }

  /// Total reps per day of the week [Mon=0 .. Sun=6]
  List<double> weeklyReps(DateTime weekStart) {
    final ws = _sessionsForWeek(weekStart);
    final byDay = <int, double>{};
    for (final s in ws) {
      final idx = _dayKey(s.date).weekday - 1;
      double reps = 0;
      for (final e in s.exercises) {
        for (final st in e.sets) {
          reps += st.reps;
        }
      }
      byDay[idx] = (byDay[idx] ?? 0) + reps;
    }
    return List.generate(7, (i) => byDay[i] ?? 0);
  }

  /// Calories burned per day of the week [Mon=0 .. Sun=6]
  List<double> weeklyCalories(DateTime weekStart) {
    final mins = weeklyDurationMinutes(weekStart);
    return mins.map((m) => m * 6.5).toList();
  }

  /// Number of sessions logged in the given week
  int weeklySessionsCount(DateTime weekStart) => _sessionsForWeek(weekStart).length;

  /// Number of unique exercises logged in the given week
  int weeklyExercisesCount(DateTime weekStart) {
    final set = <String>{};
    for (final s in _sessionsForWeek(weekStart)) {
      for (final e in s.exercises) {
        set.add(e.id);
      }
    }
    return set.length;
  }

  /// Number of PRs achieved in the given week
  int weeklyPrsCount(DateTime weekStart) {
    final bestOrm = <String, double>{};
    final bestDate = <String, DateTime>{};
    for (final s in sessions) {
      for (final e in s.exercises) {
        for (final st in e.sets) {
          if (!bestOrm.containsKey(e.id) || st.oneRm > bestOrm[e.id]!) {
            bestOrm[e.id] = st.oneRm;
            bestDate[e.id] = s.date;
          }
        }
      }
    }
    final end = weekStart.add(const Duration(days: 7));
    var n = 0;
    bestDate.forEach((_, d) {
      final k = _dayKey(d);
      if (!k.isBefore(weekStart) && k.isBefore(end)) n++;
    });
    return n;
  }
  /// List of PRs achieved within a specific period
  List<({String name, double topWeight, double oneRm, DateTime date})> prsInPeriod(
      DateTime start, DateTime end) {
    final bestOrm = <String, ({String name, double topWeight, double oneRm, DateTime date})>{};
    for (final s in sessions) {
      for (final e in s.exercises) {
        for (final st in e.sets) {
          final c = bestOrm[e.id];
          if (c == null || st.oneRm > c.oneRm) {
            bestOrm[e.id] = (
              name: e.name,
              topWeight: st.weight,
              oneRm: st.oneRm,
              date: s.date,
            );
          }
        }
      }
    }
    final out = <({String name, double topWeight, double oneRm, DateTime date})>[];
    bestOrm.forEach((_, pr) {
      if (!pr.date.isBefore(start) && pr.date.isBefore(end)) {
        out.add(pr);
      }
    });
    out.sort((a, b) => b.oneRm.compareTo(a.oneRm));
    return out;
  }

  double weeklyAvgDurationPerWorkout(DateTime weekStart) {
    final count = weeklySessionsCount(weekStart);
    if (count <= 0) return 0;
    return durationWeekMin(weekStart).toDouble() / count;
  }

  double weeklyAvgCaloriesPerWorkout(DateTime weekStart) {
    final count = weeklySessionsCount(weekStart);
    if (count <= 0) return 0;
    final totalCal = weeklyCalories(weekStart).fold(0.0, (a, b) => a + b);
    return totalCal / count;
  }

  double weeklyAvgVolumePerWorkout(DateTime weekStart) {
    final count = weeklySessionsCount(weekStart);
    if (count <= 0) return 0;
    return volumeWeekKg(weekStart) / count;
  }

  double weeklyAvgRepsPerWorkout(DateTime weekStart) {
    final count = weeklySessionsCount(weekStart);
    if (count <= 0) return 0;
    return repsWeekTotal(weekStart).toDouble() / count;
  }

  /// Total duration of the week in minutes
  int durationWeekMin(DateTime weekStart) =>
      _sessionsForWeek(weekStart).fold(0, (a, s) => a + s.durationSec) ~/ 60;

  /// Total reps of the week
  int repsWeekTotal(DateTime weekStart) {
    int total = 0;
    for (final s in _sessionsForWeek(weekStart)) {
      for (final e in s.exercises) {
        for (final st in e.sets) {
          total += st.reps;
        }
      }
    }
    return total;
  }

  /// Total volume of the week in kg
  double volumeWeekKg(DateTime weekStart) =>
      _sessionsForWeek(weekStart).fold(0.0, (a, s) => a + s.volume);

  /// Check if a given week has any sessions
  bool weekHasData(DateTime weekStart) =>
      _sessionsForWeek(weekStart).isNotEmpty;

  int get setsToday {
    final t = _dayKey(DateTime.now());
    return sessions.where((s) => _dayKey(s.date) == t).fold(0, (a, s) => a + s.setCount);
  }

  final Set<String> _celebratedGoalKeys = {};
  String? _pendingCelebrationMessage;

  String? consumePendingCelebrationMessage() {
    final msg = _pendingCelebrationMessage;
    _pendingCelebrationMessage = null;
    return msg;
  }

  void clearCelebrationMessage() => _pendingCelebrationMessage = null;

  void _checkCelebration() {
    final now = DateTime.now();
    final todayKey = DateTime(now.year, now.month, now.day);
    final weekStart = todayKey.subtract(Duration(days: todayKey.weekday - 1));

    for (final g in goals) {
      final res = calculateGoalProgress(g);
      if (res.isCompleted) {
        final key = '${g.id}_${weekStart.millisecondsSinceEpoch}';
        if (!_celebratedGoalKeys.contains(key)) {
          _celebratedGoalKeys.add(key);
          _pendingCelebrationMessage = 'Meta semanal batida!';
          RestAlarm.instance.showGoalReachedNotification();
        }
      }
    }
  }

  int get suggestedWeeklyFrequency {
    final now = DateTime.now();
    final fourWeeksAgo = now.subtract(const Duration(days: 28));
    final sessionsInLast4Weeks = sessions.where((s) => s.date.isAfter(fourWeeksAgo)).length;
    final avg = (sessionsInLast4Weeks / 4.0).round();
    if (avg > 0) return avg.clamp(1, 7);
    if (profile.weeklyGoal > 0) return profile.weeklyGoal;
    return 4;
  }

  GoalProgressResult calculateGoalProgress(Goal goal) {
    return GoalProgressCalculator.calculate(
      goal: goal,
      currentPeriodSessions: _thisWeekSessions,
      weightEntries: bodyweight,
      currentWeightFallback: latestBodyweight?.kg ?? profile.weightKg,
    );
  }

  Goal get pinnedGoal {
    return goals.firstWhere(
      (g) => g.pinnedToHome,
      orElse: () => goals.isNotEmpty
          ? goals.first
          : Goal(
              id: 'temp',
              type: GoalType.weeklyFrequency,
              targetValue: profile.weeklyGoal.toDouble(),
              pinnedToHome: true,
            ),
    );
  }

  GoalProgressResult get primaryGoalProgress => calculateGoalProgress(pinnedGoal);

  int get goalPct => primaryGoalProgress.progressPercentage;

  String get primaryGoalLabel {
    final primary = pinnedGoal;
    switch (primary.type) {
      case GoalType.weeklyFrequency:
      case GoalType.sessionsWeekly:
        return '${primary.targetValue.round()}× SEMANA';
      case GoalType.weightTarget:
      case GoalType.bodyweight:
        return 'META PESO ${weightLabel(primary.targetValue)}';
      case GoalType.volumeMonthly:
        return '${volumeValue(primary.targetValue)} $volumeUnit';
      case GoalType.strength:
        final name = exerciseById(primary.exerciseId ?? '')?.name ?? 'PR';
        return '$name: ${weightLabel(primary.targetValue)}';
      case GoalType.setsWeekly:
        return '${primary.targetValue.round()} séries/sem';
      case GoalType.durationMonthly:
        return '${primary.targetValue.round()}h de treino/mês';
    }
  }

  void addGoal(GoalType type, double target, {String? exerciseId}) {
    final id = DateTime.now().millisecondsSinceEpoch.toString();
    final isFirst = goals.isEmpty;
    final newGoal = Goal(
      id: id,
      type: type,
      targetValue: target,
      exerciseId: exerciseId,
      pinnedToHome: isFirst || !goals.any((g) => g.pinnedToHome),
    );
    goals.add(newGoal);
    _checkCelebration();
    _persist();
    notifyListeners();
  }

  void setPrimaryGoal(String id) {
    for (final g in goals) {
      g.pinnedToHome = g.id == id;
    }
    _persist();
    notifyListeners();
  }

  void deleteGoal(String id) {
    goals.removeWhere((g) => g.id == id);
    if (goals.isNotEmpty && !goals.any((g) => g.pinnedToHome)) {
      goals.first.pinnedToHome = true;
    }
    _persist();
    notifyListeners();
  }

  List<({String name, double topWeight, double oneRm})> get personalRecords {
    final best = <String, ({String name, double topWeight, double oneRm})>{};
    for (final s in sessions) {
      for (final e in s.exercises) {
        for (final st in e.sets) {
          final c = best[e.id];
          best[e.id] = (
            name: e.name,
            topWeight: c == null ? st.weight : math.max(c.topWeight, st.weight),
            oneRm: c == null ? st.oneRm : math.max(c.oneRm, st.oneRm),
          );
        }
      }
    }
    final list = best.values.toList()..sort((a, b) => b.oneRm.compareTo(a.oneRm));
    return list;
  }

  int get prsThisWeek {
    final bestOrm = <String, double>{};
    final bestDate = <String, DateTime>{};
    for (final s in sessions) {
      for (final e in s.exercises) {
        for (final st in e.sets) {
          if (!bestOrm.containsKey(e.id) || st.oneRm > bestOrm[e.id]!) {
            bestOrm[e.id] = st.oneRm;
            bestDate[e.id] = s.date;
          }
        }
      }
    }
    final start = _weekStart;
    final end = start.add(const Duration(days: 7));
    var n = 0;
    bestDate.forEach((_, d) {
      final k = _dayKey(d);
      if (!k.isBefore(start) && k.isBefore(end)) n++;
    });
    return n;
  }

  List<({String name, int pct})> get muscleSplit {
    final start = DateTime.now().subtract(const Duration(days: 30));
    final byGroup = <String, double>{};
    for (final s in sessions) {
      if (s.date.isBefore(start)) continue;
      for (final e in s.exercises) {
        final g = muscleGroup(e.primary);
        byGroup[g] = (byGroup[g] ?? 0) + e.volume;
      }
    }
    final total = byGroup.values.fold(0.0, (a, b) => a + b);
    if (total <= 0) return const [];
    final list = byGroup.entries
        .map((e) => (name: t.muscleGroupName(e.key), pct: ((e.value / total) * 100).round()))
        .where((e) => e.pct > 0)
        .toList()
      ..sort((a, b) => b.pct.compareTo(a.pct));
    return list;
  }

  static const double weeklySetTarget = 12;

  double muscleTargetFor(int days) => weeklySetTarget * days / 7;

  Map<String, double> muscleSetsOver(int days) {
    final start = _dayKey(DateTime.now()).subtract(Duration(days: days - 1));
    final out = <String, double>{};
    for (final s in sessions) {
      if (_dayKey(s.date).isBefore(start)) continue;
      for (final e in s.exercises) {
        final n = e.sets.length.toDouble();
        if (n <= 0) continue;
        out[e.primary] = (out[e.primary] ?? 0) + n;
        for (final m in exerciseById(e.id)?.secondary ?? const <String>[]) {
          out[m] = (out[m] ?? 0) + n / 2;
        }
      }
    }
    return out;
  }

  ({
    Map<String, double> currentSets,
    Map<String, double> previousSets,
    Map<String, double> currentVolume,
    Map<String, double> previousVolume,
  }) muscleDistributionForPeriod({
    required DateTime start,
    required DateTime end,
    required DateTime prevStart,
    required DateTime prevEnd,
  }) {
    final curSets = <String, double>{};
    final prevSets = <String, double>{};
    final curVol = <String, double>{};
    final prevVol = <String, double>{};

    String groupKey(String muscleId) {
      final grp = muscleGroup(muscleId).toLowerCase();
      if (grp.contains('leg') || grp.contains('perna')) return 'legs';
      if (grp.contains('arm') || grp.contains('braço')) return 'arms';
      if (grp.contains('chest') || grp.contains('peito')) return 'chest';
      if (grp.contains('shoulder') || grp.contains('ombro')) return 'shoulders';
      if (grp.contains('back') || grp.contains('costa')) return 'back';
      return 'core';
    }

    for (final s in sessions) {
      final date = s.date;
      final isCur = !date.isBefore(start) && date.isBefore(end);
      final isPrev = !date.isBefore(prevStart) && date.isBefore(prevEnd);
      if (!isCur && !isPrev) continue;

      final targetSets = isCur ? curSets : prevSets;
      final targetVol = isCur ? curVol : prevVol;

      for (final e in s.exercises) {
        final n = e.sets.length.toDouble();
        final v = e.volume;
        if (n <= 0) continue;

        final gPrim = groupKey(e.primary);
        targetSets[gPrim] = (targetSets[gPrim] ?? 0) + n;
        targetVol[gPrim] = (targetVol[gPrim] ?? 0) + v;

        final secondaries = exerciseById(e.id)?.secondary ?? const <String>[];
        for (final m in secondaries) {
          final gSec = groupKey(m);
          targetSets[gSec] = (targetSets[gSec] ?? 0) + (n * 0.5);
          targetVol[gSec] = (targetVol[gSec] ?? 0) + (v * 0.5);
        }
      }
    }

    return (
      currentSets: curSets,
      previousSets: prevSets,
      currentVolume: curVol,
      previousVolume: prevVol,
    );
  }

  Map<String, double> muscleHeatOver(int days) {
    final target = muscleTargetFor(days);
    return {
      for (final e in muscleSetsOver(days).entries) e.key: (e.value / target).clamp(0.0, 1.0),
    };
  }

  List<String> neglectedMuscles(int days) {
    final sets = muscleSetsOver(days);
    if (sets.isEmpty) return const [];
    final threshold = muscleTargetFor(days) / 3;
    final ids = kMuscles.map((m) => m.id).where((id) => (sets[id] ?? 0) < threshold).toList()
      ..sort((a, b) => (sets[a] ?? 0).compareTo(sets[b] ?? 0));
    return ids.take(3).toList();
  }

  List<({DateTime date, LoggedExercise ex})> exerciseHistory(String id) {
    final out = <({DateTime date, LoggedExercise ex})>[];
    for (final s in sessions) {
      for (final e in s.exercises) {
        if (e.id == id) out.add((date: s.date, ex: e));
      }
    }
    out.sort((a, b) => b.date.compareTo(a.date));
    return out;
  }

  List<LoggedSet> lastSetsFor(String id) {
    final h = exerciseHistory(id);
    return h.isEmpty ? const [] : h.first.ex.sets;
  }

  String? lastSummaryFor(String id) {
    final sets = lastSetsFor(id);
    if (sets.isEmpty) return null;
    return sets.map((s) => '${weightValue(s.weight)}×${s.reps}').join(' · ');
  }

  ({double topWeight, double oneRm})? exercisePr(String id) {
    final h = exerciseHistory(id);
    if (h.isEmpty) return null;
    double tw = 0, orm = 0;
    for (final r in h) {
      tw = math.max(tw, r.ex.topWeight);
      orm = math.max(orm, r.ex.bestOneRm);
    }
    return (topWeight: tw, oneRm: orm);
  }

  String? strengthExerciseId;

  List<({String id, String name, int sessions})> get trackedExercises {
    final count = <String, int>{};
    final names = <String, String>{};
    for (final s in sessions) {
      for (final e in s.exercises) {
        count[e.id] = (count[e.id] ?? 0) + 1;
        names[e.id] = e.name;
      }
    }
    final list = count.entries
        .where((e) => e.value >= 2)
        .map((e) => (id: e.key, name: names[e.key]!, sessions: e.value))
        .toList()
      ..sort((a, b) => b.sessions.compareTo(a.sessions));
    return list;
  }

  String? get activeStrengthId {
    final tracked = trackedExercises;
    if (tracked.isEmpty) return null;
    if (strengthExerciseId != null && tracked.any((e) => e.id == strengthExerciseId)) {
      return strengthExerciseId;
    }
    return tracked.first.id;
  }

  void setStrengthExercise(String id) {
    strengthExerciseId = id;
    notifyListeners();
  }

  List<double> oneRmSeries(String id) {
    final h = exerciseHistory(id).reversed;
    return h.map((r) => _round1(r.ex.bestOneRm)).toList();
  }

  ({String title, String subtitle, List<String> muscles}) get suggestedFocus {
    final table = {
      'push': (title: t.pushDay, subtitle: t.pushFocus, muscles: ['chest', 'shoulders', 'triceps']),
      'pull': (title: t.pullDay, subtitle: t.pullFocus, muscles: ['back', 'biceps', 'trapezius']),
      'legs': (title: t.legDay, subtitle: t.legFocus, muscles: ['quads', 'hamstrings', 'glutes']),
    };
    var last = '';
    if (sessions.isNotEmpty) {
      final s = sessions.reduce((a, b) => a.date.isAfter(b.date) ? a : b);
      final fam = <String, double>{};
      for (final e in s.exercises) {
        final f = muscleFamily(e.primary);
        fam[f] = (fam[f] ?? 0) + e.volume;
      }
      if (fam.isNotEmpty) {
        last = fam.entries.reduce((a, b) => a.value >= b.value ? a : b).key;
      }
    }
    const order = ['push', 'pull', 'legs'];
    final idx = order.indexOf(last);

    final next = idx >= 0 ? order[(idx + 1) % order.length] : order[DateTime.now().weekday % 3];
    return table[next]!;
  }
}
