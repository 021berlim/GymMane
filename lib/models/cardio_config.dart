/// Tipos de equipamentos e modalidades de cardio mapeados no aplicativo.
enum CardioCategoryType {
  treadmill,   // Esteira: Corrida / Caminhada -> Inclinação (%)
  bike,        // Bicicleta Ergométrica / Cicloergômetro -> Resistência (Nível)
  elliptical,  // Elíptico / Wave Machine -> Resistência (Nível)
  stepmill,    // Simulador de Escada -> Nível / Velocidade
  rower,       // Remo Seco / Rower -> Resistência / Damper
  skierg,      // SkiErg -> Damper
  rope,        // Corda de Pular / Corda Naval -> Intensidade / Nível
  general,     // Geral / Corporal / HIIT (Burpees, Polichinelos, etc.) -> Intensidade
}

extension CardioCategoryTypeX on CardioCategoryType {
  /// Nome amigável em português do equipamento ou modalidade
  String get displayNamePt {
    switch (this) {
      case CardioCategoryType.treadmill:
        return 'Esteira';
      case CardioCategoryType.bike:
        return 'Bicicleta';
      case CardioCategoryType.elliptical:
        return 'Elíptico';
      case CardioCategoryType.stepmill:
        return 'Simulador de Escada';
      case CardioCategoryType.rower:
        return 'Remo Seco';
      case CardioCategoryType.skierg:
        return 'SkiErg';
      case CardioCategoryType.rope:
        return 'Corda';
      case CardioCategoryType.general:
        return 'Cardio Geral';
    }
  }

  /// Rótulo do parâmetro específico da máquina (exibido na caixa da direita)
  String get paramLabel {
    switch (this) {
      case CardioCategoryType.treadmill:
        return 'INCLINAÇÃO';
      case CardioCategoryType.bike:
      case CardioCategoryType.elliptical:
      case CardioCategoryType.rower:
        return 'RESISTÊNCIA';
      case CardioCategoryType.stepmill:
        return 'NÍVEL';
      case CardioCategoryType.skierg:
        return 'DAMPER';
      case CardioCategoryType.rope:
      case CardioCategoryType.general:
        return 'INTENSIDADE';
    }
  }

  /// Unidade de exibição do parâmetro específico
  String get paramUnit {
    switch (this) {
      case CardioCategoryType.treadmill:
        return '%';
      case CardioCategoryType.bike:
      case CardioCategoryType.elliptical:
      case CardioCategoryType.stepmill:
      case CardioCategoryType.rope:
      case CardioCategoryType.general:
        return 'NÍV';
      case CardioCategoryType.rower:
      case CardioCategoryType.skierg:
        return 'DAMPER';
    }
  }

  /// Valor padrão recomendado para o parâmetro
  double get defaultParam {
    switch (this) {
      case CardioCategoryType.treadmill:
        return 1.0; // 1% de inclinação padrão
      case CardioCategoryType.bike:
      case CardioCategoryType.elliptical:
      case CardioCategoryType.rower:
      case CardioCategoryType.skierg:
        return 5.0; // Nível / Damper 5
      case CardioCategoryType.stepmill:
        return 4.0; // Nível 4
      case CardioCategoryType.rope:
      case CardioCategoryType.general:
        return 3.0; // Nível 3
    }
  }

  /// Incremento do botão de stepper (+ e -)
  double get paramStep {
    switch (this) {
      case CardioCategoryType.treadmill:
        return 0.5; // Inclinação varia de 0.5 em 0.5%
      default:
        return 1.0;
    }
  }

  /// Limite mínimo permitido para o parâmetro
  double get minParam {
    switch (this) {
      case CardioCategoryType.treadmill:
        return 0.0;
      default:
        return 1.0;
    }
  }

  /// Limite máximo permitido para o parâmetro
  double get maxParam {
    switch (this) {
      case CardioCategoryType.treadmill:
        return 25.0;
      case CardioCategoryType.rower:
      case CardioCategoryType.skierg:
        return 10.0;
      default:
        return 30.0;
    }
  }

  /// Duração padrão sugerida em segundos
  int get defaultSeconds {
    switch (this) {
      case CardioCategoryType.treadmill:
      case CardioCategoryType.elliptical:
        return 1200; // 20 minutos
      case CardioCategoryType.bike:
      case CardioCategoryType.stepmill:
        return 900;  // 15 minutos
      case CardioCategoryType.rower:
      case CardioCategoryType.skierg:
        return 600;  // 10 minutos
      case CardioCategoryType.rope:
      case CardioCategoryType.general:
        return 300;  // 5 minutos
    }
  }

  /// Formata o número do parâmetro para visualização
  String formatParam(double val) {
    if (this == CardioCategoryType.treadmill) {
      return (val % 1 == 0) ? '${val.toInt()}' : val.toStringAsFixed(1);
    }
    return '${val.round()}';
  }

  /// Formata o parâmetro com sua unidade de medida
  String formatParamWithUnit(double val) {
    if (this == CardioCategoryType.treadmill) {
      return '${formatParam(val)}%';
    }
    if (this == CardioCategoryType.rower || this == CardioCategoryType.skierg) {
      return 'Damper ${val.round()}';
    }
    return 'Nív ${val.round()}';
  }

  /// Formato conciso para resumos e históricos
  String formatParamShort(double val) {
    if (this == CardioCategoryType.treadmill) {
      return 'Inc ${formatParam(val)}%';
    }
    if (this == CardioCategoryType.rower || this == CardioCategoryType.skierg) {
      return 'Damper ${val.round()}';
    }
    return 'Res ${val.round()}';
  }

  /// Indica se o equipamento possui controle de velocidade (ex: Esteira)
  bool get hasSpeed => this == CardioCategoryType.treadmill;

  /// Rótulo para velocidade
  String get speedLabel => 'VELOCIDADE';

  /// Unidade de velocidade
  String get speedUnit => 'km/h';

  /// Velocidade padrão sugerida em km/h
  double get defaultSpeed => 6.0;

  /// Velocidade mínima permitida em km/h
  double get minSpeed => 0.5;

  /// Velocidade máxima permitida em km/h
  double get maxSpeed => 30.0;

  /// Passo de ajuste da velocidade
  double get speedStep => 0.5;

  /// Formata velocidade em texto
  String formatSpeed(double val) {
    return (val % 1 == 0) ? '${val.toInt()}' : val.toStringAsFixed(1);
  }

  /// Formata velocidade com unidade
  String formatSpeedWithUnit(double val) {
    return '${formatSpeed(val)} km/h';
  }
}

/// Formata segundos em MM:SS ou HH:MM:SS
String formatCardioDuration(int totalSeconds) {
  final sec = totalSeconds < 0 ? 0 : totalSeconds;
  final hours = sec ~/ 3600;
  final minutes = (sec % 3600) ~/ 60;
  final seconds = sec % 60;
  if (hours > 0) {
    return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }
  return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
}

/// Formata segundos em texto amigável (ex: "20 min", "15:30 min")
String formatCardioDurationLabel(int totalSeconds) {
  final sec = totalSeconds < 0 ? 0 : totalSeconds;
  final minutes = sec ~/ 60;
  final seconds = sec % 60;
  if (seconds == 0) {
    return '$minutes min';
  }
  return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')} min';
}

/// Detecta a categoria de cardio de um exercício baseado em seus metadados
CardioCategoryType detectCardioType({
  required String id,
  required String name,
  required String namePt,
  required String equipment,
  required String equipmentPt,
  required String bodyPart,
  required String target,
}) {
  final text = '$id $name $namePt $equipment $equipmentPt $bodyPart $target'.toLowerCase();

  // 1. Esteira (Treadmill, Incline, Caminhada / Corrida na esteira)
  if (text.contains('treadmill') ||
      text.contains('esteira') ||
      text.contains('incline treadmill')) {
    return CardioCategoryType.treadmill;
  }

  // 2. Bicicleta / Ergômetro (Bike, Cicloergômetro, Hands bike, Cycle cross)
  if (text.contains('stationary bike') ||
      text.contains('bicicleta') ||
      text.contains('cycle cross') ||
      text.contains('hands bike') ||
      text.contains('upper body ergometer') ||
      (text.contains('bike') && !text.contains('crunch'))) {
    return CardioCategoryType.bike;
  }

  // 3. Simulador de Escada (Stepmill, Stair, Escada)
  if (text.contains('stepmill') ||
      text.contains('stair') ||
      text.contains('escada')) {
    return CardioCategoryType.stepmill;
  }

  // 4. Elíptico (Elliptical, Elíptico, Wave Machine)
  if (text.contains('elliptical') ||
      text.contains('elíptico') ||
      text.contains('wave machine')) {
    return CardioCategoryType.elliptical;
  }

  // 5. Remo Seco (Rowing machine, Rower, Remo ergômetro)
  if (id == 'rowing' ||
      text.contains('rowing machine') ||
      (text.contains('rower') && !text.contains('dumbbell') && !text.contains('barbell'))) {
    return CardioCategoryType.rower;
  }

  // 6. SkiErg (Ski ergometer, SkiErg)
  if (text.contains('skierg') || text.contains('ski ergometer')) {
    return CardioCategoryType.skierg;
  }

  // 7. Corda (Jump rope, Corda de pular, Battling ropes, Corda naval)
  if (text.contains('jump rope') ||
      text.contains('pular corda') ||
      text.contains('battling rope') ||
      text.contains('corda naval') ||
      (text.contains('rope') && (text.contains('jump') || text.contains('battling')))) {
    return CardioCategoryType.rope;
  }

  // 8. Se for corrida ou caminhada livre/equipamento
  if (text.contains('run (equipment)') ||
      text.contains('push to run') ||
      text.contains('short stride run')) {
    return CardioCategoryType.treadmill;
  }

  // 9. Demais cardios (Burpees, Mountain Climbers, Polichinelos, Pulos, Agilidade)
  return CardioCategoryType.general;
}

/// Identifica se um exercício pertence à categoria de cardio
bool isExerciseCardio({
  required String id,
  required String name,
  required String namePt,
  required String primary,
  required String bodyPart,
  required String bodyPartPt,
  required String target,
  required String targetPt,
  required String category,
  required String equipment,
  required String equipmentPt,
}) {
  final p = primary.trim().toLowerCase();
  if (p == 'cardio') return true;

  final bp = bodyPart.trim().toLowerCase();
  if (bp == 'cardio') return true;

  final bpPt = bodyPartPt.trim().toLowerCase();
  if (bpPt.contains('cardio') || bpPt.contains('aeróbico')) return true;

  final tgt = target.trim().toLowerCase();
  if (tgt == 'cardiovascular system') return true;

  final cat = category.trim().toLowerCase();
  if (cat == 'cardio') return true;

  final eq = equipment.trim().toLowerCase();
  if (eq.contains('treadmill') ||
      eq.contains('stationary bike') ||
      eq.contains('elliptical') ||
      eq.contains('stepmill') ||
      eq.contains('skierg') ||
      eq.contains('upper body ergometer')) {
    return true;
  }

  final n = name.trim().toLowerCase();
  final nPt = namePt.trim().toLowerCase();
  if (n.contains('treadmill') || nPt.contains('esteira')) return true;
  if (n.contains('stationary bike') || nPt.contains('bicicleta')) return true;
  if (n.contains('rowing machine') || (id == 'rowing')) return true;
  if (n.contains('jump rope') || nPt.contains('pular corda')) return true;
  if (n.contains('stepmill') || nPt.contains('simulador de escada')) return true;

  return false;
}
