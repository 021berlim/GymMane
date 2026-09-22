import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

class SqliteStore {
  SqliteStore._();
  static final SqliteStore instance = SqliteStore._();

  Database? _db;
  bool get isOpen => _db != null && _db!.isOpen;

  Future<Database> get _ensureDb async {
    if (_db == null || !_db!.isOpen) {
      await init();
    }
    if (_db == null || !_db!.isOpen) {
      throw Exception('Database failed to open.');
    }
    return _db!;
  }

  Future<void> init({String? dbPathOverride}) async {
    if (!kIsWeb && (Platform.isLinux || Platform.isWindows || Platform.isMacOS)) {
      sqfliteFfiInit();
      databaseFactory = databaseFactoryFfi;
    }

    if (_db != null && _db!.isOpen) {
      return;
    }

    final String path = await _resolveDbPath(dbPathOverride);

    try {
      _db = await openDatabase(
        path,
        version: 1,
        onConfigure: (db) async {
          try {
            await db.rawQuery('PRAGMA busy_timeout = 5000');
          } catch (_) {
            try {
              await db.execute('PRAGMA busy_timeout = 5000');
            } catch (_) {}
          }
          try {
            await db.execute('PRAGMA foreign_keys = ON');
          } catch (_) {
            try {
              await db.rawQuery('PRAGMA foreign_keys = ON');
            } catch (_) {}
          }
        },
        onCreate: _onCreate,
      );
      for (final col in ['handle', 'badge', 'banner', 'since']) {
        try {
          await _db!.execute('ALTER TABLE profiles ADD COLUMN $col TEXT');
        } catch (_) {}
      }
      await _migrateLegacyDataIfNeeded();
    } catch (e, stack) {
      debugPrint('SqliteStore.init fallo: $e\n$stack');
    }
  }

  Future<void> _migrateLegacyDataIfNeeded() async {
    try {
      final db = _db ?? await _ensureDb;
      final check = await db.query('app_settings', where: "key = 'migrated_v1'");
      if (check.isNotEmpty) return;

      if (Platform.environment.containsKey('FLUTTER_TEST')) {
        try {
          final prefs = await SharedPreferences.getInstance().timeout(
            const Duration(milliseconds: 50),
            onTimeout: () => throw TimeoutException('test env timeout'),
          );
          final raw = prefs.getString('fitiron_v1');
          if (raw != null && raw.isNotEmpty) {
            final decoded = jsonDecode(raw);
            if (decoded is Map<String, dynamic>) {
              await saveFullState(decoded);
              await prefs.remove('fitiron_v1');
            }
          }
        } catch (_) {}
        return;
      }

      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString('fitiron_v1');
      if (raw != null && raw.isNotEmpty) {
        final decoded = jsonDecode(raw);
        if (decoded is Map<String, dynamic>) {
          await saveFullState(decoded);
          await prefs.remove('fitiron_v1');
        }
      }
    } catch (e) {
      debugPrint('Legacy migration error: $e');
    }
  }

  Future<void> close() async {
    if (_db != null && _db!.isOpen) {
      await _db!.close();
      _db = null;
    }
  }

  Future<String> _resolveDbPath(String? dbPathOverride) async {
    if (dbPathOverride != null) {
      return dbPathOverride;
    }
    if (Platform.environment.containsKey('FLUTTER_TEST')) {
      return inMemoryDatabasePath;
    }
    if (!kIsWeb && (Platform.isLinux || Platform.isWindows || Platform.isMacOS)) {
      try {
        final appSupportDir = await getApplicationSupportDirectory();
        final dbDir = Directory(p.join(appSupportDir.path, 'fitiron'));
        if (!await dbDir.exists()) await dbDir.create(recursive: true);
        final targetPath = p.join(dbDir.path, 'fitiron.db');
        if (!File(targetPath).existsSync()) {
          try {
            final oldPath = p.join(await getDatabasesPath(), 'fitiron.db');
            if (File(oldPath).existsSync()) {
              await File(oldPath).copy(targetPath);
            }
          } catch (_) {}
        }
        return targetPath;
      } catch (_) {}
    }
    final dbDir = await getDatabasesPath();
    return p.join(dbDir, 'fitiron.db');
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE profiles (
        id INTEGER PRIMARY KEY CHECK (id = 1),
        name TEXT NOT NULL,
        sex TEXT NOT NULL,
        age INTEGER NOT NULL,
        height_cm REAL NOT NULL,
        weight_kg REAL NOT NULL,
        activity REAL NOT NULL,
        weekly_goal INTEGER NOT NULL,
        photo TEXT NOT NULL,
        training_focus TEXT NOT NULL,
        handle TEXT,
        badge TEXT,
        banner TEXT,
        since TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE app_settings (
        key TEXT PRIMARY KEY,
        value TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE sessions (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        date TEXT NOT NULL,
        duration_sec INTEGER NOT NULL,
        bw_before REAL,
        bw_after REAL,
        photo_before TEXT,
        photo_after TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE session_exercises (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        session_id INTEGER NOT NULL,
        exercise_id TEXT NOT NULL,
        name TEXT NOT NULL,
        primary_muscle TEXT NOT NULL,
        sort_order INTEGER NOT NULL DEFAULT 0,
        FOREIGN KEY (session_id) REFERENCES sessions (id) ON DELETE CASCADE
      )
    ''');

    await db.execute('''
      CREATE TABLE session_sets (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        session_exercise_id INTEGER NOT NULL,
        reps INTEGER NOT NULL,
        weight REAL NOT NULL,
        sort_order INTEGER NOT NULL DEFAULT 0,
        FOREIGN KEY (session_exercise_id) REFERENCES session_exercises (id) ON DELETE CASCADE
      )
    ''');

    await db.execute('''
      CREATE TABLE bodyweight (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        date TEXT NOT NULL,
        weight_kg REAL NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE exercise_notes (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        exercise_name TEXT NOT NULL,
        date TEXT NOT NULL,
        text TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE routines (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE routine_exercises (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        routine_id TEXT NOT NULL,
        exercise_id TEXT NOT NULL,
        target_sets INTEGER NOT NULL DEFAULT 3,
        target_weight REAL NOT NULL DEFAULT 0.0,
        target_reps INTEGER NOT NULL DEFAULT 10,
        sort_order INTEGER NOT NULL DEFAULT 0,
        FOREIGN KEY (routine_id) REFERENCES routines (id) ON DELETE CASCADE
      )
    ''');

    await db.execute('''
      CREATE TABLE custom_exercises (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        primary_muscle TEXT NOT NULL,
        equipment TEXT NOT NULL DEFAULT 'Other',
        difficulty TEXT NOT NULL DEFAULT 'Beginner',
        media TEXT NOT NULL DEFAULT ''
      )
    ''');

    await db.execute('''
      CREATE TABLE goals (
        id TEXT PRIMARY KEY,
        type TEXT NOT NULL,
        target REAL NOT NULL,
        exercise_id TEXT,
        is_primary INTEGER NOT NULL DEFAULT 0
      )
    ''');
  }

  Future<Map<String, dynamic>> loadFullState() async {
    final Map<String, dynamic> result = {};
    Database database;
    try {
      database = await _ensureDb;
    } catch (e) {
      debugPrint('SqliteStore.loadFullState _ensureDb error: $e');
      return result;
    }

    // 1. Profile
    try {
      final profilesList = await database.query('profiles', where: 'id = 1');
      if (profilesList.isNotEmpty) {
        final pRow = profilesList.first;
        result['profile'] = {
          'name': pRow['name'],
          'sex': pRow['sex'],
          'age': pRow['age'],
          'h': pRow['height_cm'],
          'w': pRow['weight_kg'],
          'act': pRow['activity'],
          'goal': pRow['weekly_goal'],
          'photo': pRow['photo'],
          'focus': pRow['training_focus'],
          if (pRow['handle'] != null) 'handle': pRow['handle'],
          if (pRow['badge'] != null) 'badge': pRow['badge'],
          if (pRow['banner'] != null) 'banner': pRow['banner'],
          if (pRow['since'] != null) 'since': pRow['since'],
        };
      }
    } catch (e) {
      debugPrint('SqliteStore profile query error: $e');
    }

    // 2. App Settings
    try {
      final settingsList = await database.query('app_settings');
      final Map<String, String> settingsMap = {
        for (final s in settingsList) s['key'] as String: s['value'] as String,
      };

      if (settingsMap.containsKey('dark')) {
        result['dark'] = settingsMap['dark'] == 'true';
      }
      if (settingsMap.containsKey('units')) {
        result['units'] = settingsMap['units'];
      }
      if (settingsMap.containsKey('language')) {
        result['language'] = settingsMap['language'];
      }
      if (settingsMap.containsKey('rest')) {
        result['rest'] = int.tryParse(settingsMap['rest']!);
      }
      if (settingsMap.containsKey('alarmSound')) {
        result['alarmSound'] = settingsMap['alarmSound'];
      }
      if (settingsMap.containsKey('alarmSoundName')) {
        result['alarmSoundName'] = settingsMap['alarmSoundName'];
      }
      if (settingsMap.containsKey('bg')) {
        result['bg'] = settingsMap['bg'];
      }
      if (settingsMap.containsKey('alarmAskedAt')) {
        result['alarmAskedAt'] = int.tryParse(settingsMap['alarmAskedAt']!);
      }
      if (settingsMap.containsKey('onboarded')) {
        result['onboarded'] = settingsMap['onboarded'] == 'true';
      }
      if (settingsMap.containsKey('enablePhotos')) {
        result['enablePhotos'] = settingsMap['enablePhotos'] == 'true';
      }
      if (settingsMap.containsKey('photoTiming')) {
        result['photoTiming'] = settingsMap['photoTiming'];
      }

      if (settingsMap.containsKey('favorites')) {
        try {
          result['favorites'] = jsonDecode(settingsMap['favorites']!);
        } catch (_) {}
      }
      if (settingsMap.containsKey('checkins')) {
        try {
          result['checkins'] = jsonDecode(settingsMap['checkins']!);
        } catch (_) {}
      }
      if (settingsMap.containsKey('weeklyPlan')) {
        try {
          result['weeklyPlan'] = jsonDecode(settingsMap['weeklyPlan']!);
        } catch (_) {}
      }

      if (settingsMap.containsKey('live')) {
        try {
          result['live'] = jsonDecode(settingsMap['live']!);
        } catch (_) {}
      }
      if (settingsMap.containsKey('liveStart')) {
        result['liveStart'] = settingsMap['liveStart'];
      }
      if (settingsMap.containsKey('liveElapsed')) {
        result['liveElapsed'] = int.tryParse(settingsMap['liveElapsed']!);
      }
      if (settingsMap.containsKey('livePaused')) {
        result['livePaused'] = settingsMap['livePaused'] == 'true';
      }

      if (settingsMap.containsKey('awards')) {
        try {
          result['awards'] = jsonDecode(settingsMap['awards']!);
        } catch (_) {}
      }
      if (settingsMap.containsKey('awardsSeen')) {
        try {
          result['awardsSeen'] = jsonDecode(settingsMap['awardsSeen']!);
        } catch (_) {}
      }
      if (settingsMap.containsKey('gamification')) {
        result['gamification'] = settingsMap['gamification'];
      }
    } catch (e) {
      debugPrint('SqliteStore app_settings query error: $e');
    }

    // 3. Exercise Notes
    try {
      final notesRows = await database.query('exercise_notes', orderBy: 'id ASC');
      if (notesRows.isNotEmpty) {
        final Map<String, List<Map<String, dynamic>>> exNotes = {};
        for (final row in notesRows) {
          final exName = row['exercise_name'] as String;
          exNotes.putIfAbsent(exName, () => []).add({
            'd': row['date'],
            't': row['text'],
          });
        }
        result['exNotes'] = exNotes;
      }
    } catch (e) {
      debugPrint('SqliteStore exercise_notes query error: $e');
    }

    // 4. Routines
    try {
      final routinesRows = await database.query('routines');
      if (routinesRows.isNotEmpty) {
        final List<Map<String, dynamic>> routinesList = [];
        for (final rRow in routinesRows) {
          final rId = rRow['id'] as String;
          final rName = rRow['name'] as String;

          final rExRows = await database.query(
            'routine_exercises',
            where: 'routine_id = ?',
            whereArgs: [rId],
            orderBy: 'sort_order ASC',
          );

          final List<String> exIds = [];
          final Map<String, dynamic> cfgMap = {};

          for (final re in rExRows) {
            final exId = re['exercise_id'] as String;
            exIds.add(exId);
            cfgMap[exId] = {
              'id': exId,
              's': re['target_sets'],
              'w': re['target_weight'],
              'r': re['target_reps'],
            };
          }

          routinesList.add({
            'id': rId,
            'n': rName,
            'ex': exIds,
            'cfg': cfgMap,
          });
        }
        result['routines'] = routinesList;
      }
    } catch (e) {
      debugPrint('SqliteStore routines query error: $e');
    }

    // 5. Custom Exercises
    try {
      final customRows = await database.query('custom_exercises');
      if (customRows.isNotEmpty) {
        result['custom'] = customRows
            .map((c) => {
                  'id': c['id'],
                  'n': c['name'],
                  'p': c['primary_muscle'],
                  'e': c['equipment'],
                  'd': c['difficulty'],
                  if ((c['media'] as String? ?? '').isNotEmpty) 'm': c['media'],
                })
            .toList();
      }
    } catch (e) {
      debugPrint('SqliteStore custom_exercises query error: $e');
    }

    // 6. Bodyweight
    try {
      final bwRows = await database.query('bodyweight', orderBy: 'id ASC');
      if (bwRows.isNotEmpty) {
        result['bodyweight'] = bwRows
            .map((b) => {
                  'd': b['date'],
                  'kg': b['weight_kg'],
                })
            .toList();
      }
    } catch (e) {
      debugPrint('SqliteStore bodyweight query error: $e');
    }

    // 7. Goals
    try {
      final goalRows = await database.query('goals');
      if (goalRows.isNotEmpty) {
        result['goals'] = goalRows
            .map((g) => {
                  'id': g['id'],
                  'type': g['type'],
                  'val': g['target'],
                  'exId': g['exercise_id'],
                  'pri': (g['is_primary'] as int) == 1,
                })
            .toList();
      }
    } catch (e) {
      debugPrint('SqliteStore goals query error: $e');
    }

    // 8. Sessions
    try {
      final sessionRows = await database.query('sessions', orderBy: 'id ASC');
      if (sessionRows.isNotEmpty) {
        final List<Map<String, dynamic>> sessionsList = [];
        for (final sRow in sessionRows) {
          final sId = sRow['id'] as int;

          final exRows = await database.query(
            'session_exercises',
            where: 'session_id = ?',
            whereArgs: [sId],
            orderBy: 'sort_order ASC',
          );

          final List<Map<String, dynamic>> exList = [];
          for (final eRow in exRows) {
            final seId = eRow['id'] as int;

            final setRows = await database.query(
              'session_sets',
              where: 'session_exercise_id = ?',
              whereArgs: [seId],
              orderBy: 'sort_order ASC',
            );

            final List<Map<String, dynamic>> setList = setRows
                .map((st) => {
                      'r': st['reps'],
                      'w': st['weight'],
                    })
                .toList();

            exList.add({
              'id': eRow['exercise_id'],
              'n': eRow['name'],
              'p': eRow['primary_muscle'],
              's': setList,
            });
          }

          List<String> decodePhotos(dynamic raw) {
            if (raw == null) return [];
            final trimmed = raw.toString().trim();
            if (trimmed.isEmpty) return [];
            if (trimmed.startsWith('[') && trimmed.endsWith(']')) {
              try {
                final decoded = jsonDecode(trimmed);
                if (decoded is List) {
                  return decoded.map((e) => e.toString()).where((e) => e.isNotEmpty).toList();
                }
              } catch (_) {}
            }
            return [trimmed];
          }

          final pbList = decodePhotos(sRow['photo_before']);
          final paList = decodePhotos(sRow['photo_after']);

          sessionsList.add({
            'd': sRow['date'],
            'dur': sRow['duration_sec'],
            'ex': exList,
            if (sRow['bw_before'] != null) 'bwb': sRow['bw_before'],
            if (sRow['bw_after'] != null) 'bwa': sRow['bw_after'],
            if (pbList.isNotEmpty) 'pb': pbList.first,
            if (paList.isNotEmpty) 'pa': paList.first,
            if (pbList.isNotEmpty) 'pbs': pbList,
            if (paList.isNotEmpty) 'pas': paList,
          });
        }
        result['sessions'] = sessionsList;
      }
    } catch (e) {
      debugPrint('SqliteStore sessions query error: $e');
    }

    return result;
  }

  Future<void> saveFullState(Map<String, dynamic> data) async {
    if (data.isEmpty) return;
    final database = await _ensureDb;
    await database.transaction((txn) async {
      await txn.delete('profiles');
      await txn.delete('app_settings');
      await txn.delete('sessions');
      await txn.delete('session_exercises');
      await txn.delete('session_sets');
      await txn.delete('bodyweight');
      await txn.delete('exercise_notes');
      await txn.delete('routines');
      await txn.delete('routine_exercises');
      await txn.delete('custom_exercises');
      await txn.delete('goals');

      if (data.isEmpty) return;

      // 1. Profile
      final pMap = data['profile'] as Map?;
      if (pMap != null) {
        await txn.insert('profiles', {
          'id': 1,
          'name': (pMap['name'] as String?) ?? 'InlitX',
          'sex': (pMap['sex'] as String?) ?? 'male',
          'age': (pMap['age'] as num?)?.toInt() ?? 28,
          'height_cm': (pMap['h'] as num?)?.toDouble() ?? 175,
          'weight_kg': (pMap['w'] as num?)?.toDouble() ?? 75,
          'activity': (pMap['act'] as num?)?.toDouble() ?? 1.55,
          'weekly_goal': (pMap['goal'] as num?)?.toInt() ?? 4,
          'photo': (pMap['photo'] as String?) ?? '',
          'training_focus': (pMap['focus'] as String?) ?? 'health',
          'handle': (pMap['handle'] as String?) ?? '',
          'badge': (pMap['badge'] as String?) ?? 'blue',
          'banner': (pMap['banner'] as String?) ?? '',
          'since': (pMap['since'] as String?) ?? '',
        });
      }

      // 2. Settings
      Future<void> saveSetting(String k, Object? v) async {
        if (v == null) return;
        await txn.insert(
          'app_settings',
          {'key': k, 'value': v is String ? v : jsonEncode(v)},
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      }

      if (data.containsKey('dark')) await saveSetting('dark', data['dark'].toString());
      if (data.containsKey('units')) await saveSetting('units', data['units']);
      if (data.containsKey('language')) await saveSetting('language', data['language']);
      if (data.containsKey('rest')) await saveSetting('rest', data['rest'].toString());
      if (data.containsKey('alarmSound')) await saveSetting('alarmSound', data['alarmSound']);
      if (data.containsKey('alarmSoundName')) await saveSetting('alarmSoundName', data['alarmSoundName']);
      if (data.containsKey('bg')) await saveSetting('bg', data['bg']);
      if (data.containsKey('alarmAskedAt')) await saveSetting('alarmAskedAt', data['alarmAskedAt'].toString());
      if (data.containsKey('onboarded')) await saveSetting('onboarded', data['onboarded'].toString());
      if (data.containsKey('enablePhotos')) await saveSetting('enablePhotos', data['enablePhotos'].toString());
      if (data.containsKey('photoTiming')) await saveSetting('photoTiming', data['photoTiming']);

      if (data.containsKey('favorites')) await saveSetting('favorites', data['favorites']);
      if (data.containsKey('checkins')) await saveSetting('checkins', data['checkins']);
      if (data.containsKey('weeklyPlan')) await saveSetting('weeklyPlan', data['weeklyPlan']);

      if (data.containsKey('live')) await saveSetting('live', data['live']);
      if (data.containsKey('liveStart')) await saveSetting('liveStart', data['liveStart']);
      if (data.containsKey('liveElapsed')) await saveSetting('liveElapsed', data['liveElapsed'].toString());
      if (data.containsKey('livePaused')) await saveSetting('livePaused', data['livePaused'].toString());

      if (data.containsKey('awards')) await saveSetting('awards', data['awards']);
      if (data.containsKey('awardsSeen')) await saveSetting('awardsSeen', data['awardsSeen']);
      if (data.containsKey('gamification')) await saveSetting('gamification', data['gamification'].toString());

      // Mark migration done
      await saveSetting('migrated_v1', 'true');

      // 3. Exercise Notes
      final exNotesMap = data['exNotes'] as Map?;
      if (exNotesMap != null) {
        for (final entry in exNotesMap.entries) {
          final exName = entry.key as String;
          final notesList = entry.value as List;
          for (final n in notesList) {
            final nMap = (n as Map).cast<String, dynamic>();
            await txn.insert('exercise_notes', {
              'exercise_name': exName,
              'date': nMap['d'] as String,
              'text': nMap['t'] as String,
            });
          }
        }
      } else {
        final oldNotes = data['notes'] as Map?;
        if (oldNotes != null) {
          for (final entry in oldNotes.entries) {
            final exName = entry.key as String;
            final txt = (entry.value as String).trim();
            if (txt.isNotEmpty) {
              await txn.insert('exercise_notes', {
                'exercise_name': exName,
                'date': DateTime.now().toIso8601String(),
                'text': txt,
              });
            }
          }
        }
      }

      // 4. Routines
      final routinesList = data['routines'] as List?;
      if (routinesList != null) {
        for (final r in routinesList) {
          if (r is! Map) continue;
          final rMap = r.cast<String, dynamic>();
          final rId = rMap['id'] as String?;
          final rName = rMap['n'] as String?;
          if (rId == null || rName == null) continue;

          await txn.insert('routines', {
            'id': rId,
            'name': rName,
          });

          final exIds = ((rMap['ex'] as List?) ?? []).whereType<String>().toList();
          final cfgMap = (rMap['cfg'] as Map?)?.cast<String, dynamic>() ?? {};

          for (var i = 0; i < exIds.length; i++) {
            final exId = exIds[i];
            final c = cfgMap[exId] as Map?;
            final targetSets = (c?['s'] as num?)?.toInt() ?? 3;
            final targetWeight = (c?['w'] as num?)?.toDouble() ?? 0.0;
            final targetReps = (c?['r'] as num?)?.toInt() ?? 10;

            await txn.insert('routine_exercises', {
              'routine_id': rId,
              'exercise_id': exId,
              'target_sets': targetSets,
              'target_weight': targetWeight,
              'target_reps': targetReps,
              'sort_order': i,
            });
          }
        }
      }

      // 5. Custom Exercises
      final customList = data['custom'] as List?;
      if (customList != null) {
        for (final c in customList) {
          if (c is! Map) continue;
          final cMap = c.cast<String, dynamic>();
          final cId = cMap['id'] as String?;
          final cName = cMap['n'] as String?;
          if (cId == null || cName == null) continue;
          await txn.insert('custom_exercises', {
            'id': cId,
            'name': cName,
            'primary_muscle': (cMap['p'] as String?) ?? 'other',
            'equipment': (cMap['e'] as String?) ?? 'Other',
            'difficulty': (cMap['d'] as String?) ?? 'Beginner',
            'media': (cMap['m'] as String?) ?? '',
          });
        }
      }

      // 6. Bodyweight
      final bwList = data['bodyweight'] as List?;
      if (bwList != null) {
        for (final b in bwList) {
          if (b is! Map) continue;
          final bMap = b.cast<String, dynamic>();
          final dStr = bMap['d'] as String?;
          final kgNum = bMap['kg'] as num?;
          if (dStr == null || kgNum == null) continue;
          await txn.insert('bodyweight', {
            'date': dStr,
            'weight_kg': kgNum.toDouble(),
          });
        }
      }

      // 7. Goals
      final goalsList = data['goals'] as List?;
      if (goalsList != null) {
        for (final g in goalsList) {
          if (g is! Map) continue;
          final gMap = g.cast<String, dynamic>();
          final gId = gMap['id'] as String?;
          final gType = gMap['type'] as String?;
          final gVal = gMap['val'] as num?;
          if (gId == null || gType == null || gVal == null) continue;
          await txn.insert('goals', {
            'id': gId,
            'type': gType,
            'target': gVal.toDouble(),
            'exercise_id': gMap['exId'] as String?,
            'is_primary': (gMap['pri'] as bool? ?? false) ? 1 : 0,
          });
        }
      }

      // 8. Sessions
      final sessionsList = data['sessions'] as List?;
      if (sessionsList != null) {
        for (final s in sessionsList) {
          if (s is! Map) continue;
          final sMap = s.cast<String, dynamic>();
          final dateStr = sMap['d'] as String?;
          if (dateStr == null) continue;
          String? encodePhotos(dynamic pList, dynamic pSingle) {
            if (pList is List && pList.isNotEmpty) {
              final strList = pList.map((e) => e.toString()).where((e) => e.isNotEmpty).toList();
              if (strList.isEmpty) return null;
              if (strList.length == 1) return strList.first;
              return jsonEncode(strList);
            }
            if (pSingle is String && pSingle.isNotEmpty) {
              return pSingle;
            }
            return null;
          }

          final sessionId = await txn.insert('sessions', {
            'date': dateStr,
            'duration_sec': (sMap['dur'] as num?)?.toInt() ?? 0,
            'bw_before': (sMap['bwb'] as num?)?.toDouble(),
            'bw_after': (sMap['bwa'] as num?)?.toDouble(),
            'photo_before': encodePhotos(sMap['pbs'], sMap['pb']),
            'photo_after': encodePhotos(sMap['pas'], sMap['pa']),
          });

          final exList = (sMap['ex'] as List?) ?? [];
          for (var i = 0; i < exList.length; i++) {
            final eMap = (exList[i] as Map).cast<String, dynamic>();
            final sessionExId = await txn.insert('session_exercises', {
              'session_id': sessionId,
              'exercise_id': eMap['id'] as String,
              'name': eMap['n'] as String,
              'primary_muscle': eMap['p'] as String,
              'sort_order': i,
            });

            final setList = (eMap['s'] as List?) ?? [];
            for (var j = 0; j < setList.length; j++) {
              final stMap = (setList[j] as Map).cast<String, dynamic>();
              await txn.insert('session_sets', {
                'session_exercise_id': sessionExId,
                'reps': (stMap['r'] as num).toInt(),
                'weight': (stMap['w'] as num).toDouble(),
                'sort_order': j,
              });
            }
          }
        }
      }
    });
  }

  Future<void> clearAll() async {
    await saveFullState({});
  }
}
