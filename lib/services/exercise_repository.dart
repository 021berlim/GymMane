import 'package:sqflite/sqflite.dart';

import '../l10n/fitness_translator.dart';
import '../models/exercise.dart';
import 'apply_brazilian_exercises_patch.dart';

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
        name_en TEXT NOT NULL,
        name_pt TEXT NOT NULL,
        body_part TEXT,
        body_part_en TEXT,
        body_part_pt TEXT,
        equipment TEXT,
        equipment_en TEXT,
        equipment_pt TEXT,
        target TEXT,
        target_en TEXT,
        target_pt TEXT,
        secondary_muscles TEXT,
        secondary_muscles_en TEXT,
        secondary_muscles_pt TEXT,
        secondary_muscles_json TEXT,
        instructions TEXT,
        instructions_en TEXT,
        instructions_pt TEXT,
        instructions_json TEXT,
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
    await createSchema(db);
    return applyBrazilianExercisesPatch(
      db: db,
      jsonPath: jsonAssetPath,
      force: force,
    );
  }

  /// Busca otimizada e tolerante por ID, sem acento, com acento e multilíngue
  Future<List<Exercise>> searchExercises(
    Database db, {
    required String query,
    String? categoryFilter,
    int limit = 50,
    int offset = 0,
  }) async {
    final rawTrimmed = query.trim();
    final cleanQuery = normalizeSearchText(rawTrimmed);
    final whereClauses = <String>[];
    final whereArgs = <dynamic>[];

    if (cleanQuery.isNotEmpty) {
      // Verifica se é busca direta por ID numérico (ex: "0001", "45", "1")
      final isNumeric = RegExp(r'^\d+$').hasMatch(rawTrimmed);
      if (isNumeric) {
        final paddedId = rawTrimmed.padLeft(4, '0');
        whereClauses.add('(id = ? OR id LIKE ? OR search_index LIKE ?)');
        whereArgs.add(rawTrimmed);
        whereArgs.add('$paddedId%');
        whereArgs.add('%$cleanQuery%');
      } else {
        whereClauses.add('search_index LIKE ?');
        whereArgs.add('%$cleanQuery%');
      }
    }

    if (categoryFilter != null && categoryFilter.isNotEmpty && categoryFilter.toLowerCase() != 'all') {
      whereClauses.add('(target = ? OR target_en = ? OR target_pt = ? OR body_part = ? OR body_part_en = ? OR body_part_pt = ?)');
      whereArgs.add(categoryFilter);
      whereArgs.add(categoryFilter);
      whereArgs.add(categoryFilter);
      whereArgs.add(categoryFilter);
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
