import 'package:flutter_test/flutter_test.dart';
import 'package:fitiron/models/cardio_config.dart';
import 'package:fitiron/models/exercise.dart';
import 'package:fitiron/models/live_session.dart';
import 'package:fitiron/models/workout.dart';
import 'package:fitiron/state/fit_state.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Cardio Detection & Categorization', () {
    test('correctly detects treadmill / esteira', () {
      final type = detectCardioType(
        id: 'treadmill_run',
        name: 'Treadmill Running',
        namePt: 'Corrida na Esteira',
        equipment: 'Treadmill',
        equipmentPt: 'Esteira',
        bodyPart: 'cardio',
        target: 'cardiovascular system',
      );
      expect(type, CardioCategoryType.treadmill);
      expect(type.displayNamePt, 'Esteira');
      expect(type.paramLabel, 'INCLINAÇÃO');
      expect(type.paramUnit, '%');
      expect(type.hasSpeed, isTrue);
      expect(type.speedLabel, 'VELOCIDADE');
      expect(type.speedUnit, 'km/h');
      expect(type.formatSpeed(8.5), '8.5');
      expect(type.formatSpeedWithUnit(8.0), '8 km/h');
      expect(type.formatParamWithUnit(2.5), '2.5%');
      expect(type.formatParamShort(2.0), 'Inc 2%');
    });

    test('correctly detects stationary bike / bicicleta', () {
      final type = detectCardioType(
        id: 'stationary_bike_ride',
        name: 'Stationary Bike',
        namePt: 'Bicicleta Ergométrica',
        equipment: 'Stationary Bike',
        equipmentPt: 'Bicicleta Ergométrica',
        bodyPart: 'cardio',
        target: 'cardiovascular system',
      );
      expect(type, CardioCategoryType.bike);
      expect(type.displayNamePt, 'Bicicleta');
      expect(type.paramLabel, 'RESISTÊNCIA');
      expect(type.paramUnit, 'NÍV');
      expect(type.formatParamWithUnit(7), 'Nív 7');
      expect(type.formatParamShort(7), 'Res 7');
    });

    test('correctly detects elliptical / elíptico', () {
      final type = detectCardioType(
        id: 'elliptical_trainer',
        name: 'Elliptical Cross Trainer',
        namePt: 'Elíptico',
        equipment: 'Elliptical',
        equipmentPt: 'Elíptico',
        bodyPart: 'cardio',
        target: 'cardiovascular system',
      );
      expect(type, CardioCategoryType.elliptical);
      expect(type.displayNamePt, 'Elíptico');
      expect(type.paramLabel, 'RESISTÊNCIA');
      expect(type.paramUnit, 'NÍV');
    });

    test('correctly detects stepmill / simulador de escada', () {
      final type = detectCardioType(
        id: 'stepmill_workout',
        name: 'Stair Climber Stepmill',
        namePt: 'Simulador de Escada',
        equipment: 'Stepmill',
        equipmentPt: 'Escada',
        bodyPart: 'cardio',
        target: 'cardiovascular system',
      );
      expect(type, CardioCategoryType.stepmill);
      expect(type.displayNamePt, 'Simulador de Escada');
      expect(type.paramLabel, 'NÍVEL');
      expect(type.paramUnit, 'NÍV');
    });

    test('correctly detects rowing machine / remo seco', () {
      final type = detectCardioType(
        id: 'rowing',
        name: 'Rowing Machine',
        namePt: 'Remo Seco',
        equipment: 'Rower',
        equipmentPt: 'Remo',
        bodyPart: 'cardio',
        target: 'cardiovascular system',
      );
      expect(type, CardioCategoryType.rower);
      expect(type.displayNamePt, 'Remo Seco');
      expect(type.paramLabel, 'RESISTÊNCIA');
      expect(type.paramUnit, 'DAMPER');
      expect(type.formatParamWithUnit(5), 'Damper 5');
    });

    test('correctly detects skierg', () {
      final type = detectCardioType(
        id: 'skierg_session',
        name: 'SkiErg Workout',
        namePt: 'Treino no SkiErg',
        equipment: 'SkiErg',
        equipmentPt: 'SkiErg',
        bodyPart: 'cardio',
        target: 'cardiovascular system',
      );
      expect(type, CardioCategoryType.skierg);
      expect(type.displayNamePt, 'SkiErg');
      expect(type.paramLabel, 'DAMPER');
      expect(type.paramUnit, 'DAMPER');
    });

    test('correctly detects jump rope / corda', () {
      final type = detectCardioType(
        id: 'jump_rope',
        name: 'Jump Rope',
        namePt: 'Pular Corda',
        equipment: 'Rope',
        equipmentPt: 'Corda',
        bodyPart: 'cardio',
        target: 'cardiovascular system',
      );
      expect(type, CardioCategoryType.rope);
      expect(type.displayNamePt, 'Corda');
      expect(type.paramLabel, 'INTENSIDADE');
      expect(type.paramUnit, 'NÍV');
    });

    test('correctly classifies functional / general cardio exercises', () {
      final type = detectCardioType(
        id: 'burpee',
        name: 'Burpee',
        namePt: 'Burpee',
        equipment: 'Bodyweight',
        equipmentPt: 'Peso Corporal',
        bodyPart: 'cardio',
        target: 'cardiovascular system',
      );
      expect(type, CardioCategoryType.general);
      expect(type.displayNamePt, 'Cardio Geral');
      expect(type.paramLabel, 'INTENSIDADE');
    });

    test('distinguishes strength exercises from cardio', () {
      final benchPress = isExerciseCardio(
        id: 'barbell_bench_press',
        name: 'Barbell Bench Press',
        namePt: 'Supino Reto com Barra',
        primary: 'chest',
        bodyPart: 'chest',
        bodyPartPt: 'Peito',
        target: 'pectorals',
        targetPt: 'Peitorais',
        category: 'strength',
        equipment: 'Barbell',
        equipmentPt: 'Barra',
      );
      expect(benchPress, isFalse);

      final squat = isExerciseCardio(
        id: 'barbell_squat',
        name: 'Barbell Full Squat',
        namePt: 'Agachamento com Barra',
        primary: 'legs',
        bodyPart: 'legs',
        bodyPartPt: 'Pernas',
        target: 'quads',
        targetPt: 'Quadríceps',
        category: 'strength',
        equipment: 'Barbell',
        equipmentPt: 'Barra',
      );
      expect(squat, isFalse);
    });
  });

  group('Duration Formatters', () {
    test('formatCardioDuration formats mm:ss and hh:mm:ss properly', () {
      expect(formatCardioDuration(0), '00:00');
      expect(formatCardioDuration(45), '00:45');
      expect(formatCardioDuration(90), '01:30');
      expect(formatCardioDuration(1200), '20:00');
      expect(formatCardioDuration(3665), '01:01:05');
    });

    test('formatCardioDurationLabel formats friendly min labels', () {
      expect(formatCardioDurationLabel(1200), '20 min');
      expect(formatCardioDurationLabel(90), '01:30 min');
      expect(formatCardioDurationLabel(300), '5 min');
    });
  });

  group('Cardio Models & Serialization', () {
    test('RoutineExerciseConfig handles cardio time and param', () {
      final cfg = RoutineExerciseConfig(
        exerciseId: 'esteira_01',
        targetSets: 1,
        targetTimeSeconds: 1200,
        targetCardioParam: 2.5,
        targetSpeed: 8.5,
      );

      expect(cfg.effectiveTimeSeconds, 1200);
      expect(cfg.effectiveCardioParam, 2.5);
      expect(cfg.effectiveCardioSpeed, 8.5);

      final json = cfg.toJson();
      expect(json['s'], 1);
      expect(json['r'], 1200);
      expect(json['w'], 2.5);
      expect(json['t'], 1200);
      expect(json['cp'], 2.5);
      expect(json['sp'], 8.5);

      final decoded = RoutineExerciseConfig.fromJson(json);
      expect(decoded.effectiveTimeSeconds, 1200);
      expect(decoded.effectiveCardioParam, 2.5);
      expect(decoded.effectiveCardioSpeed, 8.5);
    });

    test('SessionSet handles cardio time, param and speed', () {
      final set = SessionSet(
        0,
        0,
        false,
        timeSeconds: 900,
        cardioParam: 6.0,
        cardioSpeed: 10.0,
      );

      expect(set.effectiveTimeSeconds, 900);
      expect(set.effectiveCardioParam, 6.0);
      expect(set.effectiveCardioSpeed, 10.0);

      final json = set.toJson();
      expect(json['t'], 900);
      expect(json['cp'], 6.0);
      expect(json['sp'], 10.0);

      final decoded = SessionSet.fromJson(json);
      expect(decoded.effectiveTimeSeconds, 900);
      expect(decoded.effectiveCardioParam, 6.0);
      expect(decoded.effectiveCardioSpeed, 10.0);
    });

    test('LoggedExercise ignores cardio in volume and 1RM calculation', () {
      final loggedCardio = LoggedExercise(
        'treadmill_01',
        'Esteira',
        'cardio',
        [
          LoggedSet(0, 0, sec: 1200, cardioParam: 2.0),
        ],
      );

      expect(loggedCardio.volume, 0.0);
      expect(loggedCardio.topWeight, 0.0);
      expect(loggedCardio.bestOneRm, 0.0);

      final loggedStrength = LoggedExercise(
        'bench_press',
        'Supino',
        'chest',
        [
          LoggedSet(10, 100),
        ],
      );

      expect(loggedStrength.volume, 1000.0);
      expect(loggedStrength.topWeight, 100.0);
      expect(loggedStrength.bestOneRm, greaterThan(100.0));
    });
  });

  group('FitState Cardio Integration', () {
    test('session initializes cardio with single set, target time and param', () {
      final fit = FitState();
      final cardioExercise = fit.allExercises.firstWhere(
        (e) => e.isCardio,
        orElse: () => fit.allExercises.firstWhere((e) => e.primary == 'cardio'),
      );
      final routine = Routine(
        'r_cardio_test',
        'Cardio Routine',
        [cardioExercise.id],
      );
      fit.startRoutine(routine);

      expect(fit.session, isNotNull);
      expect(fit.session!.exercises.length, 1);

      final sessionEx = fit.session!.exercises.first;
      expect(sessionEx.isCardio, isTrue);
      // Cardio does not have multiple sets by default: 1 single continuous card
      expect(sessionEx.sets.length, 1);
      final expectedType = cardioExercise.cardioType;
      expect(sessionEx.sets.first.effectiveTimeSeconds, expectedType.defaultSeconds);
      expect(sessionEx.sets.first.effectiveCardioParam, expectedType.defaultParam);

      // Bump time by 60 seconds
      fit.bumpSessionCardioTime(0, 0, 60);
      expect(sessionEx.sets.first.effectiveTimeSeconds, expectedType.defaultSeconds + 60);

      // Set time directly
      fit.setSessionCardioTime(0, 0, 1800); // 30 min
      expect(sessionEx.sets.first.effectiveTimeSeconds, 1800);

      // Bump machine param
      fit.bumpSessionCardioParam(0, 0, expectedType.paramStep);
      expect(sessionEx.sets.first.effectiveCardioParam, expectedType.defaultParam + expectedType.paramStep);

      // Set param directly
      fit.setSessionCardioParam(0, 0, 3.5);
      expect(sessionEx.sets.first.effectiveCardioParam, 3.5);

      // Bump speed
      fit.bumpSessionCardioSpeed(0, 0, 0.5);
      expect(sessionEx.sets.first.effectiveCardioSpeed, expectedType.defaultSpeed + 0.5);

      // Set speed directly
      fit.setSessionCardioSpeed(0, 0, 9.5);
      expect(sessionEx.sets.first.effectiveCardioSpeed, 9.5);

      // Clean up session
      fit.discardSession();
    });

    test('cardio does not inflate total workout tonnage on finish', () {
      final fit = FitState();
      final cardioExercise = fit.allExercises.firstWhere(
        (e) => e.isCardio,
        orElse: () => fit.allExercises.firstWhere((e) => e.primary == 'cardio'),
      );
      final routine = Routine(
        'r_cardio_vol_test',
        'Cardio Vol',
        [cardioExercise.id],
      );
      fit.startRoutine(routine);

      // Complete set
      fit.toggleSet(0, 0);
      expect(fit.session!.exercises[0].sets[0].done, isTrue);

      fit.finishSession();
      // Cardio volume should be 0 kg lifted
      expect(fit.summaryVolumeKg, 0.0);
    });
  });
}
