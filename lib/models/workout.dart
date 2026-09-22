export 'weight_entry.dart';

class LoggedSet {

  LoggedSet(this.reps, this.weight);
  final int reps;
  final double weight;
  double get volume => reps * weight;

  double get oneRm => weight * (1 + reps / 30);

  Map<String, dynamic> toJson() => {'r': reps, 'w': weight};
  factory LoggedSet.fromJson(Map<String, dynamic> j) =>
      LoggedSet((j['r'] as num).toInt(), (j['w'] as num).toDouble());
}

class LoggedExercise {
  LoggedExercise(this.id, this.name, this.primary, this.sets);
  final String id;
  final String name;
  final String primary;
  final List<LoggedSet> sets;

  double get volume => sets.fold(0.0, (s, x) => s + x.volume);
  double get topWeight => sets.isEmpty ? 0 : sets.map((s) => s.weight).reduce((a, b) => a > b ? a : b);
  double get bestOneRm => sets.isEmpty ? 0 : sets.map((s) => s.oneRm).reduce((a, b) => a > b ? a : b);

  Map<String, dynamic> toJson() => {
        'id': id,
        'n': name,
        'p': primary,
        's': sets.map((s) => s.toJson()).toList(),
      };
  factory LoggedExercise.fromJson(Map<String, dynamic> j) => LoggedExercise(
        j['id'] as String,
        j['n'] as String,
        j['p'] as String,
        (j['s'] as List).map((e) => LoggedSet.fromJson(e as Map<String, dynamic>)).toList(),
      );
}

class LoggedSession {
  LoggedSession(
    this.date,
    this.durationSec,
    this.exercises, {
    this.bwBefore,
    this.bwAfter,
    String? photoBefore,
    String? photoAfter,
    List<String>? photosBefore,
    List<String>? photosAfter,
  })  : photosBefore = photosBefore != null
            ? List<String>.from(photosBefore)
            : (photoBefore != null && photoBefore.isNotEmpty ? [photoBefore] : []),
        photosAfter = photosAfter != null
            ? List<String>.from(photosAfter)
            : (photoAfter != null && photoAfter.isNotEmpty ? [photoAfter] : []);

  final DateTime date;
  final int durationSec;
  final List<LoggedExercise> exercises;
  double? bwBefore;
  double? bwAfter;
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

  double get volume => exercises.fold(0.0, (s, e) => s + e.volume);
  int get setCount => exercises.fold(0, (s, e) => s + e.sets.length);

  Map<String, dynamic> toJson() => {
        'd': date.toIso8601String(),
        'dur': durationSec,
        'ex': exercises.map((e) => e.toJson()).toList(),
        'bwb': bwBefore,
        'bwa': bwAfter,
        'pb': photoBefore,
        'pa': photoAfter,
        'pbs': photosBefore,
        'pas': photosAfter,
      };

  factory LoggedSession.fromJson(Map<String, dynamic> j) {
    List<String> pbs = [];
    if (j['pbs'] is List) {
      pbs = (j['pbs'] as List).map((e) => e.toString()).where((e) => e.isNotEmpty).toList();
    } else if (j['pb'] is String && (j['pb'] as String).isNotEmpty) {
      pbs = [j['pb'] as String];
    }

    List<String> pas = [];
    if (j['pas'] is List) {
      pas = (j['pas'] as List).map((e) => e.toString()).where((e) => e.isNotEmpty).toList();
    } else if (j['pa'] is String && (j['pa'] as String).isNotEmpty) {
      pas = [j['pa'] as String];
    }

    return LoggedSession(
      DateTime.parse(j['d'] as String),
      (j['dur'] as num?)?.toInt() ?? 0,
      (j['ex'] as List).map((e) => LoggedExercise.fromJson(e as Map<String, dynamic>)).toList(),
      bwBefore: (j['bwb'] as num?)?.toDouble(),
      bwAfter: (j['bwa'] as num?)?.toDouble(),
      photosBefore: pbs,
      photosAfter: pas,
    );
  }
}



class ExerciseNote {
  ExerciseNote(this.date, this.text);
  final DateTime date;
  final String text;

  Map<String, dynamic> toJson() => {'d': date.toIso8601String(), 't': text};
  factory ExerciseNote.fromJson(Map<String, dynamic> j) =>
      ExerciseNote(DateTime.parse(j['d'] as String), j['t'] as String);
}

class RoutineExerciseConfig {
  RoutineExerciseConfig({
    required this.exerciseId,
    this.targetSets = 3,
    this.targetWeight = 0.0,
    this.targetReps = 10,
  });

  final String exerciseId;
  int targetSets;
  double targetWeight;
  int targetReps;

  Map<String, dynamic> toJson() => {
        'id': exerciseId,
        's': targetSets,
        'w': targetWeight,
        'r': targetReps,
      };

  factory RoutineExerciseConfig.fromJson(Map<String, dynamic> j) => RoutineExerciseConfig(
        exerciseId: j['id'] as String,
        targetSets: (j['s'] as num?)?.toInt() ?? 3,
        targetWeight: (j['w'] as num?)?.toDouble() ?? 0.0,
        targetReps: (j['r'] as num?)?.toInt() ?? 10,
      );
}

class Routine {
  Routine(this.id, this.name, this.exerciseIds, {Map<String, RoutineExerciseConfig>? configs})
      : configs = configs ?? {};

  final String id;
  String name;
  final List<String> exerciseIds;
  final Map<String, RoutineExerciseConfig> configs;

  RoutineExerciseConfig configFor(String exId) {
    return configs.putIfAbsent(
      exId,
      () => RoutineExerciseConfig(exerciseId: exId, targetSets: 3, targetWeight: 0.0, targetReps: 10),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'n': name,
        'ex': exerciseIds,
        'cfg': configs.map((k, v) => MapEntry(k, v.toJson())),
      };

  factory Routine.fromJson(Map<String, dynamic> j) {
    final cfgMap = <String, RoutineExerciseConfig>{};
    if (j['cfg'] != null) {
      final rawCfg = j['cfg'] as Map<String, dynamic>;
      rawCfg.forEach((k, v) {
        if (v is Map<String, dynamic>) {
          cfgMap[k] = RoutineExerciseConfig.fromJson(v);
        }
      });
    }
    return Routine(
      j['id'] as String,
      j['n'] as String,
      ((j['ex'] as List?) ?? []).cast<String>(),
      configs: cfgMap,
    );
  }
}
