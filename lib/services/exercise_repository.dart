import 'dart:convert';
import 'dart:io';
import 'package:flutter/services.dart' show rootBundle;
import 'package:sqflite/sqflite.dart';

import '../l10n/fitness_translator.dart';
import '../models/exercise.dart';

class ExerciseRepository {
  ExerciseRepository._();
  static final ExerciseRepository instance = ExerciseRepository._();

  static const String tableExercises = 'exercises';
  static const String tableLegacyMap = 'legacy_exercise_map';

  static Future<void> createSchema(Database db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS $tableExercises (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        name_pt TEXT NOT NULL,
        body_part TEXT,
        body_part_pt TEXT,
        equipment TEXT,
        equipment_pt TEXT,
        target TEXT,
        target_pt TEXT,
        secondary_muscles TEXT,
        secondary_muscles_pt TEXT,
        instructions TEXT,
        instructions_pt TEXT,
        gif_path TEXT NOT NULL,
        description TEXT,
        difficulty TEXT,
        category TEXT,
        search_index TEXT NOT NULL,
        media TEXT DEFAULT ''
      )
    ''');

    await db.execute('''
      CREATE TABLE IF NOT EXISTS $tableLegacyMap (
        legacy_id TEXT PRIMARY KEY,
        new_id TEXT NOT NULL
      )
    ''');

    await db.execute('CREATE INDEX IF NOT EXISTS idx_exercises_search ON $tableExercises(search_index);');
    await db.execute('CREATE INDEX IF NOT EXISTS idx_exercises_id ON $tableExercises(id);');
    await db.execute('CREATE INDEX IF NOT EXISTS idx_exercises_name_pt ON $tableExercises(name_pt);');
  }

  Future<int> seedDatabaseFromInitialJson({
    required Database db,
    String jsonAssetPath = 'assets/data/exercicios_metadados.json',
    bool force = false,
  }) async {
    if (!force) {
      final check = await db.rawQuery('SELECT COUNT(*) as total FROM $tableExercises');
      final currentCount = Sqflite.firstIntValue(check) ?? 0;
      if (currentCount >= 1390) return currentCount;
    } else {
      await db.delete(tableExercises);
    }

    String content;
    try {
      content = await rootBundle.loadString(jsonAssetPath);
    } catch (_) {
      final f = File(jsonAssetPath);
      if (await f.exists()) {
        content = await f.readAsString();
      } else {
        return 0;
      }
    }

    final List decoded = jsonDecode(content);

    const int chunkSize = 500;
    int insertedCount = 0;

    for (int i = 0; i < decoded.length; i += chunkSize) {
      final end = (i + chunkSize < decoded.length) ? i + chunkSize : decoded.length;
      final chunk = decoded.sublist(i, end);
      final batch = db.batch();

      for (final raw in chunk) {
        final item = raw as Map<String, dynamic>;
        final id = item['id'].toString();
        final nameEn = (item['name'] ?? '').toString();
        final namePt = FitnessTranslator.translateExerciseName(nameEn);

        final bodyPartEn = (item['bodyPart'] ?? '').toString();
        final bodyPartPt = FitnessTranslator.bodyPartsPt[bodyPartEn] ?? bodyPartEn;

        final targetEn = (item['target'] ?? '').toString();
        final targetPt = FitnessTranslator.targetMusclesPt[targetEn] ?? targetEn;

        final equipEn = (item['equipment'] ?? '').toString();
        final equipPt = FitnessTranslator.equipmentPt[equipEn] ?? equipEn;

        final secondaryRaw = (item['secondaryMuscles'] as List? ?? []).cast<String>();
        final secondaryPt = secondaryRaw
            .map((m) => FitnessTranslator.secondaryMusclesPt[m] ?? m)
            .toList();

        final instructionsRaw = (item['instructions'] as List? ?? []).cast<String>();
        final instructionsPt = FitnessTranslator.translateInstructions(instructionsRaw);

        final termsToConcat = [
          id,
          nameEn,
          namePt,
          bodyPartEn,
          bodyPartPt,
          targetEn,
          targetPt,
          equipEn,
          equipPt,
          ...secondaryRaw,
          ...secondaryPt,
        ].join(' ');

        final searchIndex = normalizeSearchText(termsToConcat);

        batch.insert(
          tableExercises,
          {
            'id': id,
            'name': nameEn,
            'name_pt': namePt,
            'body_part': bodyPartEn,
            'body_part_pt': bodyPartPt,
            'equipment': equipEn,
            'equipment_pt': equipPt,
            'target': targetEn,
            'target_pt': targetPt,
            'secondary_muscles': jsonEncode(secondaryRaw),
            'secondary_muscles_pt': jsonEncode(secondaryPt),
            'instructions': jsonEncode(instructionsRaw),
            'instructions_pt': jsonEncode(instructionsPt),
            'gif_path': 'assets/exercises/$id.gif',
            'description': (item['description'] ?? '').toString(),
            'difficulty': (item['difficulty'] ?? 'beginner').toString(),
            'category': (item['category'] ?? 'strength').toString(),
            'search_index': searchIndex,
          },
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
        insertedCount++;
      }

      await batch.commit(noResult: true);
    }

    return insertedCount;
  }

  Future<List<Exercise>> searchExercises(
    Database db, {
    required String query,
    String? categoryFilter,
    int limit = 50,
    int offset = 0,
  }) async {
    final cleanQuery = normalizeSearchText(query);
    final whereClauses = <String>[];
    final whereArgs = <dynamic>[];

    if (cleanQuery.isNotEmpty) {
      whereClauses.add('search_index LIKE ?');
      whereArgs.add('%$cleanQuery%');
    }

    if (categoryFilter != null && categoryFilter.isNotEmpty && categoryFilter.toLowerCase() != 'all') {
      whereClauses.add('(target = ? OR body_part = ?)');
      whereArgs.add(categoryFilter);
      whereArgs.add(categoryFilter);
    }

    final whereString = whereClauses.isEmpty ? null : whereClauses.join(' AND ');

    final rows = await db.query(
      tableExercises,
      where: whereString,
      whereArgs: whereArgs.isEmpty ? null : whereArgs,
      orderBy: 'name_pt ASC',
      limit: limit,
      offset: offset,
    );

    return rows.map(Exercise.fromDbMap).toList();
  }

  Future<Exercise?> getExerciseById(Database db, String id) async {
    final direct = await db.query(
      tableExercises,
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    if (direct.isNotEmpty) return Exercise.fromDbMap(direct.first);

    final mapped = await db.query(
      tableLegacyMap,
      columns: ['new_id'],
      where: 'legacy_id = ?',
      whereArgs: [id],
      limit: 1,
    );
    if (mapped.isNotEmpty) {
      final newId = mapped.first['new_id'] as String;
      return getExerciseById(db, newId);
    }

    return null;
  }

  Future<List<Exercise>> getAllExercises(Database db) async {
    final rows = await db.query(tableExercises, orderBy: 'name_pt ASC');
    return rows.map(Exercise.fromDbMap).toList();
  }
}
