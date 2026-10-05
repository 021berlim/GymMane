import 'dart:convert';
import 'package:flutter/widgets.dart';
import '../l10n/fitness_translator.dart';
import '../l10n/l10n.dart';
import 'cardio_config.dart';

export 'cardio_config.dart';
export '../l10n/fitness_translator.dart' show normalizeSearchText;

class Muscle {
  const Muscle(this.id, this.label, this.view);
  final String id;
  final String label;
  final String view;
}

class Exercise {
  const Exercise({
    required this.id,
    required this.name,
    this.namePt = '',
    this.bodyPart = 'other',
    this.bodyPartPt = 'Outros',
    this.equipment = 'Other',
    this.equipmentPt = 'Outros',
    this.target = 'other',
    this.targetPt = 'Geral',
    this.secondaryMuscles = const [],
    this.secondaryMusclesPt = const [],
    this.instructions = const [],
    this.instructionsPt = const [],
    this.gifPath = '',
    this.description = '',
    this.difficulty = 'Beginner',
    this.category = 'strength',
    this.media = '',
    String? primary,
    List<String>? secondary,
    String? art,
    List<String>? steps,
  })  : _primary = primary,
        _secondary = secondary,
        _art = art,
        _steps = steps;

  final String id;
  final String name;
  final String namePt;
  final String bodyPart;
  final String bodyPartPt;
  final String equipment;
  final String equipmentPt;
  final String target;
  final String targetPt;
  final List<String> secondaryMuscles;
  final List<String> secondaryMusclesPt;
  final List<String> instructions;
  final List<String> instructionsPt;
  final String gifPath;
  final String description;
  final String difficulty;
  final String category;
  final String media;

  final String? _primary;
  final List<String>? _secondary;
  final String? _art;
  final List<String>? _steps;

  String get nameEn => name;
  String get bodyPartEn => bodyPart;
  String get targetEn => target;
  String get equipmentEn => equipment;
  List<String> get secondaryMusclesEn => secondaryMuscles;
  List<String> get instructionsEn => instructions;

  // -------------------------------------------------------------
  // Helpers de Localização Contextual Reativa
  // -------------------------------------------------------------
  String localizedName([BuildContext? context]) {
    final bool isPt = context != null
        ? Localizations.localeOf(context).languageCode == 'pt'
        : appLanguage == 'pt';
    if (isPt && namePt.trim().isNotEmpty) {
      return namePt;
    }
    return exerciseName(this);
  }

  String getLocalizedName([BuildContext? context]) => localizedName(context);

  List<String> getLocalizedInstructions([BuildContext? context]) {
    final bool isPt = context != null
        ? Localizations.localeOf(context).languageCode == 'pt'
        : appLanguage == 'pt';
    if (isPt && instructionsPt.isNotEmpty) return instructionsPt;
    return steps;
  }

  String getLocalizedBodyPart([BuildContext? context]) {
    final bool isPt = context != null
        ? Localizations.localeOf(context).languageCode == 'pt'
        : appLanguage == 'pt';
    if (isPt && bodyPartPt.isNotEmpty) return bodyPartPt;
    return bodyPart;
  }

  String getLocalizedTarget([BuildContext? context]) {
    final bool isPt = context != null
        ? Localizations.localeOf(context).languageCode == 'pt'
        : appLanguage == 'pt';
    if (isPt && targetPt.isNotEmpty) return targetPt;
    return muscleLabel(primary);
  }

  List<String> getLocalizedSecondaryMuscles([BuildContext? context]) {
    final bool isPt = context != null
        ? Localizations.localeOf(context).languageCode == 'pt'
        : appLanguage == 'pt';
    if (isPt && secondaryMusclesPt.isNotEmpty) return secondaryMusclesPt;
    return secondary;
  }

  String getLocalizedEquipment([BuildContext? context]) {
    final bool isPt = context != null
        ? Localizations.localeOf(context).languageCode == 'pt'
        : appLanguage == 'pt';
    if (isPt && equipmentPt.isNotEmpty) return equipmentPt;
    return t.equipment(equipment);
  }

  // Getters de retrocompatibilidade com telas legadas
  String get primary => _primary ?? mapTargetToPrimaryMuscle(target, bodyPart);
  List<String> get secondary => _secondary ?? (secondaryMusclesPt.isNotEmpty && appLanguage == 'pt' ? secondaryMusclesPt : secondaryMuscles);
  List<String> get steps => _steps ?? (instructionsPt.isNotEmpty && appLanguage == 'pt' ? instructionsPt : instructions);
  String get art => _art ?? id;

  bool get isCardio => isExerciseCardio(
        id: id,
        name: name,
        namePt: namePt,
        primary: primary,
        bodyPart: bodyPart,
        bodyPartPt: bodyPartPt,
        target: target,
        targetPt: targetPt,
        category: category,
        equipment: equipment,
        equipmentPt: equipmentPt,
      );

  CardioCategoryType get cardioType => detectCardioType(
        id: id,
        name: name,
        namePt: namePt,
        equipment: equipment,
        equipmentPt: equipmentPt,
        bodyPart: bodyPart,
        target: target,
      );

  Exercise copyWith({
    String? name,
    String? namePt,
    String? bodyPart,
    String? bodyPartPt,
    String? equipment,
    String? equipmentPt,
    String? target,
    String? targetPt,
    List<String>? secondaryMuscles,
    List<String>? secondaryMusclesPt,
    List<String>? instructions,
    List<String>? instructionsPt,
    String? gifPath,
    String? description,
    String? difficulty,
    String? category,
    String? media,
  }) =>
      Exercise(
        id: id,
        name: name ?? this.name,
        namePt: namePt ?? this.namePt,
        bodyPart: bodyPart ?? this.bodyPart,
        bodyPartPt: bodyPartPt ?? this.bodyPartPt,
        equipment: equipment ?? this.equipment,
        equipmentPt: equipmentPt ?? this.equipmentPt,
        target: target ?? this.target,
        targetPt: targetPt ?? this.targetPt,
        secondaryMuscles: secondaryMuscles ?? this.secondaryMuscles,
        secondaryMusclesPt: secondaryMusclesPt ?? this.secondaryMusclesPt,
        instructions: instructions ?? this.instructions,
        instructionsPt: instructionsPt ?? this.instructionsPt,
        gifPath: gifPath ?? this.gifPath,
        description: description ?? this.description,
        difficulty: difficulty ?? this.difficulty,
        category: category ?? this.category,
        media: media ?? this.media,
        primary: _primary,
        secondary: _secondary,
        art: _art,
        steps: _steps,
      );

  bool matchesSearch(String query) => matchesExerciseSearch(this, query);

  Map<String, dynamic> toJson() => {
        'id': id,
        'n': name,
        'p': primary,
        'e': equipment,
        'd': difficulty,
        if (media.isNotEmpty) 'm': media,
      };

  factory Exercise.fromJson(Map<String, dynamic> j) => Exercise(
        id: j['id'] as String,
        name: (j['n'] ?? j['name'] ?? '') as String,
        namePt: (j['name_pt'] as String?) ?? '',
        primary: j['p'] as String?,
        secondary: const [],
        equipment: (j['e'] as String?) ?? 'Other',
        difficulty: (j['d'] as String?) ?? 'Beginner',
        art: '',
        steps: const [],
        media: (j['m'] as String?) ?? '',
      );

  factory Exercise.fromDbMap(Map<String, dynamic> row) {
    List<String> decodeList(dynamic val) {
      if (val == null) return const [];
      if (val is List) return val.map((e) => e.toString()).toList();
      try {
        final decoded = jsonDecode(val.toString());
        if (decoded is List) return decoded.map((e) => e.toString()).toList();
      } catch (_) {}
      return const [];
    }

    final rawName = (row['name_en'] ?? row['name'] ?? '').toString();
    final rawNamePt = (row['name_pt'] as String?) ?? '';
    final rawBodyPart = (row['body_part_en'] ?? row['body_part'] ?? 'other').toString();
    final rawBodyPartPt = (row['body_part_pt'] as String?) ?? 'Outros';
    final rawTarget = (row['target_en'] ?? row['target'] ?? 'other').toString();
    final rawTargetPt = (row['target_pt'] as String?) ?? 'Geral';
    final rawEquip = (row['equipment_en'] ?? row['equipment'] ?? 'Other').toString();
    final rawEquipPt = (row['equipment_pt'] as String?) ?? 'Outros';

    return Exercise(
      id: row['id'] as String,
      name: rawName,
      namePt: rawNamePt,
      bodyPart: rawBodyPart,
      bodyPartPt: rawBodyPartPt,
      equipment: rawEquip,
      equipmentPt: rawEquipPt,
      target: rawTarget,
      targetPt: rawTargetPt,
      secondaryMuscles: decodeList(row['secondary_muscles_json'] ?? row['secondary_muscles']),
      secondaryMusclesPt: decodeList(row['secondary_muscles_pt']),
      instructions: decodeList(row['instructions_json'] ?? row['instructions']),
      instructionsPt: decodeList(row['instructions_pt']),
      gifPath: (row['gif_path'] as String?) ?? '',
      description: (row['description'] as String?) ?? '',
      difficulty: (row['difficulty'] as String?) ?? 'Beginner',
      category: (row['category'] as String?) ?? 'strength',
      media: (row['media'] as String?) ?? '',
    );
  }
}

typedef ExerciseModel = Exercise;

class ToolMeta {
  const ToolMeta(this.id, this.name, this.desc);
  final String id;
  final String name;
  final String desc;
}

const List<Muscle> kMuscles = [
  Muscle('warmup', 'Warm-up / Flexibility', 'front'),
  Muscle('cardio', 'Cardio', 'front'),
  Muscle('chest', 'Chest', 'front'),
  Muscle('shoulders', 'Shoulders', 'front'),
  Muscle('biceps', 'Biceps', 'front'),
  Muscle('abdomen', 'Abdomen', 'front'),
  Muscle('obliques', 'Obliques', 'front'),
  Muscle('quads', 'Quads', 'front'),
  Muscle('forearm', 'Forearm', 'front'),
  Muscle('trapezius', 'Trapezius', 'back'),
  Muscle('back', 'Back', 'back'),
  Muscle('triceps', 'Triceps', 'back'),
  Muscle('glutes', 'Glutes', 'back'),
  Muscle('hamstrings', 'Hamstrings', 'back'),
  Muscle('calves', 'Calves', 'back'),
];

String muscleLabel(String id) => t.muscle(id);
String exerciseName(Exercise e) =>
    e.namePt.isNotEmpty && appLanguage == 'pt' ? e.namePt : t.catalogName(e.id, e.name);
List<String> exerciseSteps(Exercise e) => e.instructionsPt.isNotEmpty && appLanguage == 'pt' ? e.instructionsPt : t.catalogSteps(e.id, e.steps);

String mapTargetToPrimaryMuscle(String target, String bodyPart) {
  switch (target.trim().toLowerCase()) {
    case 'pectorals':
    case 'serratus anterior':
      return 'chest';
    case 'lats':
    case 'upper back':
    case 'spine':
      return 'back';
    case 'delts':
      return 'shoulders';
    case 'biceps':
      return 'biceps';
    case 'triceps':
      return 'triceps';
    case 'forearms':
      return 'forearm';
    case 'abs':
      return 'abdomen';
    case 'quads':
    case 'adductors':
    case 'abductors':
      return 'quads';
    case 'glutes':
      return 'glutes';
    case 'hamstrings':
      return 'hamstrings';
    case 'calves':
      return 'calves';
    case 'traps':
    case 'levator scapulae':
      return 'trapezius';
    case 'cardiovascular system':
      return 'cardio';
    default:
      final bp = bodyPart.trim().toLowerCase();
      if (bp == 'cardio') return 'cardio';
      if (bp == 'neck') return 'trapezius';
      if (bp == 'waist') return 'abdomen';
      if (bp == 'back') return 'back';
      if (bp == 'chest') return 'chest';
      if (bp == 'shoulders') return 'shoulders';
      if (bp == 'upper arms') return 'biceps';
      if (bp == 'lower arms') return 'forearm';
      if (bp == 'upper legs') return 'quads';
      if (bp == 'lower legs') return 'calves';
      return 'abdomen';
  }
}

String muscleGroup(String muscleId) {
  switch (muscleId) {
    case 'warmup':
      return 'Flexibility';
    case 'cardio':
      return 'Cardio';
    case 'chest':
      return 'Chest';
    case 'back':
    case 'trapezius':
      return 'Back';
    case 'quads':
    case 'hamstrings':
    case 'glutes':
    case 'calves':
      return 'Legs';
    case 'shoulders':
      return 'Shoulders';
    case 'biceps':
    case 'triceps':
    case 'forearm':
      return 'Arms';
    case 'abdomen':
    case 'obliques':
      return 'Core';
    default:
      return muscleLabel(muscleId);
  }
}

String muscleFamily(String muscleId) {
  switch (muscleId) {
    case 'warmup':
    case 'cardio':
      return 'core';
    case 'chest':
    case 'shoulders':
    case 'triceps':
      return 'push';
    case 'back':
    case 'trapezius':
    case 'biceps':
    case 'forearm':
      return 'pull';
    case 'quads':
    case 'hamstrings':
    case 'glutes':
    case 'calves':
      return 'legs';
    default:
      return 'core';
  }
}

/// Verifica se o identificador do exercício corresponde ao termo de busca por ID.
/// Suporta IDs alfanuméricos ("EIeI8Vf"), numéricos com ou sem zeros à esquerda ("0001", "1", "25", "0025"),
/// e prefixos como "#" ("#0001", "#1") ou "id:" / "id " ("id: 25").
bool matchesExerciseId(String exerciseId, String query) {
  final cleanQuery = query.trim().toLowerCase();
  if (cleanQuery.isEmpty) return false;

  final exId = exerciseId.trim().toLowerCase();
  if (exId.isEmpty) return false;
  if (exId == cleanQuery) return true;

  // Remove prefixos comuns como "#", "id:", "id "
  final stripped = cleanQuery
      .replaceFirst(RegExp(r'^(#|id:?\s*)', caseSensitive: false), '')
      .trim();

  if (stripped.isEmpty) return false;
  if (exId == stripped) return true;

  final isQueryNumeric = RegExp(r'^\d+$').hasMatch(stripped);
  final isExIdNumeric = RegExp(r'^\d+$').hasMatch(exId);

  if (isQueryNumeric && isExIdNumeric) {
    final strippedNum = int.tryParse(stripped);
    final exIdNum = int.tryParse(exId);
    if (strippedNum != null && exIdNum != null && strippedNum == exIdNum) {
      return true;
    }
  }

  if (isQueryNumeric) {
    final padded4 = stripped.padLeft(4, '0');
    if (exId == padded4) return true;
    if (exId.contains(padded4)) return true;
  }

  if (exId.contains(stripped)) return true;

  return false;
}

/// Função padronizada e abrangente para pesquisa de exercícios em todo o sistema GymMane.
/// Cobre:
/// 1. ID exato, numérico com/sem padding, prefixado com # ou id:, ou parcial
/// 2. Nome em Português e Inglês, nome localizado dinâmico
/// 3. Equipamento (original, em português e traduzido)
/// 4. Grupo muscular principal (primary), target, bodyPart e secundários
/// 5. Dificuldade e categoria
/// 6. Multi-termos ("supino barra", "peito halter")
bool matchesExerciseSearch(Exercise ex, String query) {
  final raw = query.trim();
  if (raw.isEmpty) return true;

  // 1. Busca por ID
  if (matchesExerciseId(ex.id, raw)) return true;

  // 2. Busca por texto normalizado (sem acentos e minúsculo)
  final normQuery = normalizeSearchText(raw);
  if (normQuery.isEmpty) return false;

  const musclePtMap = <String, String>{
    'chest': 'Peito',
    'back': 'Costas',
    'shoulders': 'Ombros Deltoides',
    'biceps': 'Bíceps',
    'triceps': 'Tríceps',
    'forearm': 'Antebraço',
    'abdomen': 'Abdômen Abdominais Abdominal',
    'obliques': 'Oblíquos',
    'quads': 'Quadríceps Pernas',
    'hamstrings': 'Posterior de Coxa Isquiotibiais',
    'glutes': 'Glúteos',
    'calves': 'Panturrilhas',
    'trapezius': 'Trapézio',
    'cardio': 'Cardio Aeróbico',
  };

  final terms = [
    ex.id,
    ex.name,
    ex.namePt,
    ex.localizedName(),
    exerciseName(ex),
    ex.equipment,
    ex.equipmentPt,
    ex.getLocalizedEquipment(),
    t.equipment(ex.equipment),
    FitnessTranslator.equipmentPt[ex.equipment.toLowerCase()] ?? '',
    ex.primary,
    muscleLabel(ex.primary),
    musclePtMap[ex.primary] ?? '',
    ex.target,
    ex.targetPt,
    ex.getLocalizedTarget(),
    ex.bodyPart,
    ex.bodyPartPt,
    ex.getLocalizedBodyPart(),
    ...ex.secondary,
    ...ex.secondaryMusclesPt,
    ...ex.getLocalizedSecondaryMuscles(),
    for (final s in ex.secondary) musclePtMap[s] ?? '',
    ex.difficulty,
    t.difficulty(ex.difficulty),
    ex.category,
  ];

  final combined = normalizeSearchText(terms.join(' '));
  if (combined.contains(normQuery)) return true;

  // Multi-termos: todas as palavras digitadas precisam estar presentes em algum termo
  final words = normQuery.split(' ').where((w) => w.isNotEmpty).toList();
  if (words.length > 1) {
    if (words.every((w) => combined.contains(w))) return true;
  }

  return false;
}
