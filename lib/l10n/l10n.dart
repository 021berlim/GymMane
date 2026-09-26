import 'package:flutter/widgets.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';

import 'app_localizations.dart';
import 'catalog_es.dart';
import 'catalog_it.dart';
import 'catalog_pt.dart';
import 'catalog_zh.dart';
import 'fitness_translator.dart';

export 'app_localizations.dart';

const Map<String, Map<String, String>> _catalogNames = {
  'es': kExerciseNameEs,
  'it': kExerciseNameIt,
  'pt': kExerciseNamePt,
  'zh': kExerciseNameZh,
};
const Map<String, Map<String, List<String>>> _catalogSteps = {
  'es': kExerciseStepsEs,
  'it': kExerciseStepsIt,
  'pt': kExerciseStepsPt,
  'zh': kExerciseStepsZh,
};

String appLanguage = 'en';
AppLocalizations t = lookupAppLocalizations(const Locale('en'));

List<String> get appLanguages =>
    AppLocalizations.supportedLocales.map((l) => l.languageCode).toList();

String languageNameOf(String code) => lookupAppLocalizations(Locale(code)).languageName;

String resolveLanguage(String code) {
  final base = code.toLowerCase().split(RegExp('[-_]')).first;
  return appLanguages.contains(base) ? base : 'en';
}

void setAppLanguage(String code) {
  appLanguage = resolveLanguage(code);
  t = lookupAppLocalizations(Locale(appLanguage));
  Intl.defaultLocale = _intlLocale;
}

String get _intlLocale => appLanguage == 'pt' ? 'pt_BR' : appLanguage;

bool _dateSymbolsReady = false;

DateFormat _dates(DateFormat Function(String locale) build) {
  if (!_dateSymbolsReady) {
    initializeDateFormatting();
    _dateSymbolsReady = true;
  }
  return build(_intlLocale);
}

extension GymL10n on AppLocalizations {
  String finishHeadline({required int prs, required int streak, required bool goalHit}) {
    if (prs > 0) return finishHeadlinePr;
    if (goalHit) return finishHeadlineGoal;
    if (streak >= 3) return finishHeadlineStreak;
    return finishHeadlineDefault;
  }

  String finishBody({required int prs, required int streak, required bool goalHit}) {
    if (prs > 0) return finishBodyPr(prs);
    if (goalHit) return finishBodyGoal;
    if (streak >= 3) return finishBodyStreak(streak);
    return finishBodyDefault;
  }

  String vsLastMonth(int pct) => vsLastMonthLabel('${pct >= 0 ? '+' : ''}$pct');

  String levelStreak(int level, int streak) => levelStreakLabel(level, streakDays(streak));

  String toolName(String id) => switch (id) {
        'rm' => toolNameRm,
        'bmi' => toolNameBmi,
        'cal' => toolNameCal,
        'bf' => toolNameBf,
        'plate' => toolNamePlate,
        _ => toolNameWarmup,
      };

  String toolTitle(String id) => switch (id) {
        'rm' => toolTitleRm,
        'bmi' => toolTitleBmi,
        'cal' => toolTitleCal,
        'bf' => toolTitleBf,
        'plate' => toolTitlePlate,
        _ => toolTitleWarmup,
      };

  String toolResultHint(String id) => switch (id) {
        'rm' => toolHintRm,
        'cal' => toolHintCal,
        'bf' => toolHintBf,
        'plate' => toolHintPlate,
        _ => toolHintWarmup,
      };

  String toolDesc(String id) => switch (id) {
        'rm' => toolDescRm,
        'bmi' => toolDescBmi,
        'cal' => toolDescCal,
        'bf' => toolDescBf,
        'plate' => toolDescPlate,
        _ => toolDescWarmup,
      };

  String bmiCategory(String key) => switch (key) {
        'Underweight' => bmiUnderweight,
        'Normal' => bmiNormal,
        'Overweight' => bmiOverweight,
        _ => bmiObese,
      };

  String activityName(String key) => switch (key) {
        'Sedentary' => actSedentary,
        'Light' => actLight,
        'Active' => actActive,
        _ => actModerate,
      };

  String muscle(String id) => switch (id) {
        'warmup' => muscleWarmup,
        'cardio' => muscleCardio,
        'chest' => muscleChest,
        'back' => muscleBack,
        'shoulders' => muscleShoulders,
        'biceps' => muscleBiceps,
        'triceps' => muscleTriceps,
        'forearm' => muscleForearm,
        'trapezius' => muscleTrapezius,
        'abdomen' => muscleAbdomen,
        'obliques' => muscleObliques,
        'quads' => muscleQuads,
        'hamstrings' => muscleHamstrings,
        'glutes' => muscleGlutes,
        'calves' => muscleCalves,
        _ => id,
      };

  String muscleGroupName(String key) => switch (key.trim().toLowerCase()) {
        'chest' => mgChest,
        'back' => mgBack,
        'legs' => mgLegs,
        'shoulders' => mgShoulders,
        'arms' => mgArms,
        'core' => mgCore,
        'flexibility' => 'Flexibilidade',
        'cardio' => 'Cardio',
        _ => key,
      };

  String equipment(String id) {
    final norm = id.trim().toLowerCase();
    if (appLanguage == 'pt' && FitnessTranslator.equipmentPt.containsKey(norm)) {
      return FitnessTranslator.equipmentPt[norm]!;
    }
    return switch (norm) {
      'barbell' => equipBarbell,
      'dumbbell' => equipDumbbell,
      'cable' => equipCable,
      'machine' || 'leverage machine' => equipMachine,
      'bodyweight' || 'body weight' => equipBodyweight,
      'weighted' => equipWeighted,
      'band' || 'resistance band' => equipBand,
      'kettlebell' => equipKettlebell,
      'all' => appLanguage == 'es' ? 'Todo el material' : (appLanguage == 'pt' ? 'Todos os Equip.' : 'All Equipment'),
      _ => equipOther,
    };
  }

  String difficulty(String id) => switch (id.trim().toLowerCase()) {
        'beginner' => diffBeginner,
        'intermediate' => diffIntermediate,
        'advanced' => diffAdvanced,
        'all' => appLanguage == 'es' ? 'Todos los niveles' : (appLanguage == 'pt' ? 'Todos os Níveis' : 'All Levels'),
        _ => diffIntermediate,
      };

  String weekday(int w) =>
      _capitalize(_dates(DateFormat.EEEE).format(DateTime(2024, 1, w)));

  String weekdayInitial(int w) =>
      _dates((l) => DateFormat('', l)).dateSymbols.NARROWWEEKDAYS[w % 7];

  String longDate(DateTime d) => '${weekday(d.weekday)}, ${shortDate(d)}';

  String shortDate(DateTime d) => _dates(DateFormat.MMMd).format(d);

  String fullDate(DateTime d) => '${weekday(d.weekday)}, ${_dates(DateFormat.MMMMd).format(d)}';

  String shortDateYear(DateTime d) => _dates(DateFormat.yMMMd).format(d);

  String monthInitial(int m) =>
      _dates((l) => DateFormat('', l)).dateSymbols.NARROWMONTHS[m - 1];

  String monthName(int m) =>
      _capitalize(_dates(DateFormat.MMMM).format(DateTime(2024, m)));

  String monthYear(DateTime d) => _capitalize(_dates(DateFormat.yMMMM).format(d));

  String catalogName(String id, String fallback) => _catalogNames[appLanguage]?[id] ?? fallback;

  List<String> catalogSteps(String id, List<String> fallback) =>
      _catalogSteps[appLanguage]?[id] ?? fallback;

  String get liveChannel => switch (appLanguage) {
        'pt' => 'Treino em andamento',
        'es' => 'Entrenamiento activo',
        _ => 'Active workout',
      };

  String get liveChannelWhy => switch (appLanguage) {
        'pt' => 'Mostra o exercício atual, série e tempo de descanso durante o treino',
        'es' => 'Muestra el ejercicio actual, serie y descanso durante el entreno',
        _ => 'Shows current exercise, set and rest timer during workout',
      };

  String liveSet(int n, int total) => switch (appLanguage) {
        'pt' => 'Série $n de $total',
        'es' => 'Serie $n de $total',
        _ => 'Set $n of $total',
      };

  String get liveResting => switch (appLanguage) {
        'pt' => 'Descanso',
        'es' => 'Descanso',
        _ => 'Rest',
      };

  String get liveAllDone => switch (appLanguage) {
        'pt' => 'Todas as séries concluídas',
        'es' => 'Todas las series completas',
        _ => 'All sets done',
      };

  String get liveDoneSet => switch (appLanguage) {
        'pt' => 'Série feita',
        'es' => 'Serie hecha',
        _ => 'Done set',
      };

  String get liveSkipRest => switch (appLanguage) {
        'pt' => 'Pular descanso',
        'es' => 'Saltar descanso',
        _ => 'Skip rest',
      };

  String get livePause => switch (appLanguage) {
        'pt' => 'Pausar',
        'es' => 'Pausar',
        _ => 'Pause',
      };

  String get liveResume => switch (appLanguage) {
        'pt' => 'Retomar',
        'es' => 'Reanudar',
        _ => 'Resume',
      };

  String get liveNext => switch (appLanguage) {
        'pt' => 'Próximo',
        'es' => 'Siguiente',
        _ => 'Next',
      };

  String liveUpNext(String name) => switch (appLanguage) {
        'pt' => 'Depois: $name',
        'es' => 'Siguiente: $name',
        _ => 'Next: $name',
      };
}

String _capitalize(String s) => s.isEmpty ? s : s[0].toUpperCase() + s.substring(1);
