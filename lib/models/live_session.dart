class SessionSet {
  SessionSet(this.reps, this.weight, this.done);
  int reps;
  double weight;
  bool done;

  Map<String, dynamic> toJson() => {'r': reps, 'w': weight, 'd': done};
  factory SessionSet.fromJson(Map<String, dynamic> j) => SessionSet(
        (j['r'] as num).toInt(),
        (j['w'] as num).toDouble(),
        j['d'] as bool? ?? false,
      );
}

class SessionExercise {
  SessionExercise(this.id, this.name, this.primary, this.sets);
  final String id;
  final String name;
  final String primary;
  final List<SessionSet> sets;

  Map<String, dynamic> toJson() => {
        'id': id,
        'n': name,
        'p': primary,
        's': sets.map((s) => s.toJson()).toList(),
      };
  factory SessionExercise.fromJson(Map<String, dynamic> j) => SessionExercise(
        j['id'] as String,
        j['n'] as String,
        j['p'] as String,
        (j['s'] as List).map((e) => SessionSet.fromJson((e as Map).cast<String, dynamic>())).toList(),
      );
}

class WorkoutSession {
  WorkoutSession({
    List<String>? photosBefore,
    List<String>? photosAfter,
    String? photoBefore,
    String? photoAfter,
  })  : photosBefore = photosBefore != null
            ? List<String>.from(photosBefore)
            : (photoBefore != null && photoBefore.isNotEmpty ? [photoBefore] : []),
        photosAfter = photosAfter != null
            ? List<String>.from(photosAfter)
            : (photoAfter != null && photoAfter.isNotEmpty ? [photoAfter] : []);

  List<SessionExercise> exercises = [];
  int currentIndex = 0;
  bool complete = false;
  bool manual = false;
  DateTime? loggedAt;
  DateTime? restEndsAt;
  int? restFrozen;
  int? _legacyRestRemaining;

  int? get restRemaining {
    final frozen = restFrozen;
    if (frozen != null) return frozen;
    final end = restEndsAt;
    if (end != null) {
      final left = end.difference(DateTime.now()).inMilliseconds;
      return left <= 0 ? null : (left / 1000).ceil();
    }
    return _legacyRestRemaining;
  }

  set restRemaining(int? val) {
    _legacyRestRemaining = val;
    if (val == null) {
      restEndsAt = null;
      restFrozen = null;
    } else {
      restEndsAt = DateTime.now().add(Duration(seconds: val));
    }
  }

  void clearRest() {
    restEndsAt = null;
    restFrozen = null;
    _legacyRestRemaining = null;
  }

  int? summaryVolume;
  int? summarySets;
  int? summaryDuration;
  double? bodyweightBeforeKg;
  double? bodyweightAfterKg;
  List<String> photosBefore;
  List<String> photosAfter;

  String? get photoBefore => photosBefore.firstOrNull;
  set photoBefore(String? val) {
    if (val == null || val.isEmpty) {
      photosBefore.clear();
    } else {
      if (photosBefore.isEmpty) {
        photosBefore.add(val);
      } else {
        photosBefore[0] = val;
      }
    }
  }

  String? get photoAfter => photosAfter.firstOrNull;
  set photoAfter(String? val) {
    if (val == null || val.isEmpty) {
      photosAfter.clear();
    } else {
      if (photosAfter.isEmpty) {
        photosAfter.add(val);
      } else {
        photosAfter[0] = val;
      }
    }
  }

  Map<String, dynamic> toJson() => {
        'ex': exercises.map((e) => e.toJson()).toList(),
        'i': currentIndex,
        'c': complete,
        if (manual) 'm': true,
        if (loggedAt != null) 'at': loggedAt!.toIso8601String(),
        if (restEndsAt != null) 're': restEndsAt!.toIso8601String(),
        if (restFrozen != null) 'rf': restFrozen,
        if (restRemaining != null) 'rr': restRemaining,
        'sv': summaryVolume,
        'ss': summarySets,
        'sd': summaryDuration,
        'bwBefore': bodyweightBeforeKg,
        'bwAfter': bodyweightAfterKg,
        'pb': photoBefore,
        'pa': photoAfter,
        'pbs': photosBefore,
        'pas': photosAfter,
      };

  factory WorkoutSession.fromJson(Map<String, dynamic> j) {
    final pbs = (j['pbs'] as List?)?.map((e) => e.toString()).where((e) => e.isNotEmpty).toList() ??
        (j['pb'] != null && (j['pb'] as String).isNotEmpty ? [j['pb'] as String] : <String>[]);
    final pas = (j['pas'] as List?)?.map((e) => e.toString()).where((e) => e.isNotEmpty).toList() ??
        (j['pa'] != null && (j['pa'] as String).isNotEmpty ? [j['pa'] as String] : <String>[]);

    return WorkoutSession(
      photosBefore: pbs,
      photosAfter: pas,
    )
      ..exercises =
          (j['ex'] as List).map((e) => SessionExercise.fromJson((e as Map).cast<String, dynamic>())).toList()
      ..currentIndex = (j['i'] as num?)?.toInt() ?? 0
      ..complete = j['c'] as bool? ?? false
      ..manual = j['m'] as bool? ?? false
      ..loggedAt = DateTime.tryParse((j['at'] as String?) ?? '')
      ..restEndsAt = DateTime.tryParse((j['re'] as String?) ?? '')
      ..restFrozen = (j['rf'] as num?)?.toInt()
      .._legacyRestRemaining = (j['rr'] as num?)?.toInt()
      ..summaryVolume = (j['sv'] as num?)?.toInt()
      ..summarySets = (j['ss'] as num?)?.toInt()
      ..summaryDuration = (j['sd'] as num?)?.toInt()
      ..bodyweightBeforeKg = (j['bwBefore'] as num?)?.toDouble()
      ..bodyweightAfterKg = (j['bwAfter'] as num?)?.toDouble();
  }
}
