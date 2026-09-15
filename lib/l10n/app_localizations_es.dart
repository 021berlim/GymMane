// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get languageName => 'Español';

  @override
  String vsLastMonthLabel(String pct) {
    return '$pct% vs. mes pasado';
  }

  @override
  String levelStreakLabel(int level, String streak) {
    return 'Nivel $level · $streak';
  }

  @override
  String get save => 'GUARDAR';

  @override
  String get cancel => 'Cancelar';

  @override
  String get cancelCaps => 'CANCELAR';

  @override
  String get deleteCaps => 'BORRAR';

  @override
  String get done => 'LISTO';

  @override
  String get set => 'Fijar';

  @override
  String get home => 'INICIO';

  @override
  String get progress => 'PROGRESO';

  @override
  String get exercises => 'EJERCICIOS';

  @override
  String get settings => 'AJUSTES';

  @override
  String get today => 'HOY';

  @override
  String get thisWeek => 'ESTA SEMANA';

  @override
  String get recommended => 'RECOMENDADOS';

  @override
  String get goal => 'OBJETIVO';

  @override
  String get volume => 'VOLUMEN';

  @override
  String get setsToday => 'SERIES HOY';

  @override
  String get prs => 'RÉCORDS';

  @override
  String get todaysFocus => 'FOCO DE HOY';

  @override
  String get todaysRoutine => 'ENTRENAMIENTO DE HOY';

  @override
  String get startWorkout => 'EMPEZAR';

  @override
  String get routines => 'ENTRENAMIENTO';

  @override
  String get goToWorkouts => 'MIS ENTRENAMIENTOS';

  @override
  String get tools => 'HERRAMIENTAS';

  @override
  String get firstSessionHint => 'Elige tus músculos y registra tu primera sesión';

  @override
  String exerciseCount(int n) {
    String _temp0 = intl.Intl.pluralLogic(n, locale: localeName, other: '$n ejercicios', one: '$n ejercicio');
    return '$_temp0';
  }

  @override
  String get pushDay => 'DÍA DE EMPUJE';

  @override
  String get pullDay => 'DÍA DE TIRÓN';

  @override
  String get legDay => 'DÍA DE PIERNA';

  @override
  String get pushFocus => 'Pecho · Hombros · Tríceps';

  @override
  String get pullFocus => 'Espalda · Bíceps · Trapecio';

  @override
  String get legFocus => 'Cuádriceps · Isquios · Glúteos';

  @override
  String get train => 'ENTRENAR';

  @override
  String get chooseRoutineTitle => 'ELIGE TU ENTRENAMIENTO';

  @override
  String get chooseRoutineBody => 'Elige una rutina guardada o crea un entrenamiento personalizado.';

  @override
  String get customWorkout => 'ENTRENAMIENTO PERSONALIZADO';

  @override
  String get logWorkout => 'REGISTRAR ENTRENAMIENTO';

  @override
  String get step1 => 'PASO 1 DE 2';

  @override
  String get step2 => 'PASO 2 DE 2';

  @override
  String get chooseFocus => 'ELIGE TU FOCO';

  @override
  String get buildSession => 'MONTA TU SESIÓN';

  @override
  String get tapMuscles => 'Toca los músculos que quieras entrenar — frente y espalda.';

  @override
  String get noMusclesYet => 'Ningún músculo elegido — toca el cuerpo para empezar.';

  @override
  String get continueBtn => 'CONTINUAR';

  @override
  String get nothingForFocus => 'Aún no hay nada para este foco';

  @override
  String get goBackPick => 'Vuelve atrás y elige un músculo con ejercicios en tu biblioteca.';

  @override
  String pickedHint(int n) {
    return 'Te hemos montado una sesión — toca para añadir o quitar cualquiera de los $n.';
  }

  @override
  String get pickAnExercise => 'ELIGE UN EJERCICIO';

  @override
  String get searchAllExercises => 'Busca cualquier ejercicio…';

  @override
  String get noExercisesMatch => 'Ningún ejercicio coincide';

  @override
  String get createItInstead => 'Créalo como ejercicio propio';

  @override
  String startCount(int n) {
    String _temp0 = intl.Intl.pluralLogic(n, locale: localeName, other: '$n EJERCICIOS', one: '$n EJERCICIO');
    return 'EMPEZAR · $_temp0';
  }

  @override
  String get inProgress => 'EN CURSO';

  @override
  String get paused => 'EN PAUSA';

  @override
  String get last => 'ÚLTIMA';

  @override
  String get rest => 'DESCANSO';

  @override
  String get skip => 'SALTAR';

  @override
  String get addSet => '+ AÑADIR SERIE';

  @override
  String get finishSession => 'TERMINAR';

  @override
  String get setCol => '#';

  @override
  String get repsCol => 'REPS';

  @override
  String weightCol(String unit) {
    return 'PESO ($unit)';
  }

  @override
  String get repsTitle => 'REPS';

  @override
  String weightTitle(String unit) {
    return 'PESO ($unit)';
  }

  @override
  String get sessionComplete => 'ENTRENO REGISTRADO';

  @override
  String get finishHeadlinePr => 'Récord personal nuevo';

  @override
  String get finishHeadlineGoal => 'Objetivo semanal cumplido';

  @override
  String get finishHeadlineStreak => 'Racha viva';

  @override
  String get finishHeadlineDefault => 'Uno más en el saco';

  @override
  String finishBodyPr(int prs) {
    String _temp0 = intl.Intl.pluralLogic(
      prs,
      locale: localeName,
      other: '$prs ejercicios',
      one: 'un ejercicio',
    );
    return 'Has levantado más que nunca en $_temp0. Ya está en tus récords.';
  }

  @override
  String get finishBodyGoal => 'Has hecho las sesiones que te propusiste esta semana.';

  @override
  String finishBodyStreak(int streak) {
    return '$streak días seguidos. Lo difícil es no parar.';
  }

  @override
  String get finishBodyDefault => 'Registrado y contado. Lo que mueve los números es la constancia.';

  @override
  String get vsLastTime => 'VS. LA ÚLTIMA VEZ';

  @override
  String get firstTime => 'Primera vez registrado';

  @override
  String prCount(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n récords nuevos',
      one: '$n récord nuevo',
    );
    return '$_temp0';
  }

  @override
  String get saveAndExit => 'GUARDAR Y SALIR';

  @override
  String get duration => 'DURACIÓN';

  @override
  String get setsCaps => 'SERIES';

  @override
  String exerciseXofY(int i, int n) {
    return 'EJERCICIO $i DE $n';
  }

  @override
  String get decrease => 'Bajar';

  @override
  String get increase => 'Subir';

  @override
  String markSet(int n) {
    return 'Marcar la serie $n como hecha';
  }

  @override
  String get pauseWorkout => 'Pausar el entreno';

  @override
  String get resumeWorkout => 'Reanudar el entreno';

  @override
  String get discardTitle => '¿Descartar el entreno?';

  @override
  String get discardBody => 'Perderás las series de esta sesión.';

  @override
  String get keepTraining => 'Seguir entrenando';

  @override
  String get discard => 'Descartar';

  @override
  String get notifRestChannel => 'Temporizador de descanso';

  @override
  String get notifRestChannelWhy => 'Te avisa cuando termina el descanso entre series';

  @override
  String get notifAlertChannel => 'Temporizador de descanso (aviso)';

  @override
  String get notifAlertChannelWhy => 'Muestra un aviso en cuanto acaba el descanso';

  @override
  String get notifGoalChannel => 'Objetivos';

  @override
  String get notifGoalChannelWhy => 'Notificaciones de objetivos cumplidos';

  @override
  String get goalReachedTitle => '¡Objetivo cumplido! 🎯';

  @override
  String get goalReachedBody => '¡Enhorabuena! Has alcanzado tu objetivo.';

  @override
  String get rateAggressiveWarning => 'Ritmo por encima del recomendado';

  @override
  String get restOverTitle => 'Se acabó el descanso';

  @override
  String get restOverBody => 'A por ello — te espera la siguiente serie.';

  @override
  String get totalVolume30d => 'VOLUMEN TOTAL · 30 DÍAS';

  @override
  String get consistency => 'CONSTANCIA';

  @override
  String monthSessionCount(int n) {
    String _temp0 = intl.Intl.pluralLogic(n, locale: localeName, other: '$n sesiones', one: '$n sesión');
    return '$_temp0';
  }

  @override
  String monthVolumeLabel(String v) {
    return '$v de volumen';
  }

  @override
  String sessionsLogged(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n sesiones registradas',
      one: '$n sesión registrada',
    );
    return '$_temp0';
  }

  @override
  String streakDays(int n) {
    String _temp0 = intl.Intl.pluralLogic(n, locale: localeName, other: 'días', one: 'día');
    return 'racha de $n $_temp0';
  }

  @override
  String get ofensivaAtRisk => 'Entrena hoy para mantener tu racha';

  @override
  String get bodyweight => 'PESO CORPORAL';

  @override
  String get notLoggedYet => 'Sin registrar';

  @override
  String get logShort => '+ ANOTAR';

  @override
  String get logBodyweight => 'ANOTAR PESO';

  @override
  String get trackWeight => 'Sigue tu peso en el tiempo';

  @override
  String get noWeightLoggedYet => 'Ningún peso registrado aún';

  @override
  String get noWeightLoggedYetSub => 'Registra tu peso para seguir tu evolución aquí';

  @override
  String get logWeightToTrack => 'Anota tu peso para dar seguimiento';

  @override
  String get bodyweightBeforeWorkout => 'Peso antes del entrenamiento';

  @override
  String get bodyweightAfterWorkout => 'Peso después del entrenamiento';

  @override
  String get bodyweightComparison => 'COMPARACIÓN DEL ENTRENAMIENTO';

  @override
  String get muscleMap => 'MAPA MUSCULAR';

  @override
  String get days7 => '7D';

  @override
  String get days30 => '30D';

  @override
  String get days90 => '3M';

  @override
  String get days180 => '6M';

  @override
  String get days365 => '1Y';

  @override
  String get heatLow => 'Sin tocar';

  @override
  String get heatHigh => 'Volumen pleno';

  @override
  String get muscleMapEmpty => 'Registra una sesión y tu cuerpo se irá encendiendo aquí.';

  @override
  String get muscleMapHint => 'Toca un músculo para ver lo que le ha tocado.';

  @override
  String muscleMapBehind(String names) {
    return 'Te estás dejando: $names';
  }

  @override
  String ofTarget(int pct) {
    return '$pct% del objetivo';
  }

  @override
  String get muscleSplit => 'REPARTO MUSCULAR';

  @override
  String get splitEmpty => 'Entrena para ver cómo se reparte tu volumen entre grupos musculares.';

  @override
  String get personalRecords => 'RÉCORDS PERSONALES';

  @override
  String get prEmpty => 'Tus récords aparecerán aquí según registres series.';

  @override
  String get strength1rm => 'FUERZA · 1RM EST.';

  @override
  String get strengthEmpty => 'Registra un ejercicio dos veces y aquí saldrá su curva de fuerza.';

  @override
  String oneRmEst(String w) {
    return '1RM est. $w';
  }

  @override
  String get restDayShort => 'Descanso';

  @override
  String get restDay => 'Día de descanso — nada registrado.';

  @override
  String get tapToDelete => 'Toca la papelera para quitar algo mal anotado.';

  @override
  String get delete => 'Borrar';

  @override
  String get deleteEntry => '¿Borrar esta anotación?';

  @override
  String deleteEntryBody(String name) {
    return '\"$name\" desaparecerá de este día, y de tus récords y gráficas.';
  }

  @override
  String get bodyweightHistory => 'HISTORIAL';

  @override
  String get workoutProgression => 'WORKOUT PROGRESSION';

  @override
  String avgDiff(String diff) {
    return 'Average: $diff';
  }

  @override
  String get noBodyweightYet => 'Nada registrado todavía.';

  @override
  String get exercisesCaps => 'EJERCICIOS';

  @override
  String get timeCaps => 'TIEMPO';

  @override
  String libraryCount(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n ejercicios en tu biblioteca',
      one: '$n ejercicio en tu biblioteca',
    );
    return '$_temp0';
  }

  @override
  String get searchExercises => 'Buscar ejercicios';

  @override
  String get muscleFilter => 'MÚSCULO';

  @override
  String get levelFilter => 'NIVEL';

  @override
  String get newExercise => 'NUEVO EJERCICIO';

  @override
  String get exerciseName => 'Nombre del ejercicio';

  @override
  String get equipmentLabel => 'MATERIAL';

  @override
  String get addExercise => 'AÑADIR EJERCICIO';

  @override
  String get advanced => 'AVANZADO';

  @override
  String get demoMedia => 'DEMOSTRACIÓN';

  @override
  String get addMedia => 'Añadir media';

  @override
  String get mediaHint => 'Imagen, GIF o vídeo';

  @override
  String get changeMedia => 'Cambiar';

  @override
  String get videoSelected => 'Vídeo seleccionado';

  @override
  String get favouritesOnly => 'Favoritos';

  @override
  String get noFavouritesYet => 'Aún no tienes favoritos';

  @override
  String get noFavouritesHint => 'Toca la estrella de un ejercicio para tenerlo aquí.';

  @override
  String get clearFilters => 'Quitar filtros';

  @override
  String get noExercisesFound => 'Sin resultados';

  @override
  String get noExercisesHint => 'Prueba otra búsqueda o quita los filtros.';

  @override
  String get personalRecord => 'RÉCORD PERSONAL';

  @override
  String get history => 'HISTORIAL';

  @override
  String get noHistory => 'Aún no hay sesiones. Entrena este ejercicio para crear historial.';

  @override
  String get notes => 'NOTAS';

  @override
  String get notePlaceholder => 'Claves, montaje, cómo te fue…';

  @override
  String showAllNotes(int n) {
    return 'Ver las $n notas';
  }

  @override
  String get showFewerNotes => 'Ver menos';

  @override
  String moreNotes(int n) {
    String _temp0 = intl.Intl.pluralLogic(n, locale: localeName, other: '$n notas más', one: '$n nota más');
    return '$_temp0';
  }

  @override
  String get howTo => 'CÓMO SE HACE';

  @override
  String get similar => 'SIMILARES';

  @override
  String get primaryLabel => 'PRINCIPAL';

  @override
  String get secondaryLabel => 'SECUNDARIOS';

  @override
  String get none => 'Ninguno';

  @override
  String setCount(int n) {
    String _temp0 = intl.Intl.pluralLogic(n, locale: localeName, other: '$n series', one: '$n serie');
    return '$_temp0';
  }

  @override
  String volumeSuffix(String v) {
    return '$v de volumen';
  }

  @override
  String get weeklyPlan => 'PLAN SEMANAL DE ENTRENAMIENTO';

  @override
  String get yourRoutines => 'TUS ENTRENAMIENTOS';

  @override
  String get noRoutines => 'Aún no hay entrenamientos. Crea uno y añade tus ejercicios.';

  @override
  String get newRoutine => 'NUEVO ENTRENAMIENTO';

  @override
  String get routineName => 'Nombre del entrenamiento';

  @override
  String get schedule => 'PROGRAMAR';

  @override
  String get addFromList => 'Añade ejercicios de la lista de abajo.';

  @override
  String get addExercises => 'Añadir ejercicios';

  @override
  String get deleteRoutine => '¿Borrar esta rutina?';

  @override
  String exercisesWithCount(int n) {
    return 'EJERCICIOS · $n';
  }

  @override
  String setDay(String day) {
    return 'PONER $day';
  }

  @override
  String get newRoutineName => 'Entrenamiento nuevo';

  @override
  String get dragToReorder => 'Mantén y arrastra para reordenar — es el orden en que entrenas.';

  @override
  String reorderHandle(String name) {
    return 'Reordenar $name';
  }

  @override
  String get removeFromRoutine => 'Quitar de la rutina';

  @override
  String get dropExercise => '¿Quitar este ejercicio?';

  @override
  String dropExerciseBody(String name) {
    return '\"$name\" sale de este entreno. No se pierde nada de lo anotado.';
  }

  @override
  String get drop => 'Quitar';

  @override
  String get addToWorkout => 'AÑADIR EJERCICIO';

  @override
  String get resetData => 'Borrar todos mis datos';

  @override
  String get resetTitle => '¿Borrar todo?';

  @override
  String get resetBody =>
      'Sesiones, récords, rutinas, notas y perfil. No tiene vuelta atrás — exporta una copia antes si crees que la querrás.';

  @override
  String get resetConfirm => 'Borrar todo';

  @override
  String get resetDone => 'Todos los datos borrados';

  @override
  String get support => 'APOYO';

  @override
  String get reportBug => 'Informar de un fallo';

  @override
  String get requestFeature => 'Pedir una función';

  @override
  String get starOnGithub => 'Dar una estrella en GitHub';

  @override
  String get buyCoffee => 'Invítame a un café';

  @override
  String get cantOpenLink => 'No he podido abrir el enlace';

  @override
  String get preferences => 'PREFERENCIAS';

  @override
  String get theme => 'Tema';

  @override
  String get darkTheme => 'Oscuro';

  @override
  String get lightTheme => 'Claro';

  @override
  String get languageLabel => 'Idioma';

  @override
  String get unitsLabel => 'Unidades';

  @override
  String get restTimer => 'Descanso';

  @override
  String get alarmBlockedTitle => 'Las notificaciones están apagadas';

  @override
  String get alarmBlockedBody => 'La alarma de descanso no sonará con la pantalla bloqueada';

  @override
  String get alarmBlockedAction => 'ACTIVAR';

  @override
  String get alarmXiaomiTitle => 'HyperOS / Xiaomi detectado';

  @override
  String get alarmXiaomiBody =>
      'Activa el \'Inicio automático\' y pon la batería en \'Sin restricciones\' para que la alarma sea fiable.';

  @override
  String get alarmSound => 'Sonido de alarma';

  @override
  String get alarmDefaultName => 'Por defecto';

  @override
  String get alarmSoundHint => 'Pon el tuyo — hasta 15 segundos';

  @override
  String get alarmChoose => 'Elegir un sonido…';

  @override
  String get alarmPreview => 'Escuchar el actual';

  @override
  String get alarmReset => 'Volver al de por defecto';

  @override
  String get alarmTooLong => 'Ese sonido dura más de 15 segundos';

  @override
  String get alarmInvalid => 'No he podido leer ese audio';

  @override
  String alarmChanged(String name) {
    return 'Sonido cambiado a «$name»';
  }

  @override
  String get alarmChangedDefault => 'De vuelta al sonido de fábrica';

  @override
  String get enablePhotosLabel => 'Progress photos';

  @override
  String get enablePhotosHint => 'Take photos before or after your workout';

  @override
  String get photoTimingLabel => 'When to take photos';

  @override
  String get photoTimingBefore => 'Before';

  @override
  String get photoTimingAfter => 'After';

  @override
  String get photoTimingBoth => 'Both';

  @override
  String get onbPhotosTitle => 'Progress photos?';

  @override
  String get onbPhotosWhy => 'Compare your body before and after each workout visually.';

  @override
  String get homeWidgets => 'PANTALLA DE INICIO';

  @override
  String get addActivityWidget => 'Añadir widget de actividad';

  @override
  String get addStatsWidget => 'Añadir widget de estadísticas';

  @override
  String get pinUnsupported => 'Añádelo desde el menú de widgets de tu lanzador';

  @override
  String get background => 'Fondo';

  @override
  String get bgNone => 'Ninguno';

  @override
  String get bgDots => 'Puntos';

  @override
  String get bgGrid => 'Rejilla';

  @override
  String get data => 'DATOS';

  @override
  String get exportCsv => 'Exportar entrenos (CSV)';

  @override
  String get exportBackup => 'Exportar copia (JSON)';

  @override
  String get importBackup => 'Importar copia';

  @override
  String get importHint => 'Elige un archivo .json exportado de FIT//IRON. Reemplazará tus datos actuales.';

  @override
  String get import => 'Importar';

  @override
  String get chooseFile => 'Elegir archivo';

  @override
  String get importFromApp => 'Importar de otra app';

  @override
  String get importUnknownFormat => 'Ese fichero no es un export de Hevy, Strong ni FitNotes';

  @override
  String get importZipNoWeights => 'Ese zip no trae ningún fichero de peso';

  @override
  String importWeights(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n pesajes importados',
      one: '$n pesaje importado',
    );
    return '$_temp0';
  }

  @override
  String get importReadFailed => 'No he podido leer ese archivo';

  @override
  String get importUnitTitle => '¿En qué unidad está ese archivo?';

  @override
  String get importUnitBody => 'Esta exportación no dice en qué unidad están los pesos.';

  @override
  String get importNothing => 'Nada nuevo que importar';

  @override
  String importDone(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n sesiones importadas',
      one: '$n sesión importada',
    );
    return '$_temp0';
  }

  @override
  String get aboutFitiron => 'Sobre FIT//IRON';

  @override
  String get yourProfile => 'TU PERFIL';

  @override
  String get autofills => 'Rellena las calculadoras';

  @override
  String get nameLabel => 'NOMBRE';

  @override
  String get sexLabel => 'SEXO';

  @override
  String get male => 'Hombre';

  @override
  String get female => 'Mujer';

  @override
  String get ageLabel => 'EDAD';

  @override
  String get heightLabel => 'ALTURA';

  @override
  String get weightLabel => 'PESO';

  @override
  String get weeklyGoal => 'OBJETIVO SEMANAL';

  @override
  String get activityLabel => 'ACTIVIDAD';

  @override
  String get addPhoto => 'Añadir foto';

  @override
  String get removePhoto => 'Quitar foto';

  @override
  String get takePhoto => 'Hacer una foto';

  @override
  String get photoBefore => 'Photo before';

  @override
  String get photoAfter => 'Photo after';

  @override
  String get photoGallery => 'PHOTO GALLERY';

  @override
  String get noPhotosYet => 'No photos recorded yet.';

  @override
  String get confirmPhoto => 'Use this photo';

  @override
  String get retakePhoto => 'Retake photo';

  @override
  String get chooseGallery => 'Elegir de la galería';

  @override
  String get backupCopied => 'Copia guardada en el portapapeles';

  @override
  String get backupImported => 'Copia importada';

  @override
  String get backupFailed => 'No he podido leer esa copia';

  @override
  String get nothingToExport => 'Nada que exportar aún — registra una sesión';

  @override
  String get athlete => 'Atleta';

  @override
  String calculatorsCount(int n) {
    return '$n calculadoras para tu entreno';
  }

  @override
  String get result => 'RESULTADO';

  @override
  String get weightLifted => 'PESO LEVANTADO';

  @override
  String get repsPerformed => 'REPS HECHAS';

  @override
  String get neck => 'CUELLO';

  @override
  String get waist => 'CINTURA';

  @override
  String get hip => 'CADERA (mujeres)';

  @override
  String get targetWeight => 'PESO OBJETIVO';

  @override
  String get workingWeight => 'PESO DE TRABAJO';

  @override
  String get activityLevel => 'NIVEL DE ACTIVIDAD';

  @override
  String get barWeight => 'PESO DE LA BARRA';

  @override
  String get perSide => 'POR LADO';

  @override
  String get justTheBar => 'Solo la barra.';

  @override
  String perSideCount(int n) {
    return '× $n por lado';
  }

  @override
  String rampSet(String pct, int reps) {
    return '$pct · $reps reps';
  }

  @override
  String get toolNameRm => '1RM';

  @override
  String get toolNameBmi => 'IMC';

  @override
  String get toolNameCal => 'Calorías';

  @override
  String get toolNameBf => 'Grasa corporal';

  @override
  String get toolNamePlate => 'Discos';

  @override
  String get toolNameWarmup => 'Calentamiento';

  @override
  String get toolTitleRm => 'Calculadora de 1RM';

  @override
  String get toolTitleBmi => 'Calculadora de IMC';

  @override
  String get toolTitleCal => 'Calorías y macros';

  @override
  String get toolTitleBf => '% de grasa corporal';

  @override
  String get toolTitlePlate => 'Calculadora de discos';

  @override
  String get toolTitleWarmup => 'Series de calentamiento';

  @override
  String get toolHintRm => 'Máximo estimado a 1 repetición (fórmula de Epley)';

  @override
  String get toolHintCal => 'Mantenimiento diario estimado';

  @override
  String get toolHintBf => 'Estimación por el método US Navy';

  @override
  String get toolHintPlate => 'Peso total de la barra';

  @override
  String get toolHintWarmup => 'Peso de trabajo objetivo';

  @override
  String get toolDescRm => 'Máximo estimado a 1 repetición';

  @override
  String get toolDescBmi => 'Índice de masa corporal';

  @override
  String get toolDescCal => 'Calorías y macros';

  @override
  String get toolDescBf => 'Porcentaje de grasa corporal';

  @override
  String get toolDescPlate => 'Qué discos poner en la barra';

  @override
  String get toolDescWarmup => 'Series de aproximación';

  @override
  String get macroProtein => 'PROTEÍNA';

  @override
  String get macroCarbs => 'CARBOHIDRATOS';

  @override
  String get macroFat => 'GRASA';

  @override
  String get bmiUnderweight => 'Bajo peso';

  @override
  String get bmiNormal => 'Normal';

  @override
  String get bmiOverweight => 'Sobrepeso';

  @override
  String get bmiObese => 'Obesidad';

  @override
  String get actSedentary => 'Sedentario';

  @override
  String get actLight => 'Ligero';

  @override
  String get actActive => 'Activo';

  @override
  String get actModerate => 'Moderado';

  @override
  String get muscleChest => 'Pecho';

  @override
  String get muscleBack => 'Espalda';

  @override
  String get muscleShoulders => 'Hombros';

  @override
  String get muscleBiceps => 'Bíceps';

  @override
  String get muscleTriceps => 'Tríceps';

  @override
  String get muscleForearm => 'Antebrazo';

  @override
  String get muscleTrapezius => 'Trapecio';

  @override
  String get muscleAbdomen => 'Abdomen';

  @override
  String get muscleObliques => 'Oblicuos';

  @override
  String get muscleQuads => 'Cuádriceps';

  @override
  String get muscleHamstrings => 'Isquiotibiales';

  @override
  String get muscleGlutes => 'Glúteos';

  @override
  String get muscleCalves => 'Gemelos';

  @override
  String get mgChest => 'Pecho';

  @override
  String get mgBack => 'Espalda';

  @override
  String get mgLegs => 'Piernas';

  @override
  String get mgShoulders => 'Hombros';

  @override
  String get mgArms => 'Brazos';

  @override
  String get mgCore => 'Core';

  @override
  String get equipBarbell => 'Barra';

  @override
  String get equipDumbbell => 'Mancuerna';

  @override
  String get equipCable => 'Polea';

  @override
  String get equipMachine => 'Máquina';

  @override
  String get equipBodyweight => 'Peso corporal';

  @override
  String get equipWeighted => 'Con lastre';

  @override
  String get equipBand => 'Goma';

  @override
  String get equipKettlebell => 'Kettlebell';

  @override
  String get equipOther => 'Otro';

  @override
  String get diffBeginner => 'Principiante';

  @override
  String get diffAdvanced => 'Avanzado';

  @override
  String get diffIntermediate => 'Intermedio';

  @override
  String get about => 'ACERCA DE';

  @override
  String version(String v) {
    return 'Versión $v';
  }

  @override
  String get aboutBlurb => 'Hecha por gente que entrena, para gente que entrena.';

  @override
  String get freeForever => 'Gratis para siempre';

  @override
  String get freeForeverWhy => 'Sin suscripción, sin anuncios, nada escondido tras un muro de pago.';

  @override
  String get fullyOffline => 'Totalmente sin conexión';

  @override
  String get fullyOfflineWhy => 'Sin cuenta, sin servidores. Tu entreno no sale de este móvil.';

  @override
  String get yoursToTake => 'Tus datos son tuyos';

  @override
  String get yoursToTakeWhy => 'Expórtalos a CSV cuando quieras, y bórralos todos de un toque.';

  @override
  String get whatsInside => 'QUÉ LLEVA DENTRO';

  @override
  String exercisesInside(int n) {
    return '$n ejercicios';
  }

  @override
  String get exercisesInsideWhy => 'Cada uno con su animación y sus instrucciones paso a paso.';

  @override
  String get calculatorsInside => '6 calculadoras';

  @override
  String get calculatorsInsideWhy =>
      '1RM, discos, IMC, calorías, grasa y calentamiento — todas con fórmulas publicadas.';

  @override
  String get mathInside => 'Cuentas honestas';

  @override
  String get mathInsideWhy =>
      'El volumen, los récords y la racha salen de tus series. Aquí no hay nada decorativo.';

  @override
  String get yourNumbers => 'TUS NÚMEROS';

  @override
  String get sessionsCaps => 'SESIONES';

  @override
  String get liftedCaps => 'LEVANTADO';

  @override
  String get streakCaps => 'RACHA';

  @override
  String daysUnit(int n) {
    String _temp0 = intl.Intl.pluralLogic(n, locale: localeName, other: 'días', one: 'día');
    return '$_temp0';
  }

  @override
  String get restDefaultLabel => 'Descanso';

  @override
  String restDefault(int s) {
    return 'Por defecto ${s}s — se cambia en Ajustes';
  }

  @override
  String get reset => 'REINICIAR';

  @override
  String get welcomeKicker => 'TE DAMOS LA BIENVENIDA A';

  @override
  String get welcomeBlurb => 'Todo se queda en tu móvil. Sin cuenta, sin internet, sin pagar nada.';

  @override
  String get welcomeStart => 'EMPEZAR';

  @override
  String onbStep(int i, int n) {
    return 'PASO $i DE $n';
  }

  @override
  String get onbNameTitle => '¿Cómo te llamamos?';

  @override
  String get onbNameHint => 'Tu nombre';

  @override
  String get onbNameWhy => 'Solo para saludarte. No sale del móvil.';

  @override
  String get onbBodyTitle => 'Cuatro números';

  @override
  String get onbBodyWhy => 'Alimentan las calculadoras. Puedes cambiarlos cuando quieras en Ajustes.';

  @override
  String get onbGoalTitle => '¿Cuántas veces entrenas?';

  @override
  String get onbGoalWhy => 'Define tu anillo de objetivo semanal. Sé sincero, no ambicioso.';

  @override
  String perWeek(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n sesiones por semana',
      one: '$n sesión por semana',
    );
    return '$_temp0';
  }

  @override
  String get onbUnitsTitle => '¿Kilos o libras?';

  @override
  String get onbFocusTitle => 'What is your main goal?';

  @override
  String get onbFocusWhy => 'We\'ll suggest exercises that match what you\'re trying to achieve.';

  @override
  String get focusHypertrophy => 'Hypertrophy';

  @override
  String get focusStrength => 'Strength';

  @override
  String get focusWeightLoss => 'Weight Loss';

  @override
  String get focusEndurance => 'Endurance';

  @override
  String get focusHealth => 'General Health';

  @override
  String get next => 'SIGUIENTE';

  @override
  String get back => 'ATRÁS';

  @override
  String get skip2 => 'Saltar';

  @override
  String get artCredit => 'Ilustraciones de ejercicios de Bryl Lim y Everkinetic';

  @override
  String get muscleWarmup => 'Flexibilidad / Calentamiento';

  @override
  String get muscleCardio => 'Cardio';

  @override
  String get exploreDetails => 'Explorar detalles';

  @override
  String get currentWeekPeriod => 'Semana actual';

  @override
  String get muscleDistribution => 'Distribución Muscular';

  @override
  String get tabWeek => 'SEMANA';

  @override
  String get tabMonth => 'MES';

  @override
  String get tabYear => 'AÑO';

  @override
  String get equivalentSets => 'Series equivalentes';

  @override
  String get equivalentVolume => 'Volumen equivalente';

  @override
  String get previousWeekPeriod => 'Semana anterior';

  @override
  String get currentMonthPeriod => 'Mes actual';

  @override
  String get previousMonthPeriod => 'Mes anterior';

  @override
  String get currentYearPeriod => 'Año actual';

  @override
  String get previousYearPeriod => 'Año anterior';

  @override
  String get equivalentSetsInfoDesc =>
      'Tu distribución muscular se calcula en función de las series totales completadas en todos tus entrenamientos.\n\nLos músculos primarios cuentan como 1 serie completa por serie realizada. Los músculos secundarios cuentan como 0.5 series, ya que ayudan en el movimiento.';

  @override
  String get equivalentVolumeInfoDesc =>
      'Tu distribución muscular semanal se calcula en función del volumen total (series, repeticiones y carga) completado en todos tus entrenamientos.\n\nLos músculos primarios cuentan como 1 serie completa por serie realizada. Los músculos secundarios cuentan como 0.5 series, ya que ayudan en el movimiento.';

  @override
  String get weeklyProgressTitle => 'PROGRESO SEMANAL';

  @override
  String get weeklyNoData => 'Nada que mostrar aún';

  @override
  String get weeklyNoDataSub => 'Los resultados aparecerán después de tu primer entrenamiento.';

  @override
  String get tabTime => 'TIEMPO';

  @override
  String get tabVolume => 'VOLUMEN';

  @override
  String get tabReps => 'REPS';
}
