part of 'fit_state.dart';

mixin WorkoutState on FitCore, SettingsState, LibraryState, StatsState, RoutinesState {
  final List<String> selectedMuscles = [];
  final Set<String> sessionPicks = {};
  String trainStep = 'select';
  WorkoutSession? session;
  Timer? _sessionTimer;
  Timer? _restTimer;
  bool bodyweightStartPromptShown = false;
  bool bodyweightFinishPromptShown = false;
  DateTime? _runningSince;
  int _elapsedBefore = 0;
  bool sessionPaused = false;

  void startWorkout() {
    if (route != 'train' && route != 'routine-choice') prevRoute = route;
    route = 'routine-choice';
    notifyListeners();
  }

  void startCustomWorkout() {
    _startCustomWorkout();
  }

  void startLogWorkout() {
    route = 'train';
    trainStep = 'review';
    selectedMuscles.clear();
    sessionPicks.clear();
    notifyListeners();
  }

  void chooseWorkoutFromRoutines({String returnRoute = 'routines'}) {
    prevRoute = returnRoute;
    route = 'routine-choice';
    notifyListeners();
  }

  void _startCustomWorkout() {
    route = 'train';
    trainStep = 'select';
    selectedMuscles.clear();
    sessionPicks.clear();
    notifyListeners();
  }

  List<Exercise> getFilteredExercises(List<String> sel) {
    if (sel.isEmpty) return const [];
    return allExercises
        .where((ex) => sel.contains(ex.primary) || ex.secondary.any(sel.contains))
        .toList();
  }

  void toggleMuscle(String id) {
    if (selectedMuscles.contains(id)) {
      selectedMuscles.remove(id);
    } else {
      selectedMuscles.add(id);
    }
    notifyListeners();
  }

  void trainContinue() {
    if (selectedMuscles.isEmpty) return;
    trainStep = 'review';
    sessionPicks
      ..clear()
      ..addAll(_defaultPicks(selectedMuscles).map((e) => e.id));
    notifyListeners();
  }

  List<Exercise> reviewExercises() {
    final base = getFilteredExercises(selectedMuscles);
    final baseIds = base.map((e) => e.id).toSet();
    final extras = allExercises.where((e) => sessionPicks.contains(e.id) && !baseIds.contains(e.id));
    return [...base, ...extras];
  }

  List<Exercise> trainSearchResults(String query) {
    final q = query.trim().toLowerCase();
    if (q.isEmpty) return const [];
    return allExercises
        .where((e) => exerciseName(e).toLowerCase().contains(q) || e.name.toLowerCase().contains(q))
        .take(40)
        .toList();
  }

  static const _pickTarget = 6;

  List<Exercise> _defaultPicks(List<String> muscles) {
    final pool = getFilteredExercises(muscles);
    if (pool.length <= _pickTarget) return pool;

    int rank(Exercise e) {
      if (favorites[e.id] == true) return 0;
      if (exerciseHistory(e.id).isNotEmpty) return 1;
      return 2;
    }

    final picks = <Exercise>[];

    for (final m in muscles) {
      final forMuscle = pool.where((e) => e.primary == m && !picks.contains(e)).toList()
        ..sort((a, b) => rank(a).compareTo(rank(b)));
      if (forMuscle.isNotEmpty) picks.add(forMuscle.first);
    }
    final rest = pool.where((e) => !picks.contains(e)).toList()
      ..sort((a, b) => rank(a).compareTo(rank(b)));
    for (final e in rest) {
      if (picks.length >= _pickTarget) break;
      picks.add(e);
    }
    return picks;
  }

  void togglePick(String id) {
    if (!sessionPicks.remove(id)) sessionPicks.add(id);
    notifyListeners();
  }

  bool isPicked(String id) => sessionPicks.contains(id);

  void trainBack() {
    trainStep = 'select';
    notifyListeners();
  }

  void closeTrain() {
    route = prevRoute;
    trainStep = 'select';
    selectedMuscles.clear();
    sessionPicks.clear();
    notifyListeners();
  }

  void startRoutine(Routine r) {
    final exs = routineExercises(r);
    if (exs.isEmpty) {
      _startCustomWorkout();
      return;
    }
    _beginSession(exs, routine: r);
  }

  void startSession() {
    final exs = allExercises.where((e) => sessionPicks.contains(e.id)).toList();
    if (exs.isNotEmpty) _beginSession(exs);
  }

  void recordSessionBodyweight(double kg, {required bool before}) {
    final current = session;
    if (current == null) return;
    if (before) {
      current.bodyweightBeforeKg = kg;
    } else {
      current.bodyweightAfterKg = kg;
    }

    // Sync with history if finished
    if (current.complete && sessions.isNotEmpty) {
      final last = sessions.last;
      if (before) {
        last.bwBefore = kg;
      } else {
        last.bwAfter = kg;
      }
    }

    persistNow();
    notifyListeners();
  }

  void recordSessionPhoto(String base64, {required bool before}) {
    final current = session;
    if (current == null) return;
    if (before) {
      if (!current.photosBefore.contains(base64)) {
        current.photosBefore.add(base64);
      }
    } else {
      if (!current.photosAfter.contains(base64)) {
        current.photosAfter.add(base64);
      }
    }

    // Sync with history if finished
    if (current.complete && sessions.isNotEmpty) {
      final last = sessions.last;
      if (before) {
        if (!last.photosBefore.contains(base64)) {
          last.photosBefore.add(base64);
        }
      } else {
        if (!last.photosAfter.contains(base64)) {
          last.photosAfter.add(base64);
        }
      }
    }

    persistNow();
    notifyListeners();
  }

  void attachPhotoToSession(LoggedSession targetSession, String base64, {required bool before}) {
    if (before) {
      targetSession.photosBefore.add(base64);
    } else {
      targetSession.photosAfter.add(base64);
    }
    persistNow();
    notifyListeners();
  }

  void deleteSessionPhoto(LoggedSession targetSession, {required bool before, String? photoData}) {
    if (before) {
      if (photoData != null) {
        targetSession.photosBefore.remove(photoData);
      } else {
        targetSession.photosBefore.clear();
      }
    } else {
      if (photoData != null) {
        targetSession.photosAfter.remove(photoData);
      } else {
        targetSession.photosAfter.clear();
      }
    }
    persistNow();
    notifyListeners();
  }

  void _beginSession(List<Exercise> exs, {Routine? routine}) {
    final s = WorkoutSession();
    bodyweightStartPromptShown = false;
    bodyweightFinishPromptShown = false;
    s.exercises = exs.map((ex) {
      final cfg = routine?.configs[ex.id];
      final last = lastSetsFor(ex.id);
      final hasConfiguredWeight = cfg != null && cfg.targetWeight > 0.0;
      final targetSetsCount = cfg?.targetSets ?? (last.isNotEmpty ? last.length : 3);
      final targetReps = (cfg?.targetReps ?? 10) > 0 ? (cfg?.targetReps ?? 10) : 10;
      final defaultWeight = hasConfiguredWeight
          ? cfg.targetWeight
          : (last.isNotEmpty ? last.first.weight : 20.0);

      final sets = List.generate(
        targetSetsCount,
        (i) {
          final w = hasConfiguredWeight
              ? cfg.targetWeight
              : (i < last.length ? last[i].weight : defaultWeight);
          final r = i < last.length ? last[i].reps : targetReps;
          return SessionSet(r, w, false);
        },
      );
      return SessionExercise(ex.id, ex.localizedName(), ex.primary, sets);
    }).toList();
    _restTimer?.cancel();
    _elapsedBefore = 0;
    sessionPaused = false;
    _startTicking();
    session = s;
    route = 'session';
    persistNow();
    notifyListeners();
  }

  void _startTicking({DateTime? from}) {
    _sessionTimer?.cancel();
    _runningSince = from ?? DateTime.now();
    _sessionTimer = Timer.periodic(const Duration(seconds: 1), (_) => notifyListeners());
  }

  int get sessionElapsed => _runningSince == null
      ? _elapsedBefore
      : _elapsedBefore + DateTime.now().difference(_runningSince!).inSeconds;

  void toggleSessionPause() {
    if (sessionPaused) {
      _startTicking();
      sessionPaused = false;
    } else {
      _elapsedBefore = sessionElapsed;
      _runningSince = null;
      _sessionTimer?.cancel();
      _restTimer?.cancel();
      RestAlarm.instance.cancel();
      sessionPaused = true;
    }
    persistNow();
    notifyListeners();
  }

  String get elapsedLabel {
    final e = sessionElapsed;
    return '${(e ~/ 60).toString().padLeft(2, '0')}:${(e % 60).toString().padLeft(2, '0')}';
  }

  SessionExercise? get currentExercise {
    final s = session;
    if (s == null || s.exercises.isEmpty) return null;
    return s.exercises[s.currentIndex];
  }

  String get sessionProgressLabel {
    final s = session;
    if (s == null) return '';
    return t.exerciseXofY(s.currentIndex + 1, s.exercises.length);
  }

  void toggleSet(int exIdx, int setIdx) {
    final st = session!.exercises[exIdx].sets[setIdx];
    st.done = !st.done;
    _persist();
    notifyListeners();
    if (st.done) {
      startRest();
      final allDone = session!.exercises[exIdx].sets.every((s) => s.done);
      if (allDone) {
        if (exIdx < session!.exercises.length - 1) {
          Future.delayed(const Duration(milliseconds: 800), () {
            if (session != null && session!.currentIndex == exIdx) {
              HapticFeedback.lightImpact();
              nextExercise();
            }
          });
        } else {
          // Automatic finish on last set of last exercise
          Future.delayed(const Duration(milliseconds: 1000), () {
            if (session != null && session!.currentIndex == exIdx) {
              HapticFeedback.mediumImpact();
              finishSession();
            }
          });
        }
      }
    }
  }

  void startRest() {
    if (sessionPaused) return;
    _restTimer?.cancel();
    RestAlarm.instance.stopSound();
    session!.restRemaining = restSeconds;

    RestAlarm.instance.schedule(Duration(seconds: restSeconds));
    askAlarmPermission();
    notifyListeners();
    _restTimer = Timer.periodic(const Duration(seconds: 1), (t) {
      final s = session;
      if (s == null || s.restRemaining == null) {
        t.cancel();
        return;
      }
      final next = s.restRemaining! - 1;
      s.restRemaining = next <= 0 ? null : next;
      if (next <= 0) {
        t.cancel();

        RestAlarm.instance.fireNow();
      }
      notifyListeners();
    });
  }

  void nudgeRest(int seconds) {
    final s = session;
    if (s == null || s.restRemaining == null) return;
    final left = (s.restRemaining! + seconds).clamp(5, 600);
    s.restRemaining = left;
    RestAlarm.instance.schedule(Duration(seconds: left));
    notifyListeners();
  }

  void skipRest() {
    _restTimer?.cancel();
    RestAlarm.instance.cancel();
    RestAlarm.instance.stopSound();
    session?.restRemaining = null;
    notifyListeners();
  }

  void addSet(int exIdx) {
    final sets = session!.exercises[exIdx].sets;
    final last = sets.isNotEmpty ? sets.last : SessionSet(10, 20, false);
    sets.add(SessionSet(last.reps, last.weight, false));
    _persist();
    notifyListeners();
  }

  void bumpSessionReps(int exIdx, int setIdx, int d) =>
      setSessionReps(exIdx, setIdx, session!.exercises[exIdx].sets[setIdx].reps + d);

  void bumpSessionWeight(int exIdx, int setIdx, int dir) {
    final current = toDisplayWeight(session!.exercises[exIdx].sets[setIdx].weight);
    final next = _round1(math.max(0.0, current + dir * weightStep));
    setSessionWeight(exIdx, setIdx, fromDisplayWeight(next));
  }

  void setSessionReps(int exIdx, int setIdx, int reps) {
    session!.exercises[exIdx].sets[setIdx].reps = reps.clamp(0, 999);
    _persist();
    notifyListeners();
  }

  void setSessionWeight(int exIdx, int setIdx, double kg) {
    session!.exercises[exIdx].sets[setIdx].weight = _round3(kg.clamp(0, 1000));
    _persist();
    notifyListeners();
  }

  void setSessionWeightShown(int exIdx, int setIdx, double shown) =>
      setSessionWeight(exIdx, setIdx, fromDisplayWeight(shown));

  void removeSessionExercise(int exIdx) {
    final s = session!;
    if (exIdx < 0 || exIdx >= s.exercises.length) return;
    s.exercises.removeAt(exIdx);
    if (s.exercises.isEmpty) {
      discardSession();
      return;
    }
    s.currentIndex = s.currentIndex.clamp(0, s.exercises.length - 1);
    persistNow();
    notifyListeners();
  }

  void addExerciseToSession(String id) {
    final s = session;
    final ex = exerciseById(id);
    if (s == null || ex == null || s.exercises.any((e) => e.id == id)) return;
    final last = lastSetsFor(id);
    s.exercises.add(SessionExercise(
      ex.id,
      ex.localizedName(),
      ex.primary,
      last.isNotEmpty
          ? last.map((l) => SessionSet(l.reps, l.weight, false)).toList()
          : [SessionSet(10, 20, false), SessionSet(10, 20, false), SessionSet(10, 20, false)],
    ));
    s.currentIndex = s.exercises.length - 1;
    persistNow();
    notifyListeners();
  }

  void goToExercise(int index) {
    final s = session;
    if (s == null) return;
    s.currentIndex = index.clamp(0, s.exercises.length - 1);
    _persist();
    notifyListeners();
  }

  void nextExercise() => goToExercise((session?.currentIndex ?? 0) + 1);

  void prevExercise() => goToExercise((session?.currentIndex ?? 0) - 1);

  void finishSession() {
    _sessionTimer?.cancel();
    _restTimer?.cancel();
    RestAlarm.instance.cancel();
    final s = session!;
    final done = <SessionSet>[];
    for (final e in s.exercises) {
      for (final st in e.sets) {
        if (st.done) done.add(st);
      }
    }
    s.summaryVolume = done.fold<double>(0, (sum, st) => sum + st.reps * st.weight).round();
    s.summarySets = done.length;
    s.summaryDuration = sessionElapsed;
    s.complete = true;
    s.restRemaining = null;

    final hasPhotos = s.photosBefore.isNotEmpty || s.photosAfter.isNotEmpty;

    if (done.isNotEmpty || hasPhotos) {
      final logged = <LoggedExercise>[];
      for (final e in s.exercises) {
        final doneSets = e.sets.where((st) => st.done).map((st) => LoggedSet(st.reps, st.weight)).toList();
        if (doneSets.isNotEmpty) {
          logged.add(LoggedExercise(e.id, e.name, e.primary, doneSets));
        }
      }
      sessions.add(LoggedSession(
        DateTime.now(),
        s.summaryDuration ?? 0,
        logged,
        bwBefore: s.bodyweightBeforeKg,
        bwAfter: s.bodyweightAfterKg,
        photosBefore: s.photosBefore,
        photosAfter: s.photosAfter,
      ));
      _computeSummaryHighlights(logged);
    } else {
      summaryPrs = 0;
      summaryVsLast = null;
    }
    _checkCelebration();
    refreshAwards();
    persistNow();
    _refreshWidgets();
    notifyListeners();
  }

  double get summaryVolumeKg => (session?.summaryVolume ?? 0).toDouble();

  int summaryPrs = 0;
  double? summaryVsLast;

  void _computeSummaryHighlights(List<LoggedExercise> justLogged) {
    var prs = 0;
    for (final e in justLogged) {
      final previousBest = sessions
          .where((s) => s != sessions.last)
          .expand((s) => s.exercises)
          .where((x) => x.id == e.id)
          .fold(0.0, (m, x) => math.max(m, x.bestOneRm));
      if (e.bestOneRm > previousBest) prs++;
    }
    summaryPrs = prs;

    final ids = justLogged.map((e) => e.id).toSet();
    LoggedSession? previous;
    for (final s in sessions.reversed.skip(1)) {
      if (s.exercises.any((e) => ids.contains(e.id))) {
        previous = s;
        break;
      }
    }
    summaryVsLast = previous?.volume;
  }

  String get summaryDurationLabel {
    final d = session?.summaryDuration ?? 0;
    return '${d ~/ 60}:${(d % 60).toString().padLeft(2, '0')}';
  }

  void saveAndExit() {
    _sessionTimer?.cancel();
    _restTimer?.cancel();
    RestAlarm.instance.cancel();
    _runningSince = null;
    _elapsedBefore = 0;
    sessionPaused = false;
    session = null;
    selectedMuscles.clear();
    sessionPicks.clear();
    trainStep = 'select';
    route = 'home';
    prevRoute = 'home';
    persistNow();
    notifyListeners();
  }

  void discardSession() => saveAndExit();

  bool get isSessionActive => route == 'session' && session != null && !session!.complete;
  bool get isSessionComplete => route == 'session' && session != null && session!.complete;
}
