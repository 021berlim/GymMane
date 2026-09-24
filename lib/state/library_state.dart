part of 'fit_state.dart';

mixin LibraryState on FitCore {
  String exSearch = '';
  String? exMuscleFilter;
  String? exEquipmentFilter;
  String? exDifficultyFilter;
  String? activeExerciseId;
  int exTab = 0;

  List<Exercise> _catalogExercises = [];
  List<Exercise> get catalogExercises => _catalogExercises;

  void setCatalogExercises(List<Exercise> list) {
    _catalogExercises = list;
    notifyListeners();
  }

  List<Exercise> get allExercises => [
    if (_catalogExercises.isNotEmpty) ..._catalogExercises else ...kExercises,
    ...customExercises,
  ];

  Exercise? exerciseById(String id) {
    if (_catalogExercises.isNotEmpty) {
      for (final e in _catalogExercises) {
        if (e.id == id) return e;
      }
    }
    for (final e in customExercises) {
      if (e.id == id) return e;
    }
    for (final e in kExercises) {
      if (e.id == id) return e;
    }
    return null;
  }

  void openExercise(String id) {
    if (route != 'exercise-detail') prevRoute = route;
    route = 'exercise-detail';
    activeExerciseId = id;
    notifyListeners();
  }

  void closeExerciseDetail() {
    route = prevRoute;
    notifyListeners();
  }

  void toggleFavorite(String id) {
    favorites[id] = !(favorites[id] ?? false);
    _persist();
    notifyListeners();
  }

  void setExSearch(String v) {
    exSearch = v;
    notifyListeners();
  }

  void setExTab(int tab) {
    exTab = tab;
    notifyListeners();
  }

  void clearExFilters() {
    exSearch = '';
    exMuscleFilter = null;
    exEquipmentFilter = null;
    exDifficultyFilter = null;
    exFavouritesOnly = false;
    notifyListeners();
  }

  void setMuscleFilter(String? id) {
    exMuscleFilter = exMuscleFilter == id ? null : id;
    notifyListeners();
  }

  void setEquipmentFilter(String? eq) {
    exEquipmentFilter = exEquipmentFilter == eq ? null : eq;
    notifyListeners();
  }

  void setDifficultyFilter(String? d) {
    exDifficultyFilter = exDifficultyFilter == d ? null : d;
    notifyListeners();
  }

  bool exFavouritesOnly = false;

  void toggleFavouritesFilter() {
    exFavouritesOnly = !exFavouritesOnly;
    notifyListeners();
  }

  int get favouriteCount => favorites.values.where((v) => v).length;

  List<Exercise> get exercisesFiltered {
    final rawQ = exSearch.trim();
    final q = normalizeSearchText(rawQ);
    return allExercises.where((ex) {
      if (exFavouritesOnly && favorites[ex.id] != true) return false;

      if (q.isNotEmpty) {
        final matchesId = ex.id.toLowerCase().contains(rawQ.toLowerCase());
        final matchesName = normalizeSearchText(ex.name).contains(q);
        final matchesLocName = normalizeSearchText(exerciseName(ex)).contains(q) ||
            normalizeSearchText(ex.namePt).contains(q);
        final matchesEquip = normalizeSearchText(ex.equipment).contains(q) ||
            normalizeSearchText(ex.equipmentPt).contains(q) ||
            normalizeSearchText(t.equipment(ex.equipment)).contains(q);
        final matchesMuscle = normalizeSearchText(ex.primary).contains(q) ||
            normalizeSearchText(ex.target).contains(q) ||
            normalizeSearchText(ex.targetPt).contains(q) ||
            normalizeSearchText(ex.bodyPart).contains(q) ||
            normalizeSearchText(ex.bodyPartPt).contains(q) ||
            normalizeSearchText(muscleLabel(ex.primary)).contains(q);
        final matchesSecondary = ex.secondary.any((m) => normalizeSearchText(m).contains(q)) ||
            ex.secondaryMusclesPt.any((m) => normalizeSearchText(m).contains(q));

        if (!matchesId &&
            !matchesName &&
            !matchesLocName &&
            !matchesEquip &&
            !matchesMuscle &&
            !matchesSecondary) {
          return false;
        }
      }
      if (exMuscleFilter != null) {
        final targetMuscle = exMuscleFilter!.toLowerCase();
        final matchesPrimary = ex.primary.toLowerCase() == targetMuscle ||
            ex.target.toLowerCase() == targetMuscle ||
            mapTargetToPrimaryMuscle(ex.target, ex.bodyPart).toLowerCase() == targetMuscle;
        final matchesSecondary = ex.secondary.map((s) => s.toLowerCase()).contains(targetMuscle);
        if (!matchesPrimary && !matchesSecondary) return false;
      }
      if (exEquipmentFilter != null) {
        final eqTarget = exEquipmentFilter!.toLowerCase();
        final exEq = ex.equipment.toLowerCase();
        final exEqPt = ex.equipmentPt.toLowerCase();
        final exName = ex.name.toLowerCase();
        final locName = exerciseName(ex).toLowerCase();

        bool matches = false;
        if (eqTarget == 'barbell' && (exEq == 'barbell' || exEqPt.contains('barra') || exName.contains('barbell') || locName.contains('barra'))) {
          matches = true;
        } else if (eqTarget == 'dumbbell' && (exEq == 'dumbbell' || exEqPt.contains('halter') || exName.contains('dumbbell') || locName.contains('halter'))) {
          matches = true;
        } else if (eqTarget == 'cable' && (exEq == 'cable' || exEqPt.contains('cabo') || exEqPt.contains('polia') || exName.contains('cable') || locName.contains('cabo') || locName.contains('polia'))) {
          matches = true;
        } else if (eqTarget == 'machine' && (exEq == 'machine' || exEqPt.contains('máquina') || exEqPt.contains('maquina') || exName.contains('machine') || locName.contains('máquina') || locName.contains('maquina'))) {
          matches = true;
        } else if (eqTarget == 'bodyweight' && (exEq == 'body weight' || exEq == 'bodyweight' || exEqPt.contains('corporal') || exName.contains('push-up') || exName.contains('pull-up') || locName.contains('corporal'))) {
          matches = true;
        } else if (eqTarget == 'weighted' && (exEq == 'weighted' || exEqPt.contains('anilha') || exEqPt.contains('peso') || exName.contains('plate') || locName.contains('anilha') || locName.contains('peso'))) {
          matches = true;
        } else if (eqTarget == 'band' && (exEq == 'band' || exEqPt.contains('elástico') || exEqPt.contains('elastico') || exName.contains('band') || locName.contains('elástico'))) {
          matches = true;
        } else if (eqTarget == 'kettlebell' && (exEq == 'kettlebell' || exEqPt.contains('kettlebell') || exName.contains('kettlebell'))) {
          matches = true;
        } else if (eqTarget == 'incline' && (exName.contains('incline') || locName.contains('inclinad'))) {
          matches = true;
        } else if (eqTarget == 'bench' && (exName.contains('bench') || locName.contains('banco'))) {
          matches = true;
        } else if (eqTarget == 'squat' && (exName.contains('squat') || locName.contains('agachament'))) {
          matches = true;
        } else if (exEq.contains(eqTarget) || exEqPt.contains(eqTarget) || exName.contains(eqTarget) || locName.contains(eqTarget)) {
          matches = true;
        }

        if (!matches) return false;
      }
      if (exDifficultyFilter != null && ex.difficulty != exDifficultyFilter) return false;
      return true;
    }).toList();
  }

  Exercise get activeExercise =>
      exerciseById(activeExerciseId ?? '') ?? kExercises.first;

  List<String> activeExerciseSteps(Exercise ex) => exerciseSteps(ex);

  List<ExerciseNote> notesFor(String id) => exNotes[id] ?? const [];

  void addNote(String id, String text) {
    final t = text.trim();
    if (t.isEmpty) return;
    (exNotes[id] ??= []).insert(0, ExerciseNote(DateTime.now(), t));
    _persist();
    notifyListeners();
  }

  void deleteNote(String id, int index) {
    final list = exNotes[id];
    if (list == null || index < 0 || index >= list.length) return;
    list.removeAt(index);
    if (list.isEmpty) exNotes.remove(id);
    _persist();
    notifyListeners();
  }

  List<Exercise> similarExercises(Exercise ex, int n) => allExercises
      .where((e) => e.id != ex.id && e.primary == ex.primary)
      .take(n)
      .toList();

  String addCustomExercise({
    required String name,
    required String primary,
    required String equipment,
    String difficulty = 'Beginner',
  }) {
    final id = 'c${DateTime.now().microsecondsSinceEpoch}';
    customExercises.add(Exercise(
      id: id,
      name: name.trim(),
      primary: primary,
      secondary: const [],
      equipment: equipment,
      difficulty: difficulty,
      art: '',
      steps: const [],
    ));
    _persist();
    notifyListeners();
    return id;
  }

  void deleteCustomExercise(String id) {
    final ex = exerciseById(id);
    if (ex != null && ex.media.isNotEmpty) MediaStore.delete(ex.media);
    customExercises.removeWhere((e) => e.id == id);
    for (final r in routines) {
      r.exerciseIds.remove(id);
    }
    favorites.remove(id);
    _persist();
    notifyListeners();
  }

  Future<void> attachExerciseMedia(String id, String srcPath) async {
    final i = customExercises.indexWhere((e) => e.id == id);
    if (i < 0) return;
    final old = customExercises[i].media;
    final base = await MediaStore.importFor(id, srcPath);
    if (base == null) return;
    if (old.isNotEmpty && old != base) await MediaStore.delete(old);
    customExercises[i] = customExercises[i].copyWith(media: base);
    _persist();
    notifyListeners();
  }

  void clearExerciseMedia(String id) {
    final i = customExercises.indexWhere((e) => e.id == id);
    if (i < 0) return;
    final old = customExercises[i].media;
    if (old.isNotEmpty) MediaStore.delete(old);
    customExercises[i] = customExercises[i].copyWith(media: '');
    _persist();
    notifyListeners();
  }

  bool isCustom(String id) => id.startsWith('c');

  List<Exercise> get focusRecommendations => RecommendationService.getRecommendations(profile.trainingFocus);
}
