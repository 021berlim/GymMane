import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:fitiron/l10n/fitness_translator.dart';
import 'package:fitiron/l10n/l10n.dart';
import 'package:fitiron/models/exercise.dart';
import 'package:fitiron/services/apply_brazilian_exercises_patch.dart';
import 'package:fitiron/services/exercise_repository.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  sqfliteFfiInit();

  group('Agente 1: Brazilian Bodybuilding Lexicographer', () {
    test('Mapeamento anatômico autêntico de regiões, músculos e equipamentos', () {
      // Regiões anatômicas
      expect(FitnessTranslator.bodyPartsPt['waist'], 'Abdômen');
      expect(FitnessTranslator.bodyPartsPt['back'], 'Costas');
      expect(FitnessTranslator.bodyPartsPt['chest'], 'Peitoral');
      expect(FitnessTranslator.bodyPartsPt['upper legs'], 'Pernas (Coxas)');
      expect(FitnessTranslator.bodyPartsPt['lower legs'], 'Panturrilhas');
      expect(FitnessTranslator.bodyPartsPt['shoulders'], 'Ombros');
      expect(FitnessTranslator.bodyPartsPt['upper arms'], 'Braços');

      // Músculos
      expect(FitnessTranslator.targetMusclesPt['abs'], 'Abdominais');
      expect(FitnessTranslator.targetMusclesPt['lats'], 'Dorsais / Grande Dorsal');
      expect(FitnessTranslator.targetMusclesPt['pectorals'], 'Peitoral Maior');
      expect(FitnessTranslator.targetMusclesPt['hamstrings'], 'Posteriores de Coxa');
      expect(FitnessTranslator.targetMusclesPt['quads'], 'Quadríceps');
      expect(FitnessTranslator.targetMusclesPt['glutes'], 'Glúteos');
      expect(FitnessTranslator.targetMusclesPt['delts'], 'Deltoides');
      expect(FitnessTranslator.targetMusclesPt['traps'], 'Trapézio');
      expect(FitnessTranslator.targetMusclesPt['triceps'], 'Tríceps');
      expect(FitnessTranslator.targetMusclesPt['biceps'], 'Bíceps');

      // Equipamentos
      expect(FitnessTranslator.equipmentPt['barbell'], 'Barra');
      expect(FitnessTranslator.equipmentPt['dumbbell'], 'Halter');
      expect(FitnessTranslator.equipmentPt['cable'], 'Polia / Cabo');
      expect(FitnessTranslator.equipmentPt['leverage machine'], 'Máquina Articulada');
      expect(FitnessTranslator.equipmentPt['smith machine'], 'Smith');
      expect(FitnessTranslator.equipmentPt['body weight'], 'Peso Corporal');
      expect(FitnessTranslator.equipmentPt['ez barbell'], 'Barra W');
    });

    test('Desambiguação obrigatória de Agachamentos', () {
      expect(FitnessTranslator.translateExerciseName('barbell squat'), 'Agachamento Livre com Barra');
      expect(FitnessTranslator.translateExerciseName('dumbbell goblet squat'), 'Agachamento Taça (Goblet) com Halter');
      expect(FitnessTranslator.translateExerciseName('smith machine squat'), 'Agachamento no Smith');
      expect(FitnessTranslator.translateExerciseName('bulgarian split squat'), 'Agachamento Búlgaro com Halteres');
      expect(FitnessTranslator.translateExerciseName('hack squat'), 'Agachamento Hack');
      expect(FitnessTranslator.translateExerciseName('front squat'), 'Agachamento Frontal com Barra');
      expect(FitnessTranslator.translateExerciseName('sumo squat'), 'Agachamento Sumô');
    });

    test('Desambiguação obrigatória de Supinos, Remadas e Puxadas', () {
      // Supinos
      expect(FitnessTranslator.translateExerciseName('barbell bench press'), 'Supino Reto com Barra');
      expect(FitnessTranslator.translateExerciseName('barbell incline bench press'), 'Supino Inclinado com Barra');
      expect(FitnessTranslator.translateExerciseName('barbell decline bench press'), 'Supino Declinado com Barra');
      expect(FitnessTranslator.translateExerciseName('dumbbell bench press'), 'Supino Reto com Halteres');
      expect(FitnessTranslator.translateExerciseName('dumbbell incline bench press'), 'Supino Inclinado com Halteres');
      expect(FitnessTranslator.translateExerciseName('close-grip bench press'), 'Supino com Pegada Fechada');

      // Remadas
      expect(FitnessTranslator.translateExerciseName('barbell bent over row'), 'Remada Curvada com Barra');
      expect(FitnessTranslator.translateExerciseName('dumbbell bent over row'), 'Remada Curvada com Halteres');
      expect(FitnessTranslator.translateExerciseName('cable seated row'), 'Remada Baixa na Polia');
      expect(FitnessTranslator.translateExerciseName('dumbbell one arm bent-over row'), 'Remada Unilateral com Halter (Serrote)');
      expect(FitnessTranslator.translateExerciseName('t-bar row'), 'Remada Cavalinho (Barra T)');

      // Puxadas
      expect(FitnessTranslator.translateExerciseName('lat pulldown'), 'Puxada Alta na Polia');
      expect(FitnessTranslator.translateExerciseName('wide grip lat pulldown'), 'Puxada Alta com Pegada Aberta');
      expect(FitnessTranslator.translateExerciseName('close grip lat pulldown'), 'Puxada Alta com Triângulo (Pegada Fechada)');
      expect(FitnessTranslator.translateExerciseName('reverse grip lat pulldown'), 'Puxada Alta com Pegada Supinada');
      expect(FitnessTranslator.translateExerciseName('straight arm pulldown'), 'Pulldown na Polia (Braços Estendidos)');
    });

    test('Desambiguação de Roscas e Tríceps', () {
      expect(FitnessTranslator.translateExerciseName('barbell curl'), 'Rosca Direta com Barra');
      expect(FitnessTranslator.translateExerciseName('ez barbell curl'), 'Rosca Direta com Barra W');
      expect(FitnessTranslator.translateExerciseName('dumbbell hammer curl'), 'Rosca Martelo com Halteres');
      expect(FitnessTranslator.translateExerciseName('preacher curl'), 'Rosca Scott');
      expect(FitnessTranslator.translateExerciseName('concentration curl'), 'Rosca Concentrada com Halter');
      expect(FitnessTranslator.translateExerciseName('cable pushdown'), 'Tríceps Pulley na Polia');
      expect(FitnessTranslator.translateExerciseName('skull crusher'), 'Tríceps Testa com Barra');
      expect(FitnessTranslator.translateExerciseName('kickback'), 'Tríceps Coice com Halter');
    });
  });

  group('Agente 2: Algorithmic Translation & Instructions Parser', () {
    test('Tradução contextual de frases de instrução', () {
      final steps = [
        'Stand with your feet shoulder-width apart.',
        'Hold a dumbbell in each hand.',
        'Keep your back straight and your core engaged.',
        'Repeat for the desired number of repetitions.',
      ];
      final translated = FitnessTranslator.translateInstructions(steps);
      expect(translated.length, 4);
      expect(translated[0], 'Fique em pé com os pés afastados na largura dos ombros.');
      expect(translated[1], 'Segure um halter em cada mão.');
      expect(translated[2], 'Mantenha as costas retas e o abdômen contraído.');
      expect(translated[3], 'Repita pelo número desejado de repetições.');
    });
  });

  group('Agente 3 & 4: Database Architect & Search Engine Specialist', () {
    late Database testDb;

    setUp(() async {
      final databaseFactory = databaseFactoryFfi;
      testDb = await databaseFactory.openDatabase(inMemoryDatabasePath);
      await ExerciseRepository.createSchema(testDb);
    });

    tearDown(() async {
      await testDb.close();
    });

    test('Migração atômica via applyBrazilianExercisesPatch e geração do search_index', () async {
      final count = await applyBrazilianExercisesPatch(
        db: testDb,
        jsonPath: 'assets/data/exercicios_metadados.json',
        force: true,
      );
      expect(count, equals(1394));

      // Verificar criação do índice de busca
      final indexCheck = await testDb.rawQuery(
        "SELECT name FROM sqlite_master WHERE type='index' AND name='idx_exercises_search'",
      );
      expect(indexCheck, isNotEmpty);

      // Verificar preservação estrita do ID original
      final ex0001 = await ExerciseRepository.instance.getExerciseById(testDb, '0001');
      expect(ex0001, isNotNull);
      expect(ex0001!.id, '0001');
      expect(ex0001.nameEn, '3/4 sit-up');
      expect(ex0001.namePt, 'Abdominal 3/4 (Sit-up)');
      expect(ex0001.targetPt, 'Abdominais');

      // Busca por ID (ex: "0001" ou "1")
      final searchById = await ExerciseRepository.instance.searchExercises(testDb, query: '0001');
      expect(searchById.any((e) => e.id == '0001'), isTrue);

      // Busca tolerante a acentos e maiúsculas
      final searchAccent = await ExerciseRepository.instance.searchExercises(testDb, query: 'elevação lateral');
      final searchNoAccent = await ExerciseRepository.instance.searchExercises(testDb, query: 'elevacao lateral');
      final searchCaps = await ExerciseRepository.instance.searchExercises(testDb, query: 'ELEVAÇÃO LATERAL');
      expect(searchAccent.length, greaterThan(0));
      expect(searchAccent.length, equals(searchNoAccent.length));
      expect(searchAccent.length, equals(searchCaps.length));

      // Busca multilíngue (em inglês)
      final searchEn = await ExerciseRepository.instance.searchExercises(testDb, query: 'lateral raise');
      expect(searchEn.length, greaterThan(0));
    });
  });

  group('Agente 5: UI & Full-App Localization Model Guard', () {
    test('Exercise localizedName prioriza PT-BR quando app está em português', () {
      setAppLanguage('pt');
      const ex = Exercise(
        id: '9999',
        name: 'Barbell Bench Press',
        namePt: 'Supino Reto com Barra',
      );

      expect(ex.localizedName(), 'Supino Reto com Barra');
      expect(ex.getLocalizedName(), 'Supino Reto com Barra');
      expect(ex.nameEn, 'Barbell Bench Press');

      setAppLanguage('en');
      expect(ex.localizedName(), 'Barbell Bench Press');
      setAppLanguage('pt');
    });
  });
}
