import 'dart:convert';
import 'dart:io';

import 'package:flutter/services.dart' show rootBundle;
import 'package:sqflite/sqflite.dart';

import '../l10n/fitness_translator.dart';
import 'exercise_repository.dart';

/// Script de migração e patch semântico atômico do catálogo de exercícios para PT-BR.
///
/// Mantém estritamente os IDs originais do dataset ("0001", etc.) para preservar
/// a integridade de históricos de treinos, sessões e rotinas gravadas pelo usuário.
Future<int> applyBrazilianExercisesPatch({
  required Database db,
  String jsonPath = 'assets/data/exercicios_metadados.json',
  bool force = false,
}) async {
  // 1. Garantir que as colunas necessárias existam no schema
  await _ensureColumnsExist(db);

  // 2. Verificar se precisa rodar
  if (!force) {
    final check = await db.rawQuery(
      'SELECT COUNT(*) as total FROM ${ExerciseRepository.tableExercises} WHERE name_pt IS NOT NULL AND name_pt != ""',
    );
    final count = Sqflite.firstIntValue(check) ?? 0;
    if (count >= 1390) {
      return count;
    }
  }

  // 3. Carregar arquivo JSON de metadados
  String content = '';
  try {
    content = await rootBundle.loadString(jsonPath);
  } catch (_) {
    final f = File(jsonPath);
    if (await f.exists()) {
      content = await f.readAsString();
    } else {
      final fallbackFile = File('novas_imagens/exercicios_metadados.json');
      if (await fallbackFile.exists()) {
        content = await fallbackFile.readAsString();
      } else {
        throw Exception('Arquivo de metadados não encontrado em $jsonPath');
      }
    }
  }

  final List decoded = jsonDecode(content);

  // 4. Inserção / Atualização atômica em lotes via Batch
  const int chunkSize = 400;
  int patchedCount = 0;

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

      final secondaryMusclesJson = jsonEncode(secondaryPt);
      final instructionsJson = jsonEncode(instructionsPt);

      // Search index: id + name_en + name_pt + target_pt + equipment_pt
      final searchTerms = [
        id,
        nameEn,
        namePt,
        targetPt,
        equipPt,
        bodyPartPt,
        targetEn,
        equipEn,
      ].join(' ');
      final searchIndex = normalizeSearchText(searchTerms);

      batch.insert(
        ExerciseRepository.tableExercises,
        {
          'id': id,
          'name': nameEn,
          'name_en': nameEn,
          'name_pt': namePt,
          'body_part': bodyPartEn,
          'body_part_en': bodyPartEn,
          'body_part_pt': bodyPartPt,
          'equipment': equipEn,
          'equipment_en': equipEn,
          'equipment_pt': equipPt,
          'target': targetEn,
          'target_en': targetEn,
          'target_pt': targetPt,
          'secondary_muscles': jsonEncode(secondaryRaw),
          'secondary_muscles_en': jsonEncode(secondaryRaw),
          'secondary_muscles_pt': secondaryMusclesJson,
          'secondary_muscles_json': secondaryMusclesJson,
          'instructions': jsonEncode(instructionsRaw),
          'instructions_en': jsonEncode(instructionsRaw),
          'instructions_pt': instructionsJson,
          'instructions_json': instructionsJson,
          'gif_path': 'assets/exercises/$id.gif',
          'description': (item['description'] ?? '').toString(),
          'difficulty': (item['difficulty'] ?? 'beginner').toString(),
          'category': (item['category'] ?? 'strength').toString(),
          'search_index': searchIndex,
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
      patchedCount++;
    }

    await batch.commit(noResult: true);
  }

  // 5. Garantir a existência do índice de busca e identificadores
  await db.execute(
    'CREATE INDEX IF NOT EXISTS idx_exercises_search ON ${ExerciseRepository.tableExercises}(search_index);',
  );
  await db.execute(
    'CREATE INDEX IF NOT EXISTS idx_exercises_id ON ${ExerciseRepository.tableExercises}(id);',
  );
  await db.execute(
    'CREATE INDEX IF NOT EXISTS idx_exercises_name_pt ON ${ExerciseRepository.tableExercises}(name_pt);',
  );

  return patchedCount;
}

Future<void> _ensureColumnsExist(Database db) async {
  final info = await db.rawQuery('PRAGMA table_info(${ExerciseRepository.tableExercises})');
  final existingColumns = info.map((c) => c['name'] as String).toSet();

  final columnsToAdd = {
    'name_en': 'TEXT',
    'name_pt': 'TEXT',
    'body_part_en': 'TEXT',
    'body_part_pt': 'TEXT',
    'target_en': 'TEXT',
    'target_pt': 'TEXT',
    'equipment_en': 'TEXT',
    'equipment_pt': 'TEXT',
    'secondary_muscles_en': 'TEXT',
    'secondary_muscles_pt': 'TEXT',
    'secondary_muscles_json': 'TEXT',
    'instructions_en': 'TEXT',
    'instructions_pt': 'TEXT',
    'instructions_json': 'TEXT',
    'search_index': 'TEXT',
  };

  for (final entry in columnsToAdd.entries) {
    if (!existingColumns.contains(entry.key)) {
      try {
        await db.execute('ALTER TABLE ${ExerciseRepository.tableExercises} ADD COLUMN ${entry.key} ${entry.value}');
      } catch (_) {}
    }
  }
}
