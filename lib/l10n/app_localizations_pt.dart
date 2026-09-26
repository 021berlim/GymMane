// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Portuguese (`pt`).
class AppLocalizationsPt extends AppLocalizations {
  AppLocalizationsPt([String locale = 'pt']) : super(locale);

  @override
  String get languageName => 'Português';

  @override
  String vsLastMonthLabel(String pct) {
    return '$pct% vs. mês passado';
  }

  @override
  String levelStreakLabel(int level, String streak) {
    return 'Nível $level · $streak';
  }

  @override
  String get save => 'SALVAR';

  @override
  String get cancel => 'Cancelar';

  @override
  String get cancelCaps => 'CANCELAR';

  @override
  String get deleteCaps => 'EXCLUIR';

  @override
  String get done => 'CONCLUÍDO';

  @override
  String get set => 'Série';

  @override
  String get home => 'INÍCIO';

  @override
  String get progress => 'PROGRESSO';

  @override
  String get exercises => 'EXERCÍCIOS';

  @override
  String get settings => 'CONFIGURAÇÕES';

  @override
  String get today => 'HOJE';

  @override
  String get thisWeek => 'ESTA SEMANA';

  @override
  String get recommended => 'RECOMENDADO';

  @override
  String get goal => 'META';

  @override
  String get volume => 'VOLUME';

  @override
  String get setsToday => 'SÉRIES HOJE';

  @override
  String get prs => 'RPs';

  @override
  String get todaysFocus => 'FOCO DE HOJE';

  @override
  String get todaysRoutine => 'TREINO DE HOJE';

  @override
  String get startWorkout => 'INICIAR TREINO';

  @override
  String get routines => 'TREINO';

  @override
  String get goToWorkouts => 'MEUS TREINOS';

  @override
  String get tools => 'FERRAMENTAS';

  @override
  String get firstSessionHint => 'Escolha seus músculos e registre seu primeiro treino';

  @override
  String exerciseCount(int n) {
    String _temp0 = intl.Intl.pluralLogic(n, locale: localeName, other: '$n exercícios', one: '$n exercício');
    return '$_temp0';
  }

  @override
  String get pushDay => 'TREINO DE EMPURRAR';

  @override
  String get pullDay => 'TREINO DE PUXAR';

  @override
  String get legDay => 'TREINO DE PERNAS';

  @override
  String get pushFocus => 'Peito · Ombros · Tríceps';

  @override
  String get pullFocus => 'Costas · Bíceps · Trapézio';

  @override
  String get legFocus => 'Quadríceps · Posteriores · Glúteos';

  @override
  String get train => 'TREINAR';

  @override
  String get chooseRoutineTitle => 'ESCOLHA SEU TREINO';

  @override
  String get chooseRoutineBody => 'Escolha uma rotina salva ou monte um treino personalizado.';

  @override
  String get customWorkout => 'TREINO PERSONALIZADO';

  @override
  String get logWorkout => 'REGISTRAR NOVO TREINO';

  @override
  String get step1 => 'ETAPA 1 DE 2';

  @override
  String get step2 => 'ETAPA 2 DE 2';

  @override
  String get chooseFocus => 'ESCOLHA SEU FOCO';

  @override
  String get buildSession => 'MONTE SEU TREINO';

  @override
  String get tapMuscles => 'Toque nos músculos que você quer treinar, pela frente e por trás.';

  @override
  String get noMusclesYet => 'Nenhum músculo selecionado. Toque no corpo para começar.';

  @override
  String get continueBtn => 'CONTINUAR';

  @override
  String get nothingForFocus => 'Nada para este foco ainda';

  @override
  String get goBackPick => 'Volte e escolha um músculo com exercícios na sua biblioteca.';

  @override
  String pickedHint(int n) {
    return 'Escolhemos um treino para você. Toque para adicionar ou remover qualquer um dos $n.';
  }

  @override
  String get pickAnExercise => 'ESCOLHA UM EXERCÍCIO';

  @override
  String get searchAllExercises => 'Buscar qualquer exercício…';

  @override
  String get noExercisesMatch => 'Nenhum exercício corresponde';

  @override
  String get createItInstead => 'Criar como exercício próprio';

  @override
  String startCount(int n) {
    String _temp0 = intl.Intl.pluralLogic(n, locale: localeName, other: '$n EXERCÍCIOS', one: '$n EXERCÍCIO');
    return 'INICIAR · $_temp0';
  }

  @override
  String get inProgress => 'EM ANDAMENTO';

  @override
  String get paused => 'PAUSADO';

  @override
  String get last => 'ÚLTIMO';

  @override
  String get rest => 'DESCANSO';

  @override
  String get skip => 'PULAR';

  @override
  String get addSet => '+ ADICIONAR SÉRIE';

  @override
  String get finishSession => 'FINALIZAR TREINO';

  @override
  String get setCol => '#';

  @override
  String get repsCol => 'REPS';

  @override
  String weightCol(String unit) {
    return 'PESO ($unit)';
  }

  @override
  String get repsTitle => 'REPETIÇÕES';

  @override
  String weightTitle(String unit) {
    return 'PESO ($unit)';
  }

  @override
  String get sessionComplete => 'TREINO REGISTRADO';

  @override
  String get finishHeadlinePr => 'Novo recorde pessoal';

  @override
  String get finishHeadlineGoal => 'Meta semanal alcançada';

  @override
  String get finishHeadlineStreak => 'Ofensiva mantida';

  @override
  String get finishHeadlineDefault => 'Mais um treino na conta';

  @override
  String finishBodyPr(int prs) {
    String _temp0 = intl.Intl.pluralLogic(
      prs,
      locale: localeName,
      other: '$prs exercícios',
      one: 'um exercício',
    );
    return 'Você levantou mais do que nunca em $_temp0. Agora está nos seus recordes.';
  }

  @override
  String get finishBodyGoal => 'Você completou os treinos que planejou para esta semana.';

  @override
  String finishBodyStreak(int streak) {
    return '$streak dias seguidos. A parte difícil é não parar.';
  }

  @override
  String get finishBodyDefault => 'Registrado e contado. É a consistência que move os números.';

  @override
  String get vsLastTime => 'VS. ÚLTIMA VEZ';

  @override
  String get firstTime => 'Primeiro registro';

  @override
  String prCount(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n novos recordes',
      one: '$n novo recorde',
    );
    return '$_temp0';
  }

  @override
  String get saveAndExit => 'CONTINUAR';

  @override
  String get duration => 'DURAÇÃO';

  @override
  String get setsCaps => 'SÉRIES';

  @override
  String exerciseXofY(int i, int n) {
    return 'EXERCÍCIO $i DE $n';
  }

  @override
  String get decrease => 'Diminuir';

  @override
  String get increase => 'Aumentar';

  @override
  String markSet(int n) {
    return 'Marcar série $n como concluída';
  }

  @override
  String get pauseWorkout => 'Pausar treino';

  @override
  String get resumeWorkout => 'Retomar treino';

  @override
  String get discardTitle => 'Descartar treino?';

  @override
  String get discardBody => 'As séries desta sessão serão perdidas.';

  @override
  String get keepTraining => 'Continuar treinando';

  @override
  String get discard => 'Descartar';

  @override
  String get notifRestChannel => 'Temporizador de descanso';

  @override
  String get notifRestChannelWhy => 'Avisa quando o descanso entre as séries termina';

  @override
  String get notifAlertChannel => 'Temporizador de descanso (alerta)';

  @override
  String get notifAlertChannelWhy => 'Exibe um aviso assim que o descanso termina';

  @override
  String get notifGoalChannel => 'Metas';

  @override
  String get notifGoalChannelWhy => 'Notificações de metas alcançadas';

  @override
  String get goalReachedTitle => 'Meta alcançada! 🎯';

  @override
  String get goalReachedBody => 'Parabéns! Você completou sua meta.';

  @override
  String get rateAggressiveWarning => 'Ritmo acima do recomendado';

  @override
  String get restOverTitle => 'Descanso terminado';

  @override
  String get restOverBody => 'De volta ao treino. A próxima série espera por você.';

  @override
  String get totalVolume30d => 'VOLUME TOTAL · 30 DIAS';

  @override
  String get consistency => 'CONSISTÊNCIA';

  @override
  String monthSessionCount(int n) {
    String _temp0 = intl.Intl.pluralLogic(n, locale: localeName, other: '$n sessões', one: '$n sessão');
    return '$_temp0';
  }

  @override
  String monthVolumeLabel(String v) {
    return '$v de volume';
  }

  @override
  String sessionsLogged(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n sessões registradas',
      one: '$n sessão registrada',
    );
    return '$_temp0';
  }

  @override
  String streakDays(int n) {
    return 'Ofensiva de $n dias';
  }

  @override
  String get ofensivaAtRisk => 'Treine hoje para manter sua ofensiva';

  @override
  String get bodyweight => 'PESO CORPORAL';

  @override
  String get notLoggedYet => 'Ainda não registrado';

  @override
  String get logShort => '+ REGISTRAR';

  @override
  String get logBodyweight => 'REGISTRAR PESO';

  @override
  String get trackWeight => 'Acompanhe seu peso ao longo do tempo';

  @override
  String get noWeightLoggedYet => 'Nenhum peso registrado ainda';

  @override
  String get noWeightLoggedYetSub => 'Registre seu peso para acompanhar sua evolução aqui';

  @override
  String get logWeightToTrack => 'Registre seu peso para acompanhar';

  @override
  String get bodyweightBeforeWorkout => 'Peso antes do treino';

  @override
  String get bodyweightAfterWorkout => 'Peso depois do treino';

  @override
  String get bodyweightComparison => 'COMPARAÇÃO DO TREINO';

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
  String get days365 => '1A';

  @override
  String get heatLow => 'Intocado';

  @override
  String get heatHigh => 'Volume máximo';

  @override
  String get muscleMapEmpty => 'Registre uma sessão e seu corpo começará a aparecer aqui.';

  @override
  String get muscleMapHint => 'Toque em um músculo para ver o que ele treinou.';

  @override
  String muscleMapBehind(String names) {
    return 'Ficando para trás: $names';
  }

  @override
  String ofTarget(int pct) {
    return '$pct% da meta';
  }

  @override
  String get recoveryTab => 'Recuperação';

  @override
  String recoveryOverall(int pct) {
    return 'Corpo $pct% recuperado';
  }

  @override
  String get recoveryAllFresh => 'Tudo recuperado. Bom dia para treinar o que quiser.';

  @override
  String recoveryStill(String muscles) {
    return 'Ainda se recuperando: $muscles';
  }

  @override
  String get recoveryTired => 'Fadigado';

  @override
  String get recoveryFresh => 'Descansado';

  @override
  String get recoveryHint =>
      'Toque num músculo para ver quanto ele se recuperou. Séries recentes pesam mais, e as mais pesadas (pelo RPE) mais ainda.';

  @override
  String recoveryPct(int pct) {
    return '$pct% recuperado';
  }

  @override
  String readyInHours(int h) {
    return 'pronto em ~$h h';
  }

  @override
  String get muscleSplit => 'DIVISÃO MUSCULAR';

  @override
  String get splitEmpty => 'Treine para ver como seu volume se divide entre os grupos musculares.';

  @override
  String get personalRecords => 'RECORDES PESSOAIS';

  @override
  String get prEmpty => 'Seus recordes aparecerão aqui conforme você registrar séries.';

  @override
  String get strength1rm => 'FORÇA · 1RM ESTIMADO';

  @override
  String get strengthEmpty => 'Registre um exercício duas vezes para ver sua curva de força aqui.';

  @override
  String oneRmEst(String w) {
    return '1RM est. $w';
  }

  @override
  String get restDayShort => 'Dia de descanso';

  @override
  String get restDay => 'Dia de descanso. Nada registrado.';

  @override
  String get tapToDelete => 'Toque na lixeira para remover um registro incorreto.';

  @override
  String get delete => 'Excluir';

  @override
  String get deleteEntry => 'Excluir este registro?';

  @override
  String deleteEntryBody(String name) {
    return '\"$name\" será removido deste dia, dos seus registros e gráficos.';
  }

  @override
  String get bodyweightHistory => 'HISTÓRICO';

  @override
  String get workoutProgression => 'PROGRESSÃO POR TREINO';

  @override
  String avgDiff(String diff) {
    return 'Média: $diff';
  }

  @override
  String get noBodyweightYet => 'Nada registrado ainda.';

  @override
  String get exercisesCaps => 'EXERCÍCIOS';

  @override
  String get timeCaps => 'TEMPO';

  @override
  String libraryCount(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n exercícios na sua biblioteca',
      one: '$n exercício na sua biblioteca',
    );
    return '$_temp0';
  }

  @override
  String get searchExercises => 'Buscar exercícios';

  @override
  String get muscleFilter => 'MÚSCULO';

  @override
  String get levelFilter => 'NÍVEL';

  @override
  String get newExercise => 'NOVO EXERCÍCIO';

  @override
  String get exerciseName => 'Nome do exercício';

  @override
  String get equipmentLabel => 'EQUIPAMENTO';

  @override
  String get addExercise => 'ADICIONAR EXERCÍCIO';

  @override
  String get advanced => 'AVANÇADO';

  @override
  String get demoMedia => 'DEMO';

  @override
  String get addMedia => 'Adicionar mídia';

  @override
  String get mediaHint => 'Imagem, GIF ou vídeo';

  @override
  String get changeMedia => 'Alterar';

  @override
  String get videoSelected => 'Vídeo selecionado';

  @override
  String get favouritesOnly => 'Favoritos';

  @override
  String get noFavouritesYet => 'Nenhum favorito ainda';

  @override
  String get noFavouritesHint => 'Toque na estrela de um exercício para mantê-lo aqui.';

  @override
  String get clearFilters => 'Limpar filtros';

  @override
  String get noExercisesFound => 'Nenhum exercício encontrado';

  @override
  String get noExercisesHint => 'Tente outra busca ou limpe seus filtros.';

  @override
  String get personalRecord => 'RECORDE PESSOAL';

  @override
  String get history => 'HISTÓRICO';

  @override
  String get noHistory => 'Nenhuma sessão registrada. Treine este exercício para criar um histórico.';

  @override
  String get notes => 'NOTAS';

  @override
  String get notePlaceholder => 'Dicas, preparação, como foi…';

  @override
  String showAllNotes(int n) {
    return 'Mostrar todas as $n notas';
  }

  @override
  String get showFewerNotes => 'Mostrar menos';

  @override
  String moreNotes(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n notas a mais',
      one: '$n nota a mais',
    );
    return '$_temp0';
  }

  @override
  String get howTo => 'COMO FAZER';

  @override
  String get similar => 'SEMELHANTES';

  @override
  String get primaryLabel => 'PRINCIPAL';

  @override
  String get secondaryLabel => 'SECUNDÁRIO';

  @override
  String get none => 'Nenhum';

  @override
  String setCount(int n) {
    String _temp0 = intl.Intl.pluralLogic(n, locale: localeName, other: '$n séries', one: '$n série');
    return '$_temp0';
  }

  @override
  String volumeSuffix(String v) {
    return '$v de volume';
  }

  @override
  String get weeklyPlan => 'PLANO SEMANAL DE TREINO';

  @override
  String get yourRoutines => 'SEUS TREINOS';

  @override
  String get noRoutines => 'Nenhum treino ainda. Crie um e adicione seus exercícios.';

  @override
  String get newRoutine => 'NOVO TREINO';

  @override
  String get routineName => 'Nome do treino';

  @override
  String get schedule => 'PROGRAMAÇÃO';

  @override
  String get addFromList => 'Adicione exercícios da lista abaixo.';

  @override
  String get addExercises => 'Adicionar exercícios';

  @override
  String get deleteRoutine => 'Excluir esta rotina?';

  @override
  String exercisesWithCount(int n) {
    return 'EXERCÍCIOS · $n';
  }

  @override
  String setDay(String day) {
    return 'DEFINIR $day';
  }

  @override
  String get newRoutineName => 'Novo treino';

  @override
  String get dragToReorder => 'Toque e arraste para reordenar. Esta é a ordem do seu treino.';

  @override
  String reorderHandle(String name) {
    return 'Reordenar $name';
  }

  @override
  String get removeFromRoutine => 'Remover da rotina';

  @override
  String get dropExercise => 'Remover este exercício?';

  @override
  String dropExerciseBody(String name) {
    return '\"$name\" sairá deste treino. Nada registrado será perdido.';
  }

  @override
  String get drop => 'Remover';

  @override
  String get addToWorkout => 'ADICIONAR UM EXERCÍCIO';

  @override
  String get resetData => 'Excluir todos os meus dados';

  @override
  String get resetTitle => 'Excluir tudo?';

  @override
  String get resetBody =>
      'Sessões, recordes, rotinas, notas e perfil. Não é possível desfazer. Exporte um backup antes, se precisar.';

  @override
  String get resetConfirm => 'Excluir tudo';

  @override
  String get resetDone => 'Todos os dados foram excluídos';

  @override
  String get support => 'SUPORTE';

  @override
  String get reportBug => 'Relatar um problema';

  @override
  String get requestFeature => 'Sugerir recurso';

  @override
  String get starOnGithub => 'Favoritar no GitHub';

  @override
  String get buyCoffee => 'Pagar um café';

  @override
  String get cantOpenLink => 'Não foi possível abrir o link';

  @override
  String get preferences => 'PREFERÊNCIAS';

  @override
  String get theme => 'Tema';

  @override
  String get darkTheme => 'Escuro';

  @override
  String get lightTheme => 'Claro';

  @override
  String get languageLabel => 'Idioma';

  @override
  String get unitsLabel => 'Unidades';

  @override
  String get restTimer => 'Temporizador de descanso';

  @override
  String get alarmBlockedTitle => 'Notificações desativadas';

  @override
  String get alarmBlockedBody => 'O alarme de descanso não tocará com a tela bloqueada';

  @override
  String get alarmBlockedAction => 'ATIVAR';

  @override
  String get alarmXiaomiTitle => 'HyperOS / Xiaomi detectado';

  @override
  String get alarmXiaomiBody =>
      'Ative o \'Início automático\' e defina a bateria como \'Sem restrições\' para que o alarme funcione de forma confiável.';

  @override
  String get alarmSound => 'Som do alarme';

  @override
  String get alarmDefaultName => 'Padrão';

  @override
  String get alarmSoundHint => 'Use o seu próprio som, com até 15 segundos';

  @override
  String get alarmChoose => 'Escolher um som…';

  @override
  String get alarmPreview => 'Reproduzir som atual';

  @override
  String get alarmReset => 'Voltar ao padrão';

  @override
  String get alarmTooLong => 'Esse som tem mais de 15 segundos';

  @override
  String get alarmInvalid => 'Não foi possível ler esse arquivo de áudio';

  @override
  String alarmChanged(String name) {
    return 'Som do alarme definido como \"$name\"';
  }

  @override
  String get alarmChangedDefault => 'Som padrão restaurado';

  @override
  String get enablePhotosLabel => 'Fotos de progresso';

  @override
  String get enablePhotosHint => 'Tirar fotos antes ou depois do treino';

  @override
  String get photoTimingLabel => 'Quando tirar foto';

  @override
  String get photoTimingBefore => 'Antes';

  @override
  String get photoTimingAfter => 'Depois';

  @override
  String get photoTimingBoth => 'Ambos';

  @override
  String get onbPhotosTitle => 'Fotos de progresso?';

  @override
  String get onbPhotosWhy => 'Compare seu corpo antes e depois de cada treino visualmente.';

  @override
  String get homeWidgets => 'TELA INICIAL';

  @override
  String get addActivityWidget => 'Adicionar widget de atividade';

  @override
  String get addStatsWidget => 'Adicionar widget de estatísticas';

  @override
  String get pinUnsupported => 'Adicione pelo menu de widgets do seu launcher';

  @override
  String get background => 'Fundo';

  @override
  String get bgNone => 'Nenhum';

  @override
  String get bgDots => 'Pontos';

  @override
  String get bgGrid => 'Grade';

  @override
  String get data => 'DADOS';

  @override
  String get exportCsv => 'Exportar treinos (CSV)';

  @override
  String get exportBackup => 'Exportar backup (JSON)';

  @override
  String get importBackup => 'Importar backup';

  @override
  String get importHint =>
      'Escolha um backup .json exportado do FIT//IRON. Isso substituirá seus dados atuais.';

  @override
  String get import => 'Importar';

  @override
  String get chooseFile => 'Escolher arquivo';

  @override
  String get importFromApp => 'Importar de outro app';

  @override
  String get importUnknownFormat => 'Este arquivo não é uma exportação do Hevy, Strong ou FitNotes';

  @override
  String get importZipNoWeights => 'Esse arquivo zip não contém um arquivo de pesos';

  @override
  String importWeights(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: 'Importados $n registros de peso',
      one: 'Importado $n registro de peso',
    );
    return '$_temp0';
  }

  @override
  String get importReadFailed => 'Não foi possível ler esse arquivo';

  @override
  String get importUnitTitle => 'Em qual unidade está esse arquivo?';

  @override
  String get importUnitBody => 'Esta exportação não informa em qual unidade os pesos estão.';

  @override
  String get importNothing => 'Nada novo para importar';

  @override
  String importDone(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: 'Importadas $n sessões',
      one: 'Importada $n sessão',
    );
    return '$_temp0';
  }

  @override
  String get aboutFitiron => 'Sobre o FIT//IRON';

  @override
  String get yourProfile => 'SEU PERFIL';

  @override
  String get autofills => 'Preenche as calculadoras automaticamente';

  @override
  String get nameLabel => 'NOME';

  @override
  String get sexLabel => 'SEXO';

  @override
  String get male => 'Masculino';

  @override
  String get female => 'Feminino';

  @override
  String get ageLabel => 'IDADE';

  @override
  String get heightLabel => 'ALTURA';

  @override
  String get weightLabel => 'PESO';

  @override
  String get weeklyGoal => 'META SEMANAL';

  @override
  String get activityLabel => 'ATIVIDADE';

  @override
  String get addPhoto => 'Adicionar foto';

  @override
  String get removePhoto => 'Remover foto';

  @override
  String get takePhoto => 'Tirar foto';

  @override
  String get photoBefore => 'Foto antes';

  @override
  String get photoAfter => 'Foto depois';

  @override
  String get photoGallery => 'GALERIA DE FOTOS';

  @override
  String get noPhotosYet => 'Nenhuma foto registrada ainda.';

  @override
  String get confirmPhoto => 'Usar esta foto';

  @override
  String get retakePhoto => 'Tirar outra';

  @override
  String get chooseGallery => 'Escolher da galeria';

  @override
  String get backupCopied => 'Backup copiado para a área de transferência';

  @override
  String get backupImported => 'Backup importado';

  @override
  String get backupFailed => 'Não foi possível ler esse backup';

  @override
  String get nothingToExport => 'Nada para exportar ainda. Registre uma sessão primeiro';

  @override
  String get athlete => 'Atleta';

  @override
  String calculatorsCount(int n) {
    return '$n calculadoras para seu treino';
  }

  @override
  String get result => 'RESULTADO';

  @override
  String get weightLifted => 'PESO LEVANTADO';

  @override
  String get repsPerformed => 'REPETIÇÕES REALIZADAS';

  @override
  String get neck => 'PESCOÇO';

  @override
  String get waist => 'CINTURA';

  @override
  String get hip => 'QUADRIL (para mulheres)';

  @override
  String get targetWeight => 'PESO-ALVO';

  @override
  String get workingWeight => 'PESO DE TRABALHO';

  @override
  String get activityLevel => 'NÍVEL DE ATIVIDADE';

  @override
  String get barWeight => 'PESO DA BARRA';

  @override
  String get perSide => 'POR LADO';

  @override
  String get justTheBar => 'Apenas a barra.';

  @override
  String perSideCount(int n) {
    return '× $n por lado';
  }

  @override
  String rampSet(String pct, int reps) {
    return '$pct · $reps repetições';
  }

  @override
  String get toolNameRm => '1RM';

  @override
  String get toolNameBmi => 'IMC';

  @override
  String get toolNameCal => 'Calorias';

  @override
  String get toolNameBf => 'Gordura corporal';

  @override
  String get toolNamePlate => 'Anilhas';

  @override
  String get toolNameWarmup => 'Aquecimento';

  @override
  String get toolTitleRm => 'Calculadora de 1RM';

  @override
  String get toolTitleBmi => 'Calculadora de IMC';

  @override
  String get toolTitleCal => 'Calorias e macros';

  @override
  String get toolTitleBf => '% de gordura corporal';

  @override
  String get toolTitlePlate => 'Calculadora de anilhas';

  @override
  String get toolTitleWarmup => 'Séries de aquecimento';

  @override
  String get toolHintRm => 'Máximo estimado de 1 repetição (fórmula de Epley)';

  @override
  String get toolHintCal => 'Manutenção diária estimada';

  @override
  String get toolHintBf => 'Estimativa pelo método da Marinha dos EUA';

  @override
  String get toolHintPlate => 'Peso total da barra';

  @override
  String get toolHintWarmup => 'Meta de peso de trabalho';

  @override
  String get toolDescRm => 'Máximo estimado de uma repetição';

  @override
  String get toolDescBmi => 'Índice de massa corporal';

  @override
  String get toolDescCal => 'Calorias e macronutrientes';

  @override
  String get toolDescBf => 'Percentual de gordura corporal';

  @override
  String get toolDescPlate => 'Calculadora de anilhas para barra';

  @override
  String get toolDescWarmup => 'Séries de progressão';

  @override
  String get macroProtein => 'PROTEÍNA';

  @override
  String get macroCarbs => 'CARBOIDRATOS';

  @override
  String get macroFat => 'GORDURA';

  @override
  String get bmiUnderweight => 'Abaixo do peso';

  @override
  String get bmiNormal => 'Normal';

  @override
  String get bmiOverweight => 'Sobrepeso';

  @override
  String get bmiObese => 'Obesidade';

  @override
  String get actSedentary => 'Sedentário';

  @override
  String get actLight => 'Levemente ativo';

  @override
  String get actActive => 'Ativo';

  @override
  String get actModerate => 'Moderadamente ativo';

  @override
  String get muscleChest => 'Peito';

  @override
  String get muscleBack => 'Costas';

  @override
  String get muscleShoulders => 'Ombros';

  @override
  String get muscleBiceps => 'Bíceps';

  @override
  String get muscleTriceps => 'Tríceps';

  @override
  String get muscleForearm => 'Antebraço';

  @override
  String get muscleTrapezius => 'Trapézio';

  @override
  String get muscleAbdomen => 'Abdômen';

  @override
  String get muscleObliques => 'Oblíquos';

  @override
  String get muscleQuads => 'Quadríceps';

  @override
  String get muscleHamstrings => 'Posteriores de coxa';

  @override
  String get muscleGlutes => 'Glúteos';

  @override
  String get muscleCalves => 'Panturrilhas';

  @override
  String get mgChest => 'Peito';

  @override
  String get mgBack => 'Costas';

  @override
  String get mgLegs => 'Pernas';

  @override
  String get mgShoulders => 'Ombros';

  @override
  String get mgArms => 'Braços';

  @override
  String get mgCore => 'Core';

  @override
  String get equipBarbell => 'Barra';

  @override
  String get equipDumbbell => 'Halteres';

  @override
  String get equipCable => 'Cabo (pulley)';

  @override
  String get equipMachine => 'Máquina';

  @override
  String get equipBodyweight => 'Peso corporal';

  @override
  String get equipWeighted => 'Com peso';

  @override
  String get equipBand => 'Elástico';

  @override
  String get equipKettlebell => 'Kettlebell';

  @override
  String get equipOther => 'Outro';

  @override
  String get diffBeginner => 'Iniciante';

  @override
  String get diffAdvanced => 'Avançado';

  @override
  String get diffIntermediate => 'Intermediário';

  @override
  String get about => 'SOBRE';

  @override
  String version(String v) {
    return 'Versão $v';
  }

  @override
  String get aboutBlurb => 'Feito por quem treina, para quem treina.';

  @override
  String get freeForever => 'Grátis para sempre';

  @override
  String get freeForeverWhy => 'Sem assinatura, sem anúncios, nada bloqueado por pagamento.';

  @override
  String get fullyOffline => 'Totalmente offline';

  @override
  String get fullyOfflineWhy => 'Sem conta, sem servidores. Seu treino nunca sai deste celular.';

  @override
  String get yoursToTake => 'Seus dados são seus';

  @override
  String get yoursToTakeWhy => 'Exporte para CSV quando quiser e exclua tudo com um toque.';

  @override
  String get whatsInside => 'O QUE TEM AQUI';

  @override
  String exercisesInside(int n) {
    return '$n exercícios';
  }

  @override
  String get exercisesInsideWhy => 'Todos com animação e instruções passo a passo.';

  @override
  String get calculatorsInside => '6 calculadoras';

  @override
  String get calculatorsInsideWhy =>
      '1RM, anilhas, IMC, calorias, gordura corporal e aquecimento, com fórmulas publicadas.';

  @override
  String get mathInside => 'Matemática honesta';

  @override
  String get mathInsideWhy =>
      'Volume, recordes e ofensivas vêm das suas próprias séries. Nada aqui é decoração.';

  @override
  String get yourNumbers => 'SEUS NÚMEROS';

  @override
  String get sessionsCaps => 'SESSÕES';

  @override
  String get liftedCaps => 'LEVANTADO';

  @override
  String get streakCaps => 'OFENSIVA';

  @override
  String daysUnit(int n) {
    String _temp0 = intl.Intl.pluralLogic(n, locale: localeName, other: 'dias', one: 'dia');
    return '$_temp0';
  }

  @override
  String get restDefaultLabel => 'Temporizador de descanso';

  @override
  String restDefault(int s) {
    return 'O padrão é ${s}s. Altere em Configurações';
  }

  @override
  String get reset => 'REDEFINIR';

  @override
  String get welcomeKicker => 'BEM-VINDO AO';

  @override
  String get welcomeBlurb => 'Tudo fica no seu celular. Sem conta, internet ou custos.';

  @override
  String get welcomeStart => 'COMEÇAR';

  @override
  String onbStep(int i, int n) {
    return 'ETAPA $i DE $n';
  }

  @override
  String get onbNameTitle => 'Como devemos chamar você?';

  @override
  String get onbNameHint => 'Seu nome';

  @override
  String get onbNameWhy => 'Usado apenas para cumprimentar você. Nunca sai do celular.';

  @override
  String get onbBodyTitle => 'Alguns números';

  @override
  String get onbBodyWhy => 'Eles alimentam as calculadoras. Você pode alterá-los em Configurações.';

  @override
  String get onbGoalTitle => 'Com que frequência você treina?';

  @override
  String get onbGoalWhy => 'Define o anel da sua meta semanal. Seja honesto, não ambicioso.';

  @override
  String perWeek(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n sessões por semana',
      one: '$n sessão por semana',
    );
    return '$_temp0';
  }

  @override
  String get onbUnitsTitle => 'Quilos ou libras?';

  @override
  String get onbFocusTitle => 'Qual é o seu foco?';

  @override
  String get onbFocusWhy => 'Sugerimos exercícios que combinam com o seu objetivo principal.';

  @override
  String get focusHypertrophy => 'Hipertrofia';

  @override
  String get focusStrength => 'Força';

  @override
  String get focusWeightLoss => 'Emagrecimento';

  @override
  String get focusEndurance => 'Resistência';

  @override
  String get focusHealth => 'Saúde geral';

  @override
  String get next => 'PRÓXIMO';

  @override
  String get back => 'VOLTAR';

  @override
  String get skip2 => 'Pular';

  @override
  String get artCredit => 'Ilustrações dos exercícios por Bryl Lim e Everkinetic';

  @override
  String get muscleWarmup => 'Flexibilidade / Aquecimento';

  @override
  String get muscleCardio => 'Cardio';

  @override
  String get exploreDetails => 'Explorar detalhes';

  @override
  String get currentWeekPeriod => 'Semana atual';

  @override
  String get muscleDistribution => 'Distribuição Muscular';

  @override
  String get tabWeek => 'SEMANA';

  @override
  String get tabMonth => 'MÊS';

  @override
  String get tabYear => 'ANO';

  @override
  String get equivalentSets => 'Séries equivalentes';

  @override
  String get equivalentVolume => 'Volume equivalente';

  @override
  String get previousWeekPeriod => 'Semana anterior';

  @override
  String get currentMonthPeriod => 'Mês atual';

  @override
  String get previousMonthPeriod => 'Mês anterior';

  @override
  String get currentYearPeriod => 'Ano atual';

  @override
  String get previousYearPeriod => 'Ano anterior';

  @override
  String get equivalentSetsInfoDesc =>
      'Sua distribuição muscular semanal é calculada com base nas séries que você completa em todos os seus treinos.\n\nMúsculos primários contam como 1 série completa por série realizada. Músculos secundários contam como 0.5 séries, pois auxiliam no movimento.\n\nIsso ajuda a criar uma visão mais precisa de como cada grupo muscular está sendo treinado, permitindo comparações entre diferentes períodos. É especialmente útil para usuários que mudam seu plano de treino com frequência, principalmente aqueles que registram treinos manualmente usando Treino Personalizado ou Treino Rápido.';

  @override
  String get equivalentVolumeInfoDesc =>
      'Sua distribuição muscular semanal é calculada com base no volume total (séries, repetições e carga) que você completa em todos os seus treinos.\n\nMúsculos primários contam como 1 série completa por série realizada. Músculos secundários contam como 0.5 séries, pois auxiliam no movimento.\n\nIsso ajuda a criar uma visão mais precisa de como cada grupo muscular está sendo treinado, permitindo comparações entre diferentes períodos. É especialmente útil para usuários que mudam seu plano de treino com frequência, principalmente aqueles que registram treinos manualmente usando Treino Personalizado ou Treino Rápido.';

  @override
  String get weeklyProgressTitle => 'PROGRESSO SEMANAL';

  @override
  String get weeklyNoData => 'Nada para mostrar ainda';

  @override
  String get weeklyNoDataSub => 'Os resultados aparecerão após o seu primeiro treino.';

  @override
  String get tabTime => 'TEMPO';

  @override
  String get tabVolume => 'VOLUME';

  @override
  String get tabReps => 'REPS';

  @override
  String get profile => 'Perfil';

  @override
  String get editProfile => 'Editar perfil';

  @override
  String get pickBadge => 'Selo';

  @override
  String get badgeTitle => 'Seu selo';

  @override
  String badgeName(String id) {
    String _temp0 = intl.Intl.selectLogic(id, {
      'gold': 'Dourado',
      'blue': 'Azul',
      'green': 'Verde',
      'other': 'Selo',
    });
    return '$_temp0';
  }

  @override
  String memberSince(String date) {
    return 'Membro desde $date';
  }

  @override
  String get coverLabel => 'CAPA';

  @override
  String get removeCover => 'Remover capa';

  @override
  String get statWorkouts => 'Treinos';

  @override
  String get statTrained => 'Treinado';

  @override
  String get statSets => 'Séries';

  @override
  String get statLifted => 'Levantado';

  @override
  String get statStreak => 'Sequência';

  @override
  String get statDays => 'dias';

  @override
  String get unitHours => 'h';

  @override
  String get unitDays => 'd';

  @override
  String levelShort(int n) {
    return 'Nível $n';
  }

  @override
  String levelToNext(int n, int next) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n treinos para o nível $next',
      one: '1 treino para o nível $next',
    );
    return '$_temp0';
  }

  @override
  String get yearTitle => 'Seu ano';

  @override
  String get yearBestMonth => 'Melhor mês';

  @override
  String get yearMonths => 'meses';

  @override
  String get awardsTitle => 'Medalhas';

  @override
  String get awardsEarned => 'Conquistadas';

  @override
  String get awardsLocked => 'A conquistar';

  @override
  String get awardWon => 'Conquistada';

  @override
  String awardWonOn(String date) {
    return 'Conquistada em $date';
  }

  @override
  String awardProgressLabel(String value, String goal) {
    return '$value de $goal';
  }

  @override
  String get awardSpinHint => 'Arraste a medalha para girá-la';

  @override
  String get awardUnlocked => 'Nova conquista desbloqueada';

  @override
  String get awardNice => 'Boa!';

  @override
  String get awardSaveImage => 'Salvar imagem';

  @override
  String get awardSaved => 'Salva na sua galeria';

  @override
  String get gamificationSetting => 'Medalhas e níveis';

  @override
  String get shareFailed => 'Não foi possível gerar a imagem';

  @override
  String get addCover => 'Adicionar capa';

  @override
  String get handleLabel => 'Nome de usuário';

  @override
  String get snapshots => 'Fotos';

  @override
  String get snapNow => 'Tirar foto';

  @override
  String get photosCard => 'Galeria';

  @override
  String get awardFirstStepName => 'Primeiro passo';

  @override
  String get awardFirstStepLine => 'Bem-vindo ao FIT//IRON. Esta é por conta da casa.';

  @override
  String get awardFirstWorkoutName => 'Primeiro treino';

  @override
  String get awardFirstWorkoutLine => 'O primeiro já está registrado. Esse é o difícil.';

  @override
  String get awardFirstRoutineName => 'Primeira rotina';

  @override
  String get awardFirstRoutineLine => 'Você tem um plano ao qual voltar.';

  @override
  String get awardFirstRecordName => 'Primeiro recorde';

  @override
  String get awardFirstRecordLine => 'Superou sua melhor marca em um exercício.';

  @override
  String get awardStreak3Name => 'Três seguidos';

  @override
  String get awardStreak3Line => 'Três dias seguidos. É assim que começa.';

  @override
  String get awardStreak7Name => 'Sete dias';

  @override
  String get awardStreak7Line => 'Uma semana inteira sem falhar um dia.';

  @override
  String get awardStreak30Name => 'Trinta dias';

  @override
  String get awardStreak30Line => 'Um mês seguido. Agora já é hábito.';

  @override
  String get awardStreak100Name => 'Cem dias';

  @override
  String get awardStreak100Line => 'Cem dias seguidos. Isso já não é motivação, é quem você é.';

  @override
  String get awardWorkouts10Name => 'Dez treinos';

  @override
  String get awardWorkouts10Line => 'Os dez primeiros são os que decidem.';

  @override
  String get awardWorkouts50Name => 'Cinquenta treinos';

  @override
  String get awardWorkouts50Line => 'Cinquenta sessões nas suas costas.';

  @override
  String get awardWorkouts100Name => 'Cem treinos';

  @override
  String get awardWorkouts100Line => 'Cem sessões registradas do início ao fim.';

  @override
  String get awardWorkouts365Name => 'Trezentos e sessenta e cinco';

  @override
  String get awardWorkouts365Line => 'Um treino para cada dia do ano, registrados um a um.';

  @override
  String get awardTonne1Name => 'Uma tonelada';

  @override
  String get awardTonne1Line => 'Mil quilos levantados entre todas as suas séries.';

  @override
  String get awardTonnes10Name => 'Dez toneladas';

  @override
  String get awardTonnes10Line => 'Dez mil quilos já passaram pelas suas mãos.';

  @override
  String get awardTonnes100Name => 'Cem toneladas';

  @override
  String get awardTonnes100Line => 'Tudo o que você levantou soma 100.000 kg.';

  @override
  String get awardSets100Name => 'Cem séries';

  @override
  String get awardSets100Line => 'Cem séries concluídas, uma a uma.';

  @override
  String get awardSets1000Name => 'Mil séries';

  @override
  String get awardSets1000Line => 'Série a série, até mil.';

  @override
  String get awardHours10Name => 'Dez horas';

  @override
  String get awardHours10Line => 'Dez horas de treino cronometradas.';

  @override
  String get awardHours50Name => 'Cinquenta horas';

  @override
  String get awardHours50Line => 'Cinquenta horas dentro da academia.';

  @override
  String get awardHours100Name => 'Cem horas';

  @override
  String get awardHours100Line => 'Cem horas debaixo da barra, cronômetro na mão.';
}
